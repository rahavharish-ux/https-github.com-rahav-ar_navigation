import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tn_ar_navigation/features/onboarding/onboarding_screen.dart';

void main() {
  testWidgets('Onboarding shows first page and advances on Next', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    expect(find.text('Navigate the world differently.'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('See directions in the real world.'), findsOneWidget);
  });

  testWidgets('Get Started appears on the last page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: OnboardingScreen()));

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Get Started'), findsOneWidget);
  });
}
