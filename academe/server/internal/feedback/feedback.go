package feedback

import (
	"context"
	"encoding/json"
	"errors"
	"strings"
	"sync"
	"time"
	"unicode/utf8"

	"academe/server/internal/india"
)

const (
	maxMessageRunes = 2000
	minMessageRunes = 10
	perDay          = 2
	perWeek         = 5
	notifyTimeout   = 30 * time.Second
)

var (
	ErrBadInput    = errors.New("category must be wrong_answer, bug or feature, with a message of 10 to 2000 characters")
	ErrDailyLimit  = errors.New("daily feedback limit reached")
	ErrWeeklyLimit = errors.New("weekly feedback limit reached")
)

type Category string

const (
	WrongAnswer Category = "wrong_answer"
	Bug         Category = "bug"
	Feature     Category = "feature"
)

type Submission struct {
	Category Category
	Message  string
	Context  json.RawMessage
}

type Store interface {
	InsertLimited(ctx context.Context, accountID string, in Submission, dayStart, dayEnd, weekStart, weekEnd time.Time) (string, error)
}

type Service struct {
	store      Store
	notify     *Notifier
	background sync.WaitGroup
}

func NewService(store Store, notify *Notifier) *Service {
	return &Service{store: store, notify: notify}
}

func (s *Service) Wait() { s.background.Wait() }

func (s *Service) Submit(ctx context.Context, accountID string, in Submission) (id string, err error) {
	in.Message = strings.TrimSpace(in.Message)
	switch in.Category {
	case WrongAnswer, Bug, Feature:
	default:
		return "", ErrBadInput
	}
	n := utf8.RuneCountInString(in.Message)
	if n < minMessageRunes || n > maxMessageRunes {
		return "", ErrBadInput
	}
	if in.Context == nil {
		in.Context = json.RawMessage(`{}`)
	}
	now := time.Now()
	dayStart, dayEnd := india.DayRange(now)
	weekStart, weekEnd := india.WeekRange(now)
	id, err = s.store.InsertLimited(ctx, accountID, in, dayStart, dayEnd, weekStart, weekEnd)
	if err != nil {
		return "", err
	}
	if s.notify != nil {
		s.background.Go(func() {
			ctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), notifyTimeout)
			defer cancel()
			s.notify.Deliver(ctx, accountID, id, in)
		})
	}
	return id, nil
}

func RetryAfter(now time.Time, err error) time.Duration {
	switch {
	case errors.Is(err, ErrDailyLimit):
		_, end := india.DayRange(now)
		return time.Until(end)
	case errors.Is(err, ErrWeeklyLimit):
		_, end := india.WeekRange(now)
		return time.Until(end)
	default:
		return 0
	}
}
