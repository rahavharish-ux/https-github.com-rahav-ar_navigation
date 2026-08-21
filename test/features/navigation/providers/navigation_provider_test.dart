import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/core/providers/location_provider.dart';
import 'package:tn_ar_navigation/features/navigation/providers/navigation_provider.dart';
import 'package:tn_ar_navigation/models/location_model.dart';
import 'package:tn_ar_navigation/models/navigation_instruction.dart';
import 'package:tn_ar_navigation/models/route_model.dart';

/// A real recalculation (off-route path) would hit the network — blocked
/// here so it fails fast and deterministically instead of hanging on this
/// environment's flaky network, same approach as
/// `route_preview_screen_test.dart`.
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 1);
  }
}

/// Lets the test push arbitrary [LocationState] values — like a live GPS
/// tick — without a real geolocator platform channel.
class _FakeLocationNotifier extends LocationNotifier {
  @override
  LocationState build() => const LocationInitial();

  void emit(LocationState next) => state = next;
}

AppLocation _fixAt(double lat, double lng) => AppLocation(
  latitude: lat,
  longitude: lng,
  accuracyMeters: 5,
  speedMetersPerSecond: 0,
  headingDegrees: 0,
  timestamp: DateTime(2026),
);

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  // A short straight route with a real depart step (at the origin — should
  // never be treated as the "next" maneuver) and a real turn before arrival.
  const origin = LatLng(11.000, 78.000);
  const turnPoint = LatLng(11.005, 78.000);
  const destination = LatLng(11.010, 78.000);
  final route = AppRoute(
    distanceMeters: 1110,
    durationSeconds: 120,
    polyline: const [origin, turnPoint, destination],
    instructions: [
      NavigationInstruction.fromOsrmStep({
        'distance': 555.0,
        'name': 'Avinashi Road',
        'maneuver': {
          'type': 'depart',
          'modifier': 'straight',
          'location': [origin.longitude, origin.latitude],
        },
      }),
      NavigationInstruction.fromOsrmStep({
        'distance': 555.0,
        'name': 'Trichy Road',
        'maneuver': {
          'type': 'turn',
          'modifier': 'right',
          'location': [turnPoint.longitude, turnPoint.latitude],
        },
      }),
      NavigationInstruction.fromOsrmStep({
        'distance': 0.0,
        'name': '',
        'maneuver': {
          'type': 'arrive',
          'modifier': null,
          'location': [destination.longitude, destination.latitude],
        },
      }),
    ],
  );

  late _FakeLocationNotifier fakeLocation;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        locationProvider.overrideWith(() {
          fakeLocation = _FakeLocationNotifier();
          return fakeLocation;
        }),
      ],
    );
    addTearDown(container.dispose);
  });

  test('start() skips the depart step and targets the real next maneuver', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);

    final state = container.read(navigationProvider);
    expect(state.status, NavigationStatus.navigating);
    expect(state.currentInstruction?.type, 'turn');
  });

  test(
    'a GPS update on the route recomputes progress toward the next turn',
    () {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);

      fakeLocation.emit(LocationAvailable(_fixAt(11.0045, 78.000)));

      final state = container.read(navigationProvider);
      expect(state.status, NavigationStatus.approachingTurn);
      expect(state.distanceToNextManeuverMeters, lessThan(150));
    },
  );

  test('reaching the maneuver point advances to the next instruction', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);

    fakeLocation.emit(LocationAvailable(_fixAt(11.005, 78.000)));

    final state = container.read(navigationProvider);
    expect(state.currentInstruction?.type, 'arrive');
  });

  test('reaching the destination marks navigation arrived', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);

    fakeLocation.emit(LocationAvailable(_fixAt(11.010, 78.000)));

    final state = container.read(navigationProvider);
    expect(state.status, NavigationStatus.arrived);
    expect(state.remainingDistanceMeters, 0);
  });

  test(
    'straying far from the polyline goes off-route and attempts a real recalculation',
    () async {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);

      // ~500m east of the route — well past the off-route threshold.
      fakeLocation.emit(LocationAvailable(_fixAt(11.005, 78.005)));

      // A recalculation request starts immediately (Dart runs an async
      // function's body synchronously up to its first `await`, so the
      // "recalculating" transition is already visible here, not just
      // after awaiting the Future).
      expect(
        container.read(navigationProvider).status,
        NavigationStatus.recalculating,
      );

      // The blocked-network recalculation fails fast; self-heals back to
      // offRoute (not a separate terminal error state) with a diagnostics
      // message, ready to retry on the next GPS update.
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final state = container.read(navigationProvider);
      expect(state.status, NavigationStatus.offRoute);
      expect(state.errorMessage, isNotNull);
    },
  );

  test('a single wrong-direction blip does not trigger a recalculation '
      '(needs sustained confirmation)', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);

    // Two forward fixes (heading toward the turn) establish a real
    // previous position, then one reversal — only one qualifying
    // wrong-direction update, below the confirmation count.
    fakeLocation.emit(LocationAvailable(_fixAt(11.0002, 78.000)));
    fakeLocation.emit(LocationAvailable(_fixAt(11.0003, 78.000)));
    fakeLocation.emit(LocationAvailable(_fixAt(11.0002, 78.000)));

    final state = container.read(navigationProvider);
    expect(state.status, isNot(NavigationStatus.wrongDirection));
    expect(state.status, isNot(NavigationStatus.recalculating));
  });

  test('sustained movement away from the next maneuver — still within the '
      'off-route distance threshold — triggers a real recalculation', () async {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);

    // Forward, then two consecutive reversals (e.g. a U-turn on the
    // same road) — both remain on the polyline (same longitude), so
    // this is not caught by the distance-based off-route check alone.
    fakeLocation.emit(LocationAvailable(_fixAt(11.0002, 78.000)));
    fakeLocation.emit(LocationAvailable(_fixAt(11.0003, 78.000)));
    fakeLocation.emit(LocationAvailable(_fixAt(11.0002, 78.000)));
    fakeLocation.emit(LocationAvailable(_fixAt(11.0001, 78.000)));

    // Same reasoning as the off-route test: the recalculation starts
    // synchronously, so by the time `emit` returns the status has
    // already moved past the transient `wrongDirection` value into
    // `recalculating`.
    expect(
      container.read(navigationProvider).status,
      NavigationStatus.recalculating,
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));

    final state = container.read(navigationProvider);
    expect(state.status, NavigationStatus.offRoute);
    expect(state.errorMessage, isNotNull);
  });

  test('pause stops progress updates until resume', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);
    container.read(navigationProvider.notifier).pause();

    fakeLocation.emit(LocationAvailable(_fixAt(11.005, 78.000)));
    expect(container.read(navigationProvider).status, NavigationStatus.paused);

    container.read(navigationProvider.notifier).resume();
    expect(
      container.read(navigationProvider).status,
      isNot(NavigationStatus.paused),
    );
  });

  test('a full simulated drive along the real polyline -- from origin, through '
      'the turn, to arrival -- transitions through every real maneuver and '
      'status in order (Phase 15: previously only isolated single-update '
      'snapshots were tested, not a continuous simulated route drive; see '
      'KNOWN_LIMITATIONS.md)', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);
    var state = container.read(navigationProvider);
    expect(state.status, NavigationStatus.navigating);
    expect(state.currentInstruction?.type, 'turn');

    // Walk a real sequence of fixes along the straight leg from origin
    // toward the turn point, as a live GPS stream would deliver them.
    // approachingThresholdMeters is 150 -- 11.003 (~222m) is still
    // "navigating"; 11.004 (~111m) is the first point within it.
    for (final lat in [11.001, 11.002, 11.003, 11.004]) {
      fakeLocation.emit(LocationAvailable(_fixAt(lat, 78.000)));
      state = container.read(navigationProvider);
      expect(state.status, isNot(NavigationStatus.offRoute));
      expect(state.currentInstruction?.type, 'turn');
    }
    expect(state.status, NavigationStatus.approachingTurn);

    // Reach the turn point -- within the real arrival/turning threshold
    // (25m, the same constant the loop above uses to advance past a
    // waypoint), so this appears as advancing straight to the real final
    // "arrive" step rather than a separately observable "turning" status
    // -- turningThresholdMeters and arrivalThresholdMeters are the same
    // value, so "turning" is only ever reachable for the final leg.
    fakeLocation.emit(LocationAvailable(_fixAt(11.005, 78.000)));
    expect(
      container.read(navigationProvider).currentInstruction?.type,
      'arrive',
    );

    // Continue along the second leg toward the destination.
    for (final lat in [11.006, 11.007, 11.008, 11.009]) {
      fakeLocation.emit(LocationAvailable(_fixAt(lat, 78.000)));
      state = container.read(navigationProvider);
      expect(state.status, isNot(NavigationStatus.offRoute));
      expect(state.status, isNot(NavigationStatus.arrived));
    }

    // Reach the real destination.
    fakeLocation.emit(LocationAvailable(_fixAt(11.010, 78.000)));
    final finalState = container.read(navigationProvider);
    expect(finalState.status, NavigationStatus.arrived);
    expect(finalState.remainingDistanceMeters, 0);
  });

  test('stop resets to idle', () {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);
    container.read(navigationProvider.notifier).stop();

    expect(container.read(navigationProvider).status, NavigationStatus.idle);
    expect(container.read(navigationProvider).route, isNull);
  });
}
