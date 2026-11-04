package progress

import (
	"context"
	"time"

	"github.com/jackc/pgx/v5/pgxpool"

	"academe/server/internal/india"
)

type WeekCounts struct {
	DaysActive   int
	Lessons      int
	ChapterTests int
	XP           int
}

type PostgresStore struct {
	pool *pgxpool.Pool
}

func NewPostgresStore(pool *pgxpool.Pool) *PostgresStore {
	return &PostgresStore{pool: pool}
}

func (s *PostgresStore) WeekCounts(ctx context.Context, accountID string, start, end time.Time) (WeekCounts, error) {
	var c WeekCounts
	startDay := start.In(india.Loc).Format("2006-01-02")
	endDay := end.In(india.Loc).Format("2006-01-02")
	err := s.pool.QueryRow(ctx, `
		SELECT
			(SELECT COUNT(*)::int FROM study_days
			 WHERE account_id = $1 AND day >= $2::date AND day < $3::date),
			(SELECT COUNT(*)::int FROM deck_completions
			 WHERE account_id = $1 AND completed_at >= $4 AND completed_at < $5),
			(SELECT COUNT(*)::int FROM chapter_results
			 WHERE account_id = $1 AND completed_at >= $4 AND completed_at < $5),
			(SELECT COALESCE(SUM(amount), 0)::int FROM xp_events
			 WHERE account_id = $1 AND created_at >= $4 AND created_at < $5)`,
		accountID, startDay, endDay, start, end,
	).Scan(&c.DaysActive, &c.Lessons, &c.ChapterTests, &c.XP)
	return c, err
}

func (s *PostgresStore) LessonDecksInWeek(ctx context.Context, accountID string, start, end time.Time) ([]string, error) {
	rows, err := s.pool.Query(ctx, `
		SELECT deck_id FROM deck_completions
		WHERE account_id = $1 AND completed_at >= $2 AND completed_at < $3`,
		accountID, start, end,
	)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}
