package httpx_test

import (
	"compress/gzip"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
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

func TestGzip(t *testing.T) {
	body := strings.Repeat(`{"title":"Light"}`, 200)
	h := httpx.Gzip(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		httpx.WriteJSON(w, http.StatusOK, body)
	}))
	for _, tc := range []struct {
		name, accept string
		gzipped      bool
	}{
		{"gzip accepted", "gzip, deflate", true},
		{"plain client", "", false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			r := httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/study/decks", nil)
			r.Header.Set("Accept-Encoding", tc.accept)
			rec := httptest.NewRecorder()
			h.ServeHTTP(rec, r)
			var reader io.Reader = rec.Body
			if got := rec.Header().Get("Content-Encoding") == "gzip"; got != tc.gzipped {
				t.Fatalf("Content-Encoding = %q, want gzip %v", rec.Header().Get("Content-Encoding"), tc.gzipped)
			}
			if tc.gzipped {
				zr, err := gzip.NewReader(rec.Body)
				if err != nil {
					t.Fatal(err)
				}
				reader = zr
			}
			raw, err := io.ReadAll(reader)
			if err != nil || !strings.Contains(string(raw), "Light") || rec.Header().Get("Vary") != "Accept-Encoding" {
				t.Errorf("body = %d bytes, %v, Vary %q; want the JSON back and Vary set", len(raw), err, rec.Header().Get("Vary"))
			}
		})
	}
	noBody := httpx.Gzip(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) { w.WriteHeader(http.StatusNoContent) }))
	r := httptest.NewRequestWithContext(t.Context(), http.MethodPut, "/", nil)
	r.Header.Set("Accept-Encoding", "gzip")
	rec := httptest.NewRecorder()
	noBody.ServeHTTP(rec, r)
	if rec.Code != http.StatusNoContent || rec.Body.Len() != 0 || rec.Header().Get("Content-Encoding") != "" {
		t.Errorf("204 through Gzip = %d, %d bytes, encoding %q; want an empty uncompressed 204", rec.Code, rec.Body.Len(), rec.Header().Get("Content-Encoding"))
	}
}
