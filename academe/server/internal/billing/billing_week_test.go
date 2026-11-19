package billing

import (
	"errors"
	"testing"
	"testing/synctest"
	"time"

	"academe/server/internal/india"
)

func TestWeekPoolIgnoresUncappedLessons(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		store := newFakeStore("riya")
		s := NewService(store, testLimits, nil)
		ctx := t.Context()
		expires := time.Now().Add(time.Hour)
		if _, err := store.Apply(ctx, "", []Change{{AccountID: "riya", Entitlement: &Entitlement{State: "active", ExpiresAt: &expires}}}); err != nil {
			t.Fatal(err)
		}
		day, _ := today(time.Now())
		for range 200 {
			if err := s.Take(ctx, "riya", Lessons); err != nil {
				t.Fatalf("Take(lessons) = %v, want nil", err)
			}
		}
		if err := s.Take(ctx, "riya", AskMe); err != nil {
			t.Fatalf("Take(askme) after many lessons = %v, want nil", err)
		}
		p, err := s.Plan(ctx, "riya")
		if err != nil || p.UsedWeek != 1 {
			t.Fatalf("Plan() usedWeek = %d, err = %v; want 1 (lessons not in pool)", p.UsedWeek, err)
		}
		_ = day
	})
}

func TestWeekPoolBlocksAndRefundsOvershoot(t *testing.T) {
	store := newFakeStore("riya")
	limits := map[string]int{"askme": 100, "scan": 100, "check": 100, "lessons": 0}
	s := NewService(store, limits, nil)
	ctx := t.Context()
	cap := s.weekCap(false)
	day, _ := today(time.Now())
	weekStart, _ := india.UsageWeekBounds(time.Now())
	store.mu.Lock()
	store.usage[usageKey{"riya", day, AskMe}] = 99
	store.usage[usageKey{"riya", weekStart, AskMe}] = cap - 1 - 99
	store.mu.Unlock()
	if err := s.Take(ctx, "riya", AskMe); err != nil {
		t.Fatalf("Take(askme) to fill pool = %v", err)
	}
	err := s.Take(ctx, "riya", Scan)
	le, ok := errors.AsType[*LimitError](err)
	if !ok || le.Scope != "week" || le.Limit != cap {
		t.Fatalf("Take(scan) after pool full = %v, want week LimitError cap %d", err, cap)
	}
	store.mu.Lock()
	scanUsed := store.usage[usageKey{"riya", day, Scan}]
	store.mu.Unlock()
	if scanUsed != 0 {
		t.Errorf("scan count = %d, want 0 after refund", scanUsed)
	}
}

func TestWeekPoolResetsOnMondayIST(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		store := newFakeStore("riya")
		s := NewService(store, map[string]int{"askme": 1, "scan": 1, "check": 1, "lessons": 0}, nil)
		ctx := t.Context()
		for day := range 7 {
			for _, f := range []Feature{AskMe, Scan, Check} {
				if err := s.Take(ctx, "riya", f); err != nil {
					t.Fatal(err)
				}
			}
			if day < 6 {
				_, next := today(time.Now())
				time.Sleep(time.Until(next))
			}
		}
		if err := s.Take(ctx, "riya", AskMe); err == nil {
			t.Fatal("want week limit before rollover")
		}
		_, weekNext := india.UsageWeekBounds(time.Now())
		time.Sleep(time.Until(weekNext))
		if err := s.Take(ctx, "riya", AskMe); err != nil {
			t.Errorf("Take after Monday IST = %v, want nil", err)
		}
	})
}
