# Syllabus: CBSE Classes 6–8 (session 2026-27)

## What was built

- `server/internal/syllabus/data/cbse-6.json`
- `server/internal/syllabus/data/cbse-7.json`
- `server/internal/syllabus/data/cbse-8.json`

The files follow the schema from the task brief. They are UTF-8 with a 2-space indent and have `"session": "2026-27"`. The session was changed after the orchestrator's correction.

Each file covers exactly the six subjects that `profile.Subjects(class, "CBSE")` returns for classes 6 to 8: maths, science, social-science, english, hindi and sanskrit. The subjects appear in that order.

## Sources

Every chapter title comes from the contents page of the official NCERT textbook PDF on ncert.nic.in. All of these PDFs carry the footer "Reprint 2026-27". The one exception is class 8 Ganita Prakash Part II, whose front matter is dated December 2025 and has no reprint footer. It is still the current book.

Book codes were taken from the live catalogue at https://ncert.nic.in/textbook.php.

- **Topics:** built from each chapter's section headings in the chapter PDFs, `https://ncert.nic.in/textbook/pdf/<code><NN>.pdf`. Each chapter's `source` field points to its own PDF.
- **Language subjects:** the exercise sections were used for grammar, vocabulary and writing topics. No literary text is reproduced; only titles, genres, authors, themes and skills are included.
- **Outcomes:** written in our own words. The books have no formal outcome lists.

| Subject | Class 6 | Class 7 | Class 8 |
|---|---|---|---|
| Maths | Ganita Prakash (fegp1) | Ganita Prakash Part I + II (gegp1, gegp2) | Ganita Prakash Part I + II (hegp1, hegp2) |
| Science | Curiosity (fecu1) | Curiosity (gecu1) | Curiosity (hecu1) |
| Social Science | Exploring Society: India and Beyond (fees1) | Part I + II (gees1, gees2) | Part I + II (hees1, hees2) |
| English | Poorvi (fepr1) | Poorvi (gepr1) | Poorvi (hepr1) |
| Hindi | Malhar (fhml1) | Malhar (ghml1) | Malhar (hhml1) |
| Sanskrit | Deepakam (fsde1) | Deepakam (gsde1) | Deepakam (hsde1) |

Cross-checks:

- Hindi and Sanskrit titles were cross-checked against study websites.

Where these disagreed with ncert.nic.in, the NCERT version was used.

CBSE circulars:

- Circular Acad-17/2026 (R3 in Class VI) and Circular Acad-33/2026 were read.
- cbseacademic.nic.in has published no separate middle-stage curriculum PDF for 2026-27; its 2026-27 curriculum page covers only Classes IX–XII. The NCERT books are therefore the syllabus.

## Counts

| Class | Subjects | Chapters | Lessons | Topics |
|---|---|---|---|---|
| 6 | 6 | 70 (Ma 10, Sc 12, SS 14, En 5 units, Hi 13, Sa 16) | 217 | 632 |
| 7 | 6 | 74 (Ma 15, Sc 12, SS 20, En 5, Hi 10, Sa 12) | 244 | 686 |
| 8 | 6 | 70 (Ma 14, Sc 13, SS 15, En 5, Hi 10, Sa 13) | 229 | 703 |

The total is 214 chapters and 690 lessons.

## Validation

The script is `scratchpad/merge.py`, a copy of `validate_cbse_6_8.py`. It builds the three files from per-subject parts, then reloads the JSON and checks the following. It passed for all three classes.

- The subject list matches `Subjects()`.
- Chapter numbers run 1..n with no gaps.
- Each chapter has 2–5 outcomes and 2–5 lessons.
- There are no duplicate topics.
- The lessons' topics, joined in order, equal the chapter's topics exactly, so every topic is in exactly one lesson and in textbook order.
- Every source is an https URL.

## How two-part books and units are stored

- **Two-part books (class 7 and 8 maths and social science):** chapter numbers continue across the parts. The `unit` field names the part.
  - Maths: "Ganita Prakash Part I", or "Ganita Prakash Part II, Chapter n" with n being the official number in that part.
  - Social science: "Part I: Theme A — …".
- **English:** chapters are the five Poorvi units, with `unit` set to "". Each unit's pieces become reading topics, followed by its grammar, vocabulary, speaking and writing points.
- **Hindi and Sanskrit:** Malhar and Deepakam have no units, so each chapter is a chapter.

## Differences from 2025-26

For these books, none. The 2026-27 reprints have the same chapter lists as the 2025-26 books. The one change inside a chapter:

- **Class 8 Social Science Part II, Chapter 4 (our chapter 11):** "The Role of the Judiciary in Our Society" was rewritten in 2026. A committee set up by the Ministry of Education rewrote it under the Supreme Court's Suo Motu Writ Petition (Civil) No. 1/2026, by an order dated 16 March 2026. Topics follow the rewritten PDF now on ncert.nic.in.

Changes elsewhere in CBSE policy:

- **Third language (R3) from Class VI:** CBSE made R3 compulsory from Class VI in 2026-27 (Circular Acad-17/2026). NCERT is publishing new R3 textbooks in 19 languages, and Hindi and Sanskrit R3 books for Class 9 ("Reva", "Irawati") came out in July 2026. They supplement the regular books and do not replace them.
- **Class 6 R3 books:** they are not on the ncert.nic.in catalogue yet, so they are not included. Malhar and Deepakam remain the Hindi and Sanskrit books.

## Discrepancies and uncertainties

- **Class 7 maths, Part II:** the "About the Book" page describes chapter 2 as "Integers — Multiplication and Division" and chapter 4 as "Decimals — Multiplication and Division". The contents page and the chapter PDFs say "Operations with Integers" and "Another Peek Beyond the Point", and those titles were used.
- **Class 8 Social Science:**
  - The judiciary chapter is called "…in Our Society" on the contents page and "…in Society" in the front-matter note. The contents-page title was used.
  - "Cultural Currents: 13th to 17th Centuries" is placed last in Part II, as in the contents. The book says it belongs to Theme C and will later move to Part I.
  - An inter-theme essay on the Paika Sangram and Sambalpur uprising sits between chapters and is not a numbered chapter, so it was omitted.
  - "A Note on History's Darker Periods" is folded into chapter 2 as its first topic.
- **Class 6 Social Science:** the introduction "Why Social Science?" is not a numbered chapter and was omitted.
- **Class 6 Sanskrit:** there are 16 chapters. Some mirrors still list 15, with "संख्यागणना ननु सरला" as chapter 13; NCERT has it as chapter 5.
- **Sanskrit title spellings:** NCERT's spellings were used where mirrors differ: "संख्यागणना", "सुभाषितरसं…" and "प्रणम्यो…".
- **Class 7 Sanskrit, chapter 6:** the title "क्रीडाम वयं श्लोकान्त्याक्षरीम्" was rebuilt from garbled PDF text and matches the mirrors.
- **Sanskrit appendices:** the noun and verb forms appendices and the class 7 "वर्णमाला-परिचयः" extra reading are not numbered chapters and were omitted. Class 8 "वर्णोच्चारण-शिक्षा १" is numbered, so it is included.
- **Hindi mirror errors:**
  - A study website calls class 6 "परीक्षा" a poem; NCERT says it is a story.
  - A study website names the poet of class 8 "स्वदेश" as Dinkar; NCERT credits गयाप्रसाद शुक्ल 'सनेही', which was used.
  - The "पढ़ने के लिए" supplementary readings appear as topics, not chapters.
- **Hindi grammar topics:** the extracted class 8 text is too garbled to read reliably, so its grammar and exercise topics come from a study website's chapter pages. Class 7 chapters 6 and 9 have thinner grammar topic lists.
- **English:**
  - Class 6 Unit 5 has four pieces, not three.
  - Piece genres (story, play, poem and so on) are our reading; the book does not label them.
  - A few grammar points in class 8 units 2 and 3 were inferred from partly garbled exercise pages.
- **Science:**
  - Chapter 1 in each class and class 6 chapter 9 have no numbered sections, so their topics summarise the chapter's own themes and summary.
  - Apostrophes are straight quotes.
- **Topics named by us:**
  - Maths: "Perimeter of a Rectangle and a Square" and "Perimeter of a Triangle and Regular Polygons" in class 6.
  - Social science: a few chapter openings with no headings, such as "India, That Is Bharat" and "From Barter to Money".
- **Lesson length:** the 5–8 minute lesson length is an estimate from topic density. Nothing was timed.

## Needs from the user

Nothing.

## Future improvements

- Add the Class VI R3 textbooks once NCERT lists them.
- Re-check the Hindi and Sanskrit topic wording with a native reader.
- Re-run the pipeline when NCERT publishes 2027-28 reprints.
