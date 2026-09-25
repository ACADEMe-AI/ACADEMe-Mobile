package scan

import (
	"context"
	"errors"
	"net/http"
	"testing"

	"academe/server/internal/billing"
	"academe/server/internal/httpx"
	"academe/server/internal/sarvam"
)

type fakeLimiter struct {
	proOnly map[billing.Feature]bool
	taken   []billing.Feature
	refunds []billing.Feature
}

func (f *fakeLimiter) Take(_ context.Context, _ string, feature billing.Feature) error {
	if f.proOnly[feature] {
		return &billing.LimitError{Feature: feature}
	}
	f.taken = append(f.taken, feature)
	return nil
}

func (f *fakeLimiter) Refund(_ context.Context, _ string, feature billing.Feature) {
	f.refunds = append(f.refunds, feature)
}

func TestLimits(t *testing.T) {
	store, folders := newFakeStore(), &fakeFolders{}
	limiter := &fakeLimiter{proOnly: map[billing.Feature]bool{billing.Lessons: true}}
	s := NewService(store, &fakeReader{text: "Light bends"}, &fakeModel{}, fakeProfiles{}, &fakeLessons{}, folders)
	s.SetLimiter(limiter)
	ctx := t.Context()

	sc, err := s.Read(ctx, "riya", Notes, []sarvam.Page{{Name: "page.jpg", Data: []byte("x")}})
	if err != nil {
		t.Fatal(err)
	}
	_, err = s.SaveNotes(ctx, "riya", sc.ID, "f1", true)
	httpErr, ok := errors.AsType[*httpx.Error](toHTTP(err))
	if !ok || httpErr.Status != http.StatusPaymentRequired || httpErr.Code != "pro_only" || len(folders.notes) != 0 {
		t.Errorf("SaveNotes(makeLesson) on free = %v, notes %v; want 402 pro_only and nothing saved", err, folders.notes)
	}
	if _, err := s.SaveNotes(ctx, "riya", sc.ID, "f1", false); err != nil || len(folders.notes) != 1 {
		t.Errorf("SaveNotes(just the notes) = %v, want the notes saved", err)
	}

	check, err := s.Read(ctx, "riya", Check, []sarvam.Page{{Name: "page.jpg", Data: []byte("x")}})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.Check(ctx, "riya", check.ID, ""); !errors.Is(err, ErrFailed) {
		t.Fatalf("Check() with no model reply = %v, want ErrFailed", err)
	}
	want := []billing.Feature{billing.Scan, billing.Scan, billing.Check}
	if len(limiter.taken) != 3 || limiter.taken[2] != want[2] || len(limiter.refunds) != 1 || limiter.refunds[0] != billing.Check {
		t.Errorf("taken %v, refunded %v; want %v and a refund for the failed check", limiter.taken, limiter.refunds, want)
	}
}
