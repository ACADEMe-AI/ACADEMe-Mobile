package india

import (
	"testing"
	"time"
)

func TestWeekRangeMondayIST(t *testing.T) {
	wed := time.Date(2026, 11, 5, 15, 0, 0, 0, Loc)
	start, end := WeekRange(wed)
	if got := start.Format("2006-01-02"); got != "2026-11-02" {
		t.Fatalf("week start = %s, want 2026-11-02", got)
	}
	if end.Sub(start) != 7*24*time.Hour {
		t.Fatalf("week length = %v, want 7d", end.Sub(start))
	}
}
