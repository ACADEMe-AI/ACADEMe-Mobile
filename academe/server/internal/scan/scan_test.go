package scan

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/folder"
	"academe/server/internal/httpx"
	"academe/server/internal/profile"
	"academe/server/internal/sarvam"
	"academe/server/internal/study"
)

type fakeStore struct {
	mu     sync.Mutex
	next   int
	scans  map[string]Scan
	owners map[string]string
}

func newFakeStore() *fakeStore {
	return &fakeStore{scans: map[string]Scan{}, owners: map[string]string{}}
}

func (f *fakeStore) Create(_ context.Context, accountID string, s Scan) (Scan, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.next++
	s.ID, s.CreatedAt = fmt.Sprintf("s%d", f.next), time.Now()
	f.scans[s.ID], f.owners[s.ID] = s, accountID
	return s, nil
}

func (f *fakeStore) Scans(_ context.Context, accountID string, _ int) ([]Scan, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := []Scan{}
	for id, s := range f.scans {
		if f.owners[id] == accountID {
			out = append(out, s)
		}
	}
	return out, nil
}

func (f *fakeStore) Scan(_ context.Context, accountID, id string) (Scan, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	s, ok := f.scans[id]
	if !ok || f.owners[id] != accountID {
		return Scan{}, ErrNotFound
	}
	return s, nil
}

func (f *fakeStore) change(accountID, id string, apply func(*Scan)) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	s, ok := f.scans[id]
	if !ok || f.owners[id] != accountID {
		return ErrNotFound
	}
	apply(&s)
	f.scans[id] = s
	return nil
}

func (f *fakeStore) SetThread(_ context.Context, accountID, id, threadID string) error {
	return f.change(accountID, id, func(s *Scan) { s.ThreadID = &threadID })
}

func (f *fakeStore) SetResult(_ context.Context, accountID, id string, m Marking) error {
	return f.change(accountID, id, func(s *Scan) { s.Result = &m })
}

func (f *fakeStore) SetFolder(_ context.Context, accountID, id, folderID string, deckID *string) error {
	return f.change(accountID, id, func(s *Scan) { s.FolderID, s.DeckID = &folderID, deckID })
}

type fakeReader struct {
	text     string
	language string
	pages    int
}

func (f *fakeReader) Digitise(_ context.Context, pages []sarvam.Page, language string) (string, error) {
	f.language, f.pages = language, len(pages)
	return f.text, nil
}

type fakeModel struct {
	mu      sync.Mutex
	replies []string
}

func (f *fakeModel) Chat(_ context.Context, messages []sarvam.Message, _ float64) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if strings.HasPrefix(messages[0].Content, "You label") {
		return "Science · Ch 10 · Light", nil
	}
	if len(f.replies) == 0 {
		return "", errors.New("no reply")
	}
	r := f.replies[0]
	f.replies = f.replies[1:]
	return r, nil
}

type fakeProfiles struct{}

func (fakeProfiles) Profile(context.Context, string) (profile.Profile, error) {
	class, board, language := 9, "ICSE", "hi"
	return profile.Profile{Class: &class, Board: &board, Language: &language}, nil
}

type fakeLessons struct{ made []study.Deck }

func (f *fakeLessons) CreateLesson(_ context.Context, _ string, d study.Deck) (study.Deck, error) {
	if err := study.Validate(d); err != nil {
		return study.Deck{}, err
	}
	d.ID = study.UserDeckPrefix + "x"
	f.made = append(f.made, d)
	return d, nil
}

type fakeFolders struct {
	notes   []string
	lessons []string
}

func (f *fakeFolders) AddNote(_ context.Context, _, id, text string) error {
	if id != "f1" {
		return folder.ErrNotFound
	}
	f.notes = append(f.notes, text)
	return nil
}

func (f *fakeFolders) AddLesson(_ context.Context, _, _, deckID string) error {
	f.lessons = append(f.lessons, deckID)
	return nil
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

const marking = `Here you go: {"question": "Define refraction.", "marks": 3, "awarded": 2,
"points": [{"text": "Bending of light", "marks": 1, "awarded": 1}, {"text": "At the boundary of two media", "marks": 1, "awarded": 1}, {"text": "Due to change in speed", "marks": 1, "awarded": 0}],
"fullMarks": "Say that the speed of light changes.", "modelAnswer": "Refraction is the bending of light…"}`

const lesson = `{"title": "Light notes", "cards": [
{"kind": "start", "goals": ["Say what refraction is"], "minutes": 4},
{"kind": "concept", "title": "Refraction", "body": "Light **bends** between media."},
{"kind": "quiz", "question": "Light bends because its…", "options": ["speed changes", "colour changes"], "answer": 0, "why": "Speed changes at the boundary."},
{"kind": "summary", "points": ["Light bends when its speed changes"]}]}`

func form(t *testing.T, mode string, files ...string) (string, *bytes.Buffer) {
	t.Helper()
	var body bytes.Buffer
	mw := multipart.NewWriter(&body)
	if err := mw.WriteField("mode", mode); err != nil {
		t.Fatal(err)
	}
	for _, name := range files {
		part, err := mw.CreateFormFile("page", name)
		if err != nil {
			t.Fatal(err)
		}
		if _, err := part.Write([]byte("image")); err != nil {
			t.Fatal(err)
		}
	}
	if err := mw.Close(); err != nil {
		t.Fatal(err)
	}
	return mw.FormDataContentType(), &body
}

func TestRoutes(t *testing.T) {
	store := newFakeStore()
	reader := &fakeReader{text: "# Refraction of light\nLight bends when it enters glass."}
	model := &fakeModel{replies: []string{"not json", marking, lesson}}
	lessons, folders := &fakeLessons{}, &fakeFolders{}
	mux := http.NewServeMux()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), NewService(store, reader, model, fakeProfiles{}, lessons, folders), guard)
	srv := httptest.NewServer(httpx.WithRequestID(mux))
	t.Cleanup(srv.Close)

	send := func(method, path, token, contentType string, body io.Reader) (int, map[string]any) {
		t.Helper()
		req, err := http.NewRequestWithContext(t.Context(), method, srv.URL+path, body)
		if err != nil {
			t.Fatal(err)
		}
		req.Header.Set("Authorization", "Bearer "+token)
		req.Header.Set("Content-Type", contentType)
		res, err := srv.Client().Do(req)
		if err != nil {
			t.Fatal(err)
		}
		var out map[string]any
		_ = json.NewDecoder(res.Body).Decode(&out)
		if err := res.Body.Close(); err != nil {
			t.Fatal(err)
		}
		return res.StatusCode, out
	}
	call := func(method, path, token, body string) (int, map[string]any) {
		t.Helper()
		return send(method, path, token, "application/json", strings.NewReader(body))
	}
	upload := func(mode string, files ...string) (int, map[string]any) {
		t.Helper()
		ct, body := form(t, mode, files...)
		return send("POST", "/scans", "riya", ct, body)
	}
	code := func(out map[string]any) any {
		e, _ := out["error"].(map[string]any)
		return e["code"]
	}

	if status, out := upload("draw", "a.jpg"); status != 422 || code(out) != "invalid_mode" {
		t.Errorf("POST /scans bad mode = %d %v, want 422 invalid_mode", status, out)
	}
	if status, out := upload("solve"); status != 422 || code(out) != "invalid_pages" {
		t.Errorf("POST /scans no pages = %d %v, want 422 invalid_pages", status, out)
	}
	if status, out := upload("solve", "a.gif"); status != 422 || code(out) != "invalid_pages" {
		t.Errorf("POST /scans gif = %d %v, want 422 invalid_pages", status, out)
	}
	eleven := make([]string, 11)
	for i := range eleven {
		eleven[i] = "p.jpg"
	}
	if status, _ := upload("notes", eleven...); status != 422 {
		t.Errorf("POST /scans 11 pages = %d, want 422", status)
	}

	status, check := upload("check", "a.JPEG")
	if status != 201 || check["title"] != "Refraction of light" || check["chapter"] != "Science · Ch 10 · Light" || check["mode"] != "check" {
		t.Fatalf("POST /scans = %d %v", status, check)
	}
	if reader.language != "hi-IN" || reader.pages != 1 {
		t.Errorf("Digitise got language %q and %d pages, want hi-IN and 1", reader.language, reader.pages)
	}
	id := check["id"].(string)
	if status, out := call("POST", "/scans/"+id+"/check", "arjun", `{}`); status != 404 || code(out) != "scan_not_found" {
		t.Errorf("check another student's scan = %d %v, want 404", status, out)
	}
	status, m := call("POST", "/scans/"+id+"/check", "riya", `{"question": "Define refraction."}`)
	if status != 200 || m["awarded"] != 2.0 || m["marks"] != 3.0 || len(m["points"].([]any)) != 3 {
		t.Fatalf("POST /scans/{id}/check = %d %v", status, m)
	}
	if _, out := call("GET", "/scans/"+id, "riya", ""); out["result"] == nil {
		t.Errorf("GET /scans/{id} result = nil, want the marking")
	}
	if status, out := call("PUT", "/scans/"+id+"/thread", "riya", `{"threadId": "7c9e6679-7425-40de-944b-e07fc1f90ae7"}`); status != 422 || code(out) != "wrong_mode" {
		t.Errorf("thread on a check scan = %d %v, want 422 wrong_mode", status, out)
	}

	_, solve := upload("solve", "a.png")
	solveID := solve["id"].(string)
	if status, out := call("PUT", "/scans/"+solveID+"/thread", "riya", `{"threadId": "nope"}`); status != 422 || code(out) != "invalid_thread" {
		t.Errorf("bad thread id = %d %v, want 422 invalid_thread", status, out)
	}
	if status, _ := call("PUT", "/scans/"+solveID+"/thread", "riya", `{"threadId": "7c9e6679-7425-40de-944b-e07fc1f90ae7"}`); status != 204 {
		t.Errorf("PUT /scans/{id}/thread = %d, want 204", status)
	}

	_, notes := upload("notes", "a.jpg", "b.jpg")
	notesID := notes["id"].(string)
	if status, out := call("POST", "/scans/"+notesID+"/notes", "riya", `{"folderId": "f9"}`); status != 404 || code(out) != "folder_not_found" {
		t.Errorf("notes to a missing folder = %d %v, want 404 folder_not_found", status, out)
	}
	status, saved := call("POST", "/scans/"+notesID+"/notes", "riya", `{"folderId": "f1", "makeLesson": true}`)
	if status != 200 || saved["deckId"] != "u-x" {
		t.Fatalf("POST /scans/{id}/notes = %d %v", status, saved)
	}
	if len(folders.notes) != 1 || len(folders.lessons) != 1 || lessons.made[0].Board != "ICSE" || lessons.made[0].Class != 9 {
		t.Errorf("notes %v, lessons %v, decks %+v", folders.notes, folders.lessons, lessons.made)
	}
	if status, out := call("GET", "/scans", "riya", ""); status != 200 || len(out["scans"].([]any)) != 3 {
		t.Errorf("GET /scans = %d %v, want 3 scans", status, out)
	}
}

func TestUnavailable(t *testing.T) {
	s := NewService(newFakeStore(), nil, nil, fakeProfiles{}, &fakeLessons{}, &fakeFolders{})
	if _, err := s.Read(t.Context(), "riya", Solve, []sarvam.Page{{Name: "a.jpg"}}); !errors.Is(err, ErrUnavailable) {
		t.Errorf("Read() without Sarvam error = %v, want ErrUnavailable", err)
	}
}

func TestNoText(t *testing.T) {
	s := NewService(newFakeStore(), &fakeReader{text: "  \n"}, &fakeModel{}, fakeProfiles{}, &fakeLessons{}, &fakeFolders{})
	if _, err := s.Read(t.Context(), "riya", Ask, []sarvam.Page{{Name: "a.jpg"}}); !errors.Is(err, ErrNoText) {
		t.Errorf("Read() of a blank page error = %v, want ErrNoText", err)
	}
}

func TestMarkingOK(t *testing.T) {
	good := Marking{Marks: 2, Awarded: 1, FullMarks: "x", Points: []Point{{Text: "a", Marks: 1, Awarded: 1}, {Text: "b", Marks: 1}}}
	tests := []struct {
		name string
		edit func(*Marking)
		want bool
	}{
		{"good", func(*Marking) {}, true},
		{"sum mismatch", func(m *Marking) { m.Awarded = 2 }, false},
		{"over marks", func(m *Marking) { m.Points = []Point{{Text: "a", Marks: 1, Awarded: 2}}; m.Awarded = 2 }, false},
		{"no points", func(m *Marking) { m.Points = nil }, false},
		{"no tip", func(m *Marking) { m.FullMarks = "" }, false},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			m := good
			m.Points = append([]Point(nil), good.Points...)
			tc.edit(&m)
			if got := m.ok(); got != tc.want {
				t.Errorf("ok() = %v, want %v", got, tc.want)
			}
		})
	}
}

func TestTitle(t *testing.T) {
	tests := []struct{ in, want string }{
		{"\n\n## Chapter 10: Light\nbody", "Chapter 10: Light"},
		{"", "Scan"},
		{strings.Repeat("a", 70), strings.Repeat("a", 59) + "…"},
	}
	for _, tc := range tests {
		if got := title(tc.in); got != tc.want {
			t.Errorf("title(%q) = %q, want %q", tc.in, got, tc.want)
		}
	}
}
