package auth

import (
	"context"
	"log/slog"
	"time"

	"academe/server/internal/email"
	"academe/server/internal/httpx"
)

const welcomeTimeout = 30 * time.Second

func (s *Service) SetLogger(l *slog.Logger) { s.logger = l }

func (s *Service) Wait() { s.background.Wait() }

func (s *Service) welcome(ctx context.Context, a Account) {
	ctx = context.WithoutCancel(ctx)
	s.background.Go(func() {
		ctx, cancel := context.WithTimeout(ctx, welcomeTimeout)
		defer cancel()
		if err := s.mailer.SendWelcome(ctx, email.Welcome{AccountID: a.ID, To: a.Email, FirstName: a.FirstName}); err != nil {
			s.logger.WarnContext(ctx, "welcome email not sent", "requestID", httpx.RequestID(ctx), "accountID", a.ID, "error", err)
		}
	})
}
