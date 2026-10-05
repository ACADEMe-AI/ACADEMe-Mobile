package profile

import (
	"context"
	"crypto/rand"
	"net/url"
	"os"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/google/go-cmp/cmp"
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

	p, err = store.Apply(ctx, accountID, Update{Subjects: &[]string{"english", "maths"}})
	if err != nil || !slices.Equal(p.Subjects, []string{"english", "maths"}) {
		t.Fatalf("Apply(subjects) = %+v, %v, want english and maths", p, err)
	}
	p, err = store.Apply(ctx, accountID, Update{BirthYear: ptr(2012)})
	if err != nil || len(p.Subjects) != 2 {
		t.Fatalf("Apply(birth year) = %+v, %v, want the subjects kept", p, err)
	}
	p, err = store.Apply(ctx, accountID, Update{Subjects: new([]string)})
	if err != nil || p.Subjects != nil {
		t.Fatalf("Apply(clear subjects) = %+v, %v, want no subjects", p, err)
	}
	for range 2 {
		p, err = store.AwardXP(ctx, accountID, SubjectsXP, SubjectsReason)
		if err != nil {
			t.Fatal(err)
		}
	}
	if p.XP != SubjectsXP {
		t.Fatalf("XP after AwardXP twice = %d, want %d", p.XP, SubjectsXP)
	}

	for range 2 {
		p, err = store.CompleteSetup(ctx, accountID, SetupXP, SetupReason)
		if err != nil {
			t.Fatal(err)
		}
	}
	if !p.SetupDone || p.XP != SetupXP+SubjectsXP {
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

func TestStreakDays(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	ctx := t.Context()

	var accountID string
	if err := pool.QueryRow(ctx, `INSERT INTO accounts (first_name, last_name, email, password_hash)
		VALUES ('Maya', 'Rao', 'maya@example.com', 'x') RETURNING id::text`).Scan(&accountID); err != nil {
		t.Fatal(err)
	}
	for _, seed := range []string{
		`INSERT INTO xp_events (account_id, amount, reason, created_at) VALUES
			($1, 5, 'a', '2026-10-02 18:29:00+00'),
			($1, 5, 'b', '2026-10-02 18:31:00+00'),
			($1, 5, 'c', '2026-10-03 10:00:00+00')`,
		`INSERT INTO study_days (account_id, day) VALUES ($1, '2026-10-01'), ($1, '2026-10-03')`,
		`INSERT INTO study_days (account_id) VALUES ($1)`,
	} {
		if _, err := pool.Exec(ctx, seed, accountID); err != nil {
			t.Fatal(err)
		}
	}
	p, err := store.Profile(ctx, accountID)
	if err != nil {
		t.Fatal(err)
	}
	today := dayOf(time.Now().In(india))
	want := []time.Time{
		time.Date(2026, 10, 1, 0, 0, 0, 0, time.UTC),
		time.Date(2026, 10, 2, 0, 0, 0, 0, time.UTC),
		time.Date(2026, 10, 3, 0, 0, 0, 0, time.UTC),
	}
	if !today.After(want[2]) {
		t.Fatalf("today = %v, want a day after the seeded ones", today)
	}
	want = append(want, today)
	if diff := cmp.Diff(want, p.days); diff != "" {
		t.Errorf("Profile days (-want +got):\n%s", diff)
	}
}
