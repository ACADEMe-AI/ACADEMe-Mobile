package auth

import (
	"bytes"
	"errors"
	"testing"
	"time"

	"github.com/jackc/pgx/v5"
)

func TestPostgresStoreReset(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	ctx := t.Context()
	maya, err := store.CreateAccount(ctx, Account{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com"}, "old-hash")
	if err != nil {
		t.Fatal(err)
	}
	if err := store.CreateSession(ctx, maya.ID, hashToken("session"), time.Now().Add(time.Hour)); err != nil {
		t.Fatal(err)
	}
	if _, err := store.ClaimResetAttempt(ctx, maya.ID); !errors.Is(err, ErrCodeExpired) {
		t.Errorf("ClaimResetAttempt with no code = %v, want ErrCodeExpired", err)
	}

	expires := time.Now().Add(resetCodeTTL).Truncate(time.Microsecond)
	if err := store.CreateResetCode(ctx, maya.ID, []byte("first"), hashToken("link-first"), expires); err != nil {
		t.Fatalf("CreateResetCode = %v", err)
	}
	if err := store.CreateResetCode(ctx, maya.ID, []byte("second"), hashToken("link-second"), expires); err != nil {
		t.Fatalf("CreateResetCode = %v", err)
	}
	var code ResetCode
	for want := 1; want <= 2; want++ {
		code, err = store.ClaimResetAttempt(ctx, maya.ID)
		if err != nil || !bytes.Equal(code.Hash, []byte("second")) || code.Attempts != want || !code.Expires.Equal(expires) {
			t.Fatalf("ClaimResetAttempt = %+v, %v, want the second code at attempt %d expiring %v", code, err, want, expires)
		}
	}

	if err := store.MarkResetCodeUsed(ctx, code.ID, hashToken("reset"), time.Now()); err != nil {
		t.Fatalf("MarkResetCodeUsed = %v", err)
	}
	if err := store.MarkResetCodeUsed(ctx, code.ID, hashToken("again"), time.Now()); !errors.Is(err, ErrCodeExpired) {
		t.Errorf("MarkResetCodeUsed twice = %v, want ErrCodeExpired", err)
	}
	if _, err := store.ClaimResetAttempt(ctx, maya.ID); !errors.Is(err, ErrCodeExpired) {
		t.Errorf("ClaimResetAttempt after use = %v, want ErrCodeExpired", err)
	}

	if _, err := store.CompleteReset(ctx, hashToken("reset"), time.Now(), "new-hash", time.Now()); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("CompleteReset with a stale token = %v, want ErrResetTokenExpired", err)
	}
	if at, err := store.TokensValidAfter(ctx, maya.ID); err != nil || !at.Equal(time.Unix(0, 0)) {
		t.Errorf("TokensValidAfter before a reset = %v, %v, want the epoch", at, err)
	}
	resetAt := revocationTime()
	id, err := store.CompleteReset(ctx, hashToken("reset"), time.Now().Add(-resetTokenTTL), "new-hash", resetAt)
	if err != nil || id != maya.ID {
		t.Fatalf("CompleteReset = %q, %v, want %q", id, err, maya.ID)
	}
	if at, err := store.TokensValidAfter(ctx, maya.ID); err != nil || !at.Equal(resetAt) {
		t.Errorf("TokensValidAfter after a reset = %v, %v, want %v", at, err, resetAt)
	}
	if _, err := store.TokensValidAfter(ctx, "00000000-0000-0000-0000-000000000000"); !errors.Is(err, ErrNotFound) {
		t.Errorf("TokensValidAfter for a missing account = %v, want ErrNotFound", err)
	}
	if _, hash, _ := store.AccountByEmail(ctx, "maya@example.com"); hash != "new-hash" {
		t.Errorf("password hash after reset = %q, want new-hash", hash)
	}
	if _, err := store.RotateSession(ctx, hashToken("session"), hashToken("next"), time.Now().Add(time.Hour)); !errors.Is(err, ErrInvalidToken) {
		t.Errorf("RotateSession after reset = %v, want ErrInvalidToken", err)
	}
	if _, err := store.CompleteReset(ctx, hashToken("reset"), time.Now().Add(-resetTokenTTL), "newer-hash", time.Now()); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("CompleteReset twice = %v, want ErrResetTokenExpired", err)
	}

	if err := store.CreateResetCode(ctx, maya.ID, []byte("third"), hashToken("link-third"), expires); err != nil {
		t.Fatal(err)
	}
	third, err := store.ClaimResetAttempt(ctx, maya.ID)
	if err != nil {
		t.Fatal(err)
	}
	if err := store.MarkResetCodeUsed(ctx, third.ID, hashToken("linked"), time.Now()); err != nil {
		t.Fatal(err)
	}
	if err := store.LinkGoogle(ctx, maya.ID, "g-maya", "maya@example.com", time.Now()); err != nil {
		t.Fatal(err)
	}
	if _, err := store.CompleteReset(ctx, hashToken("linked"), time.Now().Add(-resetTokenTTL), "hash", time.Now()); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("CompleteReset after linking Google = %v, want ErrResetTokenExpired", err)
	}
}

func TestPurgeExpiredSessionsAndResetCodes(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()
	a, err := store.CreateAccount(ctx, Account{FirstName: "M", LastName: "R", Email: "m@example.com"}, "hash")
	if err != nil {
		t.Fatal(err)
	}
	now := time.Now()
	for hash, expires := range map[string]time.Time{"live": now.Add(time.Hour), "dead": now.Add(-time.Minute)} {
		if err := store.CreateSession(ctx, a.ID, []byte(hash), expires); err != nil {
			t.Fatal(err)
		}
	}
	for link, expires := range map[string]time.Time{"recent": now.Add(-time.Hour), "old": now.Add(-resetRowsKept - time.Hour)} {
		if _, err := pool.Exec(ctx, `
			INSERT INTO password_reset_codes (account_id, code_hash, link_hash, expires_at)
			VALUES ($1, 'c', $2, $3)`, a.ID, []byte(link), expires); err != nil {
			t.Fatal(err)
		}
	}

	if err := store.PurgeExpired(ctx, now); err != nil {
		t.Fatalf("PurgeExpired() = %v", err)
	}

	var sessions, codes []string
	for query, dst := range map[string]*[]string{
		"SELECT convert_from(token_hash, 'UTF8') FROM sessions":            &sessions,
		"SELECT convert_from(link_hash, 'UTF8') FROM password_reset_codes": &codes,
	} {
		rows, err := pool.Query(ctx, query)
		if err != nil {
			t.Fatal(err)
		}
		if *dst, err = pgx.CollectRows(rows, pgx.RowTo[string]); err != nil {
			t.Fatal(err)
		}
	}
	if len(sessions) != 1 || sessions[0] != "live" || len(codes) != 1 || codes[0] != "recent" {
		t.Errorf("after PurgeExpired sessions = %v, reset codes = %v; want [live], [recent]", sessions, codes)
	}
}
