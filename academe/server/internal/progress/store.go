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
	ActiveDays   [7]bool
	OverallGrade *float64
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
	if err != nil {
		return c, err
	}
	rows, err := s.pool.Query(ctx, `
		SELECT day FROM study_days
		WHERE account_id = $1 AND day >= $2::date AND day < $3::date`,
		accountID, startDay, endDay,
	)
	if err != nil {
		return c, err
	}
	defer rows.Close()
	weekStart := start.In(india.Loc)
	for rows.Next() {
		var day time.Time
		if err := rows.Scan(&day); err != nil {
			return c, err
		}
		d := day.In(india.Loc)
		offset := int(d.Sub(weekStart).Hours() / 24)
		if offset >= 0 && offset < 7 {
			c.ActiveDays[offset] = true
		}
	}
	if err := rows.Err(); err != nil {
		return c, err
	}
	var grade *float64
	var avg *float64
	err = s.pool.QueryRow(ctx, `
		SELECT AVG(correct::float8 / total::float8 * 100.0)
		FROM chapter_results WHERE account_id = $1`, accountID,
	).Scan(&avg)
	if err != nil {
		return c, err
	}
	if avg != nil {
		v := *avg
		grade = &v
	}
	c.OverallGrade = grade
	return c, nil
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
