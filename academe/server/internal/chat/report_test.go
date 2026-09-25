package chat

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func (f *fakeStore) Report(_ context.Context, accountID string, messageID int64, _ Report) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for id, ms := range f.messages {
		for _, m := range ms {
			if m.ID == messageID && m.Role == Pebby && f.owners[id] == accountID {
				return nil
			}
		}
	}
	return ErrNotFound
}

func TestReportRoute(t *testing.T) {
	store := newFakeStore()
	s := NewService(store, &fakeTutor{}, fakeProfiles{}, fakeAccounts{})
	ex, err := s.Send(t.Context(), "riya", Send{Mode: Explain, Text: "Why?"})
	if err != nil {
		t.Fatal(err)
	}
	mux := http.NewServeMux()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), s, guard)
	reply, question := idText(ex.Reply.ID), idText(ex.Question.ID)

	tests := []struct {
		name  string
		token string
		path  string
		body  string
		want  int
	}{
		{"own answer", "riya", "/chat/messages/" + reply + "/report", `{"reason":"offensive","note":"rude"}`, http.StatusNoContent},
		{"no note", "riya", "/chat/messages/" + reply + "/report", `{"reason":"wrong"}`, http.StatusNoContent},
		{"bad reason", "riya", "/chat/messages/" + reply + "/report", `{"reason":"boring"}`, http.StatusUnprocessableEntity},
		{"long note", "riya", "/chat/messages/" + reply + "/report", `{"reason":"other","note":"` + strings.Repeat("a", maxReportNoteRunes+1) + `"}`, http.StatusUnprocessableEntity},
		{"student message", "riya", "/chat/messages/" + question + "/report", `{"reason":"wrong"}`, http.StatusNotFound},
		{"someone else's answer", "arjun", "/chat/messages/" + reply + "/report", `{"reason":"wrong"}`, http.StatusNotFound},
		{"not a number", "riya", "/chat/messages/x/report", `{"reason":"wrong"}`, http.StatusNotFound},
		{"no token", "", "/chat/messages/" + reply + "/report", `{"reason":"wrong"}`, http.StatusUnauthorized},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequestWithContext(t.Context(), "POST", tc.path, strings.NewReader(tc.body))
			if tc.token != "" {
				req.Header.Set("Authorization", "Bearer "+tc.token)
			}
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)
			if rec.Code != tc.want {
				t.Errorf("POST %s %s = %d %s, want %d", tc.path, tc.body, rec.Code, rec.Body.String(), tc.want)
			}
		})
	}
}

func TestPostgresReport(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()
	riya := newAccount(t, pool, "riya@example.com")
	arjun := newAccount(t, pool, "arjun@example.com")
	thread, err := store.CreateThread(ctx, riya, Explain, "Why?")
	if err != nil {
		t.Fatal(err)
	}
	question, err := store.AddMessage(ctx, thread.ID, Student, "Why?")
	if err != nil {
		t.Fatal(err)
	}
	reply, err := store.AddMessage(ctx, thread.ID, Pebby, "Because.")
	if err != nil {
		t.Fatal(err)
	}

	if err := store.Report(ctx, riya, reply.ID, Report{Reason: Wrong}); err != nil {
		t.Fatalf("Report() error = %v", err)
	}
	if err := store.Report(ctx, riya, reply.ID, Report{Reason: Offensive, Note: "rude"}); err != nil {
		t.Fatalf("Report(again) error = %v", err)
	}
	var reason, note string
	if err := pool.QueryRow(ctx, `SELECT reason, note FROM chat_reports WHERE message_id = $1`, reply.ID).Scan(&reason, &note); err != nil {
		t.Fatal(err)
	}
	if reason != "offensive" || note != "rude" {
		t.Errorf("stored report = %q %q, want offensive rude", reason, note)
	}
	if err := store.Report(ctx, arjun, reply.ID, Report{Reason: Wrong}); !errors.Is(err, ErrNotFound) {
		t.Errorf("Report(someone else's answer) error = %v, want ErrNotFound", err)
	}
	if err := store.Report(ctx, riya, question.ID, Report{Reason: Wrong}); !errors.Is(err, ErrNotFound) {
		t.Errorf("Report(student message) error = %v, want ErrNotFound", err)
	}
}
