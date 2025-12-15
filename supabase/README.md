# Supabase setup

## Steps
1) Create a Supabase project.
2) In SQL editor, run `schema.sql`, then `seed_defaults.sql`.
3) In Authentication > Policies, keep email/magic-link enabled. JWT audience: `authenticated`.
4) Create a service role key and anon key; note project URL.
5) Configure the Flutter app with these values (see `lib/config/supabase_keys.example.dart`).

## Row Level Security
All tables have RLS; policies restrict to the authenticated user (and family sharing via `family_id`).

## Default categories
Use `select public.seed_default_categories(auth.uid());` after profile creation to seed system defaults.
