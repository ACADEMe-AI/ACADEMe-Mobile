package email

import (
	"bytes"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestResendSendsTheCode(t *testing.T) {
	var got resendRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost || r.Header.Get("Authorization") != "Bearer re_test" {
			t.Errorf("request = %s with auth %q, want POST with Bearer re_test", r.Method, r.Header.Get("Authorization"))
		}
		if err := json.NewDecoder(r.Body).Decode(&got); err != nil {
			t.Error(err)
		}
		_, _ = w.Write([]byte(`{"id":"e1"}`))
	}))
	t.Cleanup(srv.Close)
	c := NewResend("re_test", DefaultFrom, srv.Client())
	c.URL = srv.URL

	if err := c.SendReset(t.Context(), Reset{AccountID: "a1", To: "maya@example.com", Code: "042917"}); err != nil {
		t.Fatalf("SendReset() = %v, want nil", err)
	}
	if got.From != DefaultFrom || len(got.To) != 1 || got.To[0] != "maya@example.com" {
		t.Errorf("from/to = %q %v, want %q [maya@example.com]", got.From, got.To, DefaultFrom)
	}
	if got.Subject != "Your ACADEMe code is 042917" {
		t.Errorf("subject = %q", got.Subject)
	}
	for _, want := range []string{"042917", "15 minutes", "ignore this email"} {
		if !strings.Contains(got.Text, want) {
			t.Errorf("text %q does not contain %q", got.Text, want)
		}
	}
	for _, want := range []string{">0<", ">4<", ">7<", "#564CF1", "15 minutes"} {
		if !strings.Contains(got.HTML, want) {
			t.Errorf("html does not contain %q", want)
		}
	}
}

func TestResendGoogleOnly(t *testing.T) {
	var got resendRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_ = json.NewDecoder(r.Body).Decode(&got)
	}))
	t.Cleanup(srv.Close)
	c := NewResend("k", "Test <t@academe.cc>", srv.Client())
	c.URL = srv.URL
	if err := c.SendReset(t.Context(), Reset{To: "ada@gmail.com", GoogleOnly: true}); err != nil {
		t.Fatalf("SendReset() = %v", err)
	}
	if !strings.Contains(got.HTML, "Continue with Google") || !strings.Contains(got.Text, "Continue with Google") {
		t.Errorf("google-only email does not mention Continue with Google: %q", got.Text)
	}
	if strings.Contains(got.Text, "expires") {
		t.Errorf("google-only email mentions a code: %q", got.Text)
	}
}

func TestResendRejected(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, `{"message":"domain not verified"}`, http.StatusForbidden)
	}))
	t.Cleanup(srv.Close)
	c := NewResend("k", DefaultFrom, srv.Client())
	c.URL = srv.URL
	err := c.SendReset(t.Context(), Reset{To: "a@b.co", Code: "123456"})
	if err == nil || !strings.Contains(err.Error(), "403") {
		t.Errorf("SendReset() = %v, want a 403 error", err)
	}
}

func TestLogShowsTheCodeOnlyInDev(t *testing.T) {
	for _, show := range []bool{false, true} {
		var buf bytes.Buffer
		l := Log{Logger: slog.New(slog.NewJSONHandler(&buf, nil)), ShowCode: show}
		if err := l.SendReset(t.Context(), Reset{AccountID: "a1", To: "maya@example.com", Code: "123456"}); err != nil {
			t.Fatal(err)
		}
		line := buf.String()
		if !strings.Contains(line, "reset code sent") || !strings.Contains(line, "a1") || strings.Contains(line, "maya@example.com") {
			t.Errorf("log line = %s, want the account ID and no email", line)
		}
		if strings.Contains(line, "123456") != show {
			t.Errorf("ShowCode=%v: log line = %s", show, line)
		}
	}
}
