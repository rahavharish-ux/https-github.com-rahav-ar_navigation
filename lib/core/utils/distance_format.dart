/// Formats a distance in meters as a short human-readable label, e.g.
/// "350 m" or "12.4 km". Shared by search results now, and by routing/ETA
/// displays once Phase 6 adds them — kept as one small utility rather
/// than duplicated per feature.
String formatDistanceMeters(double meters) {
  if (meters < 1000) return '${meters.round()} m';
  return '${(meters / 1000).toStringAsFixed(1)} km';
}
