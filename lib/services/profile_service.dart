import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/account_rules.dart';
import '../data/role_context.dart';

class ProfileService {
  ProfileService._();

  static final ProfileService instance = ProfileService._();
  final SupabaseClient _client = Supabase.instance.client;

  Future<void> upsertProfile({
    required String id,
    required String fullName,
    required String email,
    required String role,
    required String universityId,
  }) {
    return _client.from('profiles').upsert({
      'id': id,
      'full_name': fullName,
      'email': email,
      'role': role,
      'university_id': universityId,
    });
  }

  Future<Map<String, dynamic>?> getProfile(String id) {
    return _client.from('profiles').select().eq('id', id).maybeSingle();
  }


  Future<List<Map<String, dynamic>>> listProfilesForAdmin() async {
    final data = await _client
        .from('profiles')
        .select('id, full_name, email, role, university_id, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>?> ensureProfileForCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      return null;
    }

    final existing = await getProfile(user.id);
    if (existing != null) {
      return existing;
    }

    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? metadata['email']?.toString() ?? '';
    final fullName = metadata['full_name']?.toString().trim().isNotEmpty == true ? metadata['full_name'].toString().trim() : email.split('@').first;
    final universityId = metadata['university_id']?.toString().trim() ?? '';
    final role = userRoleFromValue(metadata['role'], fallback: roleFromRegistrationEmail(email));

    await upsertProfile(
      id: user.id,
      fullName: fullName,
      email: email,
      role: role.dbValue,
      universityId: universityId,
    );

    return getProfile(user.id);
  }
}
