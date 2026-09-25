package profile

import (
	"context"
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

const selectProfile = `
	SELECT p.language, p.birth_year, p.class_level, p.board, p.setup_done_at IS NOT NULL,
	       COALESCE((SELECT sum(amount) FROM xp_events x WHERE x.account_id = $1), 0)
	FROM (SELECT $1::uuid AS account_id) a
	LEFT JOIN profiles p ON p.account_id = a.account_id`

type queryer interface {
	QueryRow(ctx context.Context, sql string, args ...any) pgx.Row
}

func readProfile(ctx context.Context, q queryer, accountID string) (Profile, error) {
	var p Profile
	var done *bool
	err := q.QueryRow(ctx, selectProfile, accountID).Scan(&p.Language, &p.BirthYear, &p.Class, &p.Board, &done, &p.XP)
	if err != nil {
		return Profile{}, fmt.Errorf("select profile: %w", err)
	}
	p.SetupDone = done != nil && *done
	return p, nil
}

func (s *PostgresStore) Profile(ctx context.Context, accountID string) (Profile, error) {
	return readProfile(ctx, s.pool, accountID)
}

func (s *PostgresStore) Apply(ctx context.Context, accountID string, u Update) (Profile, error) {
	if _, err := s.pool.Exec(ctx, `
		INSERT INTO profiles (account_id, language, birth_year, class_level, board)
		VALUES ($1, $2, $3, $4, $5)
		ON CONFLICT (account_id) DO UPDATE SET
			language    = COALESCE(EXCLUDED.language, profiles.language),
			birth_year  = COALESCE(EXCLUDED.birth_year, profiles.birth_year),
			class_level = COALESCE(EXCLUDED.class_level, profiles.class_level),
			board       = COALESCE(EXCLUDED.board, profiles.board),
			updated_at  = now()`,
		accountID, u.Language, u.BirthYear, u.Class, u.Board,
	); err != nil {
		return Profile{}, fmt.Errorf("upsert profile: %w", err)
	}
	return readProfile(ctx, s.pool, accountID)
}

func (s *PostgresStore) CompleteSetup(ctx context.Context, accountID string, xp int, reason string) (Profile, error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return Profile{}, fmt.Errorf("begin complete setup: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := tx.Exec(ctx, `
		UPDATE profiles SET setup_done_at = now(), updated_at = now()
		WHERE account_id = $1 AND setup_done_at IS NULL`, accountID); err != nil {
		return Profile{}, fmt.Errorf("mark setup done: %w", err)
	}
	if _, err := tx.Exec(ctx, `
		INSERT INTO xp_events (account_id, amount, reason) VALUES ($1, $2, $3)
		ON CONFLICT (account_id, reason) DO NOTHING`, accountID, xp, reason); err != nil {
		return Profile{}, fmt.Errorf("award setup xp: %w", err)
	}
	p, err := readProfile(ctx, tx, accountID)
	if err != nil {
		return Profile{}, err
	}
	if err := tx.Commit(ctx); err != nil {
		return Profile{}, fmt.Errorf("commit complete setup: %w", err)
	}
	return p, nil
}
