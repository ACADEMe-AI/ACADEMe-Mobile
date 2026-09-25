package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
)

func (s *PostgresStore) CreateResetCode(ctx context.Context, accountID string, codeHash, linkHash []byte, expires time.Time) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin create reset code: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := tx.Exec(ctx, `
		UPDATE password_reset_codes SET used_at = now()
		WHERE account_id = $1 AND used_at IS NULL`, accountID); err != nil {
		return fmt.Errorf("replace reset codes: %w", err)
	}
	if _, err := tx.Exec(ctx, `
		INSERT INTO password_reset_codes (account_id, code_hash, link_hash, expires_at)
		VALUES ($1, $2, $3, $4)`, accountID, codeHash, linkHash, expires); err != nil {
		return fmt.Errorf("insert reset code: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit reset code: %w", err)
	}
	return nil
}

func (s *PostgresStore) ClaimResetAttempt(ctx context.Context, accountID string) (ResetCode, error) {
	var c ResetCode
	err := s.pool.QueryRow(ctx, `
		UPDATE password_reset_codes SET attempts = attempts + 1
		WHERE used_at IS NULL AND id = (
			SELECT id FROM password_reset_codes
			WHERE account_id = $1 AND used_at IS NULL
			ORDER BY created_at DESC LIMIT 1
		)
		RETURNING id::text, code_hash, attempts, expires_at`, accountID,
	).Scan(&c.ID, &c.Hash, &c.Attempts, &c.Expires)
	if errors.Is(err, pgx.ErrNoRows) {
		return ResetCode{}, ErrCodeExpired
	}
	if err != nil {
		return ResetCode{}, fmt.Errorf("claim reset attempt: %w", err)
	}
	return c, nil
}

func (s *PostgresStore) ClaimResetLink(ctx context.Context, linkHash []byte) (ResetCode, error) {
	var c ResetCode
	err := s.pool.QueryRow(ctx, `
		UPDATE password_reset_codes SET attempts = attempts + 1
		WHERE link_hash = $1 AND used_at IS NULL
		RETURNING id::text, code_hash, attempts, expires_at`, linkHash,
	).Scan(&c.ID, &c.Hash, &c.Attempts, &c.Expires)
	if errors.Is(err, pgx.ErrNoRows) {
		return ResetCode{}, ErrResetTokenExpired
	}
	if err != nil {
		return ResetCode{}, fmt.Errorf("claim reset link: %w", err)
	}
	return c, nil
}

func (s *PostgresStore) MarkResetCodeUsed(ctx context.Context, codeID string, tokenHash []byte, at time.Time) error {
	tag, err := s.pool.Exec(ctx, `
		UPDATE password_reset_codes SET used_at = $3, reset_token_hash = $2
		WHERE id = $1 AND used_at IS NULL`, codeID, tokenHash, at)
	if err != nil {
		return fmt.Errorf("mark reset code used: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrCodeExpired
	}
	return nil
}

func (s *PostgresStore) CompleteReset(ctx context.Context, tokenHash []byte, verifiedAfter time.Time, passwordHash string, at time.Time) (string, error) {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return "", fmt.Errorf("begin complete reset: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	var accountID string
	err = tx.QueryRow(ctx, `
		UPDATE password_reset_codes SET completed_at = now()
		WHERE reset_token_hash = $1 AND completed_at IS NULL AND used_at > $2
		RETURNING account_id::text`, tokenHash, verifiedAfter,
	).Scan(&accountID)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrResetTokenExpired
	}
	if err != nil {
		return "", fmt.Errorf("use reset token: %w", err)
	}
	tag, err := tx.Exec(ctx, `
		UPDATE accounts SET password_hash = $2, tokens_valid_after = $3
		WHERE id = $1 AND password_hash IS NOT NULL`, accountID, passwordHash, at)
	if err != nil {
		return "", fmt.Errorf("set password: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return "", ErrResetTokenExpired
	}
	if _, err := tx.Exec(ctx, "DELETE FROM sessions WHERE account_id = $1", accountID); err != nil {
		return "", fmt.Errorf("end sessions on reset: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return "", fmt.Errorf("commit complete reset: %w", err)
	}
	return accountID, nil
}
