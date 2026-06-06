import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/role_context.dart';

class AdminDataService {
  AdminDataService._();

  static final AdminDataService instance = AdminDataService._();
  final SupabaseClient _client = Supabase.instance.client;

  Future<String?> getRoleByEmail(String email) async {
    final data = await _client
        .from('admin_invitations')
        .select('role')
        .eq('email', email.trim().toLowerCase())
        .maybeSingle();
    return data?['role']?.toString();
  }

  Future<List<Map<String, dynamic>>> listInvitations() async {
    final data = await _client
        .from('admin_invitations')
        .select('id, full_name, email, university_id, role, status, created_at')
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> createInvitation({
    required String fullName,
    required String email,
    required String universityId,
    required UserRole role,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('No active session');
    await _client.from('admin_invitations').insert({
      'full_name': fullName,
      'email': email,
      'university_id': universityId,
      'role': role.dbValue,
      'status': 'Pending',
      'created_by': user.id,
    });
  }
}
