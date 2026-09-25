package lessons

import (
	"path/filepath"
	"strconv"
	"strings"

	"academe/server/internal/study"
	"academe/server/internal/syllabus"
)

type Job struct {
	Board    string
	Class    int
	Subject  syllabus.Subject
	Chapter  syllabus.Chapter
	Position int
}

func (j Job) Lesson() syllabus.Lesson { return j.Chapter.Lessons[j.Position-1] }

func (j Job) ChapterID() string {
	return study.ChapterID(j.Board, j.Class, j.Subject.Subject, j.Chapter.Number)
}

func (j Job) ID() string { return study.LessonID(j.ChapterID(), j.Position) }

func (j Job) Path(out string) string {
	return filepath.Join(out, strings.ToLower(j.Board)+"-"+strconv.Itoa(j.Class), j.ID()+".json")
}

type Filter struct {
	Board   string
	Class   int
	Subject string
	Chapter int
	Lesson  int
}

func Jobs(syllabi []syllabus.Syllabus, f Filter) []Job {
	var out []Job
	for _, s := range syllabi {
		if f.Board != "" && !strings.EqualFold(f.Board, s.Board) || f.Class != 0 && f.Class != s.Class {
			continue
		}
		for _, sub := range s.Subjects {
			if f.Subject != "" && f.Subject != sub.Subject {
				continue
			}
			for _, c := range sub.Chapters {
				if f.Chapter != 0 && f.Chapter != c.Number {
					continue
				}
				for i := range c.Lessons {
					if f.Lesson != 0 && f.Lesson != i+1 {
						continue
					}
					out = append(out, Job{Board: s.Board, Class: s.Class, Subject: sub, Chapter: c, Position: i + 1})
				}
			}
		}
	}
	return out
}
