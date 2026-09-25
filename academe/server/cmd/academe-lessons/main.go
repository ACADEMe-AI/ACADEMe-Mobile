package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"academe/server/internal/lessons"
	"academe/server/internal/sarvam"
	"academe/server/internal/syllabus"
)

func main() {
	logger := slog.New(slog.NewTextHandler(os.Stderr, nil))
	if err := run(context.Background(), logger, os.Args[1:]); err != nil {
		logger.Error("academe-lessons stopped", "error", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, logger *slog.Logger, args []string) error {
	ctx, stop := signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)
	defer stop()

	flags := flag.NewFlagSet("academe-lessons", flag.ContinueOnError)
	var f lessons.Filter
	flags.StringVar(&f.Board, "board", "", "only this board: cbse or icse")
	flags.IntVar(&f.Class, "class", 0, "only this class, 6 to 12")
	flags.StringVar(&f.Subject, "subject", "", "only this subject id, e.g. science")
	flags.IntVar(&f.Chapter, "chapter", 0, "only this chapter number")
	flags.IntVar(&f.Lesson, "lesson", 0, "only this lesson position in the chapter")
	workers := flags.Int("workers", 4, "lessons generated at the same time")
	force := flags.Bool("force", false, "regenerate lessons that are already approved")
	dryRun := flags.Bool("dry-run", false, "list the lessons that would be generated and stop")
	out := flags.String("out", "internal/study/decks", "deck folder; lessons go in <out>/<board>-<class>/<id>.json")
	review := flags.Bool("review", false, "write the teacher review report instead of generating")
	report := flags.String("html", "content-review/index.html", "where -review writes the report")
	source := flags.String("syllabus", "", "read the syllabus from this folder instead of the embedded data")
	model := flags.String("model", "sarvam-105b", "Sarvam chat model")
	maxTokens := flags.Int("max-tokens", 24000, "Sarvam completion budget for a reasoning call; calls without reasoning get at most 8000")
	authorReasoning := flags.String("author-reasoning", "none", "Sarvam reasoning effort when writing: none, low, medium, high")
	reviewReasoning := flags.String("review-reasoning", "medium", "Sarvam reasoning effort when reviewing: none, low, medium, high")
	timeout := flags.Duration("timeout", 180*time.Second, "limit for one Sarvam request")
	if err := flags.Parse(args); err != nil {
		return err
	}

	if *review {
		n, err := lessons.WriteReport(*out, *report)
		if err != nil {
			return err
		}
		logger.Info("review report written", "path", *report, "decks", n)
		return nil
	}

	syllabi, err := syllabus.Load()
	if *source != "" {
		syllabi, err = syllabus.Read(os.DirFS(*source))
	}
	if err != nil {
		return fmt.Errorf("load syllabus: %w", err)
	}
	jobs := lessons.Jobs(syllabi, f)
	key := os.Getenv("ACADEME_SARVAM_API_KEY")
	if key == "" && !*dryRun {
		return errors.New("set ACADEME_SARVAM_API_KEY")
	}
	client := func(reasoning string) *sarvam.Client {
		c := sarvam.New(key, *model, &http.Client{})
		c.MaxTokens, c.Reasoning = min(*maxTokens, 8000), json.RawMessage(`null`)
		if reasoning != "none" {
			c.MaxTokens = *maxTokens
			c.Reasoning, _ = json.Marshal(reasoning)
		}
		return c
	}
	g := &lessons.Generator{
		Author: client(*authorReasoning), Reviewer: client(*reviewReasoning), Model: *model, Out: *out, Force: *force,
		Timeout: *timeout, Backoff: 5 * time.Second, Retries: 6, Logger: logger,
	}
	if *dryRun {
		pending, skipped, err := g.Pending(jobs)
		if err != nil {
			return err
		}
		for _, j := range pending {
			fmt.Printf("%s\t%s\n", j.ID(), j.Lesson().Title) //nolint:forbidigo
		}
		logger.Info("dry run", "planned", len(jobs), "toGenerate", len(pending), "alreadyApproved", skipped)
		return nil
	}
	logger.Info("generating", "planned", len(jobs), "workers", *workers, "promptVersion", lessons.PromptVersion)
	sum, err := g.Run(ctx, jobs, *workers)
	perLesson := 0.0
	if made := sum.Approved + sum.Draft + sum.Failed; made > 0 {
		perLesson = sum.Busy.Seconds() / float64(made)
	}
	logger.Info("summary", "approved", sum.Approved, "draft", sum.Draft, "failed", sum.Failed, "skipped", sum.Skipped,
		"elapsed", sum.Elapsed.Round(time.Second).String(), "secondsPerLesson", int(perLesson),
		"lessonsPerHour", int(float64(sum.Approved+sum.Draft)/max(sum.Elapsed.Hours(), 1e-9)))
	if err != nil {
		return err
	}
	if sum.Failed > 0 {
		return fmt.Errorf("%d lessons failed; run again to retry them", sum.Failed)
	}
	return nil
}
