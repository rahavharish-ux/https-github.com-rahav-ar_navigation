/// Real, honest categories of whether this device can run AR (Phase 10),
/// distinct enough that the UI never has to guess or round up. Deliberately
/// keeps "device is capable but needs a Play Store action" as one case
/// (see [parseArCoreAvailability]) since both underlying ARCore results it
/// covers lead to the same user-facing message.
enum ArAvailability {
  /// ARCore is installed and this device can run AR right now.
  supported,

  /// The device is capable, but Google Play Services for AR needs to be
  /// installed or updated from the Play Store first.
  needsGooglePlayServicesForAr,

  /// This device's hardware/OS cannot run ARCore at all.
  unsupportedDevice,

  /// The real check ran but didn't resolve to a definite answer (error or
  /// timeout) -- never shown as if it were a confident "no".
  unknown,

  /// No native AR-availability check exists for this platform yet (iOS,
  /// web) -- this project is Android-first; see KNOWN_LIMITATIONS.md.
  notImplementedOnThisPlatform,
}

/// Maps `ArCoreApk.Availability`'s real Android enum constant name (as
/// returned verbatim by `MainActivity.kt`'s MethodChannel handler) to
/// [ArAvailability]. Pulled out of `ArPlatformService` as a pure function,
/// the same "business logic stays out of the platform-channel plumbing, so
/// it's testable without a device" pattern `camera_selection.dart` used in
/// Phase 9.
ArAvailability parseArCoreAvailability(String? raw) => switch (raw) {
  'SUPPORTED_INSTALLED' => ArAvailability.supported,
  'SUPPORTED_APK_TOO_OLD' ||
  'SUPPORTED_NOT_INSTALLED' => ArAvailability.needsGooglePlayServicesForAr,
  'UNSUPPORTED_DEVICE_NOT_CAPABLE' => ArAvailability.unsupportedDevice,
  // Covers 'UNKNOWN_ERROR', 'UNKNOWN_TIMED_OUT', a still-transient
  // 'UNKNOWN_CHECKING' that outlasted MainActivity's poll budget, null, and
  // any future ArCoreApk constant this app doesn't recognize yet.
  _ => ArAvailability.unknown,
};
