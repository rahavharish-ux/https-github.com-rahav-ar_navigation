import 'package:sensors_plus/sensors_plus.dart';

/// Thin wrapper over `package:sensors_plus`'s accelerometer/gyroscope
/// streams, same pattern as `CompassService`. Real IMU data (Phase 11),
/// diagnostics-only for now — see `motion_sensor_provider.dart` for why
/// there's no fused consumer yet.
class MotionSensorService {
  MotionSensorService({
    Stream<AccelerometerEvent>? accelerometerEvents,
    Stream<GyroscopeEvent>? gyroscopeEvents,
  }) : _accelerometerEvents = accelerometerEvents ?? accelerometerEventStream(),
       _gyroscopeEvents = gyroscopeEvents ?? gyroscopeEventStream();

  final Stream<AccelerometerEvent> _accelerometerEvents;
  final Stream<GyroscopeEvent> _gyroscopeEvents;

  Stream<AccelerometerEvent> get accelerometerEvents => _accelerometerEvents;

  Stream<GyroscopeEvent> get gyroscopeEvents => _gyroscopeEvents;
}
