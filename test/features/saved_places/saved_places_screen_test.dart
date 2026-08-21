import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/saved_places_provider.dart';
import 'package:tn_ar_navigation/features/saved_places/saved_places_screen.dart';
import 'package:tn_ar_navigation/models/place_model.dart';
import 'package:tn_ar_navigation/models/saved_place.dart';

/// A fixed [SavedPlacesState] without touching the real
/// `SavedPlacesService`, same approach as `_FixedCameraNotifier`. [load]
/// is a no-op so the fixed state isn't immediately overwritten by the
/// real (not-configured) load this screen's `initState` triggers.
class _FixedSavedPlacesNotifier extends SavedPlacesNotifier {
  _FixedSavedPlacesNotifier(this._fixed);

  final SavedPlacesState _fixed;
  int removeCalls = 0;

  @override
  SavedPlacesState build() => _fixed;

  @override
  Future<void> load() async {}

  @override
  Future<void> remove(String id) async {
    removeCalls++;
  }
}

void main() {
  Widget wrap(SavedPlacesState state) {
    return ProviderScope(
      overrides: [
        savedPlacesProvider.overrideWith(
          () => _FixedSavedPlacesNotifier(state),
        ),
      ],
      child: const MaterialApp(home: SavedPlacesScreen()),
    );
  }

  testWidgets('Shows a loading indicator while loading', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const SavedPlacesLoading()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Shows an honest empty state with no saved places', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const SavedPlacesLoaded([])));

    expect(find.textContaining("haven't saved"), findsOneWidget);
  });

  testWidgets('Shows a generic failure message, no raw error text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      wrap(const SavedPlacesFailed('PostgrestException: 42501')),
    );

    expect(
      find.text("Couldn't load your saved places right now."),
      findsOneWidget,
    );
    expect(find.textContaining('PostgrestException'), findsNothing);
  });

  testWidgets('Lists saved places with name and address', (
    WidgetTester tester,
  ) async {
    final saved = SavedPlace(
      id: 'p1',
      place: const Place(
        name: 'Meenakshi Amman Temple',
        address: 'Madurai, Tamil Nadu',
        latitude: 9.9195,
        longitude: 78.1193,
      ),
      createdAt: DateTime(2026, 8, 21),
    );

    await tester.pumpWidget(wrap(SavedPlacesLoaded([saved])));

    expect(find.text('Meenakshi Amman Temple'), findsOneWidget);
    expect(find.text('Madurai, Tamil Nadu'), findsOneWidget);
  });

  testWidgets('Tapping the delete icon calls remove()', (
    WidgetTester tester,
  ) async {
    final saved = SavedPlace(
      id: 'p1',
      place: const Place(
        name: 'Meenakshi Amman Temple',
        address: 'Madurai, Tamil Nadu',
        latitude: 9.9195,
        longitude: 78.1193,
      ),
      createdAt: DateTime(2026, 8, 21),
    );
    final notifier = _FixedSavedPlacesNotifier(SavedPlacesLoaded([saved]));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [savedPlacesProvider.overrideWith(() => notifier)],
        child: const MaterialApp(home: SavedPlacesScreen()),
      ),
    );

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    expect(notifier.removeCalls, 1);
  });
}
