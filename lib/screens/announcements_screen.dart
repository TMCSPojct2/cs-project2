import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../models/announcement_model.dart';
import '../data/demo_data.dart';

class AnnouncementsScreen extends StatefulWidget {
  final AppUser user;
  const AnnouncementsScreen({super.key, required this.user});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late List<Announcement> _announcements;

  @override
  void initState() {
    super.initState();
    _announcements = List.from(DemoData.announcements);
  }

  void _createAnnouncement() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String target = 'All Students';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('New Announcement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: contentCtrl, decoration: const InputDecoration(labelText: 'Content'), maxLines: 3),
            const SizedBox(height: 12),
            StatefulBuilder(builder: (context, setLocal) {
              return DropdownButtonFormField<String>(
                value: target,
                decoration: const InputDecoration(labelText: 'Target Audience'),
                items: ['All Students', 'All', 'Computer Engineering', 'Information Systems'].map(
                  (t) => DropdownMenuItem(value: t, child: Text(t)),
                ).toList(),
                onChanged: (v) => setLocal(() => target = v!),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _announcements.insert(0, Announcement(
                      id: 'new_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      date: DateTime.now(),
                      author: widget.user.name,
                      target: target,
                    ));
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Announcement published!'), backgroundColor: NabihTheme.success),
                  );
                },
                child: const Text('Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canCreate = widget.user.role == UserRole.staff;

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: _announcements.isEmpty
          ? const Center(child: Text('No announcements yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _announcements.length,
              itemBuilder: (context, i) => _announcementCard(_announcements[i]),
            ),
      floatingActionButton: canCreate
          ? FloatingActionButton.extended(
              onPressed: _createAnnouncement,
              icon: const Icon(Icons.add),
              label: const Text('New'),
            )
          : null,
    );
  }

  Widget _announcementCard(Announcement a) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (a.isPinned) ...[
                  const Icon(Icons.push_pin, size: 16, color: NabihTheme.error),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(a.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NabihTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(a.target, style: const TextStyle(fontSize: 10, color: NabihTheme.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(a.content, style: const TextStyle(fontSize: 14, color: NabihTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: NabihTheme.textLight),
                const SizedBox(width: 4),
                Text(a.author, style: const TextStyle(fontSize: 12, color: NabihTheme.textLight)),
                const Spacer(),
                Text('${a.date.day}/${a.date.month}/${a.date.year}', style: const TextStyle(fontSize: 12, color: NabihTheme.textLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
