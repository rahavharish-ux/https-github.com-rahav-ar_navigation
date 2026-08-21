import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/models/place_model.dart';

void main() {
  test('fromGooglePlacesJson uses the provided displayName when present', () {
    final place = Place.fromGooglePlacesJson({
      'displayName': {'text': 'Karpagam Academy', 'languageCode': 'en'},
      'formattedAddress':
          'Karpagam Academy, Pollachi Road, Coimbatore, Tamil Nadu, India',
      'location': {'latitude': 10.9601, 'longitude': 76.9382},
    });

    expect(place.name, 'Karpagam Academy');
    expect(
      place.address,
      'Karpagam Academy, Pollachi Road, Coimbatore, Tamil Nadu, India',
    );
    expect(place.latitude, 10.9601);
    expect(place.longitude, 76.9382);
  });

  test('fromGooglePlacesJson falls back to the first address segment when '
      'displayName is missing', () {
    final place = Place.fromGooglePlacesJson({
      'formattedAddress': 'Gandhipuram, Coimbatore, Tamil Nadu, India',
      'location': {'latitude': 11.0168, 'longitude': 76.9558},
    });

    expect(place.name, 'Gandhipuram');
  });

  test('fromGooglePlacesJson falls back to "Unknown place" when both '
      'displayName and formattedAddress are missing', () {
    final place = Place.fromGooglePlacesJson({
      'location': {'latitude': 11.0168, 'longitude': 76.9558},
    });

    expect(place.name, 'Unknown place');
  });
}
