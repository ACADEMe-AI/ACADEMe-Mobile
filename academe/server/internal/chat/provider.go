package chat

import (
	"context"

	"academe/server/internal/ai"
)

type Provider struct {
	provider ai.Provider
}

func NewProvider(provider ai.Provider) *Provider { return &Provider{provider: provider} }

func (p *Provider) Reply(ctx context.Context, brief Brief, history []Message) (string, error) {
	messages := make([]ai.Message, 0, len(history)+1)
	messages = append(messages, ai.Message{Role: "system", Content: SystemPrompt(brief)})
	for _, message := range history {
		role := "user"
		if message.Role == Pebby {
			role = "assistant"
		}
		messages = append(messages, ai.Message{Role: role, Content: message.Body})
	}
	return p.provider.Chat(ctx, messages, 0.3)
}
