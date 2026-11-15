// Passed at build time:
//   flutter run --dart-define-from-file=env.json
// Without them the app simply runs in local-only mode.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

const isSupabaseConfigured = supabaseUrl != '' && supabaseAnonKey != '';
