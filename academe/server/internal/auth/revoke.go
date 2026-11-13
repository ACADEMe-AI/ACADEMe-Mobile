package auth

import (
	"context"
	"fmt"
	"sync"
	"time"
)

const (
	revocationCheckTTL  = 30 * time.Second
	revocationSweepSize = 10_000
)

type revocation struct {
	validAfter time.Time
	checked    time.Time
}

type revocations struct {
	mu      sync.Mutex
	entries map[string]revocation
	sweepAt int
}

func newRevocations() *revocations {
	return &revocations{entries: map[string]revocation{}, sweepAt: revocationSweepSize}
}

func (r *revocations) get(accountID string, now time.Time) (time.Time, bool) {
	r.mu.Lock()
	defer r.mu.Unlock()
	e, ok := r.entries[accountID]
	if !ok || now.Sub(e.checked) >= revocationCheckTTL {
		return time.Time{}, false
	}
	return e.validAfter, true
}

func (r *revocations) put(accountID string, validAfter, now time.Time) time.Time {
	r.mu.Lock()
	defer r.mu.Unlock()
	if len(r.entries) > r.sweepAt {
		for id, e := range r.entries {
			if now.Sub(e.checked) >= revocationCheckTTL {
				delete(r.entries, id)
			}
		}
		r.sweepAt = max(revocationSweepSize, 2*len(r.entries))
	}
	if e, ok := r.entries[accountID]; ok && e.validAfter.After(validAfter) {
		validAfter = e.validAfter
	}
	r.entries[accountID] = revocation{validAfter: validAfter, checked: now}
	return validAfter
}

func (s *Service) Authenticate(ctx context.Context, accessToken string) (string, error) {
	accountID, issued, err := verifyAccessToken(s.tokenKey, accessToken, time.Now())
	if err != nil {
		return "", err
	}
	validAfter, err := s.tokensValidAfter(ctx, accountID)
	if err != nil {
		return "", fmt.Errorf("authenticate: %w", err)
	}
	if issued.Before(validAfter) {
		return "", ErrInvalidToken
	}
	return accountID, nil
}

func (s *Service) tokensValidAfter(ctx context.Context, accountID string) (time.Time, error) {
	now := time.Now()
	if validAfter, ok := s.revoked.get(accountID, now); ok {
		return validAfter, nil
	}
	validAfter, err := s.store.TokensValidAfter(ctx, accountID)
	if err != nil {
		return time.Time{}, err
	}
	return s.revoked.put(accountID, validAfter, now), nil
}

func (s *Service) revokeAccessTokens(accountID string, at time.Time) {
	s.revoked.put(accountID, at, time.Now())
}

func revocationTime() time.Time {
	return time.Now().Truncate(time.Microsecond)
}
