package site

import (
	"context"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"

	"github.com/google/go-cmp/cmp"
)

type fakeStore struct {
	mu       sync.Mutex
	requests []string
}

func (f *fakeStore) RequestDeletion(_ context.Context, email, _ string) (bool, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, r := range f.requests {
		if r == email {
			return false, nil
		}
	}
	f.requests = append(f.requests, email)
	return true, nil
}

type fakeMailer struct {
	mu   sync.Mutex
	sent []string
}

func (f *fakeMailer) SendDeletionNotice(_ context.Context, to string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.sent = append(f.sent, to)
	return nil
}

func newSite(t *testing.T) (*http.ServeMux, *fakeStore, *fakeMailer) {
	t.Helper()
	mux := http.NewServeMux()
	store, mailer := &fakeStore{}, &fakeMailer{}
	if err := RegisterRoutes(mux, slog.New(slog.DiscardHandler), Options{Store: store, Mailer: mailer, Resets: &fakeResetter{}, FormKey: []byte("0123456789abcdef0123456789abcdef")}); err != nil {
		t.Fatalf("RegisterRoutes() = %v", err)
	}
	return mux, store, mailer
}

func TestPages(t *testing.T) {
	mux, _, _ := newSite(t)
	tests := []struct {
		path string
		want string
	}{
		{"/", "Get it on Google Play"},
		{"/privacy", "Sarvam AI"},
		{"/terms", "Terms of use"},
		{"/delete-account", "Request deletion"},
		{"/support", "Grievance Officer"},
		{"/open", "intent://open#Intent;scheme=academe;package=com.academe.flutter"},
	}
	for _, tc := range tests {
		t.Run(tc.path, func(t *testing.T) {
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), "GET", tc.path, nil))
			body := rec.Body.String()
			if rec.Code != http.StatusOK || !strings.Contains(body, tc.want) {
				t.Errorf("GET %s = %d, body contains %q: %v; want 200 and true", tc.path, rec.Code, tc.want, strings.Contains(body, tc.want))
			}
			if got := rec.Header().Get("Content-Type"); got != "text/html; charset=utf-8" {
				t.Errorf("GET %s Content-Type = %q, want text/html", tc.path, got)
			}
			if got := rec.Header().Get("Content-Security-Policy"); !strings.Contains(got, "default-src 'none'") {
				t.Errorf("GET %s CSP = %q, want default-src 'none'", tc.path, got)
			}
			if !strings.Contains(body, "support@academe.cc") {
				t.Errorf("GET %s has no support address", tc.path)
			}
		})
	}
}

func TestUnknownPathIsNotTheLandingPage(t *testing.T) {
	mux, _, _ := newSite(t)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), "GET", "/nope", nil))
	if rec.Code != http.StatusNotFound {
		t.Errorf("GET /nope = %d, want 404", rec.Code)
	}
}

func TestRequestDeletion(t *testing.T) {
	mux, store, mailer := newSite(t)
	post := func(email string) *httptest.ResponseRecorder {
		t.Helper()
		form := url.Values{"email": {email}}.Encode()
		req := httptest.NewRequestWithContext(t.Context(), "POST", "/delete-account", strings.NewReader(form))
		req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, req)
		return rec
	}

	tests := []struct {
		name   string
		email  string
		status int
		want   string
	}{
		{"valid", "  Riya@Example.com ", http.StatusOK, "Request received"},
		{"repeat", "riya@example.com", http.StatusOK, "Request received"},
		{"not an email", "riya", http.StatusUnprocessableEntity, "look like an email address"},
		{"display name", "Riya <riya@example.com>", http.StatusUnprocessableEntity, "look like an email address"},
		{"empty", "", http.StatusUnprocessableEntity, "look like an email address"},
		{"too long", strings.Repeat("a", 250) + "@example.com", http.StatusUnprocessableEntity, "look like an email address"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			rec := post(tc.email)
			if rec.Code != tc.status || !strings.Contains(rec.Body.String(), tc.want) {
				t.Errorf("POST /delete-account %q = %d, want %d containing %q", tc.email, rec.Code, tc.status, tc.want)
			}
		})
	}
	if diff := cmp.Diff([]string{"riya@example.com"}, store.requests); diff != "" {
		t.Errorf("stored requests mismatch (-want +got):\n%s", diff)
	}
	if diff := cmp.Diff([]string{"riya@example.com"}, mailer.sent); diff != "" {
		t.Errorf("confirmation emails mismatch (-want +got):\n%s", diff)
	}
}

func TestEscapesTheSubmittedEmail(t *testing.T) {
	mux, _, _ := newSite(t)
	form := url.Values{"email": {`"><script>x</script>`}}.Encode()
	req := httptest.NewRequestWithContext(t.Context(), "POST", "/delete-account", strings.NewReader(form))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	if strings.Contains(rec.Body.String(), "<script>") {
		t.Errorf("POST /delete-account echoed raw markup: %s", rec.Body.String())
	}
}

func TestClientIPGroupsIPv6ByNetwork(t *testing.T) {
	tests := []struct{ remote, want string }{
		{"203.0.113.7:0", "203.0.113.7"},
		{"[::ffff:203.0.113.7]:0", "203.0.113.7"},
		{"[2001:db8:1:2:aaaa::1]:0", "2001:db8:1:2::/64"},
		{"[2001:db8:1:2:bbbb::9]:443", "2001:db8:1:2::/64"},
		{"garbage", "garbage"},
	}
	for _, tt := range tests {
		r := httptest.NewRequestWithContext(t.Context(), http.MethodPost, "/delete-account", nil)
		r.RemoteAddr = tt.remote
		if got := clientIP(r); got != tt.want {
			t.Errorf("clientIP(%q) = %q, want %q", tt.remote, got, tt.want)
		}
	}
}
