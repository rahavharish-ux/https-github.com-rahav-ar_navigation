import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/auth_provider.dart';
import 'package:tn_ar_navigation/features/auth/auth_screen.dart';
import 'package:tn_ar_navigation/features/home/widgets/quick_action_row.dart';
import 'package:tn_ar_navigation/features/saved_places/saved_places_screen.dart';
import 'package:tn_ar_navigation/models/app_user.dart';

class _FixedAuthNotifier extends AuthNotifier {
  _FixedAuthNotifier(this._fixed);

  final AppAuthState _fixed;

  @override
  AppAuthState build() => _fixed;
}

void main() {
  Widget wrap(AppAuthState authState) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith(() => _FixedAuthNotifier(authState)),
      ],
      child: const MaterialApp(home: Scaffold(body: QuickActionRow())),
    );
  }

  testWidgets('Tapping Home shows the honest coming-soon message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppAuthUnauthenticated()));

    await tester.tap(find.text('Home'));
    await tester.pump();

    expect(
      find.text('Saved & recent places arrive in a later phase'),
      findsOneWidget,
    );
  });

  testWidgets('Tapping Recent shows the honest coming-soon message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppAuthUnauthenticated()));

    await tester.tap(find.text('Recent'));
    await tester.pump();

    expect(
      find.text('Saved & recent places arrive in a later phase'),
      findsOneWidget,
    );
  });

  testWidgets('Tapping Saved while signed out opens the sign-in screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const AppAuthUnauthenticated()));

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthScreen), findsOneWidget);
  });

  testWidgets('Tapping Saved while signed in opens the saved places list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const AppAuthenticated(AppUser(id: 'u1', email: 'a@b.com'))),
    );

    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();

    expect(find.byType(SavedPlacesScreen), findsOneWidget);
  });
}
