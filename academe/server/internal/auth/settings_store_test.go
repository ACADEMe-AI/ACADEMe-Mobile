package auth

import (
	"errors"
	"slices"
	"strconv"
	"testing"
	"time"
)

func TestPostgresStoreAccountSettings(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	ctx := t.Context()

	maya, err := store.CreateAccount(ctx, Account{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com"}, "old")
	if err != nil {
		t.Fatal(err)
	}
	ada, err := store.CreateGoogleAccount(ctx, Account{FirstName: "Ada", Email: "ada@gmail.com"}, "g-ada")
	if err != nil {
		t.Fatal(err)
	}
	if !maya.HasPassword || maya.GoogleEmail != "" {
		t.Errorf("CreateAccount = %+v, want a password and no Google", maya)
	}
	if ada.HasPassword || ada.GoogleEmail != "ada@gmail.com" {
		t.Errorf("CreateGoogleAccount = %+v, want no password and Google ada@gmail.com", ada)
	}

	if hash, err := store.PasswordHash(ctx, ada.ID); err != nil || hash != "" {
		t.Errorf("PasswordHash(google-only) = %q, %v, want empty", hash, err)
	}
	if err := store.RemoveGoogle(ctx, ada.ID); !errors.Is(err, ErrPasswordRequired) {
		t.Errorf("RemoveGoogle(google-only) = %v, want ErrPasswordRequired", err)
	}
	if got, _ := store.AccountByID(ctx, ada.ID); got.GoogleEmail != "ada@gmail.com" {
		t.Errorf("Google after a refused RemoveGoogle = %q, want kept", got.GoogleEmail)
	}

	if err := store.AddGoogle(ctx, maya.ID, "g-ada", "ada@gmail.com"); !errors.Is(err, ErrGoogleTaken) {
		t.Errorf("AddGoogle(someone else's Google) = %v, want ErrGoogleTaken", err)
	}
	if err := store.AddGoogle(ctx, maya.ID, "g-maya", "maya.rao@gmail.com"); err != nil {
		t.Fatalf("AddGoogle = %v", err)
	}
	got, err := store.AccountByGoogleSubject(ctx, "g-maya")
	if err != nil || got.ID != maya.ID || got.GoogleEmail != "maya.rao@gmail.com" || !got.HasPassword {
		t.Errorf("AccountByGoogleSubject after AddGoogle = %+v, %v, want Maya with her password kept", got, err)
	}
	if err := store.RemoveGoogle(ctx, maya.ID); err != nil {
		t.Fatalf("RemoveGoogle = %v", err)
	}
	if _, err := store.AccountByGoogleSubject(ctx, "g-maya"); !errors.Is(err, ErrNotFound) {
		t.Errorf("AccountByGoogleSubject after RemoveGoogle = %v, want ErrNotFound", err)
	}

	later := time.Now().Add(time.Hour)
	if err := store.CreateSession(ctx, maya.ID, hashToken("phone"), later); err != nil {
		t.Fatal(err)
	}
	at := revocationTime()
	if err := store.ChangePassword(ctx, maya.ID, "stale", "new", at); !errors.Is(err, ErrWrongPassword) {
		t.Errorf("ChangePassword with a stale hash = %v, want ErrWrongPassword", err)
	}
	if err := store.ChangePassword(ctx, maya.ID, "old", "new", at); err != nil {
		t.Fatalf("ChangePassword = %v", err)
	}
	if hash, _ := store.PasswordHash(ctx, maya.ID); hash != "new" {
		t.Errorf("PasswordHash after ChangePassword = %q, want new", hash)
	}
	if validAfter, _ := store.TokensValidAfter(ctx, maya.ID); !validAfter.Equal(at) {
		t.Errorf("TokensValidAfter after ChangePassword = %v, want %v", validAfter, at)
	}
	if _, err := store.RotateSession(ctx, hashToken("phone"), hashToken("next"), later); !errors.Is(err, ErrInvalidToken) {
		t.Errorf("RotateSession after ChangePassword = %v, want ErrInvalidToken", err)
	}

	if err := store.ChangePassword(ctx, ada.ID, "", "first", at); err != nil {
		t.Fatalf("ChangePassword(google-only) = %v", err)
	}
	if got, _ := store.AccountByID(ctx, ada.ID); !got.HasPassword {
		t.Errorf("AccountByID after setting a password = %+v, want HasPassword", got)
	}
	if _, err := store.PasswordHash(ctx, "00000000-0000-0000-0000-000000000000"); !errors.Is(err, ErrNotFound) {
		t.Errorf("PasswordHash(unknown) = %v, want ErrNotFound", err)
	}
}

func TestChangePasswordRacesPostgres(t *testing.T) {
	s := NewService(NewPostgresStore(openTestPool(t)), []byte("0123456789abcdef0123456789abcdef"), nil, &fakeMailer{})
	ctx := t.Context()
	a, _, err := s.SignUp(ctx, SignUpInput{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com", Password: "sunflower"})
	if err != nil {
		t.Fatal(err)
	}
	errs := parallel(passwordChecksPerHour, func(i int) error {
		_, _, err := s.ChangePassword(ctx, a.ID, "sunflower", "marigold"+strconv.Itoa(i))
		return err
	})
	if got := count(errs, nil); got != 1 {
		t.Fatalf("%d parallel changes: %d succeeded (%v), want 1", passwordChecksPerHour, got, errs)
	}
	if got := count(errs, ErrWrongPassword); got != passwordChecksPerHour-1 {
		t.Errorf("%d parallel changes: %d wrong_password, want %d", passwordChecksPerHour, got, passwordChecksPerHour-1)
	}
	winner := "marigold" + strconv.Itoa(slices.IndexFunc(errs, func(err error) bool { return err == nil }))
	if _, _, err := s.LogIn(ctx, "maya@example.com", winner); err != nil {
		t.Errorf("LogIn with the winning password = %v", err)
	}
}
