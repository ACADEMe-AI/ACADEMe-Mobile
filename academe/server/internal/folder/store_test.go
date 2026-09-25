package folder

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

	due := date("2026-10-12")
	f, err := store.Create(ctx, riya, "Science unit test", &due)
	if err != nil || f.Name != "Science unit test" || f.DueOn == nil || !f.Reminds {
		t.Fatalf("Create() = %+v, %v", f, err)
	}
	if _, err := store.Folder(ctx, arjun, f.ID); !errors.Is(err, ErrNotFound) {
		t.Errorf("Folder() for another account error = %v, want ErrNotFound", err)
	}
	if _, err := store.Folder(ctx, riya, "not-a-uuid"); !errors.Is(err, ErrNotFound) {
		t.Errorf("Folder(bad id) error = %v, want ErrNotFound", err)
	}
	if err := store.AddChapters(ctx, f.ID, []string{"c10", "c11"}); err != nil {
		t.Fatal(err)
	}
	if err := store.AddChapters(ctx, f.ID, []string{"c10"}); err != nil {
		t.Fatal(err)
	}
	if err := store.AddNote(ctx, f.ID, "Class notes"); err != nil {
		t.Fatal(err)
	}
	items, err := store.Items(ctx, f.ID)
	if err != nil || len(items) != 3 {
		t.Fatalf("Items() = %v, %v; want two chapters and a note", items, err)
	}
	if err := store.DeleteItem(ctx, f.ID, items[1].ID); err != nil {
		t.Fatal(err)
	}
	if err := store.AddTodo(ctx, f.ID, "Learn ray diagrams", nil); err != nil {
		t.Fatal(err)
	}
	todos, err := store.Todos(ctx, f.ID)
	if err != nil || len(todos) != 1 {
		t.Fatalf("Todos() = %v, %v", todos, err)
	}
	now := time.Now()
	if err := store.SetTodoDone(ctx, f.ID, todos[0].ID, &now); err != nil {
		t.Fatal(err)
	}
	if todos, _ := store.Todos(ctx, f.ID); todos[0].DoneAt == nil {
		t.Error("todo should be done")
	}
	updated, err := store.Update(ctx, riya, f.ID, "Science test", nil, false)
	if err != nil || updated.DueOn != nil || updated.Reminds {
		t.Errorf("Update() = %+v, %v; want no date and reminders off", updated, err)
	}
	if folders, err := store.Folders(ctx, riya); err != nil || len(folders) != 1 {
		t.Errorf("Folders() = %v, %v", folders, err)
	}
	if err := store.Delete(ctx, riya, f.ID); err != nil {
		t.Fatal(err)
	}
	if items, _ := store.Items(ctx, f.ID); len(items) != 0 {
		t.Errorf("items after delete = %v, want none", items)
	}
}
