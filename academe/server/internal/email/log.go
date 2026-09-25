package email

import (
	"context"
	"log/slog"
)

type Log struct {
	Logger   *slog.Logger
	ShowCode bool
}

func (l Log) SendReset(ctx context.Context, r Reset) error {
	args := []any{"accountID", r.AccountID, "googleOnly", r.GoogleOnly}
	if l.ShowCode && r.Code != "" {
		args = append(args, "code", r.Code)
	}
	l.Logger.InfoContext(ctx, "reset code sent", args...)
	return nil
}
