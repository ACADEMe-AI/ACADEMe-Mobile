package auth

import (
	"context"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/jackc/pgx/v5/pgxpool"
)

const uniqueViolation = "23505"

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func (s *PostgresStore) CreateAccount(ctx context.Context, a Account, passwordHash string) (Account, error) {
	err := s.pool.QueryRow(ctx, `
		INSERT INTO accounts (first_name, last_name, email, password_hash)
		VALUES ($1, $2, $3, $4)
		RETURNING id::text`,
		a.FirstName, a.LastName, a.Email, passwordHash,
	).Scan(&a.ID)
	if pgErr, ok := errors.AsType[*pgconn.PgError](err); ok && pgErr.Code == uniqueViolation {
		return Account{}, ErrEmailTaken
	}
	if err != nil {
		return Account{}, fmt.Errorf("insert account: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) AccountByEmail(ctx context.Context, email string) (Account, string, error) {
	var a Account
	var hash string
	err := s.pool.QueryRow(ctx, `
		SELECT id::text, first_name, last_name, email, COALESCE(password_hash, '')
		FROM accounts WHERE email = $1`,
		email,
	).Scan(&a.ID, &a.FirstName, &a.LastName, &a.Email, &hash)
	if errors.Is(err, pgx.ErrNoRows) {
		return Account{}, "", ErrNotFound
	}
	if err != nil {
		return Account{}, "", fmt.Errorf("select account by email: %w", err)
	}
	return a, hash, nil
}

func (s *PostgresStore) AccountByID(ctx context.Context, id string) (Account, error) {
	var a Account
	err := s.pool.QueryRow(ctx, `
		SELECT id::text, first_name, last_name, email
		FROM accounts WHERE id = $1`,
		id,
	).Scan(&a.ID, &a.FirstName, &a.LastName, &a.Email)
	if errors.Is(err, pgx.ErrNoRows) {
		return Account{}, ErrNotFound
	}
	if err != nil {
		return Account{}, fmt.Errorf("select account by id: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) TokensValidAfter(ctx context.Context, accountID string) (time.Time, error) {
	var at time.Time
	err := s.pool.QueryRow(ctx, "SELECT tokens_valid_after FROM accounts WHERE id = $1", accountID).Scan(&at)
	if errors.Is(err, pgx.ErrNoRows) {
		return time.Time{}, ErrNotFound
	}
	if err != nil {
		return time.Time{}, fmt.Errorf("select tokens valid after: %w", err)
	}
	return at, nil
}

func (s *PostgresStore) AccountByGoogleSubject(ctx context.Context, subject string) (Account, error) {
	var a Account
	err := s.pool.QueryRow(ctx, `
		SELECT id::text, first_name, last_name, email
		FROM accounts WHERE google_subject = $1`,
		subject,
	).Scan(&a.ID, &a.FirstName, &a.LastName, &a.Email)
	if errors.Is(err, pgx.ErrNoRows) {
		return Account{}, ErrNotFound
	}
	if err != nil {
		return Account{}, fmt.Errorf("select account by google subject: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) CreateGoogleAccount(ctx context.Context, a Account, subject string) (Account, error) {
	err := s.pool.QueryRow(ctx, `
		INSERT INTO accounts (first_name, last_name, email, google_subject)
		VALUES ($1, $2, $3, $4)
		RETURNING id::text`,
		a.FirstName, a.LastName, a.Email, subject,
	).Scan(&a.ID)
	if pgErr, ok := errors.AsType[*pgconn.PgError](err); ok && pgErr.Code == uniqueViolation {
		return Account{}, ErrEmailTaken
	}
	if err != nil {
		return Account{}, fmt.Errorf("insert google account: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) LinkGoogle(ctx context.Context, accountID, subject string, at time.Time) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin link google: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	if _, err := tx.Exec(ctx, `
		UPDATE accounts SET google_subject = $2, password_hash = NULL, tokens_valid_after = $3
		WHERE id = $1`,
		accountID, subject, at,
	); err != nil {
		if pgErr, ok := errors.AsType[*pgconn.PgError](err); ok && pgErr.Code == uniqueViolation {
			return ErrEmailTaken
		}
		return fmt.Errorf("link google: %w", err)
	}
	if _, err := tx.Exec(ctx, "DELETE FROM sessions WHERE account_id = $1", accountID); err != nil {
		return fmt.Errorf("end sessions on link: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit link google: %w", err)
	}
	return nil
}

func (s *PostgresStore) ScheduleDeletion(ctx context.Context, id, reason string, at time.Time) error {
	tx, err := s.pool.Begin(ctx)
	if err != nil {
		return fmt.Errorf("begin schedule deletion: %w", err)
	}
	defer tx.Rollback(ctx) //nolint:errcheck
	tag, err := tx.Exec(ctx, `
		UPDATE accounts SET deletion_requested_at = $2, deletion_reason = NULLIF($3, ''), tokens_valid_after = $2
		WHERE id = $1`, id, at, reason)
	if err != nil {
		return fmt.Errorf("mark account for deletion: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	if _, err := tx.Exec(ctx, `DELETE FROM sessions WHERE account_id = $1`, id); err != nil {
		return fmt.Errorf("end sessions: %w", err)
	}
	if err := tx.Commit(ctx); err != nil {
		return fmt.Errorf("commit schedule deletion: %w", err)
	}
	return nil
}

func (s *PostgresStore) CancelDeletion(ctx context.Context, id string) error {
	if _, err := s.pool.Exec(ctx, `
		UPDATE accounts SET deletion_requested_at = NULL, deletion_reason = NULL
		WHERE id = $1 AND deletion_requested_at IS NOT NULL`, id); err != nil {
		return fmt.Errorf("cancel deletion: %w", err)
	}
	return nil
}

func (s *PostgresStore) PurgeDeleted(ctx context.Context, requestedBefore time.Time) ([]string, error) {
	rows, err := s.pool.Query(ctx, `
		DELETE FROM accounts WHERE deletion_requested_at < $1 RETURNING id`, requestedBefore)
	if err != nil {
		return nil, fmt.Errorf("purge accounts: %w", err)
	}
	ids, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		return nil, fmt.Errorf("purge accounts: %w", err)
	}
	return ids, nil
}

func (s *PostgresStore) UpdateName(ctx context.Context, id, firstName, lastName string) (Account, error) {
	a := Account{ID: id}
	err := s.pool.QueryRow(ctx, `
		UPDATE accounts SET first_name = $2, last_name = $3
		WHERE id = $1
		RETURNING first_name, last_name, email`,
		id, firstName, lastName,
	).Scan(&a.FirstName, &a.LastName, &a.Email)
	if errors.Is(err, pgx.ErrNoRows) {
		return Account{}, ErrNotFound
	}
	if err != nil {
		return Account{}, fmt.Errorf("update name: %w", err)
	}
	return a, nil
}

func (s *PostgresStore) CreateSession(ctx context.Context, accountID string, tokenHash []byte, expires time.Time) error {
	if _, err := s.pool.Exec(ctx, `
		INSERT INTO sessions (token_hash, account_id, expires_at)
		VALUES ($1, $2, $3)`,
		tokenHash, accountID, expires,
	); err != nil {
		return fmt.Errorf("insert session: %w", err)
	}
	return nil
}

func (s *PostgresStore) RotateSession(ctx context.Context, oldHash, newHash []byte, expires time.Time) (string, error) {
	var accountID string
	err := s.pool.QueryRow(ctx, `
		WITH old AS (
			DELETE FROM sessions
			WHERE token_hash = $1 AND expires_at > now()
			RETURNING account_id
		)
		INSERT INTO sessions (token_hash, account_id, expires_at)
		SELECT $2, account_id, $3 FROM old
		RETURNING account_id::text`,
		oldHash, newHash, expires,
	).Scan(&accountID)
	if errors.Is(err, pgx.ErrNoRows) {
		return "", ErrInvalidToken
	}
	if err != nil {
		return "", fmt.Errorf("rotate session: %w", err)
	}
	return accountID, nil
}

func (s *PostgresStore) DeleteSession(ctx context.Context, tokenHash []byte) error {
	if _, err := s.pool.Exec(ctx, "DELETE FROM sessions WHERE token_hash = $1", tokenHash); err != nil {
		return fmt.Errorf("delete session: %w", err)
	}
	return nil
}
