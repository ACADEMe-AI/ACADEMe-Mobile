package httpx_test

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"academe/server/internal/httpx"
)

func TestTrustClientIP(t *testing.T) {
	tests := []struct {
		name   string
		header string
		value  string
		want   string
	}{
		{"untrusted header ignored", "", "203.0.113.7", "192.0.2.1:1234"},
		{"trusted ipv4", "X-Real-IP", "203.0.113.7", "203.0.113.7:0"},
		{"trusted ipv6", "X-Real-IP", "2001:db8::1", "[2001:db8::1]:0"},
		{"garbage kept", "X-Real-IP", "not-an-ip", "192.0.2.1:1234"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			var got string
			h := httpx.TrustClientIP(tt.header, http.HandlerFunc(func(_ http.ResponseWriter, r *http.Request) {
				got = r.RemoteAddr
			}))
			r := httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/", nil)
			r.RemoteAddr = "192.0.2.1:1234"
			r.Header.Set("X-Real-IP", tt.value)
			h.ServeHTTP(httptest.NewRecorder(), r)
			if got != tt.want {
				t.Errorf("RemoteAddr = %q, want %q", got, tt.want)
			}
		})
	}
}
