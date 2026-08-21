import 'package:latlong2/latlong.dart';

import '../../models/place_model.dart';

/// Bridges [Place] (provider-agnostic) to [LatLng] (the map layer's
/// shared coordinate type) without making the place model depend on a
/// map package. See also `location_latlng.dart`.
extension PlaceLatLng on Place {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
