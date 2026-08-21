import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:tn_ar_navigation/core/utils/vision_mapping.dart';

TextLine _line(String text) {
  return TextLine(
    text: text,
    elements: const [],
    boundingBox: Rect.zero,
    recognizedLanguages: const [],
    cornerPoints: const [],
    confidence: null,
    angle: null,
  );
}

TextBlock _block(List<String> lineTexts) {
  return TextBlock(
    text: lineTexts.join('\n'),
    lines: [for (final text in lineTexts) _line(text)],
    boundingBox: Rect.zero,
    recognizedLanguages: const [],
    cornerPoints: const [],
  );
}

void main() {
  group('textRecognitionResultFromRecognizedText', () {
    test('maps full text and flattens all blocks/lines in order', () {
      final recognized = RecognizedText(
        text: 'Trichy Road\nWelcome',
        blocks: [
          _block(['Trichy Road']),
          _block(['Welcome']),
        ],
      );

      final result = textRecognitionResultFromRecognizedText(recognized);

      expect(result.fullText, 'Trichy Road\nWelcome');
      expect(result.lines, ['Trichy Road', 'Welcome']);
      expect(result.hasText, isTrue);
    });

    test('an empty result (no text found) maps to no lines', () {
      final recognized = RecognizedText(text: '', blocks: const []);

      final result = textRecognitionResultFromRecognizedText(recognized);

      expect(result.fullText, isEmpty);
      expect(result.lines, isEmpty);
      expect(result.hasText, isFalse);
    });

    test('a block with multiple lines flattens each line separately', () {
      final recognized = RecognizedText(
        text: 'A\nB\nC',
        blocks: [
          _block(['A', 'B', 'C']),
        ],
      );

      final result = textRecognitionResultFromRecognizedText(recognized);

      expect(result.lines, ['A', 'B', 'C']);
    });
  });

  group('sceneLabelsFromImageLabels', () {
    test('sorts by confidence, descending', () {
      final labels = [
        ImageLabel(confidence: 0.6, label: 'building', index: 1),
        ImageLabel(confidence: 0.9, label: 'temple', index: 2),
        ImageLabel(confidence: 0.75, label: 'tower', index: 3),
      ];

      final result = sceneLabelsFromImageLabels(labels);

      expect(result.map((l) => l.label), ['temple', 'tower', 'building']);
    });

    test('an empty list maps to an empty list', () {
      expect(sceneLabelsFromImageLabels(const []), isEmpty);
    });

    test('preserves the real confidence value and formats a percent', () {
      final result = sceneLabelsFromImageLabels([
        ImageLabel(confidence: 0.873, label: 'plant', index: 0),
      ]);

      expect(result.single.confidence, 0.873);
      expect(result.single.confidencePercent, '87%');
    });
  });
}
