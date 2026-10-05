# Syllabus: ISC (CISCE) Classes 11 and 12

## What was built

- `server/internal/syllabus/data/icse-11.json`: board `ICSE`, class 11, session `2026-27`
- `server/internal/syllabus/data/icse-12.json`: board `ICSE`, class 12, session `2026-27`

Both files cover all 14 subjects in `profile.Subjects` (the `seniorISC` list): physics, chemistry, maths, biology, english, computer-science, accountancy, commerce, economics, history, political-science, geography, psychology, physical-education.

## Which syllabus each class uses

The current school year is 2026-27:

- **Class 12** students sit the ISC 2027 exam. They use the CLASS XII part of the ISC 2027 Regulations and Syllabuses (published Feb 2025). Physics uses the Feb 2026 re-issue.
- **Class 11** students sit the ISC 2028 exam. They use the CLASS XI part of the ISC 2028 Regulations and Syllabuses (published Jan 2026).

## Sources

All sources are official PDFs on cisce.org. Each chapter's `source` holds the exact URL, and each file's `sources` array lists the PDFs it used.

| Subject | Class 12 (ISC 2027) | Class 11 (ISC 2028) |
|---|---|---|
| Physics 861 | wp-content/uploads/2026/02/ISC-2027-Physics.pdf | 2026/01/18.-Physics.pdf |
| Chemistry 862 | 2025/04/19.-ISC-Chemistry-1.pdf | 2026/01/19.-Chemistry.pdf |
| Mathematics 860 | 2025/04/17.-ISC-Mathematics.pdf | 2026/01/17.-Mathematics.pdf |
| Biology 863 | 2025/04/20.-ISC-Biology.pdf | 2026/01/20.-Biology.pdf |
| English 801 | 2025/04/2.-ISC-English.pdf | 2026/01/2.-English-1.pdf |
| Computer Science 868 | 2025/04/25.-ISC-Computer-Science.doc.pdf | 2026/01/25.-Computer-Science.pdf |
| Accounts/Accountancy 858 | 2025/04/15.-ISC-Accounts.pdf | 2026/01/15.-Accountancy.pdf |
| Commerce / Business Studies 857 | 2025/04/14.-ISC-Commerce.doc.pdf | 2026/01/14.-Business-Studies.pdf |
| Economics 856 | 2025/04/13.-ISC-Economics-1.pdf | 2026/01/13.-Economics-1.pdf |
| History 851 | 2025/04/8.-ISC-History-2.pdf | 2026/01/8.-History.pdf |
| Political Science 852 | 2025/04/9.-ISC-Political-Science-1.pdf | 2026/01/9.-Political-Science.pdf |
| Geography 853 | 2025/04/10.-ISC-Geography-1.pdf | 2026/01/10.-Geography.pdf |
| Psychology 855 | 2025/04/12.-Psychology.pdf | 2026/01/12.-Psychology.pdf |
| Physical Education 875 | 2025/04/30.-ISC-Physical-Education-2.pdf | 2026/01/30.-Physical-Education.pdf |

All paths are relative to `https://cisce.org/wp-content/uploads/`.

**How chapters were formed:**
- Chapter topics come from the syllabus text, condensed.
- Where a syllabus unit is broad, it was split into chapters the way the common ISC books do. The books used were Nootan ISC Physics, S. Chand ISC Chemistry and Biology, ML Aggarwal ISC Maths, Sumita Arora for Computer Science, and T.S. Grewal-style for Accounts. These splits were made from memory of how the books are laid out and were not checked against copies.
- Each subject's `book` field records which of these applies.
- No textbook text was copied.

## Counts

Figures are chapters / lessons / topics.

| Subject | Class 11 | Class 12 |
|---|---|---|
| Physics | 22 / 88 / 280 | 21 / 73 / 234 |
| Chemistry | 15 / 65 / 236 | 11 / 56 / 202 |
| Maths | 19 / 56 / 205 | 15 / 51 / 158 |
| Biology | 19 / 72 / 237 | 13 / 54 / 192 |
| English | 9 / 22 / 66 | 9 / 22 / 66 |
| Computer Science | 16 / 47 / 154 | 16 / 46 / 133 |
| Accountancy | 17 / 64 / 173 | 15 / 60 / 151 |
| Commerce | 11 / 36 / 87 | 14 / 47 / 122 |
| Economics | 20 / 52 / 130 | 15 / 48 / 130 |
| History | 12 / 29 / 80 | 11 / 39 / 107 |
| Political Science | 12 / 27 / 78 | 10 / 30 / 91 |
| Geography | 14 / 43 / 127 | 19 / 55 / 164 |
| Psychology | 9 / 33 / 100 | 10 / 41 / 124 |
| Physical Education | 15 / 69 / 194 | 15 / 67 / 194 |
| **Total** | **210 / 703** | **194 / 689** |

## How it was checked

A python3 check ran on both files. It confirmed that:
- each file loads as valid JSON;
- chapter numbers run 1..n and are unique within every subject;
- each chapter has 2–6 lessons and 2–5 outcomes;
- the lessons' topics, joined in order, exactly equal the chapter's `topics`, so every topic sits in exactly one lesson;
- no chapter repeats a topic;
- `marks` is a positive integer wherever it appears.

The largest lesson has 7 short topics.

## Marks

`marks` is set only where the syllabus weightage belongs to exactly one chapter, for example Physics 12 Electromagnetic Waves 2, Dual Nature 7 and Electronic Devices 7. Where one weightage covers several chapters, it was not divided up, so those chapters have no `marks`.

These syllabuses give no theory weightage at all:
- Economics 11
- Psychology
- Physical Education
- Computer Science 12
- Accounts 12 (the 2027 document)

## Confidence

- **High:** the unit and topic lists in every subject, because they come straight from the official PDFs.
- **Medium:** chapter splits and titles inside broad units (physics, chemistry, maths, CS, accounts, commerce, geography, psychology), because they come from memory of the common textbooks.
- **Medium-low:** Accounts class 12, explained under Accounts class 12 source below.

## Things a teacher should check

1. **Accounts class 12 source.** The 2027-set file (`2025/04/15.-ISC-Accounts.pdf`) is headed "ACCOUNTS (858)" and has no year header. It was the only 858 file found in the 2027 upload set; the path that fits the other 2027 files returned 404, and no alternative was found. It still includes Redemption of Debentures and a Section B/C choice (Management Accounting or Computerised Accounting/DBMS).
   - The 2028 CLASS XII text drops Redemption of Debentures and DBMS and makes every unit compulsory.
   - A teacher should confirm what the 2027 cohort is being taught.
2. **Commerce and Business Studies.** Code 857 is "Commerce" for ISC 2027 and "Business Studies" for ISC 2028. Both files keep the app's subject id `commerce`. Class 11 shows the name "Commerce (Business Studies)" and uses the Business Studies syllabus. The app's subject label for ISC 11 may need updating.
3. **Maths has no Section A/B/C any more.** In both the 2027 and 2028 syllabuses every unit is compulsory: vectors, 3-D geometry, linear programming and probability are all in Class 12. `unit` holds the syllabus unit name.
4. **Biology class 11 (2028) has no Digestion chapter.** The syllabus omits it, and that was checked against the PDF.
5. **Physical Education, Section B.** Section B games (study any two of nine) are included as 9 separate chapters in both classes. The game text is the same in the 2027 and 2028 documents. A teacher may want these hidden unless the student picks them.
6. **English.** It is modelled as English Language skills: composition types, directed writing, proposal, grammar, comprehension, summary, and listening/speaking. The Literature in English prescribed texts were deliberately left out. The 2027 and 2028 Language syllabuses are identical, so both classes have the same 9 chapters.
7. **Thin chapters.** A few chapters have only 2–3 topics because the syllabus says little about them. Examples are Economics 11 "Mathematical Tools", CS 12 "Implementation of algorithms" and Physics 11 "Centre of Mass".
8. **Practical and project work** is excluded everywhere except the English listening/speaking chapter.

## Known limits and future work

- The ISC 2028 CLASS XII text is already published. When the session rolls over to 2027-28, `icse-12.json` needs rebuilding from the 2028 PDFs (see the accounts differences above).
- The chapter splits have not been cross-checked against physical copies of the textbooks.
