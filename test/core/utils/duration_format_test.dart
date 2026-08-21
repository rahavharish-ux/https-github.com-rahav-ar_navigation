import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/duration_format.dart';

void main() {
  test('formats sub-hour durations in minutes', () {
    expect(formatDurationSeconds(90), '2 min');
    expect(formatDurationSeconds(480), '8 min');
  });

  test('formats hour-plus durations as "h min"', () {
    expect(formatDurationSeconds(4320), '1 h 12 min');
  });

  test('omits minutes when the duration is an exact number of hours', () {
    expect(formatDurationSeconds(7200), '2 h');
  });
}
