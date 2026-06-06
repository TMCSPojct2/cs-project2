import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/role_context.dart';

class NotificationsService {
  NotificationsService._();

  static final NotificationsService instance = NotificationsService._();
  static final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> refreshUnreadCount() async {
    try {
      final items = await listNotifications();
      final readIds = await listReadIds();
      final count = items.where((item) {
        final id = item['id']?.toString() ?? '';
        return id.isNotEmpty && !readIds.contains(id);
      }).length;
      unreadCount.value = count;
    } catch (_) {}
  }

  Future<List<Map<String, dynamic>>> listNotifications() async {
    final user = _client.auth.currentUser;
    final profile = activeSessionProfile;

    final data = await _client
        .from('notifications')
        .select('id, sender_id, sender_role, sender_name, target_type, target_value, title, body, category, is_admin_message, created_at')
        .order('created_at', ascending: false);
    final all = List<Map<String, dynamic>>.from(data);

    final email = user?.email ?? profile?.email ?? '';
    final roleValue = profile?.role.dbValue ?? '';

    final role = profile?.role;

    return all.where((n) {
      final type = n['target_type']?.toString() ?? '';
      final value = n['target_value']?.toString() ?? '';
      if (type == 'Group') {
        if (value == 'All Users' || value == roleValue) return true;
        // Faculty course/section notifications reach enrolled students
        if (role == UserRole.student) return _isEnrolledCourse(value);
        return false;
      }
      if (type == 'Individual') return email.isNotEmpty && value == email;
      return false;
    }).toList();
  }

  bool _isEnrolledCourse(String targetValue) {
    const courses = [
      'Software Engineering', 'هندسة البرمجيات',
      'Human Computer Interaction', 'التفاعل بين الإنسان والحاسوب',
    ];
    return courses.any((c) => targetValue.startsWith(c));
  }

  Future<Set<String>> listReadIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return <String>{};
    final data = await _client
        .from('notification_reads')
        .select('notification_id')
        .eq('user_id', user.id);
    return List<Map<String, dynamic>>.from(data)
        .map((row) => row['notification_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> sendNotification({
    required UserRole senderRole,
    required String targetType,
    required String targetValue,
    required String title,
    required String body,
    required bool isAdminMessage,
    String category = 'Academic',
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No active session');
    await _client.from('notifications').insert({
      'sender_id': user.id,
      'sender_role': senderRole.dbValue,
      'sender_name': activeSessionProfile?.name ?? '',
      'target_type': targetType,
      'target_value': targetValue,
      'title': title,
      'body': body,
      'category': category,
      'is_admin_message': isAdminMessage,
    });
  }

  Future<void> markRead(String notificationId) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    await _client.from('notification_reads').upsert({
      'notification_id': notificationId,
      'user_id': user.id,
    }, onConflict: 'notification_id,user_id');
  }

  Future<void> markAllRead(Iterable<String> notificationIds) async {
    final user = _client.auth.currentUser;
    if (user == null) return;
    final rows = notificationIds
        .where((id) => id.isNotEmpty)
        .map((id) => {'notification_id': id, 'user_id': user.id})
        .toList();
    if (rows.isEmpty) return;
    await _client.from('notification_reads').upsert(rows, onConflict: 'notification_id,user_id');
  }
}
