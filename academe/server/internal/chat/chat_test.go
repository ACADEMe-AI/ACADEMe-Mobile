package chat

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
	"academe/server/internal/profile"
	"academe/server/internal/sarvam"
)

type fakeStore struct {
	mu       sync.Mutex
	threads  map[string]Thread
	owners   map[string]string
	messages map[string][]Message
	nextID   int64
}

func newFakeStore() *fakeStore {
	return &fakeStore{threads: map[string]Thread{}, owners: map[string]string{}, messages: map[string][]Message{}}
}

func (f *fakeStore) Threads(_ context.Context, accountID string) ([]Thread, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []Thread
	for id, t := range f.threads {
		if f.owners[id] == accountID {
			out = append(out, t)
		}
	}
	return out, nil
}

func (f *fakeStore) CreateThread(_ context.Context, accountID string, mode Mode, title string) (Thread, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.nextID++
	t := Thread{ID: fmt.Sprintf("t%d", f.nextID), Mode: mode, Title: title}
	f.threads[t.ID] = t
	f.owners[t.ID] = accountID
	return t, nil
}

func (f *fakeStore) Thread(_ context.Context, accountID, threadID string) (Thread, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	t, ok := f.threads[threadID]
	if !ok || f.owners[threadID] != accountID {
		return Thread{}, ErrNotFound
	}
	return t, nil
}

func (f *fakeStore) Messages(_ context.Context, threadID string) ([]Message, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]Message(nil), f.messages[threadID]...), nil
}

func (f *fakeStore) AddMessage(_ context.Context, threadID string, role Role, body string) (Message, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.nextID++
	m := Message{ID: f.nextID, Role: role, Body: body, CreatedAt: time.Date(2026, 9, 25, 0, 0, 0, 0, time.UTC)}
	f.messages[threadID] = append(f.messages[threadID], m)
	return m, nil
}

func (f *fakeStore) DeleteLastReply(_ context.Context, threadID string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	ms := f.messages[threadID]
	if len(ms) == 0 || ms[len(ms)-1].Role != Pebby {
		return ErrNothingToRetry
	}
	f.messages[threadID] = ms[:len(ms)-1]
	return nil
}

func (f *fakeStore) Rate(_ context.Context, accountID string, messageID int64, rating int) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for id, ms := range f.messages {
		for i := range ms {
			if ms[i].ID == messageID && ms[i].Role == Pebby && f.owners[id] == accountID {
				ms[i].Rating = rating
				return nil
			}
		}
	}
	return ErrNotFound
}

type fakeTutor struct {
	briefs  []Brief
	history [][]Message
	err     error
}

func (f *fakeTutor) Reply(_ context.Context, brief Brief, history []Message) (string, error) {
	f.briefs = append(f.briefs, brief)
	f.history = append(f.history, history)
	if f.err != nil {
		return "", f.err
	}
	return "Answer " + history[len(history)-1].Body, nil
}

type fakeProfiles struct{}

func (fakeProfiles) Profile(context.Context, string) (profile.Profile, error) {
	class, board, language := 10, "CBSE", "te"
	return profile.Profile{Class: &class, Board: &board, Language: &language}, nil
}

type fakeAccounts struct{}

func (fakeAccounts) Account(context.Context, string) (auth.Account, error) {
	return auth.Account{FirstName: "Riya"}, nil
}

func TestSend(t *testing.T) {
	tutor := &fakeTutor{}
	s := NewService(newFakeStore(), tutor, fakeProfiles{}, fakeAccounts{})

	first, err := s.Send(t.Context(), "riya", Send{Mode: Explain, Text: "  What is reflection?  "})
	if err != nil {
		t.Fatalf("Send() error = %v", err)
	}
	if first.Thread.Title != "What is reflection?" || first.Reply.Body != "Answer What is reflection?" {
		t.Errorf("Send() = %+v, want a titled thread and an answer", first)
	}
	want := Brief{FirstName: "Riya", Class: 10, Board: "CBSE", Language: "te", Mode: Explain}
	if tutor.briefs[0] != want {
		t.Errorf("brief = %+v, want %+v", tutor.briefs[0], want)
	}

	id := first.Thread.ID
	if _, err := s.Send(t.Context(), "riya", Send{ThreadID: &id, Mode: Solve, Text: "And refraction?"}); err != nil {
		t.Fatalf("Send(follow-up) error = %v", err)
	}
	if got := len(tutor.history[1]); got != 3 {
		t.Errorf("follow-up history has %d messages, want 3", got)
	}
	if tutor.briefs[1].Mode != Solve {
		t.Errorf("follow-up mode = %q, want solve", tutor.briefs[1].Mode)
	}
	if _, err := s.Send(t.Context(), "arjun", Send{ThreadID: &id, Mode: Explain, Text: "hi"}); !errors.Is(err, ErrNotFound) {
		t.Errorf("Send(someone else's thread) error = %v, want ErrNotFound", err)
	}
}

func TestSendRejects(t *testing.T) {
	tests := []struct {
		name  string
		tutor Tutor
		in    Send
		want  error
	}{
		{"empty", &fakeTutor{}, Send{Mode: Explain, Text: "  "}, ErrEmpty},
		{"too long", &fakeTutor{}, Send{Mode: Explain, Text: strings.Repeat("a", maxMessageRunes+1)}, ErrTooLong},
		{"bad mode", &fakeTutor{}, Send{Mode: "chat", Text: "hi"}, ErrBadMode},
		{"no tutor", nil, Send{Mode: Explain, Text: "hi"}, ErrUnavailable},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			s := NewService(newFakeStore(), tc.tutor, fakeProfiles{}, fakeAccounts{})
			if _, err := s.Send(t.Context(), "riya", tc.in); !errors.Is(err, tc.want) {
				t.Errorf("Send(%+v) error = %v, want %v", tc.in, err, tc.want)
			}
		})
	}
}

func TestRetryReplacesTheLastAnswer(t *testing.T) {
	store := newFakeStore()
	s := NewService(store, &fakeTutor{}, fakeProfiles{}, fakeAccounts{})
	ex, err := s.Send(t.Context(), "riya", Send{Mode: Explain, Text: "Why?"})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.Retry(t.Context(), "riya", ex.Thread.ID, Explain); err != nil {
		t.Fatalf("Retry() error = %v", err)
	}
	messages, _ := store.Messages(t.Context(), ex.Thread.ID)
	if len(messages) != 2 || messages[1].ID == ex.Reply.ID {
		t.Errorf("after Retry() messages = %+v, want the question and one new answer", messages)
	}
}

func TestTitle(t *testing.T) {
	long := strings.Repeat("x", 80)
	if got := title("line one\nline two"); got != "line one" {
		t.Errorf("title(two lines) = %q, want %q", got, "line one")
	}
	if got := []rune(title(long)); len(got) != maxTitleRunes || got[len(got)-1] != '…' {
		t.Errorf("title(80 chars) = %q, want %d runes ending in …", string(got), maxTitleRunes)
	}
}

func TestSystemPromptFollowsTheStudent(t *testing.T) {
	prompt := SystemPrompt(Brief{FirstName: "Sai", Class: 9, Board: "ICSE", Language: "te", Mode: Solve})
	for _, want := range []string{"Sai", "Class 9 ICSE", "Telugu", "Mode: Solve"} {
		if !strings.Contains(prompt, want) {
			t.Errorf("SystemPrompt() is missing %q", want)
		}
	}
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
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), NewService(newFakeStore(), &fakeTutor{}, fakeProfiles{}, fakeAccounts{}), guard)
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

	if status, _ := call("GET", "/chat/threads", "", ""); status != http.StatusUnauthorized {
		t.Errorf("GET /chat/threads without a token = %d, want 401", status)
	}
	status, got := call("POST", "/chat/messages", "riya", `{"mode":"explain","text":"What is light?"}`)
	if status != http.StatusOK {
		t.Fatalf("POST /chat/messages = %d %v, want 200", status, got)
	}
	threadID := got["thread"].(map[string]any)["id"].(string)
	replyID := int64(got["reply"].(map[string]any)["id"].(float64))

	if status, got := call("GET", "/chat/threads", "riya", ""); status != http.StatusOK || len(got["threads"].([]any)) != 1 {
		t.Errorf("GET /chat/threads = %d %v, want one thread", status, got)
	}
	if status, got := call("GET", "/chat/threads/"+threadID+"/messages", "riya", ""); status != http.StatusOK || len(got["messages"].([]any)) != 2 {
		t.Errorf("GET messages = %d %v, want two messages", status, got)
	}
	if status, _ := call("GET", "/chat/threads/"+threadID+"/messages", "arjun", ""); status != http.StatusNotFound {
		t.Errorf("GET another student's messages = %d, want 404", status)
	}
	if status, _ := call("PUT", "/chat/messages/"+idText(replyID)+"/rating", "riya", `{"rating":1}`); status != http.StatusNoContent {
		t.Errorf("PUT rating = %d, want 204", status)
	}
	if status, got := call("PUT", "/chat/messages/"+idText(replyID)+"/rating", "riya", `{"rating":5}`); status != http.StatusUnprocessableEntity {
		t.Errorf("PUT rating 5 = %d %v, want 422", status, got)
	}
	if status, got := call("POST", "/chat/threads/"+threadID+"/retry", "riya", `{"mode":"explain"}`); status != http.StatusOK || got["role"] != "pebby" {
		t.Errorf("POST retry = %d %v, want a new answer", status, got)
	}
	if status, got := call("POST", "/chat/messages", "riya", `{"mode":"explain","text":""}`); status != http.StatusUnprocessableEntity || got["error"].(map[string]any)["code"] != "invalid_text" {
		t.Errorf("POST empty message = %d %v, want 422 invalid_text", status, got)
	}
}

func TestUnavailableWithoutATutor(t *testing.T) {
	mux := http.NewServeMux()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), NewService(newFakeStore(), nil, fakeProfiles{}, fakeAccounts{}), guard)
	req := httptest.NewRequestWithContext(t.Context(), "POST", "/chat/messages", strings.NewReader(`{"mode":"explain","text":"hi"}`))
	req.Header.Set("Authorization", "Bearer riya")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if rec.Code != http.StatusServiceUnavailable || !strings.Contains(rec.Body.String(), "askme_unavailable") {
		t.Errorf("POST /chat/messages without a tutor = %d %s, want 503 askme_unavailable", rec.Code, rec.Body.String())
	}
}

func idText(id int64) string {
	b, _ := json.Marshal(id)
	return string(b)
}

func TestSarvamOutageIsUnavailable(t *testing.T) {
	err := toHTTP(fmt.Errorf("tutor reply: %w", &sarvam.StatusError{Code: http.StatusPaymentRequired, Detail: "No credits available."}))
	var e *httpx.Error
	if !errors.As(err, &e) || e.Status != http.StatusServiceUnavailable || e.Code != "askme_unavailable" {
		t.Errorf("toHTTP(sarvam 402) = %v, want 503 askme_unavailable", err)
	}
}
