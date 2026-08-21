import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  // Loads GOOGLE_MAPS_API_KEY (Phase 11) for GeocodingService. The bundled
  // .env always exists (a placeholder if no real key has been configured
  // yet — see .env.example/SETUP.md), so this never fails to load; a
  // missing/placeholder key surfaces as a real, honest error from
  // GeocodingService.search() instead, not a crash here.
  await dotenv.load();

  // Supabase.initialize (Phase 14) parses the URL eagerly -- calling it
  // with the placeholder string would throw and crash app boot, unlike
  // GeocodingService's lazy per-request failure. Only initialize once a
  // real project URL/key exist; AuthService reports an honest
  // "not configured" state otherwise instead of touching
  // Supabase.instance.
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  runApp(const ProviderScope(child: TnArNavigationApp()));
}

class TnArNavigationApp extends StatelessWidget {
  const TnArNavigationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
