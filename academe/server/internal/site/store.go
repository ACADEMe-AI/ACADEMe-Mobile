package site

import (
	"context"
	"errors"
	"fmt"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

const requestsPerIPPerDay = 5

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func (s *PostgresStore) RequestDeletion(ctx context.Context, email, ip string) (bool, error) {
	if _, err := s.pool.Exec(ctx, `DELETE FROM deletion_requests WHERE created_at < now() - interval '1 year'`); err != nil {
		return false, fmt.Errorf("expire deletion requests: %w", err)
	}
	var id int64
	err := s.pool.QueryRow(ctx, `
		INSERT INTO deletion_requests (email, ip)
		SELECT $1, $2
		WHERE NOT EXISTS (SELECT 1 FROM deletion_requests
		                  WHERE email = $1 AND created_at > now() - interval '1 day')
		  AND (SELECT count(*) FROM deletion_requests
		       WHERE ip = $2 AND created_at > now() - interval '1 day') < $3
		RETURNING id`, email, ip, requestsPerIPPerDay).Scan(&id)
	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("record deletion request: %w", err)
	}
	return true, nil
}
