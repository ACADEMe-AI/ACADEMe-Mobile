package progress

import (
	"context"
	"errors"
	"time"

	"academe/server/internal/billing"
	"academe/server/internal/india"
)

var ErrProRequired = errors.New("pro required")

type SubjectCount struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	LessonsDone int    `json:"lessonsDone"`
}

type Summary struct {
	WeekStartsOn            string         `json:"weekStartsOn"`
	DaysActiveThisWeek      int            `json:"daysActiveThisWeek"`
	LessonsFinishedThisWeek int            `json:"lessonsFinishedThisWeek"`
	ChapterTestsThisWeek    int            `json:"chapterTestsThisWeek"`
	XPThisWeek              int            `json:"xpThisWeek"`
	ActiveDays              []bool         `json:"activeDays"`
	OverallGrade            *float64       `json:"overallGrade"`
	BySubject               []SubjectCount `json:"bySubject"`
}

type Store interface {
	WeekCounts(ctx context.Context, accountID string, start, end time.Time) (WeekCounts, error)
	LessonDecksInWeek(ctx context.Context, accountID string, start, end time.Time) ([]string, error)
}

type Plans interface {
	Plan(ctx context.Context, accountID string) (billing.Plan, error)
}

type Study interface {
	DeckSubject(ctx context.Context, accountID, deckID string) (id, name string, ok bool)
}

type Service struct {
	plans Plans
	study Study
	store Store
	now   func() time.Time
}

func NewService(plans Plans, study Study, store Store) *Service {
	return &Service{plans: plans, study: study, store: store, now: time.Now}
}

func (s *Service) Summary(ctx context.Context, accountID string) (Summary, error) {
	p, err := s.plans.Plan(ctx, accountID)
	if err != nil {
		return Summary{}, err
	}
	if p.Plan != "pro" {
		return Summary{}, ErrProRequired
	}
	start, end := india.WeekRange(s.now())
	counts, err := s.store.WeekCounts(ctx, accountID, start, end)
	if err != nil {
		return Summary{}, err
	}
	decks, err := s.store.LessonDecksInWeek(ctx, accountID, start, end)
	if err != nil {
		return Summary{}, err
	}
	bySubject := map[string]*SubjectCount{}
	for _, deckID := range decks {
		id, name, ok := s.study.DeckSubject(ctx, accountID, deckID)
		if !ok || id == "" {
			continue
		}
		row, ok := bySubject[id]
		if !ok {
			row = &SubjectCount{ID: id, Name: name}
			bySubject[id] = row
		}
		row.LessonsDone++
	}
	out := make([]SubjectCount, 0, len(bySubject))
	for _, row := range bySubject {
		out = append(out, *row)
	}
	active := make([]bool, 7)
	copy(active, counts.ActiveDays[:])
	return Summary{
		WeekStartsOn:            start.In(india.Loc).Format("2006-01-02"),
		DaysActiveThisWeek:      counts.DaysActive,
		LessonsFinishedThisWeek: counts.Lessons,
		ChapterTestsThisWeek:    counts.ChapterTests,
		XPThisWeek:              counts.XP,
		ActiveDays:              active,
		OverallGrade:            counts.OverallGrade,
		BySubject:               out,
	}, nil
}
