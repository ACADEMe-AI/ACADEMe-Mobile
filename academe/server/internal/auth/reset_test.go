package auth

import (
	"context"
	"encoding/json"
	"errors"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync"
	"testing"
	"testing/synctest"
	"time"

	"github.com/google/go-cmp/cmp"

	"academe/server/internal/email"
	"academe/server/internal/httpx"
)

type fakeMailer struct {
	mu       sync.Mutex
	sent     []email.Reset
	welcomed []email.Welcome
	down     bool
}

func (f *fakeMailer) SendWelcome(_ context.Context, w email.Welcome) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.welcomed = append(f.welcomed, w)
	return nil
}

func (f *fakeMailer) SendReset(_ context.Context, r email.Reset) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.down {
		return errors.New("mail provider down")
	}
	f.sent = append(f.sent, r)
	return nil
}

func (f *fakeMailer) last(t *testing.T) email.Reset {
	t.Helper()
	f.mu.Lock()
	defer f.mu.Unlock()
	if len(f.sent) == 0 {
		t.Fatal("no reset email sent")
	}
	return f.sent[len(f.sent)-1]
}

type resetEnv struct {
	handler http.Handler
	mailer  *fakeMailer
	service *Service
}

func newResetEnv(t *testing.T) resetEnv {
	t.Helper()
	logger := slog.New(slog.DiscardHandler)
	mailer := &fakeMailer{}
	mux := http.NewServeMux()
	service := NewService(newFakeStore(), []byte("0123456789abcdef0123456789abcdef"), testGoogle, mailer)
	RegisterRoutes(mux, logger, service)
	return resetEnv{handler: httpx.WithRequestID(mux), mailer: mailer, service: service}
}

func (e resetEnv) post(t *testing.T, path, body string) (int, map[string]any) {
	t.Helper()
	return e.postFrom(t, "192.0.2.1", path, body)
}

func (e resetEnv) postFrom(t *testing.T, ip, path, body string) (int, map[string]any) {
	t.Helper()
	req := httptest.NewRequestWithContext(t.Context(), http.MethodPost, path, strings.NewReader(body))
	req.RemoteAddr = ip + ":1234"
	rec := httptest.NewRecorder()
	e.handler.ServeHTTP(rec, req)
	var got map[string]any
	if rec.Body.Len() > 0 {
		if err := json.Unmarshal(rec.Body.Bytes(), &got); err != nil {
			t.Fatalf("POST %s: body %q is not JSON: %v", path, rec.Body, err)
		}
	}
	return rec.Code, got
}

func (e resetEnv) signUp(t *testing.T) (refresh string) {
	t.Helper()
	status, body := e.post(t, "/auth/sign-up", maya)
	if status != http.StatusCreated {
		t.Fatalf("sign-up = %d %v", status, body)
	}
	_, refresh = tokensOf(t, body)
	return refresh
}

func (e resetEnv) requestCode(t *testing.T) string {
	t.Helper()
	if status, body := e.post(t, "/auth/password-reset", `{"email":"maya.rao@example.com"}`); status != http.StatusAccepted {
		t.Fatalf("password-reset = %d %v, want 202", status, body)
	}
	return e.mailer.last(t).Code
}

func (e resetEnv) me(t *testing.T, access string) int {
	t.Helper()
	req := httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/me", nil)
	req.Header.Set("Authorization", "Bearer "+access)
	rec := httptest.NewRecorder()
	e.handler.ServeHTTP(rec, req)
	return rec.Code
}

func verifyBody(code string) string {
	return `{"email":"Maya.Rao@example.com","code":"` + code + `"}`
}

func completeBody(token, password string) string {
	return `{"resetToken":"` + token + `","password":"` + password + `"}`
}

func wrongCode(code string) string {
	n, _ := strconv.Atoi(code)
	return strconv.Itoa(100000 + (n+1)%900000)
}

func TestPasswordResetFlow(t *testing.T) {
	e := newResetEnv(t)
	oldRefresh := e.signUp(t)
	_, body := e.post(t, "/auth/log-in", `{"email":"maya.rao@example.com","password":"sunflower"}`)
	oldAccess, otherRefresh := tokensOf(t, body)
	if got := e.me(t, oldAccess); got != http.StatusOK {
		t.Fatalf("GET /me before the reset = %d, want 200", got)
	}

	code := e.requestCode(t)
	if len(code) != 6 || strings.Trim(code, "0123456789") != "" {
		t.Fatalf("emailed code = %q, want 6 digits", code)
	}
	if got := e.mailer.last(t); got.To != "maya.rao@example.com" || got.AccountID != "account-1" || got.GoogleOnly {
		t.Errorf("email = %+v, want a code to maya.rao@example.com", got)
	}

	if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(wrongCode(code))); status != 422 || errorCode(body) != "wrong_code" {
		t.Errorf("verify with a wrong code = %d %q, want 422 wrong_code", status, errorCode(body))
	}
	status, body := e.post(t, "/auth/password-reset/verify", verifyBody(code[:3]+" "+code[3:]))
	if status != http.StatusOK || body["expiresIn"] != float64(900) {
		t.Fatalf("verify = %d %v, want 200 with a reset token", status, body)
	}
	token := body["resetToken"].(string)
	if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(code)); status != http.StatusGone || errorCode(body) != "code_expired" {
		t.Errorf("verify a used code = %d %q, want 410 code_expired", status, errorCode(body))
	}

	if status, body := e.post(t, "/auth/password-reset/complete", completeBody(token, "short")); status != 422 || errorCode(body) != "invalid_password" {
		t.Errorf("complete with a short password = %d %q, want 422 invalid_password", status, errorCode(body))
	}
	status, body = e.post(t, "/auth/password-reset/complete", completeBody(token, "moonflower"))
	if status != http.StatusOK || body["account"].(map[string]any)["email"] != "maya.rao@example.com" {
		t.Fatalf("complete = %d %v, want 200 signed in as Maya", status, body)
	}
	access, _ := tokensOf(t, body)
	if status, _ := e.postFrom(t, "192.0.2.1", "/auth/password-reset/complete", completeBody(token, "moonflower2")); status != http.StatusGone {
		t.Errorf("complete twice with one token = %d, want 410", status)
	}

	for _, refresh := range []string{oldRefresh, otherRefresh} {
		if status, body := e.post(t, "/auth/refresh", `{"refreshToken":"`+refresh+`"}`); status != http.StatusUnauthorized || errorCode(body) != "invalid_token" {
			t.Errorf("refresh with a pre-reset session = %d %q, want 401 invalid_token", status, errorCode(body))
		}
	}
	if status, _ := e.post(t, "/auth/log-in", `{"email":"maya.rao@example.com","password":"sunflower"}`); status != http.StatusUnauthorized {
		t.Errorf("log-in with the old password = %d, want 401", status)
	}
	if status, _ := e.post(t, "/auth/log-in", `{"email":"maya.rao@example.com","password":"moonflower"}`); status != http.StatusOK {
		t.Errorf("log-in with the new password = %d, want 200", status)
	}
	if got := e.me(t, oldAccess); got != http.StatusUnauthorized {
		t.Errorf("GET /me with a pre-reset access token = %d, want 401", got)
	}
	if got := e.me(t, access); got != http.StatusOK {
		t.Errorf("GET /me with the access token from complete = %d, want 200", got)
	}
}

func TestPasswordResetIsEnumerationSafe(t *testing.T) {
	e := newResetEnv(t)
	e.signUp(t)
	e.post(t, "/auth/google", `{"idToken":"new-student"}`)

	var want map[string]any
	for i, address := range []string{"maya.rao@example.com", "nobody@example.com", "ada@gmail.com", "not an email"} {
		status, body := e.post(t, "/auth/password-reset", `{"email":"`+address+`"}`)
		if status != http.StatusAccepted {
			t.Errorf("password-reset %q = %d, want 202", address, status)
		}
		if i == 0 {
			want = body
		} else if diff := cmp.Diff(want, body); diff != "" {
			t.Errorf("password-reset %q body differs (-maya +got):\n%s", address, diff)
		}
	}
	want2 := []email.Reset{
		{AccountID: "account-1", To: "maya.rao@example.com", Code: e.mailer.sent[0].Code, LinkToken: e.mailer.sent[0].LinkToken},
		{AccountID: "account-2", To: "ada@gmail.com", GoogleOnly: true},
	}
	if diff := cmp.Diff(want2, e.mailer.sent); diff != "" {
		t.Errorf("emails sent (-want +got):\n%s", diff)
	}
	if status, body := e.post(t, "/auth/password-reset/verify", `{"email":"nobody@example.com","code":"123456"}`); status != http.StatusGone || errorCode(body) != "code_expired" {
		t.Errorf("verify for an unknown email = %d %q, want 410 code_expired", status, errorCode(body))
	}
}

func TestPasswordResetThrottle(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		e := newResetEnv(t)
		e.signUp(t)
		request := `{"email":"maya.rao@example.com"}`
		for i := range 3 {
			if status, _ := e.post(t, "/auth/password-reset", request); status != http.StatusAccepted {
				t.Fatalf("request %d = %d, want 202", i+1, status)
			}
		}
		if status, body := e.postFrom(t, "198.51.100.7", "/auth/password-reset", request); status != http.StatusTooManyRequests || errorCode(body) != "too_many_requests" {
			t.Errorf("4th request in an hour = %d %q, want 429 too_many_requests", status, errorCode(body))
		}
		if len(e.mailer.sent) != 3 {
			t.Errorf("emails sent = %d, want 3", len(e.mailer.sent))
		}

		for i := range 7 {
			e.postFrom(t, "192.0.2.1", "/auth/password-reset", `{"email":"x`+strconv.Itoa(i)+`@example.com"}`)
		}
		if status, _ := e.postFrom(t, "192.0.2.1", "/auth/password-reset", `{"email":"y@example.com"}`); status != http.StatusTooManyRequests {
			t.Errorf("11th request from one IP = %d, want 429", status)
		}

		time.Sleep(time.Hour)
		if status, _ := e.post(t, "/auth/password-reset", request); status != http.StatusAccepted {
			t.Errorf("request an hour later = %d, want 202", status)
		}
	})
}

func TestPasswordResetAttempts(t *testing.T) {
	e := newResetEnv(t)
	e.signUp(t)
	first := e.requestCode(t)
	code := e.requestCode(t)
	if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(first)); first != code && (status != 422 || errorCode(body) != "wrong_code") {
		t.Errorf("verify a replaced code = %d %q, want 422 wrong_code", status, errorCode(body))
	}
	for i := 2; i <= 5; i++ {
		want := "wrong_code"
		if i == 5 {
			want = "too_many_attempts"
		}
		if _, body := e.post(t, "/auth/password-reset/verify", verifyBody(wrongCode(code))); errorCode(body) != want {
			t.Errorf("wrong attempt %d = %q, want %q", i, errorCode(body), want)
		}
	}
	if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(code)); status != http.StatusTooManyRequests || errorCode(body) != "too_many_attempts" {
		t.Errorf("right code after 5 wrong = %d %q, want 429 too_many_attempts", status, errorCode(body))
	}
	fresh := e.requestCode(t)
	if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(fresh)); status != http.StatusOK {
		t.Errorf("verify a new code = %d %v, want 200", status, body)
	}
}

func TestPasswordResetExpiry(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		e := newResetEnv(t)
		e.signUp(t)
		code := e.requestCode(t)
		time.Sleep(resetCodeTTL)
		if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(code)); status != http.StatusGone || errorCode(body) != "code_expired" {
			t.Errorf("verify after 15 minutes = %d %q, want 410 code_expired", status, errorCode(body))
		}

		code = e.requestCode(t)
		time.Sleep(resetCodeTTL - time.Second)
		_, body := e.post(t, "/auth/password-reset/verify", verifyBody(code))
		token, _ := body["resetToken"].(string)
		if token == "" {
			t.Fatalf("verify just in time = %v, want a token", body)
		}
		time.Sleep(resetTokenTTL)
		if status, body := e.post(t, "/auth/password-reset/complete", completeBody(token, "moonflower")); status != http.StatusGone || errorCode(body) != "reset_expired" {
			t.Errorf("complete after the token expired = %d %q, want 410 reset_expired", status, errorCode(body))
		}
	})
}

func TestResetStillAcceptedWhenMailFails(t *testing.T) {
	env := newResetEnv(t)
	env.signUp(t)
	env.mailer.mu.Lock()
	env.mailer.down = true
	env.mailer.mu.Unlock()
	for _, address := range []string{"maya.rao@example.com", "nobody@example.com"} {
		status, body := env.post(t, "/auth/password-reset", `{"email":"`+address+`"}`)
		if status != http.StatusAccepted {
			t.Errorf("POST /auth/password-reset %s with mail down = %d %v, want 202", address, status, body)
		}
	}
}
