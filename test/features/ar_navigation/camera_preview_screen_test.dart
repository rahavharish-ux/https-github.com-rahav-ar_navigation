import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/camera_provider.dart';
import 'package:tn_ar_navigation/features/ar_navigation/camera_preview_screen.dart';

/// A fixed [CameraState] without touching the real `camera` plugin, which
/// has no platform-channel implementation in the test environment — same
/// approach as `route_preview_screen_test.dart`'s `_FixedRouteNotifier`.
/// [start]/[stop] are also no-ops: the real ones would otherwise overwrite
/// the fixed state the moment `CameraPreviewScreen.initState` calls
/// `start()`.
class _FixedCameraNotifier extends CameraNotifier {
  _FixedCameraNotifier(this._fixed);

  final CameraState _fixed;
  int startCalls = 0;

  @override
  CameraState build() => _fixed;

  @override
  Future<void> start() async {
    startCalls++;
  }

  @override
  void stop() {}
}

void main() {
  Widget wrap(CameraState state) {
    return ProviderScope(
      overrides: [
        cameraProvider.overrideWith(() => _FixedCameraNotifier(state)),
      ],
      child: const MaterialApp(home: CameraPreviewScreen()),
    );
  }

  testWidgets('Shows a starting message while requesting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraRequesting()));

    expect(find.text('Starting the camera…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows an honest message when no camera is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraUnavailable()));

    expect(find.textContaining("doesn't have a usable camera"), findsOneWidget);
  });

  testWidgets(
    'Shows a permission-denied message with a retry action, no fake settings deep link',
    (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const CameraPermissionDenied()));

      expect(
        find.textContaining('Camera permission is needed'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
    },
  );

  testWidgets('Shows a generic message for an unexpected error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraError('init failed: boom')));

    expect(find.text("Couldn't start the camera right now."), findsOneWidget);
    // Raw error detail is diagnostics-only, never shown to normal users —
    // same rule as location/route/navigation errors.
    expect(find.textContaining('boom'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('Tapping Try again calls start() again', (
    WidgetTester tester,
  ) async {
    final notifier = _FixedCameraNotifier(const CameraError('x'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [cameraProvider.overrideWith(() => notifier)],
        child: const MaterialApp(home: CameraPreviewScreen()),
      ),
    );
    // initState already called start() once.
    expect(notifier.startCalls, 1);

    await tester.tap(find.text('Try again'));
    await tester.pump();

    expect(notifier.startCalls, 2);
  });

  testWidgets('Mounting with the real CameraNotifier does not crash with '
      '"Tried to modify a provider while the widget tree was building" -- '
      'regression test for a real bug found on a physical device where '
      "initState's unawaited start() call mutated provider state "
      'synchronously during the build phase, silently freezing the screen '
      'on CameraRequesting forever', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: CameraPreviewScreen())),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
