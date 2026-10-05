# Syllabus: CBSE Classes 11 and 12 (2026-27)

## What was built
- `server/internal/syllabus/data/cbse-11.json`: 14 subjects, 189 chapters, 752 lessons, 2550 topics, `"session": "2026-27"`
- `server/internal/syllabus/data/cbse-12.json`: 14 subjects, 189 chapters, 762 lessons, 2559 topics, `"session": "2026-27"`

The subjects are exactly the `seniorCBSE` list in `server/internal/profile/subjects.go`, in the same order: physics, chemistry, maths, biology, english, computer-science, accountancy, business-studies, economics, history, political-science, geography, psychology, physical-education.

| Subject | XI ch / lessons | XII ch / lessons |
|---|---|---|
| Physics | 14 / 72 | 14 / 67 |
| Chemistry | 11 / 56 | 14 / 67 |
| Maths | 14 / 56 | 13 / 57 |
| Biology | 20 / 81 | 14 / 59 |
| English Core | 22 / 63 | 24 / 70 |
| Computer Science | 11 / 45 | 10 / 39 |
| Accountancy | 10 / 44 | 10 / 41 |
| Business Studies | 11 / 52 | 12 / 53 |
| Economics | 12 / 43 | 14 / 53 |
| History | 7 / 34 | 12 / 59 |
| Political Science | 18 / 61 | 15 / 61 |
| Geography | 21 / 70 | 20 / 64 |
| Psychology | 8 / 34 | 7 / 26 |
| Physical Education | 10 / 41 | 10 / 46 |

## Conventions
- **Chapter numbering:** follows the current rationalised NCERT numbering and continues across Part I and Part II. `unit` holds the book part or book name plus the curriculum unit.
- **Two-book subjects:** numbering continues across the two books.
  - Economics: Statistics then Microeconomics in XI; Macro then Indian Economic Development in XII.
  - Political Science: Constitution at Work then Political Theory in XI; Contemporary World Politics then Politics in India in XII.
  - Geography: Physical then India Physical Environment in XI; Human then India People and Economy in XII.
- **marks:** set only when one curriculum mark-bearing unit contains exactly one chapter. Otherwise the field is omitted.
- **Physical Education and Psychology:** chapters are the CBSE syllabus units.
- **English Core:** the chapters are:
  - the reading, grammar and writing areas, each with its section marks;
  - each prescribed Hornbill/Snapshots (XI) and Flamingo/Vistas (XII) piece.

  Literary chapters have three lessons: author and theme, ideas and craft, then vocabulary and answering questions. No text is reproduced.
- **Chapter sources:** every chapter's `source` is the CBSE 2026-27 curriculum PDF for its subject. The NCERT textbook pages and prelim contents PDFs (Reprint 2026-27) used to check titles are listed in `sources`.

## Validation
`go test -count=1 ./internal/syllabus/` passes. A Python check was run on both files and passes:
- the JSON loads;
- the subject list matches `subjects.go`;
- chapter numbers are unique per subject;
- every topic sits in exactly one lesson, and the lesson topics equal the chapter topics;
- every chapter has 2-6 lessons and 2-5 outcomes.

## Sources
- CBSE Curriculum 2026-27, "Secondary Curriculum: Part 2 (XI-XII)", index at https://cbseacademic.nic.in/curriculum_2027.html. Per-subject PDFs are at `https://cbseacademic.nic.in/web_material/CurriculumMain27/SecPart2/<Subject>_SecP2_2026-27.pdf`, plus `Biology_SrSecXI_2026-27_RM.pdf`. Every URL returned HTTP 200.
- No 2026-27 Maths XI reading-material PDF is published, so the 2025-26 one (`CurriculumMain26/SrSec/Maths_SrSecXI_2025-26_RM.pdf`) stays as that source. The 2026-27 Maths curriculum keeps the same formative-only list.
- The first build used the 2025-26 curriculum (`CurriculumMain26/SrSec`). Both years were extracted and diffed word by word to find the changes below.
- NCERT textbook contents pages (prelims PDFs on ncert.nic.in, Reprint 2026-27) for Physics, Chemistry, Biology, Computer Science, Accountancy, Business Studies, Economics and English.

## Changes from 2025-26 to 2026-27 (applied)
- **No change for 10 subjects:** Physics, Maths, English Core, Computer Science, Accountancy, Business Studies, Economics, History, Psychology and Physical Education changed only headers, years and layout. Units, chapters and marks are identical.
- **Chemistry:**
  - Units and marks are unchanged in both classes. The sub-topic lists are now written as NCERT section headings.
  - XII: "Bonding in metal carbonyls" is newly listed under Coordination Compounds and has been added as a topic.
  - XII: newly listed as formative-only reading material: Surface Chemistry, Isolation of Elements, Polymers, and Chemistry in Everyday Life. Added as chapters 11-14.
  - XI: s- and p-Block Elements and The Gaseous State were already formative-only in 2025-26. They are now added as chapters 10-11 for consistency.
- **Biology XII:** Environmental Issues is newly listed as formative-only CBSE reading material. Added as chapter 14.
- **Geography:**
  - XI: Minerals and Rocks (major rock types) is newly listed as formative-only. Added as chapter 21.
  - XII: Population Composition, Human Settlements (Fundamentals of Human Geography) and Migration (India People and Economy) are newly listed as formative-only. Added as chapters 18-20.
  - Practical Map Projections marks moved from 4 to 5. This is practical work, so it is not in the files.
- **Political Science** (annexure reference material, which CBSE says is not assessed in the board exam):
  - XI: "Judicial overreach" is dropped and replaced by a neutral topic on checks on judicial power. "Revision of the electoral roll" is added to Election and Representation.
  - XII: the Israel sub-topic becomes European Union, with a BRICS+ expansion note. India-Israel relations becomes India-European Union relations.
  - XII: "Ayodhya dispute / Demolition and after" becomes "Ayodhya issue / From legal proceedings to amicable acceptance". "Lok Sabha elections 2004" becomes 2004-2019.
- **How formative-only chapters are marked:** each has `unit` ending in "formative assessment only, not in board exam", so the app can label them. Biology XI Digestion and Absorption uses the same convention.

## Rationalised or removed content (not included)
- **Physics:**
  - XI: Physical World is removed.
  - XII: Communication Systems is removed. Polarisation and radioactivity are in the NCERT book but not in the curriculum.
- **Chemistry:**
  - XI: States of Matter, Hydrogen, s-Block, p-Block and Environmental Chemistry are removed as exam chapters. s- and p-block and the gaseous state are included only as formative-only chapters.
  - XII: Solid State and p-Block are removed. Surface Chemistry, Isolation, Polymers and Everyday Life are included only as formative-only chapters.
- **Maths:**
  - XI: Mathematical Induction and Mathematical Reasoning are removed. The sub-topics the curriculum marks as formative-only are kept as topics tagged "(formative only)".
  - XII: Probability is limited to conditional probability, independence, total probability and Bayes' theorem.
- **Biology:**
  - XI: Digestion and Absorption is out of the NCERT book, but CBSE keeps it as formatively assessed reading material. It is included as chapter 20 and sourced to the RM PDF. The excluded Biomolecules topics are dropped.
  - XII: Ecology covers populations only; succession and nutrient cycling are not included.
- **Computer Science:**
  - XI: the NCERT "Emerging Trends" chapter is not in the curriculum. Boolean Logic and Python Modules are added as curriculum chapters.
  - XII: Queue, Sorting, Searching, Understanding Data and Security Aspects are not in the curriculum. Python Revision Tour, Functions and Python-SQL interface are added.
- **Accountancy:**
  - XI: Bills of Exchange and Computers in Accounting are removed.
  - XII: Not-for-Profit Organisations is removed, and so are debenture redemption topics and the other curriculum exclusions.
  - Computerised Accounting, the alternative to Analysis of Financial Statements, is skipped.
- **Business Studies:**
  - XI: outsourcing, and ADR/GDR/FCCB, are omitted.
  - XII: Financial Markets is kept as chapter 10 because the 2026-27 curriculum still has it. Money-market instruments, the stock exchanges and SEBI's organisation structure are dropped.
- **Economics:**
  - Statistics: Measures of Dispersion and "Use of Statistical Tools" are removed.
  - Microeconomics: Non-competitive Markets, returns to scale, long-run costs and supply, and free entry and exit are removed.
  - Macroeconomics: demand for money is removed.
  - Indian Economic Development: Poverty and Infrastructure are removed.
- **History:**
  - XI: From the Beginning of Time, Central Islamic Lands, Industrial Revolution and Confrontation of Cultures are removed.
  - XII: Kings and Chronicles, Colonial Cities and Understanding Partition are removed.
- **Political Science:**
  - XI: Peace and Development is removed.
  - XII: Cold War Era, US Hegemony and Rise of Popular Movements are removed.
  - The annexure additions in the curriculum are included.
- **Geography:**
  - XI: Minerals and Rocks, Life on the Earth and Soils are removed. Climate Change, Biodiversity and Natural Hazards are in the files but are internally assessed only.
  - XII: Human Development (the India People and Economy chapter) and Manufacturing Industries are removed. Population Composition, Human Settlements (the Fundamentals of Human Geography chapter) and Migration are included only as formative-only chapters (2026-27).
  - XI: Minerals and Rocks is included only as a formative-only chapter (2026-27).
- **Psychology:**
  - XI: Bases of Human Behaviour is removed.
  - XII: Psychology and Life and Developing Psychological Skills are removed.
- **Not included:** practicals, project work, map work and the Practical Work in Geography books.

## Gaps and known limits
- **Topic breakdowns:** these come from the curriculum text and NCERT contents headings, not a page-by-page read of each chapter PDF. Section order inside a few History, Geography and Accountancy chapters is the likeliest thing to need adjusting.
- **Accountancy XI ch 10, Incomplete Records:** the chapter is in the 2026-27 curriculum but not listed in the current NCERT Part II contents. It is sourced to the CBSE PDF only.
- **Marks:** Physical Education XII unit marks do not add up to 70 in the curriculum PDF, so they are omitted. The Biology and CS unit marks span several chapters, so they are omitted too.
- **Physical Education XII unit 3:** the curriculum repeats the same asanas across diseases, so each disease's asana list is one topic string to keep topics unique.
- **Build scripts:** the JSON was generated from a compact text format by a builder script kept in the agent scratchpad, not the repo. Future edits should be made to the JSON directly.
