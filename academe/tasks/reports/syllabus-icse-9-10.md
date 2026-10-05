# Syllabus research: ICSE Classes 9 and 10

## What was built

- `server/internal/syllabus/data/icse-9.json`: board "ICSE", class 9, session "2026-27"
- `server/internal/syllabus/data/icse-10.json`: board "ICSE", class 10, session "2026-27"

The two files are pinned to the exam each class sits:

- **Class 10 (2026-27)** sits the **ICSE 2027** exam, so `icse-10.json` follows the 2027 syllabus's Class X section.
- **Class 9 (2026-27)** sits the **ICSE 2028** exam, so `icse-9.json` follows the 2028 syllabus's Class IX section.
  - Physics, Chemistry and Biology were rebuilt from the 2028 PDFs, where the content changed.
  - English, Hindi, Maths, History & Civics, Geography and Computer Applications keep the 2027 Class IX content. Their 2028 text matches 2027 apart from formatting. Computer Applications 2028 was not diffed, but 2026 and 2027 were identical.

Each file contains all 9 subjects that `profile.Subjects` returns for ICSE classes 9 and 10: english, hindi, maths, physics, chemistry, biology, history-civics, geography, computer. No Go code was added.

| Subject | Class 9 chapters / lessons / topics | Class 10 chapters / lessons / topics |
|---|---|---|
| English | 14 / 38 / 98 | 13 / 35 / 82 |
| Hindi | 8 / 20 / 49 | 8 / 21 / 48 |
| Maths | 28 / 72 / 127 | 25 / 70 / 122 |
| Physics | 10 / 36 / 120 (2028) | 12 / 45 / 158 |
| Chemistry | 8 / 28 / 91 (2028) | 12 / 43 / 112 |
| Biology | 14 / 33 / 81 (2028) | 15 / 45 / 113 |
| History & Civics | 17 / 51 / 132 | 21 / 56 / 163 |
| Geography | 19 / 49 / 126 | 13 / 41 / 108 |
| Computer Applications | 10 / 34 / 74 | 8 / 29 / 66 |
| **Total** | **128 / 361 / 898** | **127 / 385 / 972** |

## Sources

All from cisce.org. The Regulations and Syllabuses index for ICSE 2027 is https://cisce.org/regulations-and-syllabus-icse-2027/.

- English: https://cisce.org/wp-content/uploads/2025/03/2.-English.pdf
- Second Languages (Hindi), revised April 2026 with the prescribed texts split between IX and X: https://cisce.org/wp-content/uploads/2026/04/3.-Second-Languages.pdf
- History & Civics: https://cisce.org/wp-content/uploads/2025/03/ICSE-History-Civics.pdf
- Geography: https://cisce.org/wp-content/uploads/2025/03/ICSE-Geography.pdf
- Mathematics: https://cisce.org/wp-content/uploads/2025/03/9.-Mathematics.pdf
- Physics: https://cisce.org/wp-content/uploads/2025/03/10.-Physics.pdf
- Chemistry: https://cisce.org/wp-content/uploads/2025/03/11.-Chemistry.pdf
- Biology: https://cisce.org/wp-content/uploads/2025/03/12.-Biology.pdf
- Computer Applications: https://cisce.org/wp-content/uploads/2025/03/18.-Computer-Applications.pdf
- Appendix I, prescribed books (titles only): https://cisce.org/wp-content/uploads/2026/04/ICSE-2027-Appendix-I-List-of-Prescribed-Books.pdf
- ICSE 2028 syllabus (January 2026), index at https://cisce.org/regulations-and-syllabuses-icse-2028/. Class 9 Physics, Chemistry and Biology come from:
  - https://cisce.org/wp-content/uploads/2026/01/10.-Physics.pdf
  - https://cisce.org/wp-content/uploads/2026/01/11.-Chemistry.pdf
  - https://cisce.org/wp-content/uploads/2026/01/12.-Biology.pdf
- Compared against the ICSE 2026 syllabus PDFs listed at https://cisce.org/regulations-and-syllabus-icse-2026/.

**Chapter titles.** Where the syllabus is organised by topic, chapter titles and splits follow the usual ICSE books. The `book` field on each subject says which book applies:

- Physics, Chemistry, Biology and Maths: Selina Concise
- History & Civics and Geography: Total History & Civics and Total Geography (Morning Star)
- Computer Applications: the syllabus topic order, titled as in Understanding Computer Applications with BlueJ

**Language subjects.** English and Hindi are organised by skill:

- Paper 1 (English) and Section A (Hindi) are split by question type: composition, letter, notice and email, comprehension, summary, then the grammar areas.
- Paper 2 and Section B are taught as reading skills: drama, short story and poetry techniques, and literature assignments.
- Internal assessment is covered as listening and speaking.
- No literary text, plot or quotation is included. Prescribed book names appear only in `book`.

## Validation

- `python3 check.py` in the scratchpad checks both files:
  - both parse as JSON
  - chapter numbers run 1..n and are unique per subject
  - every chapter has 2–5 outcomes and 2–5 lessons
  - every topic appears in exactly one lesson, and the lessons joined in order equal the chapter's topic list
  - there are no duplicate topics
  - every source URL is https
- `go test ./internal/syllabus/` passes (re-run after the 2028 rebuild). The embedded loader accepts both files, and every subject is allowed for ICSE class 9 and 10.

## Syllabus changes: 2026 to 2027 (both files follow 2027)

- **Maths, Computer Applications, Biology, Geography IX, English:** no topic changes. The Maths paper grew from 2½ h to 3 h.
- **Chemistry X:** 2027 adds non-polar covalent compounds, indicators (methyl orange, phenolphthalein), hydrogen sulphites, CuSO₄ electrolysis with Pt and Cu electrodes, electroplating electrolytes, alloys and amalgams, aqua regia, and tests for HCl, NH₃, HNO₃ and H₂SO₄.
- **Civics IX:** Local Self-Government is replaced by The State Legislature. Fundamental Rights vs Directive Principles, the welfare state and Election Commission functions are added.
- **History IX:** 2027 asks for rulers in chronological order plus specific policies instead of named kings. Examples: Alauddin Khilji's reforms, Tughlaq, Babur's battles, Akbar's Rajput policy and mansabdari. The Vedic assemblies, varna and ashrama, and capitalism vs socialism are also added.
- **Civics and History X:** added parliamentary procedures (question hour, zero hour, anti-defection, passing of bills), effects of emergencies, consequences of 1857, Dayananda and Vivekananda, the Lucknow Pact, the Cold War with NATO and Warsaw, and the UDHR.
- **Geography X:** the Location, Extent and Physical Features chapter is dropped and the India map list is trimmed. Added: El Niño, irrigation methods, the Green Revolution, the Golden Quadrilateral and NSEW corridors, and waste terms (acid rain, eutrophication, biomagnification).
- **Hindi:** Section A (language) is unchanged. From 2027 the prescribed texts are split, and the Class X exam covers only the Class X portion (CISCE circular 2026-27/33).

## Class 9 science: what changed from 2027 to 2028

These changes are already applied in `icse-9.json`.

- **Physics IX:**
  - Added:
    - least count concept and pictorial calliper and screw gauge numericals
    - motion under gravity, and graphical derivation of the equations of motion
    - inverse square relation, static and dynamic inertia, applications of the second law and of gravitation
    - factors affecting fluid pressure, Pascal's law numericals, and the three upthrust cases
    - paths of specific rays and the Cartesian sign convention
    - wave motion (transverse and longitudinal waves), time period, infrasonic vs subsonic
    - free electrons, types of conductors, quantum nature of charge, resistance, and Ohm's law
  - Removed: atmospheric pressure, energy flow and energy sources, perpendicular mirrors, social initiatives on saving electricity, and the electromagnet.
  - Uniform circular motion leaves Class X in 2028. That does not affect the Class 10 file (2027 cohort).
- **Chemistry IX:**
  - Added:
    - radicals in the atmosphere and their effects
    - double displacement reactions (Na₂SO₄ + BaCl₂, AgNO₃ + NaCl, Pb(NO₃)₂ + KI)
    - colloids and suspensions, supersaturated solutions and solubility curves
    - water purification and water-borne diseases
    - Rutherford and Bohr models, and radical formation when a covalent bond breaks
    - transition element placement
    - redox by electron transfer
    - derivation and graphs of Boyle's and Charles's laws
    - water pollution, including Minamata disease
  - Renamed: the last chapter is now "Atmospheric and Environmental Chemistry".
- **Biology IX:**
  - Five-kingdom classification is replaced by Diversity in the Animal Kingdom (Porifera to Echinodermata, plus the five chordate classes).
  - Removed: the respiratory system (moved to X), personal hygiene, active and passive immunity, and waste generation and management.
  - Added: inflorescence and placentation.
  - Biology IX now has 14 chapters instead of 17.

## Confidence

- **High:** topics and their order. They were read from the official PDFs; topics are paraphrased as short noun phrases, not copied.
- **Medium:** chapter titles and splits taken from the books. They are from memory of recent editions and were not checked against a physical copy. Split points include Maths statistics, the Chemistry X "Study of Compounds" chapters (8–11, which some editions number 8A–8D), and the Morning Star chapter splits.
- **Medium-low:** grammar sub-topics for English and Hindi, and the Class 9 vs 10 split of the language skills. The syllabus lists grammar only broadly and treats the language paper as one two-year block.

## Teacher checks

1. Selina, Morning Star and APC chapter titles and order against current editions, in particular:
   - Biology 9: teeth are placed under the Digestive System
   - Biology 10: Population comes before Human Evolution
   - Civics 9: "The State Legislature" is a new 2027 chapter
2. Context topics added that the syllabus does not name explicitly:
   - Physics: "Uniform acceleration"
   - Maths: "relations between the ratios" and time/speed/work word problems
   - History: "main events of 1857", which the syllabus says are for continuity only
   - Geography: "evidence for the earth's shape"
3. Hindi grammar breakdown (synonyms, antonyms, abstract nouns, adjectives, sentence correction and transformation, idioms). The syllabus lists vocabulary, syntax, idioms, synthesis and sentence formation only.
4. English Class 10 drama and short-story theme labels, chosen to fit the prescribed Class X texts without describing them.
5. Map-work topics are grouped rather than listing every feature. Check them against the 2027 India map list.
6. Maths and Computer Applications Class 10 chapter 1 ("Revision of Class IX") could be marked optional in the app.
7. Practical and internal-assessment experiment lists are not modelled as chapters.

## Needs the user

Nothing (no keys or console setup).

## Future improvements

- Each school year, move Class 10 to the next exam year's Class X section. In 2027-28, Class 10 will follow the 2028 syllabus, which changes Physics, Chemistry and Biology.
- Split language-paper grammar by class once a school's scheme of work is available.
