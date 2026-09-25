package study

import (
	"context"
	"crypto/rand"
	"fmt"
	"slices"
	"strings"
	"time"

	"academe/server/internal/profile"
)

type Profiles interface {
	Profile(ctx context.Context, accountID string) (profile.Profile, error)
}

type Service struct {
	store    Store
	profiles Profiles
	decks    []Deck
	plan     []PlannedChapter
	now      func() time.Time
}

func NewService(store Store, profiles Profiles, decks []Deck, plan []PlannedChapter) *Service {
	return &Service{store: store, profiles: profiles, decks: decks, plan: plan, now: time.Now}
}

func (s *Service) syllabus(ctx context.Context, accountID string) (class int, board string, ok bool, err error) {
	p, err := s.profiles.Profile(ctx, accountID)
	if err != nil {
		return 0, "", false, fmt.Errorf("read profile: %w", err)
	}
	if p.Class == nil || p.Board == nil {
		return 0, "", false, nil
	}
	return *p.Class, *p.Board, true, nil
}

func (s *Service) Decks(ctx context.Context, accountID, subject string) ([]LessonSummary, error) {
	class, board, ok, err := s.syllabus(ctx, accountID)
	if err != nil || !ok {
		return nil, err
	}
	done, err := s.store.Completions(ctx, accountID)
	if err != nil {
		return nil, err
	}
	positions, err := s.store.Positions(ctx, accountID)
	if err != nil {
		return nil, err
	}
	kept, err := s.store.KeptCards(ctx, accountID)
	if err != nil {
		return nil, err
	}
	keptPerDeck := map[string]int{}
	for _, k := range kept {
		keptPerDeck[k.DeckID]++
	}
	names := map[string]string{}
	subjects, _ := profile.Subjects(class, board)
	for _, sub := range subjects {
		names[sub.ID] = sub.Name
	}
	var out []LessonSummary
	for _, d := range s.decks {
		if d.Class != class || d.Board != board || (subject != "" && d.Subject != subject) {
			continue
		}
		c, isDone := done[d.ID]
		out = append(out, LessonSummary{
			ID: d.ID, ChapterID: d.ChapterID(), Subject: d.Subject, SubjectName: names[d.Subject],
			ChapterNumber: d.ChapterNumber, ChapterTitle: d.ChapterTitle, Position: d.Position, Title: d.Title,
			Cards: len(d.Cards), Quizzes: d.quizzes(), Done: isDone, Correct: c.Correct,
			ResumeCard: positions[d.ID], Kept: keptPerDeck[d.ID],
		})
	}
	return out, nil
}

func (s *Service) deck(ctx context.Context, id string) (Deck, error) {
	if i := slices.IndexFunc(s.decks, func(d Deck) bool { return d.ID == id }); i >= 0 {
		return s.decks[i], nil
	}
	if strings.HasPrefix(id, UserDeckPrefix) {
		return s.store.UserDeck(ctx, id)
	}
	return Deck{}, ErrNotFound
}

func (s *Service) CreateLesson(ctx context.Context, accountID string, d Deck) (Deck, error) {
	if err := Validate(d); err != nil {
		return Deck{}, err
	}
	d.ID = UserDeckPrefix + rand.Text()
	if err := s.store.SaveUserDeck(ctx, accountID, d); err != nil {
		return Deck{}, err
	}
	return d, nil
}

func (s *Service) DeckFor(ctx context.Context, accountID, id string) (DeckView, error) {
	d, err := s.deck(ctx, id)
	if err != nil {
		return DeckView{}, err
	}
	positions, err := s.store.Positions(ctx, accountID)
	if err != nil {
		return DeckView{}, err
	}
	kept, err := s.store.KeptCards(ctx, accountID)
	if err != nil {
		return DeckView{}, err
	}
	view := DeckView{Deck: d, Kept: []int{}, ResumeCard: positions[id]}
	for _, k := range kept {
		if k.DeckID == id {
			view.Kept = append(view.Kept, k.Card)
		}
	}
	slices.Sort(view.Kept)
	return view, nil
}

func (s *Service) card(ctx context.Context, deckID string, card int) (Deck, Card, error) {
	d, err := s.deck(ctx, deckID)
	if err != nil {
		return Deck{}, Card{}, err
	}
	if card < 0 || card >= len(d.Cards) {
		return Deck{}, Card{}, ErrBadCard
	}
	return d, d.Cards[card], nil
}

func (s *Service) Answer(ctx context.Context, accountID, deckID string, card, choice int) (Result, error) {
	_, c, err := s.card(ctx, deckID, card)
	if err != nil {
		return Result{}, err
	}
	if c.Kind != Quiz {
		return Result{}, ErrNotQuiz
	}
	if choice < 0 || choice >= len(c.Options) {
		return Result{}, ErrBadChoice
	}
	r := Result{Correct: choice == *c.Answer, Answer: *c.Answer}
	if !r.Correct {
		k := Kept{DeckID: deckID, Card: card, Reason: "missed", DueAt: s.tomorrow()}
		return r, s.store.Keep(ctx, k, accountID, true)
	}
	awarded, err := s.store.AwardXP(ctx, accountID, QuizXP, fmt.Sprintf("quiz:%s:%d", deckID, card))
	if err != nil {
		return Result{}, err
	}
	if awarded {
		r.XPAwarded = QuizXP
	}
	return r, nil
}

func (s *Service) Complete(ctx context.Context, accountID, deckID string, correct int) error {
	d, err := s.deck(ctx, deckID)
	if err != nil {
		return err
	}
	if correct < 0 || correct > d.quizzes() {
		return ErrBadScore
	}
	return s.store.Complete(ctx, accountID, deckID, correct)
}

func (s *Service) SavePosition(ctx context.Context, accountID, deckID string, card int) error {
	if _, _, err := s.card(ctx, deckID, card); err != nil {
		return err
	}
	return s.store.SavePosition(ctx, accountID, deckID, card)
}

func (s *Service) tomorrow() time.Time {
	return s.now().Add(20 * time.Hour)
}

func (s *Service) Keep(ctx context.Context, accountID, deckID string, card int) error {
	if _, _, err := s.card(ctx, deckID, card); err != nil {
		return err
	}
	return s.store.Keep(ctx, Kept{DeckID: deckID, Card: card, Reason: "kept", DueAt: s.tomorrow()}, accountID, false)
}

func (s *Service) Unkeep(ctx context.Context, accountID, deckID string, card int) error {
	return s.store.Unkeep(ctx, accountID, deckID, card)
}

func (s *Service) items(ctx context.Context, kept []Kept) []ReviewItem {
	out := []ReviewItem{}
	for _, k := range kept {
		d, c, err := s.card(ctx, k.DeckID, k.Card)
		if err != nil {
			continue
		}
		out = append(out, ReviewItem{DeckID: k.DeckID, Card: k.Card, Reason: k.Reason, LessonTitle: d.Title, ChapterTitle: d.ChapterTitle, Content: c})
	}
	return out
}

func (s *Service) Review(ctx context.Context, accountID, chapterID string) ([]ReviewItem, error) {
	kept, err := s.store.KeptCards(ctx, accountID)
	if err != nil {
		return nil, err
	}
	now := s.now()
	var picked []Kept
	for _, k := range kept {
		d, err := s.deck(ctx, k.DeckID)
		if err != nil {
			continue
		}
		if chapterID != "" && d.ChapterID() == chapterID || chapterID == "" && !k.DueAt.After(now) {
			picked = append(picked, k)
		}
	}
	slices.SortFunc(picked, func(a, b Kept) int { return a.DueAt.Compare(b.DueAt) })
	return s.items(ctx, picked), nil
}

func (s *Service) Rate(ctx context.Context, accountID, deckID string, card int, rating string) error {
	kept, err := s.store.KeptCards(ctx, accountID)
	if err != nil {
		return err
	}
	i := slices.IndexFunc(kept, func(k Kept) bool { return k.DeckID == deckID && k.Card == card })
	if i < 0 {
		return ErrNotKept
	}
	interval, err := NextInterval(kept[i].Interval, rating)
	if err != nil {
		return err
	}
	due := s.now().Add(time.Duration(interval)*24*time.Hour - 4*time.Hour)
	return s.store.Reschedule(ctx, accountID, deckID, card, due, interval)
}

func NextInterval(current int, rating string) (int, error) {
	switch rating {
	case "again":
		return 1, nil
	case "almost":
		return max(2, current*3/2), nil
	case "knew":
		return max(4, current*5/2), nil
	}
	return 0, ErrBadRating
}

func (s *Service) chapterDecks(chapterID string) []Deck {
	var out []Deck
	for _, d := range s.decks {
		if d.ChapterID() == chapterID {
			out = append(out, d)
		}
	}
	return out
}

func (s *Service) SaveChapterResult(ctx context.Context, accountID, chapterID string, correct, total int) error {
	decks := s.chapterDecks(chapterID)
	if len(decks) == 0 {
		return ErrNoChapter
	}
	quizzes := 0
	for _, d := range decks {
		quizzes += d.quizzes()
	}
	if total < 1 || total > quizzes || correct < 0 || correct > total {
		return ErrBadScore
	}
	return s.store.SaveChapterResult(ctx, accountID, chapterID, correct, total)
}

func (s *Service) ChapterResults(ctx context.Context, accountID string) ([]ChapterResult, error) {
	results, err := s.store.ChapterResults(ctx, accountID)
	if err != nil {
		return nil, err
	}
	out := []ChapterResult{}
	for _, r := range results {
		out = append(out, r)
	}
	slices.SortFunc(out, func(a, b ChapterResult) int { return a.CompletedAt.Compare(b.CompletedAt) })
	return out, nil
}
