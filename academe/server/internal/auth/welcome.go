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

func (s *Service) Welcome(ctx context.Context, accountID, language string) {
	ctx = context.WithoutCancel(ctx)
	s.background.Go(func() {
		ctx, cancel := context.WithTimeout(ctx, welcomeTimeout)
		defer cancel()
		a, err := s.store.AccountByID(ctx, accountID)
		if err != nil {
			s.logger.WarnContext(ctx, "welcome email skipped", "requestID", httpx.RequestID(ctx), "accountID", accountID, "error", err)
			return
		}
		if err := s.mailer.SendWelcome(ctx, email.Welcome{
			AccountID: a.ID, To: a.Email, FirstName: a.FirstName, Language: language,
		}); err != nil {
			s.logger.WarnContext(ctx, "welcome email not sent", "requestID", httpx.RequestID(ctx), "accountID", a.ID, "error", err)
		}
	})
}
