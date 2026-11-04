package auth

import (
	"context"
	"encoding/base64"
	"errors"
	"log/slog"
	"net/http"
	"strconv"
	"strings"
	"testing"
	"testing/synctest"
	"time"

	"github.com/google/go-cmp/cmp"
	"github.com/google/go-cmp/cmp/cmpopts"

	"academe/server/internal/email"
	"academe/server/internal/httpx"
)

func linkBody(link string) string { return `{"linkToken":"` + link + `"}` }

func (e resetEnv) requestLink(t *testing.T) (code, link string) {
	t.Helper()
	code = e.requestCode(t)
	return code, e.mailer.last(t).LinkToken
}

func TestResetLinkFlow(t *testing.T) {
	e := newResetEnv(t)
	oldRefresh := e.signUp(t)
	code, link := e.requestLink(t)
	if raw, err := base64.RawURLEncoding.DecodeString(link); err != nil || len(raw) != 16 {
		t.Fatalf("emailed link token %q decodes to %d bytes (%v), want 16", link, len(raw), err)
	}

	status, body := e.post(t, "/auth/password-reset/link", linkBody(link))
	if status != http.StatusOK || body["expiresIn"] != float64(900) || body["resetToken"] == "" {
		t.Fatalf("link = %d %v, want 200 with a reset token", status, body)
	}
	token := body["resetToken"].(string)
	if status, body := e.post(t, "/auth/password-reset/link", linkBody(link)); status != http.StatusGone || errorCode(body) != "reset_expired" {
		t.Errorf("link used twice = %d %q, want 410 reset_expired", status, errorCode(body))
	}
	if status, body := e.post(t, "/auth/password-reset/verify", verifyBody(code)); status != http.StatusGone || errorCode(body) != "code_expired" {
		t.Errorf("verify the code after its link was used = %d %q, want 410 code_expired", status, errorCode(body))
	}
	if status, _ := e.post(t, "/auth/password-reset/complete", completeBody(token, "moonflower")); status != http.StatusOK {
		t.Fatalf("complete with the link's reset token = %d, want 200", status)
	}
	if status, _ := e.post(t, "/auth/refresh", `{"refreshToken":"`+oldRefresh+`"}`); status != http.StatusUnauthorized {
		t.Errorf("refresh with a pre-reset session = %d, want 401", status)
	}
}

func TestResetLinkRejects(t *testing.T) {
	e := newResetEnv(t)
	e.signUp(t)
	_, first := e.requestLink(t)
	code, second := e.requestLink(t)
	tests := []struct {
		name, link string
		wrongCodes int
		status     int
		code       string
	}{
		{"unknown", "AAAAAAAAAAAAAAAAAAAAAA", 0, http.StatusGone, "reset_expired"},
		{"empty", "", 0, http.StatusGone, "reset_expired"},
		{"overlong", strings.Repeat("a", maxLinkTokenLength+1), 0, http.StatusGone, "reset_expired"},
		{"replaced by a newer email", first, 0, http.StatusGone, "reset_expired"},
		{"code burned by wrong guesses", second, maxResetAttempts, http.StatusTooManyRequests, "too_many_attempts"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			for range tc.wrongCodes {
				e.post(t, "/auth/password-reset/verify", verifyBody(wrongCode(code)))
			}
			status, body := e.post(t, "/auth/password-reset/link", linkBody(tc.link))
			if status != tc.status || errorCode(body) != tc.code {
				t.Errorf("link %q = %d %q, want %d %q", tc.link, status, errorCode(body), tc.status, tc.code)
			}
		})
	}
}

func TestResetLinkExpiresAndIsThrottled(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		e := newResetEnv(t)
		e.signUp(t)
		_, link := e.requestLink(t)
		time.Sleep(resetCodeTTL)
		if status, body := e.post(t, "/auth/password-reset/link", linkBody(link)); status != http.StatusGone || errorCode(body) != "reset_expired" {
			t.Errorf("link after 15 minutes = %d %q, want 410 reset_expired", status, errorCode(body))
		}

		for i := range verifiesPerIPHour {
			e.postFrom(t, "198.51.100.7", "/auth/password-reset/link", linkBody("guess"+strconv.Itoa(i)))
		}
		if status, body := e.postFrom(t, "198.51.100.7", "/auth/password-reset/link", linkBody(link)); status != http.StatusTooManyRequests || errorCode(body) != "too_many_requests" {
			t.Errorf("link after %d guesses = %d %q, want 429 too_many_requests", verifiesPerIPHour, status, errorCode(body))
		}
	})
}

func TestResetWithLink(t *testing.T) {
	e := newResetEnv(t)
	oldRefresh := e.signUp(t)
	_, link := e.requestLink(t)
	ctx := t.Context()

	var invalid *ValidationError
	if err := e.service.ResetWithLink(ctx, link, "short", "192.0.2.9"); !errors.As(err, &invalid) {
		t.Fatalf("ResetWithLink(weak password) = %v, want a ValidationError", err)
	}
	if err := e.service.ResetWithLink(ctx, link, "moonflower", "192.0.2.9"); err != nil {
		t.Fatalf("ResetWithLink() = %v, want nil after a weak password left the link unused", err)
	}
	if err := e.service.ResetWithLink(ctx, link, "moonflower2", "192.0.2.9"); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("ResetWithLink() twice = %v, want ErrResetTokenExpired", err)
	}
	if status, _ := e.post(t, "/auth/refresh", `{"refreshToken":"`+oldRefresh+`"}`); status != http.StatusUnauthorized {
		t.Errorf("refresh after a web reset = %d, want 401", status)
	}
	if status, _ := e.post(t, "/auth/log-in", `{"email":"maya.rao@example.com","password":"moonflower"}`); status != http.StatusOK {
		t.Errorf("log-in with the new password = %d, want 200", status)
	}
}

func TestWelcomeEmail(t *testing.T) {
	e := newResetEnv(t)
	e.signUp(t)
	e.post(t, "/auth/google", `{"idToken":"new-student"}`)
	e.post(t, "/auth/google", `{"idToken":"new-student"}`)
	e.post(t, "/auth/log-in", `{"email":"maya.rao@example.com","password":"sunflower"}`)
	e.service.Wait()

	want := []email.Welcome{
		{AccountID: "account-1", To: "maya.rao@example.com", FirstName: "Maya"},
		{AccountID: "account-2", To: "ada@gmail.com", FirstName: "Ada"},
	}
	e.mailer.mu.Lock()
	defer e.mailer.mu.Unlock()
	if diff := cmp.Diff(want, e.mailer.welcomed, cmpopts.SortSlices(func(a, b email.Welcome) bool { return a.AccountID < b.AccountID })); diff != "" {
		t.Errorf("welcome emails mismatch (-want +got):\n%s", diff)
	}
}

func TestPostgresStoreResetLink(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	ctx := t.Context()
	maya, err := store.CreateAccount(ctx, Account{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com"}, "hash")
	if err != nil {
		t.Fatal(err)
	}
	expires := time.Now().Add(resetCodeTTL).Truncate(time.Microsecond)
	if err := store.CreateResetCode(ctx, maya.ID, []byte("code"), hashToken("link"), expires); err != nil {
		t.Fatal(err)
	}
	if _, err := store.ClaimResetLink(ctx, hashToken("other")); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("ClaimResetLink(unknown) = %v, want ErrResetTokenExpired", err)
	}
	if _, err := store.ClaimResetAttempt(ctx, maya.ID); err != nil {
		t.Fatal(err)
	}
	got, err := store.ClaimResetLink(ctx, hashToken("link"))
	if err != nil || got.Attempts != 2 || !got.Expires.Equal(expires) {
		t.Fatalf("ClaimResetLink = %+v, %v, want attempt 2 shared with the code", got, err)
	}
	if err := store.MarkResetCodeUsed(ctx, got.ID, hashToken("reset"), time.Now()); err != nil {
		t.Fatal(err)
	}
	if _, err := store.ClaimResetLink(ctx, hashToken("link")); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("ClaimResetLink after use = %v, want ErrResetTokenExpired", err)
	}
	var stored []byte
	if err := store.pool.QueryRow(ctx, "SELECT link_hash FROM password_reset_codes WHERE id = $1", got.ID).Scan(&stored); err != nil || !cmp.Equal(stored, hashToken("link")) {
		t.Errorf("stored link_hash = %x, %v, want the SHA-256 of the link, never the link", stored, err)
	}
}

type hangingMailer struct{ fakeMailer }

func (h *hangingMailer) SendWelcome(ctx context.Context, _ email.Welcome) error {
	<-ctx.Done()
	return ctx.Err()
}

func TestWelcomeEmailNeverBlocksSignUp(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		s := NewService(newFakeStore(), []byte("0123456789abcdef0123456789abcdef"), testGoogle, &hangingMailer{})
		mux := http.NewServeMux()
		RegisterRoutes(mux, slog.New(slog.DiscardHandler), s)
		e := resetEnv{handler: httpx.WithRequestID(mux), service: s}
		start := time.Now()
		e.signUp(t)
		if waited := time.Since(start); waited != 0 {
			t.Errorf("sign-up waited %v for a hanging mail provider, want 0", waited)
		}
		s.Wait()
		if waited := time.Since(start); waited != welcomeTimeout {
			t.Errorf("Wait() returned after %v, want the %v send timeout", waited, welcomeTimeout)
		}
	})
}
