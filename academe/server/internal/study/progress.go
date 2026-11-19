package study

import (
	"context"
	"time"
)

type LessonRef struct {
	ID      string
	Title   string
	Minutes int
}

type ChapterInfo struct {
	ID      string
	Subject string
	Number  int
	Title   string
	Lessons []LessonRef
}

type Progress struct {
	Done         map[string]time.Time
	Tests        map[string]time.Time
	DueReviews   int
	DueByChapter map[string]int
}

func (s *Service) Chapter(chapterID string) (ChapterInfo, bool) {
	decks := s.chapterDecks(chapterID)
	if len(decks) == 0 {
		return ChapterInfo{}, false
	}
	info := ChapterInfo{ID: chapterID, Subject: decks[0].Subject, Number: decks[0].ChapterNumber, Title: decks[0].ChapterTitle}
	for _, d := range decks {
		info.Lessons = append(info.Lessons, LessonRef{ID: d.ID, Title: d.Title, Minutes: d.Minutes()})
	}
	return info, true
}

func (s *Service) Lesson(ctx context.Context, id string) (LessonRef, bool) {
	d, err := s.deck(ctx, id)
	if err != nil {
		return LessonRef{}, false
	}
	return LessonRef{ID: d.ID, Title: d.Title, Minutes: d.Minutes()}, true
}

func (s *Service) Progress(ctx context.Context, accountID string) (Progress, error) {
	done, err := s.store.Completions(ctx, accountID)
	if err != nil {
		return Progress{}, err
	}
	tests, err := s.store.ChapterResults(ctx, accountID)
	if err != nil {
		return Progress{}, err
	}
	kept, err := s.store.KeptCards(ctx, accountID)
	if err != nil {
		return Progress{}, err
	}
	p := Progress{Done: map[string]time.Time{}, Tests: map[string]time.Time{}, DueByChapter: map[string]int{}}
	for id, c := range done {
		p.Done[id] = c.At
	}
	for id, r := range tests {
		p.Tests[id] = r.CompletedAt
	}
	now := s.now()
	for _, k := range kept {
		if d, err := s.deck(ctx, k.DeckID); err == nil && !k.DueAt.After(now) {
			p.DueReviews++
			p.DueByChapter[d.ChapterID()]++
		}
	}
	return p, nil
}
