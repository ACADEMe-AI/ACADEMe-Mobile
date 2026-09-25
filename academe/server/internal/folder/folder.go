package folder

import (
	"cmp"
	"context"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"
	"unicode/utf8"

	"academe/server/internal/study"
)

type Folder struct {
	ID        string
	Name      string
	DueOn     *time.Time
	Reminds   bool
	CreatedAt time.Time
}

type Item struct {
	ID        int64
	ChapterID *string
	Note      *string
	DeckID    *string
	CreatedAt time.Time
}

type Todo struct {
	ID     int64
	Title  string
	Day    *time.Time
	DoneAt *time.Time
}

type Summary struct {
	ID       string  `json:"id"`
	Name     string  `json:"name"`
	DueOn    *string `json:"dueOn"`
	Reminds  bool    `json:"reminds"`
	Items    int     `json:"items"`
	TodoLeft int     `json:"todayLeft"`
	Progress int     `json:"progress"`
}

type ChapterView struct {
	ItemID      int64  `json:"itemId"`
	ChapterID   string `json:"chapterId"`
	Subject     string `json:"subject"`
	Number      int    `json:"number"`
	Title       string `json:"title"`
	Lessons     int    `json:"lessons"`
	LessonsDone int    `json:"lessonsDone"`
}

type LessonView struct {
	ItemID  int64  `json:"itemId"`
	DeckID  string `json:"deckId"`
	Title   string `json:"title"`
	Minutes int    `json:"minutes"`
	Done    bool   `json:"done"`
}

type NoteView struct {
	ItemID    int64     `json:"itemId"`
	Text      string    `json:"text"`
	CreatedAt time.Time `json:"createdAt"`
}

type Detail struct {
	Summary
	Chapters []ChapterView `json:"chapters"`
	Notes    []NoteView    `json:"notes"`
	Lessons  []LessonView  `json:"lessons"`
	Today    []Task        `json:"today"`
	Plan     []PlanDay     `json:"plan"`
}

type Today struct {
	Tasks     []Task `json:"tasks"`
	ReviewDue int    `json:"reviewDue"`
}

var (
	ErrNotFound   = errors.New("folder not found")
	ErrBadName    = errors.New("name must be 1 to 60 characters")
	ErrBadText    = errors.New("text must be 1 to 2000 characters")
	ErrBadTitle   = errors.New("title must be 1 to 200 characters")
	ErrBadDate    = errors.New("dates are YYYY-MM-DD")
	ErrBadChapter = errors.New("unknown chapter")
)

type Store interface {
	Folders(ctx context.Context, accountID string) ([]Folder, error)
	Folder(ctx context.Context, accountID, id string) (Folder, error)
	Create(ctx context.Context, accountID, name string, due *time.Time) (Folder, error)
	Update(ctx context.Context, accountID, id, name string, due *time.Time, reminds bool) (Folder, error)
	Delete(ctx context.Context, accountID, id string) error
	Items(ctx context.Context, folderID string) ([]Item, error)
	AddChapters(ctx context.Context, folderID string, chapterIDs []string) error
	AddNote(ctx context.Context, folderID, text string) error
	AddLesson(ctx context.Context, folderID, deckID string) error
	DeleteItem(ctx context.Context, folderID string, itemID int64) error
	Todos(ctx context.Context, folderID string) ([]Todo, error)
	AddTodo(ctx context.Context, folderID, title string, day *time.Time) error
	SetTodoDone(ctx context.Context, folderID string, todoID int64, doneAt *time.Time) error
	DeleteTodo(ctx context.Context, folderID string, todoID int64) error
}

type Study interface {
	Chapter(chapterID string) (study.ChapterInfo, bool)
	Lesson(ctx context.Context, id string) (study.LessonRef, bool)
	Progress(ctx context.Context, accountID string) (study.Progress, error)
}

type Service struct {
	store Store
	study Study
	now   func() time.Time
}

func NewService(store Store, s Study) *Service {
	return &Service{store: store, study: s, now: time.Now}
}

func ParseDay(s string) (*time.Time, error) {
	if s == "" {
		return nil, nil
	}
	d, err := time.Parse(time.DateOnly, s)
	if err != nil {
		return nil, ErrBadDate
	}
	return &d, nil
}

type Day struct {
	Date   time.Time
	Offset time.Duration
}

func (s *Service) Day(today string, offsetMinutes int) (Day, error) {
	offset := time.Duration(offsetMinutes) * time.Minute
	if offset < -14*time.Hour || offset > 14*time.Hour {
		return Day{}, ErrBadDate
	}
	if today == "" {
		d, _ := time.Parse(time.DateOnly, s.now().UTC().Add(offset).Format(time.DateOnly))
		return Day{Date: d, Offset: offset}, nil
	}
	d, err := ParseDay(today)
	if err != nil {
		return Day{}, err
	}
	return Day{Date: *d, Offset: offset}, nil
}

func cleanName(name string) (string, error) {
	name = strings.TrimSpace(name)
	if name == "" || utf8.RuneCountInString(name) > 60 {
		return "", ErrBadName
	}
	return name, nil
}

func dayString(t *time.Time) *string {
	if t == nil {
		return nil
	}
	s := t.Format(time.DateOnly)
	return &s
}

func (s *Service) build(ctx context.Context, f Folder, day Day, progress study.Progress) (Detail, error) {
	items, err := s.store.Items(ctx, f.ID)
	if err != nil {
		return Detail{}, err
	}
	todos, err := s.store.Todos(ctx, f.ID)
	if err != nil {
		return Detail{}, err
	}
	d := Detail{
		Summary:  Summary{ID: f.ID, Name: f.Name, DueOn: dayString(f.DueOn), Reminds: f.Reminds, Items: len(items)},
		Chapters: []ChapterView{}, Notes: []NoteView{}, Lessons: []LessonView{},
	}
	var chapters []study.ChapterInfo
	var lessons []study.LessonRef
	for _, it := range items {
		switch {
		case it.ChapterID != nil:
			ch, ok := s.study.Chapter(*it.ChapterID)
			if !ok {
				continue
			}
			chapters = append(chapters, ch)
			view := ChapterView{ItemID: it.ID, ChapterID: ch.ID, Subject: ch.Subject, Number: ch.Number, Title: ch.Title, Lessons: len(ch.Lessons)}
			for _, l := range ch.Lessons {
				if _, ok := progress.Done[l.ID]; ok {
					view.LessonsDone++
				}
			}
			d.Chapters = append(d.Chapters, view)
		case it.DeckID != nil:
			l, ok := s.study.Lesson(ctx, *it.DeckID)
			if !ok {
				continue
			}
			lessons = append(lessons, l)
			_, done := progress.Done[l.ID]
			d.Lessons = append(d.Lessons, LessonView{ItemID: it.ID, DeckID: l.ID, Title: l.Title, Minutes: l.Minutes, Done: done})
		case it.Note != nil:
			d.Notes = append(d.Notes, NoteView{ItemID: it.ID, Text: *it.Note, CreatedAt: it.CreatedAt})
		}
	}
	plan := makePlan(planInput{offset: day.Offset, today: day.Date, due: f.DueOn, chapters: chapters, lessons: lessons, progress: progress, todos: todos})
	d.Today, d.Plan, d.Progress = plan.today, plan.days, plan.progress
	if d.Plan == nil {
		d.Plan = []PlanDay{}
	}
	for _, t := range d.Today {
		if !t.Done {
			d.TodoLeft++
		}
	}
	return d, nil
}

func sortFolders(folders []Folder) {
	slices.SortStableFunc(folders, func(a, b Folder) int {
		switch {
		case a.DueOn == nil && b.DueOn == nil:
			return b.CreatedAt.Compare(a.CreatedAt)
		case a.DueOn == nil:
			return 1
		case b.DueOn == nil:
			return -1
		}
		return cmp.Compare(a.DueOn.Unix(), b.DueOn.Unix())
	})
}

func (s *Service) details(ctx context.Context, accountID string, day Day) ([]Detail, study.Progress, error) {
	folders, err := s.store.Folders(ctx, accountID)
	if err != nil {
		return nil, study.Progress{}, err
	}
	sortFolders(folders)
	progress, err := s.study.Progress(ctx, accountID)
	if err != nil {
		return nil, study.Progress{}, err
	}
	var out []Detail
	for _, f := range folders {
		d, err := s.build(ctx, f, day, progress)
		if err != nil {
			return nil, progress, err
		}
		out = append(out, d)
	}
	return out, progress, nil
}

func (s *Service) List(ctx context.Context, accountID string, day Day) ([]Summary, error) {
	details, _, err := s.details(ctx, accountID, day)
	if err != nil {
		return nil, err
	}
	out := []Summary{}
	for _, d := range details {
		out = append(out, d.Summary)
	}
	return out, nil
}

func (s *Service) Detail(ctx context.Context, accountID, id string, day Day) (Detail, error) {
	f, err := s.store.Folder(ctx, accountID, id)
	if err != nil {
		return Detail{}, err
	}
	progress, err := s.study.Progress(ctx, accountID)
	if err != nil {
		return Detail{}, err
	}
	return s.build(ctx, f, day, progress)
}

func (s *Service) Today(ctx context.Context, accountID string, day Day) (Today, error) {
	details, progress, err := s.details(ctx, accountID, day)
	if err != nil {
		return Today{}, err
	}
	out := Today{Tasks: []Task{}, ReviewDue: progress.DueReviews}
	if progress.DueReviews > 0 {
		out.Tasks = append(out.Tasks, Task{Kind: "review", Title: fmt.Sprintf("Revise %d kept cards", progress.DueReviews), Subtitle: "Revision", Minutes: max(1, (progress.DueReviews+1)/2)})
	}
	seen := map[string]bool{}
	for _, d := range details {
		for _, t := range d.Today {
			key := t.Kind + t.DeckID + t.ChapterID
			if t.Kind == "review" || (t.Kind != "todo" && seen[key]) {
				continue
			}
			seen[key] = true
			t.FolderID, t.FolderName = d.ID, d.Name
			out.Tasks = append(out.Tasks, t)
		}
	}
	slices.SortStableFunc(out.Tasks, func(a, b Task) int {
		switch {
		case a.Done == b.Done:
			return 0
		case a.Done:
			return 1
		}
		return -1
	})
	return out, nil
}

func (s *Service) Create(ctx context.Context, accountID, name, dueOn string) (Summary, error) {
	name, err := cleanName(name)
	if err != nil {
		return Summary{}, err
	}
	due, err := ParseDay(dueOn)
	if err != nil {
		return Summary{}, err
	}
	f, err := s.store.Create(ctx, accountID, name, due)
	if err != nil {
		return Summary{}, err
	}
	return Summary{ID: f.ID, Name: f.Name, DueOn: dayString(f.DueOn), Reminds: f.Reminds}, nil
}

func (s *Service) Update(ctx context.Context, accountID, id, name, dueOn string, reminds bool) (Summary, error) {
	name, err := cleanName(name)
	if err != nil {
		return Summary{}, err
	}
	due, err := ParseDay(dueOn)
	if err != nil {
		return Summary{}, err
	}
	f, err := s.store.Update(ctx, accountID, id, name, due, reminds)
	if err != nil {
		return Summary{}, err
	}
	return Summary{ID: f.ID, Name: f.Name, DueOn: dayString(f.DueOn), Reminds: f.Reminds}, nil
}

func (s *Service) Delete(ctx context.Context, accountID, id string) error {
	return s.store.Delete(ctx, accountID, id)
}

func (s *Service) owned(ctx context.Context, accountID, id string) error {
	_, err := s.store.Folder(ctx, accountID, id)
	return err
}

func (s *Service) AddChapters(ctx context.Context, accountID, id string, chapterIDs []string) error {
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	if len(chapterIDs) == 0 {
		return ErrBadChapter
	}
	for _, c := range chapterIDs {
		if _, ok := s.study.Chapter(c); !ok {
			return ErrBadChapter
		}
	}
	return s.store.AddChapters(ctx, id, chapterIDs)
}

func (s *Service) AddNote(ctx context.Context, accountID, id, text string) error {
	text = strings.TrimSpace(text)
	if text == "" || utf8.RuneCountInString(text) > 2000 {
		return ErrBadText
	}
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	return s.store.AddNote(ctx, id, text)
}

func (s *Service) AddLesson(ctx context.Context, accountID, id, deckID string) error {
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	if _, ok := s.study.Lesson(ctx, deckID); !ok {
		return ErrBadChapter
	}
	return s.store.AddLesson(ctx, id, deckID)
}

func (s *Service) DeleteItem(ctx context.Context, accountID, id string, itemID int64) error {
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	return s.store.DeleteItem(ctx, id, itemID)
}

func (s *Service) AddTodo(ctx context.Context, accountID, id, title, day string) error {
	title = strings.TrimSpace(title)
	if title == "" || utf8.RuneCountInString(title) > 200 {
		return ErrBadTitle
	}
	d, err := ParseDay(day)
	if err != nil {
		return err
	}
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	return s.store.AddTodo(ctx, id, title, d)
}

func (s *Service) SetTodoDone(ctx context.Context, accountID, id string, todoID int64, done bool) error {
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	var at *time.Time
	if done {
		now := s.now()
		at = &now
	}
	return s.store.SetTodoDone(ctx, id, todoID, at)
}

func (s *Service) DeleteTodo(ctx context.Context, accountID, id string, todoID int64) error {
	if err := s.owned(ctx, accountID, id); err != nil {
		return err
	}
	return s.store.DeleteTodo(ctx, id, todoID)
}
