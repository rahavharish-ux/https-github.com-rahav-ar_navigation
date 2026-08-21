/// Coarse GPS-sampling regime derived from current speed. Trades GPS
/// update density for battery: dense fixes while stationary/walking
/// (where a few meters of drift matters and little ground is covered
/// between fixes anyway), sparser fixes while driving (where consecutive
/// fixes close together add little navigational value but cost more
/// battery over a long trip). See PROJECT_STATUS.md Phase 8.
enum SpeedBucket { stationary, walking, driving }

/// Distance (meters) the OS-level GPS stream must see before delivering a
/// new fix, for [bucket]. Passed straight to
/// `Geolocator.getPositionStream`'s `distanceFilter`.
double distanceFilterMetersForSpeedBucket(SpeedBucket bucket) =>
    switch (bucket) {
      SpeedBucket.stationary => 3,
      SpeedBucket.walking => 5,
      SpeedBucket.driving => 15,
    };

// Enter/exit thresholds are asymmetric (hysteresis) so a speed hovering
// right at a boundary (e.g. ~0.5 m/s — a slow stroll vs. standing still
// with GPS speed noise) doesn't flip the bucket, and therefore restart
// the GPS stream, on every update.
const double _walkingEnterMps = 0.6; // ~2.2 km/h
const double _walkingExitMps = 0.3; // ~1.1 km/h
const double _drivingEnterMps = 4.0; // ~14.4 km/h
const double _drivingExitMps = 3.0; // ~10.8 km/h

/// Picks the next [SpeedBucket] for [speedMetersPerSecond], given the
/// [previous] bucket. Hysteresis (different enter/exit speeds per
/// transition) prevents rapid bucket flapping — and the GPS-stream
/// restart that comes with it — from ordinary GPS speed noise near a
/// boundary.
SpeedBucket speedBucketFor(double speedMetersPerSecond, SpeedBucket previous) {
  final speed = speedMetersPerSecond < 0 ? 0.0 : speedMetersPerSecond;

  return switch (previous) {
    SpeedBucket.driving =>
      speed >= _drivingExitMps
          ? SpeedBucket.driving
          : speed >= _walkingEnterMps
          ? SpeedBucket.walking
          : SpeedBucket.stationary,
    SpeedBucket.walking =>
      speed >= _drivingEnterMps
          ? SpeedBucket.driving
          : speed >= _walkingExitMps
          ? SpeedBucket.walking
          : SpeedBucket.stationary,
    SpeedBucket.stationary =>
      speed >= _drivingEnterMps
          ? SpeedBucket.driving
          : speed >= _walkingEnterMps
          ? SpeedBucket.walking
          : SpeedBucket.stationary,
  };
}
