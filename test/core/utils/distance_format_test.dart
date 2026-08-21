import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/distance_format.dart';

void main() {
  test('formats sub-kilometer distances in meters', () {
    expect(formatDistanceMeters(350), '350 m');
    expect(formatDistanceMeters(999), '999 m');
  });

  test('formats kilometer-plus distances in km with one decimal', () {
    expect(formatDistanceMeters(1000), '1.0 km');
    expect(formatDistanceMeters(12400), '12.4 km');
  });
}
