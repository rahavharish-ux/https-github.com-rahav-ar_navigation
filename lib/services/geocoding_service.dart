import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';

class GeocodingException implements Exception {
  const GeocodingException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Thin wrapper over Google's Places API (New) Text Search.
///
/// Replaced OpenStreetMap Nominatim (2026-08-20): Nominatim's free,
/// crowd-sourced data has real, genuine POI-coverage gaps in Tamil Nadu —
/// a data-completeness problem no amount of query tuning could close, not
/// a bug in the old query code. See KNOWN_LIMITATIONS.md and
/// PROJECT_STATUS.md's Phase 11 entry for the full comparison that led to
/// this switch.
///
/// Requires a real Google Cloud API key with the Places API (New) enabled
/// and billing set up — read from `GOOGLE_MAPS_API_KEY` via
/// `flutter_dotenv` (see `.env.example`). This is a paid provider: unlike
/// Nominatim, there is no free public endpoint to fall back to.
///
/// The key is restricted in Google Cloud Console to Android apps (package
/// name + signing certificate) — see SETUP.md. That restriction is
/// enforced automatically for the native Maps SDK (it runs inside the app
/// process), but a plain REST call like this one has to identify itself
/// explicitly via the `X-Android-Package`/`X-Android-Cert` headers below,
/// or Google rejects it with 403 PERMISSION_DENIED even with a valid key.
class GeocodingService {
  GeocodingService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? _apiKeyFromEnv();

  static const _endpoint = 'https://places.googleapis.com/v1/places:searchText';

  static const _fieldMask =
      'places.displayName,places.formattedAddress,places.location';

  /// This app's real applicationId (`android/app/build.gradle.kts`) —
  /// not a secret, just an identity check the Android-app-restricted key
  /// needs to see on every REST call.
  static const _androidPackageName = 'com.tnarnav.tn_ar_navigation';

  /// Debug signing certificate's SHA-1, formatted exactly as Google's
  /// `X-Android-Cert` header requires: uppercase hex, no colons. Not a
  /// secret (it's derived from the debug keystore and is meant to be
  /// shared with Google Cloud Console — see SETUP.md's `signingReport`
  /// step). A release build needs its own release-cert SHA-1 added
  /// alongside this one in Cloud Console before shipping — tracked, not
  /// yet done, since release signing itself is still a TODO (see
  /// `build.gradle.kts`).
  static const _androidCertSha1 = 'B5302537C7A585F5836992A478F1E73A07775750';

  /// Tamil Nadu's real bounding box (8.083–13.583°N, 76.25–80.333°E) —
  /// same source/reasoning as the Nominatim `viewbox` this replaced.
  /// `locationBias` (not `locationRestriction`) so a real place just
  /// across a border district still shows up, just ranked lower.
  static const _tamilNaduLow = {'latitude': 8.083, 'longitude': 76.25};
  static const _tamilNaduHigh = {'latitude': 13.583, 'longitude': 80.333};

  final http.Client _client;
  final String? _apiKey;

  static String? _apiKeyFromEnv() =>
      dotenv.isInitialized ? dotenv.env['GOOGLE_MAPS_API_KEY'] : null;

  Future<List<Place>> search(String query, {int limit = 8}) async {
    final apiKey = _apiKey;
    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey == 'YOUR_GOOGLE_MAPS_API_KEY_HERE') {
      throw const GeocodingException(
        'No Google Maps API key configured. Copy .env.example to .env and '
        'set GOOGLE_MAPS_API_KEY to a real key with Places API (New) '
        'enabled — see SETUP.md.',
      );
    }

    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'X-Goog-Api-Key': apiKey,
              'X-Goog-FieldMask': _fieldMask,
              'X-Android-Package': _androidPackageName,
              'X-Android-Cert': _androidCertSha1,
            },
            body: jsonEncode({
              'textQuery': query,
              'locationBias': {
                'rectangle': {'low': _tamilNaduLow, 'high': _tamilNaduHigh},
              },
              'maxResultCount': limit,
            }),
          )
          .timeout(const Duration(seconds: 10));
    } catch (error) {
      throw GeocodingException('Network error: $error');
    }

    if (response.statusCode != 200) {
      throw GeocodingException(
        'Search failed with status ${response.statusCode}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final places = decoded['places'] as List<dynamic>? ?? const [];
    return places
        .cast<Map<String, dynamic>>()
        .map(Place.fromGooglePlacesJson)
        .toList();
  }

  void dispose() => _client.close();
}
