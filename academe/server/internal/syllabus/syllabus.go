package syllabus

import (
	"bytes"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"path"
	"slices"
	"strconv"
	"strings"

	"academe/server/internal/profile"
	"academe/server/internal/study"
)

type Syllabus struct {
	Board    string    `json:"board"`
	Class    int       `json:"class"`
	Session  string    `json:"session"`
	Sources  []Source  `json:"sources"`
	Subjects []Subject `json:"subjects"`
}

type Source struct {
	Title string `json:"title"`
	URL   string `json:"url"`
}

type Subject struct {
	Subject  string    `json:"subject"`
	Name     string    `json:"name"`
	Book     string    `json:"book"`
	Chapters []Chapter `json:"chapters"`
}

type Chapter struct {
	Number   int             `json:"number"`
	Title    string          `json:"title"`
	Unit     string          `json:"unit"`
	Marks    json.RawMessage `json:"marks,omitempty"`
	Outcomes []string        `json:"outcomes"`
	Topics   []string        `json:"topics"`
	Lessons  []Lesson        `json:"lessons"`
	Source   string          `json:"source"`
}

type Lesson struct {
	Title  string   `json:"title"`
	Topics []string `json:"topics"`
}

var ErrInvalid = errors.New("invalid syllabus")

//go:embed data/*.json
var dataFiles embed.FS

func Load() ([]Syllabus, error) {
	sub, err := fs.Sub(dataFiles, "data")
	if err != nil {
		return nil, fmt.Errorf("open syllabus data: %w", err)
	}
	return Read(sub)
}

func Read(fsys fs.FS) ([]Syllabus, error) {
	paths, err := fs.Glob(fsys, "*.json")
	if err != nil {
		return nil, fmt.Errorf("list syllabus files: %w", err)
	}
	var out []Syllabus
	var problems []error
	for _, p := range paths {
		s, err := readFile(fsys, p)
		if err != nil {
			problems = append(problems, err)
			continue
		}
		out = append(out, s)
	}
	return out, errors.Join(problems...)
}

func readFile(fsys fs.FS, p string) (Syllabus, error) {
	raw, err := fs.ReadFile(fsys, p)
	if err != nil {
		return Syllabus{}, fmt.Errorf("read %s: %w", p, err)
	}
	dec := json.NewDecoder(bytes.NewReader(raw))
	dec.DisallowUnknownFields()
	var s Syllabus
	if err := dec.Decode(&s); err != nil {
		return Syllabus{}, fmt.Errorf("%w: %s: %w", ErrInvalid, p, err)
	}
	s.Board = strings.ToUpper(s.Board)
	if want := strings.ToLower(s.Board) + "-" + strconv.Itoa(s.Class) + ".json"; path.Base(p) != want {
		return Syllabus{}, fmt.Errorf("%w: %s: board %q class %d belongs in %s", ErrInvalid, p, s.Board, s.Class, want)
	}
	if err := Validate(s); err != nil {
		return Syllabus{}, fmt.Errorf("%s: %w", p, err)
	}
	return s, nil
}

func Validate(s Syllabus) error {
	var problems []error
	bad := func(format string, args ...any) {
		problems = append(problems, fmt.Errorf("%w: %s", ErrInvalid, fmt.Sprintf(format, args...)))
	}
	allowed, ok := profile.Subjects(s.Class, s.Board)
	if !ok {
		bad("board %q class %d is not a board and class we teach", s.Board, s.Class)
	}
	if len(s.Subjects) == 0 {
		bad("no subjects")
	}
	seenSubjects := map[string]bool{}
	for _, sub := range s.Subjects {
		if !slices.ContainsFunc(allowed, func(a profile.Subject) bool { return a.ID == sub.Subject }) {
			bad("subject %q is not taught in %s class %d", sub.Subject, s.Board, s.Class)
		}
		if seenSubjects[sub.Subject] {
			bad("subject %q appears twice", sub.Subject)
		}
		seenSubjects[sub.Subject] = true
		if len(sub.Chapters) == 0 {
			bad("%s: no chapters", sub.Subject)
		}
		numbers := map[int]bool{}
		for _, c := range sub.Chapters {
			at := fmt.Sprintf("%s chapter %d %q", sub.Subject, c.Number, c.Title)
			if c.Number < 1 || numbers[c.Number] {
				bad("%s: chapter number must be positive and unique", at)
			}
			numbers[c.Number] = true
			if strings.TrimSpace(c.Title) == "" {
				bad("%s: no title", at)
			}
			if len(c.Lessons) == 0 {
				bad("%s: no lessons", at)
			}
			for _, msg := range topicProblems(c) {
				bad("%s: %s", at, msg)
			}
		}
	}
	return errors.Join(problems...)
}

func topicProblems(c Chapter) []string {
	var out []string
	home := map[string]int{}
	for i, l := range c.Lessons {
		if strings.TrimSpace(l.Title) == "" {
			out = append(out, fmt.Sprintf("lesson %d has no title", i+1))
		}
		if len(l.Topics) == 0 {
			out = append(out, fmt.Sprintf("lesson %d %q has no topics", i+1, l.Title))
		}
		for _, t := range l.Topics {
			if !slices.Contains(c.Topics, t) {
				out = append(out, fmt.Sprintf("lesson %d topic %q is not in the chapter topics", i+1, t))
			}
			if prev, ok := home[t]; ok {
				out = append(out, fmt.Sprintf("topic %q is in lessons %d and %d", t, prev, i+1))
			}
			home[t] = i + 1
		}
	}
	for _, t := range c.Topics {
		if _, ok := home[t]; !ok {
			out = append(out, fmt.Sprintf("topic %q is in no lesson", t))
		}
	}
	return out
}

func Plan(syllabi []Syllabus) []study.PlannedChapter {
	var out []study.PlannedChapter
	for _, s := range syllabi {
		for _, sub := range s.Subjects {
			for _, c := range sub.Chapters {
				p := study.PlannedChapter{
					Board: s.Board, Class: s.Class, Subject: sub.Subject, Number: c.Number, Title: c.Title, Unit: c.Unit,
					FormativeOnly: strings.Contains(strings.ToLower(c.Unit), "formative assessment only"),
				}
				for _, l := range c.Lessons {
					p.Lessons = append(p.Lessons, l.Title)
				}
				out = append(out, p)
			}
		}
	}
	return out
}
