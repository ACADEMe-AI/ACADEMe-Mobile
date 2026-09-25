package auth

import (
	"bytes"
	"errors"
	"testing"
	"time"
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
	if err := store.CreateResetCode(ctx, maya.ID, []byte("first"), expires); err != nil {
		t.Fatalf("CreateResetCode = %v", err)
	}
	if err := store.CreateResetCode(ctx, maya.ID, []byte("second"), expires); err != nil {
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

	if err := store.CreateResetCode(ctx, maya.ID, []byte("third"), expires); err != nil {
		t.Fatal(err)
	}
	third, err := store.ClaimResetAttempt(ctx, maya.ID)
	if err != nil {
		t.Fatal(err)
	}
	if err := store.MarkResetCodeUsed(ctx, third.ID, hashToken("linked"), time.Now()); err != nil {
		t.Fatal(err)
	}
	if err := store.LinkGoogle(ctx, maya.ID, "g-maya", time.Now()); err != nil {
		t.Fatal(err)
	}
	if _, err := store.CompleteReset(ctx, hashToken("linked"), time.Now().Add(-resetTokenTTL), "hash", time.Now()); !errors.Is(err, ErrResetTokenExpired) {
		t.Errorf("CompleteReset after linking Google = %v, want ErrResetTokenExpired", err)
	}
}
