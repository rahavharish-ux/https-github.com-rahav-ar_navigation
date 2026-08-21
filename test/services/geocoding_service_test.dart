import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tn_ar_navigation/services/geocoding_service.dart';

void main() {
  test('search parses a successful Places API (New) response', () async {
    final client = MockClient((request) async {
      expect(request.url.host, 'places.googleapis.com');
      expect(request.headers['X-Goog-Api-Key'], 'test-key');
      expect(request.headers['X-Goog-FieldMask'], isNotNull);
      // Required for an Android-app-restricted key — see
      // geocoding_service.dart's class doc comment.
      expect(
        request.headers['X-Android-Package'],
        'com.tnarnav.tn_ar_navigation',
      );
      expect(
        request.headers['X-Android-Cert'],
        matches(RegExp(r'^[0-9A-F]{40}$')),
      );
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['textQuery'], 'Gandhipuram');

      return http.Response(
        jsonEncode({
          'places': [
            {
              'displayName': {'text': 'Gandhipuram', 'languageCode': 'en'},
              'formattedAddress': 'Gandhipuram, Coimbatore, Tamil Nadu, India',
              'location': {'latitude': 11.0168, 'longitude': 76.9558},
            },
          ],
        }),
        200,
      );
    });

    final service = GeocodingService(client: client, apiKey: 'test-key');
    final results = await service.search('Gandhipuram');

    expect(results, hasLength(1));
    expect(results.first.name, 'Gandhipuram');
  });

  test('search biases results toward Tamil Nadu via locationBias', () async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final rectangle =
          (body['locationBias'] as Map<String, dynamic>)['rectangle']
              as Map<String, dynamic>;
      final low = rectangle['low'] as Map<String, dynamic>;
      final high = rectangle['high'] as Map<String, dynamic>;

      // Real published Tamil Nadu extent (8.083-13.583N, 76.25-80.333E) —
      // Chennai should fall inside it; a sanity check against typos in the
      // hardcoded box, not just "some box was sent".
      const chennaiLat = 13.0827;
      const chennaiLng = 80.2707;
      expect(
        chennaiLat,
        inInclusiveRange(low['latitude'] as double, high['latitude'] as double),
      );
      expect(
        chennaiLng,
        inInclusiveRange(
          low['longitude'] as double,
          high['longitude'] as double,
        ),
      );

      return http.Response(jsonEncode({'places': <dynamic>[]}), 200);
    });

    final service = GeocodingService(client: client, apiKey: 'test-key');
    await service.search('anything');
  });

  test('search throws GeocodingException when no API key is configured', () {
    final client = MockClient((request) async {
      fail('should not make a network request without a real API key');
    });
    final service = GeocodingService(client: client, apiKey: null);

    expect(
      () => service.search('anything'),
      throwsA(isA<GeocodingException>()),
    );
  });

  test('search throws GeocodingException when the API key is still the '
      'placeholder value', () {
    final client = MockClient((request) async {
      fail('should not make a network request with the placeholder key');
    });
    final service = GeocodingService(
      client: client,
      apiKey: 'YOUR_GOOGLE_MAPS_API_KEY_HERE',
    );

    expect(
      () => service.search('anything'),
      throwsA(isA<GeocodingException>()),
    );
  });

  test('search throws GeocodingException on a non-200 response', () async {
    final client = MockClient((request) async => http.Response('error', 403));
    final service = GeocodingService(client: client, apiKey: 'test-key');

    expect(
      () => service.search('anything'),
      throwsA(isA<GeocodingException>()),
    );
  });

  test(
    'search throws GeocodingException when the request itself fails',
    () async {
      final client = MockClient((request) async => throw Exception('offline'));
      final service = GeocodingService(client: client, apiKey: 'test-key');

      expect(
        () => service.search('anything'),
        throwsA(isA<GeocodingException>()),
      );
    },
  );
}
