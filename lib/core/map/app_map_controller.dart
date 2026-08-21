import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:latlong2/latlong.dart';

/// Thin wrapper over `google_maps_flutter`'s [gmaps.GoogleMapController].
/// The rest of the app depends on this type — not the map package
/// directly — so the underlying provider can be swapped later without
/// touching feature code. See ARCHITECTURE.md's "Map data strategy" (and
/// its Phase 11 update on why Nominatim/flutter_map were replaced with
/// Google's stack).
///
/// [gmaps.GoogleMapController] is only available asynchronously, once
/// [gmaps.GoogleMap.onMapCreated] fires — unlike flutter_map's
/// [gmaps.GoogleMapController]-free constructor. [moveTo]/[fitBounds]
/// calls made before that (unlikely in practice, since map creation is
/// fast, but not impossible) are queued and replayed once [attach] runs.
class AppMapController {
  gmaps.GoogleMapController? _controller;
  _PendingCamera? _pending;

  /// True for the whole span between a programmatic [moveTo]/[fitBounds]
  /// call and the camera settling (`onCameraIdle`). `google_maps_flutter`
  /// — unlike flutter_map — exposes no "why did the camera move" signal
  /// on `onCameraMoveStarted` (a real, longstanding gap in the plugin, not
  /// an oversight here); this flag is the standard workaround: anything
  /// we didn't ask for while it's false is a real user gesture.
  bool _programmaticMoveInFlight = false;

  final _userMovedController = StreamController<bool>.broadcast();

  /// Only [AppMapView] (the single `google_maps_flutter` adapter widget)
  /// should call this, from `onMapCreated`.
  void attach(gmaps.GoogleMapController controller) {
    _controller = controller;
    final pending = _pending;
    _pending = null;
    if (pending != null) _applyCamera(pending);
  }

  void moveTo(LatLng center, {double zoom = 16}) {
    final camera = _PendingCamera.center(center, zoom);
    if (_controller == null) {
      _pending = camera;
      return;
    }
    _applyCamera(camera);
  }

  /// Moves/zooms so every point in [points] is visible. A single point
  /// just centers on it (fitting bounds needs at least two). [padding] is
  /// applied uniformly on all sides — `google_maps_flutter`'s
  /// `newLatLngBounds` takes a single padding value, unlike flutter_map's
  /// per-side [EdgeInsets]; every call site in this app only ever passes
  /// `EdgeInsets.all(...)` anyway, so `padding.left` (arbitrarily, since
  /// all four sides are equal in practice) captures the real value.
  void fitBounds(
    List<LatLng> points, {
    EdgeInsets padding = const EdgeInsets.all(48),
  }) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      moveTo(points.first);
      return;
    }

    final camera = _PendingCamera.bounds(
      _boundsFromPoints(points),
      padding.left,
    );
    if (_controller == null) {
      _pending = camera;
      return;
    }
    _applyCamera(camera);
  }

  void _applyCamera(_PendingCamera camera) {
    _programmaticMoveInFlight = true;
    final update = switch (camera) {
      _CenterCamera(:final center, :final zoom) =>
        gmaps.CameraUpdate.newLatLngZoom(_toGoogleLatLng(center), zoom),
      _BoundsCamera(:final bounds, :final padding) =>
        gmaps.CameraUpdate.newLatLngBounds(bounds, padding),
    };
    _controller!.animateCamera(update);
  }

  /// Wired to [gmaps.GoogleMap.onCameraMoveStarted] by [AppMapView].
  void handleCameraMoveStarted() {
    if (!_programmaticMoveInFlight) _userMovedController.add(true);
  }

  /// Wired to [gmaps.GoogleMap.onCameraIdle] by [AppMapView] — ends the
  /// programmatic-move suppression window from [_applyCamera].
  void handleCameraIdle() {
    _programmaticMoveInFlight = false;
  }

  /// Emits whenever the map moves because of a user gesture (drag, pinch,
  /// scroll, rotate) rather than a programmatic [moveTo]/[fitBounds] call
  /// — the signal used to drop out of follow mode.
  Stream<bool> get userMovedMap => _userMovedController.stream;

  void dispose() {
    _userMovedController.close();
    _controller?.dispose();
  }
}

gmaps.LatLng _toGoogleLatLng(LatLng point) =>
    gmaps.LatLng(point.latitude, point.longitude);

gmaps.LatLngBounds _boundsFromPoints(List<LatLng> points) {
  var minLat = points.first.latitude;
  var maxLat = points.first.latitude;
  var minLng = points.first.longitude;
  var maxLng = points.first.longitude;

  for (final point in points.skip(1)) {
    minLat = math.min(minLat, point.latitude);
    maxLat = math.max(maxLat, point.latitude);
    minLng = math.min(minLng, point.longitude);
    maxLng = math.max(maxLng, point.longitude);
  }

  return gmaps.LatLngBounds(
    southwest: gmaps.LatLng(minLat, minLng),
    northeast: gmaps.LatLng(maxLat, maxLng),
  );
}

sealed class _PendingCamera {
  const _PendingCamera();

  factory _PendingCamera.center(LatLng center, double zoom) =>
      _CenterCamera(center, zoom);

  factory _PendingCamera.bounds(gmaps.LatLngBounds bounds, double padding) =>
      _BoundsCamera(bounds, padding);
}

class _CenterCamera extends _PendingCamera {
  const _CenterCamera(this.center, this.zoom);
  final LatLng center;
  final double zoom;
}

class _BoundsCamera extends _PendingCamera {
  const _BoundsCamera(this.bounds, this.padding);
  final gmaps.LatLngBounds bounds;
  final double padding;
}
