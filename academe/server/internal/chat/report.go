package chat

import (
	"context"
	"errors"
	"net/http"
	"strconv"
	"strings"
	"unicode/utf8"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Reason string

const (
	Wrong     Reason = "wrong"
	Harmful   Reason = "harmful"
	Offensive Reason = "offensive"
	Other     Reason = "other"
)

const maxReportNoteRunes = 500

var ErrBadReport = errors.New("reason must be wrong, harmful, offensive or other, with a note of at most 500 characters")

type Report struct {
	Reason Reason `json:"reason"`
	Note   string `json:"note"`
}

func (s *Service) Report(ctx context.Context, accountID string, messageID int64, in Report) error {
	in.Note = strings.TrimSpace(in.Note)
	switch in.Reason {
	case Wrong, Harmful, Offensive, Other:
	default:
		return ErrBadReport
	}
	if utf8.RuneCountInString(in.Note) > maxReportNoteRunes {
		return ErrBadReport
	}
	return s.store.Report(ctx, accountID, messageID, in)
}

func (h handler) report(w http.ResponseWriter, r *http.Request) error {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		return toHTTP(ErrNotFound)
	}
	var in Report
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	if err := h.service.Report(r.Context(), auth.AccountID(r.Context()), id, in); err != nil {
		if errors.Is(err, ErrBadReport) {
			return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_report", Message: err.Error()}
		}
		return toHTTP(err)
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}
