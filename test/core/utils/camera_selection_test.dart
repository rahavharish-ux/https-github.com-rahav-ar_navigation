import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/camera_selection.dart';

CameraDescription _camera(String name, CameraLensDirection direction) {
  return CameraDescription(
    name: name,
    lensDirection: direction,
    sensorOrientation: 0,
  );
}

void main() {
  group('pickPreferredCamera', () {
    test('returns null for an empty list', () {
      expect(pickPreferredCamera(const []), isNull);
    });

    test('prefers the back camera when one exists', () {
      final front = _camera('front', CameraLensDirection.front);
      final back = _camera('back', CameraLensDirection.back);

      expect(pickPreferredCamera([front, back]), same(back));
    });

    test('falls back to the first camera when there is no back camera', () {
      final front = _camera('front', CameraLensDirection.front);
      final external = _camera('external', CameraLensDirection.external);

      expect(pickPreferredCamera([front, external]), same(front));
    });

    test('a single front-only camera is still returned', () {
      final front = _camera('front', CameraLensDirection.front);

      expect(pickPreferredCamera([front]), same(front));
    });
  });

  group('isPermissionDeniedCode', () {
    test('recognizes the Android denial code', () {
      expect(isPermissionDeniedCode('CameraAccessDenied'), isTrue);
    });

    test('recognizes the iOS denial code', () {
      expect(isPermissionDeniedCode('CameraAccessDeniedWithoutPrompt'), isTrue);
    });

    test('is case-insensitive', () {
      expect(isPermissionDeniedCode('cameraaccessdenied'), isTrue);
    });

    test('recognizes a generic "permission" code', () {
      expect(isPermissionDeniedCode('permissionDenied'), isTrue);
    });

    test('does not flag an unrelated error code', () {
      expect(isPermissionDeniedCode('CameraAccessRestricted'), isFalse);
      expect(isPermissionDeniedCode('cameraNotFound'), isFalse);
    });
  });
}
