import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/route_provider.dart';
import 'package:tn_ar_navigation/core/theme/app_theme.dart';
import 'package:tn_ar_navigation/features/navigation/navigation_screen.dart';
import 'package:tn_ar_navigation/features/route_preview/route_preview_screen.dart';
import 'package:tn_ar_navigation/models/place_model.dart';
import 'package:tn_ar_navigation/models/route_model.dart';
import 'package:latlong2/latlong.dart';

/// Safety net against any accidental real network call during these tests
/// — same approach as home_screen_test.dart/search_screen_test.dart (see
/// that file's comment for why the map itself no longer needs this since
/// Phase 11's switch to the natively-tiled Google Maps SDK).
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 1);
  }
}

/// A fixed [RouteState] without hitting the network or a real GPS fix —
/// this screen never calculates a route in an isolated widget test since
/// no [LocationAvailable] state exists to trigger it (see
/// `RoutePreviewScreen._calculate`), so overriding the provider is the
/// real way to exercise each rendered state.
class _FixedRouteNotifier extends RouteNotifier {
  _FixedRouteNotifier(this._fixed);

  final RouteState _fixed;

  @override
  RouteState build() => _fixed;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  final destination = const Place(
    name: 'Gandhipuram',
    address: 'Gandhipuram, Coimbatore, Tamil Nadu, India',
    latitude: 11.0168,
    longitude: 76.9558,
  );

  Widget wrap(Widget child, {RouteState? routeState}) {
    return ProviderScope(
      overrides: [
        if (routeState != null)
          routeProvider.overrideWith(() => _FixedRouteNotifier(routeState)),
      ],
      child: MaterialApp(theme: AppTheme.light, home: child),
    );
  }

  testWidgets('Shows the destination name, address, and travel modes', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(RoutePreviewScreen(destination: destination)));

    expect(find.text('Gandhipuram'), findsOneWidget);
    expect(
      find.text('Gandhipuram, Coimbatore, Tamil Nadu, India'),
      findsOneWidget,
    );
    expect(find.text('Driving'), findsOneWidget);
    expect(find.text('Walking'), findsOneWidget);
    expect(find.text('Cycling'), findsOneWidget);
  });

  testWidgets('Start Navigation is disabled until a route is ready', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(RoutePreviewScreen(destination: destination)));

    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Start Navigation'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('Start Navigation is enabled once a route is ready', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        RoutePreviewScreen(destination: destination),
        routeState: const RouteReady(
          AppRoute(
            distanceMeters: 12400,
            durationSeconds: 900,
            polyline: [LatLng(11.1271, 78.6569), LatLng(11.0168, 76.9558)],
            instructions: [],
          ),
        ),
      ),
    );

    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Start Navigation'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets(
    'Tapping the enabled Start Navigation button opens NavigationScreen',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(
          RoutePreviewScreen(destination: destination),
          routeState: const RouteReady(
            AppRoute(
              distanceMeters: 12400,
              durationSeconds: 900,
              polyline: [LatLng(11.1271, 78.6569), LatLng(11.0168, 76.9558)],
              instructions: [],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Start Navigation'));
      await tester.pumpAndSettle();

      expect(find.byType(NavigationScreen), findsOneWidget);
    },
  );

  testWidgets(
    'Shows an honest message instead of an unexplained spinner when no GPS fix exists',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        wrap(RoutePreviewScreen(destination: destination)),
      );
      await tester.pump();

      expect(
        find.text('Get your location first to see a route to this place.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('Renders distance and ETA when a route is ready', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        RoutePreviewScreen(destination: destination),
        routeState: const RouteReady(
          AppRoute(
            distanceMeters: 12400,
            durationSeconds: 900,
            polyline: [LatLng(11.1271, 78.6569), LatLng(11.0168, 76.9558)],
            instructions: [],
          ),
        ),
      ),
    );

    expect(find.textContaining('15 min'), findsOneWidget);
    expect(find.textContaining('12.4 km'), findsOneWidget);
  });

  testWidgets('Shows an honest message when the travel mode is unsupported', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        RoutePreviewScreen(destination: destination),
        routeState: const RouteModeUnsupported(),
      ),
    );

    expect(
      find.textContaining("isn't available in this development"),
      findsOneWidget,
    );
  });

  testWidgets('Shows an honest message when the route request fails', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        RoutePreviewScreen(destination: destination),
        routeState: const RouteFailed('network error'),
      ),
    );

    expect(
      find.text(
        "Couldn't calculate a route right now. Check your connection and "
        'try again.',
      ),
      findsOneWidget,
    );
  });
}
