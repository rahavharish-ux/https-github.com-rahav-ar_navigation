import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/compass_provider.dart';

void main() {
  group('compassStateFromEvent', () {
    test(
      'a null heading (device has no magnetometer) is CompassUnavailable',
      () {
        expect(
          compassStateFromEvent(CompassEvent.fromList(null)),
          isA<CompassUnavailable>(),
        );
      },
    );

    test(
      'a real heading resolves to CompassAvailable with heading and accuracy',
      () {
        final result = compassStateFromEvent(
          CompassEvent.fromList([47.0, 47.0, 5.0]),
        );

        expect(result, isA<CompassAvailable>());
        expect((result as CompassAvailable).reading.headingDegrees, 47.0);
        expect(result.reading.accuracyDegrees, 5.0);
      },
    );

    test('an accuracy of -1 (real "no accuracy reported" sentinel from '
        'flutter_compass) is passed through as null, not faked as a real '
        'number', () {
      final result = compassStateFromEvent(
        CompassEvent.fromList([10.0, 10.0, -1.0]),
      );

      expect((result as CompassAvailable).reading.accuracyDegrees, isNull);
    });
  });

  test('compassProvider starts at CompassInitial', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(compassProvider), isA<CompassInitial>());
  });
}
