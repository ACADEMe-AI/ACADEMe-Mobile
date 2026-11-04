package feedback

import (
	"context"
	"sync"
	"testing"
	"time"
)

type memStore struct {
	mu   sync.Mutex
	rows []struct {
		account string
		at      time.Time
	}
	ids int
}

func (m *memStore) countLocked(accountID string, since, until time.Time) int {
	n := 0
	for _, row := range m.rows {
		if row.account != accountID {
			continue
		}
		if !row.at.Before(since) && row.at.Before(until) {
			n++
		}
	}
	return n
}

func (m *memStore) InsertLimited(_ context.Context, accountID string, in Submission, dayStart, dayEnd, weekStart, weekEnd time.Time) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.countLocked(accountID, dayStart, dayEnd) >= perDay {
		return "", ErrDailyLimit
	}
	if m.countLocked(accountID, weekStart, weekEnd) >= perWeek {
		return "", ErrWeeklyLimit
	}
	m.ids++
	m.rows = append(m.rows, struct {
		account string
		at      time.Time
	}{accountID, time.Now()})
	return "id", nil
}

func TestSubmitLimits(t *testing.T) {
	s := NewService(&memStore{}, nil)
	ctx := context.Background()
	sub := Submission{Category: Bug, Message: "Something broke on the scan screen today."}
	for i := range perDay {
		if _, err := s.Submit(ctx, "a", sub); err != nil {
			t.Fatalf("submit #%d = %v", i+1, err)
		}
	}
	if _, err := s.Submit(ctx, "a", sub); err != ErrDailyLimit {
		t.Fatalf("4th same day = %v, want ErrDailyLimit", err)
	}
}

func TestValidation(t *testing.T) {
	s := NewService(&memStore{}, nil)
	_, err := s.Submit(context.Background(), "a", Submission{Category: "nope", Message: "1234567890"})
	if err != ErrBadInput {
		t.Fatalf("bad category = %v, want ErrBadInput", err)
	}
}
