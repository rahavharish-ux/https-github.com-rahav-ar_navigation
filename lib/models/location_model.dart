import 'package:geolocator/geolocator.dart';

/// App-level location reading, decoupled from geolocator's [Position] so
/// the rest of the app doesn't depend on a specific location package.
class AppLocation {
  const AppLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.speedMetersPerSecond,
    required this.headingDegrees,
    required this.timestamp,
  });

  factory AppLocation.fromPosition(Position position) => AppLocation(
    latitude: position.latitude,
    longitude: position.longitude,
    accuracyMeters: position.accuracy,
    speedMetersPerSecond: position.speed,
    headingDegrees: position.heading,
    timestamp: position.timestamp,
  );

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final double speedMetersPerSecond;
  final double headingDegrees;
  final DateTime timestamp;

  double get speedKmh => speedMetersPerSecond * 3.6;

  /// Consumer GPS accuracy is realistically a handful of meters at best —
  /// this rejects readings worse than [maxAccuracyMeters] so obviously bad
  /// fixes never reach the UI. See KNOWN_LIMITATIONS.md.
  bool isAccurateEnough({double maxAccuracyMeters = 50}) =>
      accuracyMeters <= maxAccuracyMeters;
}
