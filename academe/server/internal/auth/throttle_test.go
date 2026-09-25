package auth

import (
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"
	"testing/synctest"
	"time"
)

func postWithHeaders(t *testing.T, h http.Handler, ip, path, body string) (int, string, string) {
	t.Helper()
	req := httptest.NewRequestWithContext(t.Context(), http.MethodPost, path, strings.NewReader(body))
	req.RemoteAddr = ip + ":1234"
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	return rec.Code, rec.Header().Get("Retry-After"), rec.Body.String()
}

func TestEntryRateLimits(t *testing.T) {
	logIn := func(email string) string {
		return `{"email":"` + email + `","password":"wrong-password"}`
	}
	signUp := func(i int) string {
		return `{"firstName":"Maya","lastName":"Rao","email":"maya` + strconv.Itoa(i) + `@example.com","password":"sunflower"}`
	}
	tests := []struct {
		name       string
		path       string
		allowed    int
		body       func(i int) string
		retryAfter time.Duration
		reset      time.Duration
	}{
		{"log-in per email and IP", "/auth/log-in", logInsPerEmailIP,
			func(int) string { return logIn("Maya@Example.com") }, logInEmailIPWindow, logInEmailIPWindow},
		{"log-in per IP", "/auth/log-in", logInsPerIPHour,
			func(i int) string { return logIn("s" + strconv.Itoa(i) + "@example.com") }, time.Hour, time.Hour},
		{"sign-up per IP", "/auth/sign-up", signUpsPerIPHour, signUp, time.Hour, time.Hour},
		{"google per IP", "/auth/google", googlePerIPHour,
			func(int) string { return `{"idToken":"nobody"}` }, time.Hour, time.Hour},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			synctest.Test(t, func(t *testing.T) {
				e := newResetEnv(t)
				for i := range tc.allowed {
					if status, _, _ := postWithHeaders(t, e.handler, "203.0.113.5", tc.path, tc.body(i)); status == http.StatusTooManyRequests {
						t.Fatalf("POST %s #%d = 429, want it allowed", tc.path, i+1)
					}
				}
				status, retry, body := postWithHeaders(t, e.handler, "203.0.113.5", tc.path, tc.body(tc.allowed))
				if want := strconv.Itoa(int(tc.retryAfter.Seconds())); status != http.StatusTooManyRequests || retry != want || !strings.Contains(body, `"too_many_requests"`) {
					t.Errorf("POST %s #%d = %d, Retry-After %q, %s; want 429 too_many_requests, Retry-After %s", tc.path, tc.allowed+1, status, retry, body, want)
				}
				if status, _, _ := postWithHeaders(t, e.handler, "198.51.100.9", tc.path, tc.body(tc.allowed+1)); status == http.StatusTooManyRequests {
					t.Errorf("POST %s from another IP = 429, want it allowed", tc.path)
				}
				time.Sleep(tc.reset)
				if status, _, _ := postWithHeaders(t, e.handler, "203.0.113.5", tc.path, tc.body(tc.allowed+2)); status == http.StatusTooManyRequests {
					t.Errorf("POST %s after %v = 429, want it allowed", tc.path, tc.reset)
				}
			})
		})
	}
}

func TestLimiterWaitCountsDownToTheOldestHit(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		l := newLimiter(2, time.Hour)
		l.wait("k")
		time.Sleep(10 * time.Minute)
		l.wait("k")
		if got := l.wait("k"); got != 50*time.Minute {
			t.Errorf("wait after 2 of 2 hits = %v, want 50m", got)
		}
	})
}
