package profile

import (
	"slices"
	"time"
)

var india = time.FixedZone("IST", 5*60*60+30*60)

type Streak struct {
	Current      int  `json:"current"`
	Longest      int  `json:"longest"`
	TodayCounted bool `json:"todayCounted"`
}

func dayOf(t time.Time) time.Time {
	y, m, d := t.Date()
	return time.Date(y, m, d, 0, 0, 0, 0, time.UTC)
}

func streakOn(days []time.Time, now time.Time) Streak {
	seen := map[time.Time]bool{}
	for _, d := range days {
		seen[dayOf(d)] = true
	}
	today := dayOf(now.In(india))
	s := Streak{TodayCounted: seen[today]}
	day := today
	if !s.TodayCounted {
		day = day.AddDate(0, 0, -1)
	}
	for ; seen[day]; day = day.AddDate(0, 0, -1) {
		s.Current++
	}
	sorted := make([]time.Time, 0, len(seen))
	for d := range seen {
		sorted = append(sorted, d)
	}
	slices.SortFunc(sorted, time.Time.Compare)
	run := 0
	for i, d := range sorted {
		if i > 0 && sorted[i-1].AddDate(0, 0, 1).Equal(d) {
			run++
		} else {
			run = 1
		}
		s.Longest = max(s.Longest, run)
	}
	return s
}
