import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required Map<String, dynamic> data,
  }) {
    return _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> verifySignupCode({required String email, required String code}) {
    return _client.auth.verifyOTP(
      type: OtpType.signup,
      email: email,
      token: code,
    );
  }

  Future<void> sendPasswordResetCode(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  Future<AuthResponse> verifyPasswordResetCode({required String email, required String code}) {
    return _client.auth.verifyOTP(
      type: OtpType.recovery,
      email: email,
      token: code,
    );
  }

  Future<UserResponse> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> signOut() => _client.auth.signOut();
}
