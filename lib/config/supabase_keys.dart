// Temporary placeholder keys for development. Replace with real project values.
class SupabaseKeys {
  const SupabaseKeys({required this.url, required this.anonKey});

  final String url;
  final String anonKey;
}

// TODO: Replace with values from Supabase project (do not commit secrets in production).
const supabaseKeys = SupabaseKeys(
  url: 'https://example-project.supabase.co',
  anonKey: 'example-anon-key',
);
