import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the map should auto-center on new GPS fixes. Turns off the
/// moment the user manually pans/zooms/rotates the map (see
/// [AppMapController.userMovedMap]); the re-center button turns it back on.
/// Cross-feature: home's map and the turn-by-turn navigation screen
/// (Phase 7) both reuse this rather than each inventing their own
/// follow/re-center mechanism — see ARCHITECTURE.md.
final mapFollowProvider = NotifierProvider<MapFollowNotifier, bool>(
  MapFollowNotifier.new,
);

class MapFollowNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void enable() => state = true;

  void disable() => state = false;
}
