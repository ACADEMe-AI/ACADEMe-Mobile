package auth

import (
	"context"
	"net/http"
	"strings"

	"academe/server/internal/httpx"
)

type accountKey struct{}

func (s *Service) RequireAccount(next httpx.HandlerFunc) httpx.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) error {
		token, ok := strings.CutPrefix(r.Header.Get("Authorization"), "Bearer ")
		if !ok {
			return toHTTP(ErrInvalidToken)
		}
		accountID, err := s.Authenticate(r.Context(), token)
		if err != nil {
			return toHTTP(err)
		}
		return next(w, r.WithContext(WithAccountID(r.Context(), accountID)))
	}
}

func WithAccountID(ctx context.Context, accountID string) context.Context {
	return context.WithValue(ctx, accountKey{}, accountID)
}

func AccountID(ctx context.Context) string {
	id, _ := ctx.Value(accountKey{}).(string)
	return id
}
