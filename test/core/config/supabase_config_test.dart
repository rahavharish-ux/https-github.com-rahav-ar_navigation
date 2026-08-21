import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/config/supabase_config.dart';

void main() {
  tearDown(dotenv.clean);

  test('isConfigured is false before dotenv has ever been loaded', () {
    expect(SupabaseConfig.isConfigured, isFalse);
  });

  test('isConfigured is false with the placeholder values', () {
    dotenv.loadFromString(
      envString:
          'SUPABASE_URL=YOUR_SUPABASE_URL_HERE\n'
          'SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY_HERE\n',
    );

    expect(SupabaseConfig.isConfigured, isFalse);
  });

  test('isConfigured is false when only one of the two values is real', () {
    dotenv.loadFromString(
      envString:
          'SUPABASE_URL=https://project.supabase.co\n'
          'SUPABASE_PUBLISHABLE_KEY=YOUR_SUPABASE_PUBLISHABLE_KEY_HERE\n',
    );

    expect(SupabaseConfig.isConfigured, isFalse);
  });

  test('isConfigured is true with real-looking values', () {
    dotenv.loadFromString(
      envString:
          'SUPABASE_URL=https://project.supabase.co\n'
          'SUPABASE_PUBLISHABLE_KEY=sb_publishable_abc123\n',
    );

    expect(SupabaseConfig.isConfigured, isTrue);
    expect(SupabaseConfig.url, 'https://project.supabase.co');
    expect(SupabaseConfig.publishableKey, 'sb_publishable_abc123');
  });
}
