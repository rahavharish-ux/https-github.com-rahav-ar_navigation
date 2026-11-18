import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/core/providers/location_provider.dart';
import 'package:tn_ar_navigation/core/providers/routing_service_provider.dart';
import 'package:tn_ar_navigation/core/utils/geo_math.dart';
import 'package:tn_ar_navigation/features/navigation/providers/navigation_provider.dart';
import 'package:tn_ar_navigation/models/location_model.dart';
import 'package:tn_ar_navigation/models/navigation_instruction.dart';
import 'package:tn_ar_navigation/models/route_model.dart';

import '../../../fakes/fake_routing_service.dart';

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
  late FakeRoutingService routing;
  late ProviderContainer container;

  setUp(() {
    routing = FakeRoutingService();
    container = ProviderContainer(
      overrides: [
        locationProvider.overrideWith(() {
          fakeLocation = _FakeLocationNotifier();
          return fakeLocation;
        }),
        routingServiceProvider.overrideWithValue(routing),
      ],
    );
    addTearDown(container.dispose);
  });

  /// A different, real-shaped route a recalculation can resolve to.
  final reroute = AppRoute(
    distanceMeters: 800,
    durationSeconds: 90,
    polyline: const [LatLng(11.005, 78.005), destination],
    instructions: [
      NavigationInstruction.fromOsrmStep({
        'distance': 800.0,
        'name': 'Service Road',
        'maneuver': {
          'type': 'depart',
          'modifier': 'left',
          'location': [78.005, 11.005],
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

  /// Lets queued microtasks (a resolved fake request and the code awaiting
  /// it) run, without any wall-clock delay.
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  /// Starts a session and pushes one fix far off the polyline, leaving a
  /// recalculation request pending in [routing].
  void startAndGoOffRoute() {
    container
        .read(navigationProvider.notifier)
        .start(route: route, destination: destination);
    fakeLocation.emit(LocationAvailable(_fixAt(11.005, 78.005)));
  }

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

      expect(routing.requests, hasLength(1));
      expect(routing.lastRequest.destination, destination);

      // The recalculation fails; navigation self-heals back to offRoute
      // (not a separate terminal error state) with a diagnostics message,
      // ready to retry on the next GPS update.
      routing.lastRequest.fail();
      await settle();

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

    expect(routing.requests, hasLength(1));
    routing.lastRequest.fail();
    await settle();

    final state = container.read(navigationProvider);
    expect(state.status, NavigationStatus.offRoute);
    expect(state.errorMessage, isNotNull);
  });

  test('a successful recalculation adopts the new route and resumes '
      'navigating', () async {
    startAndGoOffRoute();
    routing.lastRequest.succeed(reroute);
    await settle();

    final state = container.read(navigationProvider);
    expect(state.route, same(reroute));
    expect(state.errorMessage, isNull);
    expect(state.status, isNot(NavigationStatus.recalculating));
    expect(state.status, isNot(NavigationStatus.idle));
  });

  group('session teardown while a recalculation is in flight (M0 '
      'regression)', () {
    test('stop() during a pending recalculation that then succeeds stays '
        'idle -- the stopped session is not resurrected', () async {
      startAndGoOffRoute();
      expect(
        container.read(navigationProvider).status,
        NavigationStatus.recalculating,
      );

      container.read(navigationProvider.notifier).stop();
      routing.lastRequest.succeed(reroute);
      await settle();

      final state = container.read(navigationProvider);
      expect(state.status, NavigationStatus.idle);
      expect(state.route, isNull);
      expect(state.destination, isNull);
      expect(state.isActive, isFalse);
    });

    test('stop() during a pending recalculation that then fails stays idle '
        'with no error', () async {
      startAndGoOffRoute();
      container.read(navigationProvider.notifier).stop();
      routing.lastRequest.fail();
      await settle();

      final state = container.read(navigationProvider);
      expect(state.status, NavigationStatus.idle);
      expect(state.errorMessage, isNull);
    });

    test('a recalculation from a previous session cannot overwrite a newly '
        'started session', () async {
      startAndGoOffRoute();
      final stale = routing.lastRequest;
      container.read(navigationProvider.notifier).stop();
      // Back on the route before the new session starts, so the new
      // session has no reroute of its own in flight.
      fakeLocation.emit(LocationAvailable(_fixAt(11.001, 78.000)));
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);
      expect(routing.requests, hasLength(1));

      stale.succeed(reroute);
      await settle();

      final state = container.read(navigationProvider);
      expect(state.route, same(route));
      expect(state.status, NavigationStatus.navigating);
      expect(state.currentInstruction?.type, 'turn');
    });

    test('disposing the provider during a pending recalculation does not '
        'write state afterwards (no use-after-dispose error)', () async {
      startAndGoOffRoute();
      final pending = routing.lastRequest;
      container.dispose();

      // Before the fix, completing the request made `_recalculate` assign
      // `state` on a disposed Ref, which surfaced as an uncaught async
      // error and failed the test.
      pending.succeed(reroute);
      await settle();
    });
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

  group('pause/resume while a recalculation is in flight (M0 closure '
      'regression)', () {
    void pause() => container.read(navigationProvider.notifier).pause();
    void resume() => container.read(navigationProvider.notifier).resume();

    test('a reroute that succeeds while paused adopts the new route but '
        'stays paused', () async {
      startAndGoOffRoute();
      pause();
      routing.lastRequest.succeed(reroute);
      await settle();

      final state = container.read(navigationProvider);
      expect(state.status, NavigationStatus.paused);
      expect(state.route, same(reroute));
      expect(routing.requests, hasLength(1));
    });

    test('a reroute that fails while paused stays paused', () async {
      startAndGoOffRoute();
      pause();
      routing.lastRequest.fail();
      await settle();

      expect(
        container.read(navigationProvider).status,
        NavigationStatus.paused,
      );
      expect(routing.requests, hasLength(1));
    });

    test('resuming before the reroute finishes waits for it -- no second, '
        'parallel reroute against the old route', () async {
      startAndGoOffRoute();
      pause();
      resume();

      expect(
        container.read(navigationProvider).status,
        NavigationStatus.recalculating,
      );
      expect(routing.requests, hasLength(1));

      routing.lastRequest.succeed(reroute);
      await settle();

      final state = container.read(navigationProvider);
      expect(state.route, same(reroute));
      expect(state.status, isNot(NavigationStatus.paused));
      expect(state.status, isNot(NavigationStatus.recalculating));
      expect(routing.requests, hasLength(1));
    });

    test('resuming after a reroute completed while paused continues on the '
        'new route', () async {
      startAndGoOffRoute();
      pause();
      routing.lastRequest.succeed(reroute);
      await settle();
      resume();

      final state = container.read(navigationProvider);
      expect(state.route, same(reroute));
      expect(state.status, isNot(NavigationStatus.paused));
      expect(state.status, isNot(NavigationStatus.offRoute));
      expect(routing.requests, hasLength(1));
    });

    test('stop() while paused during a reroute stays idle when the reroute '
        'completes', () async {
      startAndGoOffRoute();
      pause();
      container.read(navigationProvider.notifier).stop();
      routing.lastRequest.succeed(reroute);
      await settle();

      expect(container.read(navigationProvider).status, NavigationStatus.idle);
    });
  });

  group('latest position is used when async work or a pause ends (M0 '
      'closure regression)', () {
    test('a completed reroute measures progress from the newest GPS fix, '
        'not the position at request time', () async {
      startAndGoOffRoute(); // request made at (11.005, 78.005)
      // The user keeps moving while the request is in flight.
      const newest = LatLng(11.0075, 78.0025); // on the rerouted line
      fakeLocation.emit(
        LocationAvailable(_fixAt(newest.latitude, newest.longitude)),
      );

      routing.lastRequest.succeed(reroute);
      await settle();

      final state = container.read(navigationProvider);
      expect(state.currentLocation, newest);
      expect(
        state.remainingDistanceMeters,
        closeTo(haversineMeters(newest, destination), 0.01),
      );
    });

    test('resume() recomputes from the newest GPS fix, including one that '
        'arrived while paused', () {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);
      fakeLocation.emit(LocationAvailable(_fixAt(11.001, 78.000)));
      container.read(navigationProvider.notifier).pause();

      // Moved while paused; if the user now stands still the GPS distance
      // filter sends no further fix, so resume() must use this one.
      fakeLocation.emit(LocationAvailable(_fixAt(11.0045, 78.000)));
      container.read(navigationProvider.notifier).resume();

      final state = container.read(navigationProvider);
      expect(state.currentLocation, const LatLng(11.0045, 78.000));
      expect(state.status, NavigationStatus.approachingTurn);
    });
  });

  group('remaining distance and ETA (M0 regression)', () {
    // OSRM step i's `distance` runs from maneuver i to maneuver i+1. With
    // the next maneuver at index k, the user is still on step k-1, so the
    // distance left is (distance to maneuver k) + sum(step k..end).

    test('includes the distance still to travel to the next maneuver', () {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);
      final fix = _fixAt(11.0045, 78.000);
      fakeLocation.emit(LocationAvailable(fix));

      final state = container.read(navigationProvider);
      final toTurn = haversineMeters(
        LatLng(fix.latitude, fix.longitude),
        turnPoint,
      );
      expect(state.currentInstruction?.type, 'turn');
      expect(state.distanceToNextManeuverMeters, closeTo(toTurn, 0.01));
      expect(state.remainingDistanceMeters, closeTo(toTurn + 555 + 0, 0.01));
    });

    test('on the final leg it is the distance to the destination, not 0', () {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);
      // At the turn point the index advances to the final "arrive" step,
      // ~556m before the destination.
      fakeLocation.emit(LocationAvailable(_fixAt(11.005, 78.000)));

      final state = container.read(navigationProvider);
      expect(state.currentInstruction?.type, 'arrive');
      expect(state.status, isNot(NavigationStatus.arrived));
      expect(
        state.remainingDistanceMeters,
        closeTo(haversineMeters(turnPoint, destination), 0.01),
      );
      expect(state.remainingDistanceMeters, greaterThan(500));
    });

    test("ETA is remaining distance at the route's average pace", () {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);
      fakeLocation.emit(LocationAvailable(_fixAt(11.0045, 78.000)));

      final state = container.read(navigationProvider);
      final pace = route.durationSeconds / route.distanceMeters;
      expect(
        state.remainingDurationSeconds,
        closeTo(state.remainingDistanceMeters! * pace, 0.01),
      );
    });

    test('remaining distance never increases while progressing forward '
        'along the route', () {
      container
          .read(navigationProvider.notifier)
          .start(route: route, destination: destination);

      double? previous;
      for (final lat in [
        11.001,
        11.002,
        11.003,
        11.004,
        11.0045,
        11.005,
        11.006,
        11.007,
        11.008,
        11.009,
      ]) {
        fakeLocation.emit(LocationAvailable(_fixAt(lat, 78.000)));
        final remaining = container
            .read(navigationProvider)
            .remainingDistanceMeters!;
        if (previous != null) {
          expect(remaining, lessThanOrEqualTo(previous + 0.01), reason: '$lat');
        }
        previous = remaining;
      }
    });
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
