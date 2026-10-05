# Syllabus research: CBSE Classes 9 and 10 (session 2026-27)

## What was built

- `server/internal/syllabus/data/cbse-9.json`
- `server/internal/syllabus/data/cbse-10.json`

Both files use the agreed schema: board, class, session `"2026-27"`, sources, and subjects → chapters → lessons. They cover every subject that `profile.Subjects(9|10, "CBSE")` returns: `maths`, `science`, `social-science`, `english`, `hindi`, `sanskrit` and `computer`.

The scripts that generate the files are in the scratchpad, not the repo: `common.py`, `c9_stem.py`, `c9_hum.py`, `c10_stem.py`, `c10_sst.py`, `c10_lang.py`, `build.py` and `validate.py`. They produce the files and check them. Each chapter's `topics` list is built by joining its lessons' topics, so every topic sits in exactly one lesson, in textbook order.

## Counts

| Class | Subject | Chapters | Lessons |
|---|---|---|---|
| 9 | maths | 15 (8 in the book + 7 provisional) | 41 |
| 9 | science | 13 | 40 |
| 9 | social-science | 16 (9 in the book + 7 provisional) | 38 |
| 9 | english | 19 | 57 |
| 9 | hindi | 15 | 43 |
| 9 | sanskrit | 14 | 42 |
| 9 | computer | 4 | 10 |
| 10 | maths | 14 | 35 |
| 10 | science | 14 | 50 |
| 10 | social-science | 22 | 61 |
| 10 | english | 31 | 100 |
| 10 | hindi | 18 | 54 |
| 10 | sanskrit | 12 | 36 |
| 10 | computer | 4 | 11 |

Total: 96 chapters for Class 9 and 115 for Class 10. Each chapter has 2–5 lessons and 2–5 outcomes.

## Checks run

`python3 validate.py` checks that:
- each file loads as JSON with the right board, class and session;
- the subjects match the app's list, in order;
- chapter numbers are unique within each subject;
- the lessons' topics, joined in order, equal the chapter's topics, with no duplicates;
- each chapter has 2–5 lessons and 2–5 outcomes;
- every source is an https URL.

It passes for both files.

## Sources

The main sources are the CBSE 2026-27 curriculum page (https://cbseacademic.nic.in/curriculum_2027.html) and its subject PDFs under `web_material/CurriculumMain27/SecPart1/`:

| File | Used for |
|---|---|
| `Maths_SecP1IX` | Class 9 Maths |
| `Maths_SecP1X` | Class 10 Maths |
| `ScienceSt_SecP1` | Class 9 Science (Standard) |
| `Science_SecP1` | Class 10 Science |
| `Science_SecP1IX_2026-27_RM` | CBSE reading material for Class 10 Science |
| `SocialScience_SecP1IX` | Class 9 Social Science |
| `SocialScience_SecP1X` | Class 10 Social Science |
| `English_LL_SecP1IX` | Class 9 English |
| `English_LL_SecP1` | Class 10 English |
| `Hindi_SecP1IX` | Class 9 Hindi |
| `Hindi_A_SecP1` | Class 10 Hindi Course A |
| `Sanskrit_SecP1IX` | Class 9 Sanskrit |
| `Sanskrit_SecP1` | Class 10 Sanskrit |
| `Computer_Applications_SecP1IX` | Class 9 Computer Applications |
| `Computer_Applications_SecP1X` | Class 10 Computer Applications |

NCERT contents pages and chapter PDFs from `https://ncert.nic.in/textbook/pdf/` were used to check chapter numbers and titles:

- **Class 10 books:** `jemh1ps`, `jesc1ps`, `jess1ps`–`jess4ps`, `jeff1ps`, `jefp1ps`, `jhks1ps`, `jhkr1ps` and `jhsk1ps`. All are "Reprint 2026-27".
- **New Class 9 books:** Ganita Manjari Part I (`iemh1ps` plus chapters), Exploration (`iesc101`–`113`), Understanding Society: India and Beyond Part 1 (`iest101`–`109`), Kaveri (`iebe1ps` plus units), Ganga (`ihga101`–`112`) and Sharada (`ihsh101`–`116`). The list of books comes from the NCERT textbook index.

The following sites were used only to cross-check chapter titles that appear as images in the NCERT PDFs:

- A study website: Ganga chapter list
- Web search results listing the Sharada and Exploration chapters. These were then confirmed against text inside the NCERT chapter PDFs.

No passages, poems or stories from the textbooks were copied. Topics are short factual descriptions.

## Changes from 2025-26

The work started on 2025-26. The orchestrator then corrected the session to 2026-27, and everything was rebuilt against the 2026-27 sources.

**Class 9: new NCERT books (NCF-SE 2023) replace the old ones completely.**
- **Maths:** Ganita Manjari Part I replaces the old 12-chapter book. It has 8 chapters with new titles, in a new order.
- **Science:** Exploration has 13 chapters. New topics include cells, tissues and the musculoskeletal system, mixtures, simple machines, diversity and classification, and Earth as a system.
- **Social Science:** the four separate books (History, Geography, Political Science, Economics) are replaced by one book, Understanding Society: India and Beyond. Part 1 has 9 chapters.
- **English:** Kaveri (8 units, each with a prose piece and a poem) replaces Beehive and Moments. The grammar list adds conditionals (type 1) and noun and relative clauses. The paper is now reading 20, grammar 10, writing 20 and literature 30.
- **Hindi:** Ganga (12 chapters) replaces Kshitij and Kritika. The same book serves both R1 and R2.
- **Sanskrit:** Sharada (11 lessons plus 5 grammar appendices) replaces Shemushi. The grammar adds पूर्वरूप and तुगागम sandhi, tatpurusha samasa and उच्चारणस्थान.
- **Computer Applications:** unchanged.

**Class 10: the same NCERT books and chapter list as 2025-26, with these changes:**
- **Science:** three topics are back as formative-only CBSE reading material. They are taught but not tested in the board exam:
  - Periodic Classification of Elements, added as chapter 14 with the unit "CBSE Reading Material (formative assessment only)";
  - Evolution, added as an extra lesson in chapter 8, Heredity;
  - Electric motor, electromagnetic induction and generator, added as an extra lesson in chapter 12.
- **Hindi A:** the NCERT 2026-27 reprint of Kshitij 2 and Kritika 2 no longer contains the chapters CBSE excludes. Kshitij 2 now numbers 1–12 and Kritika 2 numbers 1–3.
- **Maths, Social Science, English, Sanskrit and Computer Applications:** unchanged.

## Numbering scheme

- **Maths and Science:** chapter number = NCERT chapter number.
- **Class 10 Science, Light:** "Light – Reflection and Refraction" is chapter **9** in the current NCERT book (`jesc1ps`, Reprint 2026-27), not 10. The seeded lesson uses `science` chapter 10, which is the numbering from before 2023, when the book still included Periodic Classification. I used the NCERT number, 9. **The seeded lesson needs renumbering to 9, or it will line up with "The Human Eye and the Colourful World".**
- **Class 10 Maths:** "Pair of Linear Equations in Two Variables" is chapter 3, which matches the seed.
- **Social Science, Class 10:** numbering continues across the four books:
  - History: 1–5
  - Geography: 6–12
  - Political Science: 13–17
  - Economics: 18–22

  The book name is in `unit`.
- **Social Science, Class 9:** one book, so numbering follows it. Part 1 is 1–9 and the provisional Part 2 is 10–16.
- **English and Hindi:** numbering is sequential in book order and continues from the main reader into the supplementary reader. Each English poem is its own chapter, with `unit` saying which it is (for example "First Flight – Poem" or "Kaveri – Unit 3 (poem)"). After the literature come chapters for Reading, Grammar and Writing, which carry the exam marks.
- **Sanskrit:** keeps the NCERT lesson numbers, with the grammar and writing chapters numbered after them. Class 10 skips 9, भूकम्पविभीषिका, which CBSE does not examine.
- **Computer Applications:** there is no NCERT book, so chapters are the CBSE units 1–4.
- **`marks`:** set only where CBSE gives marks to a unit that is a single chapter (for example Class 10 Maths chapters 1 and 7, and Class 9 Science chapter 13), or to a language section or Computer Applications unit. Units that span several chapters have no `marks`. The unit is named in `unit` instead.

## Gaps and limits

1. **Class 9 Maths Part II is not out yet.** The CBSE syllabus also covers these chapters:
   - Linear Equations in Two Variables
   - Introduction to Euclid's Geometry
   - Lines and Angles
   - Triangles: Congruence Theorems
   - 4-gons (Quadrilaterals)
   - Surface Area and Volume
   - Statistics

   NCERT has not published them (`iemh2ps` returns 404). They are included as chapters 9–15, built from the CBSE curriculum, and `unit` says "chapter number provisional". Renumber them when Part II comes out.
2. **Class 9 Social Science Part 2 is not out yet.** Seven themes (Oceans and Life through Smart Ways to Manage Your Finances) are included as chapters 10–16, marked provisional, with the CBSE PDF as source. CBSE says "Course Structure will be provided shortly", so Class 9 Social Science has no marks.
3. **Class 9 Sanskrit:** CBSE says the lessons set for the exam will be notified soon, so all 11 Sharada lessons are included.
4. **Hindi:** the app has one `hindi` code. Class 10 uses Course A (002: Kshitij and Kritika). Hindi Course B (085: Sparsh and Sanchayan) is not covered. For Class 9, Ganga serves both R1 and R2. The grammar list follows R1.
5. **Class 9 Maths and Science:** CBSE also offers Maths Advanced and Science Advanced. The catalogue follows Standard, the only one the app offers.
6. **Chapter summaries for the new Class 9 language books:** the topics for Kaveri, Ganga and Sharada are brief, taken from the chapter PDFs and exercise headings. They are less detailed than the Class 10 ones and are worth enriching once the lesson generator reads the full chapters.
7. **Class 10 Social Science assessment notes:** some chapters are assessed only partly, or only internally:
   - Age of Industrialisation: periodic assessment only.
   - Lifelines of National Economy: map work only in the board exam.
   - Consumer Rights: project work.
   - Making of a Global World: only subtopics 1–1.3 in the board exam.

   They are all included because they are in the syllabus. The schema has no field for this, so it is recorded only here.
