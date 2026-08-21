import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/app_strings.dart';
import '../../core/map/app_map_controller.dart';
import '../../core/map/location_latlng.dart';
import '../../core/map/place_latlng.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/destination_provider.dart';
import '../../core/providers/location_provider.dart';
import '../../core/providers/map_follow_provider.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/map/app_map_view.dart';
import '../../widgets/map/recenter_button.dart';
import '../../widgets/travel/travel_mode_selector.dart';
import '../auth/account_screen.dart';
import '../auth/auth_screen.dart';
import '../diagnostics/diagnostics_screen.dart';
import '../route_preview/route_preview_screen.dart';
import 'widgets/current_location_badge.dart';
import 'widgets/destination_search_card.dart';
import 'widgets/locate_me_button.dart';
import 'widgets/quick_action_row.dart';

/// Home dashboard shell. The map (Phase 4) and location (Phase 3) are
/// real; search, saved places, routing, and AR are not yet — see the
/// coming-soon messages and the disabled AR button.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Approximate geographic centroid of Tamil Nadu — a reasonable statewide
  // starting view before any GPS fix exists, not a fake "current location".
  static const _tamilNaduCenter = LatLng(11.1271, 78.6569);

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
    _userMoveSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _recenter(LatLng? current) {
    ref.read(mapFollowProvider.notifier).enable();
    if (current != null) _mapController.moveTo(current);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final locationState = ref.watch(locationProvider);
    final currentLatLng = switch (locationState) {
      LocationAvailable(:final smoothedLocation) => smoothedLocation.toLatLng(),
      _ => null,
    };
    final destination = ref.watch(selectedDestinationProvider);
    final destinationLatLng = destination?.toLatLng();

    ref.listen(selectedDestinationProvider, (previous, next) {
      if (next == null) return;
      ref.read(mapFollowProvider.notifier).disable();
      final points = [next.toLatLng(), ?currentLatLng];
      _mapController.fitBounds(points);

      if (currentLatLng != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoutePreviewScreen(destination: next),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.routeNeedsLocation)),
        );
      }
    });

    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next is LocationAvailable && ref.read(mapFollowProvider)) {
        _mapController.moveTo(next.smoothedLocation.toLatLng());
      }

      final messenger = ScaffoldMessenger.of(context);
      switch (next) {
        case LocationServiceDisabled():
          messenger.showSnackBar(
            SnackBar(
              content: const Text(AppStrings.locationServiceDisabled),
              action: SnackBarAction(
                label: AppStrings.locationEnable,
                onPressed: () =>
                    ref.read(locationProvider.notifier).openLocationSettings(),
              ),
            ),
          );
        case LocationPermissionDenied(:final forever):
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                forever
                    ? AppStrings.locationPermissionDeniedForever
                    : AppStrings.locationPermissionDenied,
              ),
              action: forever
                  ? SnackBarAction(
                      label: AppStrings.locationOpenSettings,
                      onPressed: () =>
                          ref.read(locationProvider.notifier).openAppSettings(),
                    )
                  : null,
            ),
          );
        case LocationError():
          messenger.showSnackBar(
            const SnackBar(content: Text(AppStrings.locationGenericError)),
          );
        case LocationInitial() || LocationRequesting() || LocationAvailable():
          break;
      }
    });

    return Scaffold(
      // This screen has no text field of its own — the search card just
      // navigates to SearchScreen. Without this, a real overflow (113px,
      // caught via real-device testing) fires transiently when popping
      // back from SearchScreen: MediaQuery.viewInsets.bottom still
      // reflects the closing keyboard for a frame, and the default
      // (true) keyboard-avoidance shrinks this Column below what its
      // fixed-height children need.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: AppMapView(
              controller: _mapController,
              initialCenter: currentLatLng ?? _tamilNaduCenter,
              initialZoom: currentLatLng != null ? 16 : 7,
              destination: destinationLatLng,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.navigation_rounded,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        AppStrings.appName,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      IconButton(
                        tooltip: AppStrings.accountTooltip,
                        icon: const Icon(Icons.account_circle_outlined),
                        onPressed: () {
                          final authState = ref.read(authProvider);
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => authState is AppAuthenticated
                                  ? const AccountScreen()
                                  : const AuthScreen(),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        tooltip: AppStrings.diagnosticsTooltip,
                        icon: const Icon(Icons.bug_report_outlined),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const DiagnosticsScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const CurrentLocationBadge(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      RecenterButton(onPressed: () => _recenter(currentLatLng)),
                      const SizedBox(width: AppSpacing.sm),
                      const LocateMeButton(),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const _HomeBottomPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeBottomPanel extends StatelessWidget {
  const _HomeBottomPanel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
          Text(
            AppStrings.homeGreeting,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          const DestinationSearchCard(),
          const SizedBox(height: AppSpacing.md),
          const QuickActionRow(),
          const SizedBox(height: AppSpacing.md),
          const TravelModeSelector(),
          const SizedBox(height: AppSpacing.md),
          AppButton(
            label: AppStrings.arNavigation,
            variant: AppButtonVariant.secondary,
            icon: Icons.view_in_ar_outlined,
            onPressed: null,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.arNavigationComingSoon,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
