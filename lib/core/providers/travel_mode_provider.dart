import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TravelMode { driving, walking, cycling }

/// Selected travel mode — cross-feature (home's selector writes it, the
/// route preview screen's selector and route calculation both read it).
/// Only [TravelMode.driving] produces a real route as of Phase 6; see
/// `route_provider.dart` and KNOWN_LIMITATIONS.md.
final travelModeProvider = NotifierProvider<TravelModeNotifier, TravelMode>(
  TravelModeNotifier.new,
);

class TravelModeNotifier extends Notifier<TravelMode> {
  @override
  TravelMode build() => TravelMode.driving;

  void select(TravelMode mode) => state = mode;
}
