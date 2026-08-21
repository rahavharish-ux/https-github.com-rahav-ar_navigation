/// Formats a duration in seconds as a short human-readable ETA label, e.g.
/// "8 min" or "1 h 12 min". Shared by the route preview now, and by
/// turn-by-turn navigation's remaining-time display once Phase 7 adds it.
String formatDurationSeconds(double seconds) {
  final totalMinutes = (seconds / 60).round();
  if (totalMinutes < 60) return '$totalMinutes min';
  final hours = totalMinutes ~/ 60;
  final minutes = totalMinutes % 60;
  return minutes == 0 ? '$hours h' : '$hours h $minutes min';
}
