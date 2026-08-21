import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

import '../../core/map/app_map_controller.dart';

/// The one place `package:google_maps_flutter` is used outside the map
/// abstraction layer. Swapping map providers later means touching only
/// this file and [AppMapController] — nothing in `features/` imports
/// google_maps_flutter directly. See ARCHITECTURE.md's "Map data
/// strategy" for why this replaced flutter_map/OpenStreetMap (Phase 11).
///
/// The current-location dot and its heading cone are Google's own native
/// "My Location" layer (`myLocationEnabled`), not a custom marker —
/// real GPS+device-sensor rendering handled at the platform level, the
/// same visual Google Maps itself shows. This app's own
/// `locationProvider`/`compassProvider` still exist and still feed
/// navigation math, off-route detection, and diagnostics; they just
/// aren't what draws this dot. Requires a real, billing-enabled Google
/// Maps API key — see SETUP.md and KNOWN_LIMITATIONS.md.
class AppMapView extends StatelessWidget {
  const AppMapView({
    super.key,
    required this.controller,
    required this.initialCenter,
    this.initialZoom = 14,
    this.destination,
    this.routePoints,
  });

  final AppMapController controller;
  final LatLng initialCenter;
  final double initialZoom;

  /// Selected search destination (Phase 5).
  final LatLng? destination;

  /// Calculated route polyline (Phase 6, driving only). Null/fewer than
  /// two points draws nothing.
  final List<LatLng>? routePoints;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return gmaps.GoogleMap(
      initialCameraPosition: gmaps.CameraPosition(
        target: _toGoogleLatLng(initialCenter),
        zoom: initialZoom,
      ),
      onMapCreated: controller.attach,
      onCameraMoveStarted: controller.handleCameraMoveStarted,
      onCameraIdle: controller.handleCameraIdle,
      // Google's own real, platform-native blue dot + heading cone —
      // requires location permission already granted (locationProvider
      // handles that flow elsewhere); shows nothing, doesn't crash, if
      // permission isn't granted yet.
      myLocationEnabled: true,
      // This app has its own Locate Me / Re-center buttons already —
      // Google's built-in one would be a redundant second control.
      myLocationButtonEnabled: false,
      markers: {
        if (destination != null)
          gmaps.Marker(
            markerId: const gmaps.MarkerId('destination'),
            position: _toGoogleLatLng(destination!),
            icon: gmaps.BitmapDescriptor.defaultMarkerWithHue(
              gmaps.BitmapDescriptor.hueRed,
            ),
          ),
      },
      polylines: {
        if (routePoints != null && routePoints!.length > 1)
          gmaps.Polyline(
            polylineId: const gmaps.PolylineId('route'),
            points: routePoints!.map(_toGoogleLatLng).toList(),
            width: 5,
            color: colorScheme.primary,
          ),
      },
    );
  }
}

gmaps.LatLng _toGoogleLatLng(LatLng point) =>
    gmaps.LatLng(point.latitude, point.longitude);
