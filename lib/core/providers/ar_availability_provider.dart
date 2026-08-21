import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/ar_platform_service.dart';
import '../utils/ar_availability.dart';

sealed class ArAvailabilityState {
  const ArAvailabilityState();
}

/// Nothing checked yet.
class ArAvailabilityInitial extends ArAvailabilityState {
  const ArAvailabilityInitial();
}

class ArAvailabilityChecking extends ArAvailabilityState {
  const ArAvailabilityChecking();
}

class ArAvailabilityChecked extends ArAvailabilityState {
  const ArAvailabilityChecked(this.availability);

  final ArAvailability availability;
}

final arAvailabilityProvider =
    NotifierProvider<ArAvailabilityNotifier, ArAvailabilityState>(
      ArAvailabilityNotifier.new,
    );

/// Real permission-free capability check (Phase 10) -- there's no
/// "permission" to request for this, just a device/software capability
/// question -- mirroring `LocationNotifier`/`CameraNotifier`'s shape.
class ArAvailabilityNotifier extends Notifier<ArAvailabilityState> {
  late final ArPlatformService _service;

  @override
  ArAvailabilityState build() {
    _service = const ArPlatformService();
    return const ArAvailabilityInitial();
  }

  Future<void> check() async {
    if (state is ArAvailabilityChecking) return;
    state = const ArAvailabilityChecking();
    final availability = await _service.checkAvailability();
    state = ArAvailabilityChecked(availability);
  }
}
