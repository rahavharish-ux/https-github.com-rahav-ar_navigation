import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/core/providers/route_provider.dart';
import 'package:tn_ar_navigation/core/providers/travel_mode_provider.dart';

void main() {
  const origin = LatLng(11.1271, 78.6569);
  const destination = LatLng(11.2, 78.7);

  test(
    'calculate marks Walking as unsupported without touching the network',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(routeProvider.notifier)
          .calculate(
            origin: origin,
            destination: destination,
            mode: TravelMode.walking,
          );

      expect(container.read(routeProvider), isA<RouteModeUnsupported>());
    },
  );

  test(
    'calculate marks Cycling as unsupported without touching the network',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(routeProvider.notifier)
          .calculate(
            origin: origin,
            destination: destination,
            mode: TravelMode.cycling,
          );

      expect(container.read(routeProvider), isA<RouteModeUnsupported>());
    },
  );

  test('clear resets state to idle', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(routeProvider.notifier).clear();

    expect(container.read(routeProvider), isA<RouteIdle>());
  });
}
