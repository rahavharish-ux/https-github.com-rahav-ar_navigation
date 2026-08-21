import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../models/scene_label.dart';
import '../../models/text_recognition_result.dart';

/// Pure mapping from ML Kit's raw `RecognizedText` to this app's own model —
/// pulled out for testability, same pattern as `camera_selection.dart`/
/// `ar_availability.dart`.
TextRecognitionResult textRecognitionResultFromRecognizedText(
  RecognizedText recognizedText,
) {
  final lines = [
    for (final block in recognizedText.blocks)
      for (final line in block.lines) line.text,
  ];
  return TextRecognitionResult(fullText: recognizedText.text, lines: lines);
}

/// Sorted by confidence, descending — the most likely labels first. ML Kit
/// itself doesn't guarantee an order.
List<SceneLabel> sceneLabelsFromImageLabels(List<ImageLabel> labels) {
  final sorted = [...labels]
    ..sort((a, b) => b.confidence.compareTo(a.confidence));
  return [
    for (final label in sorted)
      SceneLabel(label: label.label, confidence: label.confidence),
  ];
}
