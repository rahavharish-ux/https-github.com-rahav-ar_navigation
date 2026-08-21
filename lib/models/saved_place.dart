import 'place_model.dart';

/// One row from the real `saved_places` table (Phase 14, Supabase) —
/// wraps the existing `Place` (Phase 5) plus the row's own id/timestamp,
/// rather than duplicating name/address/lat/lng fields.
class SavedPlace {
  const SavedPlace({
    required this.id,
    required this.place,
    required this.createdAt,
  });

  final String id;
  final Place place;
  final DateTime createdAt;

  factory SavedPlace.fromRow(Map<String, dynamic> row) {
    return SavedPlace(
      id: row['id'] as String,
      place: Place(
        name: row['name'] as String,
        address: (row['address'] as String?) ?? '',
        latitude: (row['latitude'] as num).toDouble(),
        longitude: (row['longitude'] as num).toDouble(),
      ),
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
