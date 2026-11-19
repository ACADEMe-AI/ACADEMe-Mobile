package feedback

import (
	"encoding/json"
	"errors"
	"log/slog"
	"math"
	"net/http"
	"strconv"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	mux.Handle("POST /me/feedback", httpx.Handle(logger, requireAccount(handler{s}.submit)))
}

type handler struct {
	service *Service
}

type submitBody struct {
	Category Category          `json:"category"`
	Message  string            `json:"message"`
	Context  json.RawMessage   `json:"context"`
}

func (h handler) submit(w http.ResponseWriter, r *http.Request) error {
	var in submitBody
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	now := time.Now()
	id, err := h.service.Submit(r.Context(), auth.AccountID(r.Context()), Submission{
		Category: in.Category,
		Message:  in.Message,
		Context:  in.Context,
	})
	switch {
	case errors.Is(err, ErrBadInput):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_feedback", Message: err.Error()}
	case errors.Is(err, ErrDailyLimit), errors.Is(err, ErrWeeklyLimit):
		wait := RetryAfter(now, err)
		if wait > 0 {
			w.Header().Set("Retry-After", strconv.Itoa(int(math.Ceil(wait.Seconds()))))
		}
		scope := "day"
		if errors.Is(err, ErrWeeklyLimit) {
			scope = "week"
		}
		return &httpx.Error{
			Status:  http.StatusTooManyRequests,
			Code:    "too_many_requests",
			Message: err.Error(),
			Details: map[string]any{"scope": scope},
		}
	case err != nil:
		return err
	}
	httpx.WriteJSON(w, http.StatusCreated, map[string]string{"id": id})
	return nil
}
