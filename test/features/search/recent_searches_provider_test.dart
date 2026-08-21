import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/features/search/providers/search_provider.dart';
import 'package:tn_ar_navigation/models/place_model.dart';

Place _place(String name) => Place(
  name: name,
  address: '$name, Tamil Nadu',
  latitude: 11,
  longitude: 77,
);

void main() {
  test('add prepends new places and de-duplicates by address', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(recentSearchesProvider.notifier).add(_place('A'));
    container.read(recentSearchesProvider.notifier).add(_place('B'));
    container.read(recentSearchesProvider.notifier).add(_place('A'));

    expect(container.read(recentSearchesProvider).map((p) => p.name), [
      'A',
      'B',
    ]);
  });

  test('add caps the list at 8 items', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    for (var i = 0; i < 10; i++) {
      container.read(recentSearchesProvider.notifier).add(_place('Place $i'));
    }

    expect(container.read(recentSearchesProvider), hasLength(8));
  });

  test('clear empties the list', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(recentSearchesProvider.notifier).add(_place('A'));
    container.read(recentSearchesProvider.notifier).clear();

    expect(container.read(recentSearchesProvider), isEmpty);
  });
}
