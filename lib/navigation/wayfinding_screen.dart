import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';
import 'building_data.dart';
import 'pathfinder.dart';
import 'floor_plan_painter.dart';

class WayfindingScreen extends StatefulWidget {
  const WayfindingScreen({super.key});

  @override
  State<WayfindingScreen> createState() => _WayfindingScreenState();
}

enum _SearchTarget { source, dest }

class _WayfindingScreenState extends State<WayfindingScreen>
    with SingleTickerProviderStateMixin {
  late final Pathfinder _pathfinder;
  late final AnimationController _animCtrl;
  final TextEditingController _searchCtrl = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  String? _sourceId;
  String? _destId;
  int _floor = 0;
  List<NavNode>? _route;
  List<Room> _allNav = [];
  String _searchQuery = '';
  bool _showSearch = false;
  bool _showDirections = false;
  String? _highlightRoomId;
  _SearchTarget _searchTarget = _SearchTarget.source;

  // Route summary
  int _routeStepCount = 0;
  Set<int> _routeFloors = {};
  bool _sheetExpanded = true;

  @override
  void initState() {
    super.initState();
    _pathfinder = Pathfinder();
    _allNav = BuildingData.navigableRooms;
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch(_SearchTarget target) {
    setState(() {
      _searchTarget = target;
      _showSearch = true;
      _searchQuery = '';
      _searchCtrl.clear();
    });
    // Request focus after frame so the TextField is mounted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocus.requestFocus();
    });
  }

  void _navigate() {
    if (_sourceId == null || _destId == null) return;
    if (_sourceId == _destId) return;
    final path = _pathfinder.findPath(_sourceId!, _destId!);
    setState(() {
      _route = path;
      if (path != null) {
        _routeFloors = path.map((n) => n.floor).toSet();
        _routeStepCount = path.length;
        // Jump to floor of start node
        _floor = path.first.floor;
        _showDirections = true;
      } else {
        _routeFloors = {};
        _routeStepCount = 0;
        _showDirections = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No route found')),
        );
      }
    });
  }

  void _clear() {
    setState(() {
      _route = null;
      _sourceId = null;
      _destId = null;
      _highlightRoomId = null;
      _showDirections = false;
      _showSearch = false;
      _searchQuery = '';
      _searchCtrl.clear();
      _routeFloors = {};
      _routeStepCount = 0;
    });
  }

  void _selectRoom(Room room) {
    setState(() {
      _showSearch = false;
      _searchQuery = '';
      _searchCtrl.clear();

      if (_searchTarget == _SearchTarget.source) {
        _sourceId = room.id;
        _floor = room.floor;
        // If destination already set, re-navigate
        if (_destId != null) {
          _navigate();
        }
      } else {
        _destId = room.id;
        _floor = room.floor;
        if (_sourceId != null) {
          _navigate();
        }
      }
      _highlightRoomId = room.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Map ──
          _buildMap(),
          // ── Top bar (search / route input) ──
          _buildTopBar(),
          // ── Floor selector (right side) ──
          _buildFloorPicker(),
          // ── Bottom sheet (directions / room info) ──
          if (_showDirections && _route != null) _buildDirectionsSheet(),
          // ── Search results overlay ──
          if (_showSearch) _buildSearchOverlay(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // MAP
  // ═══════════════════════════════════════════════════════════

  Widget _buildMap() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Intrinsic size of the floor plan canvas
        const planW = 580.0;
        const planH = 500.0;
        // Scale to fit the available space with padding
        final availW = constraints.maxWidth - 8;
        final availH = constraints.maxHeight - 8;
        final scale = (availW / planW) < (availH / planH)
            ? (availW / planW)
            : (availH / planH);
        final clampedScale = scale.clamp(0.25, 2.0);

        return AnimatedBuilder(
          animation: _animCtrl,
          builder: (context, _) {
            return Center(
              child: SizedBox(
                width: planW * clampedScale,
                height: planH * clampedScale,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CustomPaint(
                    size: const Size(planW, planH),
                    painter: FloorPlanPainter(
                      floor: _floor,
                      routePath: _route,
                      sourceRoomId: _sourceId,
                      destRoomId: _destId,
                      highlightRoomId: _highlightRoomId,
                      animValue: _animCtrl.value,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // TOP BAR
  // ═══════════════════════════════════════════════════════════

  Widget _buildTopBar() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 12,
      right: 60,
      child: Column(
        children: [
          // Search / From-To card
          Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(14),
            shadowColor: Colors.black.withValues(alpha: 0.15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: (_route != null && _sourceId != null && _destId != null)
                  ? _buildRouteInputCard()
                  : _buildSearchCard(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    final hasSource = _sourceId != null;
    final hasDest = _destId != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // From field
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _openSearch(_SearchTarget.source),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Color(0xFF546E7A), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasSource ? _roomName(_sourceId!) : 'Choose starting point...',
                      style: TextStyle(
                        color: hasSource
                            ? const Color(0xFF263238)
                            : const Color(0xFF90A4AE),
                        fontSize: 14,
                        fontWeight: hasSource ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasSource)
                    GestureDetector(
                      onTap: () => setState(() {
                        _sourceId = null;
                        _route = null;
                        _showDirections = false;
                        _highlightRoomId = null;
                      }),
                      child: const Icon(Icons.close, color: Color(0xFF90A4AE), size: 18),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // To field
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => _openSearch(_SearchTarget.dest),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF44336),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.search, color: Color(0xFF546E7A), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasDest ? _roomName(_destId!) : 'Choose destination...',
                      style: TextStyle(
                        color: hasDest
                            ? const Color(0xFF263238)
                            : const Color(0xFF90A4AE),
                        fontSize: 14,
                        fontWeight: hasDest ? FontWeight.w500 : FontWeight.normal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasDest)
                    GestureDetector(
                      onTap: () => setState(() {
                        _destId = null;
                        _route = null;
                        _showDirections = false;
                        _highlightRoomId = null;
                      }),
                      child: const Icon(Icons.close, color: Color(0xFF90A4AE), size: 18),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteInputCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Colored dots + line
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
              ),
              Container(width: 2, height: 20, color: const Color(0xFFBDBDBD)),
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Color(0xFFF44336),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // From / To labels
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _openSearch(_SearchTarget.source),
                  child: Text(
                    _sourceId != null ? _roomName(_sourceId!) : 'Choose start',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF263238),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Divider(height: 16, thickness: 0.5),
                GestureDetector(
                  onTap: () => _openSearch(_SearchTarget.dest),
                  child: Text(
                    _destId != null ? _roomName(_destId!) : 'Choose destination',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _destId != null
                          ? const Color(0xFF263238)
                          : const Color(0xFF90A4AE),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Swap + Close buttons
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    final tmp = _sourceId;
                    _sourceId = _destId;
                    _destId = tmp;
                  });
                  if (_sourceId != null && _destId != null) _navigate();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECEFF1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.swap_vert,
                      size: 18, color: Color(0xFF546E7A)),
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _clear,
                child: const Icon(Icons.close,
                    size: 18, color: Color(0xFF90A4AE)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // FLOOR PICKER
  // ═══════════════════════════════════════════════════════════

  Widget _buildFloorPicker() {
    return Positioned(
      right: 12,
      top: MediaQuery.of(context).padding.top + 8,
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withValues(alpha: 0.12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _floorBtn(4, '4'),
              _floorBtn(3, '3'),
              _floorBtn(2, '2'),
              _floorBtn(1, '1'),
              _floorBtn(0, 'G'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _floorBtn(int f, String label) {
    final selected = _floor == f;
    final hasRouteOnFloor = _routeFloors.contains(f);
    return GestureDetector(
      onTap: () => setState(() => _floor = f),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E88E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF546E7A),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            if (hasRouteOnFloor && !selected)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E88E5),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // SEARCH OVERLAY
  // ═══════════════════════════════════════════════════════════

  Widget _buildSearchOverlay() {
    final filtered = _allNav.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.name.toLowerCase().contains(q) ||
          r.shortName.toLowerCase().contains(q) ||
          r.id.toLowerCase().contains(q);
    }).toList();

    // Group by floor
    final grouped = <int, List<Room>>{};
    for (final r in filtered) {
      grouped.putIfAbsent(r.floor, () => []).add(r);
    }
    // Get all floors that have rooms, sorted
    final allFloors = grouped.keys.toList()..sort();

    return Positioned.fill(
      top: MediaQuery.of(context).padding.top + 70,
      child: GestureDetector(
        onTap: () => setState(() => _showSearch = false),
        child: Container(
          color: Colors.black.withValues(alpha: 0.3),
          child: Align(
            alignment: Alignment.topCenter,
            child: Material(
              elevation: 8,
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16)),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(16)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search target label
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _searchTarget == _SearchTarget.source
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFFF44336),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _searchTarget == _SearchTarget.source
                                ? 'Choose starting point'
                                : 'Choose destination',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF546E7A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      child: TextField(
                        controller: _searchCtrl,
                        focusNode: _searchFocus,
                        autofocus: true,
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search rooms, offices, labs...',
                          hintStyle: const TextStyle(color: Color(0xFF90A4AE)),
                          prefixIcon: const Icon(Icons.search,
                              color: Color(0xFF546E7A)),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? GestureDetector(
                                  onTap: () => setState(() {
                                    _searchQuery = '';
                                    _searchCtrl.clear();
                                  }),
                                  child: const Icon(Icons.close,
                                      color: Color(0xFF90A4AE)),
                                )
                              : GestureDetector(
                                  onTap: () => setState(() => _showSearch = false),
                                  child: const Icon(Icons.arrow_back,
                                      color: Color(0xFF90A4AE)),
                                ),
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    // Results
                    Flexible(
                      child: ListView(
                        padding: const EdgeInsets.only(bottom: 12),
                        shrinkWrap: true,
                        children: [
                          for (final floor in allFloors)
                            if (grouped.containsKey(floor)) ...[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 12, 16, 4),
                                child: Text(
                                  '${floorLabel(floor)} Floor',
                                  style: const TextStyle(
                                    color: Color(0xFF90A4AE),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              for (final room in grouped[floor]!)
                                _searchResultTile(room),
                            ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchResultTile(Room room) {
    final isSelected = room.id == _sourceId || room.id == _destId;
    return InkWell(
      onTap: () => _selectRoom(room),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconBgColor(room.type),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Icon(_iconForType(room.type),
                  size: 18, color: _iconFgColor(room.type)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 14,
                      color: const Color(0xFF263238),
                    ),
                  ),
                  Text(
                    '${floorLabel(room.floor)} Floor  •  ${room.shortName}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF90A4AE)),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle,
                  color: Color(0xFF4CAF50), size: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // DIRECTIONS BOTTOM SHEET
  // ═══════════════════════════════════════════════════════════

  Widget _buildDirectionsSheet() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Material(
        elevation: 12,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        shadowColor: Colors.black.withValues(alpha: 0.2),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── Collapsible header: tap to show/hide route summary ───
              GestureDetector(
                onTap: () => setState(() => _sheetExpanded = !_sheetExpanded),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 16, 8),
                  child: Row(
                    children: [
                      // Green/red dots compact
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50), shape: BoxShape.circle),
                      ),
                      Container(width: 16, height: 2, color: const Color(0xFF1E88E5)),
                      Container(
                        width: 10, height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF44336), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_sourceId != null ? _roomName(_sourceId!) : ''}  →  ${_destId != null ? _roomName(_destId!) : ''}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF263238),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        _sheetExpanded ? Icons.expand_more : Icons.expand_less,
                        size: 22, color: const Color(0xFF90A4AE),
                      ),
                    ],
                  ),
                ),
              ),

              // ─── Expandable: route details + info chips ───
              AnimatedCrossFade(
                firstChild: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Route summary with vertical line
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 4),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4CAF50),
                                  shape: BoxShape.circle),
                              ),
                              Container(width: 2, height: 28, color: const Color(0xFF1E88E5)),
                              Container(
                                width: 10, height: 10,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFF44336),
                                  shape: BoxShape.circle),
                              ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _sourceId != null ? _roomName(_sourceId!) : '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14,
                                    color: Color(0xFF263238)),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _destId != null ? _roomName(_destId!) : '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14,
                                    color: Color(0xFF263238)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 16),
                    // Info chips
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          _infoChip(Icons.route, '$_routeStepCount خطوات'),
                          const SizedBox(width: 12),
                          _infoChip(
                              Icons.layers,
                                _routeFloors.length == 1
                                  ? 'طابق ${floorLabel(_routeFloors.first)}'
                                  : '${_routeFloors.length} طوابق'),
                          const Spacer(),
                          if (_routeFloors.length > 1)
                            ..._routeFloors.map((f) => Padding(
                                  padding: const EdgeInsets.only(left: 4),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _floor = f),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: _floor == f
                                            ? const Color(0xFF1E88E5)
                                            : const Color(0xFFECEFF1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        floorLabel(f),
                                        style: TextStyle(
                                          color: _floor == f
                                              ? Colors.white
                                              : const Color(0xFF546E7A),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                secondChild: const SizedBox.shrink(),
                crossFadeState: _sheetExpanded
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
                duration: const Duration(milliseconds: 250),
              ),

              // ─── Steps: always visible ───
              SizedBox(
                height: 130,
                child: _buildStepList(),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF546E7A)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF546E7A),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildStepList() {
    if (_route == null) return const SizedBox.shrink();

    // Build simple turn-by-turn directions from route nodes
    final steps = _buildSimpleSteps();

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: steps.length,
      itemBuilder: (context, i) {
        final step = steps[i];
        final isActive = step.floor == _floor;
        return GestureDetector(
          onTap: () => setState(() => _floor = step.floor),
          child: Container(
            width: 130,
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isActive
                  ? const Color(0xFFE3F2FD)
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFFE0E0E0),
                width: isActive ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: step.color,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child:
                          Icon(step.icon, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'الخطوة ${i + 1}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF90A4AE),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.instruction,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF37474F),
                  ),
                ),
                const Spacer(),
                Text(
                  '${floorLabel(step.floor)} طابق',
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════

  List<_SimpleStep> _buildSimpleSteps() {
    if (_route == null || _route!.length < 2) return [];
    final steps = <_SimpleStep>[];

    // Start
    final startRoom = _findRoomForNode(_route!.first);
    steps.add(_SimpleStep(
      instruction: 'ابدأ من ${startRoom?.shortName ?? 'البداية'}',
      icon: Icons.my_location,
      color: const Color(0xFF4CAF50),
      floor: _route!.first.floor,
    ));

    for (int i = 1; i < _route!.length - 1; i++) {
      final prev = _route![i - 1];
      final curr = _route![i];
      final next = _route![i + 1];

      // Floor change
      if (curr.floor != prev.floor) {
        final goUp = curr.floor > prev.floor;
        steps.add(_SimpleStep(
          instruction: goUp
              ? 'اصعد إلى طابق ${floorLabel(curr.floor)}'
              : 'انزل إلى طابق ${floorLabel(curr.floor)}',
          icon: goUp ? Icons.arrow_upward : Icons.arrow_downward,
          color: const Color(0xFF1E88E5),
          floor: curr.floor,
        ));
        continue;
      }

      // Named waypoint
      final room = _findRoomForNode(curr);
      if (room != null && room.type != RoomType.corridor) {
        steps.add(_SimpleStep(
          instruction: 'مر عبر ${room.shortName}',
          icon: Icons.place,
          color: const Color(0xFFFF9800),
          floor: curr.floor,
        ));
        continue;
      }

      // Turn detection
      if (next.floor == curr.floor && prev.floor == curr.floor) {
        final inAngle = _angle(prev, curr);
        final outAngle = _angle(curr, next);
        final delta = _normAngle(outAngle - inAngle);
        if (delta.abs() > 0.5) {
          steps.add(_SimpleStep(
            instruction: delta > 0 ? 'انعطف يميناً' : 'انعطف يساراً',
            icon: delta > 0 ? Icons.turn_right : Icons.turn_left,
            color: const Color(0xFFFF9800),
            floor: curr.floor,
          ));
        }
      }
    }

    // Arrive
    final endRoom = _findRoomForNode(_route!.last);
    steps.add(_SimpleStep(
      instruction: 'وصلت إلى ${endRoom?.shortName ?? 'الوجهة'}',
      icon: Icons.flag,
      color: const Color(0xFFF44336),
      floor: _route!.last.floor,
    ));

    return steps;
  }

  double _angle(NavNode a, NavNode b) =>
      atan2(b.y - a.y, b.x - a.x).toDouble();

  double _normAngle(double a) {
    while (a > pi) {
      a -= 2 * pi;
    }
    while (a < -pi) {
      a += 2 * pi;
    }
    return a;
  }

  Room? _findRoomForNode(NavNode node) {
    if (node.roomId == null) return null;
    return BuildingData.allRooms.where((r) => r.id == node.roomId).firstOrNull;
  }

  String _roomName(String roomId) {
    return BuildingData.allRooms
            .where((r) => r.id == roomId)
            .firstOrNull
            ?.shortName ??
        roomId;
  }

  Color _iconBgColor(RoomType type) {
    switch (type) {
      case RoomType.lab:
        return const Color(0xFFE3F2FD);
      case RoomType.lectureHall:
        return const Color(0xFFEDE7F6);
      case RoomType.office:
        return const Color(0xFFFFF3E0);
      case RoomType.meetingRoom:
        return const Color(0xFFFFFDE7);
      case RoomType.restroom:
        return const Color(0xFFE0F7FA);
      default:
        return const Color(0xFFF5F5F5);
    }
  }

  Color _iconFgColor(RoomType type) {
    switch (type) {
      case RoomType.lab:
        return const Color(0xFF1565C0);
      case RoomType.lectureHall:
        return const Color(0xFF6A1B9A);
      case RoomType.office:
        return const Color(0xFFE65100);
      case RoomType.meetingRoom:
        return const Color(0xFFF9A825);
      case RoomType.restroom:
        return const Color(0xFF00838F);
      default:
        return const Color(0xFF546E7A);
    }
  }

  IconData _iconForType(RoomType type) {
    switch (type) {
      case RoomType.lab:
        return Icons.science;
      case RoomType.lectureHall:
        return Icons.school;
      case RoomType.office:
        return Icons.person;
      case RoomType.meetingRoom:
        return Icons.groups;
      case RoomType.stairs:
        return Icons.stairs;
      case RoomType.elevator:
        return Icons.elevator;
      case RoomType.restroom:
        return Icons.wc;
      case RoomType.entrance:
        return Icons.door_front_door;
      default:
        return Icons.room;
    }
  }
}

// ─── SIMPLE STEP ────────────────────────────────────────────

class _SimpleStep {
  final String instruction;
  final IconData icon;
  final Color color;
  final int floor;

  const _SimpleStep({
    required this.instruction,
    required this.icon,
    required this.color,
    required this.floor,
  });
}

// ─── ANIMATED BUILDER WRAPPER ───────────────────────────────

class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return _AnimatedInner(listenable: animation, builder: builder);
  }
}

class _AnimatedInner extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;

  const _AnimatedInner({
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) => builder(context, null);
}
