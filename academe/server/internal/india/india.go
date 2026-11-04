package india

import "time"

var Loc, _ = time.LoadLocation("Asia/Kolkata")

func DayRange(now time.Time) (start, end time.Time) {
	t := now.In(Loc)
	start = time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, Loc)
	end = start.AddDate(0, 0, 1)
	return start, end
}

// WeekRange is Monday 00:00 IST through the following Monday 00:00 IST.
func WeekRange(now time.Time) (start, end time.Time) {
	t := now.In(Loc)
	offset := (int(t.Weekday()) + 6) % 7
	start = time.Date(t.Year(), t.Month(), t.Day()-offset, 0, 0, 0, 0, Loc)
	end = start.AddDate(0, 0, 7)
	return start, end
}

// UsageWeekBounds matches billing usage_counts week keys (UTC date of IST Monday).
func UsageWeekBounds(now time.Time) (start, next time.Time) {
	t := now.In(Loc)
	offset := (int(t.Weekday()) + 6) % 7
	monday := time.Date(t.Year(), t.Month(), t.Day()-offset, 0, 0, 0, 0, Loc)
	start = time.Date(monday.Year(), monday.Month(), monday.Day(), 0, 0, 0, 0, time.UTC)
	next = monday.AddDate(0, 0, 7)
	return start, next
}

func UsageDayUTC(now time.Time) time.Time {
	t := now.In(Loc)
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, time.UTC)
}
