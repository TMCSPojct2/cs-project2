import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/database_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const AnnouncementsScreen({super.key, required this.profile});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  List<Map<String, dynamic>> _announcements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnnouncements();
  }

  Future<void> _loadAnnouncements() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService.getAnnouncements();
      setState(() {
        _announcements = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load announcements: $e'), backgroundColor: NabihTheme.error),
        );
      }
    }
  }

  void _createAnnouncement() {
    final titleCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String target = 'All Students';
    bool isPinned = false;

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
              return Column(
                children: [
                  DropdownButtonFormField<String>(
                    value: target,
                    decoration: const InputDecoration(labelText: 'Target Audience'),
                    items: ['All Students', 'All', 'Computer Engineering', 'Information Systems'].map(
                      (t) => DropdownMenuItem(value: t, child: Text(t)),
                    ).toList(),
                    onChanged: (v) => setLocal(() => target = v!),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('Pin Announcement'),
                    value: isPinned,
                    onChanged: (v) => setLocal(() => isPinned = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty || contentCtrl.text.trim().isEmpty) return;
                  try {
                    await DatabaseService.createAnnouncement(
                      title: titleCtrl.text.trim(),
                      content: contentCtrl.text.trim(),
                      author: widget.profile['name'] ?? 'Unknown',
                      target: target,
                      isPinned: isPinned,
                    );
                    if (mounted) Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Announcement published!'), backgroundColor: NabihTheme.success),
                    );
                    _loadAnnouncements();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to publish: $e'), backgroundColor: NabihTheme.error),
                    );
                  }
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
    final canCreate = widget.profile['role'] == 'staff';

    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnnouncements,
              child: _announcements.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No announcements yet')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _announcements.length,
                      itemBuilder: (context, i) => _announcementCard(_announcements[i]),
                    ),
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

  Widget _announcementCard(Map<String, dynamic> a) {
    final isPinned = a['is_pinned'] == true;
    final createdAt = DateTime.tryParse(a['created_at'] ?? '');
    final dateStr = createdAt != null ? '${createdAt.day}/${createdAt.month}/${createdAt.year}' : '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isPinned) ...[
                  const Icon(Icons.push_pin, size: 16, color: NabihTheme.error),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(a['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: NabihTheme.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(a['target'] ?? '', style: const TextStyle(fontSize: 10, color: NabihTheme.secondary)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(a['content'] ?? '', style: const TextStyle(fontSize: 14, color: NabihTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: NabihTheme.textLight),
                const SizedBox(width: 4),
                Text(a['author'] ?? '', style: const TextStyle(fontSize: 12, color: NabihTheme.textLight)),
                const Spacer(),
                Text(dateStr, style: const TextStyle(fontSize: 12, color: NabihTheme.textLight)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
