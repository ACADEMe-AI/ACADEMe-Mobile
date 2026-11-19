package auth

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"testing/synctest"
	"time"
)

func fillHashingSlots(s *Service) func() {
	for range cap(s.hashing) {
		s.hashing <- struct{}{}
	}
	return func() {
		for range cap(s.hashing) {
			<-s.hashing
		}
	}
}

func TestHashingWaitsForAFreeSlot(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		s := NewService(newFakeStore(), []byte("0123456789abcdef0123456789abcdef"), nil, &fakeMailer{})
		if got := cap(s.hashing); got != hashingSlots {
			t.Fatalf("hashing slots = %d, want %d", got, hashingSlots)
		}
		release := fillHashingSlots(s)
		ctx, cancel := context.WithTimeout(t.Context(), time.Second)
		defer cancel()
		if _, err := s.hash(ctx, "sunflower"); !errors.Is(err, context.DeadlineExceeded) {
			t.Errorf("hash() with every slot taken = %v, want %v", err, context.DeadlineExceeded)
		}
		if _, err := s.check(ctx, "sunflower", s.dummyHash); !errors.Is(err, context.DeadlineExceeded) {
			t.Errorf("check() with every slot taken = %v, want %v", err, context.DeadlineExceeded)
		}
		release()
		if hash, err := s.hash(t.Context(), "sunflower"); err != nil || len(s.hashing) != 0 {
			t.Errorf("hash() with free slots = %q, %v, %d slots held; want a hash, nil, 0", hash, err, len(s.hashing))
		}
	})
}

func TestJunkResetCompletesAreRejectedWithoutHashing(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		e := newResetEnv(t)
		release := fillHashingSlots(e.service)
		defer release()
		const requests = 200
		start := time.Now()
		statuses := make([]int, requests)
		bodies := make([]string, requests)
		var wg sync.WaitGroup
		for i := range requests {
			wg.Go(func() {
				ctx, cancel := context.WithTimeout(t.Context(), time.Minute)
				defer cancel()
				body := completeBody(fmt.Sprintf("junk-%d", i), strings.Repeat("p", maxPasswordLength))
				req := httptest.NewRequestWithContext(ctx, http.MethodPost, "/auth/password-reset/complete", strings.NewReader(body))
				req.RemoteAddr = fmt.Sprintf("10.0.%d.%d:1234", i/250, i%250+1)
				rec := httptest.NewRecorder()
				e.handler.ServeHTTP(rec, req)
				statuses[i], bodies[i] = rec.Code, rec.Body.String()
			})
		}
		wg.Wait()
		for i := range requests {
			if statuses[i] != http.StatusGone || !strings.Contains(bodies[i], `"reset_expired"`) {
				t.Fatalf("junk complete #%d = %d %s, want 410 reset_expired before any hashing", i, statuses[i], bodies[i])
			}
		}
		if waited := time.Since(start); waited != 0 {
			t.Errorf("junk completes waited %v for a hashing slot, want them rejected at once", waited)
		}
	})
}
