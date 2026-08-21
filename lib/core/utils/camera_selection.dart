import 'package:camera/camera.dart';

/// Picks which camera to open for AR navigation (Phase 9-10): the rear
/// ("back") camera when one exists, since that's the one you point at the
/// world; falls back to the first available camera on devices that only
/// report a front one (e.g. some tablets/emulators); `null` when [cameras]
/// is empty, meaning [CameraUnavailable] should be shown rather than a
/// crash.
CameraDescription? pickPreferredCamera(List<CameraDescription> cameras) {
  if (cameras.isEmpty) return null;
  for (final camera in cameras) {
    if (camera.lensDirection == CameraLensDirection.back) return camera;
  }
  return cameras.first;
}

/// True when a `CameraException`'s `code` indicates the user denied camera
/// permission (as opposed to a real hardware/init failure). The `camera`
/// plugin doesn't expose a single cross-platform enum for this — Android
/// and iOS each report their own string codes — so this matches on the
/// substrings both platforms are documented to use, case-insensitively.
bool isPermissionDeniedCode(String code) {
  final normalized = code.toLowerCase();
  return normalized.contains('accessdenied') ||
      normalized.contains('permission');
}
