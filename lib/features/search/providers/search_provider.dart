import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../../../models/place_model.dart';
import '../../../services/geocoding_service.dart';

sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchResults extends SearchState {
  const SearchResults(this.results);

  final List<Place> results;
}

class SearchNoResults extends SearchState {
  const SearchNoResults();
}

class SearchFailed extends SearchState {
  const SearchFailed();
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

/// Debounces user input before hitting the geocoding API — a real
/// throttle, not decoration, per the project's "debounce search
/// requests" performance requirement.
class SearchNotifier extends Notifier<SearchState> {
  static const _debounce = Duration(milliseconds: 400);
  static const _minQueryLength = 2;

  late final GeocodingService _service;
  Timer? _debounceTimer;

  @override
  SearchState build() {
    _service = createService();
    ref.onDispose(() {
      _debounceTimer?.cancel();
      _service.dispose();
    });
    return const SearchIdle();
  }

  /// Overridden in tests to inject a fake `GeocodingService` (Phase 15) —
  /// lets a test exercise this notifier's real debounce/loading/results
  /// timing (via `fakeAsync`) without a real network call, rather than
  /// replacing the whole notifier with a fixed-state stand-in.
  @visibleForTesting
  GeocodingService createService() => GeocodingService();

  void queryChanged(String query) {
    _debounceTimer?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < _minQueryLength) {
      state = const SearchIdle();
      return;
    }
    _debounceTimer = Timer(_debounce, () => _search(trimmed));
  }

  Future<void> _search(String query) async {
    state = const SearchLoading();
    try {
      final results = await _service.search(query);
      state = results.isEmpty
          ? const SearchNoResults()
          : SearchResults(results);
    } catch (_) {
      state = const SearchFailed();
    }
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<Place>>(
      RecentSearchesNotifier.new,
    );

/// Session-only recent-search list (lost on app restart). Durable,
/// cross-session history is a Phase 14 (backend/local storage) decision —
/// not added prematurely here.
class RecentSearchesNotifier extends Notifier<List<Place>> {
  static const _maxItems = 8;

  @override
  List<Place> build() => const [];

  void add(Place place) {
    final withoutDuplicate = state
        .where((p) => p.address != place.address)
        .toList();
    state = [place, ...withoutDuplicate].take(_maxItems).toList();
  }

  void removeAt(int index) {
    state = [...state]..removeAt(index);
  }

  void clear() => state = const [];
}
