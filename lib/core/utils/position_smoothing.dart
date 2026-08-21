import 'dart:math' as math;

import '../../models/location_model.dart';

/// How strongly a new raw fix pulls the smoothed position toward it.
/// Lower = smoother/slower to react, higher = snappier/more jitter. Tuned
/// to visibly damp a few meters of GPS wobble while still keeping pace
/// with real movement between fixes ~2-15m apart. See PROJECT_STATUS.md
/// Phase 8. Kept as the default for [smoothHeadingDegrees]'s public
/// `alpha` parameter and as a fallback reference point; [smoothLocation]
/// itself now picks a real per-fix alpha via [_effectiveAlpha] (Phase 16)
/// instead of always using this fixed value.
const double _smoothingAlpha = 0.35;

/// [smoothLocation]'s real per-fix alpha range (Phase 16) — a principled,
/// bounded improvement over always smoothing with the same fixed
/// [_smoothingAlpha] regardless of how good the new fix actually is: a
/// low-accuracy fix is trusted less (smoothed more heavily toward the
/// previous value), a high-accuracy fix is trusted more (tracked more
/// closely). [_worstWeightedAccuracyMeters] matches
/// `location_filter.dart`'s default `maxAccuracyMeters` — the least
/// accurate fix `shouldAcceptLocationUpdate` still accepts at all.
/// Deliberately still centered near the original fixed value at a
/// middling accuracy, not a wholesale re-tuning: this is real, tested
/// logic, but — like the original fixed alpha — has never been validated
/// against a real long-duration outdoor GPS stream (no way to do that on
/// this dev machine); see KNOWN_LIMITATIONS.md.
const double _bestWeightedAccuracyMeters = 5;
const double _worstWeightedAccuracyMeters = 50;
const double _minSmoothingAlpha = 0.15;
const double _maxSmoothingAlpha = 0.5;

/// Linearly maps [accuracyMeters] to a smoothing alpha: better accuracy
/// (closer to [_bestWeightedAccuracyMeters]) yields a higher alpha
/// (trust the new fix more), worse accuracy (closer to
/// [_worstWeightedAccuracyMeters]) yields a lower alpha (lean more on the
/// previous smoothed value). Clamped at both ends so an unusually good or
/// bad accuracy value never extrapolates past the real tuned range.
double _effectiveAlpha(double accuracyMeters) {
  final clamped = accuracyMeters.clamp(
    _bestWeightedAccuracyMeters,
    _worstWeightedAccuracyMeters,
  );
  final t =
      (clamped - _bestWeightedAccuracyMeters) /
      (_worstWeightedAccuracyMeters - _bestWeightedAccuracyMeters);
  return _maxSmoothingAlpha - t * (_maxSmoothingAlpha - _minSmoothingAlpha);
}

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

  final alpha = _effectiveAlpha(raw.accuracyMeters);

  return AppLocation(
    latitude: _lerp(previousSmoothed.latitude, raw.latitude, alpha),
    longitude: _lerp(previousSmoothed.longitude, raw.longitude, alpha),
    accuracyMeters: raw.accuracyMeters,
    speedMetersPerSecond: _lerp(
      previousSmoothed.speedMetersPerSecond,
      raw.speedMetersPerSecond,
      alpha,
    ),
    headingDegrees: smoothHeadingDegrees(
      previousSmoothed.headingDegrees,
      raw.headingDegrees,
      alpha: alpha,
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
