package profile

import (
	"context"
	"fmt"
	"slices"
	"time"
)

const (
	SetupXP     = 100
	SetupReason = "setup"

	minClass = 6
	maxClass = 12
)

var (
	Languages = []string{"en", "hi", "te", "ta", "bn"}
	Boards    = []string{"CBSE", "ICSE"}
)

type Profile struct {
	Language  *string `json:"language"`
	BirthYear *int    `json:"birthYear"`
	Class     *int    `json:"class"`
	Board     *string `json:"board"`
	SetupDone bool    `json:"setupDone"`
	XP        int     `json:"xp"`
}

func (p Profile) complete() bool {
	return p.Language != nil && p.BirthYear != nil && p.Class != nil && p.Board != nil
}

type Update struct {
	Language  *string `json:"language"`
	BirthYear *int    `json:"birthYear"`
	Class     *int    `json:"class"`
	Board     *string `json:"board"`
}

type ValidationError struct {
	Field   string
	Problem string
}

func (e *ValidationError) Error() string { return e.Field + " " + e.Problem }

type Store interface {
	Profile(ctx context.Context, accountID string) (Profile, error)
	Apply(ctx context.Context, accountID string, u Update) (Profile, error)
	CompleteSetup(ctx context.Context, accountID string, xp int, reason string) (Profile, error)
}

type Service struct {
	store Store
	now   func() time.Time
}

func NewService(store Store) *Service {
	return &Service{store: store, now: time.Now}
}

func (s *Service) Profile(ctx context.Context, accountID string) (Profile, error) {
	p, err := s.store.Profile(ctx, accountID)
	if err != nil {
		return Profile{}, fmt.Errorf("get profile: %w", err)
	}
	return p, nil
}

func (s *Service) Update(ctx context.Context, accountID string, u Update) (Profile, error) {
	if err := s.validate(u); err != nil {
		return Profile{}, err
	}
	p, err := s.store.Apply(ctx, accountID, u)
	if err != nil {
		return Profile{}, fmt.Errorf("update profile: %w", err)
	}
	if p.complete() && !p.SetupDone {
		p, err = s.store.CompleteSetup(ctx, accountID, SetupXP, SetupReason)
		if err != nil {
			return Profile{}, fmt.Errorf("complete setup: %w", err)
		}
	}
	return p, nil
}

func (s *Service) validate(u Update) error {
	year := s.now().Year()
	switch {
	case u.Language == nil && u.BirthYear == nil && u.Class == nil && u.Board == nil:
		return &ValidationError{"profile", "has nothing to update"}
	case u.Language != nil && !slices.Contains(Languages, *u.Language):
		return &ValidationError{"language", "is not supported"}
	case u.BirthYear != nil && (*u.BirthYear < year-100 || *u.BirthYear > year-5):
		return &ValidationError{"birthYear", "is out of range"}
	case u.Class != nil && (*u.Class < minClass || *u.Class > maxClass):
		return &ValidationError{"class", fmt.Sprintf("must be %d to %d", minClass, maxClass)}
	case u.Board != nil && !slices.Contains(Boards, *u.Board):
		return &ValidationError{"board", "is not supported"}
	}
	return nil
}
