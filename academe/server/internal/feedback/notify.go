package feedback

import (
	"context"
	"log/slog"

	"academe/server/internal/email"
)

type StudentEmail func(ctx context.Context, accountID string) (string, error)

type Mailer interface {
	SendFeedback(ctx context.Context, t email.FeedbackTicket) error
	SendFeedbackReceipt(ctx context.Context, t email.FeedbackTicket) error
}

type Notifier struct {
	Mail  Mailer
	Email StudentEmail
	Log   *slog.Logger
}

func (n *Notifier) Deliver(ctx context.Context, accountID, id string, in Submission) {
	if n == nil || n.Mail == nil || n.Email == nil {
		return
	}
	to, err := n.Email(ctx, accountID)
	if err != nil || to == "" {
		if n.Log != nil {
			n.Log.WarnContext(ctx, "feedback email skipped", "error", err)
		}
		return
	}
	t := email.FeedbackTicket{
		ID: id, StudentEmail: to, Category: string(in.Category), Message: in.Message,
	}
	if err := n.Mail.SendFeedback(ctx, t); err != nil && n.Log != nil {
		n.Log.WarnContext(ctx, "feedback email failed", "error", err)
	}
	if err := n.Mail.SendFeedbackReceipt(ctx, t); err != nil && n.Log != nil {
		n.Log.WarnContext(ctx, "feedback receipt email failed", "error", err)
	}
}
