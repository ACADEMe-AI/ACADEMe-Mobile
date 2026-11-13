# Brand scrub

The `academe` directory now names no other app, study website or social platform, and Pebby's docs no longer suggest that Pebby, its name, art, rig or motion came from anywhere else. Pebby is ours.

## Removed

- `design/inspiration/` (reference copies of a third-party component library; the ported widgets live in `lib/`)
- `design/mascot/shape-language/` scrape of another app's design site (the whole file)
- `design/mascot/rive/__pycache__/`
- `.DS_Store`, `design/.DS_Store`
- `flutter_01.log` (a stale Flutter crash log)
- Stale rive tool outputs in `design/mascot/rive/preview/` that nothing references: `launch.gif`, `pebby_{celebrate_big,celebrate_small,chat,encourage,idle,sleepy,wave}.gif`, and 55 `states/*.png` stills (the five `3x_turn_*.png` the page shows are kept)

## Changed

| File | Change |
|---|---|
| `server/internal/syllabus/data/icse-6.json`, `icse-7.json`, `icse-8.json` | `sources` now lists only CISCE and the publishers' own sites (Selina Publishers, Frank Educational Aids, Goyal Brothers Prakashan). Each chapter's `source` points to its publisher, or to cisce.org for curriculum-based subjects (English, Hindi, Computer, and Kundra History & Civics). The `book` fields name only the textbook and publisher, e.g. "Selina Concise Physics, Class 6 (2026-27)". Chapters, topics and lessons are unchanged. |
| `design/mascot/rive/README.md` | Removed every claim that the rig, the 12 fps grid, the loop lengths, the blinks, the easing or the arm skinning was measured from or matched another app's character file or a reference avatar. `rivread.py` is now described as a reader for checking the built file. |
| `design/mascot/rive/anim.py` | Docstrings for `blink_schedule` and `face_view` no longer mention a reference. |
| `design/mascot/rive/preview/index.html` | Removed "the same as the reference character file". The turnaround now says it follows our turnaround art. |
| `design/mascot/shape-language/SHAPE-LANGUAGE.md` | Removed the sources table, the attributions and quotes, and the link to the deleted scrape. The rules stand on their own. |
| `design/mascot/rive-celebrations.md` | Removed the brand reference from "Why Rive". Section 5 is now "Mascot feedback rules". |
| `design/preview/index.html` | Social and brand names changed to neutral wording ("short-video feed", "messaging app", "share card", "video summaries", "a language-learning app"). The S2 direction is now "Swipe feed". Four share buttons that used a messaging app's brand green now use `var(--primary)`. |
| `tasks/roadmap.md` | Seven small edits: share rows, the weekly report, video summaries, the Home feed, the answer-sounds known issue, the Study directions list and the student-journeys line. |
| `tasks/reports/cleanup.md` | Deleted the "Pebby's name" open item. Removed the old reference-folder path. |
| `tasks/reports/syllabus-icse-6-8.md` | Removed the names of study websites used as sources. The table and the confidence notes now name only the books and publishers. |
| `tasks/reports/syllabus-cbse-6-8.md`, `syllabus-cbse-9-10.md` | Study websites used for cross-checks are now called "a study website". |
| `docs/go-reference/google-go-style-best-practices.md`, `google-go-style-decisions.md`, `google-go-style-index.md`, `go-wiki-code-review-comments.md` | Removed only the video-site links. Talk titles stay as plain text. |
| `docs/flutter-reference/flutter-performance.md` | Removed the video-site channel name and one embedded video tag. |
| `.gitignore` | Added `__pycache__/` and `server/content-review/`. Changed `/build/` to `build/`. `.dart_tool/`, `.DS_Store`, `.env` and `*.pyc` were already listed. |

## Checks

- The brand grep gate from the academe directory prints nothing.
- `find . -iname` finds no file names containing those words.
- `strings` and `grep -a` over every PNG, SVG, GIF, JPG, RIV, GLB and MP4 in `assets/` and `design/` find none of the names.
- `go test ./internal/syllabus/` passes. All 14 syllabus files load, and every topic is in exactly one lesson in every chapter.
- `flutter analyze`: no issues. `flutter test`: all 158 tests pass.

## Notes

- If the gate is run with macOS BSD `grep` instead of the shell's `grep`, one short pattern in it also matches inside ordinary OAuth identifiers in `ios/Pods/` (third-party CocoaPods code, gitignored). Those are false positives, not brand names.
- `openme` still appears twice, as the old codename of our own previous app: in the roadmap changelog entry for the rename and in the cleanup report.
- `SHAPE-LANGUAGE.md` links to `design/mascot/flat/` and `examples/` files that no longer exist. That was already the case before this scrub, and I left those links alone.
