package auth

import (
	"context"
	"crypto/rand"
	"errors"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"academe/server/internal/postgres"
)

func openTestPool(t *testing.T) *pgxpool.Pool {
	t.Helper()
	base := os.Getenv("ACADEME_TEST_DATABASE_URL")
	if base == "" {
		t.Skip("ACADEME_TEST_DATABASE_URL is not set")
	}
	admin, err := postgres.Open(t.Context(), base)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(admin.Close)

	schema := "test_" + strings.ToLower(rand.Text())
	if _, err := admin.Exec(t.Context(), "CREATE SCHEMA "+schema); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		if _, err := admin.Exec(context.WithoutCancel(t.Context()), "DROP SCHEMA "+schema+" CASCADE"); err != nil {
			t.Error(err)
		}
	})

	u, err := url.Parse(base)
	if err != nil {
		t.Fatal(err)
	}
	q := u.Query()
	q.Set("search_path", schema)
	u.RawQuery = q.Encode()
	pool, err := postgres.Open(t.Context(), u.String())
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(pool.Close)
	for range 2 {
		if err := postgres.Migrate(t.Context(), pool); err != nil {
			t.Fatal(err)
		}
	}
	return pool
}

func TestPostgresStore(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	ctx := t.Context()

	maya, err := store.CreateAccount(ctx, Account{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com"}, "hash")
	if err != nil {
		t.Fatalf("CreateAccount = %v", err)
	}
	if _, err := store.CreateAccount(ctx, Account{FirstName: "M", LastName: "R", Email: "maya@example.com"}, "hash"); !errors.Is(err, ErrEmailTaken) {
		t.Errorf("CreateAccount with a taken email = %v, want ErrEmailTaken", err)
	}

	got, hash, err := store.AccountByEmail(ctx, "maya@example.com")
	if err != nil || got != maya || hash != "hash" {
		t.Errorf("AccountByEmail = %+v, %q, %v, want %+v, \"hash\"", got, hash, err, maya)
	}
	if _, _, err := store.AccountByEmail(ctx, "nobody@example.com"); !errors.Is(err, ErrNotFound) {
		t.Errorf("AccountByEmail(unknown) = %v, want ErrNotFound", err)
	}
	if got, err := store.AccountByID(ctx, maya.ID); err != nil || got != maya {
		t.Errorf("AccountByID = %+v, %v, want %+v", got, err, maya)
	}

	later := time.Now().Add(time.Hour)
	if err := store.CreateSession(ctx, maya.ID, hashToken("one"), later); err != nil {
		t.Fatalf("CreateSession = %v", err)
	}
	if id, err := store.RotateSession(ctx, hashToken("one"), hashToken("two"), later); err != nil || id != maya.ID {
		t.Errorf("RotateSession = %q, %v, want %q", id, err, maya.ID)
	}
	if _, err := store.RotateSession(ctx, hashToken("one"), hashToken("three"), later); !errors.Is(err, ErrInvalidToken) {
		t.Errorf("RotateSession with a used token = %v, want ErrInvalidToken", err)
	}

	if err := store.CreateSession(ctx, maya.ID, hashToken("expired"), time.Now().Add(-time.Minute)); err != nil {
		t.Fatalf("CreateSession = %v", err)
	}
	if _, err := store.RotateSession(ctx, hashToken("expired"), hashToken("four"), later); !errors.Is(err, ErrInvalidToken) {
		t.Errorf("RotateSession with an expired token = %v, want ErrInvalidToken", err)
	}

	if _, err := store.UpdateName(ctx, maya.ID, "Maya", "Rao-Iyer"); err != nil {
		t.Errorf("UpdateName = %v", err)
	}
	if err := store.LinkGoogle(ctx, maya.ID, "g-maya", time.Now()); err != nil {
		t.Fatalf("LinkGoogle = %v", err)
	}
	if got, err := store.AccountByGoogleSubject(ctx, "g-maya"); err != nil || got.LastName != "Rao-Iyer" {
		t.Errorf("AccountByGoogleSubject = %+v, %v, want Maya Rao-Iyer", got, err)
	}
	if _, hash, _ := store.AccountByEmail(ctx, "maya@example.com"); hash != "" {
		t.Errorf("password hash after LinkGoogle = %q, want none", hash)
	}
	if _, err := store.RotateSession(ctx, hashToken("two"), hashToken("six"), later); !errors.Is(err, ErrInvalidToken) {
		t.Errorf("RotateSession after LinkGoogle = %v, want ErrInvalidToken", err)
	}
	if _, err := store.CreateGoogleAccount(ctx, Account{Email: "maya@example.com"}, "g-other"); !errors.Is(err, ErrEmailTaken) {
		t.Errorf("CreateGoogleAccount with a taken email = %v, want ErrEmailTaken", err)
	}
	ada, err := store.CreateGoogleAccount(ctx, Account{FirstName: "Ada", Email: "ada@gmail.com"}, "g-ada")
	if err != nil {
		t.Fatalf("CreateGoogleAccount = %v", err)
	}
	if got, err := store.AccountByGoogleSubject(ctx, "g-ada"); err != nil || got != ada {
		t.Errorf("AccountByGoogleSubject = %+v, %v, want %+v", got, err, ada)
	}
	if _, err := store.AccountByGoogleSubject(ctx, "g-nobody"); !errors.Is(err, ErrNotFound) {
		t.Errorf("AccountByGoogleSubject(unknown) = %v, want ErrNotFound", err)
	}

	if err := store.DeleteSession(ctx, hashToken("two")); err != nil {
		t.Fatalf("DeleteSession = %v", err)
	}
	if _, err := store.RotateSession(ctx, hashToken("two"), hashToken("five"), later); !errors.Is(err, ErrInvalidToken) {
		t.Errorf("RotateSession after DeleteSession = %v, want ErrInvalidToken", err)
	}
}

func TestPostgresStoreDeletion(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	ctx := t.Context()
	keep, err := store.CreateAccount(ctx, Account{FirstName: "K", LastName: "Eep", Email: "keep@example.com"}, "hash")
	if err != nil {
		t.Fatal(err)
	}
	gone, err := store.CreateAccount(ctx, Account{FirstName: "G", LastName: "One", Email: "gone@example.com"}, "hash")
	if err != nil {
		t.Fatal(err)
	}
	if err := store.CreateSession(ctx, gone.ID, []byte("gone-session"), time.Now().Add(time.Hour)); err != nil {
		t.Fatal(err)
	}

	old := time.Now().Add(-DeletionGrace - time.Hour)
	if err := store.ScheduleDeletion(ctx, gone.ID, "too busy", old); err != nil {
		t.Fatalf("ScheduleDeletion() error = %v", err)
	}
	if _, err := store.RotateSession(ctx, []byte("gone-session"), []byte("next"), time.Now().Add(time.Hour)); err == nil {
		t.Error("RotateSession() after scheduling deletion succeeded, want the session gone")
	}
	if err := store.ScheduleDeletion(ctx, keep.ID, "", old); err != nil {
		t.Fatal(err)
	}
	if err := store.CancelDeletion(ctx, keep.ID); err != nil {
		t.Fatalf("CancelDeletion() error = %v", err)
	}

	ids, err := store.PurgeDeleted(ctx, time.Now().Add(-DeletionGrace))
	if err != nil || len(ids) != 1 || ids[0] != gone.ID {
		t.Fatalf("PurgeDeleted() = %v, %v, want [%s]", ids, err, gone.ID)
	}
	if _, err := store.AccountByID(ctx, gone.ID); !errors.Is(err, ErrNotFound) {
		t.Errorf("AccountByID(purged) error = %v, want ErrNotFound", err)
	}
	if _, err := store.AccountByID(ctx, keep.ID); err != nil {
		t.Errorf("AccountByID(cancelled) error = %v, want the account kept", err)
	}
}
