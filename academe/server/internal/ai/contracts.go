package ai

import "context"

type Message struct {
	Role    string `json:"role"`
	Content string `json:"content"`
}

type Page struct {
	Name string
	Data []byte
}

type Provider interface {
	Name() string
	Chat(context.Context, []Message, float64) (string, error)
	Digitise(context.Context, []Page, string) (string, error)
}
