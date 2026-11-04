package chat

import (
	"context"
	"fmt"
	"strings"

	"academe/server/internal/sarvam"
)

var languageNames = map[string]string{
	"en": "English",
	"hi": "Hindi",
	"te": "Telugu",
	"ta": "Tamil",
	"bn": "Bengali",
}

type Sarvam struct {
	client *sarvam.Client
}

func NewSarvam(client *sarvam.Client) *Sarvam {
	return &Sarvam{client: client}
}

func (s *Sarvam) Reply(ctx context.Context, brief Brief, history []Message) (string, error) {
	messages := []sarvam.Message{{Role: "system", Content: SystemPrompt(brief)}}
	for _, m := range history {
		role := "user"
		if m.Role == Pebby {
			role = "assistant"
		}
		messages = append(messages, sarvam.Message{Role: role, Content: m.Body})
	}
	return s.client.Chat(ctx, messages, 0.3)
}

func SystemPrompt(b Brief) string {
	language := languageNames[b.Language]
	if language == "" {
		language = "English"
	}
	var sb strings.Builder
	sb.WriteString("You are Pebby, the friendly study buddy inside ACADEMe, a learning app for Indian school students. ")
	fmt.Fprintf(&sb, "You are talking to %s", b.FirstName)
	if b.Class > 0 && b.Board != "" {
		fmt.Fprintf(&sb, ", a Class %d %s student", b.Class, b.Board)
	}
	sb.WriteString(". Follow their board's syllabus and use examples from Indian daily life. ")
	fmt.Fprintf(&sb, "Always answer in %s. Keep exam and science terms in English in brackets when you answer in another language. ", language)
	sb.WriteString("Keep answers short: a one-line idea, then numbered steps, then one everyday example if it helps. Use plain text and simple Markdown only. ")
	sb.WriteString("Never help with anything unsafe or unrelated to studying; gently steer back to learning. ")
	switch b.Mode {
	case Solve:
		sb.WriteString("Mode: Solve. Do not give the final answer straight away. Give one hint at a time and ask the student for their next step. Only give the full worked solution if they ask for it.")
	case Quiz:
		sb.WriteString("Mode: Quiz me. Ask one question at a time about the topic the student names, at their class level. After they answer, say clearly whether it was right, explain why in one or two lines, then ask the next question.")
	default:
		sb.WriteString("Mode: Explain. Teach the idea clearly, then check understanding with one short question at the end.")
	}
	return sb.String()
}
