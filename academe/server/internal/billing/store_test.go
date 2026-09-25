package billing

import (
	"context"
	"crypto/rand"
	"errors"
	"net/url"
	"os"
	"strings"
	"sync"
	"sync/atomic"
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

	if e, err := store.Entitlement(ctx, riya); e != nil || err != nil {
		t.Fatalf("Entitlement() before any purchase = %v, %v; want nil, nil", e, err)
	}
	now := time.Now().Truncate(time.Millisecond)
	expires := now.Add(30 * 24 * time.Hour)
	e := Entitlement{Platform: "play_store", ProductID: "academe_pro", BasePlanID: "monthly", Token: "GPA.1", State: "active", ExpiresAt: &expires, AutoRenew: true, Raw: []byte(`{"a":1}`), EventAt: now}
	if ok, err := store.Apply(ctx, "ev-1", []Change{{AccountID: riya, Entitlement: &e}}); !ok || err != nil {
		t.Fatalf("Apply(ev-1) = %v, %v; want true", ok, err)
	}
	if ok, err := store.Apply(ctx, "ev-1", []Change{{AccountID: riya}}); ok || err != nil {
		t.Errorf("Apply(ev-1) again = %v, %v; want false, nil", ok, err)
	}
	older := e
	older.State, older.EventAt = "expired", now.Add(-time.Minute)
	if _, err := store.Apply(ctx, "ev-0", []Change{{AccountID: riya, Entitlement: &older}}); err != nil {
		t.Fatal(err)
	}
	got, err := store.Entitlement(ctx, riya)
	if err != nil || got == nil || got.State != "active" || got.BasePlanID != "monthly" || !got.ExpiresAt.Equal(expires) || string(got.Raw) != `{"a": 1}` {
		t.Fatalf("Entitlement() = %+v, %v; want the active monthly plan kept over an older event", got, err)
	}
	if _, err := store.Apply(ctx, "ev-2", []Change{{AccountID: "11111111-2222-4333-8444-555555555555", Entitlement: &e}}); !errors.Is(err, ErrUnknownAccount) {
		t.Errorf("Apply(unknown account) error = %v, want ErrUnknownAccount", err)
	}
	lifetime := e
	lifetime.ExpiresAt, lifetime.Platform = nil, "promotional"
	if _, err := store.Apply(ctx, "ev-3", []Change{{AccountID: riya}, {AccountID: arjun, Entitlement: &lifetime}}); err != nil {
		t.Fatal(err)
	}
	if got, _ := store.Entitlement(ctx, riya); got != nil {
		t.Errorf("Entitlement(riya) after transfer = %+v, want nil", got)
	}
	if got, _ := store.Entitlement(ctx, arjun); got == nil || got.ExpiresAt != nil || got.Platform != "promotional" {
		t.Errorf("Entitlement(arjun) = %+v, want a lifetime promotional entitlement", got)
	}

	day := time.Date(2026, 9, 25, 0, 0, 0, 0, time.UTC)
	for i, want := range []bool{true, true, false} {
		if ok, err := store.Take(ctx, riya, day, AskMe, 2); ok != want || err != nil {
			t.Errorf("Take(askme, 2) #%d = %v, %v; want %v", i+1, ok, err, want)
		}
	}
	if err := store.Refund(ctx, riya, day, AskMe); err != nil {
		t.Fatal(err)
	}
	if ok, _ := store.Take(ctx, riya, day, AskMe, 2); !ok {
		t.Error("Take(askme) after a refund = false, want true")
	}
	if ok, _ := store.Take(ctx, riya, day, Scan, -1); !ok {
		t.Error("Take(scan, unlimited) = false, want true")
	}
	if ok, _ := store.Take(ctx, riya, day.AddDate(0, 0, 1), AskMe, 2); !ok {
		t.Error("Take(askme) the next day = false, want true")
	}
	used, err := store.Usage(ctx, riya, day)
	if err != nil || used[AskMe] != 2 || used[Scan] != 1 {
		t.Errorf("Usage() = %v, %v; want askme 2, scan 1", used, err)
	}
}

func TestPostgresTakeIsAtomic(t *testing.T) {
	pool := openTestPool(t)
	store := NewPostgresStore(pool)
	riya := newAccount(t, pool, "riya@example.com")
	day := time.Date(2026, 9, 25, 0, 0, 0, 0, time.UTC)
	var taken atomic.Int32
	var wg sync.WaitGroup
	for range 40 {
		wg.Go(func() {
			ok, err := store.Take(t.Context(), riya, day, AskMe, 10)
			if err != nil {
				t.Error(err)
			}
			if ok {
				taken.Add(1)
			}
		})
	}
	wg.Wait()
	if taken.Load() != 10 {
		t.Fatalf("%d parallel Take(askme, 10) succeeded, want exactly 10", taken.Load())
	}
	for range 40 {
		wg.Go(func() {
			if err := store.Refund(t.Context(), riya, day, AskMe); err != nil {
				t.Error(err)
			}
		})
	}
	wg.Wait()
	if used, err := store.Usage(t.Context(), riya, day); err != nil || used[AskMe] != 0 {
		t.Errorf("Usage() after 40 refunds of 10 uses = %v, %v; want 0, never negative", used, err)
	}
	s := NewService(store, map[string]int{"askme": 10}, nil)
	var allowed atomic.Int32
	for range 30 {
		wg.Go(func() {
			if s.Take(t.Context(), riya, AskMe) == nil {
				allowed.Add(1)
			}
		})
	}
	wg.Wait()
	if allowed.Load() != 10 {
		t.Errorf("%d parallel Service.Take(askme) allowed, want 10", allowed.Load())
	}
}
