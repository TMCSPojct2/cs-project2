import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../data/demo_data.dart';

class NotificationsScreen extends StatefulWidget {
  final AppUser user;
  const NotificationsScreen({super.key, required this.user});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late List<AppNotification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = DemoData.notifications;
  }

  void _sendNotification() {
    final msgCtrl = TextEditingController();
    final titleCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Send Notification', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Send to all students in your class', style: TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: msgCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty) return;
                  setState(() {
                    _notifications.insert(0, AppNotification(
                      id: 'n_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim(),
                      message: msgCtrl.text.trim(),
                      date: DateTime.now(),
                      sender: widget.user.name,
                      type: 'class',
                    ));
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification sent to students!'), backgroundColor: NabihTheme.success),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Send'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'class': return Icons.class_rounded;
      case 'event': return Icons.event;
      case 'announcement': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'class': return NabihTheme.secondary;
      case 'event': return NabihTheme.primary;
      case 'announcement': return const Color(0xFF6C5CE7);
      default: return NabihTheme.textLight;
    }
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${date.day}/${date.month}';
  }

  @override
  Widget build(BuildContext context) {
    final canSend = widget.user.role == UserRole.faculty;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => setState(() {
                for (final n in _notifications) { n.isRead = true; }
              }),
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(child: Text('No notifications'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (context, i) {
                final n = _notifications[i];
                return Card(
                  color: n.isRead ? null : NabihTheme.primary.withValues(alpha: 0.04),
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    onTap: () => setState(() => n.isRead = true),
                    leading: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: _typeColor(n.type).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_typeIcon(n.type), color: _typeColor(n.type), size: 20),
                    ),
                    title: Row(
                      children: [
                        if (!n.isRead)
                          Container(
                            width: 8, height: 8,
                            margin: const EdgeInsets.only(right: 6),
                            decoration: const BoxDecoration(color: NabihTheme.primary, shape: BoxShape.circle),
                          ),
                        Expanded(child: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600, fontSize: 14))),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(n.sender, style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                            const Spacer(),
                            Text(_timeAgo(n.date), style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: canSend
          ? FloatingActionButton.extended(
              onPressed: _sendNotification,
              icon: const Icon(Icons.send),
              label: const Text('Send'),
            )
          : null,
    );
  }
}
