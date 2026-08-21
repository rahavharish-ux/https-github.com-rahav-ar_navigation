import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/providers/destination_provider.dart';
import '../../../core/providers/map_follow_provider.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../search/search_screen.dart';

/// Shows the search prompt, or the selected destination once one exists
/// (Phase 5). Tapping opens real search; the "x" clears the destination.
class DestinationSearchCard extends ConsumerWidget {
  const DestinationSearchCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final destination = ref.watch(selectedDestinationProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SearchScreen())),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(
              destination == null ? Icons.search : Icons.place,
              color: destination == null
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.error,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                destination?.name ?? AppStrings.searchHint,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: destination == null
                      ? colorScheme.onSurfaceVariant
                      : null,
                ),
              ),
            ),
            if (destination != null)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  ref.read(selectedDestinationProvider.notifier).clear();
                  ref.read(mapFollowProvider.notifier).enable();
                },
              ),
          ],
        ),
      ),
    );
  }
}
