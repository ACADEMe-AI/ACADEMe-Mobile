package providers

import (
	"context"
	"strings"

	"academe/server/internal/ai"
)

type Stub struct{}

func NewStub() *Stub { return &Stub{} }

func (Stub) Name() string { return "stub" }

func (Stub) Chat(_ context.Context, messages []ai.Message, _ float64) (string, error) {
	if len(messages) > 0 {
		system := messages[0].Content
		switch {
		case strings.Contains(system, "board examiner"):
			return `{"question":"Explain photosynthesis.","marks":3,"awarded":2,"points":[{"text":"Uses sunlight","marks":1,"awarded":1},{"text":"Uses chlorophyll","marks":1,"awarded":1},{"text":"Makes glucose","marks":1,"awarded":0}],"fullMarks":"Mention that sunlight and chlorophyll help the plant make glucose.","modelAnswer":"Photosynthesis uses sunlight and chlorophyll to make glucose."}`, nil
		case strings.Contains(system, "Turn the student's notes"):
			return `{"title":"Photosynthesis notes","cards":[{"kind":"start","goals":["Explain photosynthesis"],"minutes":4},{"kind":"concept","title":"Photosynthesis","body":"Plants use **sunlight** and chlorophyll to make food."},{"kind":"quiz","question":"What does photosynthesis make?","options":["Glucose","Salt"],"answer":0,"why":"Photosynthesis makes glucose for the plant."},{"kind":"summary","points":["Sunlight powers photosynthesis","Chlorophyll captures light","Glucose is made as food"]}]}`, nil
		case strings.Contains(system, "label study material"):
			return "Science · Ch 1 · Photosynthesis", nil
		}
	}
	return "Photosynthesis uses sunlight and chlorophyll to make glucose.", nil
}

func (Stub) Digitise(_ context.Context, pages []ai.Page, _ string) (string, error) {
	if len(pages) == 0 {
		return "", nil
	}
	return "Photosynthesis uses sunlight and chlorophyll to make glucose. Solve 3x + 2 = 8.", nil
}

func (Stub) Close() error { return nil }

var _ ai.Provider = (*Stub)(nil)
