import 'dart:async';

import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compass_reading.dart';
import '../../services/compass_service.dart';

sealed class CompassState {
  const CompassState();
}

/// Nothing requested yet.
class CompassInitial extends CompassState {
  const CompassInitial();
}

/// No compass sensor on this device (real `flutter_compass` result, not
/// every Android device reports a magnetometer) — a real, first-class
/// state, not an error. See KNOWN_LIMITATIONS.md.
class CompassUnavailable extends CompassState {
  const CompassUnavailable();
}

class CompassAvailable extends CompassState {
  const CompassAvailable(this.reading);

  final CompassReading reading;
}

/// Holds the raw error for diagnostics; normal UI must show a generic
/// message, matching the pattern in `location_provider.dart`.
class CompassError extends CompassState {
  const CompassError(this.message);

  final String message;
}

final compassProvider = NotifierProvider<CompassNotifier, CompassState>(
  CompassNotifier.new,
);

/// Real magnetometer-based heading (Phase 11), mirroring
/// `LocationNotifier`'s stream-subscription shape. Deliberately not
/// auto-started in [build] — same "ask/start only when a screen actually
/// needs it" rule Phase 3 set for location and Phase 9 set for the
/// camera, here for battery: continuous magnetometer polling has a real
/// cost, see KNOWN_LIMITATIONS.md's battery note.
class CompassNotifier extends Notifier<CompassState> {
  late final CompassService _service;
  StreamSubscription<CompassEvent>? _subscription;

  @override
  CompassState build() {
    _service = CompassService();
    ref.onDispose(() => _subscription?.cancel());
    return const CompassInitial();
  }

  void start() {
    if (_subscription != null) return;

    final events = _service.events;
    if (events == null) {
      state = const CompassUnavailable();
      return;
    }

    _subscription = events.listen(
      _onEvent,
      onError: (Object error) {
        state = CompassError(error.toString());
      },
    );
  }

  void _onEvent(CompassEvent event) => state = compassStateFromEvent(event);

  void stop() {
    _subscription?.cancel();
    _subscription = null;
    state = const CompassInitial();
  }
}

/// Pure mapping from a real `CompassEvent` to [CompassState], pulled out
/// of [CompassNotifier] so it's unit-testable without a live stream —
/// same "business logic out of the plumbing" pattern
/// `camera_selection.dart`/`ar_availability.dart` used.
CompassState compassStateFromEvent(CompassEvent event) {
  final heading = event.heading;
  // A real device with no magnetometer reports a live stream that just
  // never carries a heading value, rather than `events` itself being
  // null — both routes to the same honest state.
  if (heading == null) return const CompassUnavailable();
  return CompassAvailable(
    CompassReading(headingDegrees: heading, accuracyDegrees: event.accuracy),
  );
}
