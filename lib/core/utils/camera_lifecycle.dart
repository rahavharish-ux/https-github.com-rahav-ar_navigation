import 'package:flutter/widgets.dart';

/// What [CameraNotifier] should do with the camera when the app's lifecycle
/// state changes.
enum CameraLifecycleAction {
  /// Nothing to do.
  none,

  /// Release the camera because the app is leaving the foreground.
  release,

  /// Re-open the camera that a previous [release] closed.
  reacquire,
}

/// Pure lifecycle → camera decision (Phase 2 M0), kept out of the notifier
/// so it's testable without a device, same pattern as
/// `camera_selection.dart`.
///
/// The `camera` plugin's own guidance is to dispose the controller when the
/// app becomes `inactive` and re-create it on `resumed`; a controller kept
/// across backgrounding can come back with a dead preview, and holding the
/// camera while backgrounded blocks other apps from using it.
///
/// - Any non-resumed state releases the camera, but only if one is open. A
///   camera that is merely *starting* is left alone: Android's camera
///   permission dialog itself moves the app to `inactive`, and releasing
///   then would cancel the very start that triggered the dialog.
/// - `resumed` re-opens the camera only if it was released by this
///   lifecycle logic — never one the user stopped by leaving the screen.
CameraLifecycleAction cameraLifecycleActionFor(
  AppLifecycleState state, {
  required bool hasOpenCamera,
  required bool releasedForLifecycle,
}) => switch (state) {
  AppLifecycleState.resumed =>
    releasedForLifecycle
        ? CameraLifecycleAction.reacquire
        : CameraLifecycleAction.none,
  AppLifecycleState.inactive ||
  AppLifecycleState.hidden ||
  AppLifecycleState.paused ||
  AppLifecycleState.detached =>
    hasOpenCamera ? CameraLifecycleAction.release : CameraLifecycleAction.none,
};
