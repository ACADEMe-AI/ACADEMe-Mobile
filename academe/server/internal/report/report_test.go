package report

import (
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type fakeStore struct {
	owned map[Report]string
	saved []Report
}

func (f *fakeStore) Save(_ context.Context, accountID string, in Report) error {
	if f.owned[Report{Kind: in.Kind, ID: in.ID}] != accountID {
		return ErrNotFound
	}
	f.saved = append(f.saved, in)
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

func TestReportRoute(t *testing.T) {
	store := &fakeStore{owned: map[Report]string{
		{Kind: Check, ID: "scan-1"}:  "riya",
		{Kind: Lesson, ID: "u-deck"}: "riya",
	}}
	mux := http.NewServeMux()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), NewService(store), guard)

	tests := []struct {
		name  string
		token string
		body  string
		want  int
	}{
		{"checked answer", "riya", `{"kind":"check","id":"scan-1","reason":"wrong","note":" marks are off "}`, http.StatusNoContent},
		{"lesson from notes", "riya", `{"kind":"lesson","id":"u-deck","reason":"harmful"}`, http.StatusNoContent},
		{"someone else's lesson", "arjun", `{"kind":"lesson","id":"u-deck","reason":"wrong"}`, http.StatusNotFound},
		{"unknown id", "riya", `{"kind":"check","id":"scan-2","reason":"wrong"}`, http.StatusNotFound},
		{"bad kind", "riya", `{"kind":"chat","id":"scan-1","reason":"wrong"}`, http.StatusUnprocessableEntity},
		{"bad reason", "riya", `{"kind":"check","id":"scan-1","reason":"boring"}`, http.StatusUnprocessableEntity},
		{"no id", "riya", `{"kind":"check","reason":"wrong"}`, http.StatusUnprocessableEntity},
		{"long id", "riya", `{"kind":"check","id":"` + strings.Repeat("a", maxIDBytes+1) + `","reason":"wrong"}`, http.StatusUnprocessableEntity},
		{"long note", "riya", `{"kind":"check","id":"scan-1","reason":"other","note":"` + strings.Repeat("a", maxNoteRunes+1) + `"}`, http.StatusUnprocessableEntity},
		{"unknown field", "riya", `{"kind":"check","id":"scan-1","reason":"wrong","extra":1}`, http.StatusBadRequest},
		{"no token", "", `{"kind":"check","id":"scan-1","reason":"wrong"}`, http.StatusUnauthorized},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequestWithContext(t.Context(), http.MethodPost, "/reports", strings.NewReader(tc.body))
			if tc.token != "" {
				req.Header.Set("Authorization", "Bearer "+tc.token)
			}
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, req)
			if rec.Code != tc.want {
				t.Errorf("POST /reports %s = %d %s, want %d", tc.body, rec.Code, rec.Body.String(), tc.want)
			}
		})
	}
	want := []Report{
		{Kind: Check, ID: "scan-1", Reason: Wrong, Note: "marks are off"},
		{Kind: Lesson, ID: "u-deck", Reason: Harmful},
	}
	if diff := cmp.Diff(want, store.saved); diff != "" {
		t.Errorf("saved reports (-want +got):\n%s", diff)
	}
}
