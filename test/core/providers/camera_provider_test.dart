import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/camera_provider.dart';
import 'package:tn_ar_navigation/core/utils/camera_lifecycle.dart';
import 'package:tn_ar_navigation/services/camera_service.dart';

const _backCamera = CameraDescription(
  name: '0',
  lensDirection: CameraLensDirection.back,
  sensorOrientation: 90,
);

/// Never touches the camera platform channel: the base constructor only
/// stores its arguments, and [dispose] is replaced with a counter.
class _FakeCameraController extends CameraController {
  _FakeCameraController()
    : super(_backCamera, ResolutionPreset.low, enableAudio: false);

  int disposeCalls = 0;

  // The real dispose() calls into the camera platform channel, which has no
  // implementation in unit tests; counting calls is all these tests need.
  @override
  // ignore: must_call_super
  Future<void> dispose() async => disposeCalls++;
}

class _FakeCameraService extends CameraService {
  _FakeCameraService();

  final List<_FakeCameraController> controllers = [];
  int listCalls = 0;

  /// When set, `initializeController` waits for it — lets a test act while
  /// a start() is still in flight.
  Completer<void>? initGate;

  @override
  Future<List<CameraDescription>> listCameras() async {
    listCalls++;
    return const [_backCamera];
  }

  @override
  Future<CameraController> initializeController(
    CameraDescription description,
  ) async {
    final gate = initGate;
    if (gate != null) await gate.future;
    final controller = _FakeCameraController();
    controllers.add(controller);
    return controller;
  }
}

class _TestableCameraNotifier extends CameraNotifier {
  _TestableCameraNotifier(this._service);

  final CameraService _service;

  @override
  CameraService createService() => _service;
}

void main() {
  late _FakeCameraService service;
  late ProviderContainer container;

  setUp(() {
    service = _FakeCameraService();
    container = ProviderContainer(
      overrides: [
        cameraProvider.overrideWith(() => _TestableCameraNotifier(service)),
      ],
    );
    addTearDown(container.dispose);
  });

  CameraNotifier notifier() => container.read(cameraProvider.notifier);

  test('start() opens the preferred camera', () async {
    await notifier().start();

    final state = container.read(cameraProvider);
    expect(state, isA<CameraAvailable>());
    expect(
      (state as CameraAvailable).controller,
      same(service.controllers.single),
    );
  });

  test('stop() while start() is still initializing releases the controller '
      'it produces and stays stopped (M0 regression)', () async {
    service.initGate = Completer<void>();
    final starting = notifier().start();
    expect(container.read(cameraProvider), isA<CameraRequesting>());
    await Future<void>.delayed(Duration.zero); // now inside initialize

    notifier().stop();
    service.initGate!.complete();
    await starting;

    expect(container.read(cameraProvider), isA<CameraInitial>());
    expect(service.controllers.single.disposeCalls, 1);
  });

  test('disposing the provider while start() is initializing does not '
      'throw, and the late controller is released (M0 regression)', () async {
    service.initGate = Completer<void>();
    final starting = notifier().start();
    await Future<void>.delayed(Duration.zero); // now inside initialize

    container.dispose();
    service.initGate!.complete();
    await starting;

    expect(service.controllers.single.disposeCalls, 1);
  });

  test('stop() before the camera list even arrives never opens a '
      'camera', () async {
    final starting = notifier().start();
    notifier().stop();
    await starting;

    expect(service.controllers, isEmpty);
    expect(container.read(cameraProvider), isA<CameraInitial>());
  });

  group('app lifecycle (M0)', () {
    test('backgrounding releases an open camera', () async {
      await notifier().start();
      final first = service.controllers.single;

      notifier().handleAppLifecycleState(AppLifecycleState.inactive);

      expect(first.disposeCalls, 1);
      expect(container.read(cameraProvider), isA<CameraInitial>());
    });

    test('the further inactive -> hidden -> paused steps do not release '
        'twice', () async {
      await notifier().start();
      final first = service.controllers.single;

      notifier()
        ..handleAppLifecycleState(AppLifecycleState.inactive)
        ..handleAppLifecycleState(AppLifecycleState.hidden)
        ..handleAppLifecycleState(AppLifecycleState.paused);

      expect(first.disposeCalls, 1);
    });

    test('returning to the foreground re-opens a camera released by '
        'backgrounding', () async {
      await notifier().start();
      notifier()
        ..handleAppLifecycleState(AppLifecycleState.inactive)
        ..handleAppLifecycleState(AppLifecycleState.paused)
        ..handleAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(service.controllers, hasLength(2));
      final state = container.read(cameraProvider);
      expect(state, isA<CameraAvailable>());
      expect(
        (state as CameraAvailable).controller,
        same(service.controllers.last),
      );
    });

    test('a resume with no prior release (e.g. after the permission '
        'dialog) does not open the camera again', () async {
      await notifier().start();
      notifier().handleAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(service.listCalls, 1);
      expect(service.controllers, hasLength(1));
    });

    test('lifecycle changes before the camera was ever started do '
        'nothing', () async {
      notifier()
        ..handleAppLifecycleState(AppLifecycleState.inactive)
        ..handleAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(service.listCalls, 0);
      expect(container.read(cameraProvider), isA<CameraInitial>());
    });

    test('a camera stopped by the user while backgrounded is not re-opened '
        'on resume', () async {
      await notifier().start();
      notifier()
        ..handleAppLifecycleState(AppLifecycleState.inactive)
        ..stop()
        ..handleAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(service.listCalls, 1);
      expect(container.read(cameraProvider), isA<CameraInitial>());
    });

    test('backgrounding while start() is still initializing (permission '
        'dialog) does not cancel the start', () async {
      service.initGate = Completer<void>();
      final starting = notifier().start();
      notifier().handleAppLifecycleState(AppLifecycleState.inactive);
      notifier().handleAppLifecycleState(AppLifecycleState.resumed);
      service.initGate!.complete();
      await starting;

      expect(container.read(cameraProvider), isA<CameraAvailable>());
      expect(service.controllers.single.disposeCalls, 0);
    });
  });

  group('backgrounded while the camera is still starting (M0 closure '
      'regression)', () {
    test('a camera that finishes initializing while the app is in the '
        'background is released, then re-opened on resume', () async {
      service.initGate = Completer<void>();
      final starting = notifier().start();
      await Future<void>.delayed(Duration.zero); // now inside initialize

      // Real backgrounding (not just the permission dialog's `inactive`).
      notifier()
        ..handleAppLifecycleState(AppLifecycleState.inactive)
        ..handleAppLifecycleState(AppLifecycleState.hidden)
        ..handleAppLifecycleState(AppLifecycleState.paused);
      service.initGate!.complete();
      await starting;

      expect(service.controllers.single.disposeCalls, 1);
      expect(container.read(cameraProvider), isA<CameraInitial>());

      service.initGate = null;
      notifier()
        ..handleAppLifecycleState(AppLifecycleState.hidden)
        ..handleAppLifecycleState(AppLifecycleState.inactive)
        ..handleAppLifecycleState(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(service.controllers, hasLength(2));
      expect(container.read(cameraProvider), isA<CameraAvailable>());
    });
  });

  group('cameraLifecycleActionFor', () {
    test('releases an open camera in every non-resumed state', () {
      for (final state in [
        AppLifecycleState.inactive,
        AppLifecycleState.hidden,
        AppLifecycleState.paused,
        AppLifecycleState.detached,
      ]) {
        expect(
          cameraLifecycleActionFor(
            state,
            hasOpenCamera: true,
            releasedForLifecycle: false,
          ),
          CameraLifecycleAction.release,
          reason: '$state',
        );
        expect(
          cameraLifecycleActionFor(
            state,
            hasOpenCamera: false,
            releasedForLifecycle: true,
          ),
          CameraLifecycleAction.none,
          reason: '$state with nothing open',
        );
      }
    });

    test('reacquires on resume only after a lifecycle release', () {
      expect(
        cameraLifecycleActionFor(
          AppLifecycleState.resumed,
          hasOpenCamera: false,
          releasedForLifecycle: true,
        ),
        CameraLifecycleAction.reacquire,
      );
      expect(
        cameraLifecycleActionFor(
          AppLifecycleState.resumed,
          hasOpenCamera: true,
          releasedForLifecycle: false,
        ),
        CameraLifecycleAction.none,
      );
    });
  });
}
