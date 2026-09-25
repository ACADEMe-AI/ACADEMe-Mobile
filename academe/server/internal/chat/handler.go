package chat

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"academe/server/internal/auth"
	"academe/server/internal/billing"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	h := handler{s}
	mux.Handle("GET /chat/threads", httpx.Handle(logger, requireAccount(h.threads)))
	mux.Handle("GET /chat/threads/{id}/messages", httpx.Handle(logger, requireAccount(h.messages)))
	mux.Handle("POST /chat/messages", httpx.Handle(logger, requireAccount(h.send)))
	mux.Handle("POST /chat/threads/{id}/retry", httpx.Handle(logger, requireAccount(h.retry)))
	mux.Handle("PUT /chat/messages/{id}/rating", httpx.Handle(logger, requireAccount(h.rate)))
	mux.Handle("POST /chat/messages/{id}/report", httpx.Handle(logger, requireAccount(h.report)))
}

type handler struct {
	service *Service
}

type threadList struct {
	Threads []Thread `json:"threads"`
}

type messageList struct {
	Messages []Message `json:"messages"`
}

type retryInput struct {
	Mode Mode `json:"mode"`
}

type ratingInput struct {
	Rating int `json:"rating"`
}

func (h handler) threads(w http.ResponseWriter, r *http.Request) error {
	threads, err := h.service.Threads(r.Context(), auth.AccountID(r.Context()))
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, threadList{nonNil(threads)})
	return nil
}

func (h handler) messages(w http.ResponseWriter, r *http.Request) error {
	messages, err := h.service.Messages(r.Context(), auth.AccountID(r.Context()), r.PathValue("id"))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, messageList{nonNil(messages)})
	return nil
}

func (h handler) send(w http.ResponseWriter, r *http.Request) error {
	var in Send
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	exchange, err := h.service.Send(r.Context(), auth.AccountID(r.Context()), in)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, exchange)
	return nil
}

func (h handler) retry(w http.ResponseWriter, r *http.Request) error {
	var in retryInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	reply, err := h.service.Retry(r.Context(), auth.AccountID(r.Context()), r.PathValue("id"), in.Mode)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, reply)
	return nil
}

func (h handler) rate(w http.ResponseWriter, r *http.Request) error {
	id, err := strconv.ParseInt(r.PathValue("id"), 10, 64)
	if err != nil {
		return toHTTP(ErrNotFound)
	}
	var in ratingInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	if err := h.service.Rate(r.Context(), auth.AccountID(r.Context()), id, in.Rating); err != nil {
		return toHTTP(err)
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

func toHTTP(err error) error {
	switch {
	case errors.Is(err, ErrNotFound):
		return &httpx.Error{Status: http.StatusNotFound, Code: "not_found", Message: "That chat doesn't exist."}
	case errors.Is(err, ErrUnavailable):
		return &httpx.Error{Status: http.StatusServiceUnavailable, Code: "askme_unavailable", Message: "ASKMe isn't ready yet."}
	case errors.Is(err, ErrEmpty):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_text", Message: "Type a question first."}
	case errors.Is(err, ErrTooLong):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_text", Message: "That question is too long."}
	case errors.Is(err, ErrBadMode):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_mode", Message: err.Error()}
	case errors.Is(err, ErrBadRating):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_rating", Message: err.Error()}
	case errors.Is(err, ErrNothingToRetry):
		return &httpx.Error{Status: http.StatusConflict, Code: "nothing_to_retry", Message: "There's no answer to retry."}
	}
	return billing.HTTPError(err)
}

func nonNil[T any](items []T) []T {
	if items == nil {
		return []T{}
	}
	return items
}
