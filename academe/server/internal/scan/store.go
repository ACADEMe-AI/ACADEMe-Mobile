package scan

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

const columns = `id, mode, title, body, chapter, thread_id::text, folder_id::text, deck_id, result, created_at`

func scanRow(row pgx.Row) (Scan, error) {
	var s Scan
	var result []byte
	if err := row.Scan(&s.ID, &s.Mode, &s.Title, &s.Text, &s.Chapter, &s.ThreadID, &s.FolderID, &s.DeckID, &result, &s.CreatedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Scan{}, ErrNotFound
		}
		return Scan{}, fmt.Errorf("scan row: %w", err)
	}
	if result != nil {
		var m Marking
		if err := json.Unmarshal(result, &m); err != nil {
			return Scan{}, fmt.Errorf("decode marking: %w", err)
		}
		s.Result = &m
	}
	return s, nil
}

func (s *PostgresStore) Create(ctx context.Context, accountID string, sc Scan) (Scan, error) {
	return scanRow(s.pool.QueryRow(ctx, `
		INSERT INTO scans (account_id, mode, title, body, chapter) VALUES ($1, $2, $3, $4, $5)
		RETURNING `+columns, accountID, sc.Mode, sc.Title, sc.Text, sc.Chapter))
}

func (s *PostgresStore) Scans(ctx context.Context, accountID string, limit int) ([]Scan, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT `+columns+` FROM scans WHERE account_id = $1 ORDER BY created_at DESC LIMIT $2`, accountID, limit)
	if err != nil {
		return nil, fmt.Errorf("select scans: %w", err)
	}
	defer rows.Close()
	out := []Scan{}
	for rows.Next() {
		sc, err := scanRow(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, sc)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read scans: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) Scan(ctx context.Context, accountID, id string) (Scan, error) {
	return scanRow(s.pool.QueryRow(ctx, `
		SELECT `+columns+` FROM scans WHERE account_id = $1 AND id::text = $2`, accountID, id))
}

func (s *PostgresStore) update(ctx context.Context, accountID, id, set string, args ...any) error {
	tag, err := s.pool.Exec(ctx, `UPDATE scans SET `+set+` WHERE account_id = $1 AND id::text = $2`,
		append([]any{accountID, id}, args...)...)
	if err != nil {
		return fmt.Errorf("update scan: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (s *PostgresStore) SetThread(ctx context.Context, accountID, id, threadID string) error {
	return s.update(ctx, accountID, id, `thread_id = $3::uuid`, threadID)
}

func (s *PostgresStore) SetResult(ctx context.Context, accountID, id string, m Marking) error {
	raw, err := json.Marshal(m)
	if err != nil {
		return fmt.Errorf("encode marking: %w", err)
	}
	return s.update(ctx, accountID, id, `result = $3`, raw)
}

func (s *PostgresStore) SetFolder(ctx context.Context, accountID, id, folderID string, deckID *string) error {
	return s.update(ctx, accountID, id, `folder_id = $3::uuid, deck_id = $4`, folderID, deckID)
}
