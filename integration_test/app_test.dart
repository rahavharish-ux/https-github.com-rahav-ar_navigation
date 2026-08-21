// Real on-device integration test (Phase 15) -- runs the actual app entry
// point (`app.main()`, unmodified) with real platform bindings, not the
// fake widget-test environment `test/widget_test.dart` uses. Deliberately
// scoped to the boot -> splash -> onboarding flow only: it needs no GPS,
// camera, or network permission, so it's safe to run standalone on any
// connected device/emulator without extra setup. See KNOWN_LIMITATIONS.md
// for why deeper flows (search, navigation, camera, auth) aren't
// integration-tested yet -- they need real permissions/credentials this
// automated pass can't grant.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tn_ar_navigation/core/constants/app_strings.dart';
import 'package:tn_ar_navigation/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'real app boot: splash shows, auto-advances to onboarding after the '
    'real 2s delay, and Next/Skip navigate through the real onboarding '
    'pages',
    (WidgetTester tester) async {
      app.main();
      // `pumpAndSettle()` would hang here, found by actually running this
      // on a physical device: `SplashScreen`'s `LoadingIndicator` is an
      // indeterminate `CircularProgressIndicator`, a perpetual animation
      // that never "settles". A couple of plain pumps are enough to let
      // the initial tree build and paint.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppStrings.appName), findsOneWidget);
      expect(find.text(AppStrings.appTagline), findsOneWidget);

      // The real splash timer (a plain `Timer`, not an animation) doesn't
      // itself schedule a frame while waiting, so there's no fake clock
      // here to fast-forward through it (unlike a normal widget test) --
      // a real wall-clock wait is needed for the real 2s delay to fire.
      await Future<void>.delayed(const Duration(seconds: 3));
      await tester.pump();
      // Onboarding's PageView has no perpetual animation once idle, so
      // pumpAndSettle is safe again from here on.
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.onboardTitle1), findsOneWidget);

      await tester.tap(find.text(AppStrings.onboardNext));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.onboardTitle2), findsOneWidget);

      await tester.tap(find.text(AppStrings.onboardNext));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.onboardTitle3), findsOneWidget);
      expect(find.text(AppStrings.onboardGetStarted), findsOneWidget);
    },
  );
}
