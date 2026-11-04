package report

import (
	"context"
	"errors"
	"log/slog"
	"net/http"
	"strings"
	"unicode/utf8"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Kind string

const (
	Check  Kind = "check"
	Lesson Kind = "lesson"
)

type Reason string

const (
	Wrong     Reason = "wrong"
	Harmful   Reason = "harmful"
	Offensive Reason = "offensive"
	Other     Reason = "other"
)

const (
	maxNoteRunes = 500
	maxIDBytes   = 100
)

var (
	ErrBadReport = errors.New("kind must be check or lesson and reason wrong, harmful, offensive or other, with a note of at most 500 characters")
	ErrNotFound  = errors.New("nothing to report")
)

type Report struct {
	Kind   Kind   `json:"kind"`
	ID     string `json:"id"`
	Reason Reason `json:"reason"`
	Note   string `json:"note"`
}

type Store interface {
	Save(ctx context.Context, accountID string, report Report) error
}

type Service struct {
	store Store
}

func NewService(store Store) *Service {
	return &Service{store: store}
}

func (s *Service) Report(ctx context.Context, accountID string, in Report) error {
	in.Note = strings.TrimSpace(in.Note)
	switch in.Kind {
	case Check, Lesson:
	default:
		return ErrBadReport
	}
	switch in.Reason {
	case Wrong, Harmful, Offensive, Other:
	default:
		return ErrBadReport
	}
	if in.ID == "" || len(in.ID) > maxIDBytes || utf8.RuneCountInString(in.Note) > maxNoteRunes {
		return ErrBadReport
	}
	return s.store.Save(ctx, accountID, in)
}

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	mux.Handle("POST /reports", httpx.Handle(logger, requireAccount(handler{s}.report)))
}

type handler struct {
	service *Service
}

func (h handler) report(w http.ResponseWriter, r *http.Request) error {
	var in Report
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	err := h.service.Report(r.Context(), auth.AccountID(r.Context()), in)
	switch {
	case errors.Is(err, ErrBadReport):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_report", Message: err.Error()}
	case errors.Is(err, ErrNotFound):
		return &httpx.Error{Status: http.StatusNotFound, Code: "not_found", Message: "That doesn't exist."}
	case err != nil:
		return err
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}
