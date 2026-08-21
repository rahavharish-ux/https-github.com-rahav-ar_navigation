import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/place_model.dart';
import '../providers/search_provider.dart';
import 'search_message_view.dart';
import 'search_result_tile.dart';

class RecentSearchesList extends ConsumerWidget {
  const RecentSearchesList({super.key, required this.onSelect});

  final ValueChanged<Place> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentSearchesProvider);

    if (recent.isEmpty) {
      return const SearchMessageView(
        message: AppStrings.searchPrompt,
        icon: Icons.search,
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Text(
                AppStrings.recentSearchesTitle,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    ref.read(recentSearchesProvider.notifier).clear(),
                child: const Text(AppStrings.clearAll),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recent.length,
            itemBuilder: (context, index) => SearchResultTile(
              place: recent[index],
              leading: Icons.history,
              onTap: () => onSelect(recent[index]),
            ),
          ),
        ),
      ],
    );
  }
}
