import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../services/motion_sensor_service.dart';

sealed class MotionSensorState {
  const MotionSensorState();
}

/// Nothing requested yet.
class MotionSensorInitial extends MotionSensorState {
  const MotionSensorInitial();
}

/// Latest accelerometer/gyroscope reading, each independently nullable:
/// `sensors_plus` exposes no "is this sensor present" check (unlike
/// `flutter_compass`'s nullable `heading`) — a genuinely absent sensor's
/// stream just never emits, the same as one that simply hasn't produced
/// its first reading yet. Rather than guess at a timeout-based
/// "unavailable" state, this stays honestly "still waiting" for whichever
/// field is null; see KNOWN_LIMITATIONS.md.
class MotionSensorReading extends MotionSensorState {
  const MotionSensorReading({this.accelerometer, this.gyroscope});

  final AccelerometerEvent? accelerometer;
  final GyroscopeEvent? gyroscope;
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, matching the pattern in `location_provider.dart`.
class MotionSensorError extends MotionSensorState {
  const MotionSensorError(this.message);

  final String message;
}

final motionSensorProvider =
    NotifierProvider<MotionSensorNotifier, MotionSensorState>(
      MotionSensorNotifier.new,
    );

/// Real accelerometer + gyroscope streams (Phase 11), diagnostics-only:
/// there's no dead-reckoning/fusion consumer of this data yet — that's
/// Phase 12 (Hybrid localization), which will decide the real fusion
/// approach once it has a concrete reason to. Deliberately not
/// auto-started, same battery reasoning as `CompassNotifier`.
class MotionSensorNotifier extends Notifier<MotionSensorState> {
  late final MotionSensorService _service;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroscopeSubscription;

  @override
  MotionSensorState build() {
    _service = MotionSensorService();
    ref.onDispose(() {
      _accelerometerSubscription?.cancel();
      _gyroscopeSubscription?.cancel();
    });
    return const MotionSensorInitial();
  }

  void start() {
    if (_accelerometerSubscription != null || _gyroscopeSubscription != null) {
      return;
    }

    _accelerometerSubscription = _service.accelerometerEvents.listen(
      (event) => _updateReading(accelerometer: event),
      onError: (Object error) => state = MotionSensorError(error.toString()),
    );
    _gyroscopeSubscription = _service.gyroscopeEvents.listen(
      (event) => _updateReading(gyroscope: event),
      onError: (Object error) => state = MotionSensorError(error.toString()),
    );
  }

  void _updateReading({
    AccelerometerEvent? accelerometer,
    GyroscopeEvent? gyroscope,
  }) {
    state = mergeMotionSensorReading(
      state,
      accelerometer: accelerometer,
      gyroscope: gyroscope,
    );
  }

  void stop() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _gyroscopeSubscription?.cancel();
    _gyroscopeSubscription = null;
    state = const MotionSensorInitial();
  }
}

/// Pure merge of a new accelerometer/gyroscope event into [previous],
/// keeping whichever field wasn't updated this call — pulled out of
/// [MotionSensorNotifier] so it's unit-testable without live sensor
/// streams, same pattern as `compass_provider.dart`'s
/// `compassStateFromEvent`.
MotionSensorReading mergeMotionSensorReading(
  MotionSensorState previous, {
  AccelerometerEvent? accelerometer,
  GyroscopeEvent? gyroscope,
}) {
  final previousReading = previous is MotionSensorReading ? previous : null;
  return MotionSensorReading(
    accelerometer: accelerometer ?? previousReading?.accelerometer,
    gyroscope: gyroscope ?? previousReading?.gyroscope,
  );
}
