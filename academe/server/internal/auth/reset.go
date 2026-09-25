package auth

import (
	"context"
	"crypto/rand"
	"crypto/subtle"
	"errors"
	"fmt"
	"math/big"
	"strings"
	"time"

	"academe/server/internal/email"
)

var (
	ErrThrottled         = errors.New("too many reset requests")
	ErrWrongCode         = errors.New("wrong reset code")
	ErrTooManyAttempts   = errors.New("reset code has no attempts left")
	ErrCodeExpired       = errors.New("reset code expired")
	ErrResetTokenExpired = errors.New("reset token expired or used")
)

const (
	resetCodeTTL      = 15 * time.Minute
	resetTokenTTL     = 15 * time.Minute
	maxResetAttempts  = 5
	codesPerEmailHour = 3
	requestsPerIPHour = 10
	verifiesPerIPHour = 30
	resetRowsKept     = 24 * time.Hour
)

type Mailer interface {
	SendReset(ctx context.Context, r email.Reset) error
	SendWelcome(ctx context.Context, w email.Welcome) error
}

type ResetCode struct {
	ID       string
	Hash     []byte
	Attempts int
	Expires  time.Time
}

type resetLimits struct {
	perEmail      *limiter
	requestIP     *limiter
	verifyIP      *limiter
	passwordCheck *limiter
}

func newResetLimits() resetLimits {
	return resetLimits{
		perEmail:      newLimiter(codesPerEmailHour, time.Hour),
		requestIP:     newLimiter(requestsPerIPHour, time.Hour),
		verifyIP:      newLimiter(verifiesPerIPHour, time.Hour),
		passwordCheck: newLimiter(passwordChecksPerHour, time.Hour),
	}
}

func (s *Service) RequestPasswordReset(ctx context.Context, address, ip string) error {
	address = normalizeEmail(address)
	if !s.limits.requestIP.allow(ip) {
		return ErrThrottled
	}
	if len(address) > maxEmailLength {
		return nil
	}
	if !s.limits.perEmail.allow(address) {
		return ErrThrottled
	}
	a, hash, err := s.store.AccountByEmail(ctx, address)
	if errors.Is(err, ErrNotFound) {
		return nil
	}
	if err != nil {
		return fmt.Errorf("request reset: %w", err)
	}
	if hash == "" {
		if err := s.mailer.SendReset(ctx, email.Reset{AccountID: a.ID, To: a.Email, GoogleOnly: true}); err != nil {
			s.logger.ErrorContext(ctx, "google reset notice not sent", "accountID", a.ID, "error", err)
		}
		return nil
	}
	code, err := newResetCode()
	if err != nil {
		return fmt.Errorf("request reset: %w", err)
	}
	link := newLinkToken()
	if err := s.store.CreateResetCode(ctx, a.ID, s.resetCodeHash(a.ID, code), hashToken(link), time.Now().Add(resetCodeTTL)); err != nil {
		return fmt.Errorf("request reset: %w", err)
	}
	if err := s.mailer.SendReset(ctx, email.Reset{AccountID: a.ID, To: a.Email, Code: code, LinkToken: link}); err != nil {
		s.logger.ErrorContext(ctx, "reset code not sent", "accountID", a.ID, "error", err)
	}
	return nil
}

func (s *Service) VerifyResetCode(ctx context.Context, address, code, ip string) (string, error) {
	if !s.limits.verifyIP.allow(ip) {
		return "", ErrThrottled
	}
	a, hash, err := s.store.AccountByEmail(ctx, normalizeEmail(address))
	if errors.Is(err, ErrNotFound) || (err == nil && hash == "") {
		return "", ErrCodeExpired
	}
	if err != nil {
		return "", fmt.Errorf("verify reset code: %w", err)
	}
	stored, err := s.store.ClaimResetAttempt(ctx, a.ID)
	if err != nil {
		return "", fmt.Errorf("verify reset code: %w", err)
	}
	switch {
	case stored.Attempts > maxResetAttempts:
		return "", ErrTooManyAttempts
	case !time.Now().Before(stored.Expires):
		return "", ErrCodeExpired
	}
	given := s.resetCodeHash(a.ID, strings.Join(strings.Fields(code), ""))
	if subtle.ConstantTimeCompare(given, stored.Hash) != 1 {
		if stored.Attempts == maxResetAttempts {
			return "", ErrTooManyAttempts
		}
		return "", ErrWrongCode
	}
	token := rand.Text()
	if err := s.store.MarkResetCodeUsed(ctx, stored.ID, hashToken(token), time.Now()); err != nil {
		return "", fmt.Errorf("verify reset code: %w", err)
	}
	return token, nil
}

func (s *Service) CompletePasswordReset(ctx context.Context, resetToken, password string) (Account, Tokens, error) {
	accountID, err := s.setPassword(ctx, resetToken, password)
	if err != nil {
		return Account{}, Tokens{}, err
	}
	a, err := s.store.AccountByID(ctx, accountID)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("complete reset: %w", err)
	}
	tokens, err := s.startSession(ctx, accountID)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("complete reset: %w", err)
	}
	return a, tokens, nil
}

func (s *Service) setPassword(ctx context.Context, resetToken, password string) (string, error) {
	if err := validatePassword(password); err != nil {
		return "", err
	}
	now := revocationTime()
	accountID, err := s.store.CompleteReset(ctx, hashToken(resetToken), now.Add(-resetTokenTTL), hashPassword(password), now)
	if err != nil {
		return "", fmt.Errorf("complete reset: %w", err)
	}
	s.revokeAccessTokens(accountID, now)
	return accountID, nil
}

func (s *Service) resetCodeHash(accountID, code string) []byte {
	return mac(s.tokenKey, "reset:"+accountID+":"+code)
}

func newResetCode() (string, error) {
	n, err := rand.Int(rand.Reader, big.NewInt(1_000_000))
	if err != nil {
		return "", fmt.Errorf("generate reset code: %w", err)
	}
	return fmt.Sprintf("%06d", n.Int64()), nil
}
