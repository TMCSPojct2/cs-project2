import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  static SupabaseClient get _client => SupabaseService.client;
  static GoTrueClient get _auth => _client.auth;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.id;

  /// Sign up with email + password. Sends confirmation email with OTP.
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
  }) async {
    return await _auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'phone': phone},
    );
  }

  /// Verify OTP code from email (signup confirmation)
  static Future<AuthResponse> verifyOTP({
    required String email,
    required String token,
    required OtpType type,
  }) async {
    return await _auth.verifyOTP(
      email: email,
      token: token,
      type: type,
    );
  }

  /// Sign in with email + password
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Sign in with OTP (magic link / code sent to email)
  static Future<void> signInWithOtp({required String email}) async {
    await _auth.signInWithOtp(email: email);
  }

  /// Sign out
  static Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user profile from profiles table
  static Future<Map<String, dynamic>?> getProfile() async {
    if (userId == null) return null;
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId!)
        .maybeSingle();
    return response;
  }

  /// Update profile
  static Future<void> updateProfile({
    String? name,
    String? department,
    String? studentId,
    String? phone,
  }) async {
    if (userId == null) return;
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (department != null) updates['department'] = department;
    if (studentId != null) updates['student_id'] = studentId;
    if (phone != null) updates['phone'] = phone;
    if (updates.isEmpty) return;
    await _client.from('profiles').update(updates).eq('id', userId!);
  }

  /// Listen to auth state changes
  static Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
}
