# M0 device checklist — camera lifecycle and navigation state

Run on a physical Android phone with a **debug** build of commit
`b6e0d7f` or later on branch `claude/phase-2-technical-audit-2di7x1`.
**Status: not run yet.** Results are recorded only from the tester's
observations (see the table at the end) — nothing here is pre-marked as
passed. Unit/widget tests already cover the logic; this checklist
confirms real Android behaviour tests can't reach (camera hardware, OS
lifecycle, permission dialogs, GPS, network timing).

## 0. Before you start (≈10 min, once)

1. **Get the code** on the computer that already has your real keys
   (`android/local.properties` with `MAPS_API_KEY`, and `.env`):
   ```
   git fetch origin
   git checkout claude/phase-2-technical-audit-2di7x1
   git pull
   flutter --version        # must say 3.38.4
   flutter pub get
   ```
   (A CI-built APK has placeholder keys: fine for sections A and B, but
   the map and search won't work, so section C needs this local build.)
2. **Phone:** Settings → About phone → tap *Build number* 7× to enable
   Developer options; Developer options → **USB debugging** on. Connect
   USB and accept the "Allow USB debugging" prompt.
3. `adb devices` lists the phone as `device`.
4. `flutter run --debug` — wait for the app to open. Leave this terminal
   running; it shows Flutter errors.
5. **Second terminal — camera-in-use check** (the `grep` runs on the
   phone, so this works from Windows cmd/PowerShell too):
   ```
   adb shell "dumpsys media.camera | grep -i 'client package'"
   ```
   A line containing `com.tnarnav.tn_ar_navigation` = our app holds the
   camera. No such line = released. (If your Android version prints
   nothing for this even while the camera is open, use the fallback in
   A2: whether the system Camera app can open.)
6. **Third terminal — error watch:**
   Windows: `adb logcat | findstr /i "flutter exception"` ·
   macOS/Linux: `adb logcat | grep -iE "flutter|exception"`.
   Any uncaught exception, red error screen, or a line containing
   `Cannot use the Ref` during a check = **Fail** for that check.
7. Note your phone model and Android version for the results table.

## A. Camera lifecycle

Screens: home → bug icon (Diagnostics) → **Preview camera** (Camera
Preview) and **Preview vision** (Computer Vision). Run A1–A8 on **both**
screens; A9 on Computer Vision only.

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
| A9 | (Vision only) Tap **Scan text** and press Home **immediately** (the capture is quick — try 3 times); return | No crash or red error in logcat; screen returns to preview; result area shows either a result or the idle prompt |

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

Requires the local build from §0 (working Maps/Places key), GPS with a
clear sky view, and a destination ~1–2 km away. Do this on foot or as a
passenger — never operate the phone while driving.

**Triggering a reroute.** Leave the drawn route by more than ~40 m (turn
down a side street and keep going ~50 m). Alternative: a mock-location
app (Developer options → *Select mock location app*) to move your
position off the line.

**Making a reroute last long enough to press a button.** Normally a
reroute finishes in under a second, too fast for C3/C5/C7. On a phone:
turn **off the test phone's mobile data**, then connect it to a Wi-Fi
network that has **no internet** — e.g. a hotspot from a second phone
whose own mobile data is off (if Android asks whether to stay connected
to a network without internet, choose to stay). Turning mobile data off
matters: otherwise Android quietly sends traffic over mobile data and the
reroute succeeds instantly. The reroute request then hangs until its
10 s timeout and *fails*, so "Recalculating your route…" stays up for
~10 s. If it still disappears within a second, the technique isn't
working on your phone — note that and skip C3–C7's timing-dependent
parts. Switch mobile data back on afterwards. (The map may stop loading
new tiles while offline; that's expected.) This tests the **failure** path; a slow-but-successful
reroute is hard to produce by hand on a phone — if you can't, mark C5's
success variant "not tested" (the logic is covered by unit tests).
Note which method you used in the results table.

| # | Steps | Expected |
|---|---|---|
| C1 | Search a destination → Route preview → **Start Navigation** | Instruction card with distance to next turn; bottom panel shows time · distance remaining; the remaining distance is never smaller than the distance to the next turn |
| C2 | Leave the route | "Recalculating your route…" ("You're off the route." may flash too briefly to see), then a new route line and new instruction |
| C3 | Trigger a reroute; while "Recalculating…" shows, press **Stop** | Returns to Route Preview. Wait 15 s: nothing navigates, no navigation screen reappears, no banner flashes |
| C4 | Immediately after C3, **Start Navigation** again (same or a different destination); wait 15 s | The new session shows **its own** route; the earlier reroute's result never replaces it |
| C5 | On the no-internet Wi-Fi: trigger a reroute; while "Recalculating…" shows, press **Pause**; wait 15 s | Banner stays **"Navigation paused"** the whole time — it must **not** change to "You're off the route." or to instructions by itself when the request times out. *(Before the M0 closure fix it switched to "off the route".)* |
| C6 | Continue C5: switch the phone back to working data, press **Resume**, keep walking off the old route | Leaves "paused"; within a few seconds a fresh reroute runs and instructions follow the **new** route from where you are now |
| C7 | On the no-internet Wi-Fi: trigger a reroute, press **Pause**, then within ~2 s press **Resume** | Banner shows **"Recalculating your route…"** (not old-route instructions, not "paused") until the request ends (~10 s), then "You're off the route." Then switch to working data: one fresh reroute, then instructions |
| C8 | Pause, move ≥ 50 m along the route, stand still, Resume | Distance to next turn reflects where you are now, without needing to move again |
| C9 | Pause → Stop; and Stop → (nothing) | Both return cleanly to Route Preview; no crash |
| C10 | Background the app during navigation for 30 s, return | Session still shown; note whether position updated while backgrounded (background tracking is not configured — expected to pause; record observed behaviour) |

## Results

Fill in from what you observed. Leave a check blank or write
"not tested" if it wasn't run — only checks you actually ran and saw
behave as expected are recorded as Pass.

| Field | Value |
|---|---|
| Date / tester | |
| Device model / Android version | |
| App build (commit, debug) | |
| Reroute-slowing method (C) | |

| Check | Camera Preview | Computer Vision | Notes |
|---|---|---|---|
| A1 Open | | | |
| A2 Background → released | | | |
| A3 Resume → re-opened | | | |
| A4 5× background/resume | | | |
| A5 Lock/unlock | | | |
| A6 Leave screen, background | | | |
| A7 Back during init | | | |
| A8 Home during init | | | |
| A9 Home during scan | n/a | | |
| B1 Deny | | | |
| B2 Try again → Allow | | | |
| B3 Deny twice | | n/a | |
| B4 Grant in Settings | | n/a | |
| B5 B1–B2 on Vision | n/a | | |

| Check | Result | Notes |
|---|---|---|
| C1 Start navigation | | |
| C2 Reroute | | |
| C3 Stop during reroute | | |
| C4 New session after C3 | | |
| C5 Pause during reroute | | |
| C6 Resume after C5 | | |
| C7 Pause → Resume during reroute | | |
| C8 Resume after moving | | |
| C9 Pause→Stop / Stop | | |
| C10 Background during navigation | | |

For any failure: the step, what you saw, and the logcat lines from §0.6.
