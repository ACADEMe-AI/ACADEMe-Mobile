package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
)

func (s *PostgresStore) PasswordHash(ctx context.Context, accountID string) (string, error) {
	var hash string
	err := s.pool.QueryRow(ctx,
		"SELECT COALESCE(password_hash, '') FROM accounts WHERE id = $1", accountID,
	).Scan(&hash)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrNotFound
	}
	if err != nil {
		return "", fmt.Errorf("select password hash: %w", err)
	}
	return hash, nil
}

func (s *PostgresStore) ChangePassword(ctx context.Context, accountID, oldHash, newHash string, at time.Time) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin change password: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	tag, err := tx.Exec(ctx, `
		UPDATE accounts SET password_hash = $3, tokens_valid_after = $4
		WHERE id = $1 AND COALESCE(password_hash, '') = $2`,
		accountID, oldHash, newHash, at)
	if err != nil {
		return fmt.Errorf("set password: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrWrongPassword
	}
	if _, err := tx.Exec(ctx, "DELETE FROM sessions WHERE account_id = $1", accountID); err != nil {
		return fmt.Errorf("end sessions on password change: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit change password: %w", err)
	}
	return nil
}

func (s *PostgresStore) AddGoogle(ctx context.Context, accountID, subject, email string) error {
	tag, err := s.pool.Exec(ctx, `
		UPDATE accounts SET google_subject = $2, google_email = $3
		WHERE id = $1`,
		accountID, subject, email)
	if pgErr, ok := errors.AsType[*pgconn.PgError](err); ok && pgErr.Code == uniqueViolation {
		return ErrGoogleTaken
	}
	if err != nil {
		return fmt.Errorf("add google: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (s *PostgresStore) RemoveGoogle(ctx context.Context, accountID string) error {
	var hasPassword bool
	err := s.pool.QueryRow(ctx, `
		UPDATE accounts SET
			google_subject = CASE WHEN password_hash IS NULL THEN google_subject END,
			google_email = CASE WHEN password_hash IS NULL THEN google_email END
		WHERE id = $1
		RETURNING password_hash IS NOT NULL`,
		accountID,
	).Scan(&hasPassword)
	if errors.Is(err, pgx.ErrNoRows) {
		return ErrNotFound
	}
	if err != nil {
		return fmt.Errorf("remove google: %w", err)
	}
	if !hasPassword {
		return ErrPasswordRequired
	}
	return nil
}
