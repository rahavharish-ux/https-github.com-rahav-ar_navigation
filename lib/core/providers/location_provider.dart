import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meta/meta.dart';

import '../../models/location_model.dart';
import '../../services/location_service.dart';
import '../utils/location_filter.dart';
import '../utils/position_smoothing.dart';
import '../utils/speed_bucket.dart';

sealed class LocationState {
  const LocationState();
}

/// Nothing requested yet.
class LocationInitial extends LocationState {
  const LocationInitial();
}

/// Checking service/permission status, or waiting on the first fix.
class LocationRequesting extends LocationState {
  const LocationRequesting({this.weakSignal = false});

  /// True once real raw fixes are arriving but keep failing the accuracy
  /// filter (Phase 12) — a genuine "weak GPS signal" signal, not a guess
  /// from elapsed time. Deliberately *not* driven by "no update in N
  /// seconds": `LocationService.positionStream` only emits on real
  /// movement past its distance filter, so silence alone is ambiguous
  /// (could mean weak signal, or could just mean the device hasn't moved)
  /// — see KNOWN_LIMITATIONS.md for why this is a deliberate, narrower
  /// signal than a full "GPS lost" detector.
  final bool weakSignal;
}

class LocationAvailable extends LocationState {
  /// [smoothedLocation] defaults to [location] when omitted, so existing
  /// call sites (and tests) that only care about a raw fix don't need to
  /// know about smoothing. `LocationNotifier` always supplies a real
  /// smoothed value (Phase 8).
  const LocationAvailable(
    this.location, {
    AppLocation? smoothedLocation,
    this.weakSignal = false,
  }) : smoothedLocation = smoothedLocation ?? location;

  /// The raw, accepted GPS fix — ground truth, shown as-is on the
  /// diagnostics screen and the home screen's GPS badge.
  final AppLocation location;

  /// [location] passed through exponential smoothing (Phase 8) so the map
  /// marker and navigation math don't visibly jitter within GPS accuracy
  /// noise. Prefer this for anything drawn on the map or fed into
  /// turn-by-turn calculations.
  final AppLocation smoothedLocation;

  /// True once real raw fixes are arriving but keep failing the accuracy
  /// filter (Phase 12) since this fix was accepted — [location] is real
  /// and unchanged, but may no longer reflect where the device actually
  /// is. See [LocationRequesting.weakSignal] for why this is driven by
  /// rejected-fix streaks, not elapsed silence.
  final bool weakSignal;
}

class LocationServiceDisabled extends LocationState {
  const LocationServiceDisabled();
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied({required this.forever});

  final bool forever;
}

/// Holds the raw error for the diagnostics screen only — normal UI must
/// never surface [message] directly to the user.
class LocationError extends LocationState {
  const LocationError(this.message);

  final String message;
}

final locationProvider = NotifierProvider<LocationNotifier, LocationState>(
  LocationNotifier.new,
);

class LocationNotifier extends Notifier<LocationState> {
  /// Consecutive rejected (too-inaccurate) raw fixes before flagging
  /// [LocationState.weakSignal] — real fixes, just not accurate enough.
  /// Deliberately several in a row rather than one: a single bad fix could
  /// be ordinary GPS jitter, not a genuine signal problem.
  static const _weakSignalRejectedStreak = 3;

  late final LocationService _service;
  StreamSubscription<Position>? _subscription;
  AppLocation? _lastAccepted;
  AppLocation? _lastSmoothed;
  SpeedBucket _speedBucket = SpeedBucket.stationary;
  int _consecutiveRejected = 0;

  @override
  LocationState build() {
    _service = createService();
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return const LocationInitial();
  }

  /// Overridden in tests to inject a fake `LocationService` (Phase 15) —
  /// lets a test verify the real cancel/resubscribe-on-speed-bucket-change
  /// wiring (previously untested; see KNOWN_LIMITATIONS.md) without a real
  /// geolocator platform channel.
  @visibleForTesting
  LocationService createService() => const LocationService();

  Future<void> requestAndStart() async {
    if (state is LocationRequesting) return;
    state = const LocationRequesting();

    try {
      final serviceEnabled = await _service.isServiceEnabled();
      if (!serviceEnabled) {
        state = const LocationServiceDisabled();
        return;
      }

      var permission = await _service.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await _service.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        state = const LocationPermissionDenied(forever: false);
        return;
      }
      if (permission == LocationPermission.deniedForever) {
        state = const LocationPermissionDenied(forever: true);
        return;
      }

      _lastAccepted = null;
      _lastSmoothed = null;
      _speedBucket = SpeedBucket.stationary;
      _consecutiveRejected = 0;
      _subscribe(distanceFilterMetersForSpeedBucket(_speedBucket));
    } catch (error) {
      state = LocationError(error.toString());
    }
  }

  /// Cancels any existing subscription and starts a new one at
  /// [distanceFilterMeters]. Used both for the initial subscription and to
  /// react to a speed-bucket change (Phase 8: speed-adaptive sampling) —
  /// geolocator has no way to change an in-flight stream's settings, so a
  /// bucket change means cancel-and-resubscribe.
  void _subscribe(double distanceFilterMeters) {
    _subscription?.cancel();
    _subscription = _service
        .positionStream(distanceFilterMeters: distanceFilterMeters)
        .listen(
          _onPosition,
          onError: (Object error) {
            state = LocationError(error.toString());
          },
        );
  }

  void _onPosition(Position position) {
    final candidate = AppLocation.fromPosition(position);
    if (!shouldAcceptLocationUpdate(
      candidate: candidate,
      previous: _lastAccepted,
    )) {
      _consecutiveRejected++;
      if (_consecutiveRejected >= _weakSignalRejectedStreak) {
        _flagWeakSignal();
      }
      return;
    }
    _consecutiveRejected = 0;
    _lastAccepted = candidate;

    final smoothed = smoothLocation(
      raw: candidate,
      previousSmoothed: _lastSmoothed,
    );
    _lastSmoothed = smoothed;
    state = LocationAvailable(candidate, smoothedLocation: smoothed);

    final nextBucket = speedBucketFor(
      smoothed.speedMetersPerSecond,
      _speedBucket,
    );
    if (nextBucket != _speedBucket) {
      _speedBucket = nextBucket;
      _subscribe(distanceFilterMetersForSpeedBucket(_speedBucket));
    }
  }

  void _flagWeakSignal() => state = withWeakSignalFlagged(state);

  Future<void> openAppSettings() => _service.openAppSettings();

  Future<void> openLocationSettings() => _service.openLocationSettings();
}

/// Marks [state] as weak-signal in place, leaving any real fix already
/// shown untouched — a real, honest degradation signal (see
/// [LocationState.weakSignal]), not a fabricated position. No-ops for
/// states this doesn't apply to (e.g. already showing a permission/
/// service error). Pulled out of [LocationNotifier] as a pure function so
/// it's unit-testable without a live stream — same pattern
/// `compass_provider.dart`'s `compassStateFromEvent` and
/// `motion_sensor_provider.dart`'s `mergeMotionSensorReading` used.
LocationState withWeakSignalFlagged(LocationState state) => switch (state) {
  LocationRequesting() => const LocationRequesting(weakSignal: true),
  LocationAvailable(:final location, :final smoothedLocation) =>
    LocationAvailable(
      location,
      smoothedLocation: smoothedLocation,
      weakSignal: true,
    ),
  LocationInitial() ||
  LocationServiceDisabled() ||
  LocationPermissionDenied() ||
  LocationError() => state,
};
