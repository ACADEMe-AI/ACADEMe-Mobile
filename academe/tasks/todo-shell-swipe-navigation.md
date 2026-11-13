# Todo: Shell edge-swipe + ASKMe mode swipe

- [x] Task 1: Add `ShellTabs` helper + unit tests
  - Acceptance: `pillOrder == [0,1,3,4]`; `step` hard-stops at ends; never returns 2; Scan prev→1 next→3; `useCardSwipe` only ASKMe↔Home and ASKMe↔Study
  - Verify: `flutter test test/ui/shell/shell_tabs_test.dart`
  - Files: `lib/ui/shell/shell_tabs.dart`, `test/ui/shell/shell_tabs_test.dart`

- [x] Task 2: AppNavBar consumes `ShellTabs.pillOrder`
  - Acceptance: pill still shows Home/ASKMe/Study/Me; no duplicated index list in `_Tabs`
  - Verify: `flutter test test/ui/shell/app_nav_bar_test.dart`
  - Files: `lib/ui/shell/widgets/app_nav_bar.dart`

- [x] Task 3: Shell edge swipe calls `_select(ShellTabs.step(...))`
  - Acceptance: left/right edge changes tab along pill order; hard stop; no mode coupling
  - Verify: widget test and/or manual; `flutter test test/ui/shell/`
  - Files: `lib/ui/shell/widgets/app_shell.dart`, edge overlay widget if extracted, tests

- [x] Task 4: Card transition for edge ASKMe↔Home/Study; basic otherwise
  - Acceptance: `useCardSwipe` drives animation; taps stay basic
  - Verify: manual + existing shell layout tests still pass
  - Files: `app_shell.dart` (+ small transition helper if needed)

- [x] Task 5: ASKMe middle swipe cycles modes; hard stop; horizontal body transition
  - Acceptance: Explain↔Solve↔Quiz via middle swipe; ModeBar synced; ends no shell change; `setMode` only path
  - Verify: `flutter test test/ui/askme/`
  - Files: `askme_screen.dart`, tests

- [x] Task 6: Analyze + regression pass
  - Acceptance: success criteria in spec met; `flutter analyze lib/ui/shell lib/ui/askme`; shell+askme tests green
  - Verify: commands above
