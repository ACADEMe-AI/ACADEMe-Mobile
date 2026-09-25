package chat

import (
	"context"
	"errors"
	"net/http"
	"testing"

	"academe/server/internal/billing"
	"academe/server/internal/httpx"
)

type fakeLimiter struct {
	left    int
	refunds int
}

func (f *fakeLimiter) Take(_ context.Context, _ string, feature billing.Feature) error {
	if f.left == 0 {
		return &billing.LimitError{Feature: feature, Limit: 1}
	}
	f.left--
	return nil
}

func (f *fakeLimiter) Refund(context.Context, string, billing.Feature) { f.refunds++ }

func TestSendIsLimited(t *testing.T) {
	tutor := &fakeTutor{err: errors.New("down")}
	limiter := &fakeLimiter{left: 1}
	s := NewService(newFakeStore(), tutor, fakeProfiles{}, fakeAccounts{})
	s.SetLimiter(limiter)
	if _, err := s.Send(t.Context(), "riya", Send{Mode: Explain, Text: "hi"}); err == nil || limiter.refunds != 1 || limiter.left != 0 {
		t.Fatalf("Send() with a failing tutor = %v, refunds %d; want an error and one refund", err, limiter.refunds)
	}
	limiter.left = 0
	_, err := s.Send(t.Context(), "riya", Send{Mode: Explain, Text: "hi"})
	httpErr, ok := errors.AsType[*httpx.Error](toHTTP(err))
	if !ok || httpErr.Status != http.StatusPaymentRequired || httpErr.Code != "limit_reached" || httpErr.Details["feature"] != billing.AskMe {
		t.Errorf("toHTTP(Send() over the limit) = %v, want 402 limit_reached for askme", httpErr)
	}
	if len(tutor.briefs) != 1 {
		t.Errorf("tutor asked %d times, want 1", len(tutor.briefs))
	}
}

func TestRetryIsLimited(t *testing.T) {
	store := newFakeStore()
	limiter := &fakeLimiter{left: 1}
	s := NewService(store, &fakeTutor{}, fakeProfiles{}, fakeAccounts{})
	s.SetLimiter(limiter)
	ex, err := s.Send(t.Context(), "riya", Send{Mode: Explain, Text: "Why?"})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.Retry(t.Context(), "riya", ex.Thread.ID, Explain); err == nil {
		t.Fatal("Retry() over the limit = nil, want a LimitError")
	}
	if messages, _ := store.Messages(t.Context(), ex.Thread.ID); len(messages) != 2 || messages[1].ID != ex.Reply.ID {
		t.Errorf("after a refused Retry() messages = %+v, want the answer kept", messages)
	}
	limiter.left = 1
	if _, err := s.Retry(t.Context(), "riya", ex.Thread.ID, Explain); err != nil || limiter.left != 0 {
		t.Fatalf("Retry() = %v, left %d; want nil and one use taken", err, limiter.left)
	}
	if _, err := s.Retry(t.Context(), "riya", "missing", Explain); !errors.Is(err, ErrNotFound) || limiter.refunds != 0 {
		t.Errorf("Retry(missing thread) = %v, refunds %d; want ErrNotFound before any use", err, limiter.refunds)
	}
}
