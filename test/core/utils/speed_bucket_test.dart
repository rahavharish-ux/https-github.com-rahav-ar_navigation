import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/speed_bucket.dart';

void main() {
  group('distanceFilterMetersForSpeedBucket', () {
    test('driving uses the widest filter', () {
      expect(
        distanceFilterMetersForSpeedBucket(SpeedBucket.driving),
        greaterThan(distanceFilterMetersForSpeedBucket(SpeedBucket.walking)),
      );
    });

    test('stationary uses the tightest filter', () {
      expect(
        distanceFilterMetersForSpeedBucket(SpeedBucket.stationary),
        lessThan(distanceFilterMetersForSpeedBucket(SpeedBucket.walking)),
      );
    });
  });

  group('speedBucketFor', () {
    test('stays stationary at near-zero speed', () {
      expect(
        speedBucketFor(0.05, SpeedBucket.stationary),
        SpeedBucket.stationary,
      );
    });

    test('enters walking once past the walking-enter threshold', () {
      expect(speedBucketFor(1.0, SpeedBucket.stationary), SpeedBucket.walking);
    });

    test('enters driving once past the driving-enter threshold', () {
      expect(speedBucketFor(6.0, SpeedBucket.stationary), SpeedBucket.driving);
    });

    test('a negative (noise) speed reading is treated as zero', () {
      expect(
        speedBucketFor(-0.5, SpeedBucket.stationary),
        SpeedBucket.stationary,
      );
    });

    test('hysteresis: does not drop out of driving at a speed still above '
        'the (lower) exit threshold, even though it is below the enter '
        'threshold', () {
      expect(speedBucketFor(3.5, SpeedBucket.driving), SpeedBucket.driving);
    });

    test('drops out of driving once below the driving-exit threshold', () {
      expect(speedBucketFor(2.0, SpeedBucket.driving), SpeedBucket.walking);
    });

    test('hysteresis: does not drop out of walking at a speed still above '
        'the (lower) exit threshold', () {
      expect(speedBucketFor(0.4, SpeedBucket.walking), SpeedBucket.walking);
    });

    test(
      'drops out of walking to stationary below the walking-exit threshold',
      () {
        expect(
          speedBucketFor(0.1, SpeedBucket.walking),
          SpeedBucket.stationary,
        );
      },
    );

    test('driving can drop straight to stationary at true zero speed', () {
      expect(speedBucketFor(0.0, SpeedBucket.driving), SpeedBucket.stationary);
    });
  });
}
