import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tn_ar_navigation/core/providers/destination_provider.dart';
import 'package:tn_ar_navigation/features/search/providers/search_provider.dart';
import 'package:tn_ar_navigation/features/search/search_screen.dart';
import 'package:tn_ar_navigation/models/place_model.dart';

/// A fixed [SearchState] without touching the real `GeocodingService`,
/// same approach as this project's other fixed-notifier test doubles.
class _FixedSearchNotifier extends SearchNotifier {
  _FixedSearchNotifier(this._fixed);

  final SearchState _fixed;

  @override
  SearchState build() => _fixed;
}

/// Mimics `HomeScreen`'s real shape just enough to reproduce a real bug
/// found on a physical device: a `ref.listen(selectedDestinationProvider)`
/// callback that pushes a new screen the instant a destination is
/// selected, while `SearchScreen` -- pushed on top of this screen -- is
/// still in the middle of its own `_select()` handler.
class _HomeLike extends ConsumerWidget {
  const _HomeLike();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(selectedDestinationProvider, (previous, next) {
      if (next == null) return;
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const _MarkerScreen()));
    });

    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const SearchScreen())),
          child: const Text('open search'),
        ),
      ),
    );
  }
}

class _MarkerScreen extends StatelessWidget {
  const _MarkerScreen();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Text('route preview marker'));
}

/// Blocks real network so the geocoding request fails fast and
/// deterministically instead of hanging on this environment's flaky
/// network — same approach as home_screen_test.dart.
class _NoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 1);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _NoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  Widget wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

  testWidgets('Shows the search prompt when idle with no recent searches', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(wrap(const SearchScreen()));

    expect(
      find.text('Search for a place, landmark, or address.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Typing a query shows a failure message once the (blocked) request fails',
    (WidgetTester tester) async {
      await tester.pumpWidget(wrap(const SearchScreen()));

      await tester.enterText(find.byType(TextField), 'Gandhipuram');
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(seconds: 1));

      expect(
        find.text(
          "Couldn't search right now. Check your connection and try again.",
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('Selecting a result opens the screen pushed in reaction to the '
      'selection, instead of that screen being immediately popped away by '
      "SearchScreen's own pop() -- regression test for a real Navigator "
      'race found on a physical device (see search_screen.dart)', (
    WidgetTester tester,
  ) async {
    const place = Place(
      name: 'LN Artistry',
      address: 'Dindigul, Tamil Nadu',
      latitude: 10.3743,
      longitude: 77.9901,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          searchProvider.overrideWith(
            () => _FixedSearchNotifier(const SearchResults([place])),
          ),
        ],
        child: const MaterialApp(home: _HomeLike()),
      ),
    );

    await tester.tap(find.text('open search'));
    await tester.pumpAndSettle();
    expect(find.byType(SearchScreen), findsOneWidget);

    await tester.tap(find.text('LN Artistry'));
    await tester.pumpAndSettle();

    expect(find.text('route preview marker'), findsOneWidget);
    expect(find.byType(SearchScreen), findsNothing);
  });
}
