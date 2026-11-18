import 'package:camera/camera.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/utils/camera_capture.dart';

const _backCamera = CameraDescription(
  name: '0',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

class _CaptureController extends CameraController {
  _CaptureController(this._result)
    : super(_backCamera, ResolutionPreset.low, enableAudio: false);

  /// An [XFile] to return, or an [Exception] to throw.
  final Object _result;

  @override
  Future<XFile> takePicture() async {
    final result = _result;
    if (result is XFile) return result;
    throw result;
  }
}

void main() {
  test('returns the captured file path', () async {
    final path = await captureStillImagePath(
      _CaptureController(XFile('/tmp/frame.jpg')),
    );
    expect(path, '/tmp/frame.jpg');
  });

  test('returns null instead of throwing when the controller was released '
      'mid-capture (e.g. app backgrounded) -- M0 closure regression', () async {
    final path = await captureStillImagePath(
      _CaptureController(
        CameraException(
          'Disposed CameraController',
          'takePicture() was called on a disposed CameraController',
        ),
      ),
    );
    expect(path, isNull);
  });
}
