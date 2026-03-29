import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
    static const String supabaseUrl = 'https://ydoxvnuxgxazgopiqogi.supabase.co';
    static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlkb3h2bnV4Z3hhemdvcGlxb2dpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3MjM5MjksImV4cCI6MjA5MDI5OTkyOX0.KgolPGnXk1LkGkHMK4c6jahQRyf7LCwrP3Er78B7-eg';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
