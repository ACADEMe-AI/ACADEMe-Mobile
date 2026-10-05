package profile

import (
	"testing"
	"testing/synctest"
	"time"

	"github.com/google/go-cmp/cmp"
)

func day(month time.Month, d int) time.Time {
	year := 2000
	if month == time.December {
		year = 1999
	}
	return time.Date(year, month, d, 0, 0, 0, 0, time.UTC)
}

func TestStreakOn(t *testing.T) {
	lastMinuteOfJan1 := 18*time.Hour + 29*time.Minute
	tests := []struct {
		name string
		days []time.Time
		wait time.Duration
		want Streak
	}{
		{name: "no days", want: Streak{}},
		{
			name: "today not counted keeps yesterday's streak",
			days: []time.Time{day(time.December, 30), day(time.December, 31)},
			want: Streak{Current: 2, Longest: 2},
		},
		{
			name: "a minute before midnight in India the streak holds",
			days: []time.Time{day(time.December, 30), day(time.December, 31)},
			wait: lastMinuteOfJan1 + 59*time.Second,
			want: Streak{Current: 2, Longest: 2},
		},
		{
			name: "midnight in India ends a streak that missed a day",
			days: []time.Time{day(time.December, 30), day(time.December, 31)},
			wait: lastMinuteOfJan1 + time.Minute,
			want: Streak{Current: 0, Longest: 2},
		},
		{
			name: "today counted",
			days: []time.Time{day(time.December, 31), day(time.January, 1)},
			want: Streak{Current: 2, Longest: 2, TodayCounted: true},
		},
		{
			name: "after midnight in India yesterday still counts",
			days: []time.Time{day(time.December, 31), day(time.January, 1)},
			wait: lastMinuteOfJan1 + time.Minute,
			want: Streak{Current: 2, Longest: 2},
		},
		{
			name: "a gap splits runs and the longest is kept",
			days: []time.Time{
				day(time.December, 20), day(time.December, 21), day(time.December, 22),
				day(time.December, 31), day(time.January, 1), day(time.January, 1),
			},
			want: Streak{Current: 2, Longest: 3, TodayCounted: true},
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			synctest.Test(t, func(t *testing.T) {
				time.Sleep(tc.wait)
				got := streakOn(tc.days, time.Now())
				if diff := cmp.Diff(tc.want, got); diff != "" {
					t.Errorf("streakOn(%v) at %v (-want +got):\n%s", tc.days, time.Now().In(india), diff)
				}
			})
		})
	}
}
