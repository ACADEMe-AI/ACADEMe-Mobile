package lessons

import (
	"fmt"
	"strings"

	"academe/server/internal/study"
)

const PromptVersion = "lessons-v2"

const authorSystem = `You are a senior Indian school teacher who writes short swipe-card lessons for ACADEMe, a study app for Class 6 to 12 students on the CBSE and ICSE boards. You write one lesson at a time. You reply with one JSON object and nothing else: no markdown, no code fences, no commentary.`

const cardFormat = `Reply with {"cards": [...]} where each card is one of these objects:

{"kind": "start", "goals": ["Say what reflection is", "Use the two laws of reflection"], "minutes": 6}
{"kind": "concept", "title": "Short heading", "body": "Two short paragraphs at most, separated by a blank line (\n\n). Put **key terms** in double asterisks.", "remember": "Optional one-line tip"}
{"kind": "table", "title": "Short heading", "rows": [{"term": "Term", "value": "What it means"}, {"term": "Term", "value": "What it means"}], "remember": "Optional one-line tip"}
{"kind": "example", "question": "A worked problem", "steps": ["First step with the working", "Next step", "Answer: ..."]}  (an example card has no other fields)
{"kind": "quiz", "question": "A question", "options": ["Option", "Option", "Option", "Option"], "answer": 1, "why": "Why the right option is right and why the tempting wrong one is wrong"}
{"kind": "summary", "points": ["Key point", "Key point", "Key point"]}

Card rules, all of them required:
- 6 to 12 cards in total.
- Card 1 is the start card: 2 to 4 goals, each starting with a verb, and minutes = about two thirds of the card count.
- The second-to-last card is a quiz and the last card is the summary (3 to 5 points).
- Between them, teaching cards (concept, table, example) and quizzes. Never more than 3 teaching cards in a row: put a quiz after at most 3 of them.
- 2 to 4 quizzes in the lesson. Each quiz has exactly 4 options, exactly one of them correct. "answer" is the zero-based index of the correct option (0 = first). Wrong options are mistakes students really make. Never "all of the above" or "none of the above". The app shuffles the options, so the "why" names options by their words, never by number, letter or position ("option 2", "B", "the first option" are all wrong).
- Every quiz tests what earlier cards of this lesson taught.
- A concept body is at most 70 words. A table has 2 to 6 short rows. An example has 2 to 5 steps and ends with the answer.
- For maths and numerical topics include at least one example card with a fully worked problem.`

const styleRules = `Writing rules:
- Simple English that a Class %d student in India reads easily: short sentences, everyday words, one idea per card. Explain any technical term the first time you use it.
- Where a real-life example helps, take it from Indian everyday life (rupees, the kitchen, cricket, monsoon, trains, festivals, Indian cities and rivers). Keep examples accurate and natural; never force a metaphor. Use SI units.
- Sound like a friendly, precise teacher. Every sentence must be scientifically exact: no vague or made-up analogies, no filler, no exclamation marks.
- Plain text maths, never LaTeX, never $ signs or backslashes. Use × ÷ − ² ³ √ ≤ ≥ ≠ π ° and fractions like 3/4. Write chemical formulas with subscript digits (H₂O, CO₂, CaCO₃) and reactions with →.
- Facts, definitions, formulas and numbers must be correct and match the %s textbook for Class %d. Check every calculation and every quiz answer index before you reply.
- Write everything in your own words. Do not copy sentences, examples or exercise questions from the textbook.
- Teach only this lesson's topics. The other lessons of the chapter are listed so you do not repeat them.`

const exampleDeck = `An example of a good lesson (format and tone only, do not reuse it):
{"cards": [{"kind": "start", "goals": ["Say what reflection is", "Use the two laws of reflection", "Describe the image in a plane mirror"], "minutes": 6}, {"kind": "concept", "title": "Light travels in straight lines", "body": "Light moves in straight lines. That's why an object in its path casts a sharp shadow.\n\nWhen light hits a surface, some of it bounces back. This bouncing back is called **reflection**."}, {"kind": "table", "title": "The two laws of reflection", "rows": [{"term": "First law", "value": "Angle of incidence = angle of reflection"}, {"term": "Second law", "value": "The incident ray, the reflected ray and the normal all lie in the same plane"}, {"term": "Normal", "value": "The line at 90° to the mirror where the ray hits it"}], "remember": "Angles are always measured from the normal, not from the mirror."}, {"kind": "quiz", "question": "A ray strikes a plane mirror making an angle of 35° with the normal. What is the angle of reflection?", "options": ["55°", "35°", "70°", "90°"], "answer": 1, "why": "Angles are measured from the normal. The angle of incidence is 35°, and by the first law of reflection the angle of reflection equals it: 35°. 55° is the angle with the mirror's surface, not with the normal."}, {"kind": "concept", "title": "Lateral inversion", "body": "Raise your right hand in front of a mirror and your image raises its left. This left–right swap is **lateral inversion**.\n\nIt's why AMBULANCE is written in reverse on the front of ambulances: drivers ahead read it the right way round in their mirrors."}, {"kind": "quiz", "question": "You stand 2 m in front of a plane mirror. How far are you from your image?", "options": ["1 m", "2 m", "4 m", "0 m"], "answer": 2, "why": "The image is as far behind the mirror as you are in front of it, so it's 2 m behind. The distance between you and your image is 2 m + 2 m = 4 m."}, {"kind": "summary", "points": ["Reflection is light bouncing off a surface", "Angle of incidence = angle of reflection, measured from the normal", "A plane mirror's image is virtual, erect, the same size and laterally inverted"]}]}`

const reviewerSystem = `You are a strict senior examiner and subject expert for Indian school boards. You check swipe-card lessons written for students before they are published. You reply with one JSON object and nothing else.`

const reviewRules = `Check the lesson below card by card for:
1. Accuracy: every fact, definition, formula, unit, number and calculation is correct.
2. Quizzes: the option marked correct really is correct, it is the only correct option, and the "why" agrees with it.
3. Level: suitable for a Class %d %s student; nothing important is beyond the syllabus.
4. Syllabus fit: it teaches this lesson's topics and does not drift into the other lessons of the chapter.
5. Originality: no passage copied from the NCERT or board textbook.
6. Clarity: simple English, no LaTeX or $ signs, nothing confusing or misleading.

Reply {"ok": true, "issues": []} if the lesson can be published as it is. Reply {"ok": false, "issues": ["card 4: marked correct is 55°, but the angle of reflection is 35°", ...]} if anything must change. Each issue names the card number (1 = first card) and says exactly what is wrong and what it should be. Do not raise matters of taste or formatting; only real problems a teacher would fix.`

func lessonBrief(j Job) string {
	var b strings.Builder
	fmt.Fprintf(&b, "Board: %s. Class: %d. Subject: %s", j.Board, j.Class, j.Subject.Name)
	if j.Subject.Book != "" {
		fmt.Fprintf(&b, " (book: %s)", j.Subject.Book)
	}
	fmt.Fprintf(&b, ".\nChapter %d: %s", j.Chapter.Number, j.Chapter.Title)
	if j.Chapter.Unit != "" {
		fmt.Fprintf(&b, " (unit: %s)", j.Chapter.Unit)
	}
	b.WriteString(".\n")
	if len(j.Chapter.Outcomes) > 0 {
		fmt.Fprintf(&b, "Chapter learning outcomes: %s.\n", strings.Join(j.Chapter.Outcomes, "; "))
	}
	fmt.Fprintf(&b, "\nThis lesson is lesson %d of %d: %q.\nIts topics: %s.\n", j.Position, len(j.Chapter.Lessons), j.Lesson().Title, strings.Join(j.Lesson().Topics, "; "))
	for i, l := range j.Chapter.Lessons {
		if i+1 == j.Position {
			continue
		}
		when := "comes later"
		if i+1 < j.Position {
			when = "already taught"
		}
		fmt.Fprintf(&b, "Other lesson %d (%s, do not repeat): %q covering %s.\n", i+1, when, l.Title, strings.Join(l.Topics, "; "))
	}
	return b.String()
}

func authorPrompt(j Job) string {
	return fmt.Sprintf("Write the lesson described below.\n\n%s\n%s\n\n%s\n\n%s", lessonBrief(j), cardFormat, fmt.Sprintf(styleRules, j.Class, j.Board, j.Class), exampleDeck)
}

func revisePrompt(issues []string) string {
	return "A reviewer found these problems in your lesson:\n- " + strings.Join(issues, "\n- ") + "\n\nFix every problem and reply with the whole corrected lesson as one JSON object in the same format."
}

func invalidPrompt(err error) string {
	return fmt.Sprintf("That reply can't be used: %v. Reply again with the whole lesson as one JSON object that follows every card rule.", err)
}

func reviewPrompt(j Job, cards []study.Card) string {
	return fmt.Sprintf("%s\n%s\n\nThe lesson, card by card:\n\n%s", lessonBrief(j), fmt.Sprintf(reviewRules, j.Class, j.Board), readable(cards))
}

func readable(cards []study.Card) string {
	var b strings.Builder
	line := func(label, text string) {
		if text != "" {
			fmt.Fprintf(&b, "  %s: %s\n", label, text)
		}
	}
	for i, c := range cards {
		fmt.Fprintf(&b, "Card %d (%s)\n", i+1, c.Kind)
		line("Title", c.Title)
		line("Text", c.Body)
		line("Goals", strings.Join(c.Goals, "; "))
		for _, r := range c.Rows {
			line(r.Term, r.Value)
		}
		line("Question", c.Question)
		for k, s := range c.Steps {
			line(fmt.Sprintf("Step %d", k+1), s)
		}
		line("Options", strings.Join(c.Options, " | "))
		if c.Answer != nil && *c.Answer < len(c.Options) {
			line("Marked correct", c.Options[*c.Answer])
		}
		line("Why", c.Why)
		line("Points", strings.Join(c.Points, "; "))
		line("Remember", c.Remember)
		b.WriteString("\n")
	}
	return b.String()
}
