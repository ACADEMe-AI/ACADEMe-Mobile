package scan

import (
	"strings"
	"testing"
)

func TestScanPromptsFollowProfileLanguage(t *testing.T) {
	b := brief{class: 10, board: "CBSE", language: "hi"}
	chapter := ChapterPrompt(b)
	if !strings.Contains(chapter, "in Hindi") || strings.Contains(chapter, "in English:") {
		t.Errorf("ChapterPrompt() = %q, want Hindi reply language", chapter)
	}
	check := CheckPrompt(b)
	if !strings.Contains(check, "Hindi") || strings.Contains(check, "Write the text in English.") {
		t.Errorf("CheckPrompt() = %q, want Hindi teaching text", check)
	}
	lesson := LessonPrompt(b)
	if !strings.Contains(lesson, "Hindi") || strings.Contains(lesson, "Write in English.") {
		t.Errorf("LessonPrompt() = %q, want Hindi lesson cards", lesson)
	}

	en := brief{class: 9, board: "ICSE", language: "en"}
	if got := ChapterPrompt(en); !strings.Contains(got, "in English") {
		t.Errorf("ChapterPrompt(en) = %q, want English", got)
	}
}
