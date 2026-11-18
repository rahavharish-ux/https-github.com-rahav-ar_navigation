import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/camera_provider.dart';

/// Forwards app lifecycle changes to [CameraNotifier] for as long as a
/// screen showing the camera is mounted (Phase 2 M0). Shared by
/// `CameraPreviewScreen` and `VisionScreen` so both release the camera when
/// the app is backgrounded and re-open it on return.
///
/// Usage:
/// ```dart
/// class _S extends ConsumerState<W>
///     with WidgetsBindingObserver, CameraLifecycleBinding<W> {}
/// ```
mixin CameraLifecycleBinding<T extends ConsumerStatefulWidget>
    on ConsumerState<T>, WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    ref.read(cameraProvider.notifier).handleAppLifecycleState(state);
  }
}
