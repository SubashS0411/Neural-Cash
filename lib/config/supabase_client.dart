import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_keys.dart';

/// Initializes a singleton Supabase client. Call once at app start.
Future<SupabaseClient> initSupabase() async {
  await Supabase.initialize(
    url: supabaseKeys.url,
    anonKey: supabaseKeys.anonKey,
  );
  return Supabase.instance.client;
}
