package study

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"slices"
	"strings"
	"sync"
	"testing"
	"testing/fstest"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
	"academe/server/internal/profile"
)

func TestLibraryIsValid(t *testing.T) {
	decks, err := Library()
	if err != nil {
		t.Fatalf("Library() error = %v", err)
	}
	if len(decks) == 0 {
		t.Fatal("Library() = no decks, want at least one")
	}
	seen := map[string]bool{}
	for _, d := range decks {
		if seen[d.ID] {
			t.Errorf("deck %s appears twice", d.ID)
		}
		seen[d.ID] = true
		subjects, ok := profile.Subjects(d.Class, d.Board)
		if !ok || !slices.ContainsFunc(subjects, func(s profile.Subject) bool { return s.ID == d.Subject }) {
			t.Errorf("deck %s: subject %q is not taught in %s class %d", d.ID, d.Subject, d.Board, d.Class)
		}
		if d.Title == "" || d.ChapterTitle == "" || d.ChapterNumber < 1 || d.Position < 1 || d.Language == "" {
			t.Errorf("deck %s is missing its title, chapter, position or language", d.ID)
		}
		if err := Validate(d); err != nil {
			t.Errorf("deck %s: %v", d.ID, err)
		}
	}
}

type fakeStore struct {
	mu        sync.Mutex
	reasons   map[string]bool
	done      map[string]Completion
	positions map[string]int
	kept      map[string][]Kept
	results   map[string]ChapterResult
	user      map[string]Deck
}

func newFakeStore() *fakeStore {
	return &fakeStore{reasons: map[string]bool{}, done: map[string]Completion{}, positions: map[string]int{}, kept: map[string][]Kept{}, results: map[string]ChapterResult{}, user: map[string]Deck{}}
}

func (f *fakeStore) AwardXP(_ context.Context, accountID string, _ int, reason string) (bool, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	key := accountID + "|" + reason
	if f.reasons[key] {
		return false, nil
	}
	f.reasons[key] = true
	return true, nil
}

func (f *fakeStore) Complete(_ context.Context, accountID, deckID string, correct int) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	key := accountID + "|" + deckID
	f.done[key] = Completion{Correct: max(f.done[key].Correct, correct), At: time.Now()}
	return nil
}

func (f *fakeStore) Completions(_ context.Context, accountID string) (map[string]Completion, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := map[string]Completion{}
	for k, v := range f.done {
		if id, ok := strings.CutPrefix(k, accountID+"|"); ok {
			out[id] = v
		}
	}
	return out, nil
}

func (f *fakeStore) SavePosition(_ context.Context, accountID, deckID string, card int) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.positions[accountID+"|"+deckID] = card
	return nil
}

func (f *fakeStore) Positions(_ context.Context, accountID string) (map[string]int, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := map[string]int{}
	for k, v := range f.positions {
		if id, ok := strings.CutPrefix(k, accountID+"|"); ok {
			out[id] = v
		}
	}
	return out, nil
}

func (f *fakeStore) Keep(_ context.Context, k Kept, accountID string, reset bool) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for i, old := range f.kept[accountID] {
		if old.DeckID == k.DeckID && old.Card == k.Card {
			if reset {
				f.kept[accountID][i].DueAt = k.DueAt
				f.kept[accountID][i].Interval = 0
			}
			return nil
		}
	}
	f.kept[accountID] = append(f.kept[accountID], k)
	return nil
}

func (f *fakeStore) Unkeep(_ context.Context, accountID, deckID string, card int) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.kept[accountID] = slices.DeleteFunc(f.kept[accountID], func(k Kept) bool { return k.DeckID == deckID && k.Card == card })
	return nil
}

func (f *fakeStore) KeptCards(_ context.Context, accountID string) ([]Kept, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return slices.Clone(f.kept[accountID]), nil
}

func (f *fakeStore) Reschedule(_ context.Context, accountID, deckID string, card int, due time.Time, interval int) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for i, k := range f.kept[accountID] {
		if k.DeckID == deckID && k.Card == card {
			f.kept[accountID][i].DueAt = due
			f.kept[accountID][i].Interval = interval
			return nil
		}
	}
	return ErrNotKept
}

func (f *fakeStore) SaveChapterResult(_ context.Context, accountID, chapterID string, correct, total int) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.results[accountID+"|"+chapterID] = ChapterResult{ChapterID: chapterID, Correct: correct, Total: total, CompletedAt: time.Now()}
	return nil
}

func (f *fakeStore) ChapterResults(_ context.Context, accountID string) (map[string]ChapterResult, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := map[string]ChapterResult{}
	for k, v := range f.results {
		if id, ok := strings.CutPrefix(k, accountID+"|"); ok {
			out[id] = v
		}
	}
	return out, nil
}

func (f *fakeStore) SaveUserDeck(_ context.Context, _ string, d Deck) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.user[d.ID] = d
	return nil
}

func (f *fakeStore) UserDeck(_ context.Context, id string) (Deck, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	d, ok := f.user[id]
	if !ok {
		return Deck{}, ErrNotFound
	}
	return d, nil
}

type fakeProfiles map[string]profile.Profile

func (f fakeProfiles) Profile(_ context.Context, accountID string) (profile.Profile, error) {
	return f[accountID], nil
}

func one(n int) *int { return &n }

var testDecks = []Deck{{
	ID: "d1", Board: "CBSE", Class: 10, Subject: "science", ChapterNumber: 9, ChapterTitle: "Light", Position: 1, Title: "Reflection", Language: "en",
	Cards: []Card{
		{Kind: Concept, Title: "Light", Body: "Light travels straight."},
		{Kind: Quiz, Question: "i = r?", Options: []string{"Yes", "No"}, Answer: one(0), Why: "First law."},
	},
}, {
	ID: "d2", Board: "ICSE", Class: 9, Subject: "physics", ChapterNumber: 1, ChapterTitle: "Motion", Position: 1, Title: "Speed", Language: "en",
	Cards: []Card{{Kind: Quiz, Question: "?", Options: []string{"a", "b"}, Answer: one(1), Why: "b."}},
}}

var testPlan = []PlannedChapter{
	{Board: "CBSE", Class: 10, Subject: "science", Number: 9, Title: "Light – Reflection and Refraction", Unit: "Natural Phenomena", Lessons: []string{"Reflection of light", "Spherical mirrors"}},
	{Board: "CBSE", Class: 10, Subject: "maths", Number: 1, Title: "Real Numbers", Unit: "Number Systems", Lessons: []string{"Prime factors"}, FormativeOnly: true},
	{Board: "ICSE", Class: 10, Subject: "physics", Number: 1, Title: "Force", Lessons: []string{"Turning effect"}},
}

func guard(next httpx.HandlerFunc) httpx.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) error {
		token, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
		if !ok {
			return &httpx.Error{Status: http.StatusUnauthorized, Code: "invalid_token", Message: "Log in again."}
		}
		return next(w, r.WithContext(auth.WithAccountID(r.Context(), token)))
	}
}

func TestRoutes(t *testing.T) {
	class, board := 10, "CBSE"
	profiles := fakeProfiles{"riya": {Class: &class, Board: &board}, "new": {}}
	mux := http.NewServeMux()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), NewService(newFakeStore(), profiles, testDecks, testPlan), guard)
	srv := httptest.NewServer(httpx.WithRequestID(mux))
	t.Cleanup(srv.Close)

	call := func(method, path, token, body string) (int, map[string]any) {
		t.Helper()
		req, err := http.NewRequestWithContext(t.Context(), method, srv.URL+path, strings.NewReader(body))
		if err != nil {
			t.Fatal(err)
		}
		if token != "" {
			req.Header.Set("Authorization", "Bearer "+token)
		}
		res, err := srv.Client().Do(req)
		if err != nil {
			t.Fatal(err)
		}
		raw, err := io.ReadAll(res.Body)
		if closeErr := res.Body.Close(); err == nil {
			err = closeErr
		}
		if err != nil {
			t.Fatal(err)
		}
		var got map[string]any
		if len(raw) > 0 {
			if err := json.Unmarshal(raw, &got); err != nil {
				t.Fatalf("%s %s body %q: %v", method, path, raw, err)
			}
		}
		return res.StatusCode, got
	}

	if status, _ := call("GET", "/study/decks", "", ""); status != http.StatusUnauthorized {
		t.Errorf("GET /study/decks without a token = %d, want 401", status)
	}
	status, got := call("GET", "/study/decks", "riya", "")
	if status != http.StatusOK || len(got["decks"].([]any)) != 1 {
		t.Fatalf("GET /study/decks = %d %v, want only the Class 10 CBSE deck", status, got)
	}
	if name := got["decks"].([]any)[0].(map[string]any)["subjectName"]; name != "Science" {
		t.Errorf("subjectName = %v, want Science", name)
	}
	chapters := got["chapters"].([]any)
	if len(chapters) != 2 {
		t.Fatalf("GET /study/decks chapters = %v, want maths 1 and science 10 for Class 10 CBSE", chapters)
	}
	maths, science := chapters[0].(map[string]any), chapters[1].(map[string]any)
	if maths["id"] != "cbse-10-maths-1" || maths["subjectName"] != "Maths" || maths["unit"] != "Number Systems" {
		t.Errorf("first chapter = %v, want cbse-10-maths-1 Maths in Number Systems", maths)
	}
	if maths["formativeOnly"] != true || science["formativeOnly"] != nil {
		t.Errorf("formativeOnly = %v and %v, want true on maths and absent on science", maths["formativeOnly"], science["formativeOnly"])
	}
	if lessons := maths["lessons"].([]any); len(lessons) != 1 || lessons[0].(map[string]any)["available"] != false || lessons[0].(map[string]any)["id"] != "cbse-10-maths-1-1" {
		t.Errorf("maths lessons = %v, want one unwritten lesson cbse-10-maths-1-1", lessons)
	}
	lessons := science["lessons"].([]any)
	if science["title"] != "Light – Reflection and Refraction" || len(lessons) != 2 {
		t.Fatalf("science chapter = %v, want the planned title and two lessons", science)
	}
	if first, second := lessons[0].(map[string]any), lessons[1].(map[string]any); first["id"] != "d1" || first["available"] != true || first["title"] != "Reflection" || second["available"] != false || second["id"] != "cbse-10-science-9-2" {
		t.Errorf("science lessons = %v, want d1 available then an unwritten cbse-10-science-9-2", lessons)
	}
	gzipped, err := http.NewRequestWithContext(t.Context(), "GET", srv.URL+"/study/decks", nil)
	if err != nil {
		t.Fatal(err)
	}
	gzipped.Header.Set("Authorization", "Bearer riya")
	if res, err := srv.Client().Do(gzipped); err != nil || !res.Uncompressed || res.Body.Close() != nil {
		t.Errorf("GET /study/decks with gzip accepted = %v; want a compressed reply the client unpacks", err)
	}
	if status, got := call("GET", "/study/decks", "new", ""); status != http.StatusOK || len(got["decks"].([]any)) != 0 || len(got["chapters"].([]any)) != 0 {
		t.Errorf("GET /study/decks before setup = %d %v, want an empty list", status, got)
	}
	if status, got := call("GET", "/study/decks?subject=maths", "riya", ""); status != http.StatusOK || len(got["decks"].([]any)) != 0 || len(got["chapters"].([]any)) != 1 {
		t.Errorf("GET /study/decks?subject=maths = %d %v, want none", status, got)
	}
	if status, got := call("GET", "/study/decks/d1", "riya", ""); status != http.StatusOK || len(got["cards"].([]any)) != 2 {
		t.Errorf("GET /study/decks/d1 = %d %v, want two cards", status, got)
	}
	if status, _ := call("GET", "/study/decks/nope", "riya", ""); status != http.StatusNotFound {
		t.Errorf("GET unknown deck = %d, want 404", status)
	}
	if status, got := call("POST", "/study/decks/d1/answers", "riya", `{"card":1,"choice":1}`); status != http.StatusOK || got["correct"] != false || got["answer"] != 0.0 || got["xpAwarded"] != 0.0 {
		t.Errorf("wrong answer = %d %v, want correct false, answer 0, no XP", status, got)
	}
	if status, got := call("POST", "/study/decks/d1/answers", "riya", `{"card":1,"choice":0}`); status != http.StatusOK || got["correct"] != true || got["xpAwarded"] != float64(QuizXP) {
		t.Errorf("right answer = %d %v, want %d XP", status, got, QuizXP)
	}
	if status, got := call("POST", "/study/decks/d1/answers", "riya", `{"card":1,"choice":0}`); status != http.StatusOK || got["xpAwarded"] != 0.0 {
		t.Errorf("same right answer again = %d %v, want no more XP", status, got)
	}
	if status, got := call("POST", "/study/decks/d1/answers", "riya", `{"card":0,"choice":0}`); status != http.StatusUnprocessableEntity || got["error"].(map[string]any)["code"] != "invalid_card" {
		t.Errorf("answering a concept card = %d %v, want 422 invalid_card", status, got)
	}
	if status, _ := call("POST", "/study/decks/d1/answers", "riya", `{"card":1,"choice":5}`); status != http.StatusUnprocessableEntity {
		t.Errorf("choice out of range = %d, want 422", status)
	}
	if status, _ := call("PUT", "/study/decks/d1/completion", "riya", `{"correct":2}`); status != http.StatusUnprocessableEntity {
		t.Errorf("more correct than quizzes = %d, want 422", status)
	}
	if status, _ := call("PUT", "/study/decks/d1/completion", "riya", `{"correct":1}`); status != http.StatusNoContent {
		t.Errorf("PUT completion = %d, want 204", status)
	}
	_, got = call("GET", "/study/decks", "riya", "")
	if d := got["decks"].([]any)[0].(map[string]any); d["done"] != true || d["correct"] != 1.0 || d["chapterId"] != "cbse-10-science-9" {
		t.Errorf("deck after completion = %v, want done with 1 correct in chapter cbse-10-science-9", d)
	}

	if status, _ := call("PUT", "/study/decks/d1/position", "riya", `{"card":1}`); status != http.StatusNoContent {
		t.Errorf("PUT position = %d, want 204", status)
	}
	if status, _ := call("PUT", "/study/decks/d1/position", "riya", `{"card":9}`); status != http.StatusUnprocessableEntity {
		t.Errorf("PUT position past the end = %d, want 422", status)
	}
	if status, _ := call("PUT", "/study/kept", "riya", `{"deckId":"d1","card":0}`); status != http.StatusNoContent {
		t.Errorf("PUT kept = %d, want 204", status)
	}
	_, got = call("GET", "/study/decks/d1", "riya", "")
	if kept := got["kept"].([]any); got["resumeCard"] != 1.0 || len(kept) != 2 {
		t.Errorf("GET deck = resume %v kept %v, want resume 1 and two kept cards (the missed quiz and card 0)", got["resumeCard"], kept)
	}
	if status, got := call("GET", "/study/review?chapter=cbse-10-science-9", "riya", ""); status != http.StatusOK || len(got["items"].([]any)) != 2 {
		t.Errorf("GET chapter review = %d %v, want two items", status, got)
	}
	if status, got := call("GET", "/study/review", "riya", ""); status != http.StatusOK || len(got["items"].([]any)) != 0 {
		t.Errorf("GET due review today = %d %v, want nothing due until tomorrow", status, got)
	}
	if status, _ := call("POST", "/study/review", "riya", `{"deckId":"d1","card":0,"rating":"knew"}`); status != http.StatusNoContent {
		t.Errorf("POST review = %d, want 204", status)
	}
	if status, _ := call("POST", "/study/review", "riya", `{"deckId":"d1","card":0,"rating":"maybe"}`); status != http.StatusUnprocessableEntity {
		t.Errorf("POST review with a bad rating = %d, want 422", status)
	}
	if status, _ := call("DELETE", "/study/kept/d1/0", "riya", ""); status != http.StatusNoContent {
		t.Errorf("DELETE kept = %d, want 204", status)
	}
	if status, _ := call("POST", "/study/review", "riya", `{"deckId":"d1","card":0,"rating":"knew"}`); status != http.StatusNotFound {
		t.Errorf("POST review of an unkept card = %d, want 404", status)
	}
	if status, _ := call("PUT", "/study/chapter-results/cbse-10-science-9", "riya", `{"correct":1,"total":1}`); status != http.StatusNoContent {
		t.Errorf("PUT chapter result = %d, want 204", status)
	}
	if status, _ := call("PUT", "/study/chapter-results/cbse-10-science-9", "riya", `{"correct":2,"total":5}`); status != http.StatusUnprocessableEntity {
		t.Errorf("PUT chapter result over the quiz count = %d, want 422", status)
	}
	if status, _ := call("PUT", "/study/chapter-results/nope", "riya", `{"correct":1,"total":1}`); status != http.StatusNotFound {
		t.Errorf("PUT unknown chapter = %d, want 404", status)
	}
	if status, got := call("GET", "/study/chapter-results", "riya", ""); status != http.StatusOK || len(got["results"].([]any)) != 1 {
		t.Errorf("GET chapter results = %d %v, want one", status, got)
	}
}

func TestNextInterval(t *testing.T) {
	for _, tc := range []struct {
		current int
		rating  string
		want    int
	}{
		{0, "again", 1}, {10, "again", 1}, {0, "almost", 2}, {4, "almost", 6}, {0, "knew", 4}, {4, "knew", 10},
	} {
		if got, err := NextInterval(tc.current, tc.rating); err != nil || got != tc.want {
			t.Errorf("NextInterval(%d, %q) = %d, %v; want %d", tc.current, tc.rating, got, err, tc.want)
		}
	}
	if _, err := NextInterval(1, "later"); !errors.Is(err, ErrBadRating) {
		t.Errorf("NextInterval(1, later) error = %v, want ErrBadRating", err)
	}
}

func validLesson() Deck {
	return Deck{
		Title: "From your notes", Language: "en",
		Cards: []Card{
			{Kind: Start, Goals: []string{"Know i = r"}, Minutes: 3},
			{Kind: Concept, Title: "Reflection", Body: "Light bounces."},
			{Kind: Quiz, Question: "i = r?", Options: []string{"Yes", "No"}, Answer: one(0), Why: "First law."},
			{Kind: Summary, Points: []string{"i = r"}},
		},
	}
}

func TestCreateLesson(t *testing.T) {
	store := newFakeStore()
	s := NewService(store, fakeProfiles{}, testDecks, nil)
	bad := validLesson()
	bad.Cards = bad.Cards[1:]
	if _, err := s.CreateLesson(t.Context(), "riya", bad); !errors.Is(err, ErrBadLesson) {
		t.Errorf("CreateLesson(no start card) error = %v, want ErrBadLesson", err)
	}
	d, err := s.CreateLesson(t.Context(), "riya", validLesson())
	if err != nil || !strings.HasPrefix(d.ID, UserDeckPrefix) {
		t.Fatalf("CreateLesson() = %v, %v", d.ID, err)
	}
	view, err := s.DeckFor(t.Context(), "riya", d.ID)
	if err != nil || len(view.Cards) != 4 {
		t.Fatalf("DeckFor(user lesson) = %v, %v", view, err)
	}
	if r, err := s.Answer(t.Context(), "riya", d.ID, 2, 0); err != nil || !r.Correct {
		t.Errorf("Answer(user lesson) = %v, %v", r, err)
	}
	if ref, ok := s.Lesson(t.Context(), d.ID); !ok || ref.Title != "From your notes" {
		t.Errorf("Lesson() = %v, %v", ref, ok)
	}
}

func TestReadDecksWalksFoldersAndSkipsReviews(t *testing.T) {
	fsys := fstest.MapFS{
		"decks/cbse-10-maths-3-1.json":                  {Data: []byte(`{"id":"seed","class":10}`)},
		"decks/cbse-10/cbse-10-science-1-1.json":        {Data: []byte(`{"id":"approved","class":10,"status":"approved","generatedBy":{"model":"sarvam-105b","promptVersion":"lessons-v2","checkedAt":"2026-09-25T10:00:00Z"}}`)},
		"decks/cbse-10/cbse-10-science-1-2.json":        {Data: []byte(`{"id":"draft","class":10,"status":"draft"}`)},
		"decks/cbse-10/cbse-10-science-1-2.review.json": {Data: []byte(`{"issues":["x"]}`)},
		"decks/cbse-10/.tmp-123":                        {Data: []byte(`{`)},
	}
	decks, err := ReadDecks(fsys)
	if err != nil {
		t.Fatalf("ReadDecks() error = %v", err)
	}
	var approved []string
	for _, d := range decks {
		if d.Approved() {
			approved = append(approved, d.ID)
		}
	}
	slices.Sort(approved)
	if len(decks) != 3 || !slices.Equal(approved, []string{"approved", "seed"}) {
		t.Errorf("ReadDecks() = %d decks, approved %v; want 3 decks with the seed and the approved one approved", len(decks), approved)
	}
}

func TestReadDecksSkipsABrokenFile(t *testing.T) {
	fsys := fstest.MapFS{
		"decks/cbse-10-maths-3-3.json":           {Data: []byte(`{"id":"seed","class":10}`)},
		"decks/cbse-10/cbse-10-science-1-1.json": {Data: []byte(`{"id":"half`)},
	}
	decks, err := ReadDecks(fsys)
	if err == nil || !strings.Contains(err.Error(), "cbse-10-science-1-1.json") || len(decks) != 1 || decks[0].ID != "seed" {
		t.Errorf("ReadDecks(one broken file) = %v, %v; want the good deck and an error naming the broken file", decks, err)
	}
}
