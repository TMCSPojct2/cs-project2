import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/database_service.dart';
import 'gpa_calculator_screen.dart';
import 'schedule_screen.dart';
import 'announcements_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const DashboardScreen({super.key, required this.profile});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> _announcements = [];
  List<Map<String, dynamic>> _todayClasses = [];
  List<Map<String, dynamic>> _upcomingEvents = [];
  bool _isLoading = true;

  Map<String, dynamic> get profile => widget.profile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        DatabaseService.getAnnouncements(),
        DatabaseService.getSchedule(),
        DatabaseService.getEvents(),
      ]);

      final allAnnouncements = results[0];
      final allSchedule = results[1];
      final allEvents = results[2];

      // Filter pinned announcements
      final pinned = allAnnouncements
          .where((a) => a['is_pinned'] == true)
          .toList();

      // Filter today's classes
      final todayDow = DateTime.now().weekday % 7; // 1=Mon..7=Sun -> 0=Sun..6=Sat
      final todayClasses = allSchedule
          .where((c) => c['day_of_week'] == todayDow)
          .toList();

      // Upcoming events (first 3 future events)
      final now = DateTime.now();
      final upcoming = allEvents.where((e) {
        final dateStr = e['date'] as String?;
        if (dateStr == null) return false;
        final date = DateTime.tryParse(dateStr);
        return date != null && date.isAfter(now.subtract(const Duration(days: 1)));
      }).take(3).toList();

      if (mounted) {
        setState(() {
          _announcements = pinned;
          _todayClasses = todayClasses;
          _upcomingEvents = upcoming;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() => _isLoading = true);
                  await _loadData();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildQuickActions(context),
                      const SizedBox(height: 24),
                      if (_announcements.isNotEmpty) ...[
                        _sectionTitle('Pinned Announcements'),
                        const SizedBox(height: 12),
                        ..._announcements.map((a) => _announcementCard(a)),
                        const SizedBox(height: 24),
                      ],
                      if (profile['role'] == 'student') ...[
                        _sectionTitle('Today\'s Classes'),
                        const SizedBox(height: 12),
                        _buildTodayClasses(context),
                        const SizedBox(height: 24),
                      ],
                      _sectionTitle('Upcoming Events'),
                      const SizedBox(height: 12),
                      _buildUpcomingEvents(context),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final name = (profile['name'] as String?) ?? '';
    final role = (profile['role'] as String?) ?? '';
    final firstName = name.isNotEmpty ? name.split(' ').first : '';
    final roleLabel = role.isNotEmpty
        ? '${role[0].toUpperCase()}${role.substring(1)}'
        : '';

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: NabihTheme.primary,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello, $firstName!',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: NabihTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(roleLabel,
                    style: const TextStyle(fontSize: 12, color: NabihTheme.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(
            color: NabihTheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
              child: Text('N',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: NabihTheme.primary))),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = <_QuickAction>[
      _QuickAction('Navigate', Icons.map_rounded, NabihTheme.primary, () {
        // Navigate tab is index 1 in bottom nav — no-op here
      }),
      _QuickAction('Schedule', Icons.calendar_today_rounded, NabihTheme.secondary, () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ScheduleScreen(profile: profile)));
      }),
      if (profile['role'] == 'student')
        _QuickAction('GPA Calc', Icons.calculate_rounded, NabihTheme.accent, () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const GpaCalculatorScreen()));
        }),
      _QuickAction('Announce', Icons.campaign_rounded, const Color(0xFF6C5CE7), () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AnnouncementsScreen(profile: profile)));
      }),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final a = actions[i];
          return GestureDetector(
            onTap: a.onTap,
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                color: a.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: a.color.withValues(alpha: 0.2)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(a.icon, color: a.color, size: 32),
                  const SizedBox(height: 8),
                  Text(a.label,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: a.color)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: NabihTheme.textPrimary));
  }

  Widget _announcementCard(Map<String, dynamic> announcement) {
    final title = (announcement['title'] as String?) ?? '';
    final content = (announcement['content'] as String?) ?? '';
    final author = (announcement['author'] as String?) ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: NabihTheme.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.push_pin_rounded, color: Color(0xFFE17055), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(content,
                      style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Text(author,
                      style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayClasses(BuildContext context) {
    if (_todayClasses.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.free_breakfast_rounded, size: 40, color: NabihTheme.textLight),
              const SizedBox(height: 8),
              const Text('No classes today!',
                  style: TextStyle(color: NabihTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _todayClasses.map((c) {
        final courseName = (c['course_name'] as String?) ?? '';
        final startTime = (c['start_time'] as String?) ?? '';
        final endTime = (c['end_time'] as String?) ?? '';
        final room = (c['room'] as String?) ?? '';
        final courseCode = (c['course_code'] as String?) ?? '';

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: NabihTheme.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.class_rounded, color: NabihTheme.secondary),
            ),
            title: Text(courseName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text('$startTime - $endTime  |  $room',
                style: const TextStyle(fontSize: 12)),
            trailing: Text(courseCode,
                style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    if (_upcomingEvents.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 40, color: NabihTheme.textLight),
              const SizedBox(height: 8),
              const Text('No upcoming events',
                  style: TextStyle(color: NabihTheme.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _upcomingEvents.map((e) {
        final title = (e['title'] as String?) ?? '';
        final location = (e['location'] as String?) ?? '';
        final category = (e['category'] as String?) ?? '';
        final dateStr = (e['date'] as String?) ?? '';
        final date = DateTime.tryParse(dateStr);

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                  color: NabihTheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('${date?.day ?? ''}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16, color: NabihTheme.primary)),
                  Text(date != null ? _monthShort(date.month) : '',
                      style: const TextStyle(fontSize: 10, color: NabihTheme.primary)),
                ],
              ),
            ),
            title: Text(title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(location,
                style: const TextStyle(fontSize: 12, color: NabihTheme.textSecondary)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NabihTheme.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(category,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFFE17055), fontWeight: FontWeight.w600)),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _monthShort(int month) {
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month];
  }
}

class _QuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction(this.label, this.icon, this.color, this.onTap);
}
