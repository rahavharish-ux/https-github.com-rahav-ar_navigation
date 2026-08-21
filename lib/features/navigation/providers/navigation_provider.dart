import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/map/location_latlng.dart';
import '../../../core/providers/location_provider.dart';
import '../../../core/utils/geo_math.dart';
import '../../../models/navigation_instruction.dart';
import '../../../models/route_model.dart';
import '../../../services/routing_service.dart';

enum NavigationStatus {
  /// No active session.
  idle,
  navigating,

  /// Within [NavigationNotifier.approachingThresholdMeters] of the next
  /// maneuver.
  approachingTurn,

  /// Within [NavigationNotifier.turningThresholdMeters] of the next
  /// maneuver.
  turning,

  /// More than [NavigationNotifier.offRouteThresholdMeters] from the route
  /// polyline; a recalculation will be attempted on the next GPS update.
  offRoute,

  /// Still within [NavigationNotifier.offRouteThresholdMeters] of the
  /// polyline (so not [offRoute]), but real movement over the last
  /// several fixes points away from the next maneuver rather than toward
  /// it — e.g. a U-turn on a divided road, still geometrically close to
  /// the line. A recalculation is attempted on the next GPS update, same
  /// as [offRoute] (Phase 8: wrong-direction detection).
  wrongDirection,

  /// A recalculation request is in flight.
  recalculating,
  arrived,
  paused,
}

/// Turn-by-turn navigation state (Phase 7). Deliberately does *not* include
/// a `PREPARING_ROUTE`/`ROUTE_READY` phase like ARCHITECTURE.md's original
/// sketch — `routeProvider` already owns that concern for the route
/// preview screen, and [start] only ever begins from an already-computed
/// [AppRoute] to avoid two providers modeling the same fetch. Also
/// deliberately omits heading, AR status, and permission status fields
/// from that same sketch — those belong to sensor fusion (Phase 11) and AR
/// (Phase 10) and would be unpopulated/fake here.
class NavigationState {
  const NavigationState({
    this.status = NavigationStatus.idle,
    this.route,
    this.destination,
    this.currentLocation,
    this.instructionIndex = 0,
    this.distanceToNextManeuverMeters,
    this.remainingDistanceMeters,
    this.remainingDurationSeconds,
    this.errorMessage,
  });

  final NavigationStatus status;
  final AppRoute? route;
  final LatLng? destination;
  final LatLng? currentLocation;
  final int instructionIndex;
  final double? distanceToNextManeuverMeters;
  final double? remainingDistanceMeters;
  final double? remainingDurationSeconds;

  /// Diagnostics-only detail from the most recent failed recalculation —
  /// raw errors are never shown to normal users, matching
  /// `location_provider.dart`. A failure keeps [status] at [offRoute]
  /// rather than a separate terminal error state, since the next GPS
  /// update naturally retries the recalculation — self-healing rather
  /// than requiring a manual retry action.
  final String? errorMessage;

  NavigationInstruction? get currentInstruction {
    final instructions = route?.instructions;
    if (instructions == null || instructionIndex >= instructions.length) {
      return null;
    }
    return instructions[instructionIndex];
  }

  bool get isActive =>
      status != NavigationStatus.idle && status != NavigationStatus.arrived;

  NavigationState copyWith({
    NavigationStatus? status,
    AppRoute? route,
    LatLng? destination,
    LatLng? currentLocation,
    int? instructionIndex,
    double? distanceToNextManeuverMeters,
    double? remainingDistanceMeters,
    double? remainingDurationSeconds,
    String? errorMessage,

    /// Explicitly resets [NavigationState.errorMessage] to null — plain
    /// `errorMessage: null` can't do this, since every other field here
    /// falls back to its previous value when omitted.
    bool clearError = false,
  }) {
    return NavigationState(
      status: status ?? this.status,
      route: route ?? this.route,
      destination: destination ?? this.destination,
      currentLocation: currentLocation ?? this.currentLocation,
      instructionIndex: instructionIndex ?? this.instructionIndex,
      distanceToNextManeuverMeters:
          distanceToNextManeuverMeters ?? this.distanceToNextManeuverMeters,
      remainingDistanceMeters:
          remainingDistanceMeters ?? this.remainingDistanceMeters,
      remainingDurationSeconds:
          remainingDurationSeconds ?? this.remainingDurationSeconds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final navigationProvider =
    NotifierProvider<NavigationNotifier, NavigationState>(
      NavigationNotifier.new,
    );

/// Drives an active turn-by-turn session from the same live GPS stream
/// `locationProvider` already exposes — no separate tracking mechanism.
class NavigationNotifier extends Notifier<NavigationState> {
  /// Off the route polyline by more than this is treated as off-route.
  static const offRouteThresholdMeters = 40.0;

  /// Within this of a maneuver, the status becomes "turning".
  static const turningThresholdMeters = 25.0;

  /// Within this of a maneuver, the status becomes "approaching".
  static const approachingThresholdMeters = 150.0;

  /// Within this of the destination, navigation is considered arrived.
  static const arrivalThresholdMeters = 25.0;

  /// Two consecutive GPS fixes must be at least this far apart before
  /// their movement bearing is trusted for wrong-direction detection —
  /// below this, the "direction of travel" implied by two nearly-
  /// identical points is GPS noise, not real movement.
  static const minMovementForBearingMeters = 8.0;

  /// Movement bearing vs. the bearing to the next maneuver must differ by
  /// more than this to count as a wrong-direction signal — a wide margin
  /// so ordinary route curvature (the road bending, not the driver
  /// reversing) never trips it.
  static const wrongDirectionThresholdDegrees = 120.0;

  /// The wrong-direction signal must hold for this many consecutive
  /// qualifying GPS updates before triggering a recalculation — a single
  /// noisy fix should never yank the driver into an unnecessary reroute.
  static const wrongDirectionConfirmationCount = 2;

  late final RoutingService _service;
  int _wrongDirectionStreak = 0;

  @override
  NavigationState build() {
    _service = RoutingService();
    ref.onDispose(_service.dispose);

    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next is LocationAvailable) {
        _onLocationUpdate(next.smoothedLocation.toLatLng());
      }
    });

    return const NavigationState();
  }

  void start({required AppRoute route, required LatLng destination}) {
    _wrongDirectionStreak = 0;
    state = NavigationState(
      status: NavigationStatus.navigating,
      route: route,
      destination: destination,
      instructionIndex: _initialInstructionIndex(route.instructions),
    );

    final locationState = ref.read(locationProvider);
    if (locationState is LocationAvailable) {
      _onLocationUpdate(locationState.smoothedLocation.toLatLng());
    }
  }

  /// OSRM's first step is always a "depart" maneuver at the starting
  /// point itself — already behind the driver the moment navigation
  /// starts, not an upcoming turn to display. Skips straight to the real
  /// next maneuver when one exists.
  int _initialInstructionIndex(List<NavigationInstruction> instructions) =>
      (instructions.length > 1 && instructions.first.type == 'depart') ? 1 : 0;

  void pause() {
    if (!state.isActive) return;
    state = state.copyWith(status: NavigationStatus.paused);
  }

  void resume() {
    if (state.status != NavigationStatus.paused) return;
    state = state.copyWith(status: NavigationStatus.navigating);
    if (state.currentLocation != null) {
      _onLocationUpdate(state.currentLocation!);
    }
  }

  void stop() {
    _wrongDirectionStreak = 0;
    state = const NavigationState();
  }

  void _onLocationUpdate(LatLng current) {
    if (!state.isActive || state.status == NavigationStatus.paused) return;

    final route = state.route;
    final destination = state.destination;
    if (route == null || destination == null) return;

    final previousLocation = state.currentLocation;
    state = state.copyWith(currentLocation: current);

    // A recalculation fetch is in flight against the (now stale) route
    // above — don't recompute maneuver/status from it, that would race
    // with `_recalculate()`'s own state updates once it resolves.
    if (state.status == NavigationStatus.recalculating) return;

    final onRouteDistance = distanceToPolylineMeters(current, route.polyline);
    if (onRouteDistance != null && onRouteDistance > offRouteThresholdMeters) {
      _wrongDirectionStreak = 0;
      state = state.copyWith(status: NavigationStatus.offRoute);
      _recalculate();
      return;
    }

    if (_isMovingWrongDirection(
      previous: previousLocation,
      current: current,
      route: route,
    )) {
      _wrongDirectionStreak++;
      if (_wrongDirectionStreak >= wrongDirectionConfirmationCount) {
        _wrongDirectionStreak = 0;
        state = state.copyWith(status: NavigationStatus.wrongDirection);
        _recalculate();
        return;
      }
    } else {
      _wrongDirectionStreak = 0;
    }

    final distanceToDestination = haversineMeters(current, destination);
    if (distanceToDestination <= arrivalThresholdMeters) {
      state = state.copyWith(
        status: NavigationStatus.arrived,
        distanceToNextManeuverMeters: 0,
        remainingDistanceMeters: 0,
        remainingDurationSeconds: 0,
      );
      return;
    }

    var index = state.instructionIndex;
    final instructions = route.instructions;
    var distanceToManeuver = index < instructions.length
        ? haversineMeters(current, instructions[index].location)
        : distanceToDestination;

    while (index < instructions.length - 1 &&
        distanceToManeuver <= arrivalThresholdMeters) {
      index++;
      distanceToManeuver = haversineMeters(
        current,
        instructions[index].location,
      );
    }

    final remainingDistance = instructions
        .skip(index)
        .fold<double>(
          0,
          (sum, instruction) => sum + instruction.distanceMeters,
        );
    final pace = route.distanceMeters > 0
        ? route.durationSeconds / route.distanceMeters
        : 0.0;

    final status = distanceToManeuver <= turningThresholdMeters
        ? NavigationStatus.turning
        : distanceToManeuver <= approachingThresholdMeters
        ? NavigationStatus.approachingTurn
        : NavigationStatus.navigating;

    state = state.copyWith(
      status: status,
      instructionIndex: index,
      distanceToNextManeuverMeters: distanceToManeuver,
      remainingDistanceMeters: remainingDistance,
      remainingDurationSeconds: remainingDistance * pace,
    );
  }

  /// True when real movement between [previous] and [current] points
  /// away from the next maneuver rather than toward it — e.g. a U-turn
  /// on a divided road, still geometrically close enough to the polyline
  /// to not be [NavigationStatus.offRoute] by distance alone. Requires a
  /// real, non-trivial movement ([minMovementForBearingMeters]) between
  /// fixes so GPS jitter while stationary/slow never reads as "wrong
  /// direction" — two nearly-identical points imply no reliable bearing
  /// at all.
  bool _isMovingWrongDirection({
    required LatLng? previous,
    required LatLng current,
    required AppRoute route,
  }) {
    if (previous == null) return false;
    if (haversineMeters(previous, current) < minMovementForBearingMeters) {
      return false;
    }

    final instructions = route.instructions;
    final index = state.instructionIndex;
    final target = index < instructions.length
        ? instructions[index].location
        : state.destination!;

    final movementBearing = bearingDegrees(previous, current);
    final expectedBearing = bearingDegrees(current, target);
    return angleDifferenceDegrees(movementBearing, expectedBearing) >
        wrongDirectionThresholdDegrees;
  }

  Future<void> _recalculate() async {
    final current = state.currentLocation;
    final destination = state.destination;
    if (current == null || destination == null) return;

    state = state.copyWith(status: NavigationStatus.recalculating);
    try {
      final route = await _service.getDrivingRoute(
        origin: current,
        destination: destination,
      );
      state = state.copyWith(
        route: route,
        instructionIndex: _initialInstructionIndex(route.instructions),
        status: NavigationStatus.navigating,
        clearError: true,
      );
      _onLocationUpdate(current);
    } on RoutingException catch (error) {
      state = state.copyWith(
        status: NavigationStatus.offRoute,
        errorMessage: error.message,
      );
    } catch (error) {
      state = state.copyWith(
        status: NavigationStatus.offRoute,
        errorMessage: error.toString(),
      );
    }
  }
}
