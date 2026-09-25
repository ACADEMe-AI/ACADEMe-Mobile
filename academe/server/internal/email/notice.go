package email

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const SupportAddress = "support@academe.cc"

type noticeRequest struct {
	From    string   `json:"from"`
	To      []string `json:"to"`
	ReplyTo string   `json:"reply_to"`
	Subject string   `json:"subject"`
	Text    string   `json:"text"`
}

func (c *Resend) SendNotice(ctx context.Context, to, subject, text string) error {
	body, err := json.Marshal(noticeRequest{From: c.From, To: []string{to}, ReplyTo: SupportAddress, Subject: subject, Text: text})
	if err != nil {
		return fmt.Errorf("encode notice: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.URL, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("build notice request: %w", err)
	}
	req.Header.Set("Authorization", "Bearer "+c.Key)
	req.Header.Set("Content-Type", "application/json")
	res, err := c.HTTP.Do(req)
	if err != nil {
		return fmt.Errorf("call resend: %w", err)
	}
	defer res.Body.Close() //nolint:errcheck
	if res.StatusCode/100 != 2 {
		detail, _ := io.ReadAll(io.LimitReader(res.Body, 512))
		return fmt.Errorf("resend status %d: %s", res.StatusCode, detail)
	}
	return nil
}

func (l Log) SendNotice(ctx context.Context, _, subject, _ string) error {
	l.Logger.InfoContext(ctx, "notice sent", "subject", subject)
	return nil
}
