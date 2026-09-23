/// Supabase keys are NOT written in the code.
/// They are passed in when you run the app:
///
///   flutter run --dart-define-from-file=env.json
///
/// `env.json` is listed in .gitignore, so your keys never reach GitHub.
/// Copy `env.example.json` to `env.json` and fill in your own values.
class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// Deep link Supabase sends the user back to after Google / Apple login.
  /// Must match AndroidManifest.xml, Info.plist and the Supabase dashboard.
  static const authRedirectUrl = 'carty://login-callback';

  static bool get isConfigured =>
      supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;
}
