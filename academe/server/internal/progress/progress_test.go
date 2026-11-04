package progress

import (
	"context"
	"testing"
	"time"

	"academe/server/internal/billing"
	"academe/server/internal/india"
)

type memStore struct {
	counts WeekCounts
	decks  []string
}

func (m *memStore) WeekCounts(context.Context, string, time.Time, time.Time) (WeekCounts, error) {
	return m.counts, nil
}

func (m *memStore) LessonDecksInWeek(context.Context, string, time.Time, time.Time) ([]string, error) {
	return m.decks, nil
}

type memPlans struct {
	plan string
}

func (m *memPlans) Plan(context.Context, string) (billing.Plan, error) {
	return billing.Plan{Plan: m.plan}, nil
}

type memStudy struct {
	subjects map[string]struct{ id, name string }
}

func (m *memStudy) DeckSubject(_ context.Context, _, deckID string) (string, string, bool) {
	s, ok := m.subjects[deckID]
	if !ok {
		return "", "", false
	}
	return s.id, s.name, true
}

func TestSummaryRequiresPro(t *testing.T) {
	s := NewService(&memPlans{plan: "free"}, &memStudy{}, &memStore{})
	_, err := s.Summary(context.Background(), "a")
	if err != ErrProRequired {
		t.Fatalf("free plan = %v, want ErrProRequired", err)
	}
}

func TestSummaryAggregates(t *testing.T) {
	fixed := time.Date(2026, 11, 5, 12, 0, 0, 0, india.Loc)
	s := NewService(
		&memPlans{plan: "pro"},
		&memStudy{subjects: map[string]struct{ id, name string }{
			"d1": {id: "science", name: "Science"},
			"d2": {id: "science", name: "Science"},
			"d3": {id: "maths", name: "Maths"},
		}},
		&memStore{
			counts: WeekCounts{DaysActive: 3, Lessons: 3, ChapterTests: 1, XP: 40},
			decks:  []string{"d1", "d2", "d3"},
		},
	)
	s.now = func() time.Time { return fixed }
	got, err := s.Summary(context.Background(), "a")
	if err != nil {
		t.Fatal(err)
	}
	if got.DaysActiveThisWeek != 3 || got.LessonsFinishedThisWeek != 3 || got.ChapterTestsThisWeek != 1 || got.XPThisWeek != 40 {
		t.Fatalf("counts = %+v", got)
	}
	if got.WeekStartsOn != "2026-11-02" {
		t.Fatalf("weekStartsOn = %q, want 2026-11-02 (Monday IST for Wed 5 Nov 2026)", got.WeekStartsOn)
	}
	if len(got.BySubject) != 2 {
		t.Fatalf("bySubject = %+v, want 2 subjects", got.BySubject)
	}
}
