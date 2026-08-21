import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:tn_ar_navigation/core/map/app_map_controller.dart';
import 'package:tn_ar_navigation/core/theme/app_theme.dart';
import 'package:tn_ar_navigation/widgets/map/app_map_view.dart';

/// `GoogleMap` needs a real native platform view to actually render a
/// live map (unverifiable in `flutter_test` — see KNOWN_LIMITATIONS.md,
/// same category of gap as the camera preview/AR live states). These
/// tests only confirm the widget builds without throwing across the real
/// prop combinations this app uses — not that a real map ever appears.
void main() {
  const location = LatLng(11.0168, 76.9558);
  const destination = LatLng(11.1271, 78.6569);

  Widget wrap(Widget child) {
    return MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );
  }

  testWidgets('Builds with no destination or route (home screen idle state)', (
    WidgetTester tester,
  ) async {
    final controller = AppMapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(AppMapView(controller: controller, initialCenter: location)),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('Builds with a destination marker', (WidgetTester tester) async {
    final controller = AppMapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        AppMapView(
          controller: controller,
          initialCenter: location,
          destination: destination,
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('Builds with a destination and a route polyline', (
    WidgetTester tester,
  ) async {
    final controller = AppMapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        AppMapView(
          controller: controller,
          initialCenter: location,
          destination: destination,
          routePoints: [location, destination],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('A single-point routePoints list draws nothing (needs >= 2)', (
    WidgetTester tester,
  ) async {
    final controller = AppMapController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      wrap(
        AppMapView(
          controller: controller,
          initialCenter: location,
          routePoints: [location],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
