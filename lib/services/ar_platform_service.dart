import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../core/utils/ar_availability.dart';

/// True only for a real, native Android runtime -- not web (where
/// `defaultTargetPlatform` can still report `android` when Chrome itself
/// runs on an Android host, but no native MethodChannel handler exists
/// there) and not iOS (no handler registered in `AppDelegate` yet; this
/// project is Android-first).
bool get _isNativeAndroid =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

/// Thin wrapper over a native MethodChannel that talks to Google's real
/// ARCore SDK directly (`MainActivity.kt`) -- not a third-party Flutter AR
/// plugin. Same "one concrete swappable class" pattern as
/// `LocationService`/`CameraService`. See `ar_availability.dart` for why
/// this phase is scoped to a capability check rather than AR rendering.
class ArPlatformService {
  const ArPlatformService();

  static const _channel = MethodChannel('tn_ar_navigation/ar_platform');

  Future<ArAvailability> checkAvailability() async {
    if (!_isNativeAndroid) return ArAvailability.notImplementedOnThisPlatform;

    try {
      final raw = await _channel.invokeMethod<String>(
        'checkArCoreAvailability',
      );
      return parseArCoreAvailability(raw);
    } on MissingPluginException {
      return ArAvailability.unknown;
    } on PlatformException {
      return ArAvailability.unknown;
    }
  }
}
