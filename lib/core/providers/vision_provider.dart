import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/scene_label.dart';
import '../../models/text_recognition_result.dart';
import '../../services/vision_service.dart';

sealed class VisionState {
  const VisionState();
}

/// Nothing captured/analyzed yet.
class VisionIdle extends VisionState {
  const VisionIdle();
}

class VisionProcessing extends VisionState {
  const VisionProcessing();
}

class VisionTextResult extends VisionState {
  const VisionTextResult(this.result);

  final TextRecognitionResult result;
}

class VisionLabelResult extends VisionState {
  const VisionLabelResult(this.labels);

  final List<SceneLabel> labels;
}

/// Real, first-class state — not an error — for the platforms these ML Kit
/// plugins genuinely ship no implementation for (web/desktop).
class VisionUnavailable extends VisionState {
  const VisionUnavailable();
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, same pattern as `LocationError`/`CameraError`.
class VisionFailed extends VisionState {
  const VisionFailed(this.message);

  final String message;
}

final visionProvider = NotifierProvider<VisionNotifier, VisionState>(
  VisionNotifier.new,
);

/// Real on-device text recognition + scene labeling (Phase 13), run against
/// a single captured camera frame — not a continuous stream. A deliberate
/// scope choice: it keeps this feature's battery/perf cost bounded and
/// avoids the CameraImage-stream-to-InputImage rotation/format handling a
/// live scanner would need, the same "ask/run only when actually needed"
/// discipline camera (Phase 9) and compass (Phase 11) established.
class VisionNotifier extends Notifier<VisionState> {
  late final VisionService _service;

  @override
  VisionState build() {
    _service = VisionService();
    ref.onDispose(() => _service.dispose());
    return isVisionSupportedOnThisPlatform
        ? const VisionIdle()
        : const VisionUnavailable();
  }

  Future<void> scanText(String imagePath) async {
    if (!isVisionSupportedOnThisPlatform) {
      state = const VisionUnavailable();
      return;
    }
    state = const VisionProcessing();
    try {
      final result = await _service.recognizeText(imagePath);
      state = VisionTextResult(result);
    } catch (error) {
      state = VisionFailed(error.toString());
    }
  }

  Future<void> labelScene(String imagePath) async {
    if (!isVisionSupportedOnThisPlatform) {
      state = const VisionUnavailable();
      return;
    }
    state = const VisionProcessing();
    try {
      final labels = await _service.labelScene(imagePath);
      state = VisionLabelResult(labels);
    } catch (error) {
      state = VisionFailed(error.toString());
    }
  }

  void reset() {
    state = isVisionSupportedOnThisPlatform
        ? const VisionIdle()
        : const VisionUnavailable();
  }
}
