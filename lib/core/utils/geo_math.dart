import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

const double _earthRadiusMeters = 6371000;

/// Great-circle distance between two points, in meters. Used by turn-by-turn
/// navigation (Phase 7) for off-route detection and remaining-distance
/// math, decoupled from geolocator's `Position`-based
/// `Geolocator.distanceBetween` (which search/diagnostics already use) so
/// this pure geometry works on plain [LatLng] route points too.
double haversineMeters(LatLng a, LatLng b) {
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);
  final deltaLat = _degToRad(b.latitude - a.latitude);
  final deltaLng = _degToRad(b.longitude - a.longitude);

  final h =
      math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
      math.cos(lat1) *
          math.cos(lat2) *
          math.sin(deltaLng / 2) *
          math.sin(deltaLng / 2);
  final c = 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  return _earthRadiusMeters * c;
}

/// The shortest distance from [point] to the line segment between [a] and
/// [b], in meters. Projects [point] onto the segment in an equirectangular
/// approximation (accurate enough at the short segment lengths a route
/// polyline uses) rather than full great-circle segment math.
double distanceToSegmentMeters(LatLng point, LatLng a, LatLng b) {
  // Equirectangular projection to a local flat plane, scaled by latitude so
  // one "unit" is roughly equal in meters along both axes near this point.
  final latScale = math.cos(_degToRad(a.latitude));
  final ax = a.longitude * latScale;
  final ay = a.latitude;
  final bx = b.longitude * latScale;
  final by = b.latitude;
  final px = point.longitude * latScale;
  final py = point.latitude;

  final dx = bx - ax;
  final dy = by - ay;
  final lengthSquared = dx * dx + dy * dy;

  final LatLng nearest;
  if (lengthSquared == 0) {
    nearest = a;
  } else {
    final t = (((px - ax) * dx + (py - ay) * dy) / lengthSquared).clamp(
      0.0,
      1.0,
    );
    nearest = LatLng(ay + t * dy, (ax + t * dx) / latScale);
  }

  return haversineMeters(point, nearest);
}

/// The shortest distance from [point] to any segment of [polyline], in
/// meters — the off-route signal turn-by-turn navigation (Phase 7) checks
/// on every GPS update. Returns null for an empty/single-point polyline
/// (nothing to be off of).
double? distanceToPolylineMeters(LatLng point, List<LatLng> polyline) {
  if (polyline.length < 2) return null;

  double? closest;
  for (var i = 0; i < polyline.length - 1; i++) {
    final distance = distanceToSegmentMeters(
      point,
      polyline[i],
      polyline[i + 1],
    );
    if (closest == null || distance < closest) closest = distance;
  }
  return closest;
}

/// Compass bearing from [a] to [b], in degrees clockwise from true north
/// (0-360). Used by turn-by-turn navigation's wrong-direction detection
/// (Phase 7) to compare real movement direction against the direction the
/// route expects.
double bearingDegrees(LatLng a, LatLng b) {
  final lat1 = _degToRad(a.latitude);
  final lat2 = _degToRad(b.latitude);
  final deltaLng = _degToRad(b.longitude - a.longitude);

  final y = math.sin(deltaLng) * math.cos(lat2);
  final x =
      math.cos(lat1) * math.sin(lat2) -
      math.sin(lat1) * math.cos(lat2) * math.cos(deltaLng);

  final bearing = math.atan2(y, x) * 180 / math.pi;
  return (bearing + 360) % 360;
}

/// Smallest angle between two compass bearings, in degrees (0-180) —
/// e.g. the difference between 350° and 10° is 20°, not 340°.
double angleDifferenceDegrees(double a, double b) {
  final diff = (a - b).abs() % 360;
  return diff > 180 ? 360 - diff : diff;
}

double _degToRad(double degrees) => degrees * math.pi / 180;
