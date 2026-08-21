/// Decouples the app from google_mlkit_image_labeling's `ImageLabel`. This
/// is a generic scene label ("temple", "tower", "building") — not a
/// specific landmark identity. On-device ML Kit has no landmark-ID model
/// (that only exists in the cloud-only Google Cloud Vision API); see
/// KNOWN_LIMITATIONS.md for why true landmark recognition isn't built.
class SceneLabel {
  const SceneLabel({required this.label, required this.confidence});

  final String label;

  /// 0.0-1.0.
  final double confidence;

  String get confidencePercent => '${(confidence * 100).round()}%';
}
