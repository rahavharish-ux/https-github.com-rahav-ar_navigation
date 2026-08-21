import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/ar_availability.dart';

void main() {
  group('parseArCoreAvailability', () {
    test('maps SUPPORTED_INSTALLED to supported', () {
      expect(
        parseArCoreAvailability('SUPPORTED_INSTALLED'),
        ArAvailability.supported,
      );
    });

    test('maps SUPPORTED_APK_TOO_OLD and SUPPORTED_NOT_INSTALLED to the same '
        'actionable "needs Play Services" result', () {
      expect(
        parseArCoreAvailability('SUPPORTED_APK_TOO_OLD'),
        ArAvailability.needsGooglePlayServicesForAr,
      );
      expect(
        parseArCoreAvailability('SUPPORTED_NOT_INSTALLED'),
        ArAvailability.needsGooglePlayServicesForAr,
      );
    });

    test('maps UNSUPPORTED_DEVICE_NOT_CAPABLE to unsupportedDevice', () {
      expect(
        parseArCoreAvailability('UNSUPPORTED_DEVICE_NOT_CAPABLE'),
        ArAvailability.unsupportedDevice,
      );
    });

    test('maps real error/timeout codes to unknown, not a false negative', () {
      expect(parseArCoreAvailability('UNKNOWN_ERROR'), ArAvailability.unknown);
      expect(
        parseArCoreAvailability('UNKNOWN_TIMED_OUT'),
        ArAvailability.unknown,
      );
      expect(
        parseArCoreAvailability('UNKNOWN_CHECKING'),
        ArAvailability.unknown,
      );
    });

    test('maps null and an unrecognized code to unknown, not a crash', () {
      expect(parseArCoreAvailability(null), ArAvailability.unknown);
      expect(
        parseArCoreAvailability('SOME_FUTURE_CONSTANT'),
        ArAvailability.unknown,
      );
    });
  });
}
