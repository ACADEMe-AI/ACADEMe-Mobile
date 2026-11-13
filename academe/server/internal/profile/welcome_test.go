package profile

import (
	"context"
	"sync"
	"testing"
	"time"
)

type fakeWelcomer struct {
	mu    sync.Mutex
	calls [][2]string
}

func (f *fakeWelcomer) Welcome(_ context.Context, accountID, language string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls = append(f.calls, [2]string{accountID, language})
}

func TestWelcomeFiresOnceWhenSetupCompletes(t *testing.T) {
	store := newFakeStore()
	welcome := &fakeWelcomer{}
	s := NewService(store, welcome)
	s.now = func() time.Time { return time.Date(2026, 9, 24, 0, 0, 0, 0, time.UTC) }

	if _, err := s.Update(t.Context(), "maya", Update{Language: ptr("hi")}); err != nil {
		t.Fatal(err)
	}
	welcome.mu.Lock()
	if len(welcome.calls) != 0 {
		t.Fatalf("welcome before setup complete = %v, want none", welcome.calls)
	}
	welcome.mu.Unlock()

	if _, err := s.Update(t.Context(), "maya", Update{
		BirthYear: ptr(2011), Class: ptr(10), Board: ptr("CBSE"),
	}); err != nil {
		t.Fatal(err)
	}
	welcome.mu.Lock()
	if len(welcome.calls) != 1 || welcome.calls[0] != [2]string{"maya", "hi"} {
		t.Fatalf("welcome after setup = %v, want [[maya hi]]", welcome.calls)
	}
	welcome.mu.Unlock()

	if _, err := s.Update(t.Context(), "maya", Update{Language: ptr("te")}); err != nil {
		t.Fatal(err)
	}
	welcome.mu.Lock()
	defer welcome.mu.Unlock()
	if len(welcome.calls) != 1 {
		t.Fatalf("welcome after later update = %v, want still one", welcome.calls)
	}
}
