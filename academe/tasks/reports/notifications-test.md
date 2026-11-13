# Notifications permission: test and review

Tester's review of the notifications-permission workstream (`tasks/reports/notifications.md`).
No device or emulator was used. The UI test agent runs the device checks (listed at the end).

## Fixed

1. **Existing users got the wrong behaviour.** Before this change, `Hint.notificationPermission`
   meant "the OS prompt has been shown" (the old code asked once, straight away). The new code
   gave that name to "the primer has been shown" and added a new `Hint.notificationPrompt` for
   the OS prompt. So an existing Android 13+ user who had already denied looked "never asked"
   (`askable`). Me offered "Turn on notifications", which re-ran the OS prompt instead of
   opening Settings.
   Fix: the hint keeps its old meaning. `Hint.notificationPermission` is the OS prompt again, and
   the primer uses a new `Hint.notificationPrimer` (`lib/data/services/hint_store.dart`,
   `lib/data/repositories/reminder_repository.dart`). An existing user who already allowed ends up
   `allowed`: no primer, and reminders are scheduled. One who denied ends up `blocked`: no primer,
   and Me opens Settings. This also removes the stale `notificationPrompt` value.
2. **The primer could be missed if it was raised before the host mounted.** The host only
   listened for changes, so if `wantsPrimer` was already true when `NotificationPrimerHost`
   mounted (for example after logging out and back in while a refresh was still running), the
   primer never showed. The repository's `!_wantsPrimer` guard stops it from notifying again.
   Fix: the host also checks once in a post-frame callback, guarded by `mounted`
   (`lib/ui/notifications/widgets/notification_primer_host.dart`).

## Tests added

- `test/data/repositories/reminder_repository_test.dart`:
  - An existing user who already allowed gets no primer and reminders are scheduled.
  - An existing user who denied is `blocked`, gets no primer, and Turn on opens Settings (no prompt).
  - A resume while still denied schedules nothing.
- `test/ui/notifications/notification_primer_host_test.dart`: Allow, then denied, then allowed in
  Settings. The real `AppLifecycleListener` resume (lifecycle walked
  inactive → hidden → paused → back → resumed) re-checks access and schedules the reminders.

## Reviewed, no change needed

- **Shows once / never shows:** raised only when something is to be sent, access is `askable`,
  and neither the primer hint nor `_wantsPrimer` is set. Allow, Not now and drag-dismiss (`null`)
  all mark the hint. The `_isShowing` guard stops a second sheet.
- **OS prompt only on Allow:** `requestPermission` is reached only from `answerPrimer(allow: true)`
  or the Me "Turn on" row. Darwin init now has `request*Permission: false`, so iOS no longer
  prompts at plugin init.
- **Android < 13:** the channel's `canRequest` is `SDK_INT >= TIRAMISU`. Below 13 the state is
  `allowed`, or `blocked` if the user turned it off, and blocked leads to Settings. The primer
  never shows.
- **iOS:** `checkPermissions().isEnabled` is `authorizationStatus == Authorized` in plugin 22.3.1
  (provisional is not counted, and the app doesn't use provisional). notDetermined → `askable`;
  after the prompt → `allowed` or `blocked`. Blocked uses `openNotificationSettingsURLString` on
  iOS 16+ and `openSettingsURLString` below that.
- **Scheduling:** `replaceAll` runs only while `allowed`. `checkAccess` re-runs `refresh()` on any
  change from not-allowed to allowed. A double `checkAccess` (the prompt's own call plus the
  resume after the Android dialog) can run `replaceAll` twice at once. Both use the same list and
  the same ids, so the end state is the same.
- **Listeners:** the primer view model removes its repository listener in `dispose()`, which the
  router calls. The host removes its listener and disposes `AppLifecycleListener`.
  `MeViewModel.dispose` removes the reminders listener, but the router's `_HomePageState` never
  disposes `_me` (or `_home`, `_study`, …). That problem predates this work and applies to all
  the view models. It now also leaves one listener on the long-lived `ReminderRepository` per
  logout. The leak is small and doesn't crash; worth fixing in the router separately.
- **No channel (tests, desktop):** `canRequest` and `openSettings` catch `MissingPluginException`.
  All tests use `FakeNotificationService`.
- **MainActivity.kt:** `ACTION_APP_NOTIFICATION_SETTINGS` + `EXTRA_APP_PACKAGE` (API 26+) with
  `packageName` (runtime = `com.academe.flutter`, correct even though the Kotlin namespace is
  `com.academe.flutter_app`). Pre-26 falls back to `ACTION_APPLICATION_DETAILS_SETTINGS` with a
  `package:` URI. Correct.
- **AppDelegate.swift** vs the flutter_local_notifications 22.3.1 README (UIScene section):
  `UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate` in
  `didFinishLaunching`, and `setPluginRegistrantCallback` in `didInitializeImplicitFlutterEngine`.
  This matches the README. The custom channel is registered through a registrar's messenger. OK.
- **AGENTS.md:** no comments in any touched file (Dart, Kotlin, Swift). Widgets are classes
  (`_Promise`, `_AccessGroup`). Colours come from `context.palette` / `AppColors`, and the barrier
  matches the other sheets. Spacing is 4, 8, 12, 16, 24, 40, 52, 120. All files are under 300
  lines (the largest is the Me screen at 215). Tests mirror lib.
- **Minor UX notes (not bugs):**
  - The group title and the row label are both "Notifications".
  - On Android 13, a user who dismisses the system dialog without choosing (tap outside) is
    treated as `blocked`, so Me opens Settings rather than prompting again. That still works.

## Runs

- `flutter analyze`: one issue, an unused import in `integration_test/auth_test.dart` (another
  agent's file).
- Notification, reminder and Me tests: 27 passed (after the fixes).
- Full `flutter test`: 135 passed. One run in between failed to compile `askme_screen.dart` and
  `scan_parts.dart` while another agent was part-way through its limits change; the suite was
  green again once that change landed.
- `flutter build apk --debug`: builds (not installed).
- `flutter build ios --no-codesign --debug`: builds.

## Left for the device check (UI test agent, Pixel 10, API 36)

1. Fresh install: create a folder with a date and reminders on. The primer appears once. Not now
   closes it with no system dialog. Relaunch: no primer. Me → Reminders and goal shows
   "Not allowed / Turn on notifications", and tapping it shows the system dialog.
2. Fresh install: primer → Allow shows the system dialog, then Allow. Me shows "Allowed".
   `adb shell dumpsys alarm | grep com.academe.flutter` (or `cmd notification`) shows scheduled
   alarms.
3. Primer → Allow → Don't allow. Me shows "Turn on in Settings", which opens the app's
   notification settings page (not app info). Switch it on and go back: Me shows "Allowed"
   without a restart, and reminders are scheduled.
4. After allowing, revoke in Settings and return. Me shows "Not allowed / Turn on in Settings".
5. Primer dragged down counts as Not now: no system dialog, and it doesn't return.
6. Primer look: Pebby, title, three lines and two buttons fit without scrolling, in light and dark.

iOS (prompt, Settings deep link, delivery) needs a simulator or iPhone. Neither agent can do that
here, so it is for the user.
