package auth

import (
	"net/http"

	"academe/server/internal/httpx"
)

type passwordRequest struct {
	CurrentPassword string `json:"currentPassword"`
	NewPassword     string `json:"newPassword"`
}

func (h handler) changePassword(w http.ResponseWriter, r *http.Request) error {
	var in passwordRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, tokens, err := h.service.ChangePassword(r.Context(), AccountID(r.Context()), in.CurrentPassword, in.NewPassword)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, session{a, tokens})
	return nil
}

func (h handler) linkGoogle(w http.ResponseWriter, r *http.Request) error {
	var in googleRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, err := h.service.LinkGoogle(r.Context(), AccountID(r.Context()), in.IDToken)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, a)
	return nil
}

func (h handler) unlinkGoogle(w http.ResponseWriter, r *http.Request) error {
	a, err := h.service.UnlinkGoogle(r.Context(), AccountID(r.Context()))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, a)
	return nil
}
