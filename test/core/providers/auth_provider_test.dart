import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/auth_provider.dart';

void main() {
  tearDown(dotenv.clean);

  test('starts as AppAuthNotConfigured when no Supabase project exists', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(authProvider), isA<AppAuthNotConfigured>());
  });

  test('signIn surfaces a real AppAuthError when not configured, never '
      'throws', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(authProvider.notifier)
        .signIn(email: 'a@b.com', password: 'password123');

    expect(container.read(authProvider), isA<AppAuthError>());
  });

  test('signUp surfaces a real AppAuthError when not configured, never '
      'throws', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(authProvider.notifier)
        .signUp(email: 'a@b.com', password: 'password123');

    expect(container.read(authProvider), isA<AppAuthError>());
  });

  test('signOut does not throw and resets to AppAuthUnauthenticated', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(authProvider.notifier).signOut();

    expect(container.read(authProvider), isA<AppAuthUnauthenticated>());
  });
}
