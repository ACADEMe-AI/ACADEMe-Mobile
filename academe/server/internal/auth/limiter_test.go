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

func TestLimiterSweepIsAmortised(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		l := newLimiter(1, time.Hour)
		for i := range limiterSweepSize + 1 {
			l.allow(strconv.Itoa(i))
		}
		l.allow("trigger")
		if want := 2 * (limiterSweepSize + 1); l.sweepAt != want {
			t.Errorf("sweepAt after a sweep of live keys = %d, want %d", l.sweepAt, want)
		}
		time.Sleep(time.Hour)
		for i := range l.sweepAt + 1 - len(l.hits) {
			l.allow("late-" + strconv.Itoa(i))
		}
		l.allow("after")
		if _, ok := l.hits["0"]; ok || len(l.hits) > l.sweepAt {
			t.Errorf("stale key kept after an hour and a sweep (keys %d, sweepAt %d)", len(l.hits), l.sweepAt)
		}
	})
}

func TestResetIgnoresOverlongEmails(t *testing.T) {
	e := newResetEnv(t)
	long := strings.Repeat("a", 60<<10) + "@example.com"
	for i := range 5 {
		if status, _ := e.post(t, "/auth/password-reset", `{"email":"`+long+`"}`); status != 202 {
			t.Fatalf("overlong request %d = %d, want 202", i+1, status)
		}
	}
	if n := len(e.service.limits.perEmail.hits); n != 0 {
		t.Errorf("per-email limiter keys after overlong emails = %d, want 0", n)
	}
}

func TestClientIPGroupsIPv6By64(t *testing.T) {
	cases := []struct{ remote, want string }{
		{"203.0.113.9:4000", "203.0.113.9"},
		{"[::ffff:203.0.113.9]:4000", "203.0.113.9"},
		{"[2001:db8:1:2:aaaa::1]:4000", "2001:db8:1:2::/64"},
		{"[2001:db8:1:2:bbbb::9]:4000", "2001:db8:1:2::/64"},
		{"garbage", "garbage"},
	}
	for _, tc := range cases {
		r := httptest.NewRequestWithContext(t.Context(), http.MethodPost, "/", nil)
		r.RemoteAddr = tc.remote
		if got := clientIP(r); got != tc.want {
			t.Errorf("clientIP(%q) = %q, want %q", tc.remote, got, tc.want)
		}
	}
}
