package billing

import (
	"context"
	"errors"
	"time"

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

func (s *PostgresStore) Entitlement(ctx context.Context, accountID string) (*Entitlement, error) {
	var e Entitlement
	err := s.pool.QueryRow(ctx, `
		SELECT platform, product_id, base_plan_id, purchase_token, state, expires_at, auto_renew, raw, event_at
		FROM subscriptions WHERE account_id = $1`, accountID,
	).Scan(&e.Platform, &e.ProductID, &e.BasePlanID, &e.Token, &e.State, &e.ExpiresAt, &e.AutoRenew, &e.Raw, &e.EventAt)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	return &e, nil
}

func (s *PostgresStore) Apply(ctx context.Context, eventID string, changes []Change) (bool, error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return false, err
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if eventID != "" {
		tag, err := tx.Exec(ctx, `INSERT INTO billing_events (id) VALUES ($1) ON CONFLICT DO NOTHING`, eventID)
		if err != nil {
			return false, err
		}
		if tag.RowsAffected() == 0 {
			return false, nil
		}
	}
	for _, c := range changes {
		if c.Entitlement == nil {
			if _, err := tx.Exec(ctx, `DELETE FROM subscriptions WHERE account_id = $1`, c.AccountID); err != nil {
				return false, err
			}
			continue
		}
		e := c.Entitlement
		_, err := tx.Exec(ctx, `
			INSERT INTO subscriptions (account_id, platform, product_id, base_plan_id, purchase_token, state, expires_at, auto_renew, raw, event_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
			ON CONFLICT (account_id) DO UPDATE SET
				platform = EXCLUDED.platform, product_id = EXCLUDED.product_id, base_plan_id = EXCLUDED.base_plan_id,
				purchase_token = EXCLUDED.purchase_token, state = EXCLUDED.state, expires_at = EXCLUDED.expires_at,
				auto_renew = EXCLUDED.auto_renew, raw = EXCLUDED.raw, event_at = EXCLUDED.event_at, updated_at = now()
			WHERE subscriptions.event_at <= EXCLUDED.event_at`,
			c.AccountID, e.Platform, e.ProductID, e.BasePlanID, e.Token, e.State, e.ExpiresAt, e.AutoRenew, e.Raw, e.EventAt)
		if pgErr, ok := errors.AsType[*pgconn.PgError](err); ok && pgErr.Code == "23503" {
			return false, ErrUnknownAccount
		}
		if err != nil {
			return false, err
		}
	}
	return true, tx.Commit(ctx)
}

func (s *PostgresStore) Usage(ctx context.Context, accountID string, day time.Time) (map[Feature]int, error) {
	rows, err := s.pool.Query(ctx, `SELECT feature, count FROM usage_counts WHERE account_id = $1 AND day = $2`, accountID, day)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	out := map[Feature]int{}
	for rows.Next() {
		var f string
		var n int
		if err := rows.Scan(&f, &n); err != nil {
			return nil, err
		}
		out[Feature(f)] = n
	}
	return out, rows.Err()
}

func (s *PostgresStore) Take(ctx context.Context, accountID string, day time.Time, f Feature, limit int) (bool, error) {
	var n int
	err := s.pool.QueryRow(ctx, `
		INSERT INTO usage_counts (account_id, day, feature, count) VALUES ($1, $2, $3, 1)
		ON CONFLICT (account_id, day, feature) DO UPDATE SET count = usage_counts.count + 1
		WHERE $4::integer < 0 OR usage_counts.count < $4::integer
		RETURNING count`, accountID, day, string(f), limit).Scan(&n)
	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}
	return err == nil, err
}

func (s *PostgresStore) Refund(ctx context.Context, accountID string, day time.Time, f Feature) error {
	_, err := s.pool.Exec(ctx, `
		UPDATE usage_counts SET count = count - 1
		WHERE account_id = $1 AND day = $2 AND feature = $3 AND count > 0`, accountID, day, string(f))
	return err
}
