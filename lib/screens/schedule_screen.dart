import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/database_service.dart';

class ScheduleScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const ScheduleScreen({super.key, required this.profile});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _days = [0, 1, 2, 3, 4];
  final _dayLabels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu'];

  List<Map<String, dynamic>> _schedule = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _days.length, vsync: this);
    final today = DateTime.now().weekday % 7;
    final idx = _days.indexOf(today);
    if (idx >= 0) _tabController.index = idx;
    _loadSchedule();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService.getSchedule();
      setState(() {
        _schedule = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load schedule: $e'), backgroundColor: NabihTheme.error),
        );
      }
    }
  }

  void _addEntry() {
    final courseNameCtrl = TextEditingController();
    final courseCodeCtrl = TextEditingController();
    final instructorCtrl = TextEditingController();
    final roomCtrl = TextEditingController();
    final startTimeCtrl = TextEditingController();
    final endTimeCtrl = TextEditingController();
    int selectedDay = _tabController.index;
    int creditHours = 3;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Class', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: courseNameCtrl, decoration: const InputDecoration(labelText: 'Course Name')),
              const SizedBox(height: 12),
              TextField(controller: courseCodeCtrl, decoration: const InputDecoration(labelText: 'Course Code')),
              const SizedBox(height: 12),
              TextField(controller: instructorCtrl, decoration: const InputDecoration(labelText: 'Instructor')),
              const SizedBox(height: 12),
              TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Room')),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startTimeCtrl,
                      decoration: const InputDecoration(labelText: 'Start Time', hintText: '08:00'),
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                        if (time != null) {
                          startTimeCtrl.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: endTimeCtrl,
                      decoration: const InputDecoration(labelText: 'End Time', hintText: '09:30'),
                      readOnly: true,
                      onTap: () async {
                        final time = await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                        if (time != null) {
                          endTimeCtrl.text = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              StatefulBuilder(builder: (context, setLocal) {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: selectedDay,
                        decoration: const InputDecoration(labelText: 'Day'),
                        items: List.generate(5, (i) => DropdownMenuItem(value: i, child: Text(_dayLabels[i]))),
                        onChanged: (v) => setLocal(() => selectedDay = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: creditHours,
                        decoration: const InputDecoration(labelText: 'Credit Hrs'),
                        items: [1, 2, 3, 4].map((c) => DropdownMenuItem(value: c, child: Text('$c'))).toList(),
                        onChanged: (v) => setLocal(() => creditHours = v!),
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (courseNameCtrl.text.trim().isEmpty ||
                        courseCodeCtrl.text.trim().isEmpty ||
                        startTimeCtrl.text.isEmpty ||
                        endTimeCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please fill in required fields'), backgroundColor: NabihTheme.error),
                      );
                      return;
                    }
                    try {
                      await DatabaseService.addScheduleEntry(
                        courseName: courseNameCtrl.text.trim(),
                        courseCode: courseCodeCtrl.text.trim(),
                        instructor: instructorCtrl.text.trim(),
                        room: roomCtrl.text.trim(),
                        dayOfWeek: selectedDay,
                        startTime: startTimeCtrl.text,
                        endTime: endTimeCtrl.text,
                        creditHours: creditHours,
                      );
                      if (mounted) Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Class added!'), backgroundColor: NabihTheme.success),
                      );
                      _loadSchedule();
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to add class: $e'), backgroundColor: NabihTheme.error),
                      );
                    }
                  },
                  child: const Text('Add Class'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteEntry(String id) async {
    try {
      await DatabaseService.deleteScheduleEntry(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class removed'), backgroundColor: NabihTheme.success),
      );
      _loadSchedule();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e'), backgroundColor: NabihTheme.error),
      );
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: _days.map((day) => _buildDayView(day)).toList(),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntry,
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }

  Widget _buildDayView(int dayOfWeek) {
    final classes = _schedule.where((c) => c['day_of_week'] == dayOfWeek).toList()
      ..sort((a, b) => (a['start_time'] ?? '').compareTo(b['start_time'] ?? ''));

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

    return RefreshIndicator(
      onRefresh: _loadSchedule,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: classes.length,
        itemBuilder: (context, i) {
          final c = classes[i];
          final color = colors[i % colors.length];
          return Dismissible(
            key: Key(c['id'].toString()),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: NabihTheme.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              return await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete Class'),
                  content: Text('Remove ${c['course_name']}?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: NabihTheme.error))),
                  ],
                ),
              );
            },
            onDismissed: (_) => _deleteEntry(c['id'].toString()),
            child: Card(
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
                                  child: Text(c['course_code'] ?? '', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
                                ),
                                const Spacer(),
                                Text('${c['credit_hours'] ?? 0} Credit Hrs', style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(c['course_name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 15, color: NabihTheme.textLight),
                                const SizedBox(width: 4),
                                Text('${c['start_time'] ?? ''} - ${c['end_time'] ?? ''}', style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.room_outlined, size: 15, color: NabihTheme.textLight),
                                const SizedBox(width: 4),
                                Text(c['room'] ?? '', style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 15, color: NabihTheme.textLight),
                                const SizedBox(width: 4),
                                Text(c['instructor'] ?? '', style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
