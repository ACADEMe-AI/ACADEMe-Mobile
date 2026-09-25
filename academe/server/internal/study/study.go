package study

import (
	"cmp"
	"context"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"path"
	"slices"
	"strings"
	"time"
)

const (
	QuizXP         = 5
	UserDeckPrefix = "u-"
)

const (
	Start   = "start"
	Concept = "concept"
	Table   = "table"
	Example = "example"
	Quiz    = "quiz"
	Summary = "summary"
)

type Row struct {
	Term  string `json:"term"`
	Value string `json:"value"`
}

type Card struct {
	Kind     string   `json:"kind"`
	Title    string   `json:"title,omitempty"`
	Body     string   `json:"body,omitempty"`
	Remember string   `json:"remember,omitempty"`
	Goals    []string `json:"goals,omitempty"`
	Minutes  int      `json:"minutes,omitempty"`
	Rows     []Row    `json:"rows,omitempty"`
	Steps    []string `json:"steps,omitempty"`
	Points   []string `json:"points,omitempty"`
	Question string   `json:"question,omitempty"`
	Options  []string `json:"options,omitempty"`
	Answer   *int     `json:"answer,omitempty"`
	Why      string   `json:"why,omitempty"`
}

type Deck struct {
	ID            string       `json:"id"`
	Board         string       `json:"board"`
	Class         int          `json:"class"`
	Subject       string       `json:"subject"`
	ChapterNumber int          `json:"chapterNumber"`
	ChapterTitle  string       `json:"chapterTitle"`
	Position      int          `json:"position"`
	Title         string       `json:"title"`
	Language      string       `json:"language"`
	Cards         []Card       `json:"cards"`
	Status        string       `json:"status,omitempty"`
	GeneratedBy   *GeneratedBy `json:"generatedBy,omitempty"`
}

type GeneratedBy struct {
	Model         string    `json:"model"`
	PromptVersion string    `json:"promptVersion"`
	CheckedAt     time.Time `json:"checkedAt"`
}

const (
	Approved = "approved"
	Draft    = "draft"
)

func (d Deck) Approved() bool { return d.Status == "" || d.Status == Approved }

func ChapterID(board string, class int, subject string, chapter int) string {
	return fmt.Sprintf("%s-%d-%s-%d", strings.ToLower(board), class, subject, chapter)
}

func (d Deck) ChapterID() string {
	if d.Subject == "" || d.ChapterNumber == 0 {
		return ""
	}
	return ChapterID(d.Board, d.Class, d.Subject, d.ChapterNumber)
}

func (d Deck) quizzes() int {
	n := 0
	for _, c := range d.Cards {
		if c.Kind == Quiz {
			n++
		}
	}
	return n
}

func (d Deck) Minutes() int {
	return max(1, (len(d.Cards)*2+2)/3)
}

type DeckView struct {
	Deck
	Kept       []int `json:"kept"`
	ResumeCard int   `json:"resumeCard"`
}

type LessonSummary struct {
	ID            string `json:"id"`
	ChapterID     string `json:"chapterId"`
	Subject       string `json:"subject"`
	SubjectName   string `json:"subjectName"`
	ChapterNumber int    `json:"chapterNumber"`
	ChapterTitle  string `json:"chapterTitle"`
	Position      int    `json:"position"`
	Title         string `json:"title"`
	Cards         int    `json:"cards"`
	Quizzes       int    `json:"quizzes"`
	Done          bool   `json:"done"`
	Correct       int    `json:"correct"`
	ResumeCard    int    `json:"resumeCard"`
	Kept          int    `json:"kept"`
}

type Result struct {
	Correct   bool `json:"correct"`
	Answer    int  `json:"answer"`
	XPAwarded int  `json:"xpAwarded"`
}

type ReviewItem struct {
	DeckID       string `json:"deckId"`
	Card         int    `json:"card"`
	Reason       string `json:"reason"`
	LessonTitle  string `json:"lessonTitle"`
	ChapterTitle string `json:"chapterTitle"`
	Content      Card   `json:"content"`
}

type ChapterResult struct {
	ChapterID   string    `json:"chapterId"`
	Correct     int       `json:"correct"`
	Total       int       `json:"total"`
	CompletedAt time.Time `json:"completedAt"`
}

type Completion struct {
	Correct int
	At      time.Time
}

type Kept struct {
	DeckID   string
	Card     int
	Reason   string
	DueAt    time.Time
	Interval int
}

var (
	ErrNotFound  = errors.New("deck not found")
	ErrBadCard   = errors.New("that card is not in the deck")
	ErrNotQuiz   = errors.New("that card is not a quiz")
	ErrBadChoice = errors.New("choice is out of range")
	ErrBadScore  = errors.New("score is out of range")
	ErrNotKept   = errors.New("that card is not kept")
	ErrBadRating = errors.New("rating must be again, almost or knew")
	ErrNoChapter = errors.New("chapter not found")
	ErrBadLesson = errors.New("lesson breaks the card rules")
)

type Store interface {
	AwardXP(ctx context.Context, accountID string, amount int, reason string) (bool, error)
	Complete(ctx context.Context, accountID, deckID string, correct int) error
	Completions(ctx context.Context, accountID string) (map[string]Completion, error)
	SavePosition(ctx context.Context, accountID, deckID string, card int) error
	Positions(ctx context.Context, accountID string) (map[string]int, error)
	Keep(ctx context.Context, k Kept, accountID string, reset bool) error
	Unkeep(ctx context.Context, accountID, deckID string, card int) error
	KeptCards(ctx context.Context, accountID string) ([]Kept, error)
	Reschedule(ctx context.Context, accountID, deckID string, card int, due time.Time, interval int) error
	SaveChapterResult(ctx context.Context, accountID, chapterID string, correct, total int) error
	ChapterResults(ctx context.Context, accountID string) (map[string]ChapterResult, error)
	SaveUserDeck(ctx context.Context, accountID string, d Deck) error
	UserDeck(ctx context.Context, id string) (Deck, error)
}

//go:embed decks
var deckFiles embed.FS

func Library() ([]Deck, error) {
	decks, err := ReadDecks(deckFiles)
	if err != nil {
		return nil, err
	}
	return slices.DeleteFunc(decks, func(d Deck) bool { return !d.Approved() }), nil
}

func ReadDecks(fsys fs.FS) ([]Deck, error) {
	var decks []Deck
	err := fs.WalkDir(fsys, ".", func(p string, e fs.DirEntry, err error) error {
		if err != nil || e.IsDir() || path.Ext(p) != ".json" || strings.HasSuffix(p, ReviewSuffix) {
			return err
		}
		raw, err := fs.ReadFile(fsys, p)
		if err != nil {
			return fmt.Errorf("read %s: %w", p, err)
		}
		var d Deck
		if err := json.Unmarshal(raw, &d); err != nil {
			return fmt.Errorf("parse %s: %w", p, err)
		}
		decks = append(decks, d)
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("list decks: %w", err)
	}
	slices.SortFunc(decks, func(a, b Deck) int {
		return cmp.Or(cmp.Compare(a.Board, b.Board), cmp.Compare(a.Class, b.Class), cmp.Compare(a.Subject, b.Subject), cmp.Compare(a.ChapterNumber, b.ChapterNumber), cmp.Compare(a.Position, b.Position))
	})
	return decks, nil
}

const ReviewSuffix = ".review.json"

func Validate(d Deck) error {
	bad := func(format string, args ...any) error {
		return fmt.Errorf("%w: %s", ErrBadLesson, fmt.Sprintf(format, args...))
	}
	if d.Title == "" || d.Language == "" {
		return bad("missing title or language")
	}
	n := len(d.Cards)
	if n < 4 || d.Cards[0].Kind != Start || d.Cards[n-1].Kind != Summary || d.Cards[n-2].Kind != Quiz {
		return bad("open on a start card and end on a quiz then a summary")
	}
	if len(d.Cards[0].Goals) == 0 || d.Cards[0].Minutes < 1 || len(d.Cards[n-1].Points) == 0 {
		return bad("start needs goals and minutes, summary needs points")
	}
	sinceQuiz := 0
	for i, c := range d.Cards[1 : n-1] {
		i++
		switch c.Kind {
		case Concept:
			if c.Title == "" || c.Body == "" {
				return bad("card %d: concept needs a title and a body", i)
			}
		case Table:
			if c.Title == "" || len(c.Rows) < 2 {
				return bad("card %d: table needs a title and two rows", i)
			}
		case Example:
			if c.Question == "" || len(c.Steps) < 2 {
				return bad("card %d: example needs a question and two steps", i)
			}
		case Quiz:
			if c.Question == "" || len(c.Options) < 2 || c.Answer == nil || *c.Answer < 0 || *c.Answer >= len(c.Options) || c.Why == "" {
				return bad("card %d: quiz needs a question, options, an answer in range and a why", i)
			}
			sinceQuiz = 0
			continue
		default:
			return bad("card %d: kind %q can't be in the middle of a lesson", i, c.Kind)
		}
		sinceQuiz++
		if sinceQuiz > 3 {
			return bad("card %d: more than three cards without a quiz", i)
		}
	}
	return nil
}
