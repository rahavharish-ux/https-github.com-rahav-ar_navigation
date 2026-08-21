import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/travel_mode_provider.dart';

/// Real, working UI state — used on both the home dashboard and the route
/// preview screen (Phase 6), where selecting a mode triggers a real route
/// request for Driving and an honest "not available" message otherwise.
class TravelModeSelector extends ConsumerWidget {
  const TravelModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(travelModeProvider);

    return SegmentedButton<TravelMode>(
      segments: const [
        ButtonSegment(
          value: TravelMode.driving,
          icon: Icon(Icons.directions_car_outlined),
          label: Text('Driving'),
        ),
        ButtonSegment(
          value: TravelMode.walking,
          icon: Icon(Icons.directions_walk_outlined),
          label: Text('Walking'),
        ),
        ButtonSegment(
          value: TravelMode.cycling,
          icon: Icon(Icons.directions_bike_outlined),
          label: Text('Cycling'),
        ),
      ],
      selected: {selected},
      onSelectionChanged: (modes) =>
          ref.read(travelModeProvider.notifier).select(modes.first),
      showSelectedIcon: false,
    );
  }
}
