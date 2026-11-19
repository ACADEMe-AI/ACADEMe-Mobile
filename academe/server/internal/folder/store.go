package folder

import (
	"context"
	"errors"
	"fmt"
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

const folderColumns = `id, name, due_on, reminds, created_at`

func scanFolder(row pgx.Row) (Folder, error) {
	var f Folder
	if err := row.Scan(&f.ID, &f.Name, &f.DueOn, &f.Reminds, &f.CreatedAt); err != nil {
		if errors.Is(err, pgx.ErrNoRows) {
			return Folder{}, ErrNotFound
		}
		return Folder{}, fmt.Errorf("scan folder: %w", err)
	}
	return f, nil
}

func (s *PostgresStore) Folders(ctx context.Context, accountID string) ([]Folder, error) {
	rows, err := s.pool.Query(ctx, `SELECT `+folderColumns+` FROM folders WHERE account_id = $1`, accountID)
	if err != nil {
		return nil, fmt.Errorf("select folders: %w", err)
	}
	defer rows.Close()
	var out []Folder
	for rows.Next() {
		f, err := scanFolder(rows)
		if err != nil {
			return nil, err
		}
		out = append(out, f)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read folders: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) Folder(ctx context.Context, accountID, id string) (Folder, error) {
	return scanFolder(s.pool.QueryRow(ctx, `
		SELECT `+folderColumns+` FROM folders WHERE account_id = $1 AND id::text = $2`, accountID, id))
}

func (s *PostgresStore) Create(ctx context.Context, accountID, name string, due *time.Time) (Folder, error) {
	return scanFolder(s.pool.QueryRow(ctx, `
		INSERT INTO folders (account_id, name, due_on) VALUES ($1, $2, $3)
		RETURNING `+folderColumns, accountID, name, due))
}

func (s *PostgresStore) Update(ctx context.Context, accountID, id, name string, due *time.Time, reminds bool) (Folder, error) {
	return scanFolder(s.pool.QueryRow(ctx, `
		UPDATE folders SET name = $3, due_on = $4, reminds = $5
		WHERE account_id = $1 AND id::text = $2
		RETURNING `+folderColumns, accountID, id, name, due, reminds))
}

func (s *PostgresStore) Delete(ctx context.Context, accountID, id string) error {
	tag, err := s.pool.Exec(ctx, `DELETE FROM folders WHERE account_id = $1 AND id::text = $2`, accountID, id)
	if err != nil {
		return fmt.Errorf("delete folder: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (s *PostgresStore) Items(ctx context.Context, folderID string) ([]Item, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, chapter_id, note, deck_id, created_at FROM folder_items
		WHERE folder_id = $1 ORDER BY id`, folderID)
	if err != nil {
		return nil, fmt.Errorf("select folder items: %w", err)
	}
	defer rows.Close()
	var out []Item
	for rows.Next() {
		var it Item
		if err := rows.Scan(&it.ID, &it.ChapterID, &it.Note, &it.DeckID, &it.CreatedAt); err != nil {
			return nil, fmt.Errorf("scan folder item: %w", err)
		}
		out = append(out, it)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read folder items: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) AddChapters(ctx context.Context, folderID string, chapterIDs []string) error {
	if _, err := s.pool.Exec(ctx, `
		INSERT INTO folder_items (folder_id, chapter_id)
		SELECT $1, unnest($2::text[])
		ON CONFLICT (folder_id, chapter_id) DO NOTHING`, folderID, chapterIDs); err != nil {
		return fmt.Errorf("add chapters: %w", err)
	}
	return nil
}

func (s *PostgresStore) AddNote(ctx context.Context, folderID, text string) error {
	if _, err := s.pool.Exec(ctx, `INSERT INTO folder_items (folder_id, note) VALUES ($1, $2)`, folderID, text); err != nil {
		return fmt.Errorf("add note: %w", err)
	}
	return nil
}

func (s *PostgresStore) AddLesson(ctx context.Context, folderID, deckID string) error {
	if _, err := s.pool.Exec(ctx, `INSERT INTO folder_items (folder_id, deck_id) VALUES ($1, $2)`, folderID, deckID); err != nil {
		return fmt.Errorf("add lesson: %w", err)
	}
	return nil
}

func (s *PostgresStore) DeleteItem(ctx context.Context, folderID string, itemID int64) error {
	if _, err := s.pool.Exec(ctx, `DELETE FROM folder_items WHERE folder_id = $1 AND id = $2`, folderID, itemID); err != nil {
		return fmt.Errorf("delete item: %w", err)
	}
	return nil
}

func (s *PostgresStore) Todos(ctx context.Context, folderID string) ([]Todo, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT id, title, day, done_at FROM folder_todos WHERE folder_id = $1 ORDER BY id`, folderID)
	if err != nil {
		return nil, fmt.Errorf("select todos: %w", err)
	}
	defer rows.Close()
	var out []Todo
	for rows.Next() {
		var t Todo
		if err := rows.Scan(&t.ID, &t.Title, &t.Day, &t.DoneAt); err != nil {
			return nil, fmt.Errorf("scan todo: %w", err)
		}
		out = append(out, t)
	}
	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("read todos: %w", err)
	}
	return out, nil
}

func (s *PostgresStore) AddTodo(ctx context.Context, folderID, title string, day *time.Time) error {
	if _, err := s.pool.Exec(ctx, `INSERT INTO folder_todos (folder_id, title, day) VALUES ($1, $2, $3)`, folderID, title, day); err != nil {
		return fmt.Errorf("add todo: %w", err)
	}
	return nil
}

func (s *PostgresStore) SetTodoDone(ctx context.Context, folderID string, todoID int64, doneAt *time.Time) error {
	tag, err := s.pool.Exec(ctx, `UPDATE folder_todos SET done_at = $3 WHERE folder_id = $1 AND id = $2`, folderID, todoID, doneAt)
	if err != nil {
		return fmt.Errorf("update todo: %w", err)
	}
	if tag.RowsAffected() == 0 {
		return ErrNotFound
	}
	return nil
}

func (s *PostgresStore) DeleteTodo(ctx context.Context, folderID string, todoID int64) error {
	if _, err := s.pool.Exec(ctx, `DELETE FROM folder_todos WHERE folder_id = $1 AND id = $2`, folderID, todoID); err != nil {
		return fmt.Errorf("delete todo: %w", err)
	}
	return nil
}
