import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/database_service.dart';
import 'create_event_screen.dart';

class EventsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const EventsScreen({super.key, required this.profile});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  static const _categories = [
    'All', 'Academic', 'Workshop', 'Seminar', 'Competition',
    'Career', 'Orientation', 'Exhibition', 'Ceremony',
  ];

  String _selectedCategory = 'All';
  String _searchQuery = '';
  List<Map<String, dynamic>> _allEvents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _loading = true);
    try {
      final events = await DatabaseService.getEvents();
      setState(() {
        _allEvents = events;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load events: $e'), backgroundColor: NabihTheme.error),
        );
      }
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    return _allEvents.where((e) {
      final matchCategory = _selectedCategory == 'All' ||
          e['category'] == _selectedCategory;
      final matchSearch = _searchQuery.isEmpty ||
          (e['title'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (e['description'] ?? '').toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.profile['role'] as String? ?? '';
    final canCreate = role == 'faculty' || role == 'staff';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Events & Activities'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final cat = _categories[i];
                final selected = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                  selectedColor: NabihTheme.primary,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : NabihTheme.textSecondary,
                    fontSize: 13,
                  ),
                  backgroundColor: NabihTheme.background,
                  side: BorderSide(
                    color: selected ? NabihTheme.primary : NabihTheme.divider,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadEvents,
                    child: _filteredEvents.isEmpty
                        ? ListView(
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                child: Text(
                                  'No events found',
                                  style: TextStyle(color: NabihTheme.textSecondary),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredEvents.length,
                            itemBuilder: (context, i) =>
                                _eventCard(_filteredEvents[i]),
                          ),
                  ),
          ),
        ],
      ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const CreateEventScreen()),
                );
                if (result == true) {
                  _loadEvents();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Event'),
            )
          : null,
    );
  }

  Widget _eventCard(Map<String, dynamic> event) {
    final date = DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showEventDetail(event),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: NabihTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${date.day}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: NabihTheme.primary,
                      ),
                    ),
                    Text(
                      _monthShort(date.month),
                      style: const TextStyle(
                        fontSize: 11,
                        color: NabihTheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event['title'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      event['description'] ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: NabihTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: NabihTheme.textLight),
                        const SizedBox(width: 4),
                        Text(
                          event['time'] ?? '',
                          style: const TextStyle(fontSize: 12, color: NabihTheme.textLight),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.location_on_outlined, size: 14, color: NabihTheme.textLight),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event['location'] ?? '',
                            style: const TextStyle(fontSize: 12, color: NabihTheme.textLight),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetail(Map<String, dynamic> event) {
    final date = DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NabihTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event['category'] ?? '',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFE17055),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              event['title'] ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              event['description'] ?? '',
              style: const TextStyle(
                fontSize: 14,
                color: NabihTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            _detailRow(Icons.calendar_today, '${date.day}/${date.month}/${date.year}'),
            _detailRow(Icons.access_time, event['time'] ?? ''),
            _detailRow(Icons.location_on, event['location'] ?? ''),
            _detailRow(Icons.person, event['organizer'] ?? ''),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Event added to your calendar!'),
                      backgroundColor: NabihTheme.success,
                    ),
                  );
                },
                icon: const Icon(Icons.calendar_month),
                label: const Text('Add to Calendar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: NabihTheme.primary),
          const SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _monthShort(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[month];
  }
}
