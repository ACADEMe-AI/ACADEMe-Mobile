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
		args = append(args, "code", r.Code, "link", ResetURL(r.LinkToken))
	}
	l.Logger.InfoContext(ctx, "reset code sent", args...)
	return nil
}

func (l Log) SendWelcome(ctx context.Context, w Welcome) error {
	l.Logger.InfoContext(ctx, "welcome email sent", "accountID", w.AccountID)
	return nil
}

func (l Log) SendDeletionNotice(ctx context.Context, _ string) error {
	l.Logger.InfoContext(ctx, "deletion notice sent")
	return nil
}

func (l Log) SendFeedback(ctx context.Context, t FeedbackTicket) error {
	l.Logger.InfoContext(ctx, "feedback ops email sent", "ticket", t.ID, "category", t.Category)
	return nil
}

func (l Log) SendFeedbackReceipt(ctx context.Context, t FeedbackTicket) error {
	l.Logger.InfoContext(ctx, "feedback receipt email sent", "ticket", t.ID)
	return nil
}
