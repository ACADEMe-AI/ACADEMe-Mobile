package providers

import (
	"context"
	"errors"
	"fmt"
	"path/filepath"
	"strings"

	"academe/server/internal/ai"
	"cloud.google.com/go/documentai/apiv1"
	"cloud.google.com/go/documentai/apiv1/documentaipb"
	"github.com/googleapis/gax-go/v2"
	"google.golang.org/api/option"
	"google.golang.org/genai"
)

type textClient interface {
	GenerateContent(context.Context, string, []*genai.Content, *genai.GenerateContentConfig) (*genai.GenerateContentResponse, error)
}

type documentClient interface {
	ProcessDocument(context.Context, *documentaipb.ProcessRequest, ...gax.CallOption) (*documentaipb.ProcessResponse, error)
}

type Google struct {
	text      textClient
	document  documentClient
	processor string
	model     string
	close     func() error
}

type Config struct {
	Project   string
	Location  string
	Model     string
	Processor string
}

func NewGoogle(ctx context.Context, cfg Config) (*Google, error) {
	if cfg.Project == "" {
		return nil, errors.New("google project is not configured")
	}
	if cfg.Location == "" {
		return nil, errors.New("google location is not configured")
	}
	if cfg.Model == "" {
		return nil, errors.New("google model is not configured")
	}
	if cfg.Processor == "" {
		return nil, errors.New("google document processor is not configured")
	}
	google, err := newGoogleText(ctx, cfg)
	if err != nil {
		return nil, err
	}
	document, err := documentai.NewDocumentProcessorClient(ctx, option.WithEndpoint(documentAIEndpoint(cfg.Processor)))
	if err != nil {
		return nil, fmt.Errorf("create google document ai client: %w", err)
	}
	google.document, google.processor, google.close = document, cfg.Processor, func() error { return document.Close() }
	return google, nil
}

func documentAIEndpoint(processor string) string {
	parts := strings.Split(processor, "/")
	for i, part := range parts[:max(0, len(parts)-1)] {
		if part == "locations" && i+1 < len(parts) {
			location := parts[i+1]
			if location == "global" {
				return "documentai.googleapis.com"
			}
			return location + "-documentai.googleapis.com"
		}
	}
	return "documentai.googleapis.com"
}

func NewGoogleText(ctx context.Context, cfg Config) (*Google, error) {
	if cfg.Processor != "" {
		return NewGoogle(ctx, cfg)
	}
	return newGoogleText(ctx, cfg)
}

func newGoogleText(ctx context.Context, cfg Config) (*Google, error) {
	if cfg.Project == "" {
		return nil, errors.New("google project is not configured")
	}
	if cfg.Location == "" {
		return nil, errors.New("google location is not configured")
	}
	if cfg.Model == "" {
		return nil, errors.New("google model is not configured")
	}
	genConfig := &genai.ClientConfig{Backend: genai.BackendVertexAI, Project: cfg.Project, Location: cfg.Location}
	if err := genConfig.UseDefaultCredentials(); err != nil {
		return nil, fmt.Errorf("configure google credentials: %w", err)
	}
	text, err := genai.NewClient(ctx, genConfig)
	if err != nil {
		return nil, fmt.Errorf("create google genai client: %w", err)
	}
	return &Google{text: text.Models, model: cfg.Model}, nil
}

func NewGoogleForClients(text textClient, document documentClient, processor, model string) *Google {
	return &Google{text: text, document: document, processor: processor, model: model}
}

func (g *Google) Name() string { return "google" }

func (g *Google) Close() error {
	if g.close == nil {
		return nil
	}
	return g.close()
}

func (g *Google) Chat(ctx context.Context, messages []ai.Message, temperature float64) (string, error) {
	if g.text == nil {
		return "", ai.ErrUnavailable
	}
	var system *genai.Content
	contents := make([]*genai.Content, 0, len(messages))
	for _, message := range messages {
		if message.Role == "system" && system == nil {
			system = genai.NewContentFromText(message.Content, "")
			continue
		}
		var role genai.Role = genai.RoleUser
		if message.Role == "assistant" || message.Role == "model" {
			role = genai.RoleModel
		}
		contents = append(contents, genai.NewContentFromText(message.Content, role))
	}
	temperature32 := float32(temperature)
	config := &genai.GenerateContentConfig{SystemInstruction: system, Temperature: &temperature32, MaxOutputTokens: 2048}
	response, err := g.text.GenerateContent(ctx, g.model, contents, config)
	if err != nil {
		return "", googleError(err)
	}
	answer := strings.TrimSpace(response.Text())
	if answer == "" {
		return "", errors.New("google returned no answer")
	}
	return answer, nil
}

func (g *Google) Digitise(ctx context.Context, pages []ai.Page, language string) (string, error) {
	if g.document == nil {
		return "", ai.ErrUnavailable
	}
	var parts []string
	options := ocrProcessOptions(language)
	for _, page := range pages {
		mime := mimeType(page.Name)
		result, err := g.document.ProcessDocument(ctx, &documentaipb.ProcessRequest{
			Name: g.processor,
			Source: &documentaipb.ProcessRequest_RawDocument{RawDocument: &documentaipb.RawDocument{
				Content: page.Data, MimeType: mime, DisplayName: filepath.Base(page.Name),
			}},
			ProcessOptions: options,
		})
		if err != nil {
			return "", fmt.Errorf("google document ai: %w", ai.ErrUnavailable)
		}
		if result.GetDocument() != nil && strings.TrimSpace(result.GetDocument().GetText()) != "" {
			parts = append(parts, strings.TrimSpace(result.GetDocument().GetText()))
		}
	}
	return strings.TrimSpace(strings.Join(parts, "\n\n")), nil
}

func ocrProcessOptions(language string) *documentaipb.ProcessOptions {
	hint := ocrLanguageHint(language)
	if hint == "" {
		return nil
	}
	return &documentaipb.ProcessOptions{
		OcrConfig: &documentaipb.OcrConfig{
			Hints: &documentaipb.OcrConfig_Hints{LanguageHints: []string{hint}},
		},
	}
}

func ocrLanguageHint(language string) string {
	code := strings.TrimSpace(language)
	if i := strings.IndexByte(code, '-'); i >= 0 {
		code = code[:i]
	}
	switch strings.ToLower(code) {
	case "hi", "te", "ta", "bn":
		return strings.ToLower(code)
	default:
		return ""
	}
}

func mimeType(name string) string {
	switch strings.ToLower(filepath.Ext(name)) {
	case ".png":
		return "image/png"
	case ".pdf":
		return "application/pdf"
	default:
		return "image/jpeg"
	}
}

func googleError(err error) error {
	var apiErr genai.APIError
	if errors.As(err, &apiErr) {
		return &ai.StatusError{Provider: "google", Code: apiErr.Code, Detail: apiErr.Message}
	}
	return fmt.Errorf("google genai: %w", err)
}

var _ ai.Provider = (*Google)(nil)
