import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tn_ar_navigation/core/providers/motion_sensor_provider.dart';

AccelerometerEvent _accel(double x) =>
    AccelerometerEvent(x, 0, 0, DateTime(2026, 1, 1));

GyroscopeEvent _gyro(double x) => GyroscopeEvent(x, 0, 0, DateTime(2026, 1, 1));

void main() {
  // Needed because `motionSensorProvider`'s build() eagerly constructs a
  // `MotionSensorService`, whose default streams call a real MethodChannel
  // (not a widget test, which initializes this implicitly via pumpWidget).
  TestWidgetsFlutterBinding.ensureInitialized();

  group('mergeMotionSensorReading', () {
    test('an accelerometer-only update from Initial leaves gyroscope null, '
        'not fabricated', () {
      final result = mergeMotionSensorReading(
        const MotionSensorInitial(),
        accelerometer: _accel(1),
      );

      expect(result.accelerometer, isNotNull);
      expect(result.gyroscope, isNull);
    });

    test('a gyroscope update preserves the previous accelerometer reading', () {
      final afterAccel = mergeMotionSensorReading(
        const MotionSensorInitial(),
        accelerometer: _accel(1),
      );

      final afterGyro = mergeMotionSensorReading(
        afterAccel,
        gyroscope: _gyro(2),
      );

      expect(afterGyro.accelerometer?.x, 1);
      expect(afterGyro.gyroscope?.x, 2);
    });

    test(
      'a new accelerometer reading replaces the old one, not accumulates',
      () {
        final first = mergeMotionSensorReading(
          const MotionSensorInitial(),
          accelerometer: _accel(1),
        );
        final second = mergeMotionSensorReading(
          first,
          accelerometer: _accel(2),
        );

        expect(second.accelerometer?.x, 2);
      },
    );
  });

  test('motionSensorProvider starts at MotionSensorInitial', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(motionSensorProvider), isA<MotionSensorInitial>());
  });
}
