package chat

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

	thread, err := store.CreateThread(ctx, riya, Explain, "What is light?")
	if err != nil {
		t.Fatalf("CreateThread() error = %v", err)
	}
	if _, err := store.AddMessage(ctx, thread.ID, Student, "What is light?"); err != nil {
		t.Fatal(err)
	}
	reply, err := store.AddMessage(ctx, thread.ID, Pebby, "Light is energy.")
	if err != nil {
		t.Fatal(err)
	}

	if _, err := store.Thread(ctx, arjun, thread.ID); !errors.Is(err, ErrNotFound) {
		t.Errorf("Thread(other account) error = %v, want ErrNotFound", err)
	}
	if _, err := store.Thread(ctx, riya, "not-a-uuid"); !errors.Is(err, ErrNotFound) {
		t.Errorf("Thread(bad id) error = %v, want ErrNotFound", err)
	}
	if err := store.Rate(ctx, arjun, reply.ID, 1); !errors.Is(err, ErrNotFound) {
		t.Errorf("Rate(other account) error = %v, want ErrNotFound", err)
	}
	if err := store.Rate(ctx, riya, reply.ID, -1); err != nil {
		t.Errorf("Rate() error = %v", err)
	}
	messages, err := store.Messages(ctx, thread.ID)
	if err != nil {
		t.Fatal(err)
	}
	if len(messages) != 2 || messages[1].Rating != -1 || messages[0].Role != Student {
		t.Errorf("Messages() = %+v, want question then a rated answer", messages)
	}
	if err := store.DeleteLastReply(ctx, thread.ID); err != nil {
		t.Errorf("DeleteLastReply() error = %v", err)
	}
	if err := store.DeleteLastReply(ctx, thread.ID); !errors.Is(err, ErrNothingToRetry) {
		t.Errorf("DeleteLastReply(after a question) error = %v, want ErrNothingToRetry", err)
	}
	threads, err := store.Threads(ctx, riya)
	if err != nil || len(threads) != 1 || threads[0].Title != "What is light?" {
		t.Errorf("Threads() = %+v, %v, want the one thread", threads, err)
	}
	if others, _ := store.Threads(ctx, arjun); len(others) != 0 {
		t.Errorf("Threads(other account) = %+v, want none", others)
	}
}
