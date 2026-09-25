package scan

import (
	"errors"
	"io"
	"log/slog"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/billing"
	"academe/server/internal/folder"
	"academe/server/internal/httpx"
	"academe/server/internal/sarvam"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

const (
	maxPageBytes   = 8 << 20
	maxUploadBytes = 40 << 20
)

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	h := handler{s}
	route := func(pattern string, f httpx.HandlerFunc) {
		mux.Handle(pattern, httpx.Handle(logger, requireAccount(f)))
	}
	route("POST /scans", h.create)
	route("GET /scans", h.list)
	route("GET /scans/{id}", h.detail)
	route("PUT /scans/{id}/thread", h.thread)
	route("POST /scans/{id}/check", h.check)
	route("POST /scans/{id}/notes", h.notes)
}

type handler struct {
	service *Service
}

type scanList struct {
	Scans []Scan `json:"scans"`
}

type threadInput struct {
	ThreadID string `json:"threadId"`
}

type checkInput struct {
	Question string `json:"question"`
}

type notesInput struct {
	FolderID   string `json:"folderId"`
	MakeLesson bool   `json:"makeLesson"`
}

type notesResult struct {
	DeckID *string `json:"deckId"`
}

func account(r *http.Request) string { return auth.AccountID(r.Context()) }

func slow(w http.ResponseWriter) {
	rc := http.NewResponseController(w)
	_ = rc.SetReadDeadline(time.Now().Add(2 * time.Minute))
	_ = rc.SetWriteDeadline(time.Now().Add(3 * time.Minute))
}

var pageTypes = map[string]string{".jpg": ".jpg", ".jpeg": ".jpg", ".png": ".png", ".pdf": ".pdf"}

func pages(w http.ResponseWriter, r *http.Request) (Mode, []sarvam.Page, error) {
	r.Body = http.MaxBytesReader(w, r.Body, maxUploadBytes)
	if err := r.ParseMultipartForm(maxPageBytes); err != nil {
		if _, ok := errors.AsType[*http.MaxBytesError](err); ok {
			return "", nil, &httpx.Error{Status: http.StatusRequestEntityTooLarge, Code: "too_large", Message: "Those photos are too big."}
		}
		return "", nil, ErrBadPages
	}
	var out []sarvam.Page
	for _, fh := range r.MultipartForm.File["page"] {
		ext, ok := pageTypes[strings.ToLower(filepath.Ext(fh.Filename))]
		if !ok || fh.Size > maxPageBytes || len(out) == MaxPages {
			return "", nil, ErrBadPages
		}
		f, err := fh.Open()
		if err != nil {
			return "", nil, err
		}
		data, err := io.ReadAll(f)
		_ = f.Close()
		if err != nil {
			return "", nil, err
		}
		out = append(out, sarvam.Page{Name: "page" + ext, Data: data})
	}
	return Mode(r.FormValue("mode")), out, nil
}

func (h handler) create(w http.ResponseWriter, r *http.Request) error {
	slow(w)
	mode, pp, err := pages(w, r)
	if err != nil {
		return toHTTP(err)
	}
	sc, err := h.service.Read(r.Context(), account(r), mode, pp)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusCreated, sc)
	return nil
}

func (h handler) list(w http.ResponseWriter, r *http.Request) error {
	scans, err := h.service.Scans(r.Context(), account(r))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, scanList{scans})
	return nil
}

func (h handler) detail(w http.ResponseWriter, r *http.Request) error {
	sc, err := h.service.Scan(r.Context(), account(r), r.PathValue("id"))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, sc)
	return nil
}

func (h handler) thread(w http.ResponseWriter, r *http.Request) error {
	var in threadInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	if err := h.service.LinkThread(r.Context(), account(r), r.PathValue("id"), in.ThreadID); err != nil {
		return toHTTP(err)
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

func (h handler) check(w http.ResponseWriter, r *http.Request) error {
	slow(w)
	var in checkInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	m, err := h.service.Check(r.Context(), account(r), r.PathValue("id"), in.Question)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, m)
	return nil
}

func (h handler) notes(w http.ResponseWriter, r *http.Request) error {
	slow(w)
	var in notesInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	deckID, err := h.service.SaveNotes(r.Context(), account(r), r.PathValue("id"), in.FolderID, in.MakeLesson)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, notesResult{deckID})
	return nil
}

func toHTTP(err error) error {
	unprocessable := func(code string) error {
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: code, Message: err.Error()}
	}
	switch {
	case errors.Is(err, ErrNotFound):
		return &httpx.Error{Status: http.StatusNotFound, Code: "scan_not_found", Message: "That scan doesn't exist."}
	case errors.Is(err, folder.ErrNotFound):
		return &httpx.Error{Status: http.StatusNotFound, Code: "folder_not_found", Message: "That folder doesn't exist."}
	case errors.Is(err, ErrUnavailable):
		return &httpx.Error{Status: http.StatusServiceUnavailable, Code: "scan_unavailable", Message: "Scanning isn't set up yet."}
	case errors.Is(err, ErrFailed):
		return &httpx.Error{Status: http.StatusBadGateway, Code: "scan_failed", Message: "Pebby couldn't read that. Try again."}
	case errors.Is(err, ErrBadMode):
		return unprocessable("invalid_mode")
	case errors.Is(err, ErrBadPages):
		return unprocessable("invalid_pages")
	case errors.Is(err, ErrNoText):
		return unprocessable("no_text")
	case errors.Is(err, ErrWrongMode):
		return unprocessable("wrong_mode")
	case errors.Is(err, ErrBadThread):
		return unprocessable("invalid_thread")
	}
	return billing.HTTPError(err)
}
