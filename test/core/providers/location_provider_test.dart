import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tn_ar_navigation/core/providers/location_provider.dart';
import 'package:tn_ar_navigation/core/utils/speed_bucket.dart';
import 'package:tn_ar_navigation/models/location_model.dart';
import 'package:tn_ar_navigation/services/location_service.dart';

AppLocation _location() => AppLocation(
  latitude: 11.0,
  longitude: 78.0,
  accuracyMeters: 10,
  speedMetersPerSecond: 0,
  headingDegrees: 0,
  timestamp: DateTime(2026, 1, 1),
);

Position _position({
  required double lat,
  required double lng,
  double accuracy = 5,
  double speed = 0,
}) {
  return Position(
    latitude: lat,
    longitude: lng,
    timestamp: DateTime(2026, 1, 1),
    accuracy: accuracy,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: speed,
    speedAccuracy: 0,
  );
}

/// A broadcast stream so `LocationNotifier._subscribe`'s real
/// cancel-then-resubscribe (on a speed-bucket change) can listen to a new
/// subscription after cancelling the previous one -- a plain
/// single-subscription `Stream` only allows being listened to once, ever.
/// Records every `distanceFilterMeters` value `positionStream` was called
/// with, so a test can confirm a real resubscription happened.
class _RecordingLocationService extends LocationService {
  final _controller = StreamController<Position>.broadcast();
  final List<double> distanceFilterCalls = [];

  void add(Position position) => _controller.add(position);

  @override
  Future<bool> isServiceEnabled() async => true;

  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.whileInUse;

  @override
  Stream<Position> positionStream({double distanceFilterMeters = 5}) {
    distanceFilterCalls.add(distanceFilterMeters);
    return _controller.stream;
  }
}

class _TestableLocationNotifier extends LocationNotifier {
  _TestableLocationNotifier(this._service);

  final LocationService _service;

  @override
  LocationService createService() => _service;
}

void main() {
  test('a speed-bucket change (stationary -> driving) cancels and '
      'resubscribes the position stream with a wider distance filter '
      '(Phase 15: previously untested wiring -- only the pure '
      'speedBucketFor/distanceFilterMetersForSpeedBucket functions were '
      'tested; see KNOWN_LIMITATIONS.md)', () async {
    final service = _RecordingLocationService();
    final container = ProviderContainer(
      overrides: [
        locationProvider.overrideWith(() => _TestableLocationNotifier(service)),
      ],
    );
    addTearDown(container.dispose);

    await container.read(locationProvider.notifier).requestAndStart();
    expect(service.distanceFilterCalls, [
      distanceFilterMetersForSpeedBucket(SpeedBucket.stationary),
    ]);

    // A real stationary-speed fix -- no bucket change, no resubscribe.
    service.add(_position(lat: 11.000, lng: 78.000, speed: 0));
    await pumpEventQueue();
    expect(service.distanceFilterCalls.length, 1);

    // A real driving-speed fix, moved enough to pass the accuracy/
    // movement filter. speed: 20 (well above the 4.0 m/s driving-enter
    // threshold) because Phase 8's exponential smoothing (alpha 0.35)
    // blends this raw speed toward the previous smoothed speed (0, from
    // the stationary fix above) before the speed-bucket decision reads
    // it -- smoothed ~= 0.35 * raw, so a raw speed only just above the
    // threshold would smooth back down below it.
    service.add(_position(lat: 11.001, lng: 78.000, speed: 20));
    await pumpEventQueue();

    expect(service.distanceFilterCalls, [
      distanceFilterMetersForSpeedBucket(SpeedBucket.stationary),
      distanceFilterMetersForSpeedBucket(SpeedBucket.driving),
    ]);
  });

  group('withWeakSignalFlagged', () {
    test('LocationRequesting gains weakSignal: true', () {
      final result = withWeakSignalFlagged(const LocationRequesting());

      expect(result, isA<LocationRequesting>());
      expect((result as LocationRequesting).weakSignal, isTrue);
    });

    test(
      'LocationAvailable gains weakSignal: true, real fix data untouched',
      () {
        final location = _location();
        final result = withWeakSignalFlagged(LocationAvailable(location));

        expect(result, isA<LocationAvailable>());
        final available = result as LocationAvailable;
        expect(available.weakSignal, isTrue);
        expect(available.location, same(location));
        expect(available.smoothedLocation, same(location));
      },
    );

    test('LocationAvailable preserves a distinct smoothedLocation', () {
      final raw = _location();
      final smoothed = _location();
      final result = withWeakSignalFlagged(
        LocationAvailable(raw, smoothedLocation: smoothed),
      );

      final available = result as LocationAvailable;
      expect(available.location, same(raw));
      expect(available.smoothedLocation, same(smoothed));
    });

    test('states with no real fix in progress (Initial/ServiceDisabled/'
        'PermissionDenied/Error) are returned unchanged', () {
      expect(
        withWeakSignalFlagged(const LocationInitial()),
        isA<LocationInitial>(),
      );
      expect(
        withWeakSignalFlagged(const LocationServiceDisabled()),
        isA<LocationServiceDisabled>(),
      );
      expect(
        withWeakSignalFlagged(const LocationPermissionDenied(forever: true)),
        isA<LocationPermissionDenied>(),
      );
      expect(
        withWeakSignalFlagged(const LocationError('offline')),
        isA<LocationError>(),
      );
    });
  });
}
