import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/theme/app_theme.dart';
import 'package:tn_ar_navigation/features/home/home_screen.dart';
import 'package:tn_ar_navigation/features/search/search_screen.dart';

/// A safety net against any accidental real network call during these
/// tests (e.g. from `RoutingService`/`GeocodingService`, if a future
/// change wires one up without a provider override) — the map itself
/// (Phase 11: Google Maps SDK) fetches tiles natively, not through
/// `dart:io`, so this doesn't govern the map specifically anymore. Fail
/// connections immediately instead of letting them hang on flaky network.
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 1);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Widget wrap(Widget child) {
    return ProviderScope(
      child: MaterialApp(theme: AppTheme.light, home: child),
    );
  }

  testWidgets('Home screen shows search prompt and travel modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const HomeScreen()));

    expect(find.text('Where do you want to go?'), findsOneWidget);
    expect(find.text('Driving'), findsOneWidget);
    expect(find.text('Walking'), findsOneWidget);
    expect(find.text('Cycling'), findsOneWidget);
  });

  testWidgets('Tapping search opens the search screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const HomeScreen()));

    await tester.tap(find.text('Where do you want to go?'));
    await tester.pumpAndSettle();

    expect(find.byType(SearchScreen), findsOneWidget);
  });
}
