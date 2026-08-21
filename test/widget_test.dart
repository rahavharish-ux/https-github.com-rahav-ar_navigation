// App-level smoke test: boots the real app entry point and follows the
// real navigation flow (splash -> onboarding), not a fake shortcut.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tn_ar_navigation/main.dart';

void main() {
  testWidgets('App boots into splash, then navigates to onboarding', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: TnArNavigationApp()));

    expect(find.text('TN AR NAV'), findsOneWidget);
    expect(find.text('AR Navigation for Tamil Nadu'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Navigate the world differently.'), findsOneWidget);
  });
}
