import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardService {
  DashboardService._();

  static final DashboardService instance = DashboardService._();
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, int>> adminCounts() async {
    final users = await _client.from('profiles').select('id');
    final announcements = await _client
        .from('notifications')
        .select('id')
        .eq('is_admin_message', true);
    final events = await _client
        .from('events')
        .select('id')
        .eq('status', 'Published');
    return {
      'users': List.from(users).length,
      'announcements': List.from(announcements).length,
      'events': List.from(events).length,
    };
  }
}
