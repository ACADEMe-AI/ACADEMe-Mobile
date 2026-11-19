# Lesson pipeline: test report

Tester, 2026-09-25. I made no Sarvam calls because the account has no credits (402). Every generator check used the fake chat in `internal/lessons`. I did not use the emulator. My own server ran on :8104 against the local Postgres and has been stopped.

## Verdict

**GO** for the full generation run once the credits are topped up. I fixed the issues below, and every check passes.

Start with a short paid smoke run and read its output before leaving the full run unattended (see "Running it").

## What I checked and found

### 1. Syllabus loader and validation
- All 14 data files load and pass validation, giving 5,777 planned lessons with no repeated chapter IDs. A new test also requires exactly 14 syllabi, and checks that every subject `profile.Subjects` teaches for each board and class has chapters.
- Per chapter: 2 to 6 lessons, no repeated lesson titles within a chapter, no title over 70 characters.
- Sources are all boards or textbook publishers (cisce.org, cbseacademic.nic.in, ncert.nic.in, Selina, Frank, Goyal).
- **Provisional CBSE Class 9 chapters** cover 7 maths chapters (9 to 15, Ganita Manjari Part II) and 7 social science chapters (10 to 16). They load normally, and their unit text isn't shown in the app (the app parses `unit` but never displays it).
  - The real risk: when NCERT publishes the book and the chapters are renumbered, generated lesson IDs such as `cbse-9-maths-9-2` would silently point at a different lesson.
  - Fix: `internal/lessons/library_test.go` now fails CI whenever a generated deck's title or chapter title no longer matches the syllabus lesson at its ID. The error says "the chapter was renumbered, so regenerate it". I confirmed the test fails by changing one title.
  - I chose not to skip provisional chapters in generation: the topics are real Class 9 content that students need now.
- **Formative-only chapters were not exposed. Fixed (additive):**
  - `syllabus.Plan` sets `PlannedChapter.FormativeOnly` when the unit says "formative assessment only". That covers 13 chapters: CBSE 10 science 14; CBSE 11 chemistry 10 and 11, biology 20, geography 21; CBSE 12 chemistry 11 to 14, biology 14, geography 18 to 20.
  - The API sends `formativeOnly: true` on those chapters and leaves it out otherwise. `openapi.yaml` documents it on `ChapterPlan`.
  - App: `PlannedChapter.isFormativeOnly` → `StudyChapter.isFormativeOnly`. Courses shows "… · Not in board exam" and the chapter screen header adds "· Not in board exam".
  - ICSE "Internal Assessment" chapters (listening and speaking skills) are marked by the school but count towards the board result, so I deliberately left them unlabelled.

### 2. Catalogue API (`GET /study/decks`)
Measured on the real server for every board and class; the app's own parser reads all 14 responses.

| Board | Classes 6 to 8 | 9 | 10 | 11 | 12 |
|---|---|---|---|---|---|
| CBSE chapters | 70 / 74 / 70 | 96 | 115 | 189 | 189 |
| ICSE chapters | 89 / 98 / 103 | 128 | 127 | 210 | 194 |

- Every subject is present: 6, 7, 9 or 14 subjects depending on board and class.
- Availability is correct. CBSE 10 shows 6 available lessons (3 seeds and 3 approved), and science 9 reads Spherical mirrors ✓, Mirror formula ✓, Refraction and Lenses coming soon.
- **Drafts are never served.** Science 1-1 and 1-3 show as unavailable and `GET /study/decks/{id}` returns 404 for them.
- The `subject` filter applies to chapters too.
- **Old app compatibility:** `LessonSummary` is byte-identical to HEAD, and `decks` only ever lists approved decks. The seeds that were removed or renumbered (maths 3-1 and 3-2, old science 9-1 to 9-3) only matter for dev accounts:
  - progress on a vanished deck ID is ignored, because review and kept-card lookups skip decks they can't find
  - progress on a reused ID (for example `cbse-10-science-9-1`) now attaches to a different lesson
  - this is harmless before release
- **Size:** a CBSE 12 account gets 105 KB of JSON today, 14.6 KB gzipped (7×). Once all 762 lessons exist, the `decks` array adds about 250 KB.
  - The server did not compress. **Added `httpx.Gzip`**, applied only to `GET /study/decks`.
  - It compresses only when the client sends `Accept-Encoding: gzip`, always sets `Vary`, and leaves 204 and 304 responses untouched.
  - The app's `http.Client` (dart:io) already asks for gzip and unpacks it transparently, so no app change is needed. I verified live that the unpacked response is byte-identical to the uncompressed one.
  - I kept it off the other routes on purpose: `ServeFileFS` for email assets uses Range requests.

### 3. Generator (fake Sarvam, `-race`)
- **JSON extraction: fixed.** Before the fix, it failed on trailing commas, on prose containing `{…}` after the JSON, on `{x}` in prose before it, and on text after a closing code fence.
  - It now starts at the first `{"`, decodes exactly one value (so trailing prose is ignored), and removes trailing commas only when the strict parse fails.
  - A syntax error still quotes the spot where parsing failed.
  - Five new table cases cover this, including a comma inside a string that must stay untouched.
- **Retry loop and reviewer loop:** already covered. The validation error is fed back to the writer; a lesson approved after a revision is saved; a lesson still rejected becomes a draft with a `.review.json`; the number of writer calls is exact.
- **Resume, and seeds never overwritten:** covered. Approved decks are skipped. Drafts and missing lessons are retried. Hand-written seeds (no `generatedBy`) are skipped even with `-force`. `-dry-run` on the real data lists 5,771 lessons to generate out of 5,777 (the 6 approved ones are skipped; the 2 drafts are retried).
- **Stopping on 401, 402 and 403: strengthened.** A new table-driven test covers all three codes. In each case the run approves one lesson, then stops on the refusal: no more calls, the `StatusError` is returned, and nothing partial is written. A rerun with 3 workers skips the approved lesson and generates the rest. The CLI exits 1 in that case.
- **Concurrency:** the whole server passes `go test -race ./...`, and `internal/lessons` and `internal/httpx` also pass `-count=5`. The summary is guarded by a mutex; stopping uses `context.WithCancelCause`; the queue drains without doing work after a stop.
- **Atomic writes: already in place.** Each file is written to a `.tmp-*` file in the same folder, then renamed. Leftover temp files start with `.`, so `//go:embed decks` ignores them and so does `ReadDecks`.
- **A bad deck file can no longer take down the server. Fixed.**
  - At runtime, `ReadDecks` skips unreadable or unparsable files and reports them. `Library()` also skips approved decks that fail `study.Validate` or repeat an ID, and returns the good decks along with a joined error.
  - `cmd/academe-api/main.go` logs "some lesson decks were skipped" with the count served, instead of refusing to start (surgical edit).
  - At build time, CI still fails: `TestLibraryIsValid` fails on any such error. New `TestGeneratedDecksMatchThePlanAndRules` checks that every deck file is named after its ID, that every generated deck sits at `<board>-<class>/<id>.json`, matches its planned lesson and titles, and, when approved, passes the generator's own v4 rules (so a `-recheck` mode isn't needed yet).
  - The generator itself (`Pending`, `-review`) stays strict and stops on a broken file rather than regenerating over it.
- Default `-timeout` raised from 180 s to 300 s. The builder measured about 30% reviewer timeouts at 180 s.

### 4. Content quality (read by me, card by card)
- **maths 1-1 (approved):** facts and working are correct (HCF 6 and LCM 36 of 12 and 18; 2³ × 3² = 72; 45 = 3² × 5).
  - One quiz had two distractors with the same value (5² × 3 and 3 × 5²). I replaced one with "3 × 15", a real mistake (not fully prime), and updated the "why".
- **maths 1-2 (approved):** the √2 proof, the √3 prime and the rearrangement of 3 + 2√5 are all correct. The "2 √5" spacing is fixed in the file, and the generator now closes that gap itself (`plainMaths`, tested).
- **science 1-2 (approved):** CaO + H₂O, CaCO₃, electrolysis, AgCl photolysis, Pb(NO₃)₂ + 2KI → PbI₂ + 2KNO₃ and Zn + CuSO₄ are all correct.
  - The endothermic quiz's "why" said calcium carbonate "also" needs heat, which reads as if neutralisation does too. I rewrote it to be exact.
  - "Recognize" → "Recognise".
- **science 1-1 and 1-3 (drafts, not served):** correctly held back.
  - 1-1 has weak state-symbol distractors (CaO appears as a reactant).
  - 1-3 has "Both A and D", now rejected by code.
- **Seeds 9-1, 9-2 and 3-3:** checked. The sign convention, the mirror-formula example (v = −60 cm, m = −2), f = R/2 and substitution are all correct.
- No copied textbook text that I could spot. Statements such as the Fundamental Theorem are standard, and the wording differs from NCERT. The one reused item is the problem 3 + 2√5, which is also in the NCERT exercises: fine as practice, not copied prose.
- No "all of the above" or "Both A and D" in any served deck. The level is right for Class 10. The language is simple, if plainer than the seeds. Indian context is thin in maths and chemistry, which is acceptable for these topics.
- **Prompts** (`internal/lessons/prompts.go`) have a good quality bar: exact facts, Indian context without forced metaphors, plain-text maths with symbols and subscripts, original wording, per-class level, a Hindi-medium mode, and a reviewer that checks the marked answer.
  - Added: Indian English spelling (colour, recognise, centre, metre, sulphate).
  - `PromptVersion` is now `lessons-v4`. `lesson-pipeline.md` still says v3.

### 5. App
- Courses and the chapter screen show "Coming soon" correctly.
  - A chapter with no lessons can't be tapped and hides Continue, the chapter test, kept cards and add-to-folder.
  - Unwritten lessons are greyed and can't be tapped.
- Continue (`continueLesson`) and next lesson (`nextAfter`) work only from the available decks, so they skip unavailable lessons.
- `test/data/model/deck_models_test.dart` parses every approved deck. I also ran the app's `studyCatalogueFromJson` on the 14 real responses (as a one-off probe, since deleted).
- New tests:
  - Courses shows "Coming soon · Not in board exam"
  - the chapter header shows "0 of 0 lessons done · Not in board exam"
  - no label on a normal chapter
  - `formativeOnly` parsing

### 6. Checks
- Server:
  - `gofmt -l .` prints nothing
  - `go vet ./...` passes
  - `golangci-lint run` reports 0 issues
  - `ACADEME_TEST_DATABASE_URL=… go test -race ./...` passes, store tests included
  - `go tool govulncheck ./...` finds 0 vulnerabilities our code calls
  - `go mod tidy -diff` is clean
- App: `dart format` is clean, `flutter analyze` finds no issues, and the full `flutter test` passes (193 tests).
- AGENTS.md:
  - no comments were added
  - Material icons only
  - colours come from the palette
  - the API change is additive
  - no competitor names (the only matches are historical names in the ICSE syllabus)
- Pre-existing issue, not fixed: `courses_view.dart` was already 306 lines and holds three public widgets. Splitting it would break `integration_test/courses_test.dart` and `support/study.dart`, which import `ChapterRow` from it and belong to the UI test agent. I tried the split, reverted it, and left it for that agent.

## Files I changed
- Server:
  - `internal/syllabus/syllabus.go`, `internal/syllabus/syllabus_test.go`
  - `internal/study/catalogue.go`, `study.go`, `handler.go`, `study_test.go`
  - `internal/httpx/middleware.go`, `middleware_test.go`
  - `internal/lessons/deck.go`, `prompts.go`, `lessons_test.go`, new `library_test.go`
  - `cmd/academe-lessons/main.go`
  - `cmd/academe-api/main.go` (one surgical edit)
  - `openapi.yaml`
  - deck content fixes in `internal/study/decks/cbse-10/cbse-10-maths-1-1.json`, `cbse-10-maths-1-2.json` and `cbse-10-science-1-2.json`
- App:
  - `lib/domain/models/deck.dart`, `lib/data/model/deck_models.dart`
  - `lib/ui/study/view_models/study_view_model.dart`
  - `lib/ui/study/widgets/courses_view.dart`, `chapter_screen.dart`
  - `test/ui/study/catalogue_test.dart`, `test/data/model/deck_models_test.dart`

## Running it
From `server/`, after topping up the Sarvam credits:

```
export ACADEME_SARVAM_API_KEY=$(sed -n 's/^SARVAM_API_KEY=//p' ../.env | tr -d '"\n\r')
go build -o /tmp/academe-lessons ./cmd/academe-lessons
/tmp/academe-lessons -board cbse -class 10 -subject science -chapter 9 -workers 2 2>&1 | tee -a /tmp/academe-lessons.log
/tmp/academe-lessons -review && open content-review/index.html
/tmp/academe-lessons -workers 6 2>&1 | tee -a /tmp/academe-lessons.log
/tmp/academe-lessons -workers 6 2>&1 | tee -a /tmp/academe-lessons.log
/tmp/academe-lessons -review
```

1. The first run generates 2 lessons, Refraction and Lenses. It's a smoke test of credits, prompt v4 and the timeouts; check the report before going on.
2. The full run takes roughly 100 hours at 6 workers and costs about ₹10k to ₹13k, per the builder's estimate. `-timeout` is now 300 s by default.
3. Run the same command again to retry drafts and failures. A 401, 402 or 403 stops the run cleanly; after a top-up, rerunning the same command resumes.
4. After each batch, run `go test ./internal/lessons ./internal/study ./internal/syllabus` before committing `internal/study/decks/**`. Those tests catch any approved deck that breaks the rules or drifts from the syllabus.
5. Raise `-workers` above 6 only if the log shows no `sarvam retry` lines for 429 errors.

## Known limits and follow-ups
- Refusals only stop the run on 401, 402 and 403. If Sarvam ever reports an empty quota as 429, each lesson backs off 6 times (about 5 to 8 minutes) before failing. That burns no credits, but watch the log.
- If Class 9 maths or social science chapters are renumbered after the run, CI will flag the generated decks, and they need `-force` regeneration or renaming.
- Only `GET /study/decks` is gzipped. Add `httpx.Gzip` to other large JSON routes if they grow.
- Lessons are English, or Hindi for Hindi and Sanskrit. Content in the other UI languages is future work.
