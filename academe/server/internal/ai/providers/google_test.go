package providers

import (
	"context"
	"errors"
	"testing"

	"academe/server/internal/ai"
	"cloud.google.com/go/documentai/apiv1/documentaipb"
	"github.com/googleapis/gax-go/v2"
	"google.golang.org/genai"
)

type fakeText struct {
	model    string
	contents []*genai.Content
	response *genai.GenerateContentResponse
	err      error
}

func (f *fakeText) GenerateContent(_ context.Context, model string, contents []*genai.Content, _ *genai.GenerateContentConfig) (*genai.GenerateContentResponse, error) {
	f.model, f.contents = model, contents
	return f.response, f.err
}

type fakeDocument struct {
	requests []*documentaipb.ProcessRequest
	texts    []string
	err      error
}

func (f *fakeDocument) ProcessDocument(_ context.Context, request *documentaipb.ProcessRequest, _ ...gax.CallOption) (*documentaipb.ProcessResponse, error) {
	f.requests = append(f.requests, request)
	if f.err != nil {
		return nil, f.err
	}
	text := f.texts[len(f.requests)-1]
	return &documentaipb.ProcessResponse{Document: &documentaipb.Document{Text: text}}, nil
}

func TestGoogleChat(t *testing.T) {
	text := &fakeText{response: &genai.GenerateContentResponse{Candidates: []*genai.Candidate{{Content: genai.NewContentFromText("answer", genai.RoleModel)}}}}
	provider := NewGoogleForClients(text, nil, "processor", "gemini-test")

	got, err := provider.Chat(t.Context(), []ai.Message{{Role: "system", Content: "policy"}, {Role: "user", Content: "question"}}, 0.3)
	if err != nil {
		t.Fatal(err)
	}
	if got != "answer" {
		t.Fatalf("Chat() = %q, want answer", got)
	}
	if text.model != "gemini-test" || len(text.contents) != 1 || text.contents[0].Parts[0].Text != "question" {
		t.Fatalf("unexpected text request: %#v", text)
	}
}

func TestGoogleChatError(t *testing.T) {
	provider := NewGoogleForClients(&fakeText{err: errors.New("boom")}, nil, "processor", "gemini-test")
	if _, err := provider.Chat(t.Context(), []ai.Message{{Role: "user", Content: "question"}}, 0.3); err == nil {
		t.Fatal("Chat() succeeded, want error")
	}
}

func TestGoogleDigitise(t *testing.T) {
	document := &fakeDocument{texts: []string{"first", "second"}}
	provider := NewGoogleForClients(nil, document, "projects/p/locations/global/processors/ocr", "gemini-test")

	got, err := provider.Digitise(t.Context(), []ai.Page{{Name: "one.jpg", Data: []byte("one")}, {Name: "two.png", Data: []byte("two")}}, "hi")
	if err != nil {
		t.Fatal(err)
	}
	if got != "first\n\nsecond" {
		t.Fatalf("Digitise() = %q", got)
	}
	if len(document.requests) != 2 || document.requests[0].Name != "projects/p/locations/global/processors/ocr" {
		t.Fatalf("unexpected document requests: %#v", document.requests)
	}
	if got := document.requests[0].GetRawDocument().GetMimeType(); got != "image/jpeg" {
		t.Errorf("first MIME type = %q, want image/jpeg", got)
	}
	if got := document.requests[1].GetRawDocument().GetMimeType(); got != "image/png" {
		t.Errorf("second MIME type = %q, want image/png", got)
	}
	hints := document.requests[0].GetProcessOptions().GetOcrConfig().GetHints().GetLanguageHints()
	if len(hints) != 1 || hints[0] != "hi" {
		t.Errorf("language hints = %v, want [hi]", hints)
	}
}

func TestGoogleDigitiseSkipsEnglishHint(t *testing.T) {
	document := &fakeDocument{texts: []string{"page"}}
	provider := NewGoogleForClients(nil, document, "processor", "gemini-test")
	if _, err := provider.Digitise(t.Context(), []ai.Page{{Name: "one.jpg", Data: []byte("one")}}, "en-IN"); err != nil {
		t.Fatal(err)
	}
	if opts := document.requests[0].GetProcessOptions(); opts != nil && len(opts.GetOcrConfig().GetHints().GetLanguageHints()) > 0 {
		t.Errorf("ProcessOptions = %#v, want no OCR language hint for English", opts)
	}
}

func TestGoogleDigitiseAssameseUsesBengaliHint(t *testing.T) {
	document := &fakeDocument{texts: []string{"page"}}
	provider := NewGoogleForClients(nil, document, "processor", "gemini-test")
	if _, err := provider.Digitise(t.Context(), []ai.Page{{Name: "one.jpg", Data: []byte("one")}}, "as"); err != nil {
		t.Fatal(err)
	}
	hints := document.requests[0].GetProcessOptions().GetOcrConfig().GetHints().GetLanguageHints()
	if len(hints) != 1 || hints[0] != "bn" {
		t.Errorf("language hints = %v, want [bn]", hints)
	}
}

func TestGoogleDigitiseError(t *testing.T) {
	provider := NewGoogleForClients(nil, &fakeDocument{err: errors.New("boom")}, "processor", "gemini-test")
	if _, err := provider.Digitise(t.Context(), []ai.Page{{Name: "one.jpg"}}, "en"); !errors.Is(err, ai.ErrUnavailable) {
		t.Fatalf("Digitise() error = %v, want ai.ErrUnavailable", err)
	}
}

func TestDocumentAIEndpoint(t *testing.T) {
	tests := map[string]string{
		"projects/p/locations/asia-south1/processors/1": "asia-south1-documentai.googleapis.com",
		"projects/p/locations/us/processors/1":          "us-documentai.googleapis.com",
		"projects/p/locations/global/processors/1":      "documentai.googleapis.com",
		"": "documentai.googleapis.com",
	}
	for processor, want := range tests {
		if got := documentAIEndpoint(processor); got != want {
			t.Errorf("documentAIEndpoint(%q) = %q, want %q", processor, got, want)
		}
	}
}
