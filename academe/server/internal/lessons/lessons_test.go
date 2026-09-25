package lessons

import (
	"context"
	"errors"
	"log/slog"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"academe/server/internal/sarvam"
	"academe/server/internal/study"
	"academe/server/internal/syllabus"
)

const goodCards = `{"cards": [
{"kind": "start", "goals": ["Balance an equation"], "minutes": 5},
{"kind": "concept", "title": "Atoms are conserved", "body": "**Mass** is neither made nor lost, so each element has the same number of atoms on both sides."},
{"kind": "example", "question": "Balance H₂ + O₂ → H₂O", "steps": ["Oxygen: 2 on the left, 1 on the right, so write 2H₂O", "Hydrogen: now 4 on the right, so write 2H₂", "Answer: 2H₂ + O₂ → 2H₂O"]},
{"kind": "quiz", "question": "Why must equations be balanced?", "options": ["Atoms are conserved", "It looks neater", "Heat is released", "Gases expand"], "answer": 0, "why": "Atoms are neither created nor destroyed in a reaction."},
{"kind": "table", "title": "Steps", "rows": [{"term": "1", "value": "Count atoms"}, {"term": "2", "value": "Add coefficients"}]},
{"kind": "quiz", "question": "Balanced form of H₂ + Cl₂ → HCl?", "options": ["H₂ + Cl₂ → 2HCl", "H₂ + Cl₂ → HCl", "2H₂ + Cl₂ → 2HCl", "H₂ + 2Cl₂ → HCl"], "answer": 0, "why": "Two H and two Cl on each side."},
{"kind": "summary", "points": ["Atoms are conserved", "Balance with coefficients, never subscripts"]}
]}`

type fakeChat struct {
	mu       sync.Mutex
	authors  []string
	reviews  []string
	errs     []error
	messages [][]sarvam.Message
}

func (f *fakeChat) Chat(_ context.Context, messages []sarvam.Message, _ float64) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.messages = append(f.messages, messages)
	if len(f.errs) > 0 {
		err := f.errs[0]
		f.errs = f.errs[1:]
		if err != nil {
			return "", err
		}
	}
	queue := &f.authors
	if messages[0].Content == reviewerSystem {
		queue = &f.reviews
	}
	if len(*queue) == 0 {
		return "", errors.New("fake has no reply left")
	}
	reply := (*queue)[0]
	if len(*queue) > 1 {
		*queue = (*queue)[1:]
	}
	return reply, nil
}

func fixtureJobs(t *testing.T, f Filter) []Job {
	t.Helper()
	syllabi, err := syllabus.Read(os.DirFS("../syllabus/testdata"))
	if err != nil {
		t.Fatal(err)
	}
	return Jobs(syllabi, f)
}

func newGenerator(t *testing.T, chat Chatter) *Generator {
	t.Helper()
	return &Generator{Author: chat, Reviewer: chat, Model: "fake", Out: t.TempDir(), Timeout: time.Second, Backoff: time.Millisecond, Retries: 2, Logger: slog.New(slog.DiscardHandler)}
}

func readDeck(t *testing.T, g *Generator, j Job) study.Deck {
	t.Helper()
	decks, err := study.ReadDecks(os.DirFS(filepath.Dir(j.Path(g.Out))))
	if err != nil || len(decks) != 1 {
		t.Fatalf("ReadDecks(%s) = %d decks, %v; want one", j.Path(g.Out), len(decks), err)
	}
	return decks[0]
}

func TestExtractJSON(t *testing.T) {
	for _, tc := range []struct {
		name, reply, want string
	}{
		{"bare", `{"ok": true}`, `{"ok": true}`},
		{"fenced", "```json\n{\"ok\": true}\n```", `{"ok": true}`},
		{"prose around", "Here it is:\n{\"a\": {\"b\": 1}}\nHope that helps.", `{"a": {"b": 1}}`},
		{"thinking first", "<think>maybe {\"x\": 1}</think>{\"ok\": false}", `{"ok": false}`},
	} {
		t.Run(tc.name, func(t *testing.T) {
			got, err := extractJSON(tc.reply)
			if err != nil || string(got) != tc.want {
				t.Errorf("extractJSON(%q) = %s, %v; want %s", tc.reply, got, err, tc.want)
			}
		})
	}
	for _, reply := range []string{"no json here", "{broken", `{"a": }`} {
		if _, err := extractJSON(reply); !errors.Is(err, ErrNoJSON) {
			t.Errorf("extractJSON(%q) error = %v, want ErrNoJSON", reply, err)
		}
	}
}

func TestParseDeckRules(t *testing.T) {
	j := fixtureJobs(t, Filter{Subject: "science", Lesson: 2})[0]
	d, err := parseDeck(j, goodCards)
	if err != nil {
		t.Fatalf("parseDeck(good) error = %v", err)
	}
	if d.ID != "cbse-10-science-1-2" || d.Title != "Balancing equations" || d.ChapterTitle != "Chemical Reactions and Equations" || d.Cards[0].Minutes != d.Minutes() {
		t.Errorf("parseDeck(good) = %+v, want the syllabus identity and computed minutes", d)
	}
	q := d.Cards[3]
	if q.Options[*q.Answer] != "Atoms are conserved" {
		t.Errorf("after shuffling, answer %d points at %q, want the right option", *q.Answer, q.Options[*q.Answer])
	}
	for _, tc := range []struct{ name, from, to string }{
		{"latex", "2H₂ + O₂ → 2H₂O", `2H_2 + O_2 \\rightarrow 2H_2O`},
		{"latex eaten by JSON escapes", "Count atoms", `\\frac{1}{2} \times 3`},
		{"five options", `"Gases expand"]`, `"Gases expand", "Light"]`},
		{"why by position", "Two H and two Cl on each side.", "Option 0 is right."},
		{"why by letter", "Two H and two Cl on each side.", "So (B) is wrong and choice c too."},
		{"why by order", "Two H and two Cl on each side.", "The first option balances."},
		{"no summary last", `{"kind": "summary"`, `{"kind": "concept"`},
	} {
		if _, err := parseDeck(j, strings.Replace(goodCards, tc.from, tc.to, 1)); err == nil {
			t.Errorf("parseDeck(%s) = nil error, want a rule failure", tc.name)
		}
	}
	if _, err := parseDeck(j, strings.Replace(goodCards, "Two H and two Cl on each side.", "The option with HCl alone leaves options are unbalanced.", 1)); err != nil {
		t.Errorf("parseDeck(why naming options by words) error = %v, want none", err)
	}
	numbers := strings.Replace(strings.Replace(goodCards, `"Heat is released"`, `"4"`, 1), "Atoms are neither created nor destroyed in a reaction.", "The option 4 is a count, not a reason.", 1)
	if _, err := parseDeck(j, numbers); err != nil {
		t.Errorf("parseDeck(why naming a numeric option by its value) error = %v, want none", err)
	}
	powers := strings.Replace(goodCards, "Count atoms", "12 = 2^2 × 3 and 10^(-3)", 1)
	if d, err := parseDeck(j, powers); err != nil || d.Cards[4].Rows[0].Value != "12 = 2² × 3 and 10⁻³" {
		t.Errorf("parseDeck(caret powers) = %v, %v; want superscripts", d.Cards[4].Rows, err)
	}
	named := strings.Replace(strings.Replace(goodCards, `"answer": 0, "why": "Atoms`, `"answer": "Atoms are conserved", "why": "Atoms`, 1), `"answer": 0, "why": "Two`, `"answer": "0", "why": "Two`, 1)
	if d, err := parseDeck(j, named); err != nil || d.Cards[3].Options[*d.Cards[3].Answer] != "Atoms are conserved" || d.Cards[5].Options[*d.Cards[5].Answer] != "H₂ + Cl₂ → 2HCl" {
		t.Errorf("parseDeck(answers as text) = %v, want answers mapped to their options", err)
	}
	short := `{"cards": [{"kind": "start", "goals": ["a"], "minutes": 2}, {"kind": "concept", "title": "t", "body": "b"}, {"kind": "quiz", "question": "q", "options": ["x", "y"], "answer": 0, "why": "w"}, {"kind": "summary", "points": ["p"]}]}`
	if _, err := parseDeck(j, short); !errors.Is(err, ErrBadDeck) {
		t.Errorf("parseDeck(four cards) error = %v, want ErrBadDeck", err)
	}
}

func TestRetriesOnValidationError(t *testing.T) {
	chat := &fakeChat{authors: []string{"```json\n{\"cards\": []}\n```", goodCards}, reviews: []string{`{"ok": true, "issues": []}`}}
	g := newGenerator(t, chat)
	jobs := fixtureJobs(t, Filter{Subject: "science", Lesson: 2})
	sum, err := g.Run(t.Context(), jobs, 2)
	if err != nil || sum.Approved != 1 || sum.Failed != 0 {
		t.Fatalf("Run() = %+v, %v; want one approved", sum, err)
	}
	second := chat.messages[1]
	if last := second[len(second)-1].Content; !strings.Contains(last, "can't be used") || !strings.Contains(last, "start card") {
		t.Errorf("retry prompt = %q, want the validation error fed back", last)
	}
	d := readDeck(t, g, jobs[0])
	if d.Status != study.Approved || d.GeneratedBy == nil || d.GeneratedBy.PromptVersion != PromptVersion || d.GeneratedBy.Model != "fake" {
		t.Errorf("saved deck status %q by %+v, want approved by fake at %s", d.Status, d.GeneratedBy, PromptVersion)
	}
	if err := study.Validate(d); err != nil {
		t.Errorf("saved deck invalid: %v", err)
	}
}

func TestReviewerLoop(t *testing.T) {
	t.Run("fixed on the second round", func(t *testing.T) {
		chat := &fakeChat{authors: []string{goodCards}, reviews: []string{`{"ok": false, "issues": ["card 4: wrong answer"]}`, `{"ok": true, "issues": []}`}}
		g := newGenerator(t, chat)
		jobs := fixtureJobs(t, Filter{Subject: "science", Lesson: 2})
		if sum, err := g.Run(t.Context(), jobs, 1); err != nil || sum.Approved != 1 {
			t.Fatalf("Run() = %+v, %v; want approved after one revision", sum, err)
		}
		revise := chat.messages[2]
		if last := revise[len(revise)-1].Content; !strings.Contains(last, "card 4: wrong answer") || revise[len(revise)-2].Role != "assistant" {
			t.Errorf("revision prompt = %q, want the previous lesson and the reviewer's issues", last)
		}
		if _, err := os.Stat(strings.TrimSuffix(jobs[0].Path(g.Out), ".json") + study.ReviewSuffix); !errors.Is(err, os.ErrNotExist) {
			t.Errorf("approved lesson has a review file: %v", err)
		}
	})
	t.Run("still rejected becomes a draft", func(t *testing.T) {
		chat := &fakeChat{authors: []string{goodCards}, reviews: []string{`not json`, `{"ok": false, "issues": ["card 2: too hard"]}`}}
		g := newGenerator(t, chat)
		jobs := fixtureJobs(t, Filter{Subject: "science", Lesson: 2})
		if sum, err := g.Run(t.Context(), jobs, 1); err != nil || sum.Draft != 1 {
			t.Fatalf("Run() = %+v, %v; want a draft", sum, err)
		}
		if d := readDeck(t, g, jobs[0]); d.Approved() {
			t.Errorf("saved deck status = %q, want draft", d.Status)
		}
		raw, err := os.ReadFile(strings.TrimSuffix(jobs[0].Path(g.Out), ".json") + study.ReviewSuffix)
		if err != nil || !strings.Contains(string(raw), "card 2: too hard") {
			t.Errorf("review file = %s, %v; want the issues", raw, err)
		}
		authors := 0
		for _, m := range chat.messages {
			if m[0].Content == authorSystem {
				authors++
			}
		}
		if authors != revisions+1 {
			t.Errorf("author calls = %d, want %d", authors, revisions+1)
		}
	})
}

func TestResume(t *testing.T) {
	chat := &fakeChat{authors: []string{goodCards}, reviews: []string{`{"ok": true, "issues": []}`}}
	g := newGenerator(t, chat)
	jobs := fixtureJobs(t, Filter{Subject: "science"})
	if err := g.save(jobs[0], study.Deck{ID: jobs[0].ID(), Board: "CBSE", Class: 10}, study.Approved, nil); err != nil {
		t.Fatal(err)
	}
	if err := g.save(jobs[1], study.Deck{ID: jobs[1].ID(), Board: "CBSE", Class: 10}, study.Draft, &Review{Issues: []string{"x"}}); err != nil {
		t.Fatal(err)
	}
	if err := writeJSON(filepath.Join(g.Out, jobs[2].ID()+".json"), study.Deck{ID: jobs[2].ID(), Board: "CBSE", Class: 10}); err != nil {
		t.Fatal(err)
	}
	pending, skipped, err := g.Pending(jobs)
	if err != nil || skipped != 2 || len(pending) != 2 || pending[0].ID() != jobs[1].ID() {
		t.Fatalf("Pending() = %d pending, %d skipped, %v; want the draft and the unwritten lesson", len(pending), skipped, err)
	}
	g.Force = true
	if pending, _, _ := g.Pending(jobs); len(pending) != 3 {
		t.Errorf("Pending(force) = %d, want 3: every generated lesson but never the hand-written one", len(pending))
	}
}

func TestAskBacksOff(t *testing.T) {
	chat := &fakeChat{authors: []string{"hi"}, errs: []error{&sarvam.StatusError{Code: 429}, &sarvam.StatusError{Code: 503}, nil}}
	g := newGenerator(t, chat)
	if got, err := g.ask(t.Context(), chat, []sarvam.Message{{Role: "user", Content: "x"}}, 0); err != nil || got != "hi" {
		t.Errorf("ask() after 429 and 503 = %q, %v; want hi", got, err)
	}
	chat = &fakeChat{authors: []string{"hi"}, errs: []error{&sarvam.StatusError{Code: 400}}}
	g = newGenerator(t, chat)
	if _, err := g.ask(t.Context(), chat, []sarvam.Message{{Role: "user", Content: "x"}}, 0); err == nil || len(chat.messages) != 1 {
		t.Errorf("ask() on 400 = %v after %d calls, want an error without retrying", err, len(chat.messages))
	}
}

func TestWriteReport(t *testing.T) {
	chat := &fakeChat{authors: []string{goodCards}, reviews: []string{`{"ok": false, "issues": ["card 2: <too> hard"]}`}}
	g := newGenerator(t, chat)
	if _, err := g.Run(t.Context(), fixtureJobs(t, Filter{Subject: "science", Lesson: 2}), 1); err != nil {
		t.Fatal(err)
	}
	path := filepath.Join(t.TempDir(), "review", "index.html")
	n, err := WriteReport(g.Out, path)
	if err != nil || n != 1 {
		t.Fatalf("WriteReport() = %d, %v; want one deck", n, err)
	}
	raw, err := os.ReadFile(path) //nolint:gosec
	if err != nil {
		t.Fatal(err)
	}
	for _, want := range []string{"Balancing equations", "draft", "card 2: &lt;too&gt; hard", "✓ Atoms are conserved", "<strong>"} {
		if !strings.Contains(string(raw), want) {
			t.Errorf("report is missing %q", want)
		}
	}
}

func TestReadableSurvivesBadAnswers(t *testing.T) {
	bad := -1
	got := readable([]study.Card{{Kind: study.Concept, Title: "t", Answer: &bad}, {Kind: study.Quiz, Question: "q", Options: []string{"a", "b"}, Answer: new(1)}})
	if !strings.Contains(got, "Marked correct: b") || strings.Count(got, "Marked correct") != 1 {
		t.Errorf("readable() = %q, want only the quiz's marked answer", got)
	}
}

func TestHindiSubjectsAreWrittenInHindi(t *testing.T) {
	j := fixtureJobs(t, Filter{Subject: "science", Lesson: 1})[0]
	if j.Language() != "en" || strings.Contains(authorPrompt(j), "Devanagari") {
		t.Errorf("science lesson language = %q, want English with no Hindi instruction", j.Language())
	}
	j.Subject = syllabus.Subject{Subject: "sanskrit", Name: "Sanskrit"}
	if j.Language() != "hi" || !strings.Contains(authorPrompt(j), "Devanagari") || !strings.Contains(reviewPrompt(j, nil), "Devanagari") {
		t.Errorf("sanskrit lesson language = %q, want hi with the Hindi-medium instruction for writer and reviewer", j.Language())
	}
}
