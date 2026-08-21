import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/auth_provider.dart';
import '../../auth/auth_screen.dart';
import '../../saved_places/saved_places_screen.dart';

/// Home/Work/Recent/Saved shortcuts. Home/Work (a labeled single saved
/// place each) and Recent (search history) still don't exist — tapping
/// those surfaces that honestly. "Saved" is real (Phase 14): it opens the
/// real saved-places list once signed in, or sign-in first otherwise —
/// see ARCHITECTURE.md's Phase 14 note for why Home/Work/Recent weren't
/// built the same round.
class QuickActionRow extends ConsumerWidget {
  const QuickActionRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void openSaved() {
      final authState = ref.read(authProvider);
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => authState is AppAuthenticated
              ? const SavedPlacesScreen()
              : const AuthScreen(),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const _QuickAction(
          icon: Icons.home_outlined,
          label: AppStrings.quickActionHome,
        ),
        const _QuickAction(
          icon: Icons.work_outline,
          label: AppStrings.quickActionWork,
        ),
        const _QuickAction(
          icon: Icons.history,
          label: AppStrings.quickActionRecent,
        ),
        _QuickAction(
          icon: Icons.bookmark_border,
          label: AppStrings.quickActionSaved,
          onTap: openSaved,
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap:
          onTap ??
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(AppStrings.comingSoonQuickAction)),
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}
