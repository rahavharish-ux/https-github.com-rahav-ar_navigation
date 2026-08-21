import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/core/utils/geo_math.dart';

void main() {
  group('haversineMeters', () {
    test('is zero for the same point', () {
      const point = LatLng(11.1271, 78.6569);
      expect(haversineMeters(point, point), 0);
    });

    test('matches the known ~111.2 km per degree of latitude', () {
      const a = LatLng(0, 0);
      const b = LatLng(1, 0);
      expect(haversineMeters(a, b), closeTo(111195, 50));
    });
  });

  group('distanceToPolylineMeters', () {
    test('returns null for fewer than 2 points', () {
      expect(distanceToPolylineMeters(const LatLng(0, 0), const []), isNull);
      expect(
        distanceToPolylineMeters(const LatLng(0, 0), const [LatLng(0, 0)]),
        isNull,
      );
    });

    test('is close to zero for a point on the polyline', () {
      const polyline = [LatLng(11.0, 78.0), LatLng(11.1, 78.0)];
      final distance = distanceToPolylineMeters(
        const LatLng(11.05, 78.0),
        polyline,
      );

      expect(distance, isNotNull);
      expect(distance!, lessThan(5));
    });

    test('grows with perpendicular distance from a straight segment', () {
      const polyline = [LatLng(11.0, 78.0), LatLng(11.1, 78.0)];
      final near = distanceToPolylineMeters(
        const LatLng(11.05, 78.0005),
        polyline,
      )!;
      final far = distanceToPolylineMeters(
        const LatLng(11.05, 78.005),
        polyline,
      )!;

      expect(far, greaterThan(near));
    });

    test('uses the closest of multiple segments', () {
      const polyline = [
        LatLng(11.0, 78.0),
        LatLng(11.1, 78.0),
        LatLng(11.1, 78.1),
      ];
      final distance = distanceToPolylineMeters(
        const LatLng(11.1, 78.05),
        polyline,
      );

      expect(distance, isNotNull);
      expect(distance!, lessThan(5));
    });
  });

  group('bearingDegrees', () {
    test('due north is 0 degrees', () {
      const a = LatLng(0, 0);
      const b = LatLng(1, 0);
      expect(bearingDegrees(a, b), closeTo(0, 0.5));
    });

    test('due east is 90 degrees', () {
      const a = LatLng(0, 0);
      const b = LatLng(0, 1);
      expect(bearingDegrees(a, b), closeTo(90, 0.5));
    });

    test('due south is 180 degrees', () {
      const a = LatLng(1, 0);
      const b = LatLng(0, 0);
      expect(bearingDegrees(a, b), closeTo(180, 0.5));
    });

    test('due west is 270 degrees', () {
      const a = LatLng(0, 1);
      const b = LatLng(0, 0);
      expect(bearingDegrees(a, b), closeTo(270, 0.5));
    });
  });

  group('angleDifferenceDegrees', () {
    test('is zero for identical bearings', () {
      expect(angleDifferenceDegrees(90, 90), 0);
    });

    test('takes the short way around the 0/360 boundary', () {
      expect(angleDifferenceDegrees(350, 10), closeTo(20, 0.001));
    });

    test('caps at 180 for opposite bearings', () {
      expect(angleDifferenceDegrees(0, 180), 180);
    });

    test('is symmetric', () {
      expect(
        angleDifferenceDegrees(30, 200),
        closeTo(angleDifferenceDegrees(200, 30), 0.001),
      );
    });
  });
}
