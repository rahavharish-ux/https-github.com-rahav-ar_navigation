import 'package:latlong2/latlong.dart';

/// One real turn-by-turn maneuver, parsed from an OSRM route step. Unlike
/// [AppRoute]'s polyline, this depends directly on [LatLng] for the same
/// reason: a maneuver location has no purpose outside being matched
/// against a live GPS position or drawn on a map.
class NavigationInstruction {
  const NavigationInstruction({
    required this.text,
    required this.type,
    required this.modifier,
    required this.location,
    required this.distanceMeters,
  });

  factory NavigationInstruction.fromOsrmStep(Map<String, dynamic> step) {
    final maneuver = step['maneuver'] as Map<String, dynamic>;
    final type = maneuver['type'] as String;
    final modifier = maneuver['modifier'] as String?;
    final roadName = step['name'] as String?;
    final location = (maneuver['location'] as List<dynamic>).cast<num>();

    return NavigationInstruction(
      text: buildInstructionText(
        type: type,
        modifier: modifier,
        roadName: roadName,
      ),
      type: type,
      modifier: modifier,
      location: LatLng(location[1].toDouble(), location[0].toDouble()),
      distanceMeters: (step['distance'] as num).toDouble(),
    );
  }

  /// Real OSRM maneuver type, e.g. "turn", "depart", "arrive", "roundabout".
  final String type;

  /// Real OSRM maneuver modifier, e.g. "left", "slight right", "straight".
  final String? modifier;

  /// Human-readable instruction built from [type]/[modifier]/road name —
  /// see [buildInstructionText].
  final String text;

  final LatLng location;

  /// Length of this step, from its maneuver to the next one (or the route
  /// end, for the last step).
  final double distanceMeters;
}

/// Builds a short human instruction from OSRM's raw maneuver data. OSRM's
/// free API returns structured maneuvers (type + modifier + road name),
/// not a ready-made sentence — full instruction text is normally generated
/// client-side (e.g. by OSRM's own `osrm-text-instructions` library). This
/// is a deliberately small, real subset of that logic: covers the maneuver
/// types OSRM actually returns for driving routes, with an honest fallback
/// for anything unrecognized, rather than a hardcoded phrase per route.
String buildInstructionText({
  required String type,
  required String? modifier,
  required String? roadName,
}) {
  final onRoad = (roadName != null && roadName.trim().isNotEmpty)
      ? ' onto ${roadName.trim()}'
      : '';
  final direction = _directionPhrase(modifier);
  String withDirection(String verb) =>
      direction.isEmpty ? '$verb$onRoad' : '$verb $direction$onRoad';

  return switch (type) {
    'depart' =>
      direction.isEmpty ? 'Start driving$onRoad' : withDirection('Head'),
    'arrive' => 'You have arrived at your destination',
    'roundabout' ||
    'rotary' ||
    'roundabout turn' => 'Enter the roundabout$onRoad',
    'exit roundabout' || 'exit rotary' => 'Exit the roundabout$onRoad',
    'merge' => withDirection('Merge'),
    'on ramp' => withDirection('Take the ramp'),
    'off ramp' => withDirection('Take the exit'),
    'fork' => withDirection('Keep'),
    'end of road' => withDirection('Turn'),
    'continue' || 'new name' || 'notification' => 'Continue$onRoad',
    'turn' => withDirection('Turn'),
    _ => withDirection('Continue'),
  };
}

String _directionPhrase(String? modifier) => switch (modifier) {
  'uturn' => 'and make a U-turn',
  'sharp right' => 'sharp right',
  'right' => 'right',
  'slight right' => 'slightly right',
  'slight left' => 'slightly left',
  'left' => 'left',
  'sharp left' => 'sharp left',
  'straight' || null => '',
  _ => '',
};
