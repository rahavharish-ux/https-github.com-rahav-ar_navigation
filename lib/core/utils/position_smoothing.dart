import 'dart:math' as math;

import '../../models/location_model.dart';

/// How strongly a new raw fix pulls the smoothed position toward it.
/// Lower = smoother/slower to react, higher = snappier/more jitter. Tuned
/// to visibly damp a few meters of GPS wobble while still keeping pace
/// with real movement between fixes ~2-15m apart. See PROJECT_STATUS.md
/// Phase 8.
const double _smoothingAlpha = 0.35;

/// Blends [raw] with [previousSmoothed] (exponential moving average) so
/// the map marker and navigation math don't visibly jitter within GPS
/// accuracy noise, while still tracking real movement — a real filter,
/// not a placeholder, same spirit as `location_filter.dart`'s accept/
/// reject check (which already ran before this).
///
/// [raw]'s [AppLocation.accuracyMeters] and [AppLocation.timestamp] are
/// always passed through unchanged: smoothing must never hide the true
/// reported accuracy or fix time, since the diagnostics screen and
/// `shouldAcceptLocationUpdate` both depend on the real accuracy value.
AppLocation smoothLocation({
  required AppLocation raw,
  required AppLocation? previousSmoothed,
}) {
  if (previousSmoothed == null) return raw;

  return AppLocation(
    latitude: _lerp(previousSmoothed.latitude, raw.latitude, _smoothingAlpha),
    longitude: _lerp(
      previousSmoothed.longitude,
      raw.longitude,
      _smoothingAlpha,
    ),
    accuracyMeters: raw.accuracyMeters,
    speedMetersPerSecond: _lerp(
      previousSmoothed.speedMetersPerSecond,
      raw.speedMetersPerSecond,
      _smoothingAlpha,
    ),
    headingDegrees: smoothHeadingDegrees(
      previousSmoothed.headingDegrees,
      raw.headingDegrees,
      alpha: _smoothingAlpha,
    ),
    timestamp: raw.timestamp,
  );
}

double _lerp(double from, double to, double alpha) =>
    from + (to - from) * alpha;

/// Exponentially-weighted circular mean of two compass headings (0-360°),
/// correctly handling the 0°/360° wraparound — a plain linear blend of
/// raw degree values would average 350° and 10° to 180° (due south)
/// instead of the real midpoint near 0°/360° (north).
double smoothHeadingDegrees(
  double previousDegrees,
  double nextDegrees, {
  double alpha = _smoothingAlpha,
}) {
  final previousRad = previousDegrees * math.pi / 180;
  final nextRad = nextDegrees * math.pi / 180;

  final x = (1 - alpha) * math.cos(previousRad) + alpha * math.cos(nextRad);
  final y = (1 - alpha) * math.sin(previousRad) + alpha * math.sin(nextRad);

  final angle = math.atan2(y, x) * 180 / math.pi;
  return (angle + 360) % 360;
}
