import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../models/navigation_instruction.dart';
import '../models/route_model.dart';

class RoutingException implements Exception {
  const RoutingException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper over OSRM's public demo routing API — driving only.
///
/// The public demo server (router.project-osrm.org) accepts "foot"/"bike"
/// as profile names in its URL but has no real pedestrian/cycling road
/// graph loaded: querying them returns byte-identical distance/duration to
/// "driving" for the same coordinates, with the response itself labeled
/// `"mode":"driving"` (verified while building this phase). Presenting
/// that as real walking/cycling routing would violate this project's
/// "no faked functionality" rule, so this service only exposes driving —
/// see KNOWN_LIMITATIONS.md.
///
/// Like `GeocodingService`'s Nominatim endpoint, this is a development-tier
/// public demo server, not meant for production traffic — a production
/// release needs a self-hosted or paid routing backend instead.
class RoutingService {
  RoutingService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://router.project-osrm.org/route/v1/driving';

  final http.Client _client;

  Future<AppRoute> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) async {
    final coordinates =
        '${origin.longitude},${origin.latitude};'
        '${destination.longitude},${destination.latitude}';
    final uri = Uri.parse('$_baseUrl/$coordinates').replace(
      queryParameters: {
        'overview': 'full',
        'geometries': 'geojson',
        'steps': 'true',
      },
    );

    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 10));
    } catch (error) {
      throw RoutingException('Network error: $error');
    }

    if (response.statusCode != 200) {
      throw RoutingException(
        'Routing failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['code'] != 'Ok') {
      throw const RoutingException('No route found');
    }

    final routes = decoded['routes'] as List<dynamic>;
    if (routes.isEmpty) throw const RoutingException('No route found');

    final route = routes.first as Map<String, dynamic>;
    final geometry = route['geometry'] as Map<String, dynamic>;
    final coordinatesList = (geometry['coordinates'] as List<dynamic>)
        .cast<List<dynamic>>();

    final legs = (route['legs'] as List<dynamic>).cast<Map<String, dynamic>>();
    final steps = legs
        .expand(
          (leg) => (leg['steps'] as List<dynamic>).cast<Map<String, dynamic>>(),
        )
        .toList();

    return AppRoute(
      distanceMeters: (route['distance'] as num).toDouble(),
      durationSeconds: (route['duration'] as num).toDouble(),
      polyline: coordinatesList
          .map(
            (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          )
          .toList(),
      instructions: steps.map(NavigationInstruction.fromOsrmStep).toList(),
    );
  }

  void dispose() => _client.close();
}
