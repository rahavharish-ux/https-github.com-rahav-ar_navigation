import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/map_follow_provider.dart';

/// Appears only after the user pans away from their location (follow mode
/// off) — tapping it hands control back via [onPressed]. Shared by the home
/// screen and the turn-by-turn navigation screen (Phase 7).
class RecenterButton extends ConsumerWidget {
  const RecenterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final following = ref.watch(mapFollowProvider);
    if (following) return const SizedBox.shrink();

    return FloatingActionButton.small(
      heroTag: 'recenter',
      tooltip: 'Re-center',
      onPressed: onPressed,
      child: const Icon(Icons.center_focus_strong),
    );
  }
}
