import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/map/app_map_controller.dart';
import '../../core/map/location_latlng.dart';
import '../../core/map/place_latlng.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/location_provider.dart';
import '../../core/providers/route_provider.dart';
import '../../core/providers/saved_places_provider.dart';
import '../../core/providers/travel_mode_provider.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/distance_format.dart';
import '../../core/utils/duration_format.dart';
import '../../models/place_model.dart';
import '../../models/route_model.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/map/app_map_view.dart';
import '../../widgets/travel/travel_mode_selector.dart';
import '../auth/auth_screen.dart';
import '../navigation/navigation_screen.dart';
import '../navigation/providers/navigation_provider.dart';

/// Real route preview (Phase 6): distance, ETA, and a drawn route polyline
/// for Driving, computed from a live GPS fix to the selected destination.
/// Walking/Cycling are honestly marked unavailable rather than reusing
/// driving-graph results under a different label — see
/// KNOWN_LIMITATIONS.md. "Start Navigation" (Phase 7) is enabled only once
/// a real route exists.
class RoutePreviewScreen extends ConsumerStatefulWidget {
  const RoutePreviewScreen({super.key, required this.destination});

  final Place destination;

  @override
  ConsumerState<RoutePreviewScreen> createState() => _RoutePreviewScreenState();
}

class _RoutePreviewScreenState extends ConsumerState<RoutePreviewScreen> {
  late final AppMapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = AppMapController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculate());
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _calculate() {
    final locationState = ref.read(locationProvider);
    if (locationState is! LocationAvailable) return;
    ref
        .read(routeProvider.notifier)
        .calculate(
          origin: locationState.location.toLatLng(),
          destination: widget.destination.toLatLng(),
          mode: ref.read(travelModeProvider),
        );
  }

  Future<void> _saveThisPlace() async {
    final authState = ref.read(authProvider);
    if (authState is! AppAuthenticated) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const AuthScreen()));
      return;
    }

    // Real bug caught on a physical device: this used to show "Place
    // saved." unconditionally, without checking whether the save actually
    // succeeded — a fake success message, which is exactly what this
    // project's "no faked functionality" rule exists to prevent.
    final saved = await ref
        .read(savedPlacesProvider.notifier)
        .save(widget.destination);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          saved ? AppStrings.placeSaved : AppStrings.savePlaceFailedMessage,
        ),
      ),
    );
  }

  void _startNavigation(AppRoute route) {
    ref
        .read(navigationProvider.notifier)
        .start(route: route, destination: widget.destination.toLatLng());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => NavigationScreen(destination: widget.destination),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locationState = ref.watch(locationProvider);
    final currentLatLng = switch (locationState) {
      LocationAvailable(:final location) => location.toLatLng(),
      _ => null,
    };
    final destinationLatLng = widget.destination.toLatLng();
    final routeState = ref.watch(routeProvider);

    ref.listen(travelModeProvider, (previous, next) {
      if (previous != next) _calculate();
    });

    ref.listen<RouteState>(routeProvider, (previous, next) {
      if (next is RouteReady && currentLatLng != null) {
        _mapController.fitBounds([currentLatLng, destinationLatLng]);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(widget.destination.name)),
      body: Column(
        children: [
          Expanded(
            child: AppMapView(
              controller: _mapController,
              initialCenter: currentLatLng ?? destinationLatLng,
              initialZoom: 13,
              destination: destinationLatLng,
              routePoints: switch (routeState) {
                RouteReady(:final route) => route.polyline,
                _ => null,
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.destination.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AppButton(
                    label: AppStrings.savePlaceButton,
                    variant: AppButtonVariant.secondary,
                    icon: Icons.bookmark_border,
                    onPressed: _saveThisPlace,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const TravelModeSelector(),
                  const SizedBox(height: AppSpacing.md),
                  _RouteSummary(
                    state: routeState,
                    hasLocation: currentLatLng != null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppButton(
                    label: AppStrings.startNavigation,
                    icon: Icons.navigation_outlined,
                    onPressed: switch (routeState) {
                      RouteReady(:final route) => () => _startNavigation(route),
                      _ => null,
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({required this.state, required this.hasLocation});

  final RouteState state;

  /// Whether a live GPS fix exists to route from. Without one, [state]
  /// stays [RouteIdle] indefinitely (nothing was ever requested) — shown
  /// honestly instead of as an unexplained, never-resolving spinner.
  final bool hasLocation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!hasLocation && state is RouteIdle) {
      return Text(
        AppStrings.routeNeedsLocation,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        textAlign: TextAlign.center,
      );
    }

    return switch (state) {
      RouteIdle() || RouteLoading() => const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Center(child: LoadingIndicator()),
      ),
      RouteReady(:final route) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.route_outlined, color: colorScheme.primary),
          const SizedBox(width: AppSpacing.sm),
          Text(
            '${formatDurationSeconds(route.durationSeconds)} · '
            '${formatDistanceMeters(route.distanceMeters)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
      RouteModeUnsupported() => Text(
        AppStrings.routeModeUnsupported,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        textAlign: TextAlign.center,
      ),
      RouteFailed() => Text(
        AppStrings.routeFailedMessage,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colorScheme.error),
        textAlign: TextAlign.center,
      ),
    };
  }
}
