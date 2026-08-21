import 'package:latlong2/latlong.dart';

import '../../models/location_model.dart';

/// Bridges [AppLocation] (provider-agnostic) to [LatLng] (the map layer's
/// shared coordinate type) without making the location model depend on a
/// map package.
extension AppLocationLatLng on AppLocation {
  LatLng toLatLng() => LatLng(latitude, longitude);
}
