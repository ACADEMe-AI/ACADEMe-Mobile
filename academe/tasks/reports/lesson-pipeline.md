# Lesson pipeline

Status: built and tested end to end. The Sarvam account ran out of credits at 21:20 IST (`402 insufficient_quota_error`), part-way through the final generation run. **Top up Sarvam credits before the full run.**

## What was built

### Syllabus catalogue: `server/internal/syllabus`
- `syllabus.go` embeds `data/*.json` (all 14 files, CBSE and ICSE, classes 6 to 12) and loads and validates them. It checks:
  - the file name matches `<board>-<class>.json`
  - the board and class are ones we teach
  - every subject code is valid for that class and board (`profile.Subjects`), with no subject listed twice
  - chapter numbers are positive and unique, and every chapter has a title and lessons
  - every lesson has a title and topics
  - every chapter topic sits in exactly one lesson, and every lesson topic is a chapter topic
  - no unknown JSON fields
- Every problem is reported with its file, subject, chapter and topic, and all problems come back at once (`errors.Join`).
- `Plan()` turns the syllabus into `study.PlannedChapter` values. Chapter IDs come from `study.ChapterID`, and lesson IDs are `chapterID-position` (`study.LessonID`).
- `syllabus_test.go` loads every real data file and checks that no chapter ID repeats and that no served deck sits in a syllabus chapter at a position the plan doesn't have. It also covers each rejection case against a fixture (`testdata/cbse-10.json`). All 14 real files pass: 5,777 planned lessons.
- `cmd/academe-api/main.go` loads the syllabus at start-up (a small, surgical edit).

### Catalogue in the API (additive)
- `GET /study/decks` now returns a `chapters` array next to `decks`, which is unchanged. It lists every syllabus chapter for the student's class and board, in subject then chapter order: `{id, subject, subjectName, number, title, unit, lessons:[{id, position, title, available}]}`.
- A chapter or lesson that has a deck but isn't in the syllabus is still listed.
- The `subject` filter applies to chapters too.
- Code: `server/internal/study/catalogue.go`. `NewService` takes the plan as a new argument.
- `openapi.yaml`: added the `ChapterPlan` schema, plus the optional `status` and `generatedBy` fields on `Deck`.

### Generated lesson storage
- `study.Library()` now walks `decks/` recursively (`//go:embed decks`) through `study.ReadDecks`, skips `*.review.json`, and serves only approved decks. A deck with no `status` (the five hand-written seeds) counts as approved.
- `Deck` gained `status` (`approved` or `draft`) and `generatedBy {model, promptVersion, checkedAt}`.
- Generated files go to `server/internal/study/decks/<board>-<class>/<id>.json`. A draft gets a sibling `<id>.review.json` holding the reviewer's issues. Git is the version history.

### Generator: `server/cmd/academe-lessons` + `server/internal/lessons`
- Flags:
  - filters: `-board -class -subject -chapter -lesson`
  - run control: `-workers` (default 4), `-force`, `-dry-run`, `-out` (default `internal/study/decks`)
  - review report: `-review`, `-html` (default `content-review/index.html`)
  - `-syllabus <dir>` reads the syllabus from a folder instead of the embedded data
  - Sarvam: `-model` (default `sarvam-105b`), `-timeout` (default 180s), `-max-tokens`, `-author-reasoning` (default `none`), `-review-reasoning` (default `medium`)
- What happens for each planned lesson without an approved file:
  1. **Writer call** (reasoning off: about 10 to 15 s instead of about 80 s). The prompt carries board, class, subject, book, chapter title, unit, outcomes, the lesson's topics, and the neighbouring lessons marked "already taught" or "comes later". It asks for the exact card format for the class level, in simple English with Indian context and plain-text maths (× ÷ ² √ ≤, subscript formulas), original wording and 6 to 12 cards.
  2. **Reply handling.** The generator keeps only `message.content` (reasoning is dropped), strips any `<think>` block and code fences, and extracts the JSON object. Deterministic clean-ups follow:
     - an answer given as text or a letter is mapped to its index
     - `x^2` becomes `x²` and `root 5` becomes `√5`
     - "Step 1:" labels are removed
     - quiz options are shuffled
     - start-card minutes are computed
     - fields a card kind doesn't use are dropped
  3. **Checks.** `study.Validate` runs, plus generator rules: 6 to 12 cards, at most 4 distinct options, no LaTeX, `$` or backslashes (including JSON escapes such as `\frac`), no "option 2" or "(B)" references in a quiz's "why", and no "Both A and D" or "all of the above" options. If a check fails, the exact error goes back to Sarvam, up to 5 replies in total. JSON syntax errors quote the spot where parsing failed.
  4. **Reviewer call** (reasoning on). It sees the lesson as readable text with the "marked correct" option spelled out, and checks accuracy, quiz answers, level, syllabus fit, originality and clarity. It returns `{ok, issues[]}`. If `ok` is false, the writer revises the lesson using the issues, for up to 2 more rounds.
  5. **Result.** OK means `status: approved`. Otherwise the lesson is saved as `draft` with a `.review.json`.
- Hindi and Sanskrit lessons are written in Hindi (Devanagari), with `language: "hi"`.
- Robust for unattended runs:
  - resumable: approved decks are skipped; hand-written seeds are never overwritten, even with `-force`; drafts and failures are retried on the next run
  - atomic file writes (temp file, then rename)
  - bounded worker pool
  - exponential backoff with jitter on 429, 5xx, timeouts and empty replies (6 retries, capped at 5 minutes)
  - per-request timeout
  - stops the whole run on 401, 402 or 403 (no credits or a bad key), so it doesn't burn through the queue
  - a panic in one lesson only fails that lesson; Ctrl-C stops cleanly
  - one log line per lesson with id, status, title, seconds and done/of, then a final summary (approved, draft, failed, skipped, elapsed, seconds per lesson, lessons per hour)
  - exit code 1 if anything failed, so a wrapper can simply rerun
- Prompts are Go constants in `internal/lessons/prompts.go`, with `PromptVersion = "lessons-v4"` recorded in every generated deck.
- `internal/sarvam`, additive changes:
  - a typed `StatusError` (same message text as before)
  - `MaxTokens` (Sarvam's default of 2048 truncated every lesson inside the reasoning)
  - `Reasoning` (`reasoning_effort`, where `null` turns reasoning off)

### Teacher review aid
`academe-lessons -review` writes `server/content-review/index.html`, which is git-ignored. It shows every deck, grouped by board, class, subject and chapter, with a status badge, the model and prompt version, and the reviewer's issues for drafts. Every card is rendered, with ✓ on the answer the app accepts.

### App (`lib/`)
- `domain/models/deck.dart` adds `PlannedChapter`, `PlannedLesson` and `StudyCatalogue`. `data/model/deck_models.dart` parses the catalogue and treats a missing `chapters` field (an older server) as empty.
- `StudyRepository.decks()` became `catalogue()`: the same single `GET /study/decks` call, now returning decks and chapters. The remote repository, API service and `FakeStudyRepository.chapterList` were updated to match.
- `StudyViewModel.allChapters` merges the catalogue with the decks. Subjects come from the catalogue, and the default subject is the first one with lessons.
- `StudyChapter` gained:
  - `isComingSoon`, `lessonsPlanned` and `lessonsComing`
  - `outline`, the planned and written lessons in order
  - `isDone`, which is now false for an empty chapter
- Continue, filters and folders work as before. Add-chapters lists only chapters that have lessons.
- Courses shows every chapter:
  - chapters with no lessons are greyed, say "Coming soon · N lessons" with a clock icon, and can't be tapped
  - partly written chapters say "x of y lessons · n coming soon"
  - the Continue key is hidden when the selected subject has no lessons
- The chapter screen lists planned lessons in order; unwritten ones are greyed, say "Coming soon" and can't be tapped (`widgets/planned_lesson_row.dart`). For a chapter with no lessons, the resume key, chapter test, kept cards and add-to-folder are hidden.

### Seed renumbering (orchestrator request)
Science seeds are now chapter 9: `cbse-10-science-9-1/2/3`. References to `cbse-10-science-10` were updated in the server study, store and folder tests, the app study tests and `FakeStudyRepository`.

## Generated content in the repo
From the real `cbse-10.json`, in `server/internal/study/decks/cbse-10/`:

| Lesson | Status | Notes |
|---|---|---|
| cbse-10-maths-1-1 Prime factorisation and the Fundamental Theorem | approved | correct worked example (HCF 6, LCM 36 of 12 and 18) and quizzes |
| cbse-10-maths-1-2 Revisiting irrational numbers | approved | correct √2 proof by contradiction and √5 isolation. In an earlier round the reviewer caught a false "12 × 18 = 72" and the writer fixed it |
| cbse-10-science-1-2 Types of reactions | approved | accurate: CaCO₃, electrolysis of water, AgCl photolysis, Pb(NO₃)₂ + KI |
| cbse-10-science-1-1 Chemical equations | draft | the reviewer flagged two cards as too close to NCERT wording |
| cbse-10-science-1-3 Oxidation and reduction | draft (demoted by me) | approved under v2, but card 9 had the option "Both A and D". The v3 checks now reject this. Reason recorded in its `.review.json` |

These were produced by the lessons-v2 run. The credits ran out before a v3 rerun. Two deterministic clean-ups now built into the generator (superscript powers in maths 1-1, √ in maths 1-2) were applied to those two files. Verified:
- `GET /study/decks` for a new Class 10 CBSE account on a local server (:8091) returns 8 decks and 115 chapters (111 of them coming soon). Chapter 1 of maths and science shows the right available and unwritten lessons, `GET /study/decks/cbse-10-maths-1-1` serves the lesson, and the draft returns 404.
- `test/data/model/deck_models_test.dart` parses every approved server deck with the app's own parser.

My judgement of the output: the facts and quiz keys are right, and the reviewer genuinely catches arithmetic and scope errors. The prose is plainer than the hand-written seeds, with the odd flat "why". About 50% of lessons are approved on the first run. Most drafts are for "too close to the NCERT wording" or drift into the next lesson; rerunning retries them.

## Tests
- Server: `internal/syllabus` covers the real data plus every rejection case. `internal/lessons` runs against a fake Sarvam and covers:
  - JSON extraction (fences, prose, `<think>`, syntax-error context)
  - card rules, including LaTeX, options named by position, cross-referencing options, clean-ups and text answers
  - retry after a validation error, with the error fed back
  - the reviewer loop, both approved after a revision and ending as a draft with a review file
  - resume and `-force`, where seeds are never regenerated
  - backoff on 429 and 503, and no retry on 400
  - stopping the run on 402
  - the HTML report, including escaping
  - Hindi-medium prompts
- Also on the server: `internal/study` handler tests for `chapters` (planned, available and unwritten lessons; the subject filter; an empty list before setup) and `ReadDecks` (subfolders, drafts, review files).
- Server definition of done: gofmt clean; go vet; golangci-lint shows 0 issues; `go test -race ./...` passes, store tests included; govulncheck reports no called vulnerabilities; `go mod tidy` leaves no diff.
- App: `test/ui/study/catalogue_test.dart` (view model merge, Courses coming-soon row, chapter screen with greyed lessons, empty chapter) and `test/data/model/deck_models_test.dart`. `flutter analyze` finds 0 issues; the full `flutter test` passes (192 tests).

## Running the full generation
From `server/`, after topping up Sarvam credits:

```
export ACADEME_SARVAM_API_KEY=$(sed -n 's/^SARVAM_API_KEY=//p' ../.env | tr -d '"\n\r')
go build -o /tmp/academe-lessons ./cmd/academe-lessons
/tmp/academe-lessons -dry-run | wc -l
/tmp/academe-lessons -workers 8 -timeout 300s 2>&1 | tee -a /tmp/academe-lessons.log
/tmp/academe-lessons -workers 8 -timeout 300s 2>&1 | tee -a /tmp/academe-lessons.log
/tmp/academe-lessons -review
open content-review/index.html
```

- The first run command does the generation. Run the same command again to retry failures and drafts. It is resumable at any point, and Ctrl-C is safe.
- One board and class at a time: add `-board cbse -class 10`.
- Keep `-timeout 300s`: at 180 s, about 7 in 23 reviewer calls (reasoning on) timed out and were retried.
- Commit `server/internal/study/decks/**` as batches finish. Drafts stay out of the app until they pass review.

## Throughput and cost
- Measured on CBSE 10, chapter 1 of all 7 subjects, 6 workers: 23 lessons in 23 min 42 s. That is about 62 s of wall time per lesson (about 58 lessons an hour), and about 333 s of Sarvam time per lesson (1 to 3 writer calls at 10 to 15 s each, 1 to 3 reviewer calls at 60 to 180 s each). Result: 12 approved, 7 drafts, 4 failures; a rerun retries the drafts and failures.
- **All classes: 5,777 planned lessons.**
  - At 6 workers: about 100 hours for one pass.
  - At 12 workers: roughly 50 hours, if Sarvam doesn't throttle. Concurrency above 6 is untested, because the credits ran out.
  - Allow about 25% extra for the second pass on drafts and failures.
- **Estimated tokens:** about 12k input and 18k output per lesson, mostly reviewer reasoning. For all classes that is about 70M input and 105M output tokens. At Sarvam's list price (₹29.28 per 1M input, ₹73.2 per 1M output) that comes to **about ₹10,000 (roughly US$115)** for one pass, or ₹12,000 to ₹13,000 with retries.
  - For scale: the credits that just ran out covered about 45 lessons across my trial runs.
  - Artificial Analysis lists $0.04 / $0.17 per 1M, which would be about $25 in total; budget for the rupee figure.

## Needs the user
- **Top up Sarvam credits.** The full run needs roughly ₹10k to ₹13k.
- **Hand-written seeds don't match the new syllabus lesson plan:**
  - Science chapter 9 plans 1 Spherical mirrors, 2 Mirror formula, 3 Refraction, 4 Lenses. The seeds occupy positions 1 to 3 as Reflection of light, Spherical mirrors and Mirror formula. So "Refraction" is hidden behind the "Mirror formula" seed and will never be generated.
  - Maths chapter 3 plans 1 Graphical method, 2 Consistency conditions, 3 Substitution, 4 Elimination. The seeds are "What a pair of linear equations is" and "Solving by substitution", so substitution appears twice.
  - Fix: renumber the seeds to their matching plan positions (for example science 9-2 → 9-1 and 9-3 → 9-2, and retire or merge 9-1), or accept the overlap. I renumbered only the chapters, as asked.
- A teacher should spot-check `content-review/index.html`, drafts first.

## Known limits
- One reviewer model is judging its own family's output. It is strict on arithmetic and scope but can miss things; the v2 miss described above is now caught by code. Human spot checks still matter.
- The originality check is only the reviewer's judgement; there is no text-similarity check against NCERT.
- English literature lessons discuss copyrighted texts in the model's own words; the originality rule and the reviewer guard this, but it deserves a human look.
- Lessons are English only, apart from Hindi and Sanskrit. The app's other 4 UI languages don't translate lesson content.

## Future improvements
- Run the reviewer on a stronger or different model (or two reviewers) for cross-checking.
- Add a `-recheck` mode that reruns the code checks on existing approved decks after the rules change, demoting failures to draft.
- Detect textbook copying by n-gram overlap against digitised NCERT text.
- Show "coming soon" counts per subject in the subject pills.
