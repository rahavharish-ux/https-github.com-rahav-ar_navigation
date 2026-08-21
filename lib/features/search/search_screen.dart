import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/destination_provider.dart';
import '../../models/place_model.dart';
import '../../widgets/common/loading_indicator.dart';
import 'providers/search_provider.dart';
import 'widgets/recent_searches_list.dart';
import 'widgets/search_message_view.dart';
import 'widgets/search_result_tile.dart';

/// Search doesn't calculate a route or show distance/ETA to the picked
/// place — that needs real routing data, which arrives in Phase 6.
/// Selecting a result here just sets the destination and returns to the
/// map, where it's shown as a real marker.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(Place place) {
    // Real bug found on a physical device: `selectedDestinationProvider`'s
    // listener in HomeScreen (set up via `ref.listen`) fires synchronously
    // from the moment `.select(place)` below runs, and pushes
    // RoutePreviewScreen right then and there -- while this screen is
    // still the top route. If we then popped *this* screen, that pop()
    // call would remove whatever the Navigator's new top route is (the
    // just-pushed RoutePreviewScreen), not SearchScreen, so
    // RoutePreviewScreen would open and immediately close again.
    // Popping first, before the provider changes, avoids the race
    // entirely: HomeScreen's listener then pushes onto a Navigator whose
    // top is already back to Home.
    Navigator.of(context).pop();
    ref.read(selectedDestinationProvider.notifier).select(place);
    ref.read(recentSearchesProvider.notifier).add(place);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
          ),
          onChanged: (value) =>
              ref.read(searchProvider.notifier).queryChanged(value),
        ),
      ),
      body: switch (state) {
        SearchIdle() => RecentSearchesList(onSelect: _select),
        SearchLoading() => const Center(child: LoadingIndicator()),
        SearchNoResults() => const SearchMessageView(
          message: AppStrings.searchNoResults,
          icon: Icons.search_off,
        ),
        SearchFailed() => const SearchMessageView(
          message: AppStrings.searchFailedMessage,
          icon: Icons.wifi_off,
        ),
        SearchResults(:final results) => ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) => SearchResultTile(
            place: results[index],
            onTap: () => _select(results[index]),
          ),
        ),
      },
    );
  }
}
