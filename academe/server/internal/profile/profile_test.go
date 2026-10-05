package profile

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
	if u.Subjects != nil {
		p.Subjects = *u.Subjects
	}
	f.profiles[accountID] = p
	return p, nil
}

func (f *fakeStore) AwardXP(_ context.Context, accountID string, xp int, reason string) (Profile, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	p := f.profiles[accountID]
	if f.awards[accountID+reason] == 0 {
		p.XP += xp
	}
	f.awards[accountID+reason]++
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
	want := map[string]any{"language": nil, "birthYear": nil, "class": nil, "board": nil, "subjects": nil, "setupDone": false, "xp": float64(0)}
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
	status, body = call("PATCH", "/me/profile", "maya", `{"subjects":["maths","english","maths"]}`)
	if diff := cmp.Diff([]any{"maths", "english"}, body["subjects"]); status != http.StatusOK || diff != "" || body["xp"] != float64(SetupXP+SubjectsXP) {
		t.Errorf("PATCH subjects = %d %v, diff (-want +got):\n%s", status, body, diff)
	}
	if status, body := call("PATCH", "/me/profile", "maya", `{"subjects":["maths"]}`); status != 422 || body["error"].(map[string]any)["code"] != "invalid_subjects" {
		t.Errorf("PATCH subjects without English = %d %v, want 422 invalid_subjects", status, body)
	}
	status, body = call("GET", "/catalog/streams?class=11&board=ICSE", "", "")
	if status != http.StatusOK || len(body["streams"].([]any)) != 4 {
		t.Errorf("GET streams = %d %v, want 4 streams", status, body)
	}
	if status, _ := call("GET", "/catalog/streams?class=10&board=CBSE", "", ""); status != http.StatusBadRequest {
		t.Errorf("GET streams for Class 10 = %d, want 400", status)
	}
	status, body = call("GET", "/catalog/subjects?class=9&board=CBSE", "", "")
	if status != http.StatusOK || len(body["subjects"].([]any)) != 7 {
		t.Errorf("GET subjects = %d %v, want 7 subjects", status, body)
	}
	if status, _ := call("GET", "/catalog/subjects?class=x&board=CBSE", "", ""); status != http.StatusBadRequest {
		t.Errorf("GET subjects with a bad class = %d, want 400", status)
	}
}

func TestSubjectPicks(t *testing.T) {
	tests := []struct {
		name      string
		start     Profile
		update    Update
		want      []string
		wantField string
	}{
		{name: "no class yet", start: Profile{}, update: Update{Subjects: &[]string{"english"}}, wantField: "subjects"},
		{name: "not taught", start: Profile{Class: ptr(10), Board: ptr("CBSE")}, update: Update{Subjects: &[]string{"english", "physics"}}, wantField: "subjects"},
		{name: "no english", start: Profile{Class: ptr(10), Board: ptr("CBSE")}, update: Update{Subjects: &[]string{"maths"}}, wantField: "subjects"},
		{name: "empty", start: Profile{Class: ptr(10), Board: ptr("CBSE")}, update: Update{Subjects: &[]string{}}, wantField: "subjects"},
		{name: "board order", start: Profile{Class: ptr(10), Board: ptr("CBSE")}, update: Update{Subjects: &[]string{"hindi", "english", "maths"}}, want: []string{"maths", "english", "hindi"}},
		{name: "with a new class", start: Profile{Class: ptr(10), Board: ptr("CBSE")}, update: Update{Class: ptr(11), Subjects: &[]string{"english", "physics"}}, want: []string{"physics", "english"}},
		{name: "board change filters", start: Profile{Class: ptr(10), Board: ptr("CBSE"), Subjects: []string{"maths", "science", "english", "sanskrit"}}, update: Update{Board: ptr("ICSE")}, want: []string{"english", "maths"}},
		{name: "class change in band keeps", start: Profile{Class: ptr(9), Board: ptr("CBSE"), Subjects: []string{"maths", "english"}}, update: Update{Class: ptr(10)}, want: []string{"maths", "english"}},
		{name: "class 10 to 11 clears", start: Profile{Class: ptr(10), Board: ptr("CBSE"), Subjects: []string{"maths", "english"}}, update: Update{Class: ptr(11)}},
		{name: "language leaves picks", start: Profile{Class: ptr(10), Board: ptr("CBSE"), Subjects: []string{"maths", "english"}}, update: Update{Language: ptr("hi")}, want: []string{"maths", "english"}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			store := newFakeStore()
			store.profiles["a"] = tc.start
			p, err := newService(store).Update(t.Context(), "a", tc.update)
			v, _ := errors.AsType[*ValidationError](err)
			if tc.wantField != "" {
				if v == nil || v.Field != tc.wantField {
					t.Errorf("Update(%s) = %v, want a %s validation error", tc.name, err, tc.wantField)
				}
				return
			}
			if err != nil {
				t.Fatalf("Update(%s) = %v", tc.name, err)
			}
			if diff := cmp.Diff(tc.want, p.Subjects); diff != "" {
				t.Errorf("Update(%s) subjects diff (-want +got):\n%s", tc.name, diff)
			}
		})
	}
}

func TestSubjectsRewardPaidOnce(t *testing.T) {
	store := newFakeStore()
	store.profiles["a"] = Profile{Class: ptr(8), Board: ptr("CBSE"), SetupDone: true, XP: SetupXP}
	s := newService(store)
	for range 2 {
		if _, err := s.Update(t.Context(), "a", Update{Subjects: &[]string{"english", "maths"}}); err != nil {
			t.Fatal(err)
		}
	}
	if got := store.profiles["a"].XP; got != SetupXP+SubjectsXP {
		t.Errorf("XP after saving subjects twice = %d, want %d", got, SetupXP+SubjectsXP)
	}
}

func TestStreams(t *testing.T) {
	for _, board := range Boards {
		for _, class := range []int{11, 12} {
			streams, ok := Streams(class, board)
			allowed, _ := Subjects(class, board)
			if !ok || len(streams) != 4 {
				t.Fatalf("Streams(%d, %s) = %d streams, %v; want 4", class, board, len(streams), ok)
			}
			for _, st := range streams {
				if st.Main[0].ID != English {
					t.Errorf("Streams(%d, %s) %s main = %v, want English first", class, board, st.ID, st.Main)
				}
				for _, sub := range append(slices.Clone(st.Main), st.Optional...) {
					if !slices.Contains(allowed, sub) {
						t.Errorf("Streams(%d, %s) %s has %s, which Subjects doesn't list", class, board, st.ID, sub.ID)
					}
				}
			}
		}
	}
	if _, ok := Streams(10, "CBSE"); ok {
		t.Error("Streams(10, CBSE) ok = true, want false")
	}
}
