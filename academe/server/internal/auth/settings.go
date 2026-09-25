package auth

import (
	"context"
	"errors"
	"fmt"
	"unicode/utf8"
)

var (
	ErrWrongPassword    = errors.New("wrong current password")
	ErrGoogleTaken      = errors.New("google account belongs to another account")
	ErrPasswordRequired = errors.New("account has no password")
)

const passwordChecksPerHour = 5

func (s *Service) ChangePassword(ctx context.Context, id, current, next string) (Account, Tokens, error) {
	if err := validatePassword(next); err != nil {
		return Account{}, Tokens{}, err
	}
	hash, err := s.store.PasswordHash(ctx, id)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("change password: %w", err)
	}
	if hash != "" {
		if err := s.checkCurrentPassword(id, current, hash); err != nil {
			return Account{}, Tokens{}, err
		}
	}
	now := revocationTime()
	if err := s.store.ChangePassword(ctx, id, hash, hashPassword(next), now); err != nil {
		return Account{}, Tokens{}, fmt.Errorf("change password: %w", err)
	}
	s.revokeAccessTokens(id, now)
	a, err := s.store.AccountByID(ctx, id)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("change password: %w", err)
	}
	tokens, err := s.startSession(ctx, id)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("change password: %w", err)
	}
	return a, tokens, nil
}

func (s *Service) checkCurrentPassword(id, current, hash string) error {
	if !s.limits.passwordCheck.allow(id) {
		return ErrThrottled
	}
	if utf8.RuneCountInString(current) > maxPasswordLength {
		return ErrWrongPassword
	}
	ok, err := checkPassword(current, hash)
	if err != nil {
		return fmt.Errorf("check current password: %w", err)
	}
	if !ok {
		return ErrWrongPassword
	}
	return nil
}

func (s *Service) LinkGoogle(ctx context.Context, id, idToken string) (Account, error) {
	if s.google == nil {
		return Account{}, ErrGoogleUnavailable
	}
	identity, err := s.google.Verify(ctx, idToken)
	if err != nil {
		return Account{}, fmt.Errorf("link google: %w", err)
	}
	if err := s.store.AddGoogle(ctx, id, identity.Subject, identity.Email); err != nil {
		return Account{}, fmt.Errorf("link google: %w", err)
	}
	return s.Account(ctx, id)
}

func (s *Service) UnlinkGoogle(ctx context.Context, id string) (Account, error) {
	if err := s.store.RemoveGoogle(ctx, id); err != nil {
		return Account{}, fmt.Errorf("unlink google: %w", err)
	}
	return s.Account(ctx, id)
}
