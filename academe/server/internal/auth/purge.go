package auth

import (
	"context"
	"log/slog"
	"time"
)

func (s *Service) PurgeEvery(ctx context.Context, logger *slog.Logger, every time.Duration) {
	ticker := time.NewTicker(every)
	defer ticker.Stop()
	for {
		n, err := s.PurgeDeleted(ctx)
		switch {
		case err != nil && ctx.Err() == nil:
			logger.ErrorContext(ctx, "purge failed", "error", err)
		case n > 0:
			logger.InfoContext(ctx, "accounts purged", "count", n)
		}
		if err := s.store.PurgeExpired(ctx, time.Now()); err != nil && ctx.Err() == nil {
			logger.ErrorContext(ctx, "purge expired sessions failed", "error", err)
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}
