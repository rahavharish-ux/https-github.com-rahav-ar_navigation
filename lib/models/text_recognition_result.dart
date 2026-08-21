/// Decouples the app from google_mlkit_text_recognition's `RecognizedText`,
/// same reasoning as `AppLocation` decoupling from geolocator's `Position`.
class TextRecognitionResult {
  const TextRecognitionResult({required this.fullText, required this.lines});

  /// All recognized text joined as returned by ML Kit. Empty if nothing was
  /// recognized.
  final String fullText;

  /// One entry per recognized line, in reading order within each block.
  final List<String> lines;

  bool get hasText => lines.isNotEmpty;

  static const empty = TextRecognitionResult(fullText: '', lines: []);
}
