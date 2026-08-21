/// A searchable location result. Decouples the app from the geocoding
/// provider's response shape (Google Places API (New) — see
/// ARCHITECTURE.md for why this replaced OpenStreetMap Nominatim).
class Place {
  const Place({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  /// Parses one entry from Places API (New) Text Search's `places` array.
  factory Place.fromGooglePlacesJson(Map<String, dynamic> json) {
    final displayName = json['displayName'] as Map<String, dynamic>?;
    final providedName = (displayName?['text'] as String?)?.trim();
    final address = (json['formattedAddress'] as String?) ?? '';
    final location = json['location'] as Map<String, dynamic>;

    final name = (providedName != null && providedName.isNotEmpty)
        ? providedName
        : (address.isNotEmpty
              ? address.split(',').first.trim()
              : 'Unknown place');

    return Place(
      name: name,
      address: address,
      latitude: (location['latitude'] as num).toDouble(),
      longitude: (location['longitude'] as num).toDouble(),
    );
  }

  final String name;
  final String address;
  final double latitude;
  final double longitude;
}
