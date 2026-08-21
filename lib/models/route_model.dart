import 'package:latlong2/latlong.dart';

import 'navigation_instruction.dart';

/// A calculated route between two points. Unlike [AppLocation]/[Place], a
/// route has no purpose outside being drawn on a map, so — unlike those
/// models — it depends directly on [LatLng] (the map layer's shared
/// coordinate type) instead of going through a separate bridge file.
class AppRoute {
  const AppRoute({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.polyline,
    required this.instructions,
  });

  final double distanceMeters;
  final double durationSeconds;
  final List<LatLng> polyline;

  /// Real turn-by-turn maneuvers, in order — empty only if OSRM returned
  /// none (shouldn't happen for a normal driving route). Used by
  /// turn-by-turn navigation (Phase 7).
  final List<NavigationInstruction> instructions;
}
