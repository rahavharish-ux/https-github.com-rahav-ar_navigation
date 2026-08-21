import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/heading_fusion.dart';
import 'package:tn_ar_navigation/core/utils/speed_bucket.dart';

void main() {
  group('fuseHeading', () {
    test('prefers compass when stationary, even if GPS heading exists', () {
      final result = fuseHeading(
        gpsHeadingDegrees: 90,
        compassHeadingDegrees: 45,
        speedBucket: SpeedBucket.stationary,
      );

      expect(result.source, HeadingSource.compass);
      expect(result.headingDegrees, 45);
    });

    test('prefers compass when walking, even if GPS heading exists', () {
      final result = fuseHeading(
        gpsHeadingDegrees: 90,
        compassHeadingDegrees: 45,
        speedBucket: SpeedBucket.walking,
      );

      expect(result.source, HeadingSource.compass);
    });

    test('prefers GPS course when driving, even if compass exists', () {
      final result = fuseHeading(
        gpsHeadingDegrees: 90,
        compassHeadingDegrees: 45,
        speedBucket: SpeedBucket.driving,
      );

      expect(result.source, HeadingSource.gps);
      expect(result.headingDegrees, 90);
    });

    test('falls back to GPS when driving but compass is unavailable', () {
      final result = fuseHeading(
        gpsHeadingDegrees: 90,
        compassHeadingDegrees: null,
        speedBucket: SpeedBucket.driving,
      );

      expect(result.source, HeadingSource.gps);
      expect(result.headingDegrees, 90);
    });

    test(
      'falls back to compass when driving but GPS heading is unavailable',
      () {
        final result = fuseHeading(
          gpsHeadingDegrees: null,
          compassHeadingDegrees: 45,
          speedBucket: SpeedBucket.driving,
        );

        expect(result.source, HeadingSource.compass);
        expect(result.headingDegrees, 45);
      },
    );

    test('falls back to GPS when stationary but compass is unavailable', () {
      final result = fuseHeading(
        gpsHeadingDegrees: 90,
        compassHeadingDegrees: null,
        speedBucket: SpeedBucket.stationary,
      );

      expect(result.source, HeadingSource.gps);
      expect(result.headingDegrees, 90);
    });

    test('reports no source when neither is available', () {
      final result = fuseHeading(
        gpsHeadingDegrees: null,
        compassHeadingDegrees: null,
        speedBucket: SpeedBucket.driving,
      );

      expect(result.source, HeadingSource.none);
      expect(result.headingDegrees, isNull);
    });
  });
}
