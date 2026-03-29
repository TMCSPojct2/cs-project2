
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class AuthService {
  /// Helper to check if user is guest by email (not .edu domain)
  static bool isGuest(String email) {
    final lower = email.toLowerCase();
    return !lower.endsWith('@uqu.edu.sa');
  }

  /// Generate a 6-digit OTP
  static String generateOtp() {
    final rand = Random.secure();
    return List.generate(6, (_) => rand.nextInt(10)).join();
  }

  static SupabaseClient get _client => SupabaseService.client;
  static GoTrueClient get _auth => _client.auth;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
  static String? get userId => currentUser?.id;

  /// Step 1: Send real OTP email to any address via Supabase magic-link OTP.
  static Future<void> sendOtp({required String email}) async {
    await _auth.signInWithOtp(
      email: email,
      shouldCreateUser: true,
      emailRedirectTo: null,
    );
  }

  /// Step 2: Verify OTP, set password, upsert profile.
  static Future<void> completeRegistration({
    required String email,
    required String token,
    required String password,
    required String name,
    String? phone,
    String? roleOverride,
  }) async {
    // Verify the OTP — logs the user in
    await _auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.email,
    );

    await _auth.updateUser(
      UserAttributes(
        password: password,
        data: {'name': name, if (phone != null) 'phone': phone},
      ),
    );

    final uid = _auth.currentUser?.id;
    if (uid != null) {
      final role = roleOverride ?? _roleFromEmailStatic(email);
      await _client.from('profiles').upsert({
        'id': uid,
        'name': name,
        'email': email,
        'role': role,
        if (phone != null) 'phone': phone,
      }, onConflict: 'id');
    }
  }

  static String _roleFromEmailStatic(String email) {
    final lower = email.toLowerCase();
    if (RegExp(r'^s\d+@uqu\.edu\.sa$').hasMatch(lower)) return 'student';
    if (lower.endsWith('@uqu.edu.sa')) return 'faculty';
    return 'visitor';
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
