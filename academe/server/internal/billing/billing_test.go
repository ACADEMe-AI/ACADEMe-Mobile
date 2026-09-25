package billing

import (
	"context"
	"errors"
	"sync"
	"testing"
	"testing/synctest"
	"time"

	"github.com/google/go-cmp/cmp"
)

type usageKey struct {
	account string
	day     time.Time
	feature Feature
}

type fakeStore struct {
	mu       sync.Mutex
	accounts map[string]bool
	subs     map[string]Entitlement
	events   map[string]bool
	usage    map[usageKey]int
}

func newFakeStore(accounts ...string) *fakeStore {
	f := &fakeStore{accounts: map[string]bool{}, subs: map[string]Entitlement{}, events: map[string]bool{}, usage: map[usageKey]int{}}
	for _, a := range accounts {
		f.accounts[a] = true
	}
	return f
}

func (f *fakeStore) Entitlement(_ context.Context, accountID string) (*Entitlement, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	e, ok := f.subs[accountID]
	if !ok {
		return nil, nil
	}
	return &e, nil
}

func (f *fakeStore) Apply(_ context.Context, eventID string, changes []Change) (bool, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if eventID != "" && f.events[eventID] {
		return false, nil
	}
	for _, c := range changes {
		if c.Entitlement != nil && !f.accounts[c.AccountID] {
			return false, ErrUnknownAccount
		}
	}
	for _, c := range changes {
		switch old, ok := f.subs[c.AccountID]; {
		case c.Entitlement == nil:
			delete(f.subs, c.AccountID)
		case !ok || !old.EventAt.After(c.Entitlement.EventAt):
			f.subs[c.AccountID] = *c.Entitlement
		}
	}
	if eventID != "" {
		f.events[eventID] = true
	}
	return true, nil
}

func (f *fakeStore) Usage(_ context.Context, accountID string, day time.Time) (map[Feature]int, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	out := map[Feature]int{}
	for k, n := range f.usage {
		if k.account == accountID && k.day.Equal(day) {
			out[k.feature] = n
		}
	}
	return out, nil
}

func (f *fakeStore) Take(_ context.Context, accountID string, day time.Time, feature Feature, limit int) (bool, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	k := usageKey{accountID, day, feature}
	if limit >= 0 && f.usage[k] >= limit {
		return false, nil
	}
	f.usage[k]++
	return true, nil
}

func (f *fakeStore) Refund(_ context.Context, accountID string, day time.Time, feature Feature) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if k := (usageKey{accountID, day, feature}); f.usage[k] > 0 {
		f.usage[k]--
	}
	return nil
}

var testLimits = map[string]int{"askme": 2, "scan": 3, "check": 1, "lessons": 0}

func TestLimiterRollsOverAtMidnightInIndia(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		s := NewService(newFakeStore(), testLimits, nil)
		ctx := t.Context()
		for i := range 2 {
			if err := s.Take(ctx, "riya", AskMe); err != nil {
				t.Fatalf("Take(askme) #%d = %v, want nil", i+1, err)
			}
		}
		err := s.Take(ctx, "riya", AskMe)
		le, ok := errors.AsType[*LimitError](err)
		if !ok || le.Limit != 2 || le.Feature != AskMe {
			t.Fatalf("Take(askme) #3 = %v, want a LimitError for 2 a day", err)
		}
		midnight := time.Date(2000, 1, 2, 0, 0, 0, 0, india)
		if !le.ResetsAt.Equal(midnight) {
			t.Errorf("ResetsAt = %v, want %v", le.ResetsAt, midnight)
		}
		if err := s.Take(ctx, "arjun", AskMe); err != nil {
			t.Errorf("Take(askme) for another account = %v, want nil", err)
		}
		time.Sleep(time.Until(midnight) - time.Second)
		if err := s.Take(ctx, "riya", AskMe); err == nil {
			t.Error("Take(askme) a second before midnight IST = nil, want the limit")
		}
		time.Sleep(time.Second)
		if err := s.Take(ctx, "riya", AskMe); err != nil {
			t.Errorf("Take(askme) at midnight IST = %v, want nil", err)
		}
		p, err := s.Plan(ctx, "riya")
		if err != nil || p.UsedToday[AskMe] != 1 || p.Plan != "free" {
			t.Errorf("Plan() = %+v, %v; want free with 1 askme used", p, err)
		}
	})
}

func TestLimiterRefundProOnlyAndPro(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		store := newFakeStore("riya")
		s := NewService(store, testLimits, nil)
		ctx := t.Context()
		if err := s.Take(ctx, "riya", Check); err != nil {
			t.Fatal(err)
		}
		s.Refund(ctx, "riya", Check)
		if err := s.Take(ctx, "riya", Check); err != nil {
			t.Errorf("Take(check) after a refund = %v, want nil", err)
		}
		if le, ok := errors.AsType[*LimitError](s.Take(ctx, "riya", Lessons)); !ok || le.Limit != 0 {
			t.Errorf("Take(lessons) = %v, want a pro-only LimitError", le)
		}
		if err := s.Take(ctx, "riya", Feature("mock")); err != nil {
			t.Errorf("Take(unlisted feature) = %v, want nil", err)
		}
		expires := time.Now().Add(time.Hour)
		if _, err := store.Apply(ctx, "", []Change{{AccountID: "riya", Entitlement: &Entitlement{State: "active", ExpiresAt: &expires}}}); err != nil {
			t.Fatal(err)
		}
		for range 5 {
			if err := s.Take(ctx, "riya", Check); err != nil {
				t.Fatalf("Take(check) on pro = %v, want nil", err)
			}
		}
		if err := s.Take(ctx, "riya", Lessons); err != nil {
			t.Errorf("Take(lessons) on pro = %v, want nil", err)
		}
		p, _ := s.Plan(ctx, "riya")
		if diff := cmp.Diff(map[Feature]*int{AskMe: nil, Scan: nil, Check: nil, Lessons: nil}, p.Limits); p.Plan != "pro" || diff != "" {
			t.Errorf("Plan() = %s, limits diff (-want +got):\n%s", p.Plan, diff)
		}
		time.Sleep(2 * time.Hour)
		if p, _ := s.Plan(ctx, "riya"); p.Plan != "free" {
			t.Errorf("Plan() after expiry = %s, want free", p.Plan)
		}
	})
}
