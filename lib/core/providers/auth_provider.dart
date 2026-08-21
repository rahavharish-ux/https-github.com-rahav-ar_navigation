import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../services/auth_service.dart';
import '../config/supabase_config.dart';

/// Named `AppAuthState` (not `AuthState`) to avoid colliding with
/// `supabase_flutter`'s own exported `AuthState` type.
sealed class AppAuthState {
  const AppAuthState();
}

/// No Supabase project configured yet — a real, first-class state (not an
/// error), same reasoning as `CameraUnavailable`/`VisionUnavailable`.
class AppAuthNotConfigured extends AppAuthState {
  const AppAuthNotConfigured();
}

class AppAuthUnauthenticated extends AppAuthState {
  const AppAuthUnauthenticated();
}

class AppAuthenticating extends AppAuthState {
  const AppAuthenticating();
}

/// Sign-up succeeded but no session exists yet — the project's default
/// Supabase auth settings require confirming via email first. A real,
/// first-class state, not an error.
class AppAuthEmailConfirmationRequired extends AppAuthState {
  const AppAuthEmailConfirmationRequired();
}

class AppAuthenticated extends AppAuthState {
  const AppAuthenticated(this.user);

  final AppUser user;
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, same pattern as `LocationError`/`CameraError`.
class AppAuthError extends AppAuthState {
  const AppAuthError(this.message);

  final String message;
}

final authProvider = NotifierProvider<AuthNotifier, AppAuthState>(
  AuthNotifier.new,
);

/// Real Supabase email/password auth (Phase 14), mirroring
/// `LocationNotifier`/`CameraNotifier`'s shape. Subscribes to Supabase's
/// real auth-state stream once configured, so a session restored from
/// local storage (or a token refresh) updates `state` without any screen
/// having to poll for it.
class AuthNotifier extends Notifier<AppAuthState> {
  late final AuthService _service;
  StreamSubscription<AppUser?>? _subscription;

  @override
  AppAuthState build() {
    _service = const AuthService();
    ref.onDispose(() => _subscription?.cancel());

    if (!SupabaseConfig.isConfigured) return const AppAuthNotConfigured();

    _subscription = _service.userChanges.listen((user) {
      state = user == null
          ? const AppAuthUnauthenticated()
          : AppAuthenticated(user);
    });

    final current = _service.currentUser;
    return current == null
        ? const AppAuthUnauthenticated()
        : AppAuthenticated(current);
  }

  Future<void> signUp({required String email, required String password}) async {
    if (state is AppAuthenticating) return;
    state = const AppAuthenticating();
    try {
      final user = await _service.signUp(email: email, password: password);
      state = user == null
          ? const AppAuthEmailConfirmationRequired()
          : AppAuthenticated(user);
    } on AuthServiceException catch (error) {
      state = AppAuthError(error.message);
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (state is AppAuthenticating) return;
    state = const AppAuthenticating();
    try {
      final user = await _service.signIn(email: email, password: password);
      state = AppAuthenticated(user);
    } on AuthServiceException catch (error) {
      state = error.isEmailNotConfirmed
          ? const AppAuthEmailConfirmationRequired()
          : AppAuthError(error.message);
    }
  }

  Future<void> signOut() async {
    await _service.signOut();
    state = const AppAuthUnauthenticated();
  }
}
