package auth

import (
	"sync"
	"time"
)

const limiterSweepSize = 10_000

type limiter struct {
	mu      sync.Mutex
	max     int
	window  time.Duration
	hits    map[string][]time.Time
	sweepAt int
}

func newLimiter(maxHits int, window time.Duration) *limiter {
	return &limiter{max: maxHits, window: window, hits: map[string][]time.Time{}, sweepAt: limiterSweepSize}
}

func (l *limiter) allow(key string) bool {
	now := time.Now()
	l.mu.Lock()
	defer l.mu.Unlock()
	if len(l.hits) > l.sweepAt {
		for k, times := range l.hits {
			if len(l.recent(times, now)) == 0 {
				delete(l.hits, k)
			}
		}
		l.sweepAt = max(limiterSweepSize, 2*len(l.hits))
	}
	recent := l.recent(l.hits[key], now)
	if len(recent) >= l.max {
		l.hits[key] = recent
		return false
	}
	l.hits[key] = append(recent, now)
	return true
}

func (l *limiter) recent(times []time.Time, now time.Time) []time.Time {
	cutoff := now.Add(-l.window)
	i := 0
	for i < len(times) && !times[i].After(cutoff) {
		i++
	}
	return times[i:]
}
