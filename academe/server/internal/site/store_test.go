package site

import (
	"context"
	"crypto/rand"
	"fmt"
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

func TestPostgresRequestDeletion(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()

	fresh, err := store.RequestDeletion(ctx, "riya@example.com", "10.0.0.1")
	if err != nil || !fresh {
		t.Fatalf("RequestDeletion(first) = %v, %v, want true, nil", fresh, err)
	}
	if fresh, err := store.RequestDeletion(ctx, "riya@example.com", "10.0.0.2"); err != nil || fresh {
		t.Errorf("RequestDeletion(same email) = %v, %v, want false, nil", fresh, err)
	}
	for i := range requestsPerIPPerDay - 1 {
		if fresh, err := store.RequestDeletion(ctx, fmt.Sprintf("s%d@example.com", i), "10.0.0.1"); err != nil || !fresh {
			t.Fatalf("RequestDeletion(%d from one IP) = %v, %v, want true, nil", i+2, fresh, err)
		}
	}
	if fresh, err := store.RequestDeletion(ctx, "late@example.com", "10.0.0.1"); err != nil || fresh {
		t.Errorf("RequestDeletion(over the IP limit) = %v, %v, want false, nil", fresh, err)
	}
	if _, err := pool.Exec(ctx, `UPDATE deletion_requests SET created_at = now() - interval '13 months' WHERE email = 'riya@example.com'`); err != nil {
		t.Fatal(err)
	}
	if fresh, err := store.RequestDeletion(ctx, "riya@example.com", "10.0.0.3"); err != nil || !fresh {
		t.Errorf("RequestDeletion(a year later) = %v, %v, want true, nil", fresh, err)
	}
	var old int
	if err := pool.QueryRow(ctx, `SELECT count(*) FROM deletion_requests WHERE created_at < now() - interval '1 year'`).Scan(&old); err != nil || old != 0 {
		t.Errorf("requests older than a year = %d, %v, want 0", old, err)
	}
}
