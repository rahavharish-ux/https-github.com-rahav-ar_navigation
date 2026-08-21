import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/location_filter.dart';
import 'package:tn_ar_navigation/models/location_model.dart';

AppLocation _location({
  double lat = 11.0168,
  double lng = 76.9558,
  double accuracy = 10,
}) {
  return AppLocation(
    latitude: lat,
    longitude: lng,
    accuracyMeters: accuracy,
    speedMetersPerSecond: 0,
    headingDegrees: 0,
    timestamp: DateTime(2026, 1, 1),
  );
}

void main() {
  test('accepts the first reading if accurate enough', () {
    final candidate = _location(accuracy: 15);

    expect(
      shouldAcceptLocationUpdate(candidate: candidate, previous: null),
      isTrue,
    );
  });

  test('rejects the first reading if too inaccurate', () {
    final candidate = _location(accuracy: 200);

    expect(
      shouldAcceptLocationUpdate(candidate: candidate, previous: null),
      isFalse,
    );
  });

  test('rejects a low-accuracy candidate even with a previous reading', () {
    final previous = _location(accuracy: 10);
    final candidate = _location(lat: 11.1, accuracy: 200);

    expect(
      shouldAcceptLocationUpdate(candidate: candidate, previous: previous),
      isFalse,
    );
  });

  test(
    'rejects a tiny movement that is not more accurate than the previous fix',
    () {
      final previous = _location(accuracy: 8);
      // ~1m north, below the default 2m movement threshold.
      final candidate = _location(lat: 11.0168 + 0.000009, accuracy: 8);

      expect(
        shouldAcceptLocationUpdate(candidate: candidate, previous: previous),
        isFalse,
      );
    },
  );

  test('accepts a genuine movement past the threshold', () {
    final previous = _location(accuracy: 8);
    // ~100m north.
    final candidate = _location(lat: 11.0177, accuracy: 8);

    expect(
      shouldAcceptLocationUpdate(candidate: candidate, previous: previous),
      isTrue,
    );
  });

  test('accepts a tiny movement if the new fix is more accurate', () {
    final previous = _location(accuracy: 30);
    final candidate = _location(lat: 11.0168 + 0.000009, accuracy: 5);

    expect(
      shouldAcceptLocationUpdate(candidate: candidate, previous: previous),
      isTrue,
    );
  });
}
