import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_strings.dart';
import '../../core/map/app_map_controller.dart';
import '../../core/map/place_latlng.dart';
import '../../core/providers/map_follow_provider.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/distance_format.dart';
import '../../core/utils/duration_format.dart';
import '../../models/place_model.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/map/app_map_view.dart';
import '../../widgets/map/recenter_button.dart';
import 'providers/navigation_provider.dart';
import 'widgets/maneuver_icon.dart';

/// Real turn-by-turn navigation (Phase 7): a live session driven by GPS
/// updates, with real maneuver instructions, distance/ETA, off-route
/// detection with automatic recalculation, and arrival detection. Reuses
/// the same map-follow/re-center mechanism as the home screen (Phase 4)
/// rather than inventing a second one — see ARCHITECTURE.md.
class NavigationScreen extends ConsumerStatefulWidget {
  const NavigationScreen({super.key, required this.destination});

  final Place destination;

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  late final AppMapController _mapController;
  StreamSubscription<bool>? _userMoveSubscription;

  @override
  void initState() {
    super.initState();
    _mapController = AppMapController();
    _userMoveSubscription = _mapController.userMovedMap.listen((_) {
      ref.read(mapFollowProvider.notifier).disable();
    });
  }

  @override
  void dispose() {
    // Ending the session (navigationProvider.notifier.stop()) is handled
    // by PopScope's onPopInvokedWithResult in build(), not here — mutating
    // provider state from dispose() is unsafe (Riverpod's `ref` relies on
    // a BuildContext that's mid-teardown) and, in tests, can run after the
    // whole ProviderScope is already gone. PopScope's callback fires while
    // this widget is still fully mounted, for every way the screen closes
    // (buttons, back gesture, or programmatic pop) alike.
    _userMoveSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _recenter(LatLng? current) {
    ref.read(mapFollowProvider.notifier).enable();
    if (current != null) _mapController.moveTo(current);
  }

  void _togglePauseResume(NavigationStatus status) {
    final notifier = ref.read(navigationProvider.notifier);
    if (status == NavigationStatus.paused) {
      notifier.resume();
    } else {
      notifier.pause();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(navigationProvider);
    final destinationLatLng = widget.destination.toLatLng();

    ref.listen<NavigationState>(navigationProvider, (previous, next) {
      if (next.currentLocation != null && ref.read(mapFollowProvider)) {
        _mapController.moveTo(next.currentLocation!);
      }
    });

    return PopScope(
      // Runs on every way this screen closes — Stop/Done button, system
      // back gesture, or a programmatic pop alike — while the widget is
      // still fully mounted, unlike dispose() (see its comment above).
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) ref.read(navigationProvider.notifier).stop();
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AppMapView(
                controller: _mapController,
                initialCenter: navState.currentLocation ?? destinationLatLng,
                initialZoom: 17,
                destination: destinationLatLng,
                routePoints: navState.route?.polyline,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: _StatusBanner(state: navState),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RecenterButton(
                          onPressed: () => _recenter(navState.currentLocation),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BottomPanel(
                    state: navState,
                    onPauseResume: () => _togglePauseResume(navState.status),
                    onLeave: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.state});

  final NavigationState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return switch (state.status) {
      NavigationStatus.offRoute => _MessageCard(
        color: colorScheme.errorContainer,
        onColor: colorScheme.onErrorContainer,
        icon: Icons.wrong_location_outlined,
        message: AppStrings.navigationOffRoute,
        detail: state.errorMessage != null
            ? AppStrings.navigationErrorMessage
            : null,
      ),
      NavigationStatus.wrongDirection => _MessageCard(
        color: colorScheme.errorContainer,
        onColor: colorScheme.onErrorContainer,
        icon: Icons.u_turn_left_outlined,
        message: AppStrings.navigationWrongDirection,
      ),
      NavigationStatus.recalculating => _MessageCard(
        color: colorScheme.secondaryContainer,
        onColor: colorScheme.onSecondaryContainer,
        icon: Icons.sync,
        message: AppStrings.navigationRecalculating,
      ),
      NavigationStatus.paused => _MessageCard(
        color: colorScheme.surfaceContainerHigh,
        onColor: colorScheme.onSurface,
        icon: Icons.pause_circle_outline,
        message: AppStrings.navigationPaused,
      ),
      NavigationStatus.arrived => _MessageCard(
        color: colorScheme.primaryContainer,
        onColor: colorScheme.onPrimaryContainer,
        icon: Icons.flag_outlined,
        message: AppStrings.navigationArrivedTitle,
      ),
      _ => _InstructionCard(state: state),
    };
  }
}

class _InstructionCard extends StatelessWidget {
  const _InstructionCard({required this.state});

  final NavigationState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final instruction = state.currentInstruction;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          ManeuverIcon(
            type: instruction?.type ?? 'continue',
            modifier: instruction?.modifier,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatDistanceMeters(state.distanceToNextManeuverMeters ?? 0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  instruction?.text ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: colorScheme.onPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.color,
    required this.onColor,
    required this.icon,
    required this.message,
    this.detail,
  });

  final Color color;
  final Color onColor;
  final IconData icon;
  final String message;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, color: onColor),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: onColor),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: onColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.state,
    required this.onPauseResume,
    required this.onLeave,
  });

  final NavigationState state;
  final VoidCallback onPauseResume;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final arrived = state.status == NavigationStatus.arrived;
    final paused = state.status == NavigationStatus.paused;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (arrived)
            Text(
              AppStrings.navigationArrivedBody,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.route_outlined, color: colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${formatDurationSeconds(state.remainingDurationSeconds ?? 0)} · '
                  '${formatDistanceMeters(state.remainingDistanceMeters ?? 0)} remaining',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          const SizedBox(height: AppSpacing.md),
          if (arrived)
            AppButton(label: AppStrings.navigationDone, onPressed: onLeave)
          else
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: paused
                        ? AppStrings.navigationResume
                        : AppStrings.navigationPause,
                    variant: AppButtonVariant.secondary,
                    onPressed: onPauseResume,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    label: AppStrings.navigationStop,
                    onPressed: onLeave,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
