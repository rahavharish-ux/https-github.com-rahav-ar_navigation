import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Real Supabase project credentials (Phase 14), read from `.env` the same
/// way Phase 11's `GOOGLE_MAPS_API_KEY` is -- see `.env.example`.
class SupabaseConfig {
  const SupabaseConfig._();

  // dotenv.env throws NotInitializedError before dotenv.load() has run
  // (e.g. widget tests, which never call main()) -- same guard
  // GeocodingService uses for GOOGLE_MAPS_API_KEY.
  static String get url =>
      dotenv.isInitialized ? (dotenv.env['SUPABASE_URL'] ?? '') : '';

  /// Supabase's client-safe key, formatted `sb_publishable_...`. Named
  /// "publishable key" (not "anon key") to match Supabase's current
  /// dashboard terminology and SDK API — `anonKey` still works but is
  /// deprecated as of `supabase_flutter` 2.17.
  static String get publishableKey => dotenv.isInitialized
      ? (dotenv.env['SUPABASE_PUBLISHABLE_KEY'] ?? '')
      : '';

  /// False until a real project URL/key replace the placeholders --
  /// `main.dart` uses this to decide whether to call `Supabase.initialize`
  /// at all (a placeholder URL would fail to parse and crash app boot),
  /// and `AuthService` uses it to fail every call honestly instead of
  /// touching an uninitialized `Supabase.instance`, the same "no faked
  /// functionality" pattern `GeocodingService.search()` established for a
  /// missing Maps API key.
  static bool get isConfigured =>
      url.isNotEmpty &&
      publishableKey.isNotEmpty &&
      !url.startsWith('YOUR_') &&
      !publishableKey.startsWith('YOUR_');
}
