import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Talks to Supabase Auth. Screens never call Supabase directly —
/// they go through AuthProvider, which uses this class.
class AuthService {
  final SupabaseClient _client;

  AuthService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Returns true if the user is logged in right away,
  /// false if Supabase requires them to confirm their email first.
  Future<bool> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      // Saved in auth.users.raw_user_meta_data; a database trigger
      // copies it into the public.profiles table.
      data: {'username': username, 'phone': phone},
    );
    return response.session != null;
  }

  /// Opens the Google login page in the browser.
  /// After the user logs in, Google -> Supabase -> sends the user back
  /// to the app through the deep link `carty://login-callback`.
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: Env.authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  /// Same flow as Google, but with Apple.
  Future<void> signInWithApple() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: Env.authRedirectUrl,
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _client.auth.signOut();
}
