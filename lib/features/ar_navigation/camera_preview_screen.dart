import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/common/loading_indicator.dart';

/// Real live camera feed (Phase 9) — no AR overlays yet, that's Phase 10.
/// Reachable only from the diagnostics screen for now: the home screen's
/// "AR Navigation" button stays disabled until there's an actual AR
/// experience behind it, so this doesn't overpromise what's built.
class CameraPreviewScreen extends ConsumerStatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  ConsumerState<CameraPreviewScreen> createState() =>
      _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends ConsumerState<CameraPreviewScreen> {
  @override
  void initState() {
    super.initState();
    // Riverpod forbids modifying provider state during a widget life-cycle
    // method (initState included) -- calling `start()` here directly threw
    // "Tried to modify a provider while the widget tree was building" as an
    // unhandled error inside the unawaited Future it returns, silently
    // aborting before it ever reached `listCameras()`/`initializeController()`
    // and leaving the screen stuck on "Starting the camera..." forever.
    // Found on a real device (Phase 13's real-device pass) -- this path had
    // never been exercised on real hardware before. Deferring with a
    // post-frame callback is Riverpod's own documented fix.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(cameraProvider.notifier).start();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraProvider);

    return PopScope(
      // Runs while the widget is still fully mounted, for every way this
      // screen closes (app bar back button, system back gesture, or a
      // programmatic pop) — same reasoning as `NavigationScreen`'s
      // `dispose()` comment: mutating provider state from `dispose()`
      // itself is unsafe.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) ref.read(cameraProvider.notifier).stop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.cameraPreviewTitle)),
        body: switch (state) {
          CameraInitial() || CameraRequesting() => const _StatusMessage(
            message: AppStrings.cameraStarting,
            child: LoadingIndicator(),
          ),
          CameraAvailable(:final controller) => _LivePreview(
            controller: controller,
          ),
          CameraUnavailable() => _StatusMessage(
            icon: Icons.no_photography_outlined,
            message: AppStrings.cameraUnavailable,
          ),
          CameraPermissionDenied() => _StatusMessage(
            icon: Icons.videocam_off_outlined,
            message: AppStrings.cameraPermissionDenied,
            onRetry: () => ref.read(cameraProvider.notifier).start(),
          ),
          CameraError() => _StatusMessage(
            icon: Icons.error_outline,
            message: AppStrings.cameraGenericError,
            onRetry: () => ref.read(cameraProvider.notifier).start(),
          ),
        },
      ),
    );
  }
}

class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            AppStrings.cameraNoOverlayNote,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({
    required this.message,
    this.icon,
    this.child,
    this.onRetry,
  });

  final String message;
  final IconData? icon;
  final Widget? child;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ?child,
            if (icon != null)
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(label: AppStrings.cameraTryAgain, onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}
