import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../models/route_model.dart';
import '../../services/routing_service.dart';
import 'travel_mode_provider.dart';

sealed class RouteState {
  const RouteState();
}

/// Nothing requested yet.
class RouteIdle extends RouteState {
  const RouteIdle();
}

class RouteLoading extends RouteState {
  const RouteLoading();
}

class RouteReady extends RouteState {
  const RouteReady(this.route);

  final AppRoute route;
}

/// The selected [TravelMode] isn't [TravelMode.driving]. The routing
/// backend (OSRM's public demo) has no real walking/cycling road graph —
/// see KNOWN_LIMITATIONS.md — so this is surfaced honestly instead of
/// silently reusing driving-mode results under a different label.
class RouteModeUnsupported extends RouteState {
  const RouteModeUnsupported();
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, matching the pattern in `location_provider.dart`.
class RouteFailed extends RouteState {
  const RouteFailed(this.message);

  final String message;
}

final routeProvider = NotifierProvider<RouteNotifier, RouteState>(
  RouteNotifier.new,
);

class RouteNotifier extends Notifier<RouteState> {
  late final RoutingService _service;

  @override
  RouteState build() {
    _service = RoutingService();
    ref.onDispose(_service.dispose);
    return const RouteIdle();
  }

  Future<void> calculate({
    required LatLng origin,
    required LatLng destination,
    required TravelMode mode,
  }) async {
    if (mode != TravelMode.driving) {
      state = const RouteModeUnsupported();
      return;
    }

    state = const RouteLoading();
    try {
      final route = await _service.getDrivingRoute(
        origin: origin,
        destination: destination,
      );
      state = RouteReady(route);
    } on RoutingException catch (error) {
      state = RouteFailed(error.message);
    } catch (error) {
      state = RouteFailed(error.toString());
    }
  }

  void clear() => state = const RouteIdle();
}
