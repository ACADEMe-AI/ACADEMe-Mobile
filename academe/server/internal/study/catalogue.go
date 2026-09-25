package study

import (
	"cmp"
	"context"
	"slices"
	"strconv"

	"academe/server/internal/profile"
)

type PlannedChapter struct {
	Board   string
	Class   int
	Subject string
	Number  int
	Title   string
	Unit    string
	Lessons []string

	FormativeOnly bool
}

func (p PlannedChapter) ID() string { return ChapterID(p.Board, p.Class, p.Subject, p.Number) }

func LessonID(chapterID string, position int) string {
	return chapterID + "-" + strconv.Itoa(position)
}

type ChapterSummary struct {
	ID          string          `json:"id"`
	Subject     string          `json:"subject"`
	SubjectName string          `json:"subjectName"`
	Number      int             `json:"number"`
	Title       string          `json:"title"`
	Unit        string          `json:"unit"`
	Lessons     []PlannedLesson `json:"lessons"`

	FormativeOnly bool `json:"formativeOnly,omitempty"`
}

type PlannedLesson struct {
	ID        string `json:"id"`
	Position  int    `json:"position"`
	Title     string `json:"title"`
	Available bool   `json:"available"`
}

func (s *Service) Chapters(ctx context.Context, accountID, subject string) ([]ChapterSummary, error) {
	class, board, ok, err := s.syllabus(ctx, accountID)
	if err != nil || !ok {
		return []ChapterSummary{}, err
	}
	names := map[string]string{}
	subjects, _ := profile.Subjects(class, board)
	for _, sub := range subjects {
		names[sub.ID] = sub.Name
	}
	wanted := func(b string, c int, sub string) bool {
		return b == board && c == class && (subject == "" || sub == subject) && names[sub] != ""
	}
	byID := map[string]*ChapterSummary{}
	var out []*ChapterSummary
	add := func(c ChapterSummary) *ChapterSummary {
		if got, ok := byID[c.ID]; ok {
			return got
		}
		byID[c.ID] = &c
		out = append(out, &c)
		return &c
	}
	for _, p := range s.plan {
		if !wanted(p.Board, p.Class, p.Subject) {
			continue
		}
		c := add(ChapterSummary{ID: p.ID(), Subject: p.Subject, SubjectName: names[p.Subject], Number: p.Number, Title: p.Title, Unit: p.Unit, Lessons: []PlannedLesson{}, FormativeOnly: p.FormativeOnly})
		for i, title := range p.Lessons {
			c.Lessons = append(c.Lessons, PlannedLesson{ID: LessonID(c.ID, i+1), Position: i + 1, Title: title})
		}
	}
	for _, d := range s.decks {
		if !wanted(d.Board, d.Class, d.Subject) || d.ChapterID() == "" {
			continue
		}
		c := add(ChapterSummary{ID: d.ChapterID(), Subject: d.Subject, SubjectName: names[d.Subject], Number: d.ChapterNumber, Title: d.ChapterTitle, Lessons: []PlannedLesson{}})
		lesson := PlannedLesson{ID: d.ID, Position: d.Position, Title: d.Title, Available: true}
		if i := slices.IndexFunc(c.Lessons, func(l PlannedLesson) bool { return l.Position == d.Position }); i >= 0 {
			c.Lessons[i] = lesson
		} else {
			c.Lessons = append(c.Lessons, lesson)
		}
	}
	result := make([]ChapterSummary, 0, len(out))
	for _, c := range out {
		slices.SortFunc(c.Lessons, func(a, b PlannedLesson) int { return cmp.Compare(a.Position, b.Position) })
		result = append(result, *c)
	}
	slices.SortStableFunc(result, func(a, b ChapterSummary) int {
		return cmp.Or(cmp.Compare(a.Subject, b.Subject), cmp.Compare(a.Number, b.Number))
	})
	return result, nil
}
