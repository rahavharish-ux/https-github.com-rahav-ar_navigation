import 'package:geolocator/geolocator.dart';

import '../../models/location_model.dart';

/// Decides whether a new GPS reading should replace the current one, so
/// the UI (and later, the map marker) doesn't jump around on every tick
/// of GPS noise. Real filter, not a placeholder: rejects low-accuracy
/// fixes, and ignores tiny movements unless the new fix is more accurate
/// than the one it would replace.
bool shouldAcceptLocationUpdate({
  required AppLocation candidate,
  required AppLocation? previous,
  double maxAccuracyMeters = 50,
  double minMovementMeters = 2,
}) {
  if (!candidate.isAccurateEnough(maxAccuracyMeters: maxAccuracyMeters)) {
    return false;
  }
  if (previous == null) {
    return true;
  }

  final movedMeters = Geolocator.distanceBetween(
    previous.latitude,
    previous.longitude,
    candidate.latitude,
    candidate.longitude,
  );

  if (movedMeters < minMovementMeters &&
      candidate.accuracyMeters >= previous.accuracyMeters) {
    return false;
  }
  return true;
}
