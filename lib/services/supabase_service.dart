import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
    static const String supabaseUrl = 'https://aghtctrkaehdyxpppbcc.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFnaHRjdHJrYWVoZHl4cHBwYmNjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjI3MzUsImV4cCI6MjA5MDI5ODczNX0.tgfRXEU6I58t_aGSdXv8Hcumf-2_VrNIP4l8zt97NSM';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
