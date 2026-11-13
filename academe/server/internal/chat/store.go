package chat

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func (s *PostgresStore) Threads(ctx context.Context, accountID string) ([]Thread, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, mode, title, updated_at FROM chat_threads
		WHERE account_id = $1 ORDER BY updated_at DESC LIMIT 200`, accountID)
	if err != nil {
		return nil, fmt.Errorf("select threads: %w", err)
	}
	threads, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (Thread, error) {
		var t Thread
		err := row.Scan(&t.ID, &t.Mode, &t.Title, &t.UpdatedAt)
		return t, err
	})
	if err != nil {
		return nil, fmt.Errorf("scan threads: %w", err)
	}
	return threads, nil
}

func (s *PostgresStore) CreateThread(ctx context.Context, accountID string, mode Mode, title string) (Thread, error) {
	t := Thread{Mode: mode, Title: title}
	err := s.pool.QueryRow(ctx, `
		INSERT INTO chat_threads (account_id, mode, title) VALUES ($1, $2, $3)
		RETURNING id, updated_at`, accountID, mode, title).Scan(&t.ID, &t.UpdatedAt)
	if err != nil {
		return Thread{}, fmt.Errorf("insert thread: %w", err)
	}
	return t, nil
}

func (s *PostgresStore) Thread(ctx context.Context, accountID, threadID string) (Thread, error) {
	var t Thread
	err := s.pool.QueryRow(ctx, `
		SELECT id, mode, title, updated_at FROM chat_threads
		WHERE id = $1 AND account_id = $2`, threadID, accountID).Scan(&t.ID, &t.Mode, &t.Title, &t.UpdatedAt)
	if errors.Is(err, pgx.ErrNoRows) || isInvalidUUID(err) {
		return Thread{}, ErrNotFound
	}
	if err != nil {
		return Thread{}, fmt.Errorf("select thread: %w", err)
	}
	return t, nil
}

func (s *PostgresStore) Messages(ctx context.Context, threadID string) ([]Message, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, role, body, COALESCE(rating, 0), created_at FROM chat_messages
		WHERE thread_id = $1 ORDER BY id`, threadID)
	if err != nil {
		return nil, fmt.Errorf("select messages: %w", err)
	}
	messages, err := pgx.CollectRows(rows, func(row pgx.CollectableRow) (Message, error) {
		var m Message
		err := row.Scan(&m.ID, &m.Role, &m.Body, &m.Rating, &m.CreatedAt)
		return m, err
	})
	if err != nil {
		return nil, fmt.Errorf("scan messages: %w", err)
	}
	return messages, nil
}

func (s *PostgresStore) AddMessage(ctx context.Context, threadID string, role Role, body string) (Message, error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return Message{}, fmt.Errorf("begin add message: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	m := Message{Role: role, Body: body}
	if err := tx.QueryRow(ctx, `
		INSERT INTO chat_messages (thread_id, role, body) VALUES ($1, $2, $3)
		RETURNING id, created_at`, threadID, role, body).Scan(&m.ID, &m.CreatedAt); err != nil {
		return Message{}, fmt.Errorf("insert message: %w", err)
	}
	if _, err := tx.Exec(ctx, `UPDATE chat_threads SET updated_at = $2 WHERE id = $1`, threadID, m.CreatedAt); err != nil {
		return Message{}, fmt.Errorf("touch thread: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return Message{}, fmt.Errorf("commit add message: %w", err)
	}
	return m, nil
}

func (s *PostgresStore) DeleteLastReply(ctx context.Context, threadID string) error {
	tag, err := s.pool.Exec(ctx, `
		DELETE FROM chat_messages WHERE id = (
			SELECT id FROM chat_messages WHERE thread_id = $1 ORDER BY id DESC LIMIT 1
		) AND role = 'pebby'`, threadID)
	if err != nil {
		return fmt.Errorf("delete last reply: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNothingToRetry
	}
	return nil
}

func (s *PostgresStore) Rate(ctx context.Context, accountID string, messageID int64, rating int) error {
	var value *int
	if rating != 0 {
		value = &rating
	}
	tag, err := s.pool.Exec(ctx, `
		UPDATE chat_messages m SET rating = $3
		FROM chat_threads t
		WHERE m.id = $2 AND m.thread_id = t.id AND t.account_id = $1 AND m.role = 'pebby'`,
		accountID, messageID, value)
	if err != nil {
		return fmt.Errorf("rate message: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (s *PostgresStore) Report(ctx context.Context, accountID string, messageID int64, report Report) error {
	tag, err := s.pool.Exec(ctx, `
		INSERT INTO chat_reports (message_id, account_id, reason, note)
		SELECT m.id, t.account_id, $3, $4
		FROM chat_messages m JOIN chat_threads t ON t.id = m.thread_id
		WHERE m.id = $2 AND t.account_id = $1 AND m.role = 'pebby'
		ON CONFLICT (message_id, account_id)
		DO UPDATE SET reason = EXCLUDED.reason, note = EXCLUDED.note, created_at = now()`,
		accountID, messageID, report.Reason, report.Note)
	if err != nil {
		return fmt.Errorf("report message: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func isInvalidUUID(err error) bool {
	pgErr, ok := errors.AsType[*pgconn.PgError](err)
	return ok && pgErr.Code == "22P02"
}
