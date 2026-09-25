package study

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

	for i, want := range []bool{true, false} {
		got, err := store.AwardXP(ctx, riya, QuizXP, "quiz:d1:2")
		if err != nil || got != want {
			t.Errorf("AwardXP() call %d = %v, %v; want %v", i+1, got, err, want)
		}
	}
	var total int
	if err := pool.QueryRow(ctx, `SELECT sum(amount) FROM xp_events WHERE account_id = $1`, riya).Scan(&total); err != nil || total != QuizXP {
		t.Errorf("xp total = %d, %v; want %d", total, err, QuizXP)
	}
	for _, correct := range []int{2, 1} {
		if err := store.Complete(ctx, riya, "d1", correct); err != nil {
			t.Fatalf("Complete(%d) error = %v", correct, err)
		}
	}
	done, err := store.Completions(ctx, riya)
	if err != nil || done["d1"].Correct != 2 {
		t.Errorf("Completions() = %v, %v; want d1 kept at its best score 2", done, err)
	}

	if err := store.SavePosition(ctx, riya, "d1", 3); err != nil {
		t.Fatal(err)
	}
	if err := store.SavePosition(ctx, riya, "d1", 5); err != nil {
		t.Fatal(err)
	}
	if pos, err := store.Positions(ctx, riya); err != nil || pos["d1"] != 5 {
		t.Errorf("Positions() = %v, %v; want d1 at 5", pos, err)
	}

	later := time.Now().Add(48 * time.Hour)
	soon := time.Now().Add(time.Hour)
	if err := store.Keep(ctx, Kept{DeckID: "d1", Card: 2, Reason: "kept", DueAt: later}, riya, false); err != nil {
		t.Fatal(err)
	}
	if err := store.Keep(ctx, Kept{DeckID: "d1", Card: 2, Reason: "missed", DueAt: soon}, riya, true); err != nil {
		t.Fatal(err)
	}
	kept, err := store.KeptCards(ctx, riya)
	if err != nil || len(kept) != 1 || kept[0].DueAt.Sub(soon).Abs() > time.Second {
		t.Errorf("KeptCards() = %v, %v; want one card due soon after a miss", kept, err)
	}
	if err := store.Reschedule(ctx, riya, "d1", 2, later, 4); err != nil {
		t.Fatalf("Reschedule() error = %v", err)
	}
	if err := store.Reschedule(ctx, riya, "d1", 9, later, 4); !errors.Is(err, ErrNotKept) {
		t.Errorf("Reschedule(unkept) error = %v, want ErrNotKept", err)
	}
	if err := store.Unkeep(ctx, riya, "d1", 2); err != nil {
		t.Fatal(err)
	}
	if kept, _ := store.KeptCards(ctx, riya); len(kept) != 0 {
		t.Errorf("KeptCards() after Unkeep = %v, want none", kept)
	}

	if err := store.SaveChapterResult(ctx, riya, "cbse-10-science-9", 7, 9); err != nil {
		t.Fatal(err)
	}
	results, err := store.ChapterResults(ctx, riya)
	if err != nil || results["cbse-10-science-9"].Correct != 7 || results["cbse-10-science-9"].Total != 9 {
		t.Errorf("ChapterResults() = %v, %v; want 7 of 9", results, err)
	}
}
