# Subjects and filters (S5, E14, E15, G2)

The spec was `design/preview/subjects-designs.html`, with Home built as option C ("Subject rows").

## What was built

### Server

- **Migration `0023_profile_subjects.sql`** adds `profiles.subjects text[]`. NULL means the student hasn't saved any picks yet.
- **`PATCH /me/profile`** accepts `subjects`:
  - Every code must appear in `profile.Subjects(class, board)`, using the class and board as they stand after the update. English is required.
  - Codes are saved in board order with duplicates removed.
  - Errors return 422 `invalid_subjects`: no class and board yet, a subject that isn't taught in them, or no English.
- **Changing class or board** filters out picks the new syllabus doesn't teach. Crossing between Class 10 and Class 11 clears the picks (back to NULL), because the senior subject lists are different.
- **XP**: `setupDone` means what it meant before. Language, birth year, class and board together still pay 100 XP (reason `setup`). The first save of subjects pays 25 XP once (reason `setup:subjects`). A new student finishes setup with 125 XP, and an existing student also gets the 25 the first time they pick subjects. Old app builds behave exactly as they did before.
- **`GET /me/profile`** returns `subjects`, which is null until the student saves picks.
- **`GET /catalog/streams?class=11|12&board=CBSE|ICSE`** returns the four streams with their main and optional subjects (`profile/streams.go`):
  - Science · PCM, Science · PCB, Commerce and Humanities.
  - English always comes first in the main list.
  - Commerce uses `business-studies` on CBSE and `commerce` on ISC.
  - Any other class returns 400 `invalid_query`.
- **`GET /study/decks`** only adds fields:
  - `subjects[]`: every subject for the class and board, in board order, with `chapters`, `lessonsAvailable` and `lessonsDone`.
  - `minutes` on each deck and on each available planned lesson.
  - On each chapter: `revisionDue` (kept or missed cards due now), `marks` (when the syllabus gives marks for that chapter alone) and `lastStudiedAt` (when a lesson in it was last finished).
  - `Service.Catalogue` reads completions, positions and kept cards once per request. Before, the decks and the chapters each read them separately.
- `syllabus.Plan` now carries chapter marks.
- `openapi.yaml` documents all of the above. It also adds a shared `Subject` schema.

### App

- **Data**:
  - `Profile.subjects`, `hasPicks`, `studies(id)` (true for every subject when there are no picks), `isSenior` and `syllabusLabel`.
  - `ProfileUpdate.subjects`.
  - `StudyStream` model, `ProfileRepository.streams()` (cached per class and board).
  - `SubjectProgress`, plus the new catalogue fields.
  - `Hint.pickSubjects`.
- **Picker** (`lib/ui/subjects/`):
  - `SubjectsViewModel` uses commands for load and save.
  - Class 6–10 starts with the usual subjects on (everything except Sanskrit and Computer Applications) and English locked.
  - Class 11–12 starts on the stream cards. Choosing a stream turns its main subjects on and keeps any optional picks the new stream also offers. Saved picks bring their stream back.
  - The same view model drives setup step 5, the Home Edit sheet, the "Pick your subjects" card and Me → Class and board.
  - `SubjectPills`, `StreamCards` (swipe cards like the language step), `SubjectsPicker` and `SubjectsSheet`.
- **Setup**: `SetupTask.subjects` is step 5 ("SET UP · 5/5", +25 XP, Later). The board step now says "Continue" and the subjects step says "Finish setup".
  - On Class 11–12, Back on "Anything else?" returns to the stream cards.
  - The checklist reads "0 / 125 XP", and the finish flight shows the XP actually earned (+125, or +100 after Later on step 5).
  - The subjects item opens the class step if class or board is missing.
- **Home**:
  - `SubjectRows` lists only the picked subjects (every subject when there are no picks). Each row has a tinted icon square in board-order tint, the name, "Next: Ch N · lesson" (or "All lessons done" / "Lessons coming soon"), and a green ring from `lessonsDone / lessonsAvailable`, or a schedule icon when the subject has no lessons.
  - Tapping a row calls `StudyViewModel.openSubject` and switches to Study → Courses.
  - "Edit" opens the picker sheet.
  - `PickSubjectsCard` shows once, after setup, to students with no picks. Tapping it or closing it marks it seen.
  - The subject grid is gone. `HomeGreeting` and `DashboardLoadError` moved out of `home_screen.dart` to keep it under 300 lines.
- **Study**:
  - The subject pills show the picked subjects that have chapters, on one scrolling row.
  - The status row has a Filters key (tune icon, with a count badge) that opens `FiltersSheet`. It has three switches and a Textbook / Most marks / Recent sort, and the button shows a live "Show N chapters" count.
  - `ActiveFilterChips` shows each active filter as a removable chip, with the chapter count.
  - Add chapters uses the same subject list, status row and sheet.
  - The Courses / Folders tab now lives in `StudyViewModel`, so Home can open Courses.
  - `StudyChapter` and `ChapterFilters` have their own files. `ChapterRow` and `ContinueKey` moved out of `courses_view.dart`.
- **Me → Class and board** gets a "Subjects" group with a Stream row (Class 11–12 only) and a Subjects row ("All subjects" or "5 · Maths, Science, …"). Both open `SubjectsSheet`. The Stream row saves as soon as a stream is chosen.
- **Shared code**:
  - `PageDots` (moved out of the language step).
  - `SubjectIcons` (Material icons per subject and per stream).
  - `longDate` in `utils/dates.dart`.
  - The account-left handling moved into `MeNavigation`, which keeps `app_shell.dart` under 300 lines.

## Choices worth knowing

- **The stream isn't stored**: it is worked out from the picks, as the first stream whose main subjects are all picked. A PCMB student reads as PCM.
- **Marks are sparse**: the syllabus files give marks for 162 chapters, mostly units with a single chapter. "Most marks" puts those chapters first and keeps textbook order for the rest.
- **"Recent" counts finished lessons only**: it sorts by the last finished lesson in the chapter. A chapter that has only been opened doesn't count until a lesson in it is finished.
- **The locked English pill has a solid border**: the design's dashed border isn't native in Flutter, so it uses a solid border-colour outline with a raised fill and a lock icon.
- **The server catalogue lists every subject**: the app does the filtering by picks. This lets "no picks" show everything and lets Add chapters reuse the same list.
- The scratchpad `rules.md` named in the task didn't exist, so I followed `AGENTS.md`, `server/AGENTS.md` and memory.

## How it was tested

- **Server**:
  - Checks: `gofmt -l .` (clean), `go vet ./...`, `golangci-lint run` (0 issues), `go test -race ./...` against the local Postgres (all packages pass, and `TestPostgresStore` ran rather than skipped), and `go tool govulncheck ./...` (no reachable vulnerabilities).
  - New tests: `TestSubjectPicks` (10 cases), `TestSubjectsRewardPaidOnce`, `TestStreams` (every stream subject is in `Subjects`, English first) and `TestCatalogueRevisionDueAndMarks`.
  - Extended tests: the routes tests (PATCH subjects, `invalid_subjects`, `GET /catalog/streams`, catalogue `subjects`, `minutes`, `revisionDue`, `lastStudiedAt`), the Postgres store test (subjects saved, kept, cleared; AwardXP once) and the syllabus marks test.
- **App**: `dart format` (clean), `flutter analyze` (no issues), `flutter test` (218 pass).
  - `test/ui/home/home_subjects_test.dart`: the Class 11 stream then extras; rows for picked subjects only, with next lesson, coming soon, tap-to-open, and Edit then Save; no picks showing every subject plus the card, whose save pays +25.
  - `test/ui/home/home_screen_test.dart`: 1/5, "0 / 125 XP", the board → subjects → +125 flight, and Later on step 5 paying +100 and leaving the card.
  - `test/ui/home/view_models/home_view_model_test.dart`: five tasks, the subjects task gated on syllabus, the reward adding up to 125, and the card dismissed once.
  - `test/ui/study/filters_test.dart`: picks filtering, each filter and both sorts, the sheet's live counts, chips, Clear and sort, and Add chapters with the Filters key.
  - `test/ui/subjects/subjects_test.dart`: the view model for Class 6–10 defaults, streams, restoring saved picks and a failed load; Me rows and sheets for both a junior and a senior student.
  - Data tests: profile subjects JSON, streams cached per class and board, and catalogue parsing of every new field.
- **Integration**: `integration_test/support/flows.dart` now taps Continue on the board step, waits for "Which subjects do you study?", takes the `setup-subjects` screenshot and taps Finish setup. `courses_test.dart` scrolls each subject pill into view before tapping it, because the pills now sit on one scrolling row. These journeys were not run on a device, as asked.

## Pixel 10 checks for the orchestrator

Run the server from this worktree (migration 0023 applies at start-up) and the app against it on the Pixel 10.

1. **New account, Class 10 CBSE**:
   - The sheet runs 1/5 to 5/5, and the board step's button says Continue.
   - Step 5 shows English locked (grey, lock icon) and Maths, Science, Social Science and Hindi on, with Sanskrit and Computer Applications off.
   - Finish setup flies **+125** into the chip, and the chip ends at 125 XP.
2. **New account, Later on step 5**: the flight shows +100, the checklist goes, and the "Pick your subjects" card appears. Tap it, Save, and the chip goes up 25. The card never comes back. Also try closing the card with ✕ on another account.
3. **Class 11 or 12**:
   - Step 5 shows stream swipe cards: PCM, PCB, Commerce, Humanities. The dots and the "Swipe for Humanities" caption follow the swipe.
   - "Choose Science · PCM" leads to "Anything else?" with Main pre-on (English locked) and Optional pills.
   - The header Back returns to the cards.
   - Check that Commerce on ICSE (ISC) shows "Commerce" and on CBSE shows "Business Studies".
4. **Home "Your subjects"**:
   - Only the picked subjects show, in board-order tints.
   - Science shows "Next: Ch 9 · …" with a green ring. Subjects with no lessons show "Lessons coming soon" and a schedule icon.
   - Tapping a row lands on Study → Courses with that subject selected, even if Folders was open.
   - Edit opens the sheet, and Save updates Home and Study straight away.
5. **Study → Courses**:
   - The subject pills fit one row (or scroll sideways), and the Filters key sits at the end of All / In progress / Done.
   - The sheet's switches and sort work, and the button count changes live.
   - After applying, the chips and the badge count show, tapping a chip removes it, and "No chapters match these filters." appears when nothing is left.
   - Check "Board exam only" on CBSE 10 Science (chapter 14 disappears).
6. **Folders → a folder → Add chapters**: the same picked subjects, the Filters key and the same sheet.
7. **Me → Class and board**:
   - A Subjects group appears below the board picker.
   - On Class 11–12 the Stream row shows the stream (or "Not set"), and choosing one saves at once.
   - The Subjects row shows "All subjects" or "N · names…", and Save updates it.
8. **Class or board changes in Me**: going from Class 10 to 11 clears the picks (Home shows every subject and the Stream row says "Not set"). Going from Class 9 to 10 keeps them.
9. **Existing account that finished setup before this change**: no checklist, every subject on Home, the "Pick your subjects" card once, and +25 XP on the first save.
10. **Display**: dark mode and 1.3× text on step 5, the filters sheet and the Home rows (no overflow, long subject names ellipsise).
11. **Integration**: run the sign-up journeys (`onboarding_test`, `courses_test`, `folders_test`) with `tool/ui_test.sh` to confirm the new step 5 path and the `setup-subjects` screenshot.
