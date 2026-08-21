import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/location_provider.dart';
import '../../../core/providers/map_follow_provider.dart';

/// Real permission + GPS request, wired to [locationProvider]. Feedback
/// for denied/disabled/error states is shown by the parent screen via
/// `ref.listen`, so this widget only needs to trigger the request and
/// reflect the in-flight state. Also re-enables map follow mode, since
/// "locate me" implies "show and center me on the map".
class LocateMeButton extends ConsumerWidget {
  const LocateMeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationProvider);
    final isRequesting = state is LocationRequesting;

    return FloatingActionButton.small(
      heroTag: 'locateMe',
      onPressed: isRequesting
          ? null
          : () {
              ref.read(mapFollowProvider.notifier).enable();
              ref.read(locationProvider.notifier).requestAndStart();
            },
      child: isRequesting
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.my_location),
    );
  }
}
