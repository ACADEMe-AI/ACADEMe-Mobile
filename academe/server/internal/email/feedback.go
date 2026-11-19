package email

import "context"

func (c *Resend) SendFeedback(ctx context.Context, t FeedbackTicket) error {
	m, err := t.opsMessage()
	if err != nil {
		return err
	}
	return c.sendTo(ctx, SupportAddress, t.StudentEmail, m)
}

func (c *Resend) SendFeedbackReceipt(ctx context.Context, t FeedbackTicket) error {
	m, err := t.receivedMessage()
	if err != nil {
		return err
	}
	return c.sendTo(ctx, t.StudentEmail, SupportAddress, m)
}
