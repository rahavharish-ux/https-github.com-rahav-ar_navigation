import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/saved_places_provider.dart';
import 'package:tn_ar_navigation/models/place_model.dart';

void main() {
  tearDown(dotenv.clean);

  const place = Place(
    name: 'Meenakshi Amman Temple',
    address: 'Madurai, Tamil Nadu',
    latitude: 9.9195,
    longitude: 78.1193,
  );

  test('starts idle, not auto-loaded', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(savedPlacesProvider), isA<SavedPlacesIdle>());
  });

  test('load surfaces a real SavedPlacesFailed when not configured, never '
      'throws', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(savedPlacesProvider.notifier).load();

    expect(container.read(savedPlacesProvider), isA<SavedPlacesFailed>());
  });

  test('save surfaces a real SavedPlacesFailed when not configured, never '
      'throws', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(savedPlacesProvider.notifier).save(place);

    expect(container.read(savedPlacesProvider), isA<SavedPlacesFailed>());
  });

  test('save returns false on failure -- a real bug on a physical device '
      '(RoutePreviewScreen showing "Place saved." unconditionally) was '
      'caused by a caller not being able to check this, since save() used '
      'to return void', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container
        .read(savedPlacesProvider.notifier)
        .save(place);

    expect(result, isFalse);
  });

  test('remove surfaces a real SavedPlacesFailed when not configured, '
      'never throws', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(savedPlacesProvider.notifier).remove('some-id');

    expect(container.read(savedPlacesProvider), isA<SavedPlacesFailed>());
  });
}
