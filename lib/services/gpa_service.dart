import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GpaService {
  GpaService._();

  static final GpaService instance = GpaService._();
  final SupabaseClient _client = Supabase.instance.client;

  final ValueNotifier<double?> gpaNotifier = ValueNotifier(null);

  Future<Map<String, dynamic>?> latestGpa() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;
    final record = await _client
        .from('gpa_records')
        .select('id, gpa, courses, created_at')
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    if (record != null) {
      gpaNotifier.value = (record['gpa'] as num?)?.toDouble();
    }
    return record;
  }

  Future<void> saveGpa({required double gpa, required List<Map<String, dynamic>> courses}) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No active session');
    // Update notifier immediately so home screen reflects the result
    // even if the DB insert fails.
    gpaNotifier.value = double.parse(gpa.toStringAsFixed(2));
    await _client.from('gpa_records').insert({
      'user_id': user.id,
      'gpa': double.parse(gpa.toStringAsFixed(2)),
      'courses': courses,
    });
  }
}
