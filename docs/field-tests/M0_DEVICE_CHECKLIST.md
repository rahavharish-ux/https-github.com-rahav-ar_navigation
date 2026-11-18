# M0 device checklist — camera lifecycle and navigation state

Run on a physical Android phone with a **debug** build of the M0 commits.
Nothing here has been run yet. Record results in the table at the end.
Covered by unit/widget tests; this checklist confirms real Android
behaviour that tests cannot reach (camera hardware, OS lifecycle, GPS,
network timing).

**Setup**
- `adb devices` shows the phone; `flutter run --debug` installed the app.
- Package: `com.tnarnav.tn_ar_navigation`.
- Camera-in-use check used below:
  `adb shell dumpsys media.camera | grep -iA3 "active camera clients"` —
  our package listed = camera open; absent = released.
- Keep `adb logcat | grep -iE "flutter|camera"` running; any uncaught
  exception or `Cannot use the Ref` message is a failure.

## A. Camera lifecycle

Screens: home → bug icon (Diagnostics) → **Preview camera** (Camera
Preview) and **Preview vision** (Computer Vision). Run A1–A5 on **both**.

| # | Steps | Expected |
|---|---|---|
| A1 | Open the screen | "Starting the camera…" then live preview. dumpsys lists our package |
| A2 | Press Home (background). Wait 5 s | dumpsys **no longer** lists our package. Open the system Camera app: it works (camera not held by us). Close it |
| A3 | Return to the app (recents) | Brief "Starting the camera…", then live preview again (not frozen/black). dumpsys lists our package once (not twice) |
| A4 | Repeat A2–A3 five times quickly | Preview recovers every time; no crash, no error screen |
| A5 | Lock screen while preview is showing, unlock | Same as A2/A3 |
| A6 | Press back to leave the screen, then Home, then return | Camera stays closed (dumpsys: not listed); app shows Diagnostics, no preview restarts in the background |
| A7 | **Stop during initialization:** open the screen and press back immediately (within ~0.5 s, while "Starting the camera…" shows). Repeat 5× | No crash; after each, dumpsys does **not** list our package (late-initialized camera was released) |
| A8 | **Background during initialization:** open the screen and press Home immediately; wait 5 s; return | Camera not held while backgrounded (check dumpsys during the wait); on return the preview starts normally |
| A9 | (Vision only) Tap **Scan text**, and press Home before the result appears; return | No crash or red error in logcat; screen returns to preview; result area shows either a result or the idle prompt |

## B. Camera permission

Reset first: `adb shell pm revoke com.tnarnav.tn_ar_navigation android.permission.CAMERA`
(Android kills the app process on revoke — relaunch it).

| # | Steps | Expected |
|---|---|---|
| B1 | Open Camera Preview → system dialog → **Don't allow** | Permission-denied message with **Try again**; no crash. dumpsys: not listed |
| B2 | Tap **Try again** → dialog (if Android shows it again) → **Allow** | Live preview appears. (The dialog briefly makes the app `inactive`; the camera start must **not** be cancelled by it) |
| B3 | Revoke again, open Camera Preview, deny twice (Android then stops asking) | Denied message persists; Try again does not crash |
| B4 | Grant in system Settings → Apps → app → Permissions → Camera → Allow; return to the app | After Try again (or reopening the screen), live preview appears |
| B5 | Repeat B1–B2 from the Computer Vision screen | Same results |

## C. Navigation state

Requires a working Maps/Places key (see SETUP.md), GPS, and a destination
~1–2 km away. **Triggering a reroute:** leave the drawn route by more than
~40 m (walk/drive down a side street), or use a mock-location app
(Developer options → *Select mock location app*) to move the position off
the line. **Making a reroute slow enough to interact with:** a reroute
normally finishes in under a second; on an emulator use
`adb emu network delay <ms>` (or a throttled network) so the
"Recalculating your route…" banner stays up for several seconds (the
request times out after 10 s). Note which method you used.

| # | Steps | Expected |
|---|---|---|
| C1 | Search a destination → Route preview → **Start Navigation** | Instruction card with distance to next turn; bottom panel shows time · distance remaining; the remaining distance is never smaller than the distance to the next turn |
| C2 | Leave the route | "You're off the route." then "Recalculating your route…", then a new route line and new instruction |
| C3 | Trigger a reroute; while "Recalculating…" shows, press **Stop** | Returns to Route Preview. Wait 15 s: nothing navigates, no navigation screen reappears, no banner flashes |
| C4 | Immediately after C3, **Start Navigation** again (same or a different destination); wait 15 s | The new session shows **its own** route; the earlier reroute's result never replaces it |
| C5 | Trigger a reroute; while "Recalculating…" shows, press **Pause**; wait until the request has finished (≥ 12 s) | Banner stays **"Navigation paused"**; it must not switch back to instructions by itself. (The route line may update to the new route) |
| C6 | Continue C5: press **Resume** | Instructions follow the **new** route from your current position |
| C7 | Trigger a reroute, press **Pause**, then **Resume** before the reroute finishes | Shows "Recalculating…" (not old-route instructions); only **one** reroute happens (with `adb logcat` / network inspector, if available); then normal instructions |
| C8 | Pause, move ≥ 50 m along the route, stand still, Resume | Distance to next turn reflects where you are now, without needing to move again |
| C9 | Pause → Stop; and Stop → (nothing) | Both return cleanly to Route Preview; no crash |
| C10 | Background the app during navigation for 30 s, return | Session still shown; note whether position updated while backgrounded (background tracking is not configured — expected to pause; record observed behaviour) |

## Results

| Field | Value |
|---|---|
| Date / tester | |
| Device model / Android version | |
| App build (commit) | |
| Reroute-slowing method (C) | |

| Check | Pass / Fail | Notes |
|---|---|---|
| A1–A9 (Camera Preview) | | |
| A1–A9 (Computer Vision) | | |
| B1–B5 | | |
| C1–C10 | | |

Any failure: note the step, what was seen, and attach the logcat excerpt.
