package syllabus

import (
	"errors"
	"fmt"
	"os"
	"slices"
	"strings"
	"testing"
	"testing/fstest"

	"academe/server/internal/profile"
	"academe/server/internal/study"
)

func TestRealDataIsValid(t *testing.T) {
	syllabi, err := Load()
	if err != nil {
		t.Fatalf("Load() error:\n%v", err)
	}
	if len(syllabi) != 14 {
		t.Errorf("Load() = %d syllabi, want CBSE and ICSE for classes 6 to 12", len(syllabi))
	}
	seen := map[string]bool{}
	var formative []string
	taught := map[string]bool{}
	for _, p := range Plan(syllabi) {
		if seen[p.ID()] {
			t.Errorf("chapter %s appears twice", p.ID())
		}
		seen[p.ID()] = true
		taught[fmt.Sprint(p.Board, p.Class, p.Subject)] = true
		if p.FormativeOnly {
			formative = append(formative, p.ID())
		}
	}
	if len(formative) != 13 || !slices.Contains(formative, "cbse-10-science-14") || !slices.Contains(formative, "cbse-12-chemistry-13") {
		t.Errorf("formative-only chapters = %v, want the 13 CBSE reading-material chapters", formative)
	}
	for _, s := range syllabi {
		subjects, _ := profile.Subjects(s.Class, s.Board)
		for _, sub := range subjects {
			if !taught[fmt.Sprint(s.Board, s.Class, sub.ID)] {
				t.Errorf("%s class %d: subject %s has no chapters", s.Board, s.Class, sub.ID)
			}
		}
	}
	decks, err := study.Library()
	if err != nil {
		t.Fatalf("study.Library() error = %v", err)
	}
	lessons := map[string]bool{}
	for _, p := range Plan(syllabi) {
		for i := range p.Lessons {
			lessons[study.LessonID(p.ID(), i+1)] = true
		}
	}
	for _, d := range decks {
		if seen[d.ChapterID()] && !lessons[d.ID] {
			t.Errorf("deck %s is in syllabus chapter %s but at no planned lesson position", d.ID, d.ChapterID())
		}
	}
}

func TestFixtureLoads(t *testing.T) {
	syllabi, err := Read(os.DirFS("testdata"))
	if err != nil {
		t.Fatalf("Read(testdata) error = %v", err)
	}
	plan := Plan(syllabi)
	if len(plan) != 2 || plan[0].ID() != "cbse-10-science-1" || len(plan[0].Lessons) != 4 || plan[1].ID() != "cbse-10-maths-1" {
		t.Fatalf("Plan(testdata) = %+v, want science 1 with four lessons then maths 1", plan)
	}
	if syllabi[0].Board != "CBSE" {
		t.Errorf("board = %q, want CBSE", syllabi[0].Board)
	}
}

func TestReadRejects(t *testing.T) {
	raw, err := os.ReadFile("testdata/cbse-10.json")
	if err != nil {
		t.Fatal(err)
	}
	good := string(raw)
	for _, tc := range []struct {
		name, file, from, to, want string
	}{
		{"wrong file name", "cbse-9.json", "", "", "belongs in cbse-10.json"},
		{"unknown board", "igcse-10.json", `"board": "cbse"`, `"board": "igcse"`, "not a board and class we teach"},
		{"subject not taught", "cbse-10.json", `"subject": "maths"`, `"subject": "physics"`, `subject "physics" is not taught in CBSE class 10`},
		{"unknown field", "cbse-10.json", `"number": 1,
          "title": "Real Numbers"`, `"number": 1,
          "title": "Real Numbers", "bogus": "x"`, "unknown field"},
		{"topic in two lessons", "cbse-10.json", `["Balancing chemical equations"]}`, `["Balancing chemical equations", "Writing chemical equations"]}`, `topic "Writing chemical equations" is in lessons 1 and 2`},
		{"topic in no lesson", "cbse-10.json", `{"title": "Balancing equations", "topics": ["Balancing chemical equations"]},`, ``, `topic "Balancing chemical equations" is in no lesson`},
		{"lesson topic not in chapter", "cbse-10.json", `["Irrational numbers and their proofs"]}`, `["Irrational numbers and their proofs", "Surds"]}`, `topic "Surds" is not in the chapter topics`},
	} {
		t.Run(tc.name, func(t *testing.T) {
			body := good
			if tc.from != "" {
				if !strings.Contains(body, tc.from) {
					t.Fatalf("fixture has no %q", tc.from)
				}
				body = strings.Replace(body, tc.from, tc.to, 1)
			}
			_, err := Read(fstest.MapFS{tc.file: {Data: []byte(body)}})
			if !errors.Is(err, ErrInvalid) || !strings.Contains(err.Error(), tc.want) {
				t.Errorf("Read(%s) error = %v, want ErrInvalid mentioning %q", tc.name, err, tc.want)
			}
		})
	}
}

func TestValidateDuplicateChapterAndEmptyLessons(t *testing.T) {
	syllabi, err := Read(os.DirFS("testdata"))
	if err != nil {
		t.Fatal(err)
	}
	s := syllabi[0]
	s.Subjects[1].Chapters = append(s.Subjects[1].Chapters, Chapter{Number: 1, Title: "Again"})
	err = Validate(s)
	for _, want := range []string{`maths chapter 1 "Again": chapter number must be positive and unique`, `maths chapter 1 "Again": no lessons`} {
		if err == nil || !strings.Contains(err.Error(), want) {
			t.Errorf("Validate(duplicate chapter) error = %v, want %q", err, want)
		}
	}
}
