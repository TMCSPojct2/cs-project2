import 'package:flutter/material.dart';
import '../data/language_controller.dart';
import '../data/role_context.dart';
import '../navigation/building_data.dart';
import '../navigation/models.dart';
import '../services/events_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/common_widgets.dart';

class AdminEventScreen extends StatefulWidget {
  const AdminEventScreen({super.key});

  @override
  State<AdminEventScreen> createState() => _AdminEventScreenState();
}

class _AdminEventScreenState extends State<AdminEventScreen> {
  final Set<String> _expanded = {};
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedLocation;
  String _category = 'Workshop';
  DateTime? _pickedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  late Future<_EventsBundle> _eventsFuture;
  bool _publishing = false;

  static const _months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];

  String get _formattedDate {
    if (_pickedDate == null) return '';
    return '${_months[_pickedDate!.month - 1]} ${_pickedDate!.day}';
  }

  String get _formattedTime {
    if (_startTime == null || _endTime == null) return '';
    return '${_fmt(_startTime!)} - ${_fmt(_endTime!)}';
  }

  String _fmt(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) setState(() => _pickedDate = picked);
  }

  Future<void> _pickLocation() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LocationPickerSheet(),
    );
    if (picked != null) setState(() => _selectedLocation = picked);
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? (_startTime ?? const TimeOfDay(hour: 10, minute: 0)) : (_endTime ?? const TimeOfDay(hour: 16, minute: 0)),
    );
    if (picked != null) setState(() => isStart ? _startTime = picked : _endTime = picked);
  }

  @override
  void initState() {
    super.initState();
    _eventsFuture = _loadEvents();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = currentUserRole(context, fallback: UserRole.admin);
    final isAdmin = role == UserRole.admin;
    final canFavorite = role == UserRole.student || role == UserRole.faculty;
    final bottomIndex = isAdmin ? 2 : (role == UserRole.visitor ? 3 : 0);

    return AppScaffold(
      bottomNavigationBar: RoleBottomNav(currentIndex: bottomIndex, items: NavItems.forRole(role), role: role),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 18, 24, 110),
        children: [
          BrandHeader(
            subtitle: isAdmin ? LanguageController.text('Event management', 'إدارة الفعاليات') : LanguageController.text('University events', 'فعاليات الجامعة'),
            trailing: IconButton(onPressed: () => smartBack(context, role), icon: const Icon(Icons.arrow_back_rounded)),
          ),
          const SizedBox(height: 24),
          SurfaceCard(
            gradient: const LinearGradient(colors: [Color(0xFF123836), Color(0xFF0F5B57), Color(0xFF2A7C77)]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AccentPill(label: isAdmin ? LanguageController.text('EVENTS CONTROL', 'إدارة الفعاليات') : LanguageController.text('PUBLIC EVENTS', 'الفعاليات العامة'), icon: Icons.event_available_rounded, filled: true),
              const SizedBox(height: 16),
              Text(isAdmin ? LanguageController.text('Publish and review university events.', 'انشر وراجع فعاليات الجامعة.') : LanguageController.text('Explore public university activities.', 'استعرض الأنشطة الجامعية العامة.'), style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white)),
              const SizedBox(height: 10),
              Text(isAdmin ? LanguageController.text('Published events are saved and displayed to students, faculty, admins, and visitors.', 'تُحفظ الفعاليات المنشورة وتظهر للطلاب وأعضاء هيئة التدريس والإدارة والزوار.') : LanguageController.text('View upcoming activities with quick context and expandable details.', 'اعرض الأنشطة القادمة مع تفاصيل مختصرة قابلة للتوسيع.'), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white.withOpacity(.82))),
            ]),
          ),
          if (isAdmin) ...[
            const SizedBox(height: 20),
            SurfaceCard(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(LanguageController.text('Create Event', 'إنشاء فعالية'), style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextField(controller: _titleController, decoration: InputDecoration(labelText: LanguageController.text('Event title', 'عنوان الفعالية'), prefixIcon: const Icon(Icons.event_outlined))),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(labelText: LanguageController.text('Category', 'التصنيف')),
                  items: const ['Workshop', 'Orientation', 'Awareness', 'Ceremony', 'Seminar'].map((item) => DropdownMenuItem(value: item, child: Text(LanguageController.translateRaw(item)))).toList(),
                  onChanged: (value) => setState(() => _category = value ?? 'Workshop'),
                ),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _PickerField(
                    label: LanguageController.text('Date', 'التاريخ'),
                    value: _formattedDate.isEmpty ? null : _formattedDate,
                    hint: LanguageController.text('Pick date', 'اختر التاريخ'),
                    icon: Icons.calendar_today_rounded,
                    onTap: _pickDate,
                  )),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  Expanded(child: _PickerField(
                    label: LanguageController.text('Start time', 'وقت البدء'),
                    value: _startTime == null ? null : _fmt(_startTime!),
                    hint: LanguageController.text('Pick start', 'اختر البداية'),
                    icon: Icons.schedule_rounded,
                    onTap: () => _pickTime(true),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: _PickerField(
                    label: LanguageController.text('End time', 'وقت الانتهاء'),
                    value: _endTime == null ? null : _fmt(_endTime!),
                    hint: LanguageController.text('Pick end', 'اختر النهاية'),
                    icon: Icons.schedule_rounded,
                    onTap: () => _pickTime(false),
                  )),
                ]),
                const SizedBox(height: 14),
                _PickerField(
                  label: LanguageController.text('Location', 'الموقع'),
                  value: _selectedLocation,
                  hint: LanguageController.text('Pick from campus map', 'اختر من خريطة الحرم'),
                  icon: Icons.place_outlined,
                  onTap: _pickLocation,
                ),
                const SizedBox(height: 14),
                SizedBox(height: 130, child: TextField(controller: _descriptionController, maxLines: null, expands: true, decoration: InputDecoration(labelText: LanguageController.text('Event description', 'وصف الفعالية'), alignLabelWithHint: true))),
                const SizedBox(height: 18),
                SizedBox(width: double.infinity, child: GradientButton(label: _publishing ? LanguageController.text('Publishing...', 'جاري النشر...') : LanguageController.text('Publish Event', 'نشر الفعالية'), icon: Icons.check_circle_outline_rounded, onPressed: _publishing ? null : _publishEvent)),
              ]),
            ),
          ],
          const SizedBox(height: 20),
          SectionTitle(title: LanguageController.text('Upcoming Events', 'الفعاليات القادمة'), action: LanguageController.text('Refresh', 'تحديث'), onAction: _reloadEvents),
          const SizedBox(height: 12),
          FutureBuilder<_EventsBundle>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Center(child: CircularProgressIndicator()));
              }
              if (snapshot.hasError) {
                return SurfaceCard(child: Text(LanguageController.text('Unable to load events right now.', 'تعذر تحميل الفعاليات الآن.'), style: Theme.of(context).textTheme.bodyLarge));
              }
              final bundle = snapshot.data ?? const _EventsBundle(events: [], favorites: <String>{});
              if (bundle.events.isEmpty) {
                return SurfaceCard(child: Text(LanguageController.text('No events available yet.', 'لا توجد فعاليات متاحة بعد.'), style: Theme.of(context).textTheme.bodyLarge));
              }
              return Column(children: bundle.events.map((event) {
                final id = event['id']?.toString() ?? '';
                final expanded = _expanded.contains(id);
                final favorite = bundle.favorites.contains(id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _EventCard(
                    event: event,
                    expanded: expanded,
                    favorite: favorite,
                    canFavorite: canFavorite && id.length > 20,
                    onToggle: () => setState(() => expanded ? _expanded.remove(id) : _expanded.add(id)),
                    onFavorite: () => _toggleFavorite(id, favorite),
                  ),
                );
              }).toList());
            },
          ),
        ],
      ),
    );
  }

  Future<_EventsBundle> _loadEvents() async {
    final events = await EventsService.instance.listEvents();
    final favorites = await EventsService.instance.listFavoriteEventIds();
    return _EventsBundle(events: events, favorites: favorites);
  }

  void _reloadEvents() => setState(() => _eventsFuture = _loadEvents());

  Future<void> _publishEvent() async {
    final title = _titleController.text.trim();
    final date = _formattedDate;
    final time = _formattedTime;
    final location = _selectedLocation ?? '';
    final description = _descriptionController.text.trim();
    if (title.isEmpty || date.isEmpty || time.isEmpty || location.isEmpty || description.isEmpty) {
      _showMessage(LanguageController.text('Complete all event fields.', 'أكمل جميع حقول الفعالية.'));
      return;
    }
    setState(() => _publishing = true);
    try {
      await EventsService.instance.createEvent(title: title, category: _category, date: date, time: time, location: location, description: description);
      if (!mounted) return;
      setState(() => _publishing = false);
      _reloadEvents();
      _showMessage(LanguageController.text('Event published', 'تم نشر الفعالية'));
    } catch (_) {
      if (!mounted) return;
      setState(() => _publishing = false);
      _showMessage(LanguageController.text('Unable to publish event now.', 'تعذر نشر الفعالية الآن.'));
    }
  }

  Future<void> _toggleFavorite(String eventId, bool favorite) async {
    if (eventId.isEmpty) return;
    try {
      await EventsService.instance.toggleFavorite(eventId: eventId, currentlyFavorite: favorite);
      _reloadEvents();
    } catch (_) {
      _showMessage(LanguageController.text('Unable to update favorite now.', 'تعذر تحديث المفضلة الآن.'));
    }
  }

  void _showMessage(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

// ── Location picker sheet ─────────────────────────────────────────────────────
class _LocationPickerSheet extends StatefulWidget {
  const _LocationPickerSheet();

  @override
  State<_LocationPickerSheet> createState() => _LocationPickerSheetState();
}

class _LocationPickerSheetState extends State<_LocationPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  static final _venues = [
    ...BuildingData.groundFloor,
    ...BuildingData.firstFloor,
    ...BuildingData.secondFloor,
    ...BuildingData.thirdFloor,
  ].where((r) => r.type == RoomType.lectureHall || r.type == RoomType.lab || r.type == RoomType.room).toList();

  List<Room> get _filtered {
    if (_query.isEmpty) return _venues;
    final q = _query.toLowerCase();
    return _venues.where((r) => r.name.toLowerCase().contains(q)).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.line, borderRadius: BorderRadius.circular(4))),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: LanguageController.text('Search campus locations...', 'ابحث في مواقع الحرم...'),
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              controller: scroll,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final room = _filtered[i];
                final floorLabel = room.floor == 0
                    ? LanguageController.text('Ground Floor', 'الدور الأرضي')
                    : LanguageController.text('Floor ${room.floor}', 'الدور ${room.floor}');
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  leading: Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.place_outlined, color: AppColors.primary, size: 20),
                  ),
                  title: Text(room.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(floorLabel, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                  onTap: () => Navigator.pop(context, room.name),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }
}

// ── Picker field ──────────────────────────────────────────────────────────────
class _PickerField extends StatelessWidget {
  final String label;
  final String? value;
  final String hint;
  final IconData icon;
  final VoidCallback onTap;
  const _PickerField({required this.label, required this.value, required this.hint, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasValue = value != null && value!.isNotEmpty;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
        ),
        child: Text(
          hasValue ? value! : hint,
          style: TextStyle(
            color: hasValue ? AppColors.ink : AppColors.muted,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}

class _EventsBundle {
  final List<Map<String, dynamic>> events;
  final Set<String> favorites;
  const _EventsBundle({required this.events, required this.favorites});
}

class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool expanded;
  final bool favorite;
  final bool canFavorite;
  final VoidCallback onToggle;
  final VoidCallback onFavorite;
  const _EventCard({required this.event, required this.expanded, required this.favorite, required this.canFavorite, required this.onToggle, required this.onFavorite});

  @override
  Widget build(BuildContext context) {
    final title = event['title']?.toString() ?? '';
    final category = event['category']?.toString() ?? '';
    final date = event['event_date']?.toString() ?? '';
    final time = event['event_time']?.toString() ?? '';
    final location = event['location']?.toString() ?? '';
    final description = event['description']?.toString() ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.line), borderRadius: BorderRadius.circular(30)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF152B44), Color(0xFF26476D)])),
            child: Row(children: [
              Container(width: 76, height: 76, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withOpacity(.14), borderRadius: BorderRadius.circular(24)), child: Text(date.replaceAll(' ', '\n'), textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AccentPill(label: LanguageController.translateRaw(category), icon: Icons.local_activity_outlined, filled: true),
                const SizedBox(height: 10),
                Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white)),
              ])),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.schedule_rounded, size: 18, color: AppColors.primary), const SizedBox(width: 8), Expanded(child: Text(time, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.ink)))]),
              const SizedBox(height: 12),
              if (location.isNotEmpty)
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pushNamed(context, '/navigation', arguments: location),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(children: [
                        const Icon(Icons.map_outlined, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(location, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13), overflow: TextOverflow.ellipsis)),
                        const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 14),
                      ]),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              Text(description, maxLines: expanded ? null : 3, overflow: expanded ? TextOverflow.visible : TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 10),
              Row(children: [
                TextButton.icon(onPressed: onToggle, icon: Icon(expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded), label: Text(expanded ? LanguageController.text('Show less', 'عرض أقل') : LanguageController.text('Read more', 'قراءة المزيد'))),
                const Spacer(),
                if (canFavorite) IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded, color: favorite ? AppColors.secondary : AppColors.primary)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
