package httpx

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
)

const maxBodyBytes = 64 << 10

type Error struct {
	Status  int
	Code    string
	Message string
	Details map[string]any
}

func (e *Error) Error() string { return e.Code + ": " + e.Message }

var errInternal = &Error{
	Status:  http.StatusInternalServerError,
	Code:    "internal",
	Message: "Something went wrong on our side.",
}

type HandlerFunc func(http.ResponseWriter, *http.Request) error

func Handle(logger *slog.Logger, h HandlerFunc) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		err := h(w, r)
		if err == nil {
			return
		}
		httpErr, ok := errors.AsType[*Error](err)
		if !ok {
			logger.ErrorContext(r.Context(), "request failed",
				"requestID", RequestID(r.Context()), "error", err)
			httpErr = errInternal
		}
		writeError(w, r, httpErr)
	})
}

type errorEnvelope struct {
	Error errorBody `json:"error"`
}

type errorBody struct {
	Code      string         `json:"code"`
	Message   string         `json:"message"`
	RequestID string         `json:"requestId"`
	Details   map[string]any `json:"details,omitempty"`
}

func writeError(w http.ResponseWriter, r *http.Request, e *Error) {
	WriteJSON(w, e.Status, errorEnvelope{errorBody{
		Code:      e.Code,
		Message:   e.Message,
		RequestID: RequestID(r.Context()),
		Details:   e.Details,
	}})
}

func DecodeJSON(w http.ResponseWriter, r *http.Request, dst any) error {
	dec := json.NewDecoder(http.MaxBytesReader(w, r.Body, maxBodyBytes))
	dec.DisallowUnknownFields()
	if err := dec.Decode(dst); err != nil {
		if _, ok := errors.AsType[*http.MaxBytesError](err); ok {
			return &Error{Status: http.StatusRequestEntityTooLarge, Code: "body_too_large",
				Message: "The request body is too large."}
		}
		return &Error{Status: http.StatusBadRequest, Code: "invalid_json",
			Message: "The request body isn't valid: " + err.Error()}
	}
	if err := dec.Decode(&struct{}{}); !errors.Is(err, io.EOF) {
		return &Error{Status: http.StatusBadRequest, Code: "invalid_json",
			Message: "The request body must be a single JSON object."}
	}
	return nil
}

func WriteJSON(w http.ResponseWriter, status int, v any) {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(v)
}
