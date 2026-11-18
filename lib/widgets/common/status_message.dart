import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/theme/app_spacing.dart';
import '../buttons/app_button.dart';

/// Centered status message with an optional icon, leading widget (e.g. a
/// spinner) and "Try again" action. Previously duplicated verbatim as
/// `_StatusMessage` in `CameraPreviewScreen` and `_CenteredMessage` in
/// `VisionScreen` (Phase 2 M0 audit).
class StatusMessage extends StatelessWidget {
  const StatusMessage({
    super.key,
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
