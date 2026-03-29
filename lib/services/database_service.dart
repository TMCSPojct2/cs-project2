import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import 'auth_service.dart';

class DatabaseService {
  static SupabaseClient get _client => SupabaseService.client;

  /// Send a notification (for OTP, announcements, etc)
  static Future<void> sendNotification({
    required String title,
    required String message,
    required String senderName,
    required String type,
    String? targetEmail,
    String? targetRole,
  }) async {
    final data = {
      'title': title,
      'message': message,
      'sender_name': senderName,
      'type': type,
      'created_at': DateTime.now().toIso8601String(),
    };
    if (targetEmail != null) data['target_email'] = targetEmail;
    if (targetRole != null) data['target_role'] = targetRole;
    await _client.from('notifications').insert(data);
  }

  // ── EVENTS ──
  static Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await _client
        .from('events')
        .select()
        .eq('is_active', true)
        .order('date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createEvent({
    required String title,
    required String description,
    required String date,
    required String time,
    required String location,
    required String category,
    required String organizer,
  }) async {
    await _client.from('events').insert({
      'title': title,
      'description': description,
      'date': date,
      'time': time,
      'location': location,
      'category': category,
      'organizer': organizer,
      'created_by': AuthService.userId,
    });
  }

  static Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }

  // ── ANNOUNCEMENTS ──
  static Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select()
        .order('is_pinned', ascending: false)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> createAnnouncement({
    required String title,
    required String content,
    required String author,
    required String target,
    bool isPinned = false,
  }) async {
    await _client.from('announcements').insert({
      'title': title,
      'content': content,
      'author': author,
      'target': target,
      'is_pinned': isPinned,
      'created_by': AuthService.userId,
    });
  }

  // ── SCHEDULES ──
  static Future<List<Map<String, dynamic>>> getSchedule() async {
    if (AuthService.userId == null) return [];
    final response = await _client
        .from('schedules')
        .select()
        .eq('user_id', AuthService.userId!)
        .order('day_of_week')
        .order('start_time');
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> addScheduleEntry({
    required String courseName,
    required String courseCode,
    required String instructor,
    required String room,
    required int dayOfWeek,
    required String startTime,
    required String endTime,
    required int creditHours,
  }) async {
    await _client.from('schedules').insert({
      'user_id': AuthService.userId,
      'course_name': courseName,
      'course_code': courseCode,
      'instructor': instructor,
      'room': room,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'credit_hours': creditHours,
    });
  }

  static Future<void> deleteScheduleEntry(String id) async {
    await _client.from('schedules').delete().eq('id', id);
  }

  // ── NOTIFICATIONS ──
  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final response = await _client
        .from('notifications')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<Set<String>> getReadNotificationIds() async {
    if (AuthService.userId == null) return {};
    final response = await _client
        .from('notification_reads')
        .select('notification_id')
        .eq('user_id', AuthService.userId!);
    return Set<String>.from(
      List<Map<String, dynamic>>.from(response).map((r) => r['notification_id'] as String),
    );
  }

  static Future<void> markNotificationRead(String notificationId) async {
    if (AuthService.userId == null) return;
    await _client.from('notification_reads').upsert({
      'user_id': AuthService.userId,
      'notification_id': notificationId,
    });
  }

  static Future<void> markAllNotificationsRead() async {
    if (AuthService.userId == null) return;
    final notifications = await getNotifications();
    for (final n in notifications) {
      await _client.from('notification_reads').upsert({
        'user_id': AuthService.userId,
        'notification_id': n['id'],
      });
    }
  }

  // ── GPA RECORDS ──
  static Future<List<Map<String, dynamic>>> getGpaRecords() async {
    if (AuthService.userId == null) return [];
    final response = await _client
        .from('gpa_records')
        .select()
        .eq('user_id', AuthService.userId!)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  static Future<void> saveGpaRecord({
    required String semester,
    required List<Map<String, dynamic>> courses,
    required double gpa,
    required int totalCredits,
  }) async {
    await _client.from('gpa_records').insert({
      'user_id': AuthService.userId,
      'semester': semester,
      'courses': courses,
      'gpa': gpa,
      'total_credits': totalCredits,
    });
  }
}
