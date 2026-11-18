import 'package:camera/camera.dart';

/// Captures one still frame and returns its file path, or `null` when the
/// controller can no longer capture — most commonly because the app was
/// backgrounded mid-capture and `CameraNotifier` released the camera
/// (Phase 2 M0). Callers treat `null` as "nothing captured" rather than
/// letting the `CameraException` escape as an uncaught async error.
Future<String?> captureStillImagePath(CameraController controller) async {
  try {
    final photo = await controller.takePicture();
    return photo.path;
  } on CameraException {
    return null;
  }
}
