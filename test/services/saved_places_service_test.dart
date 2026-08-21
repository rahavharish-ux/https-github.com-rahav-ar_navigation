import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/models/place_model.dart';
import 'package:tn_ar_navigation/services/saved_places_service.dart';

/// Same "honest failure when not configured" pattern as
/// auth_service_test.dart — none of these touch `Supabase.instance`.
void main() {
  tearDown(dotenv.clean);

  const service = SavedPlacesService();
  const place = Place(
    name: 'Meenakshi Amman Temple',
    address: 'Madurai, Tamil Nadu',
    latitude: 9.9195,
    longitude: 78.1193,
  );

  test('list throws a real, honest SavedPlacesException when not '
      'configured', () async {
    await expectLater(service.list(), throwsA(isA<SavedPlacesException>()));
  });

  test('save throws a real, honest SavedPlacesException when not '
      'configured', () async {
    await expectLater(
      service.save(place),
      throwsA(isA<SavedPlacesException>()),
    );
  });

  test('remove throws a real, honest SavedPlacesException when not '
      'configured', () async {
    await expectLater(
      service.remove('some-id'),
      throwsA(isA<SavedPlacesException>()),
    );
  });
}
