import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/camera_provider.dart';
import 'package:tn_ar_navigation/features/vision/vision_screen.dart';

/// A fixed [CameraState] without touching the real `camera` plugin, which
/// has no platform-channel implementation in the test environment — same
/// approach as `camera_preview_screen_test.dart`'s `_FixedCameraNotifier`.
/// The `CameraAvailable` (live feed + vision results) render path can't be
/// exercised here for the same reason it can't for `CameraPreviewScreen` —
/// see KNOWN_LIMITATIONS.md.
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
      child: const MaterialApp(home: VisionScreen()),
    );
  }

  testWidgets('Shows the Computer Vision title while starting the camera', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraRequesting()));

    expect(find.text('Computer Vision'), findsOneWidget);
    expect(find.text('Starting the camera…'), findsOneWidget);
  });

  testWidgets('Shows an honest message when no camera is available', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraUnavailable()));

    expect(find.textContaining("doesn't have a usable camera"), findsOneWidget);
  });

  testWidgets('Shows a permission-denied message with a retry action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraPermissionDenied()));

    expect(find.textContaining('Camera permission is needed'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('Shows a generic message for an unexpected camera error', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const CameraError('init failed: boom')));

    expect(find.text("Couldn't start the camera right now."), findsOneWidget);
    expect(find.textContaining('boom'), findsNothing);
  });

  testWidgets('Starts the camera once on init', (WidgetTester tester) async {
    final notifier = _FixedCameraNotifier(const CameraUnavailable());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [cameraProvider.overrideWith(() => notifier)],
        child: const MaterialApp(home: VisionScreen()),
      ),
    );

    expect(notifier.startCalls, 1);
  });

  testWidgets(
    'Mounting with the real CameraNotifier does not crash with '
    '"Tried to modify a provider while the widget tree was building" -- '
    'same regression this bug had in CameraPreviewScreen, see its test file',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: VisionScreen())),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    },
  );
}
