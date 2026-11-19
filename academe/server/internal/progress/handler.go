package progress

import (
	"errors"
	"log/slog"
	"net/http"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	mux.Handle("GET /me/progress", httpx.Handle(logger, requireAccount(handler{s: s}.get)))
}

type handler struct {
	s *Service
}

func (h handler) get(w http.ResponseWriter, r *http.Request) error {
	summary, err := h.s.Summary(r.Context(), auth.AccountID(r.Context()))
	if errors.Is(err, ErrProRequired) {
		return &httpx.Error{Status: http.StatusForbidden, Code: "pro_required", Message: err.Error()}
	}
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, summary)
	return nil
}
