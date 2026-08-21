import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/providers/location_provider.dart';
import '../../../core/utils/distance_format.dart';
import '../../../models/place_model.dart';

class SearchResultTile extends ConsumerWidget {
  const SearchResultTile({
    super.key,
    required this.place,
    required this.onTap,
    this.leading,
  });

  final Place place;
  final VoidCallback onTap;
  final IconData? leading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    String? distanceLabel;
    if (locationState is LocationAvailable) {
      final meters = Geolocator.distanceBetween(
        locationState.location.latitude,
        locationState.location.longitude,
        place.latitude,
        place.longitude,
      );
      distanceLabel = formatDistanceMeters(meters);
    }

    return ListTile(
      leading: Icon(leading ?? Icons.place_outlined),
      title: Text(place.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        place.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: distanceLabel == null ? null : Text(distanceLabel),
      onTap: onTap,
    );
  }
}
