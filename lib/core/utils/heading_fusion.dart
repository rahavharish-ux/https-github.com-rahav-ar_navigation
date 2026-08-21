import 'speed_bucket.dart';

/// Which real heading source [fuseHeading] picked.
enum HeadingSource {
  /// GPS course-over-ground (`AppLocation.headingDegrees`, computed by the
  /// platform location API from real consecutive fixes).
  gps,

  /// Magnetometer compass (`CompassReading.headingDegrees`, Phase 11).
  compass,

  /// Neither source had a real value to offer.
  none,
}

class FusedHeading {
  const FusedHeading({required this.headingDegrees, required this.source});

  /// Null only when [source] is [HeadingSource.none].
  final double? headingDegrees;
  final HeadingSource source;
}

/// Picks the more reliable of two real heading sources this app already
/// has (Phase 3's GPS course, Phase 11's compass) rather than averaging or
/// blending them — a genuine blend would need real-world calibration this
/// project has no way to validate on this dev machine, so this stays a
/// simple, explainable choice instead.
///
/// GPS course-over-ground is only reliable once there's real sustained
/// movement to compute it from; a stationary or slow-moving device
/// reports a course that's mostly noise. The magnetometer has the
/// opposite problem: reliable at rest, but a moving vehicle's own metal
/// frame/electronics can distort it. So: prefer GPS course once moving at
/// [SpeedBucket.driving] speed (reusing Phase 8's already-tuned
/// threshold, not a new invented one), compass otherwise — falling back
/// to whichever source is actually available if the preferred one isn't.
FusedHeading fuseHeading({
  required double? gpsHeadingDegrees,
  required double? compassHeadingDegrees,
  required SpeedBucket speedBucket,
}) {
  final preferGps = speedBucket == SpeedBucket.driving;

  final preferred = preferGps
      ? (gpsHeadingDegrees, HeadingSource.gps)
      : (compassHeadingDegrees, HeadingSource.compass);
  if (preferred.$1 != null) {
    return FusedHeading(headingDegrees: preferred.$1, source: preferred.$2);
  }

  final fallback = preferGps
      ? (compassHeadingDegrees, HeadingSource.compass)
      : (gpsHeadingDegrees, HeadingSource.gps);
  if (fallback.$1 != null) {
    return FusedHeading(headingDegrees: fallback.$1, source: fallback.$2);
  }

  return const FusedHeading(headingDegrees: null, source: HeadingSource.none);
}
