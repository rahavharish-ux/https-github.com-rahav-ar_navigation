import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/models/route_model.dart';
import 'package:tn_ar_navigation/services/routing_service.dart';

/// One captured `getDrivingRoute` call. The test decides when and how it
/// resolves, so in-flight behaviour (stop/dispose/restart while a request
/// is pending) can be exercised deterministically, with no network and no
/// wall-clock waits.
class PendingRouteRequest {
  PendingRouteRequest(this.origin, this.destination);

  final LatLng origin;
  final LatLng destination;
  final Completer<AppRoute> _completer = Completer<AppRoute>();

  Future<AppRoute> get future => _completer.future;

  void succeed(AppRoute route) => _completer.complete(route);

  void fail([String message = 'fake routing failure']) =>
      _completer.completeError(RoutingException(message));
}

/// Drop-in [RoutingService] for `routingServiceProvider.overrideWithValue`.
class FakeRoutingService extends RoutingService {
  FakeRoutingService();

  final List<PendingRouteRequest> requests = [];

  PendingRouteRequest get lastRequest => requests.last;

  @override
  Future<AppRoute> getDrivingRoute({
    required LatLng origin,
    required LatLng destination,
  }) {
    final request = PendingRouteRequest(origin, destination);
    requests.add(request);
    return request.future;
  }

  @override
  void dispose() {}
}
