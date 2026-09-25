# ACADEMe — engineering rules

Every change to this app follows these rules. They are distilled from the
official Flutter and Dart guidance, saved verbatim in `docs/flutter-reference/`
— read the source file named in brackets when a rule needs more context.

A change is not done until `flutter analyze`, `dart format`, `flutter test`
and a Pixel 10 run all pass (see **Definition of done**).

The Go backend in `server/` has its own rules: `server/AGENTS.md`.

## 1. Architecture — MVVM, two layers

[flutter-architecture-guide.md, flutter-architecture-recommendations.yml]

- **UI layer**: a *view* (widgets) and a *view model* (a `ChangeNotifier`) per
  feature. Views are dumb: they render view-model state and forward user events.
- **Data layer**: *repositories* (source of truth, business logic, caching) and
  *services* (one per external source: HTTP API, local storage, platform). View
  models talk to repositories, never to services.
- **Domain models** are immutable (`final` fields, `const` constructors,
  `copyWith`), shared by both layers.
- Data flows one way: data layer → view model → view. Events flow back as method
  calls on the view model.
- The only logic allowed in a widget: show/hide on a view-model flag, animation
  maths, layout from screen size, and simple routing.
- Inject dependencies through constructors. No global singletons, no service
  locator reaching into widgets.
- Add a domain layer (use-cases) only when view models start repeating logic.

## 2. Folder structure

[flutter-case-study.md — "Package structure"]

UI is organised by feature, data by type:

```
lib/
  main.dart
  routing/                  router + route names
  config/                   dependencies, environment
  ui/
    core/
      themes/               app_theme.dart — AppColors, AppRadius,
                            AppTextStyles, AppTheme (only place)
      ui/                   shared widgets: buttons, links, headline, stagger
      motion/               keyframe tracks and easing
    <feature>/
      view_models/<feature>_view_model.dart
      widgets/<feature>_screen.dart
      widgets/<other_widgets>.dart
  domain/models/<model>.dart
  data/
    repositories/<name>_repository.dart
    services/<name>_service.dart
    model/<api_model>.dart
  utils/
test/                       mirrors lib/ (test/ui/auth/..., test/data/...)
testing/fakes/              fake repositories and services for tests
```

A feature is one of the product areas in `tasks/roadmap.md` (splash, auth,
onboarding, companion, scan, study, progress, settings, paywall).

## 3. Naming

[effective-dart-style.md]

| Thing | Style | Example |
|---|---|---|
| Files, folders | `lowercase_with_underscores` | `login_email_screen.dart` |
| Classes, enums, typedefs, extensions | `UpperCamelCase` | `LoginEmailScreen` |
| Members, variables, constants, params | `lowerCamelCase` | `headlineSize`, `defaultGap` |
| Private | leading `_`, only when actually private | `_passwordController` |

- One public widget per file, file named after it: `WelcomeScreen` →
  `welcome_screen.dart`. Suffixes: `_screen`, `_view_model`, `_repository`,
  `_service`.
- **No abbreviations** unless universal (`id`, `url`, `ms` is fine in a unit
  suffix). Not `Ac`, `Sz`, `K`, `E`, `c`, `t`, `a`, `deco`. Name it for what it
  is: `AppColors`, `ScreenScale`, `Keyframe`, `Easing`, `controller`, `progress`.
- Durations are `Duration`, not `int` milliseconds.
- Booleans read as questions or states: `isReady`, `showLogIn`, `hasError`.
- Imports: `dart:` first, then `package:`, then relative; alphabetical within
  each group. Relative imports inside `lib/`.

## 4. Comments

**No comments.** Not `//`, not `///`, not `ponytail:`, not `TODO`, in code or
config (Dart, Kotlin, Gradle, XML, YAML). Names carry the meaning; if code
needs explaining, rename or restructure it. Reasons that matter beyond the
code go in this file or `tasks/`.

The only exception is analyzer directives: `// ignore: <lint>`.

## 5. Widgets — when to split

[flutter-performance.md — "Control build() cost", "Pitfalls"]

**Always a widget class, never a method that returns a widget.** `_buildHeader()`
or `Widget _link(...)` helpers are not allowed; extract a `StatelessWidget`
(private `_Header` in the same file is fine). Widget classes can be `const`,
get their own `BuildContext`, and let Flutter skip rebuilding them.

Extract a widget when **any** of these is true:

1. It's used twice → move it to `ui/core/ui/` as a public widget.
2. It changes on its own (its own animation, `setState`, or listener) → extract
   so the rebuild stays inside it.
3. A `build()` method no longer fits on one screen (~60 lines) → split by
   visual region.
4. It has a name in the design (sheet, headline, link row, field).

Keep private in the file until a second screen needs it, then promote to
`ui/core/ui/`.

**Files** stay under ~300 lines. Past that, the private widgets move to their
own files in the feature's `widgets/` folder.

## 6. Performance

[flutter-performance.md, flutter-rendering-performance.md]

- `const` every constructor and literal that can be. Lints enforce it.
- **Localise rebuilds.** Put `setState`, `ListenableBuilder` and
  `AnimatedBuilder` as low in the tree as possible — around the part that
  changes, not the screen. A text field that re-enables a button wraps the
  *button* in a `ListenableBuilder`, not the whole screen in `setState`.
- `AnimatedBuilder`: pass everything that doesn't animate as `child:`; never
  rebuild a static subtree every tick.
- **No `Opacity` in animations.** Use `FadeTransition`, `AnimatedOpacity`, or
  paint with a semi-transparent colour (`color.withValues(alpha: t)`). Static
  "disabled" looks come from the widget's disabled style, not an `Opacity`
  wrapper.
- Prefer `*Transition` widgets (`FadeTransition`, `SlideTransition`,
  `ScaleTransition`) driven by an `Animation` over computing values in `build`.
- No side effects in `build()` — don't set state-machine inputs, start
  controllers or fire callbacks there. Use listeners and `initState`.
- Rounded corners via `borderRadius`, not `ClipRRect`. No clipping inside
  animations. Avoid `saveLayer` triggers (`Opacity`, `ShaderMask`,
  `ColorFilter`, `Clip.antiAliasWithSaveLayer`).
- Lists that can outgrow the screen use `ListView.builder` / slivers. No
  `IntrinsicHeight` / `IntrinsicWidth`.
- Dispose every controller, `FocusNode`, `AnimationController`,
  `StreamSubscription` and Rive controller you create.
- Never override `operator ==` on a widget.
- Keep each frame under 16 ms on the Pixel 10 — check with DevTools'
  performance view when adding motion.

## 7. Design system

- **Colours, type and radii come only from `ui/core/themes/app_theme.dart`.** No hex
  literals, `Colors.*` or raw font sizes in screens. Brand marks drawn to spec
  (the Google "G", `AcademeWordmark`) are the only exceptions.
- Three font families, bundled so iOS and Android render identically:
  - **Baloo 2** 800 — headlines, via `AppTextStyles.display`. Covers all five launch scripts.
  - **Archivo** 700 — subheads, via `AppTextStyles.subhead` (and `titleLarge`/`titleMedium`).
    Latin only: in Hindi, Telugu, Tamil and Bengali it falls back to Noto Sans.
  - **Noto Sans** 400 and 600 — everything else, from the theme. All scripts.
- Screens never set `fontFamily` or a raw weight for a heading level — they use
  `AppTextStyles` and `copyWith` for size and colour only.
- Spacing literals (`SizedBox`, `EdgeInsets`) sit on the 4 pt grid. Sizes that
  depend on the screen come from `ScreenScale`.
  `test/type_consistency_test.dart` enforces both.
- Every screen reads correctly on the Pixel 10 at the default text scale and at
  1.3× — test with the device's font-size setting.

## 8. State and async

- `ChangeNotifier` view models, observed with `ListenableBuilder`. No extra
  state library until one is justified in writing.
- User actions go through **commands** on the view model (running / error /
  completed state) [flutter-pattern-command.md].
- Repositories return `Result<T>` (ok / error), not thrown exceptions
  [flutter-pattern-result.md].
- After any `await`, check `mounted` / `context.mounted` before using context.
- No `print`. Use `debugPrint` or `dart:developer` `log`, and never log
  credentials or tokens.

## 9. Testing

[flutter-case-study-testing.md]

- View models and repositories get unit tests, run against **fakes** in
  `testing/fakes/` — never the real network.
- Each screen gets a widget test covering its main states.
- Wrap the app in `PebbyStandIn` in widget tests: Rive's native text engine
  doesn't load under `flutter test`.
- New screens get a screenshot-harness entry in the same change.
- Tests mirror `lib/`: `test/ui/auth/welcome_screen_test.dart`.

## 10. Android and Play Store

The app ships as an update to the existing Play listing, so these hold from
the first build, not the week of release.

- **Identity never changes**: `applicationId` `com.academe.flutter`.
  `namespace` stays `com.academe.flutter_app` so `MainActivity` keeps the
  published class name and home-screen shortcuts survive the update.
- **Every upload raises the build number** (`version: x.y.z+N` in
  `pubspec.yaml`). The old app's last upload is 1.0.5+6.
- **16 KB memory pages**: every native library in a release APK has a LOAD
  alignment of 0x4000 or more. Check after adding or upgrading any plugin with
  native code:

  ```
  flutter build apk --release
  zipalign -c -P 16 -v 4 build/app/outputs/flutter-apk/app-release.apk
  llvm-readelf -lW <each lib/*/*.so>   # LOAD align ≥ 0x4000
  ```

  A plugin that fails is upgraded or replaced, never shipped.
- **Edge-to-edge**: every screen draws behind the system bars and pads its
  content with `SafeArea` or the view insets. Bar icons come from
  `AppSystemBars`; never set `statusBarColor`, `systemNavigationBarColor` or
  `systemNavigationBarDividerColor` (deprecated from Android 15).
- **Large screens**: no orientation lock (`screenOrientation`,
  `setPreferredOrientations`) and no `resizeableActivity="false"`. Screens
  work in portrait and landscape and on tablets: content is width-capped and
  scrolls when height runs out.
- `targetSdk` and `compileSdk` follow Flutter's defaults, which track Play's
  requirement. Don't pin them lower.
- **Permissions**: only what the app uses. Plugins that add extras get them
  stripped in `AndroidManifest.xml` with `tools:node="remove"`; check with
  `aapt dump permissions <apk>`. Today: `INTERNET`, `POST_NOTIFICATIONS`
  (study reminders, asked the first time there is a reminder to send) and
  `RECEIVE_BOOT_COMPLETED` (scheduled reminders survive a restart). The
  notifications plugin's `VIBRATE` is stripped. ACADEMe Pro (RevenueCat and
  Play Billing) adds `com.android.vending.BILLING` and `ACCESS_NETWORK_STATE`.
- Both Android themes set `android:defaultFocusHighlightEnabled` to `false`.
  Otherwise any hardware key press (a keyboard, or typing into the emulator)
  draws Android's green focus outline around the whole Flutter view; focus
  rings are Flutter's job.
- `android:allowBackup="false"`: `flutter_secure_storage` keys can't be
  restored onto another device, so a backed-up session would only break.
- Release builds refuse plain `http`; the debug-only network security config
  allows `10.0.2.2` and `localhost` for the local server.
- Upload signing (`android/key.properties` and the keystore) is set up only
  when preparing a release; both stay out of git.

## 11. Server and environment

The app reads its settings from `--dart-define`s (`lib/config/environment.dart`):

| Define | Default | Meaning |
|---|---|---|
| `API_BASE_URL` | `http://10.0.2.2:8080` | the Go server; the default is the Mac as seen from the emulator |
| `GOOGLE_SERVER_CLIENT_ID` | empty | the **web** OAuth client ID; empty = Google shows "isn't ready yet" |
| `REVENUECAT_GOOGLE_API_KEY` | empty | RevenueCat public Android key (`goog_…`); empty = the paywall says purchases aren't available |
| `REVENUECAT_APPLE_API_KEY` | empty | RevenueCat public iOS key (`appl_…`), for the iOS release |

Sessions: the refresh token and the account live in `flutter_secure_storage`
(`SecureSessionStore`); the access token only in memory. `AuthRepositoryRemote`
refreshes once on a 401 and retries; a rejected refresh signs the student out.


## 12. Definition of done

All of these, every change:

```
dart format lib test          # formatted, 80 columns
flutter analyze               # zero issues — infos included
flutter test                  # all green
flutter run -d emulator-5554  # looks right on the Pixel 10
```

Never run ACADEMe on macOS, Chrome or the iOS simulator for sign-off — the
Pixel 10 is the reference device.

Then tick the task in `tasks/roadmap.md` and add a line to its change log.
