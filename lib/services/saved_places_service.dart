import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../models/place_model.dart';
import '../models/saved_place.dart';

class SavedPlacesException implements Exception {
  const SavedPlacesException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin, swappable wrapper over the real `saved_places` Postgres table
/// (Phase 14) — same "one concrete class" pattern as `GeocodingService`/
/// `RoutingService`. Row Level Security (see `supabase/schema.sql`) scopes
/// every query to the signed-in user server-side; this class never sends a
/// `user_id` filter itself.
class SavedPlacesService {
  const SavedPlacesService();

  static const _table = 'saved_places';

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<SavedPlace>> list() {
    return _run(() async {
      final rows = await _client
          .from(_table)
          .select()
          .order('created_at', ascending: false);
      return rows.map(SavedPlace.fromRow).toList();
    });
  }

  Future<SavedPlace> save(Place place) {
    return _run(() async {
      final row = await _client
          .from(_table)
          .insert({
            'name': place.name,
            'address': place.address,
            'latitude': place.latitude,
            'longitude': place.longitude,
          })
          .select()
          .single();
      return SavedPlace.fromRow(row);
    });
  }

  Future<void> remove(String id) {
    return _run(() => _client.from(_table).delete().eq('id', id));
  }

  Future<T> _run<T>(Future<T> Function() action) async {
    if (!SupabaseConfig.isConfigured) {
      throw const SavedPlacesException(
        'No Supabase project configured — see SETUP.md.',
      );
    }
    try {
      return await action();
    } on PostgrestException catch (error) {
      throw SavedPlacesException(error.message);
    } catch (error) {
      throw SavedPlacesException('Network error: $error');
    }
  }
}
