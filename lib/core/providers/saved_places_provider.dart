import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/place_model.dart';
import '../../models/saved_place.dart';
import '../../services/saved_places_service.dart';

sealed class SavedPlacesState {
  const SavedPlacesState();
}

class SavedPlacesIdle extends SavedPlacesState {
  const SavedPlacesIdle();
}

class SavedPlacesLoading extends SavedPlacesState {
  const SavedPlacesLoading();
}

class SavedPlacesLoaded extends SavedPlacesState {
  const SavedPlacesLoaded(this.places);

  final List<SavedPlace> places;
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, same pattern as `LocationError`/`CameraError`.
class SavedPlacesFailed extends SavedPlacesState {
  const SavedPlacesFailed(this.message);

  final String message;
}

final savedPlacesProvider =
    NotifierProvider<SavedPlacesNotifier, SavedPlacesState>(
      SavedPlacesNotifier.new,
    );

/// Real saved-places list backed by Supabase (Phase 14), mirroring
/// `SearchState`'s shape. Not auto-loaded on app start — only when
/// `SavedPlacesScreen` actually needs it, same "load only when needed"
/// discipline the rest of this project follows.
class SavedPlacesNotifier extends Notifier<SavedPlacesState> {
  late final SavedPlacesService _service;

  @override
  SavedPlacesState build() {
    _service = const SavedPlacesService();
    return const SavedPlacesIdle();
  }

  Future<void> load() async {
    state = const SavedPlacesLoading();
    try {
      final places = await _service.list();
      state = SavedPlacesLoaded(places);
    } on SavedPlacesException catch (error) {
      state = SavedPlacesFailed(error.message);
    }
  }

  /// Returns whether the save actually succeeded — a real bug on a
  /// physical device (`RoutePreviewScreen` showing "Place saved." even
  /// when the save had failed) was caused by a caller not checking this,
  /// since this previously returned `void`.
  Future<bool> save(Place place) async {
    try {
      await _service.save(place);
      await load();
      return true;
    } on SavedPlacesException catch (error) {
      state = SavedPlacesFailed(error.message);
      return false;
    }
  }

  Future<void> remove(String id) async {
    try {
      await _service.remove(id);
      await load();
    } on SavedPlacesException catch (error) {
      state = SavedPlacesFailed(error.message);
    }
  }
}
