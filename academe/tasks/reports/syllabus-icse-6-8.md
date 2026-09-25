# Syllabus data: ICSE Classes 6, 7 and 8

## What was built

- `server/internal/syllabus/data/icse-6.json`: 9 subjects, 89 chapters, 269 lessons
- `server/internal/syllabus/data/icse-7.json`: 9 subjects, 98 chapters, 278 lessons
- `server/internal/syllabus/data/icse-8.json`: 9 subjects, 103 chapters, 270 lessons

Each file has board `ICSE` and session `2026-27`, the current school year. The subjects are exactly what `profile.Subjects` returns for ICSE Classes 6 to 8: english, hindi, maths, physics, chemistry, biology, history-civics, geography, computer. Every chapter has:

- 2 to 5 outcomes
- 2 to 5 lessons, in order
- no more than 6 topics per lesson (sized for 5 to 8 minutes)
- each topic in exactly one lesson

Language subjects are grammar, vocabulary and writing units. There is no reader or literature content. All text is my own wording; nothing is copied from a textbook.

The generator scripts are in the session scratchpad: `syl/build.py` has the shared builder and checks, `syl/icse6.py`, `icse7.py` and `icse8.py` hold the data, and `syl/newmaths.py` rebuilds Maths 6 and 7 in the current edition's chapter order. No Go code was changed.

## Why the lists come from textbooks

CISCE publishes a Curriculum for Classes I to VIII, but it is a print publication. cisce.org sits behind a Cloudflare challenge, and I could not download the Classes VI to VIII documents. So the chapter lists come from the most widely used ICSE-aligned books:

- Selina Concise is the standard series for all three sciences at all three classes.
- For History & Civics and Geography, three publishers (Frank, Goyal, Beeta/Kundra) have almost the same chapter lists. That suggests the lists follow the CISCE curriculum.

Each subject's `book` field names the textbook and publisher. Each chapter's `source` is the publisher's site, or cisce.org where the chapters follow the CISCE curriculum rather than one book.

| Subject | Class 6 | Class 7 | Class 8 |
|---|---|---|---|
| Maths | Selina Concise, current 22-chapter edition | Selina Concise, current 25-chapter edition | Selina Concise, 25 chapters |
| Physics, Chemistry, Biology | Selina Concise | Selina Concise | Selina Concise |
| History & Civics | Frank (latest edition, labelled "2025-26 syllabus"; same list as Effective History & Civics) | Frank (15 chapters) | Kundra, latest edition (same scope as Effective History & Civics) |
| Geography | Frank (latest edition, labelled "2025-26 syllabus"; same list as Goyal) | Frank (same list as Goyal) | Veena Bhargava/Goyal, 2026 edition |
| Computer | CISCE Computer Studies topics | CISCE Computer Studies topics | CISCE Computer Studies topics |
| English | CISCE English grammar, vocabulary and writing scope | Same | Same |
| Hindi | General Class 6 vyakaran list | General Class 7 vyakaran list | General Class 8 grammar list |

In Class 8 Physics, the book's chapter 8 has two parts (8a Household Electricity, 8b Static Electricity). They are chapters 8 and 9 in the file.

## Confidence per subject

For all subjects, the sub-topics and lesson splits are written from subject knowledge of these books. I checked chapter titles and order against the sources; I did not check the topics inside each chapter against the printed books.

- **Physics, Chemistry, Biology: chapter lists high, topics medium.** The lists follow the newest edition, marked "2027 Edition", which is the 2026-27 book. For example, older Class 6 Physics editions opened with Measurement and had an Energy chapter.
- **Maths: medium (Class 8 medium-high).** Selina has restructured its Class 6 and 7 books, and the new editions are in use for 2026-27. The current Class 6 book has 22 chapters. The files now follow the new editions:
  - Class 6 has 22 chapters instead of the old 34. The old chapters are regrouped: Estimation and Place Value moved into Number System; Number Line into Integers; HCF and LCM into Playing with Numbers; Ratio, Proportion and Unitary Method into one chapter; algebra operations and Substitution into Fundamental Concepts of Algebra; Simple Equations into Framing Algebraic Expressions; Angles into Fundamental Concepts of Geometry; Polygons into Quadrilaterals; Mean and Median into Data Handling. A new Constructions chapter was added.
  - Class 7 has 25 chapters instead of 22. Set Concepts moved to chapter 6. There are new chapters on Speed, Distance and Time (12), Inequalities (15) and Constructions (22). Angle and triangle constructions moved into Constructions.
  - Chapters 1-18 of Class 7 are the most certain. Chapters 20 (Recognition of Solids) and 22 (Constructions) are least certain.
  - The topics inside the regrouped chapters carry over from the old edition. I have not checked them against the new books.

- **History & Civics: chapter lists high, topics medium.** Class 8 publishers differ in how they split the chapters. For example, Effective History & Civics has separate chapters on the American War of Independence and on UN agencies; here they sit inside Kundra's chapters.
- **Geography: chapter lists high, topics medium.** The Class 7 Europe and Africa chapters include the case studies from Around the World (Tourism in Switzerland, Cocoa in Ghana). Check that the school's book has them.
- **Computer: medium.** These are curriculum topics, not one book. Understanding Computer Studies and Logix name and order chapters differently. The Class 8 "App Development" chapter is only named in the syllabus summary and has no detail there, so its contents are my inference.
- **English: medium-low.** The units are built from the CISCE grammar, vocabulary and writing scope, not from a book's chapters. How grammar points are grouped into units is my choice.
- **Hindi: low.** I found no ICSE-specific Hindi source for Classes 6 to 8. The units follow general Hindi grammar lists for each class and are not tied to one book.

## What a teacher should double-check

1. **Maths Class 6 and 7.** Check the chapter numbering against a printed 2026-27 copy, especially Class 7 chapters 19-25 and the topics inside the merged Class 6 chapters. Chapter numbers are stable IDs in `Plan`.
2. **Hindi.** Check the unit split, the Devanagari terms, and which class introduces sandhi, samas, vachya and lokoktiyan.
3. **Class 8 Computer "App Development".** Check which tool is used, such as MIT App Inventor or Thunkable.
4. **Science sub-topics** at the edges of each chapter. Examples: eclipses in Class 6 Light, chromatography in Class 7 Chemistry chapter 3, dialysis in Class 7 Excretion, the greenhouse effect in Class 8 Carbon.
5. **Class 8 History.** Check where the American War of Independence and the Industrial Revolution sit. Here they are inside "A Period of Transition" and "The Growth of Nationalism".

## How it was tested

- The `build.py` check (Python, `json` module) ran on all three files. It covers: the exact subject set, unique chapter numbers, every topic in exactly one lesson in order, 2 to 5 lessons and outcomes per chapter, and a URL source on every chapter.
- `go test -count=1 ./internal/syllabus/` passes. It loads the real data with `DisallowUnknownFields` and checks the file name against board and class, the subject whitelist and the topic rules.

## Known limits and future work

- When the CISCE Curriculum for Classes I to VIII can be obtained (print, or cisce.org without the challenge), re-check the chapter scope against it and drop the textbook dependence where they differ.
- Check the topics inside Maths 6 and 7 against the new Selina editions once a printed copy or table of contents is available.
