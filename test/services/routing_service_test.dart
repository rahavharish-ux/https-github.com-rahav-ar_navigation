import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/services/routing_service.dart';

void main() {
  const origin = LatLng(11.1271, 78.6569);
  const destination = LatLng(11.2, 78.7);

  test('getDrivingRoute parses a successful OSRM response', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'router.project-osrm.org');
      expect(request.url.path, contains('driving'));
      expect(
        request.url.path,
        contains('${origin.longitude},${origin.latitude}'),
      );
      return http.Response(
        jsonEncode({
          'code': 'Ok',
          'routes': [
            {
              'distance': 20996.7,
              'duration': 1754.4,
              'geometry': {
                'type': 'LineString',
                'coordinates': [
                  [78.6569, 11.1271],
                  [78.66, 11.14],
                  [78.7, 11.2],
                ],
              },
              'legs': [
                {
                  'steps': [
                    {
                      'distance': 800.0,
                      'name': 'Avinashi Road',
                      'maneuver': {
                        'type': 'depart',
                        'modifier': 'straight',
                        'location': [78.6569, 11.1271],
                      },
                    },
                    {
                      'distance': 0.0,
                      'name': '',
                      'maneuver': {
                        'type': 'arrive',
                        'modifier': null,
                        'location': [78.7, 11.2],
                      },
                    },
                  ],
                },
              ],
            },
          ],
        }),
        200,
      );
    });

    final service = RoutingService(client: client);
    final route = await service.getDrivingRoute(
      origin: origin,
      destination: destination,
    );

    expect(route.distanceMeters, 20996.7);
    expect(route.durationSeconds, 1754.4);
    expect(route.polyline, hasLength(3));
    expect(route.polyline.first, const LatLng(11.1271, 78.6569));
    expect(route.instructions, hasLength(2));
    expect(route.instructions.first.text, 'Start driving onto Avinashi Road');
    expect(
      route.instructions.last.text,
      'You have arrived at your destination',
    );
  });

  test(
    'getDrivingRoute throws RoutingException on a non-200 response',
    () async {
      final client = MockClient((request) async => http.Response('error', 503));
      final service = RoutingService(client: client);

      expect(
        () => service.getDrivingRoute(origin: origin, destination: destination),
        throwsA(isA<RoutingException>()),
      );
    },
  );

  test(
    'getDrivingRoute throws RoutingException when OSRM reports no route',
    () async {
      final client = MockClient(
        (request) async =>
            http.Response(jsonEncode({'code': 'NoRoute', 'routes': []}), 200),
      );
      final service = RoutingService(client: client);

      expect(
        () => service.getDrivingRoute(origin: origin, destination: destination),
        throwsA(isA<RoutingException>()),
      );
    },
  );

  test(
    'getDrivingRoute throws RoutingException when the request itself fails',
    () async {
      final client = MockClient((request) async => throw Exception('offline'));
      final service = RoutingService(client: client);

      expect(
        () => service.getDrivingRoute(origin: origin, destination: destination),
        throwsA(isA<RoutingException>()),
      );
    },
  );
}
