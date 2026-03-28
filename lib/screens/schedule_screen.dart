import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../data/demo_data.dart';

class ScheduleScreen extends StatefulWidget {
  final AppUser user;
  const ScheduleScreen({super.key, required this.user});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Sun=0, Mon=1, Tue=2, Wed=3, Thu=4
  final _days = [0, 1, 2, 3, 4];
  final _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    // Start on today's tab if applicable
    final today = DateTime.now().weekday % 7;
    final idx = _days.indexOf(today);
    if (idx >= 0) _tabController.index = idx;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: _dayLabels.map((d) => Tab(text: d)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _days.map((day) => _buildDayView(day)).toList(),
      ),
    );
  }

  Widget _buildDayView(int dayOfWeek) {
    final classes = DemoData.schedule.where((c) => c.dayOfWeek == dayOfWeek).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    if (classes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.free_breakfast_rounded, size: 64, color: NabihTheme.textLight),
            const SizedBox(height: 12),
            const Text('No classes this day', style: TextStyle(fontSize: 16, color: NabihTheme.textSecondary)),
          ],
        ),
      );
    }

    final colors = [
      NabihTheme.primary,
      NabihTheme.secondary,
      const Color(0xFF6C5CE7),
      NabihTheme.accent,
      NabihTheme.success,
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: classes.length,
      itemBuilder: (context, i) {
        final c = classes[i];
        final color = colors[i % colors.length];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(c.courseCode, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                            ),
                            const Spacer(),
                            Text('${c.creditHours} Credit Hrs', style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(c.courseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.access_time, size: 15, color: NabihTheme.textLight),
                            const SizedBox(width: 4),
                            Text('${c.startTime} - ${c.endTime}', style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.room_outlined, size: 15, color: NabihTheme.textLight),
                            const SizedBox(width: 4),
                            Text(c.room, style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 15, color: NabihTheme.textLight),
                            const SizedBox(width: 4),
                            Text(c.instructor, style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
