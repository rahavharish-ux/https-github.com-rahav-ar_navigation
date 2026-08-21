import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tn_ar_navigation/services/auth_service.dart';

User _user() => const User(
  id: 'u1',
  appMetadata: {},
  userMetadata: {},
  aud: 'authenticated',
  createdAt: '2026-08-21T00:00:00Z',
);

Session _session() =>
    Session(accessToken: 'token', tokenType: 'bearer', user: _user());

/// Real, honest failure paths when no Supabase project is configured
/// (dotenv never loaded here, same as this project's other widget/unit
/// tests) — mirrors `GeocodingService`'s missing-API-key test and
/// `ar_platform_service_test.dart`'s "never throws, resolves honestly"
/// pattern. None of these touch `Supabase.instance`, which would throw
/// since `Supabase.initialize` is never called in this test environment.
void main() {
  tearDown(dotenv.clean);

  const service = AuthService();

  test('currentUser is null when not configured', () {
    expect(service.currentUser, isNull);
  });

  test('userChanges is an empty stream when not configured', () async {
    final events = await service.userChanges.toList();
    expect(events, isEmpty);
  });

  test('signIn throws a real, honest AuthServiceException when not '
      'configured', () async {
    await expectLater(
      service.signIn(email: 'a@b.com', password: 'password123'),
      throwsA(isA<AuthServiceException>()),
    );
  });

  test('signUp throws a real, honest AuthServiceException when not '
      'configured', () async {
    await expectLater(
      service.signUp(email: 'a@b.com', password: 'password123'),
      throwsA(isA<AuthServiceException>()),
    );
  });

  test('signOut does not throw when not configured', () async {
    await expectLater(service.signOut(), completes);
  });

  group('hasRealSession', () {
    test('is false for a response with a real user but no session -- the '
        'exact shape a pending-email-confirmation sign-up returns, and the '
        'real bug found on a physical device (checking `user` instead of '
        '`session` treated this as a real authenticated session)', () {
      final response = AuthResponse(user: _user());

      expect(hasRealSession(response), isFalse);
    });

    test('is true for a response with a real session', () {
      final response = AuthResponse(session: _session());

      expect(hasRealSession(response), isTrue);
    });
  });

  test('AuthServiceException defaults isEmailNotConfirmed to false, and '
      'carries it when set -- AuthNotifier.signIn uses this to surface the '
      'same AppAuthEmailConfirmationRequired state sign-up uses, instead of '
      'a generic error, matching what a real unconfirmed-account sign-in '
      'attempt does on a physical device', () {
    const generic = AuthServiceException('boom');
    const unconfirmed = AuthServiceException(
      'Email not confirmed',
      isEmailNotConfirmed: true,
    );

    expect(generic.isEmailNotConfirmed, isFalse);
    expect(unconfirmed.isEmailNotConfirmed, isTrue);
  });
}
