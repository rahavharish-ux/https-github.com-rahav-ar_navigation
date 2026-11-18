import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../services/camera_service.dart';
import '../utils/camera_lifecycle.dart';
import '../utils/camera_selection.dart';

sealed class CameraState {
  const CameraState();
}

/// Nothing requested yet.
class CameraInitial extends CameraState {
  const CameraInitial();
}

class CameraRequesting extends CameraState {
  const CameraRequesting();
}

class CameraAvailable extends CameraState {
  const CameraAvailable(this.controller);

  final CameraController controller;
}

/// No usable camera on this device. A real, first-class state (not an
/// error) — AR navigation (Phase 10) must detect this and fall back to
/// standard navigation rather than fail; see KNOWN_LIMITATIONS.md.
class CameraUnavailable extends CameraState {
  const CameraUnavailable();
}

class CameraPermissionDenied extends CameraState {
  const CameraPermissionDenied();
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, matching the pattern in `location_provider.dart`.
class CameraError extends CameraState {
  const CameraError(this.message);

  final String message;
}

final cameraProvider = NotifierProvider<CameraNotifier, CameraState>(
  CameraNotifier.new,
);

/// Real permission→init flow for the device camera (Phase 9), mirroring
/// `LocationNotifier`'s shape. Deliberately does not request camera access
/// on app launch or on `AR Navigation` becoming visible — only when a
/// screen that actually needs the feed (`CameraPreviewScreen`) starts it,
/// same "ask only when needed" rule Phase 3 established for location.
class CameraNotifier extends Notifier<CameraState> {
  late final CameraService _service;

  /// Tracked separately from [state] (rather than pattern-matching `state`
  /// inside [_disposeController]) because Riverpod forbids reading `state`
  /// from within a `ref.onDispose` callback — the same reason
  /// `LocationNotifier` tracks `_lastAccepted`/`_lastSmoothed` as plain
  /// fields instead of deriving them from `state`.
  CameraController? _controller;

  /// Incremented by [stop] and by a lifecycle release. A [start] in flight
  /// captures it before awaiting the platform and, if it has changed (or
  /// the provider was disposed) by the time a controller is ready, releases
  /// that controller instead of publishing it (Phase 2 M0).
  int _startGeneration = 0;

  /// True while the camera is closed only because the app left the
  /// foreground, so `resumed` knows to re-open it.
  bool _releasedForLifecycle = false;

  /// True between a `hidden`/`paused`/`detached` lifecycle event and the
  /// next `resumed`. Not set by `inactive` alone, which the camera
  /// permission dialog also triggers while the app stays visible.
  bool _appInBackground = false;

  @override
  CameraState build() {
    _service = createService();
    ref.onDispose(_disposeController);
    return const CameraInitial();
  }

  /// Overridden in tests to inject a fake `CameraService` (Phase 2 M0),
  /// same pattern as `LocationNotifier.createService`.
  @visibleForTesting
  CameraService createService() => const CameraService();

  Future<void> start() async {
    if (state is CameraRequesting) return;
    final generation = _startGeneration;
    bool isStale() => !ref.mounted || generation != _startGeneration;
    state = const CameraRequesting();

    try {
      final cameras = await _service.listCameras();
      if (isStale()) return;
      final description = pickPreferredCamera(cameras);
      if (description == null) {
        state = const CameraUnavailable();
        return;
      }

      final controller = await _service.initializeController(description);
      if (isStale()) {
        // Stopped, backgrounded, or disposed while initializing: nobody
        // will ever show or release this controller, so release it now.
        controller.dispose();
        return;
      }
      if (_appInBackground) {
        // Finished initializing after the app went to the background, so
        // there was no open camera to release at the time. Release it now
        // and let `resumed` re-open it (M0 closure).
        controller.dispose();
        _releasedForLifecycle = true;
        state = const CameraInitial();
        return;
      }
      _controller = controller;
      state = CameraAvailable(controller);
    } on CameraException catch (error) {
      if (isStale()) return;
      state = isPermissionDeniedCode(error.code)
          ? const CameraPermissionDenied()
          : CameraError(error.description ?? error.code);
    } catch (error) {
      if (isStale()) return;
      state = CameraError(error.toString());
    }
  }

  void stop() {
    _startGeneration++;
    _releasedForLifecycle = false;
    _disposeController();
    state = const CameraInitial();
  }

  /// Forwarded from the screens showing the camera (see
  /// `CameraLifecycleBinding`). Releases the camera when the app leaves the
  /// foreground and re-opens it on return — see [cameraLifecycleActionFor].
  void handleAppLifecycleState(AppLifecycleState lifecycleState) {
    switch (lifecycleState) {
      case AppLifecycleState.hidden ||
          AppLifecycleState.paused ||
          AppLifecycleState.detached:
        _appInBackground = true;
      case AppLifecycleState.resumed:
        _appInBackground = false;
      case AppLifecycleState.inactive:
        break;
    }
    switch (cameraLifecycleActionFor(
      lifecycleState,
      hasOpenCamera: _controller != null,
      releasedForLifecycle: _releasedForLifecycle,
    )) {
      case CameraLifecycleAction.none:
        return;
      case CameraLifecycleAction.release:
        _startGeneration++;
        _releasedForLifecycle = true;
        _disposeController();
        // Same state as "not started yet": the screens already show
        // "Starting the camera..." for it, which is what the user sees for
        // the moment it takes to re-open on return.
        state = const CameraInitial();
      case CameraLifecycleAction.reacquire:
        _releasedForLifecycle = false;
        start();
    }
  }

  void _disposeController() {
    // Fire-and-forget: `dispose()` releases the platform camera session
    // asynchronously, but neither `stop()` nor `ref.onDispose` can await
    // it (the latter runs synchronously), and there's nothing meaningful
    // to do with a failure at teardown time.
    _controller?.dispose();
    _controller = null;
  }
}
