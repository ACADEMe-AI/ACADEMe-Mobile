package report

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func (s *PostgresStore) Save(ctx context.Context, accountID string, report Report) error {
	tag, err := s.pool.Exec(ctx, `
		INSERT INTO content_reports (kind, target_id, account_id, reason, note)
		SELECT $1::text, $2::text, $3::uuid, $4, $5
		WHERE CASE $1::text
			WHEN 'check' THEN EXISTS (SELECT 1 FROM scans WHERE id::text = $2 AND account_id = $3 AND mode = 'check')
			WHEN 'lesson' THEN EXISTS (SELECT 1 FROM user_decks WHERE id = $2 AND account_id = $3)
			ELSE false
		END
		ON CONFLICT (kind, target_id, account_id)
		DO UPDATE SET reason = EXCLUDED.reason, note = EXCLUDED.note, created_at = now()`,
		report.Kind, report.ID, accountID, report.Reason, report.Note)
	if err != nil {
		return fmt.Errorf("save report: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}
