import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/position_smoothing.dart';
import 'package:tn_ar_navigation/models/location_model.dart';

AppLocation _location({
  double lat = 11.0,
  double lng = 78.0,
  double accuracy = 10,
  double speed = 0,
  double heading = 0,
}) {
  return AppLocation(
    latitude: lat,
    longitude: lng,
    accuracyMeters: accuracy,
    speedMetersPerSecond: speed,
    headingDegrees: heading,
    timestamp: DateTime(2026, 1, 1),
  );
}

void main() {
  group('smoothLocation', () {
    test('with no previous smoothed value, passes the raw fix through', () {
      final raw = _location(lat: 11.5, lng: 78.5);

      final result = smoothLocation(raw: raw, previousSmoothed: null);

      expect(result, same(raw));
    });

    test('blends toward the raw fix rather than jumping straight to it', () {
      final previous = _location(lat: 11.000, lng: 78.000);
      final raw = _location(lat: 11.001, lng: 78.000);

      final result = smoothLocation(raw: raw, previousSmoothed: previous);

      expect(result.latitude, greaterThan(previous.latitude));
      expect(result.latitude, lessThan(raw.latitude));
    });

    test('always passes through the raw accuracy and timestamp unchanged', () {
      final previous = _location(accuracy: 5, speed: 1);
      final raw = _location(accuracy: 40, speed: 3);

      final result = smoothLocation(raw: raw, previousSmoothed: previous);

      expect(result.accuracyMeters, raw.accuracyMeters);
      expect(result.timestamp, raw.timestamp);
    });

    test('smooths speed toward the raw value without matching it exactly', () {
      final previous = _location(speed: 0);
      final raw = _location(speed: 10);

      final result = smoothLocation(raw: raw, previousSmoothed: previous);

      expect(result.speedMetersPerSecond, greaterThan(0));
      expect(result.speedMetersPerSecond, lessThan(10));
    });

    test('a real, principled improvement (Phase 16): a low-accuracy fix is '
        'trusted less (blended less toward it) than a high-accuracy fix '
        'given the identical raw movement -- accuracy-weighted smoothing, '
        'not a fixed alpha regardless of fix quality', () {
      final previous = _location(lat: 11.000);
      final accurateRaw = _location(lat: 11.001, accuracy: 5);
      final inaccurateRaw = _location(lat: 11.001, accuracy: 50);

      final accurateResult = smoothLocation(
        raw: accurateRaw,
        previousSmoothed: previous,
      );
      final inaccurateResult = smoothLocation(
        raw: inaccurateRaw,
        previousSmoothed: previous,
      );

      // Both move toward the raw fix, but the accurate one moves further.
      expect(accurateResult.latitude, greaterThan(inaccurateResult.latitude));
      expect(inaccurateResult.latitude, greaterThan(previous.latitude));
      expect(accurateResult.latitude, lessThan(accurateRaw.latitude));
    });

    test('accuracy weighting is clamped -- an unusually good or bad accuracy '
        "value doesn't extrapolate past the real tuned alpha range", () {
      final previous = _location(lat: 11.000);
      final veryAccurate = _location(lat: 11.001, accuracy: 0.5);
      final veryInaccurate = _location(lat: 11.001, accuracy: 500);

      final accurateResult = smoothLocation(
        raw: veryAccurate,
        previousSmoothed: previous,
      );
      final inaccurateResult = smoothLocation(
        raw: veryInaccurate,
        previousSmoothed: previous,
      );

      // Still real blending in both directions, not 0% or 100%.
      expect(accurateResult.latitude, greaterThan(previous.latitude));
      expect(accurateResult.latitude, lessThan(veryAccurate.latitude));
      expect(inaccurateResult.latitude, greaterThan(previous.latitude));
      expect(inaccurateResult.latitude, lessThan(veryInaccurate.latitude));
    });
  });

  group('smoothHeadingDegrees', () {
    test('blends two nearby headings without wraparound involved', () {
      final result = smoothHeadingDegrees(0, 90, alpha: 0.5);
      expect(result, closeTo(45, 0.5));
    });

    test(
      'correctly averages across the 0/360 boundary instead of through 180',
      () {
        final result = smoothHeadingDegrees(350, 10, alpha: 0.5);
        // The real midpoint of 350deg and 10deg is 0deg (=360deg), not
        // 180deg, which a naive linear average would produce.
        final distanceFromNorth = result <= 180 ? result : 360 - result;
        expect(distanceFromNorth, lessThan(5));
      },
    );

    test('a low alpha stays closer to the previous heading', () {
      final result = smoothHeadingDegrees(0, 100, alpha: 0.1);
      expect(result, lessThan(50));
    });

    test('result is always within the 0-360 range', () {
      final result = smoothHeadingDegrees(10, 350, alpha: 0.5);
      expect(result, inInclusiveRange(0, 360));
    });
  });
}
