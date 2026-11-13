package scan

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

func TestPostgresStore(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()
	riya := newAccount(t, pool, "riya@example.com")
	arjun := newAccount(t, pool, "arjun@example.com")

	s, err := store.Create(ctx, riya, Scan{Mode: Check, Title: "Refraction", Text: "Light bends", Chapter: "Science"})
	if err != nil || s.ID == "" || s.Result != nil || s.ThreadID != nil {
		t.Fatalf("Create() = %+v, %v", s, err)
	}
	if _, err := store.Scan(ctx, arjun, s.ID); !errors.Is(err, ErrNotFound) {
		t.Errorf("Scan() for another account error = %v, want ErrNotFound", err)
	}
	if _, err := store.Scan(ctx, riya, "nope"); !errors.Is(err, ErrNotFound) {
		t.Errorf("Scan(bad id) error = %v, want ErrNotFound", err)
	}
	m := Marking{Question: "Define refraction.", Marks: 1, Awarded: 1, Points: []Point{{Text: "Bending", Marks: 1, Awarded: 1}}, FullMarks: "Good"}
	if err := store.SetResult(ctx, riya, s.ID, m); err != nil {
		t.Fatal(err)
	}
	if err := store.SetResult(ctx, arjun, s.ID, m); !errors.Is(err, ErrNotFound) {
		t.Errorf("SetResult() for another account error = %v, want ErrNotFound", err)
	}
	thread := "7c9e6679-7425-40de-944b-e07fc1f90ae7"
	if err := store.SetThread(ctx, riya, s.ID, thread); err != nil {
		t.Fatal(err)
	}
	folder, deck := "0b6f1c1e-7c4b-4b8e-9d7e-3c8a5e2f1a90", "u-abc"
	if err := store.SetFolder(ctx, riya, s.ID, folder, &deck); err != nil {
		t.Fatal(err)
	}
	got, err := store.Scan(ctx, riya, s.ID)
	if err != nil || got.Result == nil || got.Result.Points[0].Text != "Bending" || *got.ThreadID != thread || *got.FolderID != folder || *got.DeckID != deck {
		t.Fatalf("Scan() = %+v, %v", got, err)
	}
	if _, err := store.Create(ctx, riya, Scan{Mode: Notes, Title: "Notes", Text: "x"}); err != nil {
		t.Fatal(err)
	}
	list, err := store.Scans(ctx, riya, 20)
	if err != nil || len(list) != 2 || list[0].Mode != Notes {
		t.Errorf("Scans() = %+v, %v; want the newest first", list, err)
	}
	if list, _ := store.Scans(ctx, arjun, 20); len(list) != 0 {
		t.Errorf("Scans() for another account = %v, want none", list)
	}
}
