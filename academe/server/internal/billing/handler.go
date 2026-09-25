package billing

import (
	"cmp"
	"crypto/subtle"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"sync"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard, webhookAuth string) {
	h := handler{service: s, webhookAuth: webhookAuth, syncs: &limiter{max: syncsPerMinute, window: time.Minute, hits: map[string][]time.Time{}}}
	mux.Handle("GET /me/plan", httpx.Handle(logger, requireAccount(h.plan)))
	mux.Handle("POST /billing/sync", httpx.Handle(logger, requireAccount(h.sync)))
	mux.Handle("POST /billing/revenuecat/webhook", httpx.Handle(logger, h.webhook))
}

const syncsPerMinute = 10

type handler struct {
	service     *Service
	webhookAuth string
	syncs       *limiter
}

type limiter struct {
	mu     sync.Mutex
	max    int
	window time.Duration
	hits   map[string][]time.Time
}

func (l *limiter) allow(key string) bool {
	now := time.Now()
	cutoff := now.Add(-l.window)
	l.mu.Lock()
	defer l.mu.Unlock()
	if len(l.hits) > 10_000 {
		for k, times := range l.hits {
			if !times[len(times)-1].After(cutoff) {
				delete(l.hits, k)
			}
		}
	}
	recent := l.hits[key]
	for len(recent) > 0 && !recent[0].After(cutoff) {
		recent = recent[1:]
	}
	if len(recent) >= l.max {
		l.hits[key] = recent
		return false
	}
	l.hits[key] = append(recent, now)
	return true
}

func (h handler) plan(w http.ResponseWriter, r *http.Request) error {
	p, err := h.service.Plan(r.Context(), auth.AccountID(r.Context()))
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, p)
	return nil
}

func (h handler) sync(w http.ResponseWriter, r *http.Request) error {
	accountID := auth.AccountID(r.Context())
	if !h.syncs.allow(accountID) {
		return &httpx.Error{Status: http.StatusTooManyRequests, Code: "too_many_requests", Message: "Too many tries. Wait a minute and try again."}
	}
	p, err := h.service.Sync(r.Context(), accountID)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, p)
	return nil
}

func (h handler) webhook(w http.ResponseWriter, r *http.Request) error {
	if h.webhookAuth == "" {
		return toHTTP(ErrUnavailable)
	}
	if subtle.ConstantTimeCompare([]byte(r.Header.Get("Authorization")), []byte(h.webhookAuth)) != 1 {
		return &httpx.Error{Status: http.StatusUnauthorized, Code: "invalid_token", Message: "Wrong webhook authorization."}
	}
	body, err := io.ReadAll(http.MaxBytesReader(w, r.Body, 256<<10))
	if err != nil {
		return &httpx.Error{Status: http.StatusRequestEntityTooLarge, Code: "body_too_large", Message: "The request body is too large."}
	}
	if err := h.service.HandleEvent(r.Context(), body); err != nil {
		return toHTTP(err)
	}
	w.WriteHeader(http.StatusOK)
	return nil
}

func toHTTP(err error) error {
	switch {
	case errors.Is(err, ErrUnavailable):
		return &httpx.Error{Status: http.StatusServiceUnavailable, Code: "billing_unavailable", Message: "Purchases aren't set up yet."}
	case errors.Is(err, ErrBadEvent):
		return &httpx.Error{Status: http.StatusBadRequest, Code: "invalid_event", Message: "That isn't a RevenueCat event."}
	case errors.Is(err, ErrStore):
		return &httpx.Error{Status: http.StatusBadGateway, Code: "billing_failed", Message: "RevenueCat didn't answer. Try again."}
	}
	return err
}

var featureNames = map[Feature]string{AskMe: "ASKMe messages", Scan: "scans", Check: "answer checks"}

func HTTPError(err error) error {
	le, ok := errors.AsType[*LimitError](err)
	if !ok {
		return err
	}
	details := map[string]any{"feature": le.Feature, "limit": le.Limit, "resetsAt": le.ResetsAt}
	if le.Limit == 0 {
		return &httpx.Error{Status: http.StatusPaymentRequired, Code: "pro_only", Message: "This is part of ACADEMe Pro.", Details: details}
	}
	return &httpx.Error{Status: http.StatusPaymentRequired, Code: "limit_reached", Message: "You've used today's free " + cmp.Or(featureNames[le.Feature], string(le.Feature)) + ".", Details: details}
}
