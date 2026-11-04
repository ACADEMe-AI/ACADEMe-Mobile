package auth

import (
	"context"
	"crypto/rand"
	"encoding/base64"
	"errors"
	"fmt"
	"net/http"
	"time"

	"academe/server/internal/httpx"
)

const maxLinkTokenLength = 64

func newLinkToken() string {
	b := make([]byte, 16)
	_, _ = rand.Read(b)
	return base64.RawURLEncoding.EncodeToString(b)
}

func (s *Service) RedeemResetLink(ctx context.Context, linkToken, ip string) (string, error) {
	if !s.limits.verifyIP.allow(ip) {
		return "", ErrThrottled
	}
	if linkToken == "" || len(linkToken) > maxLinkTokenLength {
		return "", ErrResetTokenExpired
	}
	stored, err := s.store.ClaimResetLink(ctx, hashToken(linkToken))
	if err != nil {
		return "", fmt.Errorf("redeem reset link: %w", err)
	}
	switch {
	case stored.Attempts > maxResetAttempts:
		return "", ErrTooManyAttempts
	case !time.Now().Before(stored.Expires):
		return "", ErrResetTokenExpired
	}
	token := rand.Text()
	err = s.store.MarkResetCodeUsed(ctx, stored.ID, hashToken(token), time.Now())
	if errors.Is(err, ErrCodeExpired) {
		return "", ErrResetTokenExpired
	}
	if err != nil {
		return "", fmt.Errorf("redeem reset link: %w", err)
	}
	return token, nil
}

func (s *Service) ResetWithLink(ctx context.Context, linkToken, password, ip string) error {
	if err := validatePassword(password); err != nil {
		return err
	}
	token, err := s.RedeemResetLink(ctx, linkToken, ip)
	if err != nil {
		return err
	}
	_, err = s.setPassword(ctx, token, password)
	return err
}

type linkRequest struct {
	LinkToken string `json:"linkToken"`
}

func (h handler) redeemResetLink(w http.ResponseWriter, r *http.Request) error {
	var in linkRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	token, err := h.service.RedeemResetLink(r.Context(), in.LinkToken, clientIP(r))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, verified{token, int(resetTokenTTL.Seconds())})
	return nil
}
