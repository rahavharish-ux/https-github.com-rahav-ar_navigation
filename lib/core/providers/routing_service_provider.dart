import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/routing_service.dart';

/// The single [RoutingService] instance shared by route preview
/// (`routeProvider`) and turn-by-turn recalculation (`navigationProvider`).
///
/// Exists so tests can override it with a fake that resolves or fails on
/// demand (Phase 2 M0). Before this, both notifiers constructed
/// `RoutingService()` directly, so their tests could only "block" the real
/// network with a short connect timeout and a wall-clock wait, which made
/// them depend on how fast the environment refused the connection.
final routingServiceProvider = Provider<RoutingService>((ref) {
  final service = RoutingService();
  ref.onDispose(service.dispose);
  return service;
});
