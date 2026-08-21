/// Decouples the app from `flutter_compass`'s `CompassEvent`, the same
/// reason `AppLocation` decouples from geolocator's `Position` — this is
/// read by both the diagnostics screen and the map (Phase 11), not just
/// one call site.
class CompassReading {
  const CompassReading({required this.headingDegrees, this.accuracyDegrees});

  /// Compass heading in degrees clockwise from magnetic north (0-360).
  final double headingDegrees;

  /// Estimated heading accuracy in degrees, when the platform reports one
  /// (iOS does; Android often doesn't, in which case this is null — never
  /// faked as a fixed number).
  final double? accuracyDegrees;
}
