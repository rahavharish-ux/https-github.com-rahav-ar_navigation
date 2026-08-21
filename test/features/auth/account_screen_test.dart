import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/auth_provider.dart';
import 'package:tn_ar_navigation/features/auth/account_screen.dart';
import 'package:tn_ar_navigation/models/app_user.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._fixed);

  final AppAuthState _fixed;
  int signOutCalls = 0;

  @override
  AppAuthState build() => _fixed;

  @override
  Future<void> signOut() async {
    signOutCalls++;
    state = const AppAuthUnauthenticated();
  }
}

void main() {
  testWidgets('Shows the signed-in email and a Saved Places entry point', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith(
            () => _FixedAuthNotifier(
              const AppAuthenticated(AppUser(id: 'u1', email: 'a@b.com')),
            ),
          ),
        ],
        child: const MaterialApp(home: AccountScreen()),
      ),
    );

    expect(find.textContaining('a@b.com'), findsOneWidget);
    expect(find.text('Saved Places'), findsOneWidget);
    expect(find.text('Sign Out'), findsOneWidget);
  });

  testWidgets('Tapping Sign Out calls signOut() and pops', (
    WidgetTester tester,
  ) async {
    final notifier = _FixedAuthNotifier(
      const AppAuthenticated(AppUser(id: 'u1', email: 'a@b.com')),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => notifier)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AccountScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Sign Out'));
    await tester.pumpAndSettle();

    expect(notifier.signOutCalls, 1);
    expect(find.byType(AccountScreen), findsNothing);
  });
}
