import 'package:flutter_compass/flutter_compass.dart';

/// Thin wrapper over `package:flutter_compass`, same pattern as
/// `LocationService`/`CameraService`. The constructor accepts an injectable
/// stream so tests can drive real state-transition logic without a real
/// magnetometer.
class CompassService {
  CompassService({Stream<CompassEvent>? events})
    : _events = events ?? FlutterCompass.events;

  /// Null when this device has no compass sensor at all (real
  /// `flutter_compass` behavior — not every Android device reports one).
  /// On web, `flutter_compass` returns an empty stream rather than null,
  /// which still resolves correctly to [CompassUnavailable] since it never
  /// emits a reading.
  final Stream<CompassEvent>? _events;

  Stream<CompassEvent>? get events => _events;
}
