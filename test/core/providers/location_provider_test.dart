import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/location_provider.dart';
import 'package:tn_ar_navigation/models/location_model.dart';

AppLocation _location() => AppLocation(
  latitude: 11.0,
  longitude: 78.0,
  accuracyMeters: 10,
  speedMetersPerSecond: 0,
  headingDegrees: 0,
  timestamp: DateTime(2026, 1, 1),
);

void main() {
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
