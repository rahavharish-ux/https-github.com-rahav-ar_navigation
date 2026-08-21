import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/camera_service.dart';
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

  @override
  CameraState build() {
    _service = const CameraService();
    ref.onDispose(_disposeController);
    return const CameraInitial();
  }

  Future<void> start() async {
    if (state is CameraRequesting) return;
    state = const CameraRequesting();

    try {
      final cameras = await _service.listCameras();
      final description = pickPreferredCamera(cameras);
      if (description == null) {
        state = const CameraUnavailable();
        return;
      }

      final controller = await _service.initializeController(description);
      _controller = controller;
      state = CameraAvailable(controller);
    } on CameraException catch (error) {
      state = isPermissionDeniedCode(error.code)
          ? const CameraPermissionDenied()
          : CameraError(error.description ?? error.code);
    } catch (error) {
      state = CameraError(error.toString());
    }
  }

  void stop() {
    _disposeController();
    state = const CameraInitial();
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
