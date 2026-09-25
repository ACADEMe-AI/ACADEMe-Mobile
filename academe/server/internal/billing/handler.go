package billing

import (
	"crypto/subtle"
	"errors"
	"io"
	"log/slog"
	"net/http"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard, webhookAuth string) {
	h := handler{service: s, webhookAuth: webhookAuth}
	mux.Handle("GET /me/plan", httpx.Handle(logger, requireAccount(h.plan)))
	mux.Handle("POST /billing/sync", httpx.Handle(logger, requireAccount(h.sync)))
	mux.Handle("POST /billing/revenuecat/webhook", httpx.Handle(logger, h.webhook))
}

type handler struct {
	service     *Service
	webhookAuth string
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
	p, err := h.service.Sync(r.Context(), auth.AccountID(r.Context()))
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

func HTTPError(err error) error {
	le, ok := errors.AsType[*LimitError](err)
	if !ok {
		return err
	}
	details := map[string]any{"feature": le.Feature, "limit": le.Limit, "resetsAt": le.ResetsAt}
	if le.Limit == 0 {
		return &httpx.Error{Status: http.StatusPaymentRequired, Code: "pro_only", Message: "This is part of ACADEMe Pro.", Details: details}
	}
	return &httpx.Error{Status: http.StatusPaymentRequired, Code: "limit_reached", Message: "You've used today's free " + string(le.Feature) + ".", Details: details}
}
