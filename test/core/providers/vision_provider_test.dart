import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/vision_provider.dart';

void main() {
  // Needed because scanText/labelScene exercise a real MethodChannel call
  // (not a widget test, which initializes this implicitly via pumpWidget) —
  // same reasoning as ar_platform_service_test.dart.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('starts idle or unavailable depending on the reported platform', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(visionProvider),
      anyOf(isA<VisionIdle>(), isA<VisionUnavailable>()),
    );
  });

  test(
    'scanText never throws with no native MethodChannel handler (this test '
    'environment) -- it resolves to a real, honest non-crashing result',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container.read(visionProvider.notifier).scanText('unused_path.jpg');

      expect(
        container.read(visionProvider),
        anyOf(isA<VisionFailed>(), isA<VisionUnavailable>()),
      );
    },
  );

  test(
    'labelScene never throws with no native MethodChannel handler (this '
    'test environment) -- it resolves to a real, honest non-crashing result',
    () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      await container
          .read(visionProvider.notifier)
          .labelScene('unused_path.jpg');

      expect(
        container.read(visionProvider),
        anyOf(isA<VisionFailed>(), isA<VisionUnavailable>()),
      );
    },
  );

  test('reset() returns to the idle/unavailable state', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(visionProvider.notifier).scanText('unused_path.jpg');
    container.read(visionProvider.notifier).reset();

    expect(
      container.read(visionProvider),
      anyOf(isA<VisionIdle>(), isA<VisionUnavailable>()),
    );
  });
}
