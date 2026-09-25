package profile

import (
	"context"
	"crypto/rand"
	"net/url"
	"os"
	"strings"
	"testing"

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
	if err := postgres.Migrate(t.Context(), pool); err != nil {
		t.Fatal(err)
	}
	return pool
}

func TestPostgresStore(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()

	var accountID string
	if err := pool.QueryRow(ctx, `INSERT INTO accounts (first_name, last_name, email, password_hash)
		VALUES ('Maya', 'Rao', 'maya@example.com', 'x') RETURNING id::text`).Scan(&accountID); err != nil {
		t.Fatal(err)
	}

	p, err := store.Profile(ctx, accountID)
	if err != nil || p.Language != nil || p.SetupDone || p.XP != 0 {
		t.Fatalf("Profile of a new account = %+v, %v, want empty", p, err)
	}

	if _, err := store.Apply(ctx, accountID, Update{Language: ptr("ta")}); err != nil {
		t.Fatal(err)
	}
	p, err = store.Apply(ctx, accountID, Update{Class: ptr(8), Board: ptr("ICSE")})
	if err != nil || p.Language == nil || *p.Language != "ta" || *p.Class != 8 || *p.Board != "ICSE" || p.BirthYear != nil {
		t.Fatalf("Apply = %+v, %v, want ta / 8 / ICSE with no birth year", p, err)
	}

	for range 2 {
		p, err = store.CompleteSetup(ctx, accountID, SetupXP, SetupReason)
		if err != nil {
			t.Fatal(err)
		}
	}
	if !p.SetupDone || p.XP != SetupXP {
		t.Errorf("after CompleteSetup twice = %+v, want done with %d XP once", p, SetupXP)
	}

	if _, err := pool.Exec(ctx, "DELETE FROM accounts WHERE id = $1", accountID); err != nil {
		t.Fatal(err)
	}
	var left int
	if err := pool.QueryRow(ctx, "SELECT (SELECT count(*) FROM profiles) + (SELECT count(*) FROM xp_events)").Scan(&left); err != nil || left != 0 {
		t.Errorf("rows left after deleting the account = %d, %v, want 0", left, err)
	}
}
