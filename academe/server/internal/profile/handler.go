package profile

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	h := handler{s}
	mux.Handle("GET /me/profile", httpx.Handle(logger, requireAccount(h.get)))
	mux.Handle("PATCH /me/profile", httpx.Handle(logger, requireAccount(h.update)))
	mux.Handle("GET /catalog/subjects", httpx.Handle(logger, subjects))
}

type handler struct {
	service *Service
}

func (h handler) get(w http.ResponseWriter, r *http.Request) error {
	p, err := h.service.Profile(r.Context(), auth.AccountID(r.Context()))
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, p)
	return nil
}

func (h handler) update(w http.ResponseWriter, r *http.Request) error {
	var in Update
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	p, err := h.service.Update(r.Context(), auth.AccountID(r.Context()), in)
	if v, ok := errors.AsType[*ValidationError](err); ok {
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_" + v.Field, Message: v.Error()}
	}
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, p)
	return nil
}

type subjectList struct {
	Subjects []Subject `json:"subjects"`
}

func subjects(w http.ResponseWriter, r *http.Request) error {
	class, err := strconv.Atoi(r.URL.Query().Get("class"))
	list, ok := Subjects(class, r.URL.Query().Get("board"))
	if err != nil || !ok {
		return &httpx.Error{Status: http.StatusBadRequest, Code: "invalid_query", Message: "class must be 6 to 12 and board CBSE or ICSE."}
	}
	httpx.WriteJSON(w, http.StatusOK, subjectList{list})
	return nil
}
