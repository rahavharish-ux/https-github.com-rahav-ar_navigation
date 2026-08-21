import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:supabase_flutter/supabase_flutter.dart'
    as gotrue
    show AuthState;

import '../core/config/supabase_config.dart';
import '../models/app_user.dart';

class AuthServiceException implements Exception {
  const AuthServiceException(this.message, {this.isEmailNotConfirmed = false});

  final String message;

  /// True for gotrue's real `email_not_confirmed` error code — lets
  /// `AuthNotifier` surface this as the same first-class
  /// `AppAuthEmailConfirmationRequired` state sign-up uses, instead of a
  /// generic error, the same way a real sign-in attempt against an
  /// unconfirmed account was found to behave on a physical device.
  final bool isEmailNotConfirmed;

  @override
  String toString() => message;
}

/// Thin, swappable wrapper over `supabase_flutter`'s auth client, same
/// pattern as `GeocodingService`/`LocationService`: one concrete class, a
/// single custom exception type callers catch, no premature interface.
/// Email/password only this phase (see ARCHITECTURE.md's Phase 14 note for
/// why magic link/OAuth weren't adopted).
class AuthService {
  const AuthService();

  GoTrueClient get _auth => Supabase.instance.client.auth;

  AppUser? get currentUser {
    if (!SupabaseConfig.isConfigured) return null;
    return _toAppUser(_auth.currentUser);
  }

  /// Emits the current user (or `null` when signed out) on every real auth
  /// change — sign in, sign out, token refresh. An empty stream when
  /// Supabase isn't configured, so `AuthNotifier` never touches
  /// `Supabase.instance` in that case.
  Stream<AppUser?> get userChanges {
    if (!SupabaseConfig.isConfigured) return const Stream.empty();
    return _auth.onAuthStateChange.map(
      (gotrue.AuthState state) => _toAppUser(state.session?.user),
    );
  }

  /// `null` means the sign-up request itself succeeded but no session
  /// exists yet — a real, non-error Supabase state (email confirmation
  /// required before the user can sign in), not an exception. Callers
  /// (`AuthNotifier`) surface this as its own first-class state, the same
  /// "don't shove a real non-error case into the error state" rule
  /// `CameraUnavailable`/`RouteState.modeUnsupported` already established.
  ///
  /// Real bug caught on a physical device: this checked `response.user`
  /// instead of `response.session`. Supabase's sign-up response includes
  /// a real `user` object even when email confirmation is still pending
  /// (`response.session` is what's actually null in that case) — checking
  /// `user` meant the app treated an unconfirmed sign-up as a real
  /// authenticated session, when no session token existed at all. Every
  /// later authenticated call (e.g. saving a place) then failed for real,
  /// silently, since nothing here or upstream checked the outcome.
  Future<AppUser?> signUp({required String email, required String password}) {
    return _run(() async {
      final response = await _auth.signUp(email: email, password: password);
      if (!hasRealSession(response)) return null;
      return _toAppUser(response.user);
    });
  }

  Future<AppUser> signIn({required String email, required String password}) {
    return _run(() async {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final user = response.user;
      if (user == null) {
        throw const AuthServiceException("Couldn't sign in right now.");
      }
      return _toAppUser(user)!;
    });
  }

  Future<void> signOut() {
    if (!SupabaseConfig.isConfigured) return Future.value();
    return _auth.signOut();
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    if (!SupabaseConfig.isConfigured) {
      throw const AuthServiceException(
        'No Supabase project configured. Copy .env.example to .env and set '
        'SUPABASE_URL/SUPABASE_ANON_KEY to a real project — see SETUP.md.',
      );
    }
    try {
      return await action();
    } on AuthServiceException {
      rethrow;
    } on AuthException catch (error) {
      throw AuthServiceException(
        error.message,
        isEmailNotConfirmed: error.code == 'email_not_confirmed',
      );
    } catch (error) {
      throw AuthServiceException('Network error: $error');
    }
  }

  AppUser? _toAppUser(User? user) =>
      user == null ? null : AppUser(id: user.id, email: user.email);
}

/// True only when [response] carries a real, usable session — not just a
/// `user` object. Pulled out as a pure function for testability, same
/// pattern `camera_selection.dart`/`ar_availability.dart` established.
///
/// Supabase's sign-up response includes a real `user` object even when
/// email confirmation is still pending (only `session` is null in that
/// case) — checking `user` instead of `session` was a real bug caught on
/// a physical device: the app treated an unconfirmed sign-up as a real
/// authenticated session, when no session token existed at all.
bool hasRealSession(AuthResponse response) => response.session != null;
