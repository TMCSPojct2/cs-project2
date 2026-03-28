import 'package:flutter/material.dart';
import '../theme.dart';
import '../services/database_service.dart';

class NotificationsScreen extends StatefulWidget {
  final Map<String, dynamic> profile;
  const NotificationsScreen({super.key, required this.profile});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  Set<String> _readIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await DatabaseService.getNotifications();
      final readIds = await DatabaseService.getReadNotificationIds();
      setState(() {
        _notifications = data;
        _readIds = readIds;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load notifications: $e'), backgroundColor: NabihTheme.error),
        );
      }
    }
  }

  Future<void> _markAsRead(String id) async {
    if (_readIds.contains(id)) return;
    try {
      await DatabaseService.markNotificationRead(id);
      setState(() => _readIds.add(id));
    } catch (_) {}
  }

  Future<void> _markAllRead() async {
    try {
      await DatabaseService.markAllNotificationsRead();
      setState(() {
        for (final n in _notifications) {
          _readIds.add(n['id'].toString());
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: NabihTheme.error),
        );
      }
    }
  }

  void _sendNotification() {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();
    String type = 'class';
    String? targetRole = 'student';

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
            const Text('Send to students', style: TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            const SizedBox(height: 12),
            TextField(controller: msgCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
            const SizedBox(height: 12),
            StatefulBuilder(builder: (context, setLocal) {
              return DropdownButtonFormField<String>(
                value: type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: ['class', 'event', 'announcement', 'general'].map(
                  (t) => DropdownMenuItem(value: t, child: Text(t)),
                ).toList(),
                onChanged: (v) => setLocal(() => type = v!),
              );
            }),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty || msgCtrl.text.trim().isEmpty) return;
                  try {
                    await DatabaseService.sendNotification(
                      title: titleCtrl.text.trim(),
                      message: msgCtrl.text.trim(),
                      senderName: widget.profile['name'] ?? 'Unknown',
                      type: type,
                      targetRole: targetRole,
                    );
                    if (mounted) Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification sent!'), backgroundColor: NabihTheme.success),
                    );
                    _loadNotifications();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to send: $e'), backgroundColor: NabihTheme.error),
                    );
                  }
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

  IconData _typeIcon(String? type) {
    switch (type) {
      case 'class': return Icons.class_rounded;
      case 'event': return Icons.event;
      case 'announcement': return Icons.campaign;
      default: return Icons.notifications;
    }
  }

  Color _typeColor(String? type) {
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
    final canSend = widget.profile['role'] == 'faculty';
    final unreadCount = _notifications.where((n) => !_readIds.contains(n['id'].toString())).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        automaticallyImplyLeading: false,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text('Mark all read', style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text('No notifications')),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _notifications.length,
                      itemBuilder: (context, i) {
                        final n = _notifications[i];
                        final id = n['id'].toString();
                        final isRead = _readIds.contains(id);
                        final createdAt = DateTime.tryParse(n['created_at'] ?? '');
                        final timeStr = createdAt != null ? _timeAgo(createdAt) : '';

                        return Card(
                          color: isRead ? null : NabihTheme.primary.withValues(alpha: 0.04),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            onTap: () => _markAsRead(id),
                            leading: Container(
                              width: 42, height: 42,
                              decoration: BoxDecoration(
                                color: _typeColor(n['type']).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_typeIcon(n['type']), color: _typeColor(n['type']), size: 20),
                            ),
                            title: Row(
                              children: [
                                if (!isRead)
                                  Container(
                                    width: 8, height: 8,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: const BoxDecoration(color: NabihTheme.primary, shape: BoxShape.circle),
                                  ),
                                Expanded(child: Text(n['title'] ?? '', style: TextStyle(fontWeight: isRead ? FontWeight.normal : FontWeight.w600, fontSize: 14))),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(n['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: NabihTheme.textSecondary)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text(n['sender_name'] ?? '', style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                                    const Spacer(),
                                    Text(timeStr, style: const TextStyle(fontSize: 11, color: NabihTheme.textLight)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
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
