// Copy to supabase_keys.dart and fill with your project settings.
class SupabaseKeys {
  const SupabaseKeys({required this.url, required this.anonKey});

  final String url;
  final String anonKey;
}

// Example placeholder (do not commit real keys)
const supabaseKeys = SupabaseKeys(
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-key',
);
