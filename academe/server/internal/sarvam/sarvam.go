package sarvam

import (
	"archive/zip"
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"mime/multipart"
	"net/http"
	"path"
	"strings"
	"time"
)

const (
	ChatURL = "https://api.sarvam.ai/v1/chat/completions"
	DocURL  = "https://api.sarvam.ai/doc-ai/v1"
)

var ErrTimeout = errors.New("sarvam took too long")

type StatusError struct {
	Code   int
	Detail string
}

func (e *StatusError) Error() string { return fmt.Sprintf("sarvam status %d: %s", e.Code, e.Detail) }

type Client struct {
	ChatURL   string
	DocURL    string
	Key       string
	Model     string
	HTTP      *http.Client
	Poll      time.Duration
	Deadline  time.Duration
	MaxTokens int
	Reasoning json.RawMessage
	JSON      bool
}

func New(key, model string, client *http.Client) *Client {
	return &Client{ChatURL: ChatURL, DocURL: DocURL, Key: key, Model: model, HTTP: client, Poll: time.Second, Deadline: 45 * time.Second}
}

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type chatRequest struct {
	Model       string          `json:"model"`
	Messages    []Message       `json:"messages"`
	Temperature float64         `json:"temperature"`
	MaxTokens   int             `json:"max_tokens,omitempty"`
	Reasoning   json.RawMessage `json:"reasoning_effort,omitempty"`
	Format      *responseFormat `json:"response_format,omitempty"`
}

type responseFormat struct {
	Type string `json:"type"`
}

type chatResponse struct {
	Choices []struct {
		Message Message `json:"message"`
	} `json:"choices"`
}

func (c *Client) do(req *http.Request, out any) error {
	req.Header.Set("api-subscription-key", c.Key)
	res, err := c.HTTP.Do(req)
	if err != nil {
		return fmt.Errorf("call sarvam: %w", err)
	}
	defer res.Body.Close() //nolint:errcheck
	if res.StatusCode/100 != 2 {
		detail, _ := io.ReadAll(io.LimitReader(res.Body, 512))
		return &StatusError{Code: res.StatusCode, Detail: string(detail)}
	}
	if err := json.NewDecoder(io.LimitReader(res.Body, 4<<20)).Decode(out); err != nil {
		return fmt.Errorf("decode sarvam response: %w", err)
	}
	return nil
}

func (c *Client) Chat(ctx context.Context, messages []Message, temperature float64) (string, error) {
	payload := chatRequest{Model: c.Model, Messages: messages, Temperature: temperature, MaxTokens: c.MaxTokens, Reasoning: c.Reasoning}
	if c.JSON {
		payload.Format = &responseFormat{Type: "json_object"}
	}
	body, err := json.Marshal(payload)
	if err != nil {
		return "", fmt.Errorf("encode sarvam request: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.ChatURL, bytes.NewReader(body))
	if err != nil {
		return "", fmt.Errorf("build sarvam request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	var out chatResponse
	if err := c.do(req, &out); err != nil {
		return "", err
	}
	if len(out.Choices) == 0 || strings.TrimSpace(out.Choices[0].Message.Content) == "" {
		return "", errors.New("sarvam returned no answer")
	}
	return strings.TrimSpace(out.Choices[0].Message.Content), nil
}

type Page struct {
	Name string
	Data []byte
}

func zipPages(pages []Page) ([]byte, error) {
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	for i, p := range pages {
		w, err := zw.Create(fmt.Sprintf("page_%03d%s", i+1, path.Ext(p.Name)))
		if err != nil {
			return nil, fmt.Errorf("zip page: %w", err)
		}
		if _, err := w.Write(p.Data); err != nil {
			return nil, fmt.Errorf("zip page: %w", err)
		}
	}
	if err := zw.Close(); err != nil {
		return nil, fmt.Errorf("zip pages: %w", err)
	}
	return buf.Bytes(), nil
}

func (c *Client) Digitise(ctx context.Context, pages []Page, language string) (string, error) {
	archive, err := zipPages(pages)
	if err != nil {
		return "", err
	}
	var form bytes.Buffer
	mw := multipart.NewWriter(&form)
	fw, err := mw.CreateFormFile("file", "scan.zip")
	if err != nil {
		return "", fmt.Errorf("build form: %w", err)
	}
	if _, err := fw.Write(archive); err != nil {
		return "", fmt.Errorf("build form: %w", err)
	}
	_ = mw.WriteField("language", language)
	_ = mw.WriteField("output_format", "md")
	if err := mw.Close(); err != nil {
		return "", fmt.Errorf("build form: %w", err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.DocURL+"/job/digitise", &form)
	if err != nil {
		return "", fmt.Errorf("build digitise request: %w", err)
	}
	req.Header.Set("Content-Type", mw.FormDataContentType())
	var job struct {
		JobID string `json:"job_id"`
	}
	if err := c.do(req, &job); err != nil {
		return "", err
	}
	if err := c.wait(ctx, job.JobID); err != nil {
		return "", err
	}
	return c.download(ctx, job.JobID)
}

func (c *Client) get(ctx context.Context, url string, out any) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("build sarvam request: %w", err)
	}
	return c.do(req, out)
}

func (c *Client) wait(ctx context.Context, jobID string) error {
	ctx, cancel := context.WithTimeout(ctx, c.Deadline)
	defer cancel()
	for {
		var status struct {
			Status string `json:"status"`
		}
		if err := c.get(ctx, c.DocURL+"/job/"+jobID+"/status", &status); err != nil {
			if ctx.Err() != nil {
				return ErrTimeout
			}
			return err
		}
		switch status.Status {
		case "completed", "partially_completed":
			return nil
		case "failed", "rejected":
			return fmt.Errorf("sarvam digitise %s", status.Status)
		}
		select {
		case <-ctx.Done():
			return ErrTimeout
		case <-time.After(c.Poll):
		}
	}
}

func (c *Client) download(ctx context.Context, jobID string) (string, error) {
	var link struct {
		URL string `json:"url"`
	}
	if err := c.get(ctx, c.DocURL+"/job/"+jobID+"/download-url", &link); err != nil {
		return "", err
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, link.URL, nil)
	if err != nil {
		return "", fmt.Errorf("build download request: %w", err)
	}
	res, err := c.HTTP.Do(req)
	if err != nil {
		return "", fmt.Errorf("download digitised text: %w", err)
	}
	defer res.Body.Close() //nolint:errcheck
	raw, err := io.ReadAll(io.LimitReader(res.Body, 20<<20))
	if err != nil {
		return "", fmt.Errorf("read digitised text: %w", err)
	}
	return markdownFromZip(raw)
}

func markdownFromZip(raw []byte) (string, error) {
	zr, err := zip.NewReader(bytes.NewReader(raw), int64(len(raw)))
	if err != nil {
		return "", fmt.Errorf("open digitised zip: %w", err)
	}
	for _, f := range zr.File {
		if strings.HasPrefix(f.Name, "metadata/") || path.Ext(f.Name) != ".md" {
			continue
		}
		r, err := f.Open()
		if err != nil {
			return "", fmt.Errorf("open %s: %w", f.Name, err)
		}
		text, err := io.ReadAll(io.LimitReader(r, 4<<20))
		_ = r.Close()
		if err != nil {
			return "", fmt.Errorf("read %s: %w", f.Name, err)
		}
		return strings.TrimSpace(string(text)), nil
	}
	return "", errors.New("no text in the digitised zip")
}
