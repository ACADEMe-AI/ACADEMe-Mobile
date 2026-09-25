package chat

import (
	"context"
	"errors"
	"fmt"
	"strings"
	"time"
	"unicode/utf8"

	"academe/server/internal/auth"
	"academe/server/internal/billing"
	"academe/server/internal/profile"
)

type Mode string

const (
	Explain Mode = "explain"
	Solve   Mode = "solve"
	Quiz    Mode = "quiz"
)

func (m Mode) valid() bool { return m == Explain || m == Solve || m == Quiz }

type Role string

const (
	Student Role = "student"
	Pebby   Role = "pebby"
)

type Thread struct {
	ID        string    `json:"id"`
	Mode      Mode      `json:"mode"`
	Title     string    `json:"title"`
	UpdatedAt time.Time `json:"updatedAt"`
}

type Message struct {
	ID        int64     `json:"id"`
	Role      Role      `json:"role"`
	Body      string    `json:"body"`
	Rating    int       `json:"rating"`
	CreatedAt time.Time `json:"createdAt"`
}

type Brief struct {
	FirstName string
	Class     int
	Board     string
	Language  string
	Mode      Mode
}

var (
	ErrNotFound       = errors.New("thread not found")
	ErrUnavailable    = errors.New("tutor unavailable")
	ErrEmpty          = errors.New("message is empty")
	ErrTooLong        = errors.New("message is too long")
	ErrBadMode        = errors.New("mode must be explain, solve or quiz")
	ErrBadRating      = errors.New("rating must be -1, 0 or 1")
	ErrNothingToRetry = errors.New("nothing to retry")
)

const (
	maxMessageRunes = 2000
	maxTitleRunes   = 60
	historyLimit    = 20
)

type Store interface {
	Threads(ctx context.Context, accountID string) ([]Thread, error)
	CreateThread(ctx context.Context, accountID string, mode Mode, title string) (Thread, error)
	Thread(ctx context.Context, accountID, threadID string) (Thread, error)
	Messages(ctx context.Context, threadID string) ([]Message, error)
	AddMessage(ctx context.Context, threadID string, role Role, body string) (Message, error)
	DeleteLastReply(ctx context.Context, threadID string) error
	Rate(ctx context.Context, accountID string, messageID int64, rating int) error
	Report(ctx context.Context, accountID string, messageID int64, report Report) error
}

type Tutor interface {
	Reply(ctx context.Context, brief Brief, history []Message) (string, error)
}

type Profiles interface {
	Profile(ctx context.Context, accountID string) (profile.Profile, error)
}

type Accounts interface {
	Account(ctx context.Context, id string) (auth.Account, error)
}

type Limiter interface {
	Take(ctx context.Context, accountID string, f billing.Feature) error
	Refund(ctx context.Context, accountID string, f billing.Feature)
}

type Service struct {
	store    Store
	tutor    Tutor
	profiles Profiles
	accounts Accounts
	limiter  Limiter
}

func (s *Service) SetLimiter(l Limiter) { s.limiter = l }

func NewService(store Store, tutor Tutor, profiles Profiles, accounts Accounts) *Service {
	return &Service{store: store, tutor: tutor, profiles: profiles, accounts: accounts}
}

type Send struct {
	ThreadID *string `json:"threadId"`
	Mode     Mode    `json:"mode"`
	Text     string  `json:"text"`
}

type Exchange struct {
	Thread   Thread  `json:"thread"`
	Question Message `json:"question"`
	Reply    Message `json:"reply"`
}

func (s *Service) Threads(ctx context.Context, accountID string) ([]Thread, error) {
	return s.store.Threads(ctx, accountID)
}

func (s *Service) Messages(ctx context.Context, accountID, threadID string) ([]Message, error) {
	if _, err := s.store.Thread(ctx, accountID, threadID); err != nil {
		return nil, err
	}
	return s.store.Messages(ctx, threadID)
}

func (s *Service) Send(ctx context.Context, accountID string, in Send) (Exchange, error) {
	text := strings.TrimSpace(in.Text)
	switch {
	case text == "":
		return Exchange{}, ErrEmpty
	case utf8.RuneCountInString(text) > maxMessageRunes:
		return Exchange{}, ErrTooLong
	case !in.Mode.valid():
		return Exchange{}, ErrBadMode
	case s.tutor == nil:
		return Exchange{}, ErrUnavailable
	}
	if s.limiter != nil {
		if err := s.limiter.Take(ctx, accountID, billing.AskMe); err != nil {
			return Exchange{}, err
		}
	}
	exchange, err := s.send(ctx, accountID, in, text)
	if err != nil && s.limiter != nil {
		s.limiter.Refund(ctx, accountID, billing.AskMe)
	}
	return exchange, err
}

func (s *Service) send(ctx context.Context, accountID string, in Send, text string) (Exchange, error) {
	var thread Thread
	var err error
	if in.ThreadID != nil {
		thread, err = s.store.Thread(ctx, accountID, *in.ThreadID)
	} else {
		thread, err = s.store.CreateThread(ctx, accountID, in.Mode, title(text))
	}
	if err != nil {
		return Exchange{}, err
	}
	question, err := s.store.AddMessage(ctx, thread.ID, Student, text)
	if err != nil {
		return Exchange{}, err
	}
	reply, err := s.answer(ctx, accountID, thread.ID, in.Mode)
	if err != nil {
		return Exchange{}, err
	}
	thread.Mode = in.Mode
	thread.UpdatedAt = reply.CreatedAt
	return Exchange{Thread: thread, Question: question, Reply: reply}, nil
}

func (s *Service) Retry(ctx context.Context, accountID, threadID string, mode Mode) (Message, error) {
	if !mode.valid() {
		return Message{}, ErrBadMode
	}
	if s.tutor == nil {
		return Message{}, ErrUnavailable
	}
	if _, err := s.store.Thread(ctx, accountID, threadID); err != nil {
		return Message{}, err
	}
	if err := s.store.DeleteLastReply(ctx, threadID); err != nil {
		return Message{}, err
	}
	return s.answer(ctx, accountID, threadID, mode)
}

func (s *Service) Rate(ctx context.Context, accountID string, messageID int64, rating int) error {
	if rating < -1 || rating > 1 {
		return ErrBadRating
	}
	return s.store.Rate(ctx, accountID, messageID, rating)
}

func (s *Service) answer(ctx context.Context, accountID, threadID string, mode Mode) (Message, error) {
	brief, err := s.brief(ctx, accountID, mode)
	if err != nil {
		return Message{}, err
	}
	history, err := s.store.Messages(ctx, threadID)
	if err != nil {
		return Message{}, err
	}
	if len(history) > historyLimit {
		history = history[len(history)-historyLimit:]
	}
	text, err := s.tutor.Reply(ctx, brief, history)
	if err != nil {
		return Message{}, fmt.Errorf("tutor reply: %w", err)
	}
	return s.store.AddMessage(ctx, threadID, Pebby, text)
}

func (s *Service) brief(ctx context.Context, accountID string, mode Mode) (Brief, error) {
	p, err := s.profiles.Profile(ctx, accountID)
	if err != nil {
		return Brief{}, err
	}
	account, err := s.accounts.Account(ctx, accountID)
	if err != nil {
		return Brief{}, err
	}
	b := Brief{FirstName: account.FirstName, Language: "en", Mode: mode}
	if p.Language != nil {
		b.Language = *p.Language
	}
	if p.Class != nil {
		b.Class = *p.Class
	}
	if p.Board != nil {
		b.Board = *p.Board
	}
	return b, nil
}

func title(text string) string {
	line, _, _ := strings.Cut(text, "\n")
	if utf8.RuneCountInString(line) <= maxTitleRunes {
		return line
	}
	return string([]rune(line)[:maxTitleRunes-1]) + "…"
}
