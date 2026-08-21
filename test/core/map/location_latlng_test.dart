import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/map/location_latlng.dart';
import 'package:tn_ar_navigation/models/location_model.dart';

void main() {
  test('toLatLng carries latitude/longitude through unchanged', () {
    final location = AppLocation(
      latitude: 11.0168,
      longitude: 76.9558,
      accuracyMeters: 10,
      speedMetersPerSecond: 0,
      headingDegrees: 0,
      timestamp: DateTime(2026, 1, 1),
    );

    final latLng = location.toLatLng();

    expect(latLng.latitude, 11.0168);
    expect(latLng.longitude, 76.9558);
  });
}
