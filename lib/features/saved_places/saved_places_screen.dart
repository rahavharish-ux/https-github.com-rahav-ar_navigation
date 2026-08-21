import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/saved_places_provider.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/common/loading_indicator.dart';

/// Real saved-places list backed by Supabase (Phase 14). Reachable from
/// `AccountScreen` and from the home screen's "Saved" quick action (once
/// signed in — see `QuickActionRow`).
class SavedPlacesScreen extends ConsumerStatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    // Deferred — see Phase 13's real-device bug in
    // camera_preview_screen.dart for why calling a notifier directly from
    // initState is unsafe with Riverpod.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(savedPlacesProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedPlacesProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.savedPlacesTitle)),
      body: switch (state) {
        SavedPlacesIdle() ||
        SavedPlacesLoading() => const Center(child: LoadingIndicator()),
        SavedPlacesFailed() => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              AppStrings.savedPlacesFailedMessage,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SavedPlacesLoaded(:final places) =>
          places.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      AppStrings.savedPlacesEmpty,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: places.length,
                  itemBuilder: (context, index) {
                    final saved = places[index];
                    return ListTile(
                      leading: const Icon(Icons.bookmark),
                      title: Text(saved.place.name),
                      subtitle: saved.place.address.isEmpty
                          ? null
                          : Text(
                              saved.place.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                      trailing: IconButton(
                        tooltip: AppStrings.removeSavedPlace,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => ref
                            .read(savedPlacesProvider.notifier)
                            .remove(saved.id),
                      ),
                    );
                  },
                ),
      },
    );
  }
}
