# Setup

## Prerequisites

- Flutter 3.38.4 (stable channel)
- Dart 3.10.3 (bundled with the Flutter SDK above)
- Android SDK (platform android-36, build-tools 36.1.0 verified working)
- Java/JDK bundled with Android Studio (OpenJDK 21) or equivalent
- Android device or emulator for running the app (optional for build-only workflows)

Verify your toolchain:

```bash
flutter --version
flutter doctor -v
```

## Getting the project running

```bash
cd tn_ar_navigation
flutter pub get
flutter run
```

## Verification commands

```bash
flutter analyze       # static analysis, should report "No issues found!"
flutter test          # widget tests
flutter build apk --debug   # Android debug build (no device required)
```

## Google Maps API key (required since Phase 11)

The map (Google Maps SDK) and search (Places API (New)) are both real
Google Maps Platform services now — see KNOWN_LIMITATIONS.md for why this
replaced the earlier free OpenStreetMap/Nominatim stack. **Nothing map-
or search-related works without a real key configured** — this is not
optional, and there is no free fallback.

1. **Create a Google Cloud project** (or use an existing one) at
   [console.cloud.google.com](https://console.cloud.google.com).
2. **Enable billing** on that project. Google Maps Platform requires a
   billing account even within the free monthly credit — the app will
   not work without one.
3. **Enable these APIs** (APIs & Services → Library):
   - Places API (New) — powers search
   - Maps SDK for Android — powers the visual map on Android
   - Maps SDK for iOS — only if/when iOS is actually built (see below)
4. **Create an API key** (APIs & Services → Credentials → Create
   Credentials → API key).
5. **Restrict the key** (edit the key → Application restrictions →
   Android apps): add this app's package name
   (`com.tnarnav.tn_ar_navigation`) and its debug signing certificate's
   SHA-1 fingerprint (`cd android && ./gradlew signingReport`, look for
   the `debug` variant). Restricting to just the APIs above (API
   restrictions) is also recommended. An unrestricted key that leaks is a
   real liability — this step isn't optional busywork.
6. **Configure the key in two places** (both are gitignored — never
   commit a real key):
   - `android/local.properties`: add a line
     `MAPS_API_KEY=<your real key>` (see the `YOUR_GOOGLE_MAPS_API_KEY_HERE`
     placeholder already there).
   - `.env` in the project root: copy `.env.example` to `.env` and set
     `GOOGLE_MAPS_API_KEY=<your real key>` (used by `GeocodingService`'s
     Places API calls).
   - iOS (only if building for iOS): replace the placeholder in
     `ios/Runner/AppDelegate.swift`'s `GMSServices.provideAPIKey(...)`
     call — hardcoded there rather than injected, since iOS isn't built/
     verified on this project's dev machine yet (see below).
7. Re-run `flutter pub get` if you haven't already, then
   `flutter build apk --debug` or `flutter run` to pick up the new key.

**Security note** (from `flutter_dotenv`'s own documentation): `.env` is
bundled as a Flutter asset, which means it's extractable from a built
APK/IPA by anyone with the file — treat step 5's key restriction as the
real security boundary, not `.env`'s `.gitignore` entry (that only keeps
the key out of *version control*, not out of the *built app*). A
production release should proxy Places/Geocoding calls through a backend
instead of shipping a raw key in the client — not done yet, tracked for
Phase 14.

## Supabase project (required since Phase 14, for auth + saved places)

Auth (sign up/sign in) and saved places are real Supabase-backed features
now. **Nothing auth- or saved-places-related works without a real
project configured** — the rest of the app (GPS, map, search, routing,
navigation, camera, vision) works fine without one; `AuthScreen` and
`SavedPlacesScreen` just show an honest "no backend configured" message
instead of crashing.

1. **Create a Supabase project** at
   [supabase.com](https://supabase.com) (free tier is enough) — new
   organization if needed, then "New Project." Set a database password
   (Supabase requires one; the app itself never uses it) and pick a
   region.
2. **Run the schema**: open the dashboard's SQL Editor → New query →
   paste the contents of `supabase/schema.sql` from this repo → Run.
   Creates the `saved_places` table with Row Level Security policies that
   scope every row to its owner — this is the real access-control
   boundary, not the client key below.
3. **Copy your project's credentials** (Settings → API Keys):
   - **Project URL**
   - **Publishable key** (`sb_publishable_...`) — Supabase's current name
     for what used to be called the "anon" key; safe to ship in a client
     app. Never use a **Secret key** (`sb_secret_...`, the old
     "service_role" key) here — that one can bypass Row Level Security
     entirely and must never leave a server.
4. **Configure `.env`** (gitignored — never commit real credentials): copy
   `.env.example` to `.env` if you haven't already, and set
   `SUPABASE_URL`/`SUPABASE_PUBLISHABLE_KEY` to the real values from step 3.
5. Re-run `flutter build apk --debug` or `flutter run` to pick up the new
   config.

**Email confirmation is currently OFF on this project's Supabase
dashboard** (Authentication → Sign In / Providers → Email → "Confirm
email"). This was a real, deliberate decision made during Phase 14's
live verification: the free-tier shared email service wasn't delivering
confirmation emails in reasonable time, so every sign-up gets a real
session immediately for now. **Revisit this before any production
release** — re-enable confirmation and/or configure a real transactional
email provider (Settings → Auth → SMTP Settings in the dashboard).

## Notes

- This project currently targets **Android first**; the `ios/` folder was
  generated so iOS support remains possible later, but it has not been
  built or verified on macOS/Xcode yet.
- No emulator/physical Android device is required to build the debug APK
  (`flutter build apk --debug` only needs the Android SDK/build tools).
  A device or emulator is only required for `flutter run`.
- Network access to `pub.dev`, `storage.googleapis.com`, and
  `maven.google.com` is required for the first `flutter pub get` / Gradle
  sync (to download dependencies and the Gradle wrapper). Subsequent
  builds work offline once cached.
- Do not add map, routing, AR, AI, GPS, camera, or sensor packages
  without a deliberate decision — see `PROJECT_STATUS.md` and
  `DEVELOPMENT.md` for the phase each capability belongs to. Supabase
  (Phase 14) is the most recently added exception, already wired up per
  the section above.
- From Phase 3 onward, testing on a real Android device (not just an
  emulator) becomes important for GPS/camera/AR/sensor accuracy — a
  device is not required yet, but plan to have one available. This is
  now also true for the Google Maps switch (Phase 11): map rendering and
  search have not been verified against a real key or a real device on
  this project's dev machine — see KNOWN_LIMITATIONS.md.
