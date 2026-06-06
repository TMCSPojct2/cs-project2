import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/app_content.dart';
import '../data/role_context.dart';

class ScheduleService {
  ScheduleService._();

  static final ScheduleService instance = ScheduleService._();
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<ScheduleItem>> listSchedule(UserRole role) async {
    final user = _client.auth.currentUser;
    if (user == null) return <ScheduleItem>[];
    final data = await _client
        .from('schedule_items')
        .select('title, time_range, meta, location, accent_hex, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: true);
    final rows = List<Map<String, dynamic>>.from(data);
    if (rows.isEmpty) return <ScheduleItem>[];
    return rows.map((row) {
      return ScheduleItem(
        title: row['title']?.toString() ?? '',
        time: row['time_range']?.toString() ?? '',
        meta: row['meta']?.toString() ?? '',
        place: row['location']?.toString() ?? '',
        accent: _parseColor(row['accent_hex']?.toString()),
      );
    }).toList();
  }

  Future<void> addItem({
    required UserRole role,
    required String title,
    required String timeRange,
    required String meta,
    required String location,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No active session');
    await _client.from('schedule_items').insert({
      'user_id': user.id,
      'role': role.dbValue,
      'title': title,
      'time_range': timeRange,
      'meta': meta,
      'location': location,
      'accent_hex': role == UserRole.faculty ? '#26476D' : '#0F5B57',
    });
  }

  Color _parseColor(String? value) {
    final text = (value ?? '#0F5B57').replaceAll('#', '').trim();
    final hex = int.tryParse(text, radix: 16) ?? 0x0F5B57;
    return Color(0xFF000000 | hex);
  }
}
