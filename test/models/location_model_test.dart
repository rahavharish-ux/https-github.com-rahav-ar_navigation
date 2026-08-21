import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tn_ar_navigation/models/location_model.dart';

Position _position({required double accuracy, double speed = 0}) {
  return Position(
    latitude: 11.0168,
    longitude: 76.9558,
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

void main() {
  test('fromPosition maps fields correctly', () {
    final location = AppLocation.fromPosition(
      _position(accuracy: 12, speed: 5),
    );

    expect(location.latitude, 11.0168);
    expect(location.longitude, 76.9558);
    expect(location.accuracyMeters, 12);
    expect(location.speedMetersPerSecond, 5);
  });

  test('speedKmh converts m/s to km/h', () {
    final location = AppLocation.fromPosition(
      _position(accuracy: 10, speed: 10),
    );

    expect(location.speedKmh, closeTo(36, 0.001));
  });

  test('isAccurateEnough rejects low-accuracy fixes', () {
    final good = AppLocation.fromPosition(_position(accuracy: 10));
    final bad = AppLocation.fromPosition(_position(accuracy: 200));

    expect(good.isAccurateEnough(), isTrue);
    expect(bad.isAccurateEnough(), isFalse);
  });
}
