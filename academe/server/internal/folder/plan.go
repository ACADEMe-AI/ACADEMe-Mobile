package folder

import (
	"fmt"
	"time"

	"academe/server/internal/study"
)

type Task struct {
	Kind       string `json:"kind"`
	Title      string `json:"title"`
	Subtitle   string `json:"subtitle"`
	Minutes    int    `json:"minutes"`
	Done       bool   `json:"done"`
	DeckID     string `json:"deckId,omitempty"`
	ChapterID  string `json:"chapterId,omitempty"`
	TodoID     int64  `json:"todoId,omitempty"`
	FolderID   string `json:"folderId,omitempty"`
	FolderName string `json:"folderName,omitempty"`
}

type PlanDay struct {
	Day   string `json:"day"`
	Tasks []Task `json:"tasks"`
}

type planInput struct {
	offset   time.Duration
	today    time.Time
	due      *time.Time
	chapters []study.ChapterInfo
	lessons  []study.LessonRef
	progress study.Progress
	todos    []Todo
}

type planOutput struct {
	today    []Task
	days     []PlanDay
	progress int
}

func (in planInput) isToday(at time.Time) bool {
	return at.UTC().Add(in.offset).Format(time.DateOnly) == in.today.Format(time.DateOnly)
}

func daysBetween(from, to time.Time) int {
	return int(to.Sub(from).Hours() / 24)
}

func makePlan(in planInput) planOutput {
	var pending, doneToday []Task
	total, done := 0, 0
	dueReviews := 0
	for _, ch := range in.chapters {
		subtitle := fmt.Sprintf("Lesson · Ch %d · %s", ch.Number, ch.Title)
		for _, l := range ch.Lessons {
			total++
			t := Task{Kind: "lesson", Title: l.Title, Subtitle: subtitle, Minutes: l.Minutes, DeckID: l.ID}
			if at, ok := in.progress.Done[l.ID]; ok {
				done++
				if in.isToday(at) {
					t.Done = true
					doneToday = append(doneToday, t)
				}
				continue
			}
			pending = append(pending, t)
		}
		total++
		t := Task{Kind: "test", Title: fmt.Sprintf("Ch %d test", ch.Number), Subtitle: "Chapter test · " + ch.Title, Minutes: 5, ChapterID: ch.ID}
		if at, ok := in.progress.Tests[ch.ID]; ok {
			done++
			if in.isToday(at) {
				t.Done = true
				doneToday = append(doneToday, t)
			}
		} else {
			pending = append(pending, t)
		}
		dueReviews += in.progress.DueByChapter[ch.ID]
	}
	for _, l := range in.lessons {
		total++
		t := Task{Kind: "lesson", Title: l.Title, Subtitle: "Lesson · from your notes", Minutes: l.Minutes, DeckID: l.ID}
		if at, ok := in.progress.Done[l.ID]; ok {
			done++
			if in.isToday(at) {
				t.Done = true
				doneToday = append(doneToday, t)
			}
			continue
		}
		pending = append(pending, t)
	}
	out := planOutput{}
	if total > 0 {
		out.progress = done * 100 / total
	}
	if dueReviews > 0 {
		out.today = append(out.today, Task{Kind: "review", Title: fmt.Sprintf("Revise %d kept cards", dueReviews), Subtitle: "From this folder", Minutes: max(1, (dueReviews+1)/2)})
	}
	days := 0
	if in.due != nil {
		days = daysBetween(in.today, *in.due)
	}
	switch {
	case in.due == nil && len(pending) > 0:
		out.today = append(out.today, pending[0])
	case in.due != nil && days <= 0:
		out.today = append(out.today, pending...)
	case in.due != nil:
		perDay := (len(pending) + days - 1) / days
		for i := range days {
			day := in.today.AddDate(0, 0, i)
			var tasks []Task
			switch {
			case i*perDay < len(pending):
				tasks = pending[i*perDay : min(len(pending), (i+1)*perDay)]
			case i > 0 && len(in.chapters)+len(in.lessons) > 0:
				tasks = []Task{{Kind: "review", Title: "Revise what you kept", Subtitle: "Kept cards and missed questions", Minutes: 5}}
			}
			if i == 0 {
				out.today = append(out.today, tasks...)
			}
			out.days = append(out.days, PlanDay{Day: day.Format(time.DateOnly), Tasks: tasks})
		}
		out.days = append(out.days, PlanDay{Day: in.due.Format(time.DateOnly), Tasks: []Task{}})
	}
	for _, td := range in.todos {
		t := Task{Kind: "todo", Title: td.Title, Subtitle: "Your to-do", TodoID: td.ID, Done: td.DoneAt != nil}
		switch {
		case td.DoneAt != nil && in.isToday(*td.DoneAt):
			out.today = append(out.today, t)
		case td.DoneAt != nil:
		case td.Day == nil || !td.Day.After(in.today):
			out.today = append(out.today, t)
		default:
			for i := range out.days {
				if out.days[i].Day == td.Day.Format(time.DateOnly) {
					out.days[i].Tasks = append(out.days[i].Tasks, t)
				}
			}
		}
	}
	var open []Task
	for _, t := range out.today {
		if t.Kind == "todo" && t.Done {
			doneToday = append(doneToday, t)
		} else {
			open = append(open, t)
		}
	}
	open = append(open, doneToday...)
	out.today = open
	if out.today == nil {
		out.today = []Task{}
	}
	for i := range out.days {
		if out.days[i].Tasks == nil {
			out.days[i].Tasks = []Task{}
		}
	}
	return out
}
