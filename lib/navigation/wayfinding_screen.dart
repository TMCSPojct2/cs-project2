import 'dart:math';

import 'package:flutter/material.dart';

import 'building_data.dart';
import 'floor_plan_painter.dart';
import 'models.dart';
import 'pathfinder.dart';

class WayfindingScreen extends StatefulWidget {
  final String? initialDestinationQuery;
  final String? initialDestinationId;
  const WayfindingScreen({
    super.key,
    this.initialDestinationQuery,
    this.initialDestinationId,
  });

  @override
  State<WayfindingScreen> createState() => _WayfindingScreenState();
}

enum _SearchTarget { source, destination }

class _WayfindingScreenState extends State<WayfindingScreen> with SingleTickerProviderStateMixin {
  late final Pathfinder _pathfinder;
  late final AnimationController _animationController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String? _sourceId;
  String? _destinationId;
  int _floor = 0;
  List<NavNode>? _route;
  late final List<Room> _allNavigableRooms;
  String _searchQuery = '';
  bool _showSearch = false;
  String? _highlightRoomId;
  _SearchTarget _searchTarget = _SearchTarget.source;
  int _routeStepCount = 0;
  int _currentStepIndex = 0;
  Set<int> _routeFloors = {};
  Room? _tappedRoom;
  final TransformationController _transformationController = TransformationController();

  @override
  void initState() {
    super.initState();
    _pathfinder = Pathfinder();
    _allNavigableRooms = BuildingData.navigableRooms;
    _animationController = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialDestinationId != null && widget.initialDestinationId!.isNotEmpty) {
        final roomId = widget.initialDestinationId!;
        try {
          final room = _allNavigableRooms.firstWhere((r) => r.id == roomId);
          setState(() {
            _destinationId = roomId;
            _highlightRoomId = roomId;
            _floor = room.floor;
            _showSearch = false;
          });
          return;
        } catch (_) {}
      }
      if (widget.initialDestinationQuery != null && widget.initialDestinationQuery!.isNotEmpty) {
        setState(() {
          _searchTarget = _SearchTarget.destination;
          _showSearch = true;
          _searchQuery = widget.initialDestinationQuery!;
          _searchController.text = widget.initialDestinationQuery!;
        });
        _searchFocus.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _searchFocus.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _openSearch(_SearchTarget target) {
    setState(() {
      _searchTarget = target;
      _showSearch = true;
      _searchQuery = '';
      _searchController.clear();
      _tappedRoom = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _searchFocus.requestFocus());
  }

  void _navigate() {
    if (_sourceId == null || _destinationId == null || _sourceId == _destinationId) return;
    final path = _pathfinder.findPath(_sourceId!, _destinationId!);
    setState(() {
      _route = path;
      _currentStepIndex = 0;
      if (path != null) {
        _routeFloors = path.map((node) => node.floor).toSet();
        _routeStepCount = path.length;
        _floor = path.first.floor;
      } else {
        _routeFloors = {};
        _routeStepCount = 0;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر العثور على مسار')));
      }
    });
  }

  void _clear() {
    setState(() {
      _route = null; _sourceId = null; _destinationId = null;
      _highlightRoomId = null; _showSearch = false; _searchQuery = '';
      _searchController.clear(); _routeFloors = {}; _routeStepCount = 0;
      _currentStepIndex = 0; _tappedRoom = null;
    });
  }

  void _selectRoom(Room room) {
    setState(() {
      _showSearch = false; _searchQuery = ''; _searchController.clear();
      if (_searchTarget == _SearchTarget.source) {
        _sourceId = room.id;
      } else {
        _destinationId = room.id;
      }
      _floor = room.floor;
      _highlightRoomId = room.id;
    });
    if (_sourceId != null && _destinationId != null) _navigate();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        if (isWide) {
          final panelWidth = min(380.0, constraints.maxWidth * 0.31);
          final mapPadding = EdgeInsets.only(left: panelWidth + 28, right: 8, top: 8, bottom: 8);
          return Stack(children: [
            _buildMap(mapPadding),
            _buildFloatingBanner(true),
            _buildInteractivePanel(isWide: true, panelWidth: panelWidth, maxHeight: constraints.maxHeight, narrowPanelMaxH: 0),
            _buildFloorPicker(true),
            if (_tappedRoom != null) _buildRoomInfoCard(),
          ]);
        }
        return Column(children: [
          _buildTopSearchCard(),
          _buildHorizontalFloorPicker(),
          Expanded(child: Stack(children: [
            _buildMap(const EdgeInsets.all(4)),
            if (_showSearch) _buildSearchDropdown(),
            if (_tappedRoom != null && !_showSearch) _buildRoomInfoCardCompact(),
          ])),
          if (_route != null && !_showSearch) _buildStepBar(),
        ]);
      },
    );
  }

  Widget _buildMap(EdgeInsets padding) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      padding: padding,
      child: LayoutBuilder(builder: (context, constraints) {
        // planWidth/planHeight sized to fit ppu=24 building (30×29 units) + title band (62px top)
        const planWidth = 800.0, planHeight = 840.0;
        final scale = min((constraints.maxWidth - 8) / planWidth, (constraints.maxHeight - 8) / planHeight).clamp(0.25, 2.0);
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Center(
            child: InteractiveViewer(
              transformationController: _transformationController,
              minScale: 0.5, maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: GestureDetector(
                onTapDown: (details) => _onMapTap(details, scale),
                child: SizedBox(
                  width: planWidth * scale, height: planHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: CustomPaint(
                      size: const Size(planWidth, planHeight),
                      painter: FloorPlanPainter(
                        floor: _floor, routePath: _route,
                        sourceRoomId: _sourceId, destRoomId: _destinationId,
                        highlightRoomId: _highlightRoomId,
                        animValue: _animationController.value,
                        pixelsPerUnit: 24,
                        buildingTitle: 'مبنى كلية الهندسة والحاسبات بالقنفذة',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _onMapTap(TapDownDetails details, double scale) {
    if (_showSearch) return;
    // ppu=24, title band adds 50px → topY=62, leftX offset=12
    const pixelsPerUnit = 24.0, offsetX = 12.0, offsetY = 62.0;
    final unitX = (details.localPosition.dx / scale - offsetX) / pixelsPerUnit;
    final unitY = (details.localPosition.dy / scale - offsetY) / pixelsPerUnit;
    Room? found;
    for (final room in BuildingData.roomsForFloor(_floor)) {
      if (unitX >= room.x && unitX <= room.x + room.w && unitY >= room.y && unitY <= room.y + room.h) { found = room; break; }
    }
    setState(() => _tappedRoom = (_tappedRoom?.id == found?.id) ? null : found);
  }

  Widget _buildFloatingBanner(bool isWide) {
    if (!isWide || (_destinationId == null && _route == null)) return const SizedBox.shrink();
    final destination = _destinationId != null ? _roomName(_destinationId!) : '';
    final subtitle = _route != null ? 'التوجّه إلى: $destination' : 'الخريطة التفاعلية';
    return Positioned(
      top: 8, left: isWide ? 420 : 92, right: 92,
      child: IgnorePointer(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.38), borderRadius: BorderRadius.circular(18)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(subtitle, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(destination, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractivePanel({required bool isWide, required double panelWidth, required double maxHeight, required double narrowPanelMaxH}) {
    final panel = Material(
      elevation: 14, color: Colors.transparent,
      child: Container(
        width: panelWidth,
        constraints: BoxConstraints(maxHeight: isWide ? maxHeight - 24 : narrowPanelMaxH),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 22, offset: const Offset(0, 10))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Column(children: [
            _buildPanelHeader(), _buildSearchBar(),
            Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 18), child: _showSearch ? _buildSearchPanelBody() : _buildNavigatorPanelBody())),
          ]),
        ),
      ),
    );
    return isWide ? Positioned(left: 12, top: 12, bottom: 12, child: panel) : Positioned(left: 12, right: 12, top: 56, child: panel);
  }

  Widget _buildPanelHeader() {
    final title = _showSearch
        ? (_searchTarget == _SearchTarget.source ? 'اختر نقطة البداية' : 'اختر الوجهة')
        : (_route != null ? (_destinationId != null ? _roomName(_destinationId!) : 'الملاحة') : 'الملاحة التفاعلية');
    final subtitle = _showSearch
        ? 'ابحث باسم الغرفة أو رقمها'
        : (_route != null
            ? 'خطوة ${_currentStepIndex + 1} من ${_buildSimpleSteps().length} • طابق ${floorLabel(_floor)}'
            : 'اختر نقطة البداية والوجهة ليظهر لك المسار');
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        InkWell(
          onTap: () { if (_showSearch) { setState(() => _showSearch = false); } else { _clear(); } },
          borderRadius: BorderRadius.circular(18),
          child: Container(
            width: 44, height: 44, alignment: Alignment.center,
            decoration: BoxDecoration(color: const Color(0xFFF3F5F7), borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.close, color: Color(0xFF263238), size: 26),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF18222D))),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF7B8794), fontWeight: FontWeight.w500)),
        ])),
        if (!_showSearch && _route != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(color: const Color(0xFFEDF4FF), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.alt_route, color: Color(0xFF1E63D5), size: 20),
          ),
      ]),
    );
  }

  Widget _buildNavigatorPanelBody() {
    return ListView(padding: EdgeInsets.zero, children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFB), borderRadius: BorderRadius.circular(22)),
        child: Column(children: [
          _buildRouteInputCard(),
          if (_sourceId != null && _destinationId != null && _route == null) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _navigate,
                icon: const Icon(Icons.navigation_outlined),
                label: const Text('إظهار المسار'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF203864), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
              ),
            ),
          ],
        ]),
      ),
      if (_route != null) ...[
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _buildRouteStatCard(Icons.route, 'الخطوات', '$_routeStepCount')),
          const SizedBox(width: 8),
          Expanded(child: _buildRouteStatCard(Icons.layers_outlined, 'الطوابق', '${_routeFloors.length}')),
          const SizedBox(width: 8),
          Expanded(child: _buildRouteStatCard(Icons.map_outlined, 'الحالي', floorLabel(_floor))),
        ]),
        const SizedBox(height: 12),
        _buildStepNavigator(),
      ] else const SizedBox(height: 6),
    ]);
  }

  Widget _buildSearchPanelBody() {
    final filteredRooms = _allNavigableRooms.where((room) {
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      return room.name.toLowerCase().contains(query) || room.shortName.toLowerCase().contains(query) || room.id.toLowerCase().contains(query);
    }).toList();

    return Column(children: [
      TextField(
        controller: _searchController, focusNode: _searchFocus, autofocus: true,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: _searchTarget == _SearchTarget.source ? 'ابحث عن نقطة البداية' : 'ابحث عن الوجهة',
          hintStyle: const TextStyle(color: Color(0xFF9AA6B2)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF5E6A76)),
          suffixIcon: _searchQuery.isEmpty ? null : IconButton(
            onPressed: () => setState(() { _searchQuery = ''; _searchController.clear(); }),
            icon: const Icon(Icons.close, color: Color(0xFF9AA6B2)),
          ),
          filled: true, fillColor: const Color(0xFFF6F8FA),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: Container(
          decoration: BoxDecoration(color: const Color(0xFFFDFDFD), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE8EDF2))),
          child: filteredRooms.isEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.search_off_rounded, size: 44, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('لا توجد نتائج', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                  const SizedBox(height: 4),
                  Text('جرّب كلمة أخرى', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                ]))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredRooms.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                  itemBuilder: (context, index) => _searchResultTile(filteredRooms[index]),
                ),
        ),
      ),
    ]);
  }

  Widget _buildSearchBar() {
    if (_showSearch) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: InkWell(
        onTap: () => _openSearch(_sourceId == null ? _SearchTarget.source : _SearchTarget.destination),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 52, padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(color: const Color(0xFFF6F8FA), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE8EDF2))),
          child: Row(children: [
            const Icon(Icons.search, color: Color(0xFF546E7A)), const SizedBox(width: 12),
            Expanded(child: Text(
              _sourceId == null ? 'ابحث عن نقطة البداية أو الوجهة' : _destinationId == null ? 'ابحث عن الوجهة' : 'ابحث عن غرفة',
              style: const TextStyle(fontSize: 14, color: Color(0xFF7B8794)),
            )),
            if (_sourceId != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14)), child: const Text('بداية', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32)))),
            if (_sourceId != null && _destinationId != null) const SizedBox(width: 8),
            if (_destinationId != null) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(14)), child: const Text('وجهة', style: TextStyle(fontSize: 12, color: Color(0xFFC62828)))),
          ]),
        ),
      ),
    );
  }

  Widget _buildStepNavigator() {
    final steps = _buildSimpleSteps();
    if (steps.isEmpty) return const SizedBox.shrink();
    final stepIndex = _currentStepIndex.clamp(0, steps.length - 1);
    final step = steps[stepIndex];
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _buildStepTile(step, stepIndex),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: OutlinedButton(
          onPressed: stepIndex > 0 ? () => _goToStep(stepIndex - 1) : null,
          style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF1E63D5), side: const BorderSide(color: Color(0xFF1E63D5)), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('السابق'),
        )),
        const SizedBox(width: 10),
        Expanded(child: FilledButton(
          onPressed: stepIndex < steps.length - 1 ? () => _goToStep(stepIndex + 1) : null,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF1E63D5), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
          child: const Text('التالي'),
        )),
      ]),
      const SizedBox(height: 10),
      Text('خطوة ${stepIndex + 1} من ${steps.length}', style: const TextStyle(fontSize: 12, color: Color(0xFF7B8794), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
    ]);
  }

  void _goToStep(int index) {
    final steps = _buildSimpleSteps();
    if (index < 0 || index >= steps.length) return;
    setState(() { _currentStepIndex = index; _floor = steps[index].floor; });
  }

  Widget _buildRouteStatCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFFF5F8FB), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: const Color(0xFF506173)),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF7B8794), fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: Color(0xFF18222D), fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildStepTile(_SimpleStep step, int index) {
    final isActive = step.floor == _floor;
    return InkWell(
      onTap: () => setState(() => _floor = step.floor),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEAF2FF) : const Color(0xFFF8FAFB),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? const Color(0xFF1E63D5) : const Color(0xFFE2E8EE)),
        ),
        child: Row(children: [
          Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: step.color, borderRadius: BorderRadius.circular(12)), child: Icon(step.icon, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('خطوة ${index + 1}', style: const TextStyle(fontSize: 11, color: Color(0xFF7B8794), fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(step.instruction, style: const TextStyle(fontSize: 13, color: Color(0xFF18222D), fontWeight: FontWeight.w600)),
          ])),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: isActive ? const Color(0xFF1E63D5) : const Color(0xFFEFF3F6), borderRadius: BorderRadius.circular(14)),
            child: Text(floorLabel(step.floor), style: TextStyle(fontSize: 11, color: isActive ? Colors.white : const Color(0xFF506173), fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  Widget _buildSearchDropdown() {
    final filteredRooms = _allNavigableRooms.where((room) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return room.name.toLowerCase().contains(q) || room.shortName.toLowerCase().contains(q) || room.id.toLowerCase().contains(q);
    }).toList();

    return Positioned.fill(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() { _showSearch = false; _searchQuery = ''; _searchController.clear(); }),
        child: Container(
          color: Colors.black.withValues(alpha: 0.32),
          child: Align(
            alignment: Alignment.topCenter,
            child: GestureDetector(
              onTap: () {},
              child: Container(
                margin: const EdgeInsets.fromLTRB(10, 6, 10, 20),
                constraints: const BoxConstraints(maxHeight: 420),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 22, offset: const Offset(0, 6))],
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Active search field
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocus,
                      autofocus: true,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: _searchTarget == _SearchTarget.source ? 'ابحث عن نقطة البداية' : 'ابحث عن الوجهة',
                        hintStyle: const TextStyle(color: Color(0xFF9AA6B2)),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF5E6A76), size: 20),
                        suffixIcon: Row(mainAxisSize: MainAxisSize.min, children: [
                          if (_searchQuery.isNotEmpty)
                            IconButton(onPressed: () => setState(() { _searchQuery = ''; _searchController.clear(); }), icon: const Icon(Icons.close, size: 18, color: Color(0xFF9AA6B2))),
                          IconButton(onPressed: () => setState(() { _showSearch = false; _searchQuery = ''; _searchController.clear(); }), icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF546E7A))),
                        ]),
                        filled: true, fillColor: const Color(0xFFF6F8FA),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  // Results list
                  if (filteredRooms.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.search_off_rounded, size: 38, color: Colors.grey[300]),
                        const SizedBox(height: 10),
                        Text('لا توجد نتائج', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[500])),
                      ]),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(bottom: 8),
                        itemCount: filteredRooms.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (_, i) => _searchResultTile(filteredRooms[i]),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopSearchCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE4E9EF)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 18, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
              Container(width: 2, height: 20, color: const Color(0xFFBDBDBD)),
              Container(width: 11, height: 11, decoration: const BoxDecoration(color: Color(0xFFF44336), shape: BoxShape.circle)),
            ]),
          ),
          Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            InkWell(
              onTap: () => _openSearch(_SearchTarget.source),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Padding(padding: const EdgeInsets.fromLTRB(0, 15, 12, 10), child: Text(
                _sourceId != null ? _roomName(_sourceId!) : 'اختر نقطة البداية',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _sourceId != null ? const Color(0xFF1A2330) : const Color(0xFFAAB4BE)),
              )),
            ),
            const Divider(height: 1, endIndent: 12),
            InkWell(
              onTap: () => _openSearch(_SearchTarget.destination),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
              child: Padding(padding: const EdgeInsets.fromLTRB(0, 10, 12, 15), child: Text(
                _destinationId != null ? _roomName(_destinationId!) : 'اختر الوجهة',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _destinationId != null ? const Color(0xFF1A2330) : const Color(0xFFAAB4BE)),
              )),
            ),
          ])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _iconBtn(Icons.swap_vert, onTap: () {
                setState(() { final tmp = _sourceId; _sourceId = _destinationId; _destinationId = tmp; });
                if (_sourceId != null && _destinationId != null) _navigate();
              }),
              if (_sourceId != null || _destinationId != null)
                _iconBtn(Icons.close, color: const Color(0xFF90A4AE), size: 16, onTap: _clear),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _iconBtn(IconData icon, {required VoidCallback onTap, Color color = const Color(0xFF546E7A), double size = 18}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: size, color: color),
      ),
    );
  }

  Widget _buildStepBar() {
    final steps = _buildSimpleSteps();
    if (steps.isEmpty) return const SizedBox.shrink();
    final idx = _currentStepIndex.clamp(0, steps.length - 1);
    final step = steps[idx];
    return Container(
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Color(0x1A000000), blurRadius: 14, offset: Offset(0, -3))]),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 14),
      child: Row(children: [
        _stepNavBtn(Icons.arrow_back_ios_rounded, enabled: idx > 0, onTap: () => _goToStep(idx - 1)),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            Container(width: 34, height: 34, alignment: Alignment.center, decoration: BoxDecoration(color: step.color, borderRadius: BorderRadius.circular(11)), child: Icon(step.icon, color: Colors.white, size: 17)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(step.instruction, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF18222D))),
              Text('خطوة ${idx + 1} من ${steps.length} · طابق ${floorLabel(step.floor)}', style: const TextStyle(fontSize: 11, color: Color(0xFF7B8794))),
            ])),
          ]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(steps.length, (i) {
            final active = i == idx;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: active ? 18 : 6, height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: active ? const Color(0xFF1E63D5) : const Color(0xFFDDE3EC), borderRadius: BorderRadius.circular(3)),
            );
          })),
        ])),
        _stepNavBtn(Icons.arrow_forward_ios_rounded, enabled: idx < steps.length - 1, onTap: () => _goToStep(idx + 1)),
      ]),
    );
  }

  Widget _stepNavBtn(IconData icon, {required bool enabled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 46, height: 46, alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: enabled ? const Color(0xFF1E63D5) : const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(14)),
        child: Icon(icon, size: 18, color: enabled ? Colors.white : const Color(0xFFBBCBD8)),
      ),
    );
  }

  Widget _buildRoomInfoCardCompact() {
    final room = _tappedRoom!;
    final isSource = room.id == _sourceId, isDest = room.id == _destinationId;
    return Positioned(
      top: 8, left: 8, right: 60,
      child: Material(
        elevation: 10, borderRadius: BorderRadius.circular(18), color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 4))]),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
              Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: _iconBackground(room.type), borderRadius: BorderRadius.circular(12)), child: Icon(_iconForType(room.type), size: 18, color: _iconForeground(room.type))),
              const SizedBox(width: 10),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.shortName.replaceAll('\n', ' '), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF18222D))),
                Text('طابق ${floorLabel(room.floor)}', style: const TextStyle(fontSize: 11, color: Color(0xFF7B8794))),
              ])),
              InkWell(onTap: () => setState(() => _tappedRoom = null), child: const Icon(Icons.close, size: 20, color: Color(0xFF90A4AE))),
            ]),
            if (!isSource || !isDest) ...[
              const SizedBox(height: 10),
              Row(children: [
                if (!isSource) Expanded(child: OutlinedButton(
                  onPressed: () { setState(() { _sourceId = room.id; _highlightRoomId = room.id; _floor = room.floor; _tappedRoom = null; _route = null; _routeFloors = {}; _routeStepCount = 0; }); if (_destinationId != null) _navigate(); },
                  style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4CAF50), side: const BorderSide(color: Color(0xFF4CAF50)), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('بداية', style: TextStyle(fontSize: 12)),
                )),
                if (!isSource && !isDest) const SizedBox(width: 8),
                if (!isDest) Expanded(child: FilledButton(
                  onPressed: () { setState(() { _destinationId = room.id; _highlightRoomId = room.id; _floor = room.floor; _tappedRoom = null; }); if (_sourceId != null) _navigate(); },
                  style: FilledButton.styleFrom(backgroundColor: const Color(0xFF203864), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: const Text('وجهة', style: TextStyle(fontSize: 12)),
                )),
              ]),
            ],
          ]),
        ),
      ),
    );
  }

  Widget _buildRoomInfoCard() {
    final room = _tappedRoom!;
    final isSource = room.id == _sourceId, isDest = room.id == _destinationId;
    return Positioned(
      left: 12, right: 12, bottom: 12,
      child: Material(
        elevation: 20, borderRadius: BorderRadius.circular(28), color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.14), blurRadius: 24, offset: const Offset(0, 8))]),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: _iconBackground(room.type), borderRadius: BorderRadius.circular(16)), child: Icon(_iconForType(room.type), size: 24, color: _iconForeground(room.type))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.shortName.replaceAll('\n', ' '), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF18222D))),
                const SizedBox(height: 4),
                Text('طابق ${floorLabel(room.floor)}', style: const TextStyle(fontSize: 12, color: Color(0xFF7B8794))),
              ])),
              InkWell(onTap: () => setState(() => _tappedRoom = null), borderRadius: BorderRadius.circular(12), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 22, color: Color(0xFF90A4AE)))),
            ]),
            if (isSource || isDest) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: isSource ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(14)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isSource ? Icons.trip_origin : Icons.place, size: 16, color: isSource ? const Color(0xFF4CAF50) : const Color(0xFFF44336)),
                  const SizedBox(width: 6),
                  Text(isSource ? 'نقطة البداية المختارة' : 'الوجهة المختارة', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSource ? const Color(0xFF388E3C) : const Color(0xFFC62828))),
                ]),
              ),
            ],
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () { setState(() { _sourceId = room.id; _highlightRoomId = room.id; _floor = room.floor; _tappedRoom = null; _route = null; _routeFloors = {}; _routeStepCount = 0; }); if (_destinationId != null) _navigate(); },
                icon: const Icon(Icons.trip_origin, size: 18), label: const Text('نقطة البداية'),
                style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF4CAF50), side: const BorderSide(color: Color(0xFF4CAF50)), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              )),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(
                onPressed: () { setState(() { _destinationId = room.id; _highlightRoomId = room.id; _floor = room.floor; _tappedRoom = null; }); if (_sourceId != null) _navigate(); },
                icon: const Icon(Icons.place, size: 18), label: const Text('الوجهة'),
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFF203864), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildRouteInputCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        Column(children: [
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF4CAF50), shape: BoxShape.circle)),
          Container(width: 2, height: 14, color: const Color(0xFFBDBDBD)),
          Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF44336), shape: BoxShape.circle)),
        ]),
        const SizedBox(width: 8),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          InkWell(
            onTap: () => _openSearch(_SearchTarget.source),
            borderRadius: BorderRadius.circular(8),
            child: Container(constraints: const BoxConstraints(minHeight: 40), alignment: Alignment.centerLeft,
              child: Text(_sourceId != null ? _roomName(_sourceId!) : 'اختر نقطة البداية', overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _sourceId != null ? const Color(0xFF263238) : const Color(0xFF9AA6B2)))),
          ),
          const Divider(height: 8, thickness: 0.5),
          InkWell(
            onTap: () => _openSearch(_SearchTarget.destination),
            borderRadius: BorderRadius.circular(8),
            child: Container(constraints: const BoxConstraints(minHeight: 40), alignment: Alignment.centerLeft,
              child: Text(_destinationId != null ? _roomName(_destinationId!) : 'اختر الوجهة', overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _destinationId != null ? const Color(0xFF263238) : const Color(0xFF9AA6B2)))),
          ),
        ])),
        Column(children: [
          InkWell(
            onTap: () { setState(() { final previous = _sourceId; _sourceId = _destinationId; _destinationId = previous; }); if (_sourceId != null && _destinationId != null) _navigate(); },
            borderRadius: BorderRadius.circular(10),
            child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.swap_vert, size: 20, color: Color(0xFF546E7A))),
          ),
          const SizedBox(height: 8),
          InkWell(onTap: _clear, borderRadius: BorderRadius.circular(8), child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close, size: 18, color: Color(0xFF90A4AE)))),
        ]),
      ]),
    );
  }

  Widget _buildHorizontalFloorPicker() {
    return Container(
      color: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [4, 3, 2, 1, 0].map(_floorButtonH).toList()),
    );
  }

  Widget _floorButtonH(int floor) {
    final isSelected = _floor == floor, hasRoute = _routeFloors.contains(floor);
    return GestureDetector(
      onTap: () => setState(() => _floor = floor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 62, height: 44, alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFF0F4F8), borderRadius: BorderRadius.circular(12)),
        child: Stack(alignment: Alignment.center, children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(floorShortLabel(floor), style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF1A2D3E), fontWeight: FontWeight.bold, fontSize: 15)),
            Text(floorLabel(floor), style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF3D5166), fontSize: 9.5, fontWeight: FontWeight.w600)),
          ]),
          if (hasRoute && !isSelected) const Positioned(right: 6, top: 5, child: _RouteDot()),
        ]),
      ),
    );
  }

  Widget _buildFloorPicker(bool isWide) {
    return Positioned(
      right: 10, top: 12,
      child: Material(
        elevation: 2, borderRadius: BorderRadius.circular(10), shadowColor: Colors.black.withValues(alpha: 0.12),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ...[4, 3, 2, 1, 0].map((f) => _floorButton(f, floorShortLabel(f))),
            const Divider(height: 6, indent: 6, endIndent: 6),
            GestureDetector(
              onTap: () => setState(() => _transformationController.value = Matrix4.identity()),
              child: Container(width: 34, height: 30, alignment: Alignment.center, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1), decoration: BoxDecoration(borderRadius: BorderRadius.circular(7)), child: const Icon(Icons.fit_screen, size: 15, color: Color(0xFF546E7A))),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _floorButton(int floor, String label) {
    final isSelected = _floor == floor, hasRoute = _routeFloors.contains(floor);
    return GestureDetector(
      onTap: () => setState(() => _floor = floor),
      child: Container(
        width: 34, height: 34, alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFF1E88E5) : Colors.transparent, borderRadius: BorderRadius.circular(7)),
        child: Stack(alignment: Alignment.center, children: [
          Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF546E7A), fontWeight: FontWeight.bold, fontSize: 13)),
          if (hasRoute && !isSelected) const Positioned(right: 4, top: 4, child: _RouteDot()),
        ]),
      ),
    );
  }

  Widget _searchResultTile(Room room) {
    final isSelected = room.id == _sourceId || room.id == _destinationId;
    return InkWell(
      onTap: () => _selectRoom(room),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: _iconBackground(room.type), borderRadius: BorderRadius.circular(10)), child: Icon(_iconForType(room.type), size: 18, color: _iconForeground(room.type))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(room.name, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, fontSize: 14, color: const Color(0xFF263238))),
            Text('طابق ${floorLabel(room.floor)} • ${room.shortName}', style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE))),
          ])),
          if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 20),
        ]),
      ),
    );
  }

  List<_SimpleStep> _buildSimpleSteps() {
    if (_route == null || _route!.length < 2) return const [];
    final steps = <_SimpleStep>[];
    final startRoom = _findRoomForNode(_route!.first);
    steps.add(_SimpleStep(instruction: 'ابدأ من ${startRoom?.shortName ?? 'البداية'}', icon: Icons.my_location, color: const Color(0xFF4CAF50), floor: _route!.first.floor));
    for (var index = 1; index < _route!.length - 1; index++) {
      final previous = _route![index - 1], current = _route![index], next = _route![index + 1];
      if (current.floor != previous.floor) {
        final up = current.floor > previous.floor;
        steps.add(_SimpleStep(instruction: up ? 'اصعد إلى طابق ${floorLabel(current.floor)}' : 'انزل إلى طابق ${floorLabel(current.floor)}', icon: up ? Icons.arrow_upward : Icons.arrow_downward, color: const Color(0xFF1E88E5), floor: current.floor));
        continue;
      }
      final room = _findRoomForNode(current);
      if (room != null && room.type != RoomType.corridor) {
        steps.add(_SimpleStep(instruction: 'مر عبر ${room.shortName}', icon: Icons.place, color: const Color(0xFFFF9800), floor: current.floor));
        continue;
      }
      if (next.floor == current.floor && previous.floor == current.floor) {
        final inAngle = _angle(previous, current), outAngle = _angle(current, next);
        final delta = _normalizeAngle(outAngle - inAngle);
        if (delta.abs() > 0.5) {
          steps.add(_SimpleStep(instruction: delta > 0 ? 'انعطف يميناً' : 'انعطف يساراً', icon: delta > 0 ? Icons.turn_right : Icons.turn_left, color: const Color(0xFFFF9800), floor: current.floor));
        }
      }
    }
    final endRoom = _findRoomForNode(_route!.last);
    steps.add(_SimpleStep(instruction: 'وصلت إلى ${endRoom?.shortName ?? 'الوجهة'}', icon: Icons.flag, color: const Color(0xFFF44336), floor: _route!.last.floor));
    return steps;
  }

  double _angle(NavNode from, NavNode to) => atan2(to.y - from.y, to.x - from.x).toDouble();

  double _normalizeAngle(double angle) {
    while (angle > pi) { angle -= 2 * pi; }
    while (angle < -pi) { angle += 2 * pi; }
    return angle;
  }

  Room? _findRoomForNode(NavNode node) {
    if (node.roomId == null) return null;
    return BuildingData.allRooms.where((room) => room.id == node.roomId).firstOrNull;
  }

  String _roomName(String roomId) => BuildingData.allRooms.where((room) => room.id == roomId).firstOrNull?.shortName ?? roomId;

  Color _iconBackground(RoomType type) {
    switch (type) {
      case RoomType.lab:         return const Color(0xFFE3F2FD);
      case RoomType.lectureHall: return const Color(0xFFEDE7F6);
      case RoomType.office:      return const Color(0xFFFFF3E0);
      case RoomType.meetingRoom: return const Color(0xFFFFFDE7);
      case RoomType.restroom:    return const Color(0xFFE0F7FA);
      default:                   return const Color(0xFFF5F5F5);
    }
  }

  Color _iconForeground(RoomType type) {
    switch (type) {
      case RoomType.lab:         return const Color(0xFF1565C0);
      case RoomType.lectureHall: return const Color(0xFF6A1B9A);
      case RoomType.office:      return const Color(0xFFE65100);
      case RoomType.meetingRoom: return const Color(0xFFF9A825);
      case RoomType.restroom:    return const Color(0xFF00838F);
      default:                   return const Color(0xFF546E7A);
    }
  }

  IconData _iconForType(RoomType type) {
    switch (type) {
      case RoomType.lab:         return Icons.science;
      case RoomType.lectureHall: return Icons.school;
      case RoomType.office:      return Icons.person;
      case RoomType.meetingRoom: return Icons.groups;
      case RoomType.stairs:      return Icons.stairs;
      case RoomType.elevator:    return Icons.elevator;
      case RoomType.restroom:    return Icons.wc;
      case RoomType.entrance:    return Icons.door_front_door;
      case RoomType.corridor:
      case RoomType.room:        return Icons.room;
    }
  }
}

class _SimpleStep {
  final String instruction;
  final IconData icon;
  final Color color;
  final int floor;
  const _SimpleStep({required this.instruction, required this.icon, required this.color, required this.floor});
}

class _RouteDot extends StatelessWidget {
  const _RouteDot();
  @override
  Widget build(BuildContext context) => Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF1E88E5), shape: BoxShape.circle));
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
