package lessons

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"math/rand/v2"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"academe/server/internal/sarvam"
	"academe/server/internal/study"
)

const (
	authorAttempts = 4
	reviewAttempts = 3
	revisions      = 2
	authorHeat     = 0.4
	reviewerHeat   = 0.1
)

type Chatter interface {
	Chat(ctx context.Context, messages []sarvam.Message, temperature float64) (string, error)
}

type Generator struct {
	Author   Chatter
	Reviewer Chatter
	Model    string
	Out      string
	Force    bool
	Timeout  time.Duration
	Backoff  time.Duration
	Retries  int
	Logger   *slog.Logger
}

type Summary struct {
	Approved, Draft, Failed, Skipped int
	Busy                             time.Duration
	Elapsed                          time.Duration
}

type Review struct {
	Issues    []string  `json:"issues"`
	Rounds    int       `json:"rounds"`
	CheckedAt time.Time `json:"checkedAt"`
}

func (g *Generator) Pending(jobs []Job) ([]Job, int, error) {
	if err := os.MkdirAll(g.Out, 0o750); err != nil {
		return nil, 0, fmt.Errorf("create %s: %w", g.Out, err)
	}
	decks, err := study.ReadDecks(os.DirFS(g.Out))
	if err != nil {
		return nil, 0, err
	}
	have := map[string]study.Deck{}
	for _, d := range decks {
		have[d.ID] = d
	}
	var pending []Job
	for _, j := range jobs {
		d, ok := have[j.ID()]
		if ok && (d.GeneratedBy == nil || d.Approved() && !g.Force) {
			continue
		}
		pending = append(pending, j)
	}
	return pending, len(jobs) - len(pending), nil
}

func (g *Generator) Run(ctx context.Context, jobs []Job, workers int) (Summary, error) {
	began := time.Now()
	pending, skipped, err := g.Pending(jobs)
	if err != nil {
		return Summary{}, err
	}
	sum := Summary{Skipped: skipped}
	queue := make(chan Job)
	var mu sync.Mutex
	var wg sync.WaitGroup
	for range max(1, workers) {
		wg.Go(func() {
			for j := range queue {
				start := time.Now()
				status, err := g.one(ctx, j)
				took := time.Since(start)
				mu.Lock()
				sum.Busy += took
				switch {
				case err != nil:
					sum.Failed++
				case status == study.Approved:
					sum.Approved++
				default:
					sum.Draft++
				}
				done := sum.Approved + sum.Draft + sum.Failed
				mu.Unlock()
				if err != nil {
					g.Logger.Error("lesson failed", "id", j.ID(), "seconds", int(took.Seconds()), "done", done, "of", len(pending), "error", err)
					continue
				}
				g.Logger.Info("lesson", "id", j.ID(), "status", status, "title", j.Lesson().Title, "seconds", int(took.Seconds()), "done", done, "of", len(pending))
			}
		})
	}
	for _, j := range pending {
		if ctx.Err() != nil {
			break
		}
		queue <- j
	}
	close(queue)
	wg.Wait()
	sum.Elapsed = time.Since(began)
	return sum, ctx.Err()
}

func (g *Generator) one(ctx context.Context, j Job) (string, error) {
	var deck study.Deck
	var issues []string
	for round := 0; ; round++ {
		var err error
		if deck, err = g.write(ctx, j, deck, issues); err != nil {
			return "", err
		}
		v, err := g.review(ctx, j, deck)
		if err != nil {
			return "", err
		}
		if v.OK {
			return study.Approved, g.save(j, deck, study.Approved, nil)
		}
		issues = v.Issues
		g.Logger.Info("review asked for changes", "id", j.ID(), "round", round+1, "issues", strings.Join(issues, " | "))
		if round == revisions {
			return study.Draft, g.save(j, deck, study.Draft, &Review{Issues: issues, Rounds: round + 1, CheckedAt: time.Now().UTC()})
		}
	}
}

func (g *Generator) write(ctx context.Context, j Job, previous study.Deck, issues []string) (study.Deck, error) {
	messages := []sarvam.Message{{Role: "system", Content: authorSystem}, {Role: "user", Content: authorPrompt(j)}}
	if previous.Cards != nil {
		raw, err := json.Marshal(struct {
			Cards []study.Card `json:"cards"`
		}{previous.Cards})
		if err != nil {
			return study.Deck{}, fmt.Errorf("encode previous lesson: %w", err)
		}
		messages = append(messages, sarvam.Message{Role: "assistant", Content: string(raw)}, sarvam.Message{Role: "user", Content: revisePrompt(issues)})
	}
	var last error
	for range authorAttempts {
		reply, err := g.ask(ctx, g.Author, messages, authorHeat)
		if err != nil {
			return study.Deck{}, err
		}
		d, err := parseDeck(j, reply)
		if err == nil {
			return d, nil
		}
		last = err
		g.Logger.Warn("lesson reply rejected", "id", j.ID(), "error", err)
		messages = append(messages, sarvam.Message{Role: "assistant", Content: reply}, sarvam.Message{Role: "user", Content: invalidPrompt(err)})
	}
	return study.Deck{}, fmt.Errorf("no valid lesson after %d replies: %w", authorAttempts, last)
}

func (g *Generator) review(ctx context.Context, j Job, d study.Deck) (verdict, error) {
	messages := []sarvam.Message{{Role: "system", Content: reviewerSystem}, {Role: "user", Content: reviewPrompt(j, d.Cards)}}
	var last error
	for range reviewAttempts {
		reply, err := g.ask(ctx, g.Reviewer, messages, reviewerHeat)
		if err != nil {
			return verdict{}, err
		}
		v, err := parseVerdict(reply)
		if err == nil {
			return v, nil
		}
		last = err
	}
	return verdict{}, fmt.Errorf("no usable review after %d replies: %w", reviewAttempts, last)
}

func (g *Generator) ask(ctx context.Context, chat Chatter, messages []sarvam.Message, temperature float64) (string, error) {
	for attempt := 0; ; attempt++ {
		callCtx, cancel := context.WithTimeout(ctx, g.Timeout)
		reply, err := chat.Chat(callCtx, messages, temperature)
		cancel()
		if err == nil {
			return reply, nil
		}
		if ctx.Err() != nil {
			return "", ctx.Err()
		}
		if se, ok := errors.AsType[*sarvam.StatusError](err); ok && se.Code != http.StatusTooManyRequests && se.Code < 500 {
			return "", err
		}
		if attempt >= g.Retries {
			return "", fmt.Errorf("sarvam gave up after %d tries: %w", attempt+1, err)
		}
		wait := min(g.Backoff<<attempt, 5*time.Minute)
		wait += rand.N(wait/2 + 1) //nolint:gosec
		g.Logger.Warn("sarvam retry", "attempt", attempt+1, "wait", wait.String(), "error", err)
		select {
		case <-ctx.Done():
			return "", ctx.Err()
		case <-time.After(wait):
		}
	}
}

func (g *Generator) save(j Job, d study.Deck, status string, r *Review) error {
	d.Status = status
	d.GeneratedBy = &study.GeneratedBy{Model: g.Model, PromptVersion: PromptVersion, CheckedAt: time.Now().UTC().Truncate(time.Second)}
	path := j.Path(g.Out)
	reviewPath := strings.TrimSuffix(path, ".json") + study.ReviewSuffix
	if r == nil {
		if err := os.Remove(reviewPath); err != nil && !errors.Is(err, os.ErrNotExist) {
			return fmt.Errorf("remove old review: %w", err)
		}
	} else if err := writeJSON(reviewPath, r); err != nil {
		return err
	}
	return writeJSON(path, d)
}

func writeJSON(path string, v any) error {
	raw, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		return fmt.Errorf("encode %s: %w", path, err)
	}
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		return fmt.Errorf("create %s: %w", filepath.Dir(path), err)
	}
	tmp, err := os.CreateTemp(filepath.Dir(path), ".tmp-*")
	if err != nil {
		return fmt.Errorf("write %s: %w", path, err)
	}
	defer os.Remove(tmp.Name()) //nolint:errcheck
	if _, err := tmp.Write(append(raw, '\n')); err != nil {
		_ = tmp.Close()
		return fmt.Errorf("write %s: %w", path, err)
	}
	if err := tmp.Close(); err != nil {
		return fmt.Errorf("write %s: %w", path, err)
	}
	if err := os.Chmod(tmp.Name(), 0o644); err != nil { //nolint:gosec
		return fmt.Errorf("write %s: %w", path, err)
	}
	if err := os.Rename(tmp.Name(), path); err != nil {
		return fmt.Errorf("write %s: %w", path, err)
	}
	return nil
}
