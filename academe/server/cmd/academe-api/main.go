package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"syscall"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/billing"
	"academe/server/internal/chat"
	"academe/server/internal/config"
	"academe/server/internal/email"
	"academe/server/internal/folder"
	"academe/server/internal/httpx"
	"academe/server/internal/postgres"
	"academe/server/internal/profile"
	"academe/server/internal/sarvam"
	"academe/server/internal/scan"
	"academe/server/internal/site"
	"academe/server/internal/study"
	"academe/server/internal/syllabus"
)

func main() {
	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	if err := run(context.Background(), logger); err != nil {
		logger.Error("server stopped", "error", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, logger *slog.Logger) error {
	ctx, stop := signal.NotifyContext(ctx, os.Interrupt, syscall.SIGTERM)
	defer stop()

	cfg, err := config.FromEnv()
	if err != nil {
		return err
	}
	pool, err := postgres.Open(ctx, cfg.DatabaseURL)
	if err != nil {
		return err
	}
	defer pool.Close()
	if err := postgres.Migrate(ctx, pool); err != nil {
		return err
	}

	mux := http.NewServeMux()
	mux.Handle("GET /healthz", httpx.Handle(logger, func(w http.ResponseWriter, r *http.Request) error {
		if err := pool.Ping(r.Context()); err != nil {
			return err
		}
		httpx.WriteJSON(w, http.StatusOK, map[string]string{"status": "ok"})
		return nil
	}))
	var google auth.GoogleVerifier
	if len(cfg.GoogleClientIDs) > 0 {
		google = auth.NewGoogleIDTokens(cfg.GoogleClientIDs, auth.GoogleCertsURL, &http.Client{Timeout: 5 * time.Second})
	} else {
		logger.Warn("google sign-in disabled", "reason", "ACADEME_GOOGLE_CLIENT_IDS is not set")
	}
	var mailer auth.Mailer = email.Log{Logger: logger, ShowCode: cfg.EmailDev}
	if cfg.ResendAPIKey != "" {
		mailer = email.NewResend(cfg.ResendAPIKey, cfg.EmailFrom, &http.Client{Timeout: 10 * time.Second})
	} else {
		logger.Warn("reset emails are only logged", "reason", "ACADEME_RESEND_API_KEY is not set")
	}
	authService := auth.NewService(auth.NewPostgresStore(pool), cfg.TokenKey, google, mailer)
	authService.SetLogger(logger)
	defer authService.Wait()
	auth.RegisterRoutes(mux, logger, authService)
	profiles := profile.NewService(profile.NewPostgresStore(pool))
	profile.RegisterRoutes(mux, logger, profiles, authService.RequireAccount)
	var tutor chat.Tutor
	var reader scan.Reader
	var model scan.Model
	if cfg.SarvamAPIKey != "" {
		client := sarvam.New(cfg.SarvamAPIKey, cfg.SarvamModel, &http.Client{Timeout: 60 * time.Second})
		client.Reasoning = json.RawMessage(`null`)
		tutor, reader, model = chat.NewSarvam(client), client, client
	} else {
		logger.Warn("askme and scan disabled", "reason", "ACADEME_SARVAM_API_KEY is not set")
	}
	var revenueCat *billing.RevenueCat
	if cfg.RevenueCatSecretKey != "" {
		revenueCat = billing.NewRevenueCat(cfg.RevenueCatSecretKey, billing.RevenueCatAPI, &http.Client{Timeout: 15 * time.Second})
		authService.SetSubscriberDeleter(revenueCat)
	} else {
		logger.Warn("purchase sync disabled", "reason", "ACADEME_REVENUECAT_SECRET_KEY is not set")
	}
	plans := billing.NewService(billing.NewPostgresStore(pool), cfg.FreeLimits, revenueCat)
	plans.SetTesters(cfg.BillingTesters)
	plans.SetEntitlement(cfg.RevenueCatEntitlement)
	billing.RegisterRoutes(mux, logger, plans, authService.RequireAccount, cfg.RevenueCatWebhookAuth)
	chats := chat.NewService(chat.NewPostgresStore(pool), tutor, profiles, authService)
	chats.SetLimiter(plans)
	chat.RegisterRoutes(mux, logger, chats, authService.RequireAccount)
	decks, err := study.Library()
	if err != nil {
		return fmt.Errorf("load decks: %w", err)
	}
	syllabi, err := syllabus.Load()
	if err != nil {
		return fmt.Errorf("load syllabus: %w", err)
	}
	studyService := study.NewService(study.NewPostgresStore(pool), profiles, decks, syllabus.Plan(syllabi))
	study.RegisterRoutes(mux, logger, studyService, authService.RequireAccount)
	folders := folder.NewService(folder.NewPostgresStore(pool), studyService)
	folder.RegisterRoutes(mux, logger, folders, authService.RequireAccount)
	scans := scan.NewService(scan.NewPostgresStore(pool), reader, model, profiles, studyService, folders)
	scans.SetLimiter(plans)
	scan.RegisterRoutes(mux, logger, scans, authService.RequireAccount)
	notices, _ := mailer.(site.Mailer)
	if err := site.RegisterRoutes(mux, logger, site.Options{
		Store: site.NewPostgresStore(pool), Mailer: notices, Resets: authService,
		FormKey: cfg.TokenKey, AndroidCerts: cfg.AndroidCerts,
	}); err != nil {
		return fmt.Errorf("load site: %w", err)
	}

	srv := &http.Server{
		Handler:           httpx.TrustClientIP(cfg.ClientIPHeader, httpx.WithRequestID(httpx.Recover(logger, httpx.LogRequests(logger, mux)))),
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       10 * time.Second,
		WriteTimeout:      60 * time.Second,
		IdleTimeout:       60 * time.Second,
		ErrorLog:          slog.NewLogLogger(logger.Handler(), slog.LevelWarn),
	}

	ln, err := new(net.ListenConfig).Listen(ctx, "tcp", cfg.Addr)
	if err != nil {
		return err
	}
	var background sync.WaitGroup
	defer background.Wait()
	background.Go(func() { authService.PurgeEvery(ctx, logger, time.Hour) })

	serveErr := make(chan error, 1)
	go func() { serveErr <- srv.Serve(ln) }()
	logger.Info("listening", "addr", ln.Addr().String())

	select {
	case err := <-serveErr:
		return err
	case <-ctx.Done():
	}
	logger.Info("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		return err
	}
	if err := <-serveErr; !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}
