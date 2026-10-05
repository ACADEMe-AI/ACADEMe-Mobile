package report

import (
	"context"
	"crypto/rand"
	"errors"
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

func newAccount(t *testing.T, pool *pgxpool.Pool, email string) string {
	t.Helper()
	var id string
	if err := pool.QueryRow(t.Context(), `
		INSERT INTO accounts (first_name, last_name, email, password_hash)
		VALUES ('Riya', 'S', $1, 'x') RETURNING id`, email).Scan(&id); err != nil {
		t.Fatal(err)
	}
	return id
}

func TestPostgresSave(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()
	riya := newAccount(t, pool, "riya@example.com")
	arjun := newAccount(t, pool, "arjun@example.com")
	var check, notes string
	if err := pool.QueryRow(ctx, `
		INSERT INTO scans (account_id, mode, title, body) VALUES ($1, 'check', 'Q1', 'x') RETURNING id`, riya).Scan(&check); err != nil {
		t.Fatal(err)
	}
	if err := pool.QueryRow(ctx, `
		INSERT INTO scans (account_id, mode, title, body) VALUES ($1, 'notes', 'Notes', 'x') RETURNING id`, riya).Scan(&notes); err != nil {
		t.Fatal(err)
	}
	if _, err := pool.Exec(ctx, `INSERT INTO user_decks (id, account_id, deck) VALUES ('u-deck', $1, '{}')`, riya); err != nil {
		t.Fatal(err)
	}

	for _, in := range []Report{
		{Kind: Check, ID: check, Reason: Wrong},
		{Kind: Check, ID: check, Reason: Offensive, Note: "rude"},
		{Kind: Lesson, ID: "u-deck", Reason: Harmful},
	} {
		if err := store.Save(ctx, riya, in); err != nil {
			t.Fatalf("Save(%+v) = %v, want nil", in, err)
		}
	}
	var reason, note string
	if err := pool.QueryRow(ctx, `SELECT reason, note FROM content_reports WHERE kind = 'check' AND target_id = $1`, check).Scan(&reason, &note); err != nil {
		t.Fatal(err)
	}
	if reason != "offensive" || note != "rude" {
		t.Errorf("stored check report = %q %q, want offensive rude", reason, note)
	}

	tests := []struct {
		name    string
		account string
		in      Report
	}{
		{"someone else's check", arjun, Report{Kind: Check, ID: check, Reason: Wrong}},
		{"someone else's lesson", arjun, Report{Kind: Lesson, ID: "u-deck", Reason: Wrong}},
		{"a notes scan as a check", riya, Report{Kind: Check, ID: notes, Reason: Wrong}},
		{"not a scan id", riya, Report{Kind: Check, ID: "not-a-uuid", Reason: Wrong}},
		{"no such lesson", riya, Report{Kind: Lesson, ID: "u-none", Reason: Wrong}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if err := store.Save(ctx, tc.account, tc.in); !errors.Is(err, ErrNotFound) {
				t.Errorf("Save(%+v) = %v, want ErrNotFound", tc.in, err)
			}
		})
	}
}
