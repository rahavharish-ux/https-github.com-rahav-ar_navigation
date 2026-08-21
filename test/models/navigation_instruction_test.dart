import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/models/navigation_instruction.dart';

void main() {
  group('buildInstructionText', () {
    test('depart with no direction and a road name', () {
      expect(
        buildInstructionText(
          type: 'depart',
          modifier: 'straight',
          roadName: 'Avinashi Road',
        ),
        'Start driving onto Avinashi Road',
      );
    });

    test('depart with no road name', () {
      expect(
        buildInstructionText(type: 'depart', modifier: null, roadName: ''),
        'Start driving',
      );
    });

    test('arrive ignores road name and modifier', () {
      expect(
        buildInstructionText(
          type: 'arrive',
          modifier: 'left',
          roadName: 'Main St',
        ),
        'You have arrived at your destination',
      );
    });

    test('turn with a direction and road name', () {
      expect(
        buildInstructionText(
          type: 'turn',
          modifier: 'right',
          roadName: 'Trichy Road',
        ),
        'Turn right onto Trichy Road',
      );
    });

    test('turn with no road name', () {
      expect(
        buildInstructionText(type: 'turn', modifier: 'left', roadName: null),
        'Turn left',
      );
    });

    test('roundabout', () {
      expect(
        buildInstructionText(
          type: 'roundabout',
          modifier: null,
          roadName: 'Gandhipuram Roundabout',
        ),
        'Enter the roundabout onto Gandhipuram Roundabout',
      );
    });

    test('continue', () {
      expect(
        buildInstructionText(
          type: 'continue',
          modifier: 'straight',
          roadName: 'NH 544',
        ),
        'Continue onto NH 544',
      );
    });

    test('unrecognized type falls back honestly instead of crashing', () {
      expect(
        buildInstructionText(
          type: 'something new',
          modifier: 'right',
          roadName: null,
        ),
        'Continue right',
      );
    });
  });

  group('NavigationInstruction.fromOsrmStep', () {
    test('parses a real OSRM step', () {
      final instruction = NavigationInstruction.fromOsrmStep({
        'distance': 250.5,
        'name': 'Avinashi Road',
        'maneuver': {
          'type': 'turn',
          'modifier': 'right',
          'location': [78.6569, 11.1271],
        },
      });

      expect(instruction.type, 'turn');
      expect(instruction.modifier, 'right');
      expect(instruction.text, 'Turn right onto Avinashi Road');
      expect(instruction.distanceMeters, 250.5);
      expect(instruction.location, const LatLng(11.1271, 78.6569));
    });
  });
}
