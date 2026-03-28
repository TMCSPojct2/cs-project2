import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://dkdbyixfxtwmekcprddp.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRrZGJ5aXhmeHR3bWVrY3ByZGRwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjI2NTcsImV4cCI6MjA5MDI5ODY1N30.8yyuZXhIs9DaY1RIuyMyb0fHk7zwYLzAp0fdVKY3Whg';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
