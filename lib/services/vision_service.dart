import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../core/utils/vision_mapping.dart';
import '../models/scene_label.dart';
import '../models/text_recognition_result.dart';

/// True only where the ML Kit Flutter plugins actually ship a platform
/// implementation — Android and iOS. Both `google_mlkit_text_recognition`
/// and `google_mlkit_image_labeling` have no web/desktop implementation, so
/// this app-level guard must exist before calling either recognizer, the
/// same reasoning `ArPlatformService`'s native-Android guard established
/// for ARCore (Phase 10).
bool get isVisionSupportedOnThisPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

/// Thin, swappable wrapper over the two on-device ML Kit recognizers this
/// phase uses — same "one concrete class, no interface until a second
/// implementation exists" pattern as `LocationService`/`CameraService`.
/// Both recognizers run fully on-device: no network call, no cloud API key,
/// per this project's Phase 13 on-device-only decision (see
/// ARCHITECTURE.md).
class VisionService {
  VisionService()
    : _textRecognizer = TextRecognizer(),
      _imageLabeler = ImageLabeler(options: ImageLabelerOptions());

  final TextRecognizer _textRecognizer;
  final ImageLabeler _imageLabeler;

  Future<TextRecognitionResult> recognizeText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognized = await _textRecognizer.processImage(inputImage);
    return textRecognitionResultFromRecognizedText(recognized);
  }

  Future<List<SceneLabel>> labelScene(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final labels = await _imageLabeler.processImage(inputImage);
    return sceneLabelsFromImageLabels(labels);
  }

  /// Best-effort release: `close()` calls a real `MethodChannel`, which can
  /// fail (e.g. no native handler in this test environment, or a real
  /// platform-side error). Nothing meaningful to do about a failure at
  /// teardown time — same reasoning as `CameraNotifier._disposeController`.
  Future<void> dispose() async {
    try {
      await _textRecognizer.close();
    } catch (_) {
      // Ignored -- see doc comment above.
    }
    try {
      await _imageLabeler.close();
    } catch (_) {
      // Ignored -- see doc comment above.
    }
  }
}
