import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/core/theme/app_theme.dart';
import 'package:tn_ar_navigation/features/navigation/navigation_screen.dart';
import 'package:tn_ar_navigation/features/navigation/providers/navigation_provider.dart';
import 'package:tn_ar_navigation/models/navigation_instruction.dart';
import 'package:tn_ar_navigation/models/place_model.dart';
import 'package:tn_ar_navigation/models/route_model.dart';

/// Safety net against any accidental real network call during these tests
/// — same approach as the other map-bearing screen tests (see
/// home_screen_test.dart's comment for why the map itself no longer
/// needs this since Phase 11's switch to the natively-tiled Google Maps
/// SDK).
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 1);
  }
}

/// A fixed [NavigationState] without a real GPS stream — skips
/// [NavigationNotifier.build]'s `locationProvider` subscription entirely,
/// so the screen renders exactly the given state and nothing more, the
/// same technique `route_preview_screen_test.dart` uses for [RouteState].
class _FixedNavigationNotifier extends NavigationNotifier {
  _FixedNavigationNotifier(this._fixed);

  final NavigationState _fixed;

  @override
  NavigationState build() => _fixed;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  const destination = Place(
    name: 'Gandhipuram',
    address: 'Gandhipuram, Coimbatore, Tamil Nadu, India',
    latitude: 11.0168,
    longitude: 76.9558,
  );

  final route = AppRoute(
    distanceMeters: 1110,
    durationSeconds: 120,
    polyline: const [LatLng(11.0, 78.0), LatLng(11.01, 78.0)],
    instructions: [
      NavigationInstruction.fromOsrmStep({
        'distance': 555.0,
        'name': 'Trichy Road',
        'maneuver': {
          'type': 'turn',
          'modifier': 'right',
          'location': [78.0, 11.005],
        },
      }),
    ],
  );

  Widget wrap(NavigationState navState) {
    return ProviderScope(
      overrides: [
        navigationProvider.overrideWith(
          () => _FixedNavigationNotifier(navState),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        const NavigationScreen(destination: destination),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('Shows the current maneuver text and distance while navigating', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        NavigationState(
          status: NavigationStatus.navigating,
          route: route,
          destination: const LatLng(11.01, 78.0),
          distanceToNextManeuverMeters: 320,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Turn right onto Trichy Road'), findsOneWidget);
    expect(find.textContaining('320 m'), findsOneWidget);
  });

  testWidgets('Shows an honest off-route banner', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        NavigationState(
          status: NavigationStatus.offRoute,
          route: route,
          destination: const LatLng(11.01, 78.0),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text("You're off the route."), findsOneWidget);
  });

  testWidgets('Shows a recalculating banner', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        NavigationState(
          status: NavigationStatus.recalculating,
          route: route,
          destination: const LatLng(11.01, 78.0),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Recalculating your route…'), findsOneWidget);
  });

  testWidgets('Shows a paused banner and a Resume control', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        NavigationState(
          status: NavigationStatus.paused,
          route: route,
          destination: const LatLng(11.01, 78.0),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('Navigation paused'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);
  });

  testWidgets('Shows arrival with a Done control that closes the screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        NavigationState(
          status: NavigationStatus.arrived,
          route: route,
          destination: const LatLng(11.01, 78.0),
          remainingDistanceMeters: 0,
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text("You've arrived"), findsOneWidget);
    expect(find.text('You have arrived at your destination.'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationScreen), findsNothing);
  });

  testWidgets('Stop closes the screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        NavigationState(
          status: NavigationStatus.navigating,
          route: route,
          destination: const LatLng(11.01, 78.0),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stop'));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationScreen), findsNothing);
  });
}
