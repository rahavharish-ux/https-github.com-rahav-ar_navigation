import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/ar_availability_provider.dart';
import '../../core/providers/camera_provider.dart';
import '../../core/providers/compass_provider.dart';
import '../../core/providers/location_provider.dart';
import '../../core/providers/motion_sensor_provider.dart';
import '../../core/providers/vision_provider.dart';
import '../../core/utils/ar_availability.dart';
import '../../core/utils/heading_fusion.dart';
import '../../core/utils/speed_bucket.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/buttons/app_button.dart';
import '../ar_navigation/camera_preview_screen.dart';
import '../vision/vision_screen.dart';

/// Real technical readout for developers/evaluators — not shown
/// prominently to normal users. Reachable only via the small debug icon
/// on the home screen's app bar.
class DiagnosticsScreen extends ConsumerWidget {
  const DiagnosticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(locationProvider);
    final cameraState = ref.watch(cameraProvider);
    final arState = ref.watch(arAvailabilityProvider);
    final compassState = ref.watch(compassProvider);
    final motionState = ref.watch(motionSensorProvider);
    final visionState = ref.watch(visionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.diagnosticsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          _DiagnosticsSection(
            title: 'Location',
            rows: switch (state) {
              LocationInitial() => [('Status', 'Not requested yet')],
              LocationRequesting(:final weakSignal) => [
                (
                  'Status',
                  weakSignal
                      ? 'Requesting… weak GPS signal (fixes arriving but '
                            'too inaccurate — Phase 12)'
                      : 'Requesting…',
                ),
              ],
              LocationServiceDisabled() => [
                ('Status', 'Location services disabled'),
              ],
              LocationPermissionDenied(:final forever) => [
                (
                  'Status',
                  forever ? 'Permission denied (forever)' : 'Permission denied',
                ),
              ],
              LocationError(:final message) => [
                ('Status', 'Error'),
                ('Detail', message),
              ],
              LocationAvailable(:final location, :final weakSignal) => [
                (
                  'Status',
                  weakSignal
                      ? 'Available (weak signal — may be stale, Phase 12)'
                      : 'Available',
                ),
                ('Latitude', location.latitude.toStringAsFixed(6)),
                ('Longitude', location.longitude.toStringAsFixed(6)),
                ('Accuracy', '${location.accuracyMeters.toStringAsFixed(1)} m'),
                ('Speed', '${location.speedKmh.toStringAsFixed(1)} km/h'),
                ('Heading', '${location.headingDegrees.toStringAsFixed(0)}°'),
                ('Timestamp', location.timestamp.toIso8601String()),
              ],
            },
          ),
          if (state case LocationAvailable(
            :final location,
            :final smoothedLocation,
          )) ...[
            const SizedBox(height: AppSpacing.md),
            _DiagnosticsSection(
              title: 'Smoothed (Phase 8)',
              rows: [
                ('Latitude', smoothedLocation.latitude.toStringAsFixed(6)),
                ('Longitude', smoothedLocation.longitude.toStringAsFixed(6)),
                (
                  'Heading',
                  '${smoothedLocation.headingDegrees.toStringAsFixed(0)}°',
                ),
                (
                  'Raw vs. smoothed drift',
                  '${Geolocator.distanceBetween(location.latitude, location.longitude, smoothedLocation.latitude, smoothedLocation.longitude).toStringAsFixed(1)} m',
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: 'Request location',
            onPressed: () =>
                ref.read(locationProvider.notifier).requestAndStart(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DiagnosticsSection(
            title: 'Camera',
            rows: [
              (
                'Status',
                switch (cameraState) {
                  CameraInitial() => 'Not requested yet',
                  CameraRequesting() => 'Requesting…',
                  CameraAvailable() => 'Available',
                  CameraUnavailable() => 'No usable camera on this device',
                  CameraPermissionDenied() => 'Permission denied',
                  CameraError(:final message) => 'Error: $message',
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.cameraPreviewButton,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const CameraPreviewScreen(),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DiagnosticsSection(
            title: 'AR (ARCore)',
            rows: [
              (
                'Status',
                switch (arState) {
                  ArAvailabilityInitial() => 'Not checked yet',
                  ArAvailabilityChecking() => 'Checking…',
                  ArAvailabilityChecked(:final availability) =>
                    switch (availability) {
                      ArAvailability.supported => 'Supported — ARCore ready',
                      ArAvailability.needsGooglePlayServicesForAr =>
                        'Device capable — install/update Google Play '
                            'Services for AR',
                      ArAvailability.unsupportedDevice =>
                        'Not supported on this device',
                      ArAvailability.unknown =>
                        'Could not determine (error or timeout)',
                      ArAvailability.notImplementedOnThisPlatform =>
                        'Not implemented on this platform yet',
                    },
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Check AR support',
            variant: AppButtonVariant.secondary,
            onPressed: () => ref.read(arAvailabilityProvider.notifier).check(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DiagnosticsSection(
            title: 'Compass',
            rows: [
              (
                'Status',
                switch (compassState) {
                  CompassInitial() => 'Not started yet',
                  CompassUnavailable() => 'No compass sensor on this device',
                  CompassError(:final message) => 'Error: $message',
                  CompassAvailable(:final reading) =>
                    '${reading.headingDegrees.toStringAsFixed(0)}°'
                        '${reading.accuracyDegrees != null ? ' (±${reading.accuracyDegrees!.toStringAsFixed(0)}°)' : ''}',
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Start compass',
            variant: AppButtonVariant.secondary,
            onPressed: () => ref.read(compassProvider.notifier).start(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DiagnosticsSection(
            title: 'Fused heading (Phase 12)',
            rows: () {
              final gpsHeading = switch (state) {
                LocationAvailable(:final smoothedLocation) =>
                  smoothedLocation.headingDegrees,
                _ => null,
              };
              final compassHeading = switch (compassState) {
                CompassAvailable(:final reading) => reading.headingDegrees,
                _ => null,
              };
              final speedBucket = switch (state) {
                // No "previous bucket" concept for a one-shot diagnostic
                // read (unlike LocationNotifier's live hysteresis) —
                // stationary is a neutral, honest starting point.
                LocationAvailable(:final smoothedLocation) => speedBucketFor(
                  smoothedLocation.speedMetersPerSecond,
                  SpeedBucket.stationary,
                ),
                _ => SpeedBucket.stationary,
              };
              final fused = fuseHeading(
                gpsHeadingDegrees: gpsHeading,
                compassHeadingDegrees: compassHeading,
                speedBucket: speedBucket,
              );
              return [
                (
                  'Fused',
                  switch (fused.source) {
                    HeadingSource.none => 'No source available yet',
                    HeadingSource.gps =>
                      '${fused.headingDegrees!.toStringAsFixed(0)}° '
                          '(source: GPS course — ${speedBucket.name} speed)',
                    HeadingSource.compass =>
                      '${fused.headingDegrees!.toStringAsFixed(0)}° '
                          '(source: compass — ${speedBucket.name} speed)',
                  },
                ),
              ];
            }(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DiagnosticsSection(
            title: 'Motion sensors (IMU)',
            rows: switch (motionState) {
              MotionSensorInitial() => [('Status', 'Not started yet')],
              MotionSensorError(:final message) => [
                ('Status', 'Error: $message'),
              ],
              MotionSensorReading(:final accelerometer, :final gyroscope) => [
                (
                  'Accelerometer',
                  accelerometer == null
                      ? 'Waiting for first reading…'
                      : 'x:${accelerometer.x.toStringAsFixed(2)} '
                            'y:${accelerometer.y.toStringAsFixed(2)} '
                            'z:${accelerometer.z.toStringAsFixed(2)} m/s²',
                ),
                (
                  'Gyroscope',
                  gyroscope == null
                      ? 'Waiting for first reading…'
                      : 'x:${gyroscope.x.toStringAsFixed(2)} '
                            'y:${gyroscope.y.toStringAsFixed(2)} '
                            'z:${gyroscope.z.toStringAsFixed(2)} rad/s',
                ),
              ],
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: 'Start motion sensors',
            variant: AppButtonVariant.secondary,
            onPressed: () => ref.read(motionSensorProvider.notifier).start(),
          ),
          const SizedBox(height: AppSpacing.lg),
          _DiagnosticsSection(
            title: 'Vision (Phase 13)',
            rows: [
              (
                'Status',
                switch (visionState) {
                  VisionIdle() => 'Not analyzed yet',
                  VisionProcessing() => 'Processing…',
                  VisionTextResult(:final result) =>
                    result.hasText
                        ? '${result.lines.length} line(s) of text recognized'
                        : 'No text detected',
                  VisionLabelResult(:final labels) =>
                    labels.isEmpty
                        ? 'No labels detected'
                        : '${labels.length} scene label(s) detected',
                  VisionUnavailable() =>
                    'On-device text/scene recognition not implemented on '
                        'this platform',
                  VisionFailed(:final message) => 'Error: $message',
                },
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            label: AppStrings.visionPreviewButton,
            variant: AppButtonVariant.secondary,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const VisionScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

class _DiagnosticsSection extends StatelessWidget {
  const _DiagnosticsSection({required this.title, required this.rows});

  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final (label, value) in rows)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(child: Text(value)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
