package scan

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"
	"time"
	"unicode/utf8"

	"academe/server/internal/billing"
	"academe/server/internal/profile"
	"academe/server/internal/sarvam"
	"academe/server/internal/study"
)

type Mode string

const (
	Solve Mode = "solve"
	Check Mode = "check"
	Notes Mode = "notes"
	Ask   Mode = "ask"
)

func (m Mode) valid() bool { return m == Solve || m == Check || m == Notes || m == Ask }

const MaxPages = 10

type Point struct {
	Text    string `json:"text"`
	Marks   int    `json:"marks"`
	Awarded int    `json:"awarded"`
}

type Marking struct {
	Question    string  `json:"question"`
	Marks       int     `json:"marks"`
	Awarded     int     `json:"awarded"`
	Points      []Point `json:"points"`
	FullMarks   string  `json:"fullMarks"`
	ModelAnswer string  `json:"modelAnswer"`
}

type Scan struct {
	ID        string    `json:"id"`
	Mode      Mode      `json:"mode"`
	Title     string    `json:"title"`
	Text      string    `json:"text"`
	Chapter   string    `json:"chapter"`
	ThreadID  *string   `json:"threadId"`
	FolderID  *string   `json:"folderId"`
	DeckID    *string   `json:"deckId"`
	Result    *Marking  `json:"result"`
	CreatedAt time.Time `json:"createdAt"`
}

var (
	ErrUnavailable = errors.New("scan is not set up")
	ErrBadMode     = errors.New("mode must be solve, check, notes or ask")
	ErrBadPages    = errors.New("send 1 to 10 photos")
	ErrNoText      = errors.New("no text found in the photo")
	ErrNotFound    = errors.New("scan not found")
	ErrWrongMode   = errors.New("that scan is for another job")
	ErrFailed      = errors.New("could not finish the scan")
	ErrBadThread   = errors.New("threadId must be a thread id")
)

type Reader interface {
	Digitise(ctx context.Context, pages []sarvam.Page, language string) (string, error)
}

type Model interface {
	Chat(ctx context.Context, messages []sarvam.Message, temperature float64) (string, error)
}

type Profiles interface {
	Profile(ctx context.Context, accountID string) (profile.Profile, error)
}

type Lessons interface {
	CreateLesson(ctx context.Context, accountID string, d study.Deck) (study.Deck, error)
}

type Folders interface {
	AddNote(ctx context.Context, accountID, id, text string) error
	AddLesson(ctx context.Context, accountID, id, deckID string) error
}

type Store interface {
	Create(ctx context.Context, accountID string, s Scan) (Scan, error)
	Scans(ctx context.Context, accountID string, limit int) ([]Scan, error)
	Scan(ctx context.Context, accountID, id string) (Scan, error)
	SetThread(ctx context.Context, accountID, id, threadID string) error
	SetResult(ctx context.Context, accountID, id string, m Marking) error
	SetFolder(ctx context.Context, accountID, id, folderID string, deckID *string) error
}

type Limiter interface {
	Take(ctx context.Context, accountID string, f billing.Feature) error
	Refund(ctx context.Context, accountID string, f billing.Feature)
}

type Service struct {
	store    Store
	reader   Reader
	model    Model
	profiles Profiles
	lessons  Lessons
	folders  Folders
	limiter  Limiter
}

func (s *Service) SetLimiter(l Limiter) { s.limiter = l }

func (s *Service) limited(ctx context.Context, accountID string, f billing.Feature, run func() error) error {
	if s.limiter == nil {
		return run()
	}
	if err := s.limiter.Take(ctx, accountID, f); err != nil {
		return err
	}
	if err := run(); err != nil {
		s.limiter.Refund(ctx, accountID, f)
		return err
	}
	return nil
}

func NewService(store Store, reader Reader, model Model, profiles Profiles, lessons Lessons, folders Folders) *Service {
	return &Service{store: store, reader: reader, model: model, profiles: profiles, lessons: lessons, folders: folders}
}

type brief struct {
	class    int
	board    string
	language string
}

func (s *Service) brief(ctx context.Context, accountID string) (brief, error) {
	p, err := s.profiles.Profile(ctx, accountID)
	if err != nil {
		return brief{}, fmt.Errorf("read profile: %w", err)
	}
	b := brief{class: 10, board: "CBSE", language: "en"}
	if p.Class != nil {
		b.class = *p.Class
	}
	if p.Board != nil {
		b.board = *p.Board
	}
	if p.Language != nil {
		b.language = *p.Language
	}
	return b, nil
}

func (b brief) student() string {
	return fmt.Sprintf("a Class %d %s student in India", b.class, b.board)
}

func clip(text string, n int) string {
	if utf8.RuneCountInString(text) <= n {
		return text
	}
	return string([]rune(text)[:n-1]) + "…"
}

func title(text string) string {
	for line := range strings.SplitSeq(text, "\n") {
		line = strings.TrimSpace(strings.Trim(strings.TrimSpace(line), "#*-•"))
		if line == "" {
			continue
		}
		return clip(line, 60)
	}
	return "Scan"
}

func (s *Service) Read(ctx context.Context, accountID string, mode Mode, pages []sarvam.Page) (Scan, error) {
	if !mode.valid() {
		return Scan{}, ErrBadMode
	}
	if len(pages) == 0 || len(pages) > MaxPages {
		return Scan{}, ErrBadPages
	}
	if s.reader == nil || s.model == nil {
		return Scan{}, ErrUnavailable
	}
	var sc Scan
	err := s.limited(ctx, accountID, billing.Scan, func() (err error) {
		sc, err = s.read(ctx, accountID, mode, pages)
		return err
	})
	return sc, err
}

func (s *Service) read(ctx context.Context, accountID string, mode Mode, pages []sarvam.Page) (Scan, error) {
	b, err := s.brief(ctx, accountID)
	if err != nil {
		return Scan{}, err
	}
	text, err := s.reader.Digitise(ctx, pages, b.language+"-IN")
	if err != nil {
		return Scan{}, fmt.Errorf("%w: %w", ErrFailed, err)
	}
	text = strings.TrimSpace(text)
	if text == "" {
		return Scan{}, ErrNoText
	}
	chapter, err := s.model.Chat(ctx, []sarvam.Message{
		{Role: "system", Content: "You label study material for " + b.student() + ". Reply with one short line only, in English: Subject · Ch <number> · <chapter name>, using the textbook chapter this belongs to. If you are unsure of the chapter, reply with just the subject."},
		{Role: "user", Content: text},
	}, 0)
	if err != nil || utf8.RuneCountInString(chapter) > 80 || strings.Contains(chapter, "\n") {
		chapter = ""
	}
	return s.store.Create(ctx, accountID, Scan{Mode: mode, Title: title(text), Text: text, Chapter: strings.TrimSpace(chapter)})
}

func (s *Service) Scans(ctx context.Context, accountID string) ([]Scan, error) {
	return s.store.Scans(ctx, accountID, 20)
}

func (s *Service) Scan(ctx context.Context, accountID, id string) (Scan, error) {
	return s.store.Scan(ctx, accountID, id)
}

func (s *Service) LinkThread(ctx context.Context, accountID, id, threadID string) error {
	sc, err := s.store.Scan(ctx, accountID, id)
	if err != nil {
		return err
	}
	if sc.Mode != Solve && sc.Mode != Ask {
		return ErrWrongMode
	}
	if !isUUID(threadID) {
		return ErrBadThread
	}
	return s.store.SetThread(ctx, accountID, id, threadID)
}

func isUUID(s string) bool {
	if len(s) != 36 {
		return false
	}
	for i, c := range s {
		switch {
		case i == 8 || i == 13 || i == 18 || i == 23:
			if c != '-' {
				return false
			}
		case !strings.ContainsRune("0123456789abcdefABCDEF", c):
			return false
		}
	}
	return true
}

func jsonObject(reply string) string {
	start, end := strings.Index(reply, "{"), strings.LastIndex(reply, "}")
	if start < 0 || end <= start {
		return ""
	}
	return reply[start : end+1]
}

func (s *Service) Check(ctx context.Context, accountID, id, question string) (Marking, error) {
	sc, err := s.store.Scan(ctx, accountID, id)
	if err != nil {
		return Marking{}, err
	}
	if sc.Mode != Check {
		return Marking{}, ErrWrongMode
	}
	if s.model == nil {
		return Marking{}, ErrUnavailable
	}
	var m Marking
	err = s.limited(ctx, accountID, billing.Check, func() (err error) {
		m, err = s.check(ctx, accountID, sc, question)
		return err
	})
	return m, err
}

func (s *Service) check(ctx context.Context, accountID string, sc Scan, question string) (Marking, error) {
	b, err := s.brief(ctx, accountID)
	if err != nil {
		return Marking{}, err
	}
	page := sc.Text
	if q := strings.TrimSpace(question); q != "" {
		page = "Question: " + q + "\n\n" + page
	}
	for range 2 {
		reply, err := s.model.Chat(ctx, []sarvam.Message{
			{Role: "system", Content: CheckPrompt(b)},
			{Role: "user", Content: page},
		}, 0.1)
		if err != nil {
			return Marking{}, fmt.Errorf("%w: %w", ErrFailed, err)
		}
		var m Marking
		if json.Unmarshal([]byte(jsonObject(reply)), &m) != nil || !m.ok() {
			continue
		}
		if err := s.store.SetResult(ctx, accountID, sc.ID, m); err != nil {
			return Marking{}, err
		}
		return m, nil
	}
	return Marking{}, ErrFailed
}

func (m Marking) ok() bool {
	if m.Marks < 1 || m.Marks > 20 || m.Awarded < 0 || m.Awarded > m.Marks || len(m.Points) == 0 || m.FullMarks == "" {
		return false
	}
	awarded := 0
	for _, p := range m.Points {
		if p.Text == "" || p.Awarded < 0 || p.Awarded > p.Marks {
			return false
		}
		awarded += p.Awarded
	}
	return awarded == m.Awarded
}

func CheckPrompt(b brief) string {
	return "You are a fair " + b.board + " board examiner marking the written answer of " + b.student() + ". " +
		"The page has the question and the student's handwritten answer. Mark it the way the official " + b.board + " marking scheme would: one point per idea the scheme expects, with its marks. " +
		"Reply with JSON only, no other text: " +
		`{"question": "the question", "marks": total marks for the question, "awarded": marks earned, ` +
		`"points": [{"text": "one expected idea", "marks": marks for it, "awarded": marks the student earned for it}], ` +
		`"fullMarks": "one or two sentences on exactly what to add for full marks", "modelAnswer": "a short full-marks answer"}. ` +
		"The awarded marks of the points must add up to awarded. Write the text in English."
}

type lessonJSON struct {
	Title string       `json:"title"`
	Cards []study.Card `json:"cards"`
}

func LessonPrompt(b brief) string {
	return "Turn the student's notes into a short swipe lesson for " + b.student() + ". Reply with JSON only: " +
		`{"title": "short lesson title", "cards": [...]}. Card kinds and fields: ` +
		`{"kind": "start", "goals": ["2 or 3 things they will be able to do"], "minutes": 5}; ` +
		`{"kind": "concept", "title": "...", "body": "2 to 4 short sentences, **bold** key words", "remember": "optional one line"}; ` +
		`{"kind": "table", "title": "...", "rows": [{"term": "...", "value": "..."}]} (at least 2 rows); ` +
		`{"kind": "example", "question": "...", "steps": ["step 1", "step 2"]}; ` +
		`{"kind": "quiz", "question": "...", "options": ["...", "...", "..."], "answer": index of the right option, "why": "why it is right"}; ` +
		`{"kind": "summary", "points": ["three one-line points"]}. ` +
		"Rules: the first card is start; the last two are a quiz then the summary; put a quiz after every 2 or 3 teaching cards; 6 to 12 cards in all. " +
		"Only use facts from the notes and the textbook; do not invent. Write in English."
}

func (s *Service) SaveNotes(ctx context.Context, accountID, id, folderID string, makeLesson bool) (*string, error) {
	sc, err := s.store.Scan(ctx, accountID, id)
	if err != nil {
		return nil, err
	}
	if sc.Mode != Notes {
		return nil, ErrWrongMode
	}
	if !makeLesson {
		return s.saveNotes(ctx, accountID, sc, folderID, false)
	}
	var deckID *string
	err = s.limited(ctx, accountID, billing.Lessons, func() (err error) {
		deckID, err = s.saveNotes(ctx, accountID, sc, folderID, true)
		return err
	})
	return deckID, err
}

func (s *Service) saveNotes(ctx context.Context, accountID string, sc Scan, folderID string, makeLesson bool) (*string, error) {
	if err := s.folders.AddNote(ctx, accountID, folderID, clip(sc.Text, 2000)); err != nil {
		return nil, err
	}
	var deckID *string
	if makeLesson {
		d, err := s.makeLesson(ctx, accountID, sc.Text)
		if err != nil {
			return nil, err
		}
		if err := s.folders.AddLesson(ctx, accountID, folderID, d.ID); err != nil {
			return nil, err
		}
		deckID = &d.ID
	}
	return deckID, s.store.SetFolder(ctx, accountID, sc.ID, folderID, deckID)
}

func (s *Service) makeLesson(ctx context.Context, accountID, text string) (study.Deck, error) {
	if s.model == nil {
		return study.Deck{}, ErrUnavailable
	}
	b, err := s.brief(ctx, accountID)
	if err != nil {
		return study.Deck{}, err
	}
	for range 2 {
		reply, err := s.model.Chat(ctx, []sarvam.Message{
			{Role: "system", Content: LessonPrompt(b)},
			{Role: "user", Content: text},
		}, 0.2)
		if err != nil {
			return study.Deck{}, fmt.Errorf("%w: %w", ErrFailed, err)
		}
		var l lessonJSON
		if json.Unmarshal([]byte(jsonObject(reply)), &l) != nil {
			continue
		}
		d, err := s.lessons.CreateLesson(ctx, accountID, study.Deck{
			Board: b.board, Class: b.class, Title: strings.TrimSpace(l.Title), Language: "en", Position: 1, Cards: l.Cards,
		})
		if errors.Is(err, study.ErrBadLesson) {
			continue
		}
		return d, err
	}
	return study.Deck{}, ErrFailed
}
