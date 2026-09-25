package profile

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/google/go-cmp/cmp"

	"academe/server/internal/httpx"
)

type fakeStore struct {
	mu       sync.Mutex
	profiles map[string]Profile
	awards   map[string]int
}

func newFakeStore() *fakeStore {
	return &fakeStore{profiles: map[string]Profile{}, awards: map[string]int{}}
}

func (f *fakeStore) Profile(_ context.Context, accountID string) (Profile, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.profiles[accountID], nil
}

func (f *fakeStore) Apply(_ context.Context, accountID string, u Update) (Profile, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	p := f.profiles[accountID]
	if u.Language != nil {
		p.Language = u.Language
	}
	if u.BirthYear != nil {
		p.BirthYear = u.BirthYear
	}
	if u.Class != nil {
		p.Class = u.Class
	}
	if u.Board != nil {
		p.Board = u.Board
	}
	f.profiles[accountID] = p
	return p, nil
}

func (f *fakeStore) CompleteSetup(_ context.Context, accountID string, xp int, _ string) (Profile, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	p := f.profiles[accountID]
	if !p.SetupDone {
		p.SetupDone = true
		p.XP += xp
		f.awards[accountID]++
	}
	f.profiles[accountID] = p
	return p, nil
}

func ptr[T any](v T) *T { return &v }

func newService(store Store) *Service {
	s := NewService(store)
	s.now = func() time.Time { return time.Date(2026, 9, 24, 0, 0, 0, 0, time.UTC) }
	return s
}

func TestUpdateValidation(t *testing.T) {
	tests := []struct {
		name      string
		update    Update
		wantField string
	}{
		{name: "empty", update: Update{}, wantField: "profile"},
		{name: "unknown language", update: Update{Language: ptr("fr")}, wantField: "language"},
		{name: "born this year", update: Update{BirthYear: ptr(2025)}, wantField: "birthYear"},
		{name: "class 5", update: Update{Class: ptr(5)}, wantField: "class"},
		{name: "class 13", update: Update{Class: ptr(13)}, wantField: "class"},
		{name: "state board", update: Update{Board: ptr("SSC")}, wantField: "board"},
		{name: "valid", update: Update{Language: ptr("te"), BirthYear: ptr(2011), Class: ptr(9), Board: ptr("ICSE")}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			_, err := newService(newFakeStore()).Update(t.Context(), "a", tc.update)
			v, _ := errors.AsType[*ValidationError](err)
			got := ""
			if v != nil {
				got = v.Field
			}
			if got != tc.wantField {
				t.Errorf("Update(%s) field = %q (err %v), want %q", tc.name, got, err, tc.wantField)
			}
		})
	}
}

func TestSetupRewardPaidOnce(t *testing.T) {
	store := newFakeStore()
	s := newService(store)
	ctx := t.Context()

	steps := []Update{{Language: ptr("hi")}, {BirthYear: ptr(2011)}, {Class: ptr(9)}}
	for _, u := range steps {
		p, err := s.Update(ctx, "maya", u)
		if err != nil || p.SetupDone || p.XP != 0 {
			t.Fatalf("partial Update = %+v, %v, want not done, 0 XP", p, err)
		}
	}
	p, err := s.Update(ctx, "maya", Update{Board: ptr("CBSE")})
	if err != nil || !p.SetupDone || p.XP != SetupXP {
		t.Fatalf("last Update = %+v, %v, want done, %d XP", p, err, SetupXP)
	}
	if _, err := s.Update(ctx, "maya", Update{Class: ptr(10)}); err != nil {
		t.Fatal(err)
	}
	if store.awards["maya"] != 1 {
		t.Errorf("setup reward paid %d times, want 1", store.awards["maya"])
	}
}

func TestSubjects(t *testing.T) {
	tests := []struct {
		class   int
		board   string
		wantOK  bool
		wantHas string
	}{
		{6, "CBSE", true, "science"},
		{10, "CBSE", true, "computer"},
		{12, "CBSE", true, "business-studies"},
		{9, "ICSE", true, "history-civics"},
		{11, "ICSE", true, "commerce"},
		{5, "CBSE", false, ""},
		{9, "SSC", false, ""},
	}
	for _, tc := range tests {
		got, ok := Subjects(tc.class, tc.board)
		if ok != tc.wantOK {
			t.Errorf("Subjects(%d, %q) ok = %v, want %v", tc.class, tc.board, ok, tc.wantOK)
			continue
		}
		if tc.wantHas == "" {
			continue
		}
		found := false
		for _, s := range got {
			found = found || s.ID == tc.wantHas
		}
		if !found {
			t.Errorf("Subjects(%d, %q) has no %q", tc.class, tc.board, tc.wantHas)
		}
	}
}

func fakeGuard(next httpx.HandlerFunc) httpx.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) error {
		if r.Header.Get("Authorization") != "Bearer maya" {
			return &httpx.Error{Status: http.StatusUnauthorized, Code: "invalid_token", Message: "Log in again."}
		}
		return next(w, r)
	}
}

func TestRoutes(t *testing.T) {
	mux := http.NewServeMux()
	RegisterRoutes(mux, slog.New(slog.DiscardHandler), newService(newFakeStore()), fakeGuard)
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
		if err := json.Unmarshal(raw, &got); err != nil {
			t.Fatalf("%s %s: %q is not JSON", method, path, raw)
		}
		return res.StatusCode, got
	}

	if status, _ := call("GET", "/me/profile", "", ""); status != http.StatusUnauthorized {
		t.Errorf("GET /me/profile without a token = %d, want 401", status)
	}
	status, body := call("GET", "/me/profile", "maya", "")
	want := map[string]any{"language": nil, "birthYear": nil, "class": nil, "board": nil, "setupDone": false, "xp": float64(0)}
	if diff := cmp.Diff(want, body); status != http.StatusOK || diff != "" {
		t.Errorf("GET /me/profile = %d, diff (-want +got):\n%s", status, diff)
	}
	if status, body := call("PATCH", "/me/profile", "maya", `{"class":4}`); status != 422 || body["error"].(map[string]any)["code"] != "invalid_class" {
		t.Errorf("PATCH class 4 = %d %v, want 422 invalid_class", status, body)
	}
	if status, _ := call("PATCH", "/me/profile", "maya", `{"school":"x"}`); status != http.StatusBadRequest {
		t.Errorf("PATCH unknown field = %d, want 400", status)
	}
	status, body = call("PATCH", "/me/profile", "maya", `{"language":"hi","birthYear":2011,"class":9,"board":"CBSE"}`)
	if status != http.StatusOK || body["setupDone"] != true || body["xp"] != float64(SetupXP) {
		t.Errorf("PATCH all four = %d %v, want setup done with %d XP", status, body, SetupXP)
	}
	status, body = call("GET", "/catalog/subjects?class=9&board=CBSE", "", "")
	if status != http.StatusOK || len(body["subjects"].([]any)) != 7 {
		t.Errorf("GET subjects = %d %v, want 7 subjects", status, body)
	}
	if status, _ := call("GET", "/catalog/subjects?class=x&board=CBSE", "", ""); status != http.StatusBadRequest {
		t.Errorf("GET subjects with a bad class = %d, want 400", status)
	}
}
