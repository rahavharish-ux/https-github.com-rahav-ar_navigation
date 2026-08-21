import 'package:flutter/material.dart';

/// Maps a real OSRM maneuver type/modifier (see
/// `models/navigation_instruction.dart`) to a Material icon. Kept
/// separate from the model so the model layer stays free of Flutter
/// dependencies, matching this project's other models.
class ManeuverIcon extends StatelessWidget {
  const ManeuverIcon({
    super.key,
    required this.type,
    required this.modifier,
    this.size = 32,
    this.color,
  });

  final String type;
  final String? modifier;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Icon(_iconFor(type, modifier), size: size, color: color);
  }

  static IconData _iconFor(String type, String? modifier) {
    switch (type) {
      case 'depart':
        return Icons.navigation_outlined;
      case 'arrive':
        return Icons.flag_outlined;
      case 'roundabout':
      case 'rotary':
      case 'roundabout turn':
      case 'exit roundabout':
      case 'exit rotary':
        return Icons.roundabout_left_outlined;
      case 'merge':
      case 'on ramp':
      case 'off ramp':
      case 'fork':
        return Icons.merge_outlined;
      case 'end of road':
      case 'turn':
        return _turnIconFor(modifier);
      case 'continue':
      case 'new name':
      case 'notification':
        return Icons.straight_outlined;
      default:
        return Icons.straight_outlined;
    }
  }

  static IconData _turnIconFor(String? modifier) {
    switch (modifier) {
      case 'uturn':
        return Icons.u_turn_left_outlined;
      case 'sharp right':
      case 'right':
        return Icons.turn_right_outlined;
      case 'slight right':
        return Icons.turn_slight_right_outlined;
      case 'slight left':
        return Icons.turn_slight_left_outlined;
      case 'left':
      case 'sharp left':
        return Icons.turn_left_outlined;
      case 'straight':
      default:
        return Icons.straight_outlined;
    }
  }
}
