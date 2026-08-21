import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/auth_provider.dart';
import 'package:tn_ar_navigation/features/auth/auth_screen.dart';
import 'package:tn_ar_navigation/models/app_user.dart';

/// A fixed [AppAuthState] without touching the real `AuthService`, same
/// approach as `camera_preview_screen_test.dart`'s `_FixedCameraNotifier`.
class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._fixed);

  final AppAuthState _fixed;
  int signInCalls = 0;
  int signUpCalls = 0;

  @override
  AppAuthState build() => _fixed;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalls++;
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    signUpCalls++;
  }
}

void main() {
  Widget wrap(AppAuthState state) {
    return ProviderScope(
      overrides: [authProvider.overrideWith(() => _FixedAuthNotifier(state))],
      child: const MaterialApp(home: AuthScreen()),
    );
  }

  testWidgets(
    'Shows an honest not-configured message instead of a form when no '
    'Supabase project is set up (this test environment, real dotenv '
    'never loaded)',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: AuthScreen())),
      );

      expect(find.textContaining('No backend is configured'), findsOneWidget);
      expect(find.byType(TextField), findsNothing);
    },
  );

  testWidgets('Shows the sign-in form with email/password fields', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppAuthUnauthenticated()));

    expect(find.text('Sign In'), findsWidgets);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text("Don't have an account? Create one"), findsOneWidget);
  });

  testWidgets('Toggling switches to the sign-up form', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppAuthUnauthenticated()));

    await tester.tap(find.text("Don't have an account? Create one"));
    await tester.pump();

    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Already have an account? Sign in'), findsOneWidget);
  });

  testWidgets('Shows a generic sign-in failure message, no raw error text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const AppAuthError('Invalid login credentials')),
    );

    expect(
      find.text(
        "Couldn't sign in. Check your email and password and try again.",
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Invalid login credentials'), findsNothing);
  });

  testWidgets('Submit button is disabled while authenticating', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppAuthenticating()));

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets('Entering email/password and tapping Sign In calls signIn()', (
    WidgetTester tester,
  ) async {
    final notifier = _FixedAuthNotifier(const AppAuthUnauthenticated());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => notifier)],
        child: const MaterialApp(home: AuthScreen()),
      ),
    );

    await tester.enterText(find.byType(TextField).first, 'a@b.com');
    await tester.enterText(find.byType(TextField).last, 'password123');
    // 'Sign In' also appears in the AppBar title -- target the button.
    await tester.tap(find.widgetWithText(FilledButton, 'Sign In'));
    await tester.pump();

    expect(notifier.signInCalls, 1);
    expect(notifier.signUpCalls, 0);
  });

  testWidgets('Becoming AppAuthenticated pops the screen', (
    WidgetTester tester,
  ) async {
    final notifier = _FixedAuthNotifier(const AppAuthUnauthenticated());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [authProvider.overrideWith(() => notifier)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(AuthScreen), findsOneWidget);

    notifier.state = const AppAuthenticated(
      AppUser(id: 'u1', email: 'a@b.com'),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsNothing);
  });
}
