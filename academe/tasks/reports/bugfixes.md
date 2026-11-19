# Bug fixes from §11 Known issues (2026-10-05)

Six of the seven rows recorded on 2026-10-04 are fixed. The welcome pitch (row 7) is left alone until the lead USP is decided.

## 1. A folder's date showed the weekday twice

- **Cause**: `dueLabel` in `lib/utils/dates.dart` returned "Fri · 5 days" for dates within a week. The folder header then put `shortDay` in front of it and lower-cased it, which gave "Fri 9 Oct · fri · 5 days".
- **Fix** (all in `dates.dart`, so every caller gets it):
  - `dueLabel` now returns "Today", "Tomorrow", "in N days", "Yesterday" or "N days ago". It no longer includes a weekday.
  - The new `dueLine` returns `shortDay` plus `dueLabel`, for example "Fri 9 Oct · in 5 days".
- **Callers**:
  - The folder header (`folder_parts.dart`) uses `dueLine`.
  - The folder tile tag (`folders_view.dart`) shows "in 5 days".
  - Recent scans (`scan_screen.dart`) show "Today" or "3 days ago".
  - The folder sheet and the plan only use `shortDay`, so they didn't change.
  - Home Today shows no dates.
- **Test**: `test/utils/dates_test.dart`.

## 2. "1 lessons"

- **Cause**: count strings were built by hand in each widget, and only a few of them handled one.
- **Fix**: one helper, `pluralize(count, noun)` in `lib/utils/plural.dart`, used wherever a count is shown:
  - lessons (chapter rows, the chapter screen, folder chapters, Add chapters)
  - cards and quick checks (the lesson start card and the chapter's lesson rows)
  - questions (the chapter test)
  - chapters (the filters sheet, filter chips, Add N chapters)
  - pages (scan notes)
  - minutes (the daily goal sheet)
  - scans and ASKMe questions (the limit sheet)
  - marks (recent scans: "0/1 mark")
  - days (due labels)
  - "things" (the reminder body)
  - folders (the Home Today card)
- The hand-written `== 1 ?` checks it replaces are gone.
- "min" and "XP" don't change in the plural.
- **Server**: "Revise 1 kept cards" in folder plans and Today now reads "Revise 1 kept card" (`folder.reviseTitle`).
- **Tests**:
  - `test/utils/plural_test.dart`
  - `catalogue_test.dart`: "one lesson, card and quick check read in the singular"
  - `folder/plan_test.go`: `TestReviseTitle`

## 3. The streak stayed at 0 (F1, basic)

- **Cause**: nothing computed a streak. Home's flame showed a literal `'0'`, and Me had `static const streak = 0`.
- **What counts as a day**: a day in India time (Asia/Kolkata) counts when the student earns XP (quick checks, setup, subjects) or finishes a lesson or a chapter test.
- **Why there is a new table**: XP alone wasn't enough. Finishing a lesson pays no XP (only right answers do, once per question), so finishing a lesson a second time, or getting every check wrong, wouldn't count. `deck_completions` and `chapter_results` overwrite their timestamp, so they keep no history.
- **Server**:
  - **Migration `0024_study_days.sql`** adds `study_days (account_id, day)`. The default for `day` is today in India time.
  - `study.PostgresStore.Complete` and `SaveChapterResult` insert today's row in the same statement (a CTE that does nothing if the row is already there).
  - The profile query reads the distinct India days from `xp_events` and `study_days`.
  - `profile.streakOn(days, now)` works out:
    - `current`: the run of days up to today. While today isn't counted yet, it runs up to yesterday, so the streak isn't broken until the day is over.
    - `longest`
    - `todayCounted`
  - It uses `time.FixedZone` for India, so it doesn't depend on the image having time-zone data.
  - **`GET /me/profile`** and the `PATCH` response gain `streak: {current, longest, todayCounted}`. This is an additive change. `openapi.yaml` documents the new `Streak` schema and the streak-day note on the completion and chapter-result routes.
- **App**:
  - The `Streak` model sits on `Profile`. It is parsed when the server sends it and is zero when an older server doesn't.
  - Home's flame shows `streak.current`. It is orange once today counts and grey before that. Its semantics label is "N day streak".
  - Me's stats card shows the same number and colour. `_Stats` moved to `me_stats.dart`, which brings `me_screen.dart` under 300 lines.
  - The lesson player already reloads the profile when a lesson or test finishes. Home and Me listen to the profile repository, so the flame updates as soon as the lesson ends.
- **Tests**:
  - `profile/streak_test.go`: `testing/synctest`, including a minute before and a minute after midnight in India, today not counted, a gap and the longest run.
  - `profile/store_test.go` `TestStreakDays` on Postgres: xp events either side of India midnight, plus `study_days`.
  - `study/store_test.go`: Complete and SaveChapterResult record today once.
  - `profile_test.go` `TestRoutes`: `streak` in the JSON.
  - App:
    - Streak JSON in `profile_repository_remote_test.dart`
    - Me shows the streak (`me_screens_test.dart`)
    - Home's flame goes from 0 to 1 when a lesson ends (`study_navigation_test.dart`)

## 4. "Back to chapter" went to the course list

- **Cause**: "Back to chapter" on the lesson-done and chapter-report views just closed the deck. That returned to whatever screen had opened it: Courses' Continue, Home, Today or a folder.
- **Fix** in `lib/ui/shell/widgets/study_navigation.dart`:
  - Chapter routes are remembered by chapter id.
  - `backToChapter(chapterId)` pops to that chapter's route if it is still on the stack. Otherwise it replaces the deck with the chapter screen, so Back from the chapter returns to where the student started.
  - `DeckScreen` takes `onBackToChapter`, which both views use.
  - A lesson without a chapter (lessons made from scanned notes) shows "Done" and just closes.
- **Test**: `test/ui/shell/study_navigation_test.dart`.
  - Opened from Courses → Back to chapter shows the chapter, and Back goes to Courses.
  - Opened from the chapter → it pops back to the same chapter, without a duplicate.

## 5. Log in below the keyboard

- **Cause**: `LoginEmailScreen` had its own `SingleChildScrollView`, without the `reverse: true` that `AuthPage` uses. When the keyboard opened, the bottom of the page was pushed out of view.
- **Fix**: `reverse: true`. The fields, Log in and "New here? Sign up" now stay above the keyboard.
- **Sign-up**: checked. The page is a Column with Pebby in an `Expanded`, so it already shrinks and the button stays above the keyboard. Its test is new.
- **Tests**: `login_email_screen_test.dart` "the fields and Log in stay above the keyboard" (fails without the fix) and `sign_up_screen_test.dart` "the field and Continue stay above the keyboard", both with `FakeViewPadding` insets.

## 6. The tab bar covering content in landscape

- **Cause**:
  - Home, ASKMe, Scan and Me already pad by `MediaQuery.paddingOf(context).bottom`. With `extendBody`, that value is the real height of the floating bar.
  - Courses and Folders used a hard-coded `120`. The bar is 76 plus the system bottom inset, so whenever that inset is over 44 (three-button navigation along the bottom, as on large screens in landscape), the last chapter row or the New folder button ended behind the bar.
  - In widget tests at the Pixel 10's landscape size with gesture navigation, every tab already scrolled clear. If the device still shows the bar over content after this change, it is the bar floating over content while the list is at rest, which `extendBody` does by design. Scrolling should move the content clear.
- **Fix**: Courses and Folders pad by `24 + MediaQuery.paddingOf(context).bottom`, the same as Home and Me.
- **Test**: `test/ui/shell/app_shell_layout_test.dart` runs portrait, landscape and landscape with a 48 dp bottom inset. On Home, ASKMe, Me, Scan, Courses and Folders it flings each list to the end and checks that the last item is above the top of the bar. The third case fails on Courses and Folders without the fix. `test/helpers/shell_app.dart` builds the whole signed-in app on fakes, and the navigation test uses it too.

## Also fixed

- The right-answer praise line ("Nice! That's right.") was in a centred `Row` without `Flexible`. It overflowed by 1 px in the new end-to-end test, and narrow phones at 1.3× text could do the same. It is now `Flexible`.
- `FakeProfileRepository.load` notifies listeners like the real one does, and takes `nextLoad`.
- `integration_test/folders_test.dart` waits for `lessons? done`, because a chapter with one lesson now reads "lesson done".

## Checks run

- Server:
  - `gofmt -l .` printed nothing.
  - `go vet ./...` passed.
  - `golangci-lint run`: 0 issues.
  - `go test -race ./...` against Postgres: all green.
  - `govulncheck`: our code calls no vulnerable function.
- App:
  - `dart format` made no changes.
  - `flutter analyze`: no issues.
  - `flutter test`: all green.
  - Not run on a device, as asked.

## Pixel 10 checks for the orchestrator

Run the server from this worktree (migration 0024 applies at start-up), then the app against it.

1. **Folder date**
   - Make a folder dated 5 days from today. Expect:
     - The folder header reads "<Day> <d> <Mon> · in 5 days", for example "Fri 9 Oct · in 5 days", with the weekday shown once.
     - The tile on Study → Folders shows "in 5 days".
   - Edit the date to tomorrow. Expect "… · Tomorrow" and a rose "Tomorrow" tag.
   - Edit it to today. Expect "… · Today".
   - On Scan, a scan from today shows "Today", and an older one shows "N days ago".
2. **Plurals**
   - Open a chapter that has exactly one available lesson, or add one with Folders → Add chapters → pick 1. Expect:
     - "0 of 1 lesson done"
     - "N cards · 1 quick check" when the lesson has one check
     - The button reads "Add 1 chapter".
   - The Filters sheet shows "Show 1 chapter" when one matches.
   - Scan notes with one page: "Read 1 page", then "Pebby read 1 page".
   - A check scan out of 1 mark: "0/1 mark".
   - With one kept card due, the Today task reads "Revise 1 kept card".
3. **Streak**
   - On a fresh account, after setup, Home shows an orange flame with 1, because the setup XP counts today. Me → the stats card shows "1 · day streak" with an orange flame.
   - On an account with no XP today, finish a lesson, even one that is already done, and tap "Back to chapter" then Back. Expect Home's flame to be orange with today counted, without pulling to refresh.
   - Two days running: yesterday's activity plus none today shows the streak in grey (still yesterday's count). Studying today turns it orange and adds one.
   - Optional, in psql: `INSERT INTO study_days (account_id, day) VALUES ('<id>', current_date - 1), ('<id>', current_date - 2);`, then reopen Home. Expect the flame to be 2 in grey, or 3 in orange if today already counts.
4. **Back to chapter**
   - Study → Courses → tap the Continue card → finish the lesson → "Back to chapter". Expect that lesson's chapter screen. Back then returns to Courses.
   - Home → a lesson task on the Today card → finish → Back to chapter. Expect the chapter. Back returns to Home.
   - From a lesson task inside a folder, the same: the chapter, then Back to the folder.
   - From the chapter → Next lesson → finish → Back to chapter. Expect the same chapter, and only one Back to reach Courses (no duplicate chapter).
   - Chapter test from a folder's "Ch N test" task → report → "Back to chapter". Expect the chapter screen.
5. **Log in with the keyboard**
   - Welcome → Log in → tap Email. Expect Email, Password, "Forgot password?" and the Log in button all above the keyboard, with Password not cut off.
   - Tap Password. Expect the same.
   - Sign up → Hi Pebby! → the name step. Expect the field and Continue above the keyboard.
6. **Landscape**
   - Rotate to landscape on Home, ASKMe, Scan, Study → Courses (a subject with many chapters), Study → Folders (several folders) and Me.
   - On each, scroll to the end. Expect the last row or button to sit fully above the floating tab bar.
   - Repeat in portrait. Optionally switch to three-button navigation in Settings and repeat.
