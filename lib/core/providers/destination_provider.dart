import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/place_model.dart';

/// The user's currently selected destination, if any. Read by the home
/// screen's map (to place a marker and fit both points in view) and
/// written by the search screen. Real routing/ETA to this destination
/// arrives in Phase 6 — selecting a place here does not calculate a route.
final selectedDestinationProvider =
    NotifierProvider<SelectedDestinationNotifier, Place?>(
      SelectedDestinationNotifier.new,
    );

class SelectedDestinationNotifier extends Notifier<Place?> {
  @override
  Place? build() => null;

  void select(Place place) => state = place;

  void clear() => state = null;
}
