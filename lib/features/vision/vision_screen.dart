import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/providers/vision_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/common/loading_indicator.dart';

/// Real on-device computer vision (Phase 13): street-sign text recognition
/// and generic scene labeling, run against a single captured camera frame —
/// not a continuous live scanner, see `vision_provider.dart` for why.
/// Reachable only from the diagnostics screen for now — the same "prove it
/// via diagnostics before it's a first-class user-facing entry point" path
/// every sensor/camera phase in this project has used.
class VisionScreen extends ConsumerStatefulWidget {
  const VisionScreen({super.key});

  @override
  ConsumerState<VisionScreen> createState() => _VisionScreenState();
}

class _VisionScreenState extends ConsumerState<VisionScreen> {
  @override
  void initState() {
    super.initState();
    // Same fix as `CameraPreviewScreen.initState` -- see its doc comment.
    // Riverpod forbids modifying provider state synchronously from
    // initState; deferring with a post-frame callback is its own
    // documented fix.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(cameraProvider.notifier).start();
    });
  }

  Future<void> _captureAndAnalyze(
    Future<void> Function(String path) analyze,
  ) async {
    final cameraState = ref.read(cameraProvider);
    if (cameraState is! CameraAvailable) return;
    final photo = await cameraState.controller.takePicture();
    if (!mounted) return;
    await analyze(photo.path);
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = ref.watch(cameraProvider);
    final visionState = ref.watch(visionProvider);

    return PopScope(
      // Same reasoning as `CameraPreviewScreen`/`NavigationScreen`: mutating
      // provider state from `dispose()` itself is unsafe, so this stops the
      // camera while the widget is still fully mounted instead.
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) ref.read(cameraProvider.notifier).stop();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text(AppStrings.visionTitle)),
        body: switch (cameraState) {
          CameraInitial() || CameraRequesting() => const _CenteredMessage(
            message: AppStrings.cameraStarting,
            child: LoadingIndicator(),
          ),
          CameraUnavailable() => const _CenteredMessage(
            icon: Icons.no_photography_outlined,
            message: AppStrings.cameraUnavailable,
          ),
          CameraPermissionDenied() => _CenteredMessage(
            icon: Icons.videocam_off_outlined,
            message: AppStrings.cameraPermissionDenied,
            onRetry: () => ref.read(cameraProvider.notifier).start(),
          ),
          CameraError() => _CenteredMessage(
            icon: Icons.error_outline,
            message: AppStrings.cameraGenericError,
            onRetry: () => ref.read(cameraProvider.notifier).start(),
          ),
          CameraAvailable(:final controller) => Column(
            children: [
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: CameraPreview(controller),
                  ),
                ),
              ),
              _VisionControls(
                busy: visionState is VisionProcessing,
                onScanText: () => _captureAndAnalyze(
                  (path) => ref.read(visionProvider.notifier).scanText(path),
                ),
                onLabelScene: () => _captureAndAnalyze(
                  (path) => ref.read(visionProvider.notifier).labelScene(path),
                ),
              ),
              _VisionResultPanel(state: visionState),
            ],
          ),
        },
      ),
    );
  }
}

class _VisionControls extends StatelessWidget {
  const _VisionControls({
    required this.busy,
    required this.onScanText,
    required this.onLabelScene,
  });

  final bool busy;
  final VoidCallback onScanText;
  final VoidCallback onLabelScene;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: AppStrings.visionScanText,
              onPressed: busy ? null : onScanText,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              label: AppStrings.visionLabelScene,
              variant: AppButtonVariant.secondary,
              onPressed: busy ? null : onLabelScene,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisionResultPanel extends StatelessWidget {
  const _VisionResultPanel({required this.state});

  final VisionState state;

  @override
  Widget build(BuildContext context) {
    final mutedStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 220),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: switch (state) {
          VisionIdle() => Text(
            AppStrings.visionIdlePrompt,
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
          VisionProcessing() => const Center(child: LoadingIndicator()),
          VisionUnavailable() => Text(
            AppStrings.visionUnavailable,
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
          VisionFailed() => Text(
            AppStrings.visionFailedMessage,
            textAlign: TextAlign.center,
            style: mutedStyle,
          ),
          VisionTextResult(:final result) =>
            result.hasText
                ? ListView(
                    shrinkWrap: true,
                    children: [for (final line in result.lines) Text(line)],
                  )
                : Text(
                    AppStrings.visionNoTextFound,
                    textAlign: TextAlign.center,
                    style: mutedStyle,
                  ),
          VisionLabelResult(:final labels) =>
            labels.isEmpty
                ? Text(
                    AppStrings.visionNoLabelsFound,
                    textAlign: TextAlign.center,
                    style: mutedStyle,
                  )
                : ListView(
                    shrinkWrap: true,
                    children: [
                      for (final label in labels)
                        Text('${label.label} (${label.confidencePercent})'),
                    ],
                  ),
        },
      ),
    );
  }
}

class _CenteredMessage extends StatelessWidget {
  const _CenteredMessage({
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
