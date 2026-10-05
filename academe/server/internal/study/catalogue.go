package study

import (
	"cmp"
	"context"
	"slices"
	"strconv"
	"time"

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
	Marks   int

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

	FormativeOnly bool       `json:"formativeOnly,omitempty"`
	Marks         int        `json:"marks,omitempty"`
	RevisionDue   int        `json:"revisionDue"`
	LastStudiedAt *time.Time `json:"lastStudiedAt,omitempty"`
}

type PlannedLesson struct {
	ID        string `json:"id"`
	Position  int    `json:"position"`
	Title     string `json:"title"`
	Available bool   `json:"available"`
	Minutes   int    `json:"minutes,omitempty"`
}

type SubjectSummary struct {
	ID               string `json:"id"`
	Name             string `json:"name"`
	Chapters         int    `json:"chapters"`
	LessonsAvailable int    `json:"lessonsAvailable"`
	LessonsDone      int    `json:"lessonsDone"`
}

type Catalogue struct {
	Decks    []LessonSummary  `json:"decks"`
	Chapters []ChapterSummary `json:"chapters"`
	Subjects []SubjectSummary `json:"subjects"`
}

type activity struct {
	done      map[string]Completion
	positions map[string]int
	kept      []Kept
}

func (s *Service) activity(ctx context.Context, accountID string) (activity, error) {
	var a activity
	var err error
	if a.done, err = s.store.Completions(ctx, accountID); err != nil {
		return activity{}, err
	}
	if a.positions, err = s.store.Positions(ctx, accountID); err != nil {
		return activity{}, err
	}
	if a.kept, err = s.store.KeptCards(ctx, accountID); err != nil {
		return activity{}, err
	}
	return a, nil
}

func (s *Service) Catalogue(ctx context.Context, accountID, subject string) (Catalogue, error) {
	out := Catalogue{Decks: []LessonSummary{}, Chapters: []ChapterSummary{}, Subjects: []SubjectSummary{}}
	class, board, ok, err := s.syllabus(ctx, accountID)
	if err != nil || !ok {
		return out, err
	}
	a, err := s.activity(ctx, accountID)
	if err != nil {
		return Catalogue{}, err
	}
	subjects, _ := profile.Subjects(class, board)
	names := map[string]string{}
	for _, sub := range subjects {
		names[sub.ID] = sub.Name
	}
	out.Decks = append(out.Decks, s.lessons(class, board, subject, names, a)...)
	out.Chapters = s.chapters(class, board, subject, names, a)
	for _, sub := range subjects {
		if subject == "" || sub.ID == subject {
			out.Subjects = append(out.Subjects, summarize(sub, out.Chapters, a.done))
		}
	}
	return out, nil
}

func summarize(sub profile.Subject, chapters []ChapterSummary, done map[string]Completion) SubjectSummary {
	out := SubjectSummary{ID: sub.ID, Name: sub.Name}
	for _, c := range chapters {
		if c.Subject != sub.ID {
			continue
		}
		out.Chapters++
		for _, l := range c.Lessons {
			if !l.Available {
				continue
			}
			out.LessonsAvailable++
			if _, ok := done[l.ID]; ok {
				out.LessonsDone++
			}
		}
	}
	return out
}

func (s *Service) chapters(class int, board, subject string, names map[string]string, act activity) []ChapterSummary {
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
		c := add(ChapterSummary{ID: p.ID(), Subject: p.Subject, SubjectName: names[p.Subject], Number: p.Number, Title: p.Title, Unit: p.Unit, Lessons: []PlannedLesson{}, FormativeOnly: p.FormativeOnly, Marks: p.Marks})
		for i, title := range p.Lessons {
			c.Lessons = append(c.Lessons, PlannedLesson{ID: LessonID(c.ID, i+1), Position: i + 1, Title: title})
		}
	}
	for _, d := range s.decks {
		if !wanted(d.Board, d.Class, d.Subject) || d.ChapterID() == "" {
			continue
		}
		c := add(ChapterSummary{ID: d.ChapterID(), Subject: d.Subject, SubjectName: names[d.Subject], Number: d.ChapterNumber, Title: d.ChapterTitle, Lessons: []PlannedLesson{}})
		lesson := PlannedLesson{ID: d.ID, Position: d.Position, Title: d.Title, Available: true, Minutes: d.Minutes()}
		if at, ok := act.done[d.ID]; ok && (c.LastStudiedAt == nil || at.At.After(*c.LastStudiedAt)) {
			c.LastStudiedAt = &at.At
		}
		if i := slices.IndexFunc(c.Lessons, func(l PlannedLesson) bool { return l.Position == d.Position }); i >= 0 {
			c.Lessons[i] = lesson
		} else {
			c.Lessons = append(c.Lessons, lesson)
		}
	}
	now := s.now()
	for _, k := range act.kept {
		if k.DueAt.After(now) {
			continue
		}
		if d, ok := s.libraryDeck(k.DeckID); ok {
			if c, ok := byID[d.ChapterID()]; ok {
				c.RevisionDue++
			}
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
	return result
}
