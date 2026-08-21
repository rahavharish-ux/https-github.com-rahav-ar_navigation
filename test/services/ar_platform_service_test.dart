import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/ar_availability.dart';
import 'package:tn_ar_navigation/services/ar_platform_service.dart';

void main() {
  // Needed because this test exercises a real MethodChannel call (not a
  // widget test, which initializes this implicitly via pumpWidget).
  TestWidgetsFlutterBinding.ensureInitialized();

  test('checkAvailability never throws in an environment with no native '
      'MethodChannel handler (this test environment) -- it resolves to a '
      'real, honest non-crashing result', () async {
    const service = ArPlatformService();

    final result = await service.checkAvailability();

    expect(
      result,
      anyOf(
        ArAvailability.notImplementedOnThisPlatform,
        ArAvailability.unknown,
      ),
    );
  });
}
