package site

import (
	"context"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"net/url"
	"strings"
	"sync"
	"testing"

	"github.com/google/go-cmp/cmp"

	"academe/server/internal/auth"
)

type fakeResetter struct {
	mu        sync.Mutex
	used      map[string]bool
	throttled bool
	calls     []string
}

func (f *fakeResetter) ResetWithLink(_ context.Context, link, password, ip string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls = append(f.calls, link+" "+ip)
	switch {
	case f.throttled:
		return auth.ErrThrottled
	case len(password) < 8:
		return &auth.ValidationError{Field: "password", Problem: "is too short"}
	case f.used[link] || link != "good-link":
		return auth.ErrResetTokenExpired
	}
	if f.used == nil {
		f.used = map[string]bool{}
	}
	f.used[link] = true
	return nil
}

func newResetSite(t *testing.T) (*http.ServeMux, *fakeResetter) {
	t.Helper()
	mux, resets := http.NewServeMux(), &fakeResetter{}
	if err := RegisterRoutes(mux, slog.New(slog.DiscardHandler), Options{Store: &fakeStore{}, Resets: resets, FormKey: []byte("0123456789abcdef0123456789abcdef")}); err != nil {
		t.Fatal(err)
	}
	return mux, resets
}

func getForm(t *testing.T, mux http.Handler, link string) (*http.Cookie, string, *httptest.ResponseRecorder) {
	t.Helper()
	return getFormOver(t, mux, link, "https")
}

func getFormOver(t *testing.T, mux http.Handler, link, proto string) (*http.Cookie, string, *httptest.ResponseRecorder) {
	t.Helper()
	rec := httptest.NewRecorder()
	req := httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/reset-password?c="+url.QueryEscape(link), nil)
	req.Header.Set("X-Forwarded-Proto", proto)
	mux.ServeHTTP(rec, req)
	cookies := rec.Result().Cookies()
	if len(cookies) != 1 {
		return nil, "", rec
	}
	body := rec.Body.String()
	_, after, _ := strings.Cut(body, `name="t" value="`)
	token, _, _ := strings.Cut(after, `"`)
	return cookies[0], token, rec
}

func postReset(t *testing.T, mux http.Handler, cookie *http.Cookie, form url.Values) *httptest.ResponseRecorder {
	t.Helper()
	return postResetOver(t, mux, cookie, form, "https")
}

func postResetOver(t *testing.T, mux http.Handler, cookie *http.Cookie, form url.Values, proto string) *httptest.ResponseRecorder {
	t.Helper()
	req := httptest.NewRequestWithContext(t.Context(), http.MethodPost, "/reset-password", strings.NewReader(form.Encode()))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Set("X-Forwarded-Proto", proto)
	req.RemoteAddr = "203.0.113.9:4000"
	if cookie != nil {
		req.AddCookie(&http.Cookie{Name: cookie.Name, Value: cookie.Value, Secure: true, HttpOnly: true, SameSite: http.SameSiteStrictMode})
	}
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	return rec
}

func TestResetPageShowsTheForm(t *testing.T) {
	mux, _ := newResetSite(t)
	cookie, token, rec := getForm(t, mux, "good-link")
	body := rec.Body.String()
	if rec.Code != http.StatusOK || token == "" {
		t.Fatalf("GET /reset-password = %d with form token %q, want 200 and a token", rec.Code, token)
	}
	for _, want := range []string{`name="c" value="good-link"`, `type="password"`, "Save new password", `href="academe://reset?c=good-link"`, "support@academe.cc"} {
		if !strings.Contains(body, want) {
			t.Errorf("reset page does not contain %q", want)
		}
	}
	if cookie == nil || cookie.Name != "__Host-academe-reset" || !cookie.Secure || !cookie.HttpOnly || cookie.SameSite != http.SameSiteStrictMode || cookie.Path != "/" {
		t.Errorf("reset cookie = %+v, want __Host- cookie, Secure, HttpOnly, SameSite=Strict, Path=/", cookie)
	}
	for header, want := range map[string]string{"Cache-Control": "no-store", "Referrer-Policy": "no-referrer", "X-Content-Type-Options": "nosniff"} {
		if got := rec.Header().Get(header); got != want {
			t.Errorf("%s = %q, want %q", header, got, want)
		}
	}

	for _, link := range []string{`"><script>x</script>`, "javascript:alert(1)", "a&next=https://evil.example", strings.Repeat("a", 65)} {
		_, _, rec = getForm(t, mux, link)
		if rec.Code != http.StatusBadRequest || strings.Contains(rec.Body.String(), link) || len(rec.Result().Cookies()) != 0 {
			t.Errorf("GET /reset-password?c=%q = %d, want 400 without echoing the link", link, rec.Code)
		}
	}
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/reset-password", nil))
	if rec.Code != http.StatusBadRequest || !strings.Contains(rec.Body.String(), "Open the link again") || len(rec.Result().Cookies()) != 0 {
		t.Errorf("GET /reset-password without a link = %d, want 400 asking to open the link again", rec.Code)
	}
}

func TestResetPagePost(t *testing.T) {
	mux, resets := newResetSite(t)
	cookie, token, _ := getForm(t, mux, "good-link")
	otherCookie, otherToken, _ := getForm(t, mux, "other-link")
	form := func(link, token, password, confirm string) url.Values {
		return url.Values{"c": {link}, "t": {token}, "password": {password}, "confirm": {confirm}}
	}
	tests := []struct {
		name   string
		cookie *http.Cookie
		form   url.Values
		status int
		want   string
	}{
		{"no cookie", nil, form("good-link", token, "moonflower", "moonflower"), http.StatusForbidden, "Open the link again"},
		{"cookie from another visit", otherCookie, form("good-link", token, "moonflower", "moonflower"), http.StatusForbidden, "Open the link again"},
		{"token for another link", cookie, form("good-link", otherToken, "moonflower", "moonflower"), http.StatusForbidden, "Open the link again"},
		{"token moved to another link", otherCookie, form("good-link", otherToken, "moonflower", "moonflower"), http.StatusForbidden, "Open the link again"},
		{"passwords differ", cookie, form("good-link", token, "moonflower", "sunflower"), http.StatusUnprocessableEntity, "don&#39;t match"},
		{"too short", cookie, form("good-link", token, "short", "short"), http.StatusUnprocessableEntity, "Use 8 to 128 characters"},
		{"saved", cookie, form("good-link", token, "moonflower", "moonflower"), http.StatusOK, "Password changed"},
		{"link already used", cookie, form("good-link", token, "moonflower", "moonflower"), http.StatusGone, "This link has expired"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			rec := postReset(t, mux, tc.cookie, tc.form)
			if rec.Code != tc.status || !strings.Contains(rec.Body.String(), tc.want) {
				t.Errorf("POST /reset-password = %d, want %d containing %q", rec.Code, tc.status, tc.want)
			}
			if rec.Code == http.StatusOK {
				if c := rec.Result().Cookies(); len(c) != 1 || c[0].MaxAge >= 0 {
					t.Errorf("cookies after success = %v, want the reset cookie cleared", c)
				}
			}
		})
	}
	want := []string{"good-link 203.0.113.9", "good-link 203.0.113.9", "good-link 203.0.113.9"}
	if diff := cmp.Diff(want, resets.calls); diff != "" {
		t.Errorf("ResetWithLink calls mismatch (-want +got):\n%s", diff)
	}

	resets.throttled = true
	if rec := postReset(t, mux, cookie, form("good-link", token, "moonflower", "moonflower")); rec.Code != http.StatusTooManyRequests {
		t.Errorf("POST when throttled = %d, want 429", rec.Code)
	}
}

func TestResetPageOverPlainHTTP(t *testing.T) {
	mux, _ := newResetSite(t)
	cookie, token, _ := getFormOver(t, mux, "good-link", "http")
	if cookie == nil || cookie.Name != "academe-reset" || cookie.Secure || !cookie.HttpOnly || cookie.SameSite != http.SameSiteStrictMode {
		t.Fatalf("reset cookie over http = %+v, want a plain HttpOnly SameSite=Strict cookie a browser keeps on http", cookie)
	}
	form := url.Values{"c": {"good-link"}, "t": {token}, "password": {"moonflower"}, "confirm": {"moonflower"}}
	if rec := postResetOver(t, mux, cookie, form, "https"); rec.Code != http.StatusForbidden {
		t.Errorf("http cookie posted over https = %d, want 403", rec.Code)
	}
	if rec := postResetOver(t, mux, cookie, form, "http"); rec.Code != http.StatusOK {
		t.Errorf("POST over http = %d, want 200", rec.Code)
	}
}

func TestEmailAssets(t *testing.T) {
	mux, _ := newResetSite(t)
	tests := []struct {
		path, contentType string
		status            int
	}{
		{"/email/logo.png", "image/png", http.StatusOK},
		{"/email/pebby-wave.png", "image/png", http.StatusOK},
		{"/email/pebby-shy.png", "image/png", http.StatusOK},
		{"/email/baloo2-800.ttf", "font/ttf", http.StatusOK},
		{"/email/nope.png", "", http.StatusNotFound},
		{"/email/..%2fsite.go", "", http.StatusBadRequest},
	}
	for _, tc := range tests {
		rec := httptest.NewRecorder()
		mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), http.MethodGet, tc.path, nil))
		if rec.Code != tc.status || (tc.contentType != "" && rec.Header().Get("Content-Type") != tc.contentType) {
			t.Errorf("GET %s = %d %q, want %d %q", tc.path, rec.Code, rec.Header().Get("Content-Type"), tc.status, tc.contentType)
		}
	}
}

func TestAssetLinks(t *testing.T) {
	mux, _ := newResetSite(t)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/.well-known/assetlinks.json", nil))
	if rec.Code != http.StatusNotFound {
		t.Errorf("assetlinks without a certificate = %d, want 404", rec.Code)
	}

	cert := strings.TrimSuffix(strings.Repeat("AB:", 32), ":")
	mux = http.NewServeMux()
	if err := RegisterRoutes(mux, slog.New(slog.DiscardHandler), Options{Store: &fakeStore{}, AndroidCerts: []string{cert}}); err != nil {
		t.Fatal(err)
	}
	rec = httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/.well-known/assetlinks.json", nil))
	var got []map[string]any
	if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil || rec.Header().Get("Content-Type") != "application/json" {
		t.Fatalf("assetlinks = %d %s (%v)", rec.Code, rec.Body, err)
	}
	want := []map[string]any{{
		"relation": []any{"delegate_permission/common.handle_all_urls"},
		"target":   map[string]any{"namespace": "android_app", "package_name": "com.academe.flutter", "sha256_cert_fingerprints": []any{cert}},
	}}
	if diff := cmp.Diff(want, got); diff != "" {
		t.Errorf("assetlinks mismatch (-want +got):\n%s", diff)
	}

	if err := RegisterRoutes(http.NewServeMux(), slog.New(slog.DiscardHandler), Options{AndroidCerts: []string{"not-a-cert"}}); err == nil {
		t.Errorf("RegisterRoutes(bad certificate) = nil, want an error")
	}
}
