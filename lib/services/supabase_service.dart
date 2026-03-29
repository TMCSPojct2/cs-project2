import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://pvxcxegwdwipjaiuqcxk.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB2eGN4ZWd3ZHdpcGphaXVxY3hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQ3OTA2NzQsImV4cCI6MjA5MDM2NjY3NH0.keA84NntSBzDtFN872DQ9luFRdrpsI9_MWi5LISp-IA';

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
}
