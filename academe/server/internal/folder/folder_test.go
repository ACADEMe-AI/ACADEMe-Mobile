package folder

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"slices"
	"strings"
	"sync"
	"testing"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
	"academe/server/internal/study"
)

type fakeStore struct {
	mu      sync.Mutex
	next    int64
	folders map[string]Folder
	owners  map[string]string
	items   map[string][]Item
	todos   map[string][]Todo
}

func newFakeStore() *fakeStore {
	return &fakeStore{folders: map[string]Folder{}, owners: map[string]string{}, items: map[string][]Item{}, todos: map[string][]Todo{}}
}

func (f *fakeStore) Folders(_ context.Context, accountID string) ([]Folder, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []Folder
	for id, fo := range f.folders {
		if f.owners[id] == accountID {
			out = append(out, fo)
		}
	}
	return out, nil
}

func (f *fakeStore) Folder(_ context.Context, accountID, id string) (Folder, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	fo, ok := f.folders[id]
	if !ok || f.owners[id] != accountID {
		return Folder{}, ErrNotFound
	}
	return fo, nil
}

func (f *fakeStore) Create(_ context.Context, accountID, name string, due *time.Time) (Folder, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.next++
	fo := Folder{ID: fmt.Sprintf("f%d", f.next), Name: name, DueOn: due, Reminds: true, CreatedAt: time.Now()}
	f.folders[fo.ID], f.owners[fo.ID] = fo, accountID
	return fo, nil
}

func (f *fakeStore) Update(_ context.Context, accountID, id, name string, due *time.Time, reminds bool) (Folder, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	fo, ok := f.folders[id]
	if !ok || f.owners[id] != accountID {
		return Folder{}, ErrNotFound
	}
	fo.Name, fo.DueOn, fo.Reminds = name, due, reminds
	f.folders[id] = fo
	return fo, nil
}

func (f *fakeStore) Delete(_ context.Context, accountID, id string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if _, ok := f.folders[id]; !ok || f.owners[id] != accountID {
		return ErrNotFound
	}
	delete(f.folders, id)
	return nil
}

func (f *fakeStore) Items(_ context.Context, folderID string) ([]Item, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return slices.Clone(f.items[folderID]), nil
}

func (f *fakeStore) AddChapters(_ context.Context, folderID string, chapterIDs []string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, c := range chapterIDs {
		if slices.ContainsFunc(f.items[folderID], func(it Item) bool { return it.ChapterID != nil && *it.ChapterID == c }) {
			continue
		}
		f.next++
		f.items[folderID] = append(f.items[folderID], Item{ID: f.next, ChapterID: &c})
	}
	return nil
}

func (f *fakeStore) AddNote(_ context.Context, folderID, text string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.next++
	f.items[folderID] = append(f.items[folderID], Item{ID: f.next, Note: &text})
	return nil
}

func (f *fakeStore) AddLesson(_ context.Context, folderID, deckID string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.next++
	f.items[folderID] = append(f.items[folderID], Item{ID: f.next, DeckID: &deckID})
	return nil
}

func (f *fakeStore) DeleteItem(_ context.Context, folderID string, itemID int64) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.items[folderID] = slices.DeleteFunc(f.items[folderID], func(it Item) bool { return it.ID == itemID })
	return nil
}

func (f *fakeStore) Todos(_ context.Context, folderID string) ([]Todo, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return slices.Clone(f.todos[folderID]), nil
}

func (f *fakeStore) AddTodo(_ context.Context, folderID, title string, day *time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.next++
	f.todos[folderID] = append(f.todos[folderID], Todo{ID: f.next, Title: title, Day: day})
	return nil
}

func (f *fakeStore) SetTodoDone(_ context.Context, folderID string, todoID int64, doneAt *time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for i, t := range f.todos[folderID] {
		if t.ID == todoID {
			f.todos[folderID][i].DoneAt = doneAt
			return nil
		}
	}
	return ErrNotFound
}

func (f *fakeStore) DeleteTodo(_ context.Context, folderID string, todoID int64) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.todos[folderID] = slices.DeleteFunc(f.todos[folderID], func(t Todo) bool { return t.ID == todoID })
	return nil
}

type fakeStudy struct{}

func (fakeStudy) Chapter(id string) (study.ChapterInfo, bool) {
	if id != "cbse-10-science-9" {
		return study.ChapterInfo{}, false
	}
	return chapter(id, 10, "l1", "l2"), true
}

func (fakeStudy) Lesson(_ context.Context, id string) (study.LessonRef, bool) {
	return study.LessonRef{ID: id, Title: "From your notes", Minutes: 4}, id == "u-1"
}

func (fakeStudy) Progress(context.Context, string) (study.Progress, error) {
	return study.Progress{Done: map[string]time.Time{}, Tests: map[string]time.Time{}, DueReviews: 2, DueByChapter: map[string]int{"cbse-10-science-9": 2}}, nil
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
	mux := http.NewServeMux()
	store := newFakeStore()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), NewService(store, fakeStudy{}), guard)
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
	code := func(got map[string]any) any { return got["error"].(map[string]any)["code"] }

	if status, _ := call("GET", "/folders", "", ""); status != http.StatusUnauthorized {
		t.Errorf("GET /folders without a token = %d, want 401", status)
	}
	if status, got := call("POST", "/folders", "riya", `{"name":"  "}`); status != http.StatusUnprocessableEntity || code(got) != "invalid_name" {
		t.Errorf("POST blank name = %d %v, want 422 invalid_name", status, got)
	}
	if status, got := call("POST", "/folders", "riya", `{"name":"Test","dueOn":"12/10"}`); status != http.StatusUnprocessableEntity || code(got) != "invalid_date" {
		t.Errorf("POST bad date = %d %v, want 422 invalid_date", status, got)
	}
	status, got := call("POST", "/folders", "riya", `{"name":"Science unit test","dueOn":"2026-10-12"}`)
	if status != http.StatusCreated || got["dueOn"] != "2026-10-12" {
		t.Fatalf("POST /folders = %d %v, want 201 with the date", status, got)
	}
	id := got["id"].(string)
	if status, got := call("POST", "/folders/"+id+"/chapters", "riya", `{"chapterIds":["nope"]}`); status != http.StatusUnprocessableEntity || code(got) != "invalid_chapter" {
		t.Errorf("POST unknown chapter = %d %v, want 422 invalid_chapter", status, got)
	}
	if status, _ := call("POST", "/folders/"+id+"/chapters", "riya", `{"chapterIds":["cbse-10-science-9"]}`); status != http.StatusNoContent {
		t.Errorf("POST chapters = %d, want 204", status)
	}
	if status, _ := call("POST", "/folders/"+id+"/notes", "riya", `{"text":"Class notes"}`); status != http.StatusNoContent {
		t.Errorf("POST note = %d, want 204", status)
	}
	svc := NewService(store, fakeStudy{})
	if err := svc.AddLesson(t.Context(), "riya", id, "u-1"); err != nil {
		t.Errorf("AddLesson() error = %v", err)
	}
	if err := svc.AddLesson(t.Context(), "riya", id, "u-404"); !errors.Is(err, ErrBadChapter) {
		t.Errorf("AddLesson(unknown) error = %v, want ErrBadChapter", err)
	}
	if status, _ := call("POST", "/folders/"+id+"/todos", "riya", `{"title":"Learn ray diagrams"}`); status != http.StatusNoContent {
		t.Errorf("POST todo = %d, want 204", status)
	}
	if status, _ := call("GET", "/folders/"+id, "arjun", ""); status != http.StatusNotFound {
		t.Errorf("GET another student's folder = %d, want 404", status)
	}
	if status, _ := call("POST", "/folders/"+id+"/todos", "arjun", `{"title":"x"}`); status != http.StatusNotFound {
		t.Errorf("POST todo to another student's folder = %d, want 404", status)
	}

	status, got = call("GET", "/folders/"+id+"?today=2026-10-09&offset=330", "riya", "")
	if status != http.StatusOK {
		t.Fatalf("GET folder = %d %v", status, got)
	}
	if n := len(got["chapters"].([]any)); n != 1 {
		t.Errorf("chapters = %d, want 1", n)
	}
	if n := len(got["notes"].([]any)); n != 1 {
		t.Errorf("notes = %d, want 1", n)
	}
	if n := len(got["lessons"].([]any)); n != 1 {
		t.Errorf("lessons = %d, want 1", n)
	}
	today := got["today"].([]any)
	if len(today) != 4 {
		t.Fatalf("today = %v, want review, two lessons and the to-do", today)
	}
	todoID := int64(today[3].(map[string]any)["todoId"].(float64))
	if status, _ := call("PUT", fmt.Sprintf("/folders/%s/todos/%d", id, todoID), "riya", `{"done":true}`); status != http.StatusNoContent {
		t.Errorf("PUT todo done = %d, want 204", status)
	}
	if status, got := call("GET", "/today", "riya", ""); status != http.StatusOK || got["reviewDue"] != 2.0 || len(got["tasks"].([]any)) != 3 {
		t.Errorf("GET /today = %d %v, want one review, one lesson and the to-do", status, got)
	}
	if status, got := call("GET", "/folders?today=2026-10-09", "riya", ""); status != http.StatusOK || len(got["folders"].([]any)) != 1 {
		t.Errorf("GET /folders = %d %v, want one", status, got)
	}
	if status, got := call("PUT", "/folders/"+id, "riya", `{"name":"Science test","dueOn":"","reminds":false}`); status != http.StatusOK || got["dueOn"] != nil || got["reminds"] != false {
		t.Errorf("PUT folder = %d %v, want no date and reminders off", status, got)
	}
	if status, _ := call("DELETE", "/folders/"+id, "riya", ""); status != http.StatusNoContent {
		t.Errorf("DELETE folder = %d, want 204", status)
	}
	if status, _ := call("DELETE", "/folders/"+id, "riya", ""); status != http.StatusNotFound {
		t.Errorf("DELETE again = %d, want 404", status)
	}
}
