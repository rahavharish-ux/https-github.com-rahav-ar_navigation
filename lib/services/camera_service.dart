import 'package:camera/camera.dart';

/// Thin wrapper over `package:camera`, following the same pattern as
/// `LocationService`/`RoutingService`: keeps the concrete plugin isolated
/// to one swappable file rather than importing it across the app.
class CameraService {
  const CameraService();

  Future<List<CameraDescription>> listCameras() => availableCameras();

  /// Creates and initializes a controller for [description]. Audio is
  /// disabled: AR navigation guidance has no use for the microphone, and
  /// requesting it would mean asking for a permission this app never uses.
  Future<CameraController> initializeController(
    CameraDescription description,
  ) async {
    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller.initialize();
    return controller;
  }
}
