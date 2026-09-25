# Notifications permission (Android + iOS)

## What was built

- **Primer sheet** — `lib/ui/notifications/widgets/notification_primer_sheet.dart`.
  Pebby (encourage pose), "Get a nudge before your test", three lines on what
  we send (test heads-ups 3 days / evening before / morning of, the study
  reminder on the chosen days, nothing else), **Allow** and **Not now**.
  Allow triggers the OS prompt; Not now or dragging it away does not.
- **When it shows** — `NotificationPrimerHost` wraps `AppShell` in
  `_HomePage` (`lib/routing/router.dart`) and listens to
  `NotificationPrimerViewModel`. `ReminderRepository.refresh()` raises
  `wantsPrimer` once: the first time there is a reminder to send *or* a folder
  with a date and reminders on, and only when the OS can still prompt and the
  primer hasn't been shown before (`Hint.notificationPermission`).
- **Android < 13** — the Kotlin channel reports `canRequest = false`, so no
  primer and no prompt. Notifications are on by default there; if the user
  switched them off, Me shows "Turn on in Settings".
- **Access state** — `NotificationAccess { unknown, allowed, askable, blocked }`
  in `lib/domain/models/reminder.dart`; `ReminderRepository` is now a
  `ChangeNotifier` exposing `access`, `wantsPrimer`, `answerPrimer`,
  `requestPermission`, `turnOn`, `checkAccess`. `Hint.notificationPrompt`
  (new enum value in `hint_store.dart`) records that the OS prompt was shown,
  so "Not now" still leaves a one-tap OS prompt in Me (important on iOS, where
  an app that never asked has no Notifications entry in Settings).
- **Me → Notifications** (`lib/ui/me/widgets/notifications_screen.dart`) —
  a "Notifications" group at the top: `Allowed` / `Not allowed`; when not
  allowed, a row "Turn on notifications" (never prompted: runs the OS prompt)
  or "Turn on in Settings" (denied: opens the app's system notification
  settings). `MeViewModel` takes an optional `ReminderRepository`.
- **Resume** — `AppLifecycleListener(onResume)` in the host calls
  `checkAccess()`; a switch to allowed re-runs `refresh()`, so reminders get
  scheduled the moment permission comes back from Settings or the prompt.
  Scheduling is now skipped while not allowed (iOS refuses unauthorised
  requests) and done on grant.
- **Service** — `LocalNotificationService` gains `isAllowed`
  (Android `areNotificationsEnabled`, iOS `checkPermissions().isEnabled`),
  `canRequest`, `requestPermission` (Android 13 runtime permission; iOS
  `requestPermissions(alert, badge, sound)`), `openSettings`. Darwin init no
  longer auto-requests (`request*Permission: false`); iOS details added.
- **Platform channel `academe/notification_settings`** (no new dependency):
  - Android `MainActivity.kt`: `canRequest` = SDK ≥ 33; `open` =
    `ACTION_APP_NOTIFICATION_SETTINGS` (API 26+), app details before that.
  - iOS `AppDelegate.swift`: `canRequest` = true; `open` =
    `openNotificationSettingsURLString` (iOS 16+) else `openSettingsURLString`.
  - permission_handler was not added: the plugin already covers check and
    request; only "open settings" and the SDK check were missing, ~30 lines
    of native code.

## iOS project

`ios/` already existed (UIScene template, bundle id `com.academe.flutter`,
deployment target 13.0), so no `flutter create` was needed. `AppDelegate`
now sets `UNUserNotificationCenter.current().delegate` in
`didFinishLaunching` and registers `FlutterLocalNotificationsPlugin
.setPluginRegistrantCallback` in `didInitializeImplicitFlutterEngine`, as the
plugin README requires for UIScene apps. Local notifications need no
Info.plist keys, so Info.plist is untouched.

`flutter build ios --no-codesign --debug` **builds** (Xcode 26.6, CocoaPods
1.16.2). The first attempt failed in rive_native's build hook ("setup marker
not found"); running `dart run rive_native:setup --platform ios` once fixed it
(unrelated to this work, but every fresh iOS machine will need it).

## Tests

- `test/data/repositories/reminder_repository_test.dart` — ask-once logic:
  no primer with nothing to send; first dated folder raises it once; Allow
  prompts and schedules; Not now never re-shows it but Me can still prompt;
  denied → Settings; granted in Settings → rescheduled on resume; Android < 13
  never primes.
- `test/ui/notifications/notification_primer_host_test.dart` — sheet appears,
  Allow prompts, Not now doesn't and never returns; fonts check.
- `test/ui/me/notifications_screen_test.dart` — allowed / never asked /
  denied states and their taps.
- `testing/fakes/fake_notification_service.dart` updated (grant, prompt
  availability, settings-opened counter).
- The old "asked once" test in `test/domain/reminder_test.dart` moved to the
  repository test.
- `dart format` clean, `flutter analyze` clean for my files (one unrelated
  warning in `integration_test/auth_test.dart` owned by another agent),
  full `flutter test` green (115), `flutter build apk --debug` and
  `flutter build ios --no-codesign --debug` both build.

## Needs the user

- Run on the Pixel 10 (not done here: the emulator belongs to the UI test
  agent) and a real iPhone/simulator check of the prompt and the Settings
  deep link — neither could be run by this agent.
- iOS signing / Apple team for a device build.

## Known limits / future

- No screenshot-harness (integration_test) entry for the primer yet — the
  harness runs on the emulator, owned by the UI test agent.
- iOS "provisional" (quiet) authorisation isn't used; could be offered to
  skip the prompt entirely.
- Strings are English only, like the rest of Me today.
- "When my streak is about to end" and "When I level up" toggles still don't
  schedule anything (pre-existing); the primer copy doesn't promise them.
