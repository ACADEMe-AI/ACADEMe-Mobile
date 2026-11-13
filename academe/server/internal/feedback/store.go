package feedback

import (
	"context"
	"errors"
	"fmt"
	"hash/fnv"
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

func feedbackLockKey(accountID string) int64 {
	h := fnv.New64a()
	_, _ = h.Write([]byte(accountID))
	return int64(h.Sum64()) //nolint:gosec // advisory lock key, not crypto
}

func (s *PostgresStore) InsertLimited(ctx context.Context, accountID string, in Submission, dayStart, dayEnd, weekStart, weekEnd time.Time) (string, error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return "", fmt.Errorf("begin feedback tx: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := tx.Exec(ctx, `SELECT pg_advisory_xact_lock($1)`, feedbackLockKey(accountID)); err != nil {
		return "", fmt.Errorf("lock feedback account: %w", err)
	}
	var id string
	err = tx.QueryRow(ctx, `
		INSERT INTO account_feedback (account_id, category, message, context)
		SELECT $1, $2, $3, $4
		WHERE (SELECT count(*) FROM account_feedback
		       WHERE account_id = $1 AND created_at >= $5 AND created_at < $6) < $7
		  AND (SELECT count(*) FROM account_feedback
		       WHERE account_id = $1 AND created_at >= $8 AND created_at < $9) < $10
		RETURNING id::text`,
		accountID, in.Category, in.Message, in.Context,
		dayStart, dayEnd, perDay, weekStart, weekEnd, perWeek,
	).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		var dayN int
		if err := tx.QueryRow(ctx, `
			SELECT count(*)::int FROM account_feedback
			WHERE account_id = $1 AND created_at >= $2 AND created_at < $3`,
			accountID, dayStart, dayEnd,
		).Scan(&dayN); err != nil {
			return "", fmt.Errorf("count day feedback: %w", err)
		}
		if dayN >= perDay {
			return "", ErrDailyLimit
		}
		return "", ErrWeeklyLimit
	}
	if err != nil {
		return "", fmt.Errorf("insert feedback: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return "", fmt.Errorf("commit feedback: %w", err)
	}
	return id, nil
}
