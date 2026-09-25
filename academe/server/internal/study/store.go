package study

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func (s *PostgresStore) AwardXP(ctx context.Context, accountID string, amount int, reason string) (bool, error) {
	tag, err := s.pool.Exec(ctx, `
		INSERT INTO xp_events (account_id, amount, reason) VALUES ($1, $2, $3)
		ON CONFLICT (account_id, reason) DO NOTHING`, accountID, amount, reason)
	if err != nil {
		return false, fmt.Errorf("award quiz xp: %w", err)
	}
	return tag.RowsAffected() == 1, nil
}

func (s *PostgresStore) Complete(ctx context.Context, accountID, deckID string, correct int) error {
	if _, err := s.pool.Exec(ctx, `
		INSERT INTO deck_completions (account_id, deck_id, correct) VALUES ($1, $2, $3)
		ON CONFLICT (account_id, deck_id) DO UPDATE SET
			correct      = GREATEST(deck_completions.correct, EXCLUDED.correct),
			completed_at = now()`, accountID, deckID, correct); err != nil {
		return fmt.Errorf("complete deck: %w", err)
	}
	return nil
}

func (s *PostgresStore) Completions(ctx context.Context, accountID string) (map[string]Completion, error) {
	rows, err := s.pool.Query(ctx, `SELECT deck_id, correct, completed_at FROM deck_completions WHERE account_id = $1`, accountID)
	if err != nil {
		return nil, fmt.Errorf("select completions: %w", err)
	}
	defer rows.Close()
	out := map[string]Completion{}
	for rows.Next() {
		var id string
		var c Completion
		if err := rows.Scan(&id, &c.Correct, &c.At); err != nil {
			return nil, fmt.Errorf("scan completion: %w", err)
		}
		out[id] = c
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read completions: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) SavePosition(ctx context.Context, accountID, deckID string, card int) error {
	if _, err := s.pool.Exec(ctx, `
		INSERT INTO deck_positions (account_id, deck_id, card) VALUES ($1, $2, $3)
		ON CONFLICT (account_id, deck_id) DO UPDATE SET card = EXCLUDED.card, updated_at = now()`,
		accountID, deckID, card); err != nil {
		return fmt.Errorf("save position: %w", err)
	}
	return nil
}

func (s *PostgresStore) Positions(ctx context.Context, accountID string) (map[string]int, error) {
	rows, err := s.pool.Query(ctx, `SELECT deck_id, card FROM deck_positions WHERE account_id = $1`, accountID)
	if err != nil {
		return nil, fmt.Errorf("select positions: %w", err)
	}
	defer rows.Close()
	out := map[string]int{}
	for rows.Next() {
		var id string
		var card int
		if err := rows.Scan(&id, &card); err != nil {
			return nil, fmt.Errorf("scan position: %w", err)
		}
		out[id] = card
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read positions: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) Keep(ctx context.Context, k Kept, accountID string, reset bool) error {
	query := `
		INSERT INTO kept_cards (account_id, deck_id, card, reason, due_at) VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (account_id, deck_id, card) DO NOTHING`
	if reset {
		query = `
		INSERT INTO kept_cards (account_id, deck_id, card, reason, due_at) VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (account_id, deck_id, card) DO UPDATE SET
			due_at = LEAST(kept_cards.due_at, EXCLUDED.due_at), interval_days = 0`
	}
	if _, err := s.pool.Exec(ctx, query, accountID, k.DeckID, k.Card, k.Reason, k.DueAt); err != nil {
		return fmt.Errorf("keep card: %w", err)
	}
	return nil
}

func (s *PostgresStore) Unkeep(ctx context.Context, accountID, deckID string, card int) error {
	if _, err := s.pool.Exec(ctx, `DELETE FROM kept_cards WHERE account_id = $1 AND deck_id = $2 AND card = $3`,
		accountID, deckID, card); err != nil {
		return fmt.Errorf("unkeep card: %w", err)
	}
	return nil
}

func (s *PostgresStore) KeptCards(ctx context.Context, accountID string) ([]Kept, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT deck_id, card, reason, due_at, interval_days FROM kept_cards
		WHERE account_id = $1 ORDER BY due_at`, accountID)
	if err != nil {
		return nil, fmt.Errorf("select kept cards: %w", err)
	}
	defer rows.Close()
	var out []Kept
	for rows.Next() {
		var k Kept
		if err := rows.Scan(&k.DeckID, &k.Card, &k.Reason, &k.DueAt, &k.Interval); err != nil {
			return nil, fmt.Errorf("scan kept card: %w", err)
		}
		out = append(out, k)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read kept cards: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) Reschedule(ctx context.Context, accountID, deckID string, card int, due time.Time, interval int) error {
	tag, err := s.pool.Exec(ctx, `
		UPDATE kept_cards SET due_at = $4, interval_days = $5
		WHERE account_id = $1 AND deck_id = $2 AND card = $3`, accountID, deckID, card, due, interval)
	if err != nil {
		return fmt.Errorf("reschedule card: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotKept
	}
	return nil
}

func (s *PostgresStore) SaveChapterResult(ctx context.Context, accountID, chapterID string, correct, total int) error {
	if _, err := s.pool.Exec(ctx, `
		INSERT INTO chapter_results (account_id, chapter_id, correct, total) VALUES ($1, $2, $3, $4)
		ON CONFLICT (account_id, chapter_id) DO UPDATE SET
			correct = EXCLUDED.correct, total = EXCLUDED.total, completed_at = now()`,
		accountID, chapterID, correct, total); err != nil {
		return fmt.Errorf("save chapter result: %w", err)
	}
	return nil
}

func (s *PostgresStore) ChapterResults(ctx context.Context, accountID string) (map[string]ChapterResult, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT chapter_id, correct, total, completed_at FROM chapter_results WHERE account_id = $1`, accountID)
	if err != nil {
		return nil, fmt.Errorf("select chapter results: %w", err)
	}
	defer rows.Close()
	out := map[string]ChapterResult{}
	for rows.Next() {
		var r ChapterResult
		if err := rows.Scan(&r.ChapterID, &r.Correct, &r.Total, &r.CompletedAt); err != nil {
			return nil, fmt.Errorf("scan chapter result: %w", err)
		}
		out[r.ChapterID] = r
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read chapter results: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) SaveUserDeck(ctx context.Context, accountID string, d Deck) error {
	raw, err := json.Marshal(d)
	if err != nil {
		return fmt.Errorf("encode user deck: %w", err)
	}
	if _, err := s.pool.Exec(ctx, `INSERT INTO user_decks (id, account_id, deck) VALUES ($1, $2, $3)`, d.ID, accountID, raw); err != nil {
		return fmt.Errorf("save user deck: %w", err)
	}
	return nil
}

func (s *PostgresStore) UserDeck(ctx context.Context, id string) (Deck, error) {
	var raw []byte
	if err := s.pool.QueryRow(ctx, `SELECT deck FROM user_decks WHERE id = $1`, id).Scan(&raw); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Deck{}, ErrNotFound
		}
		return Deck{}, fmt.Errorf("select user deck: %w", err)
	}
	var d Deck
	if err := json.Unmarshal(raw, &d); err != nil {
		return Deck{}, fmt.Errorf("decode user deck: %w", err)
	}
	return d, nil
}
