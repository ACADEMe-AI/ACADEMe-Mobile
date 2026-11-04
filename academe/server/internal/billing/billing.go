package billing

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"sync"
	"time"

	"academe/server/internal/india"
)

type Feature string

const (
	AskMe   Feature = "askme"
	Scan    Feature = "scan"
	Check   Feature = "check"
	Lessons Feature = "lessons"
)

var features = []Feature{AskMe, Scan, Check, Lessons}

var (
	ErrUnavailable    = errors.New("billing is not set up")
	ErrUnknownAccount = errors.New("no such account")
	ErrBadEvent       = errors.New("event is not valid")
	ErrStore          = errors.New("revenuecat request failed")
)

type LimitError struct {
	Feature  Feature
	Limit    int
	ResetsAt time.Time
	Scope    string
}

func (e *LimitError) Error() string {
	if e.Limit == 0 {
		return fmt.Sprintf("%s is a pro feature", e.Feature)
	}
	return fmt.Sprintf("%s limit of %d a day reached", e.Feature, e.Limit)
}

type Entitlement struct {
	Platform   string
	ProductID  string
	BasePlanID string
	Token      string
	State      string
	ExpiresAt  *time.Time
	AutoRenew  bool
	Raw        json.RawMessage
	EventAt    time.Time
	Sandbox    bool
}

func (e Entitlement) active(now time.Time) bool {
	return e.State != "expired" && (e.ExpiresAt == nil || e.ExpiresAt.After(now))
}

type Change struct {
	AccountID   string
	Entitlement *Entitlement
}

type Plan struct {
	Plan       string           `json:"plan"`
	ExpiresAt  *time.Time       `json:"expiresAt"`
	AutoRenew  bool             `json:"autoRenew"`
	ProductID  *string          `json:"productId"`
	BasePlanID *string          `json:"basePlanId"`
	Platform   *string          `json:"platform"`
	State      *string          `json:"state"`
	Limits        map[Feature]*int `json:"limits"`
	UsedToday     map[Feature]int  `json:"usedToday"`
	ResetsAt      time.Time        `json:"resetsAt"`
	UsedWeek      int              `json:"usedWeek"`
	WeekLimit     int              `json:"weekLimit"`
	WeekResetsAt  time.Time        `json:"weekResetsAt"`
}

type Store interface {
	Entitlement(ctx context.Context, accountID string) (*Entitlement, error)
	Apply(ctx context.Context, eventID string, changes []Change) (bool, error)
	Usage(ctx context.Context, accountID string, day time.Time) (map[Feature]int, error)
	WeekUsage(ctx context.Context, accountID string, start, end time.Time) (int, error)
	Take(ctx context.Context, accountID string, day time.Time, f Feature, limit int) (bool, error)
	Refund(ctx context.Context, accountID string, day time.Time, f Feature) error
}

type Service struct {
	store       Store
	free        map[string]int
	revenueCat  *RevenueCat
	testers     map[string]bool
	entitlement string
	locks       sync.Map
}

func (s *Service) SetEntitlement(id string) {
	if id != "" {
		s.entitlement = id
	}
}

func (s *Service) SetTesters(ids []string) {
	s.testers = map[string]bool{}
	for _, id := range ids {
		s.testers[id] = true
	}
}

func (s *Service) allowed(accountID string, sandbox bool) bool {
	return !sandbox || s.testers["*"] || s.testers[accountID]
}

func NewService(store Store, free map[string]int, revenueCat *RevenueCat) *Service {
	return &Service{store: store, free: free, revenueCat: revenueCat, entitlement: EntitlementID}
}

func today(now time.Time) (day, next time.Time) {
	day = india.UsageDayUTC(now)
	t := now.In(india.Loc)
	next = time.Date(t.Year(), t.Month(), t.Day()+1, 0, 0, 0, 0, india.Loc)
	return day, next
}

func (s *Service) accountLock(accountID string) *sync.Mutex {
	v, _ := s.locks.LoadOrStore(accountID, &sync.Mutex{})
	return v.(*sync.Mutex)
}

func (s *Service) dailyLimit(f Feature, pro bool) (limit int, capped bool) {
	freeLimit, ok := s.free[string(f)]
	if !ok {
		return -1, false
	}
	if pro {
		if freeLimit == 0 {
			return -1, false
		}
		return freeLimit * 3, true
	}
	return freeLimit, true
}

func (s *Service) weekCap(pro bool) int {
	sum := 0
	for _, f := range features {
		l, ok := s.free[string(f)]
		if !ok {
			continue
		}
		if pro {
			if l == 0 {
				continue
			}
			l *= 3
		}
		if l > 0 {
			sum += l
		}
	}
	return 7 * sum
}

func (s *Service) current(ctx context.Context, accountID string) (*Entitlement, error) {
	e, err := s.store.Entitlement(ctx, accountID)
	if err != nil {
		return nil, fmt.Errorf("read entitlement: %w", err)
	}
	if e == nil || !e.active(time.Now()) {
		return nil, nil
	}
	return e, nil
}

func (s *Service) Plan(ctx context.Context, accountID string) (Plan, error) {
	e, err := s.current(ctx, accountID)
	if err != nil {
		return Plan{}, err
	}
	now := time.Now()
	day, next := today(now)
	weekStart, weekNext := india.UsageWeekBounds(now)
	used, err := s.store.Usage(ctx, accountID, day)
	if err != nil {
		return Plan{}, fmt.Errorf("read usage: %w", err)
	}
	usedWeek, err := s.store.WeekUsage(ctx, accountID, weekStart, weekNext)
	if err != nil {
		return Plan{}, fmt.Errorf("read weekly usage: %w", err)
	}
	pro := e != nil
	p := Plan{
		Plan: "free", Limits: map[Feature]*int{}, UsedToday: map[Feature]int{},
		ResetsAt: next, UsedWeek: usedWeek, WeekLimit: s.weekCap(pro), WeekResetsAt: weekNext,
	}
	for _, f := range features {
		p.UsedToday[f] = used[f]
		limit, capped := s.dailyLimit(f, pro)
		if capped {
			l := limit
			p.Limits[f] = &l
		}
	}
	if e != nil {
		p.Plan, p.ExpiresAt, p.AutoRenew, p.State = "pro", e.ExpiresAt, e.AutoRenew, &e.State
		p.ProductID, p.BasePlanID, p.Platform = &e.ProductID, &e.BasePlanID, &e.Platform
	}
	return p, nil
}

func (s *Service) Take(ctx context.Context, accountID string, f Feature) error {
	e, err := s.current(ctx, accountID)
	if err != nil {
		return err
	}
	pro := e != nil
	limit, capped := s.dailyLimit(f, pro)
	day, next := today(time.Now())
	if !capped {
		ok, err := s.store.Take(ctx, accountID, day, f, -1)
		if err != nil {
			return fmt.Errorf("count usage: %w", err)
		}
		if !ok {
			return fmt.Errorf("count usage: take failed")
		}
		return nil
	}
	if limit == 0 {
		return &LimitError{Feature: f, ResetsAt: next, Scope: "day"}
	}
	mu := s.accountLock(accountID)
	mu.Lock()
	defer mu.Unlock()
	weekStart, weekNext := india.UsageWeekBounds(time.Now())
	usedWeek, err := s.store.WeekUsage(ctx, accountID, weekStart, weekNext)
	if err != nil {
		return fmt.Errorf("read weekly usage: %w", err)
	}
	cap := s.weekCap(pro)
	if usedWeek >= cap {
		return &LimitError{Feature: f, Limit: cap, ResetsAt: weekNext, Scope: "week"}
	}
	ok, err := s.store.Take(ctx, accountID, day, f, limit)
	if err != nil {
		return fmt.Errorf("count usage: %w", err)
	}
	if !ok {
		return &LimitError{Feature: f, Limit: limit, ResetsAt: next, Scope: "day"}
	}
	usedWeek, err = s.store.WeekUsage(ctx, accountID, weekStart, weekNext)
	if err != nil {
		return fmt.Errorf("read weekly usage: %w", err)
	}
	if usedWeek > cap {
		_ = s.store.Refund(ctx, accountID, day, f)
		return &LimitError{Feature: f, Limit: cap, ResetsAt: weekNext, Scope: "week"}
	}
	return nil
}

func (s *Service) Refund(ctx context.Context, accountID string, f Feature) {
	day, _ := today(time.Now())
	_ = s.store.Refund(context.WithoutCancel(ctx), accountID, day, f)
}

func (s *Service) Sync(ctx context.Context, accountID string) (Plan, error) {
	if err := s.sync(ctx, "", accountID); err != nil {
		return Plan{}, err
	}
	return s.Plan(ctx, accountID)
}

func (s *Service) sync(ctx context.Context, eventID, accountID string) error {
	if s.revenueCat == nil {
		return ErrUnavailable
	}
	e, err := s.revenueCat.Subscriber(ctx, accountID, s.entitlement)
	if err != nil {
		return err
	}
	if e == nil || !s.allowed(accountID, e.Sandbox) {
		e = &Entitlement{State: "expired", Raw: json.RawMessage("{}"), EventAt: time.Now()}
	}
	if _, err := s.store.Apply(ctx, eventID, []Change{{AccountID: accountID, Entitlement: e}}); err != nil && !errors.Is(err, ErrUnknownAccount) {
		return fmt.Errorf("save entitlement: %w", err)
	}
	return nil
}

func (s *Service) HandleEvent(ctx context.Context, body []byte) error {
	ev, err := parseEvent(body)
	if err != nil {
		return err
	}
	var changes []Change
	switch {
	case ev.Type == "TRANSFER":
		for _, id := range ev.TransferredTo {
			if !isUUID(id) || s.revenueCat == nil {
				continue
			}
			if err := s.sync(ctx, "", id); err != nil {
				return err
			}
		}
		for _, id := range ev.TransferredFrom {
			if isUUID(id) {
				gone := Entitlement{State: "expired", Raw: ev.raw, EventAt: time.UnixMilli(ev.EventTimestampMs)}
				changes = append(changes, Change{AccountID: id, Entitlement: &gone})
			}
		}
	case ev.grants(s.entitlement) && isUUID(ev.AppUserID):
		e, ok := ev.entitlement()
		if !ok || !s.allowed(ev.AppUserID, e.Sandbox) {
			return nil
		}
		if ev.Type == "EXPIRATION" && s.revenueCat != nil {
			return s.sync(ctx, ev.ID, ev.AppUserID)
		}
		changes = append(changes, Change{AccountID: ev.AppUserID, Entitlement: &e})
	}
	if len(changes) == 0 {
		return nil
	}
	if _, err := s.store.Apply(ctx, ev.ID, changes); err != nil && !errors.Is(err, ErrUnknownAccount) {
		return fmt.Errorf("apply %s: %w", ev.Type, err)
	}
	return nil
}
