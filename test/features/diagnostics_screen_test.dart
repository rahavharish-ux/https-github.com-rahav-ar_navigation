import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/features/diagnostics/diagnostics_screen.dart';

void main() {
  testWidgets('Diagnostics screen shows initial location status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
    );

    expect(find.text('Developer Diagnostics'), findsOneWidget);
    // Location and camera both start unrequested — two sections, same text.
    expect(find.text('Not requested yet'), findsNWidgets(2));
  });

  testWidgets('Shows a Camera section with a Preview camera action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
    );

    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Preview camera'), findsOneWidget);
  });

  testWidgets(
    'Shows an AR section with a not-checked-yet status and a check action',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
      );

      expect(find.text('AR (ARCore)'), findsOneWidget);
      expect(find.text('Not checked yet'), findsOneWidget);
      expect(find.text('Check AR support'), findsOneWidget);
    },
  );

  testWidgets('Tapping Check AR support requests an AR availability check', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
    );

    await tester.tap(find.text('Check AR support'));
    await tester.pump();

    // The real check runs against a MethodChannel with no native handler
    // in this test environment, so it settles on an honest non-crashing
    // result rather than "Not checked yet" — see ar_platform_service_test.dart
    // for what that result actually is.
    expect(find.text('Not checked yet'), findsNothing);
  });

  testWidgets('Shows Compass and Motion sensors sections with start actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
    );
    // These sections are below the fold in the diagnostics ListView —
    // scroll to them rather than assume they're already built/visible.
    await tester.scrollUntilVisible(find.text('Motion sensors (IMU)'), 300);

    expect(find.text('Compass'), findsOneWidget);
    expect(find.text('Not started yet'), findsNWidgets(2));
    expect(find.text('Start compass'), findsOneWidget);
    expect(find.text('Motion sensors (IMU)'), findsOneWidget);
    expect(find.text('Start motion sensors'), findsOneWidget);
  });

  testWidgets('Tapping Start compass starts the real compass stream', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
    );
    await tester.scrollUntilVisible(find.text('Start compass'), 300);

    await tester.tap(find.text('Start compass'));
    await tester.pump();

    // No native flutter_compass EventChannel handler in this test
    // environment, so the stream stays open without emitting — this just
    // confirms tapping doesn't throw, matching the "live-feed states need
    // a real device" gap already documented for camera/AR.
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Tapping Start motion sensors starts the real accelerometer/gyroscope streams',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
      );
      await tester.scrollUntilVisible(find.text('Start motion sensors'), 300);

      await tester.tap(find.text('Start motion sensors'));
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Shows a Vision section with a not-analyzed-yet status and a preview action',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: DiagnosticsScreen())),
      );
      await tester.scrollUntilVisible(find.text('Vision (Phase 13)'), 300);

      expect(find.text('Vision (Phase 13)'), findsOneWidget);
      expect(find.text('Not analyzed yet'), findsOneWidget);
      expect(find.text('Preview vision'), findsOneWidget);
    },
  );
}
