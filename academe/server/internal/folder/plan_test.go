package folder

import (
	"testing"
	"time"

	"academe/server/internal/study"
)

func date(s string) time.Time {
	d, err := time.Parse(time.DateOnly, s)
	if err != nil {
		panic(err)
	}
	return d
}

func chapter(id string, number int, lessons ...string) study.ChapterInfo {
	ch := study.ChapterInfo{ID: id, Subject: "science", Number: number, Title: "Light"}
	for _, l := range lessons {
		ch.Lessons = append(ch.Lessons, study.LessonRef{ID: l, Title: l, Minutes: 6})
	}
	return ch
}

func kinds(tasks []Task) []string {
	var out []string
	for _, t := range tasks {
		out = append(out, t.Kind+":"+t.DeckID+t.ChapterID+t.Title)
	}
	return out
}

func TestPlanSpreadsWorkOverTheDaysLeft(t *testing.T) {
	due := date("2026-10-13")
	out := makePlan(planInput{
		today:    date("2026-10-08"),
		due:      &due,
		chapters: []study.ChapterInfo{chapter("c10", 10, "l1", "l2", "l3")},
		progress: study.Progress{Done: map[string]time.Time{}, Tests: map[string]time.Time{}},
	})
	if len(out.days) != 6 {
		t.Fatalf("plan days = %d, want 5 study days and the due day", len(out.days))
	}
	if got := kinds(out.today); len(got) != 1 || got[0] != "lesson:l1l1" {
		t.Errorf("today = %v, want the first lesson", got)
	}
	if got := kinds(out.days[3].Tasks); len(got) != 1 || got[0] != "test:c10Ch 10 test" {
		t.Errorf("fourth day = %v, want the chapter test", got)
	}
	if got := kinds(out.days[4].Tasks); len(got) != 1 || got[0] != "review:Revise what you kept" {
		t.Errorf("day before the test = %v, want revision", got)
	}
	if out.days[5].Day != "2026-10-13" || len(out.days[5].Tasks) != 0 {
		t.Errorf("due day = %+v, want an empty test day", out.days[5])
	}
	if out.progress != 0 {
		t.Errorf("progress = %d, want 0", out.progress)
	}
}

func TestPlanRollsForwardAndMarksTodayDone(t *testing.T) {
	due := date("2026-10-10")
	today := date("2026-10-09")
	out := makePlan(planInput{
		offset:   5*time.Hour + 30*time.Minute,
		today:    today,
		due:      &due,
		chapters: []study.ChapterInfo{chapter("c10", 10, "l1", "l2", "l3")},
		progress: study.Progress{
			Done:         map[string]time.Time{"l1": date("2026-10-01"), "l2": time.Date(2026, 10, 8, 20, 0, 0, 0, time.UTC)},
			Tests:        map[string]time.Time{},
			DueByChapter: map[string]int{"c10": 3},
		},
	})
	got := kinds(out.today)
	want := []string{"review:Revise 3 kept cards", "lesson:l3l3", "test:c10Ch 10 test", "lesson:l2l2"}
	if len(got) != len(want) {
		t.Fatalf("today = %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Errorf("today[%d] = %q, want %q", i, got[i], want[i])
		}
	}
	if !out.today[3].Done {
		t.Error("lesson finished at 1:30 am IST should count as done today")
	}
	if out.progress != 50 {
		t.Errorf("progress = %d, want 50", out.progress)
	}
}

func TestPlanWithoutADateShowsTheNextStepAndTodos(t *testing.T) {
	today := date("2026-10-09")
	tomorrow := date("2026-10-10")
	done := time.Date(2026, 10, 9, 5, 0, 0, 0, time.UTC)
	old := date("2026-10-01")
	out := makePlan(planInput{
		today:    today,
		chapters: []study.ChapterInfo{chapter("c10", 10, "l1", "l2")},
		progress: study.Progress{Done: map[string]time.Time{}, Tests: map[string]time.Time{}},
		todos: []Todo{
			{ID: 1, Title: "Ask sir about Q7"},
			{ID: 2, Title: "Learn formula", DoneAt: &done},
			{ID: 3, Title: "Old one", DoneAt: &old},
			{ID: 4, Title: "Tomorrow's", Day: &tomorrow},
		},
	})
	got := kinds(out.today)
	want := []string{"lesson:l1l1", "todo:Ask sir about Q7", "todo:Learn formula"}
	if len(got) != len(want) {
		t.Fatalf("today = %v, want %v", got, want)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Errorf("today[%d] = %q, want %q", i, got[i], want[i])
		}
	}
	if len(out.days) != 0 {
		t.Errorf("plan days = %v, want none without a date", out.days)
	}
}
