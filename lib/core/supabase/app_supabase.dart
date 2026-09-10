import 'package:supabase_flutter/supabase_flutter.dart';

/// Project URL is public. Paste the anon/publishable key from
/// Supabase → Project Settings → API, or pass --dart-define=SUPABASE_ANON_KEY=...
abstract final class AppSupabase {
  static const url = 'https://zvvxqswrrpyauldxmyoz.supabase.co';
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2dnhxc3dycnB5YXVsZHhteW96Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg3OTMyMDMsImV4cCI6MjEwNDM2OTIwM30.8v2jMC8oWCQj1DWz2chjeO4K4RXDB_KjWRSD9Q8Tt7o',
  );

  static const authRedirectUrl = 'com.ahmadjamil.tum://login-callback';

  static bool get isConfigured => anonKey.isNotEmpty;

  static Future<void> initialize() async {
    if (!isConfigured) return;
    await Supabase.initialize(url: url, publishableKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
