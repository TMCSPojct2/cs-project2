import 'package:supabase_flutter/supabase_flutter.dart';

class EventsService {
  EventsService._();

  static final EventsService instance = EventsService._();
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> listEvents() async {
    try {
      final data = await _client
          .from('events')
          .select('id, title, category, event_date, event_time, location, description, status, created_at')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return _fallbackEvents;
    }
  }

  Future<Set<String>> listFavoriteEventIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return <String>{};
    final data = await _client
        .from('event_favorites')
        .select('event_id')
        .eq('user_id', user.id);
    return List<Map<String, dynamic>>.from(data)
        .map((row) => row['event_id']?.toString() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
  }

  Future<void> createEvent({
    required String title,
    required String category,
    required String date,
    required String time,
    required String location,
    required String description,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No active session');
    await _client.from('events').insert({
      'title': title,
      'category': category,
      'event_date': date,
      'event_time': time,
      'location': location,
      'description': description,
      'status': 'Published',
      'created_by': user.id,
    });
  }

  Future<void> toggleFavorite({required String eventId, required bool currentlyFavorite}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No active session');
    if (currentlyFavorite) {
      await _client.from('event_favorites').delete().eq('user_id', user.id).eq('event_id', eventId);
    } else {
      await _client.from('event_favorites').insert({'user_id': user.id, 'event_id': eventId});
    }
  }
}

const List<Map<String, dynamic>> _fallbackEvents = [
  {
    'id': 'public-ai-summit',
    'title': 'AI Innovation Summit 2026',
    'category': 'Workshop',
    'event_date': 'OCT 24',
    'event_time': '10:00 AM - 04:00 PM',
    'location': 'Main Auditorium, Building A',
    'description': 'A full-day university event focused on artificial intelligence, smart services, student innovation, and practical demonstrations from academic teams.',
    'status': 'Published',
  },
];
