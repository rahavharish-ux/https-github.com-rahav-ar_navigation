import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/features/search/providers/search_provider.dart';
import 'package:tn_ar_navigation/models/place_model.dart';
import 'package:tn_ar_navigation/services/geocoding_service.dart';

/// Returns [_results] without a real network call, so `fakeAsync` can
/// deterministically control the debounce timing around it — same
/// "override just the notifier's service, keep the real state machine"
/// approach `LocationNotifier.createService` uses.
class _FakeGeocodingService extends GeocodingService {
  _FakeGeocodingService(this._results);

  final List<Place> _results;

  /// A real (fake-clock-controlled) delay, not an immediately-resolved
  /// Future — otherwise `fakeAsync.elapse()` firing the debounce timer
  /// would also resolve this in the same pass, making `SearchLoading`
  /// unobservable as an intermediate state.
  @override
  Future<List<Place>> search(String query, {int limit = 8}) {
    return Future<List<Place>>.delayed(
      const Duration(milliseconds: 50),
      () => _results,
    );
  }

  @override
  void dispose() {}
}

class _TestableSearchNotifier extends SearchNotifier {
  _TestableSearchNotifier(this._service);

  final GeocodingService _service;

  @override
  GeocodingService createService() => _service;
}

const _place = Place(
  name: 'Meenakshi Amman Temple',
  address: 'Madurai, Tamil Nadu',
  latitude: 9.9195,
  longitude: 78.1193,
);

void main() {
  /// Timing-precise coverage of the real debounce → loading → results
  /// sequence (Phase 15) — previously only covered by a non-timing-precise
  /// idle/failure-path widget test (see KNOWN_LIMITATIONS.md).
  test('queryChanged debounces for 400ms before searching, then transitions '
      'Idle -> Loading -> Results in order', () {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [
          searchProvider.overrideWith(
            () => _TestableSearchNotifier(_FakeGeocodingService([_place])),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(searchProvider.notifier);

      notifier.queryChanged('Meenakshi');
      expect(container.read(searchProvider), isA<SearchIdle>());

      async.elapse(const Duration(milliseconds: 399));
      expect(
        container.read(searchProvider),
        isA<SearchIdle>(),
        reason: 'still within the debounce window',
      );

      async.elapse(const Duration(milliseconds: 1));
      expect(container.read(searchProvider), isA<SearchLoading>());

      async.elapse(const Duration(milliseconds: 50));
      expect(container.read(searchProvider), isA<SearchResults>());
      expect((container.read(searchProvider) as SearchResults).results, [
        _place,
      ]);
    });
  });

  test('a second query within the debounce window resets the timer -- only '
      'the final query is searched', () {
    fakeAsync((async) {
      final service = _FakeGeocodingService([_place]);
      final container = ProviderContainer(
        overrides: [
          searchProvider.overrideWith(() => _TestableSearchNotifier(service)),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(searchProvider.notifier);

      notifier.queryChanged('Meen');
      async.elapse(const Duration(milliseconds: 200));
      notifier.queryChanged('Meenakshi');
      async.elapse(const Duration(milliseconds: 200));
      // The first query's debounce would have fired by now (400ms
      // since it started) if the timer hadn't been reset.
      expect(container.read(searchProvider), isA<SearchIdle>());

      async.elapse(const Duration(milliseconds: 200));
      async.elapse(const Duration(milliseconds: 50));
      expect(container.read(searchProvider), isA<SearchResults>());
    });
  });

  test('a query below the minimum length resets to Idle without a timer', () {
    fakeAsync((async) {
      final container = ProviderContainer(
        overrides: [
          searchProvider.overrideWith(
            () => _TestableSearchNotifier(_FakeGeocodingService([_place])),
          ),
        ],
      );
      addTearDown(container.dispose);

      container.read(searchProvider.notifier).queryChanged('M');
      async.elapse(const Duration(seconds: 1));

      expect(container.read(searchProvider), isA<SearchIdle>());
    });
  });
}
