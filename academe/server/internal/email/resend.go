package email

import (
	"bytes"
	"cmp"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

const (
	ResendURL   = "https://api.resend.com/emails"
	DefaultFrom = "ACADEMe <no-reply@academe.cc>"
)

type Resend struct {
	URL  string
	Key  string
	From string
	HTTP *http.Client
}

func NewResend(key, from string, client *http.Client) *Resend {
	return &Resend{URL: ResendURL, Key: key, From: cmp.Or(from, DefaultFrom), HTTP: client}
}

type resendRequest struct {
	From    string   `json:"from"`
	To      []string `json:"to"`
	ReplyTo string   `json:"reply_to"`
	Subject string   `json:"subject"`
	HTML    string   `json:"html"`
	Text    string   `json:"text"`
}

func (c *Resend) SendReset(ctx context.Context, r Reset) error {
	m, err := r.message()
	if err != nil {
		return err
	}
	return c.send(ctx, r.To, m)
}

func (c *Resend) SendWelcome(ctx context.Context, w Welcome) error {
	m, err := w.message()
	if err != nil {
		return err
	}
	return c.send(ctx, w.To, m)
}

func (c *Resend) SendDeletionNotice(ctx context.Context, to string) error {
	m, err := deletionMessage()
	if err != nil {
		return err
	}
	return c.send(ctx, to, m)
}

func (c *Resend) send(ctx context.Context, to string, m message) error {
	body, err := json.Marshal(resendRequest{From: c.From, To: []string{to}, ReplyTo: SupportAddress, Subject: m.Subject, HTML: m.HTML, Text: m.Text})
	if err != nil {
		return fmt.Errorf("encode resend request: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.URL, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("build resend request: %w", err)
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
