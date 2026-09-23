import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

/// Holds the login state for the whole app.
/// Any widget can call `context.watch<AuthProvider>()` to rebuild
/// when the user logs in or out.
class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  late final StreamSubscription<AuthState> _subscription;

  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._service) {
    // Supabase tells us whenever the session changes
    // (email login, Google/Apple redirect coming back, logout, token refresh).
    _subscription = _service.authStateChanges.listen((_) => notifyListeners());
  }

  User? get user => _service.currentUser;
  bool get isLoggedIn => user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Name shown in the drawer. Google/Apple give "full_name",
  /// email sign-up gives "username" (we save it on register).
  String get displayName {
    final meta = user?.userMetadata ?? {};
    final name = meta['username'] ?? meta['full_name'] ?? meta['name'];
    if (name is String && name.isNotEmpty) return name;
    return user?.email ?? 'Guest';
  }

  String? get avatarUrl {
    final url = user?.userMetadata?['avatar_url'];
    return url is String && url.isNotEmpty ? url : null;
  }

  Future<bool> signInWithEmail(String email, String password) {
    return _run(() => _service.signInWithEmail(email: email, password: password));
  }

  /// Returns true when the account is ready to use immediately.
  Future<bool?> signUp({
    required String email,
    required String password,
    required String username,
    required String phone,
  }) async {
    bool? loggedIn;
    final ok = await _run(() async {
      loggedIn = await _service.signUp(
        email: email,
        password: password,
        username: username,
        phone: phone,
      );
    });
    return ok ? loggedIn : null;
  }

  Future<bool> signInWithGoogle() => _run(_service.signInWithGoogle);

  Future<bool> signInWithApple() => _run(_service.signInWithApple);

  Future<void> signOut() => _service.signOut();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Shared loading + error handling for every auth action.
  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      return false;
    } catch (_) {
      _errorMessage = 'Something went wrong. Check your connection and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
