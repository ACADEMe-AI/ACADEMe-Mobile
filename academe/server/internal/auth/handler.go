package auth

import (
	"errors"
	"log/slog"
	"net/http"
	"net/netip"
	"time"

	"academe/server/internal/httpx"
)

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service) {
	h := handler{s}
	mux.Handle("POST /auth/sign-up", httpx.Handle(logger, h.signUp))
	mux.Handle("POST /auth/log-in", httpx.Handle(logger, h.logIn))
	mux.Handle("POST /auth/refresh", httpx.Handle(logger, h.refresh))
	mux.Handle("POST /auth/log-out", httpx.Handle(logger, h.logOut))
	mux.Handle("POST /auth/google", httpx.Handle(logger, h.google))
	mux.Handle("POST /auth/password-reset", httpx.Handle(logger, h.requestReset))
	mux.Handle("POST /auth/password-reset/verify", httpx.Handle(logger, h.verifyReset))
	mux.Handle("POST /auth/password-reset/complete", httpx.Handle(logger, h.completeReset))
	mux.Handle("POST /auth/password-reset/link", httpx.Handle(logger, h.redeemResetLink))
	mux.Handle("GET /me", httpx.Handle(logger, s.RequireAccount(h.me)))
	mux.Handle("PATCH /me", httpx.Handle(logger, s.RequireAccount(h.updateMe)))
	mux.Handle("DELETE /me", httpx.Handle(logger, s.RequireAccount(h.deleteMe)))
	mux.Handle("POST /me/password", httpx.Handle(logger, s.RequireAccount(h.changePassword)))
	mux.Handle("POST /me/google", httpx.Handle(logger, s.RequireAccount(h.linkGoogle)))
	mux.Handle("DELETE /me/google", httpx.Handle(logger, s.RequireAccount(h.unlinkGoogle)))
}

type handler struct {
	service *Service
}

type session struct {
	Account Account `json:"account"`
	Tokens  Tokens  `json:"tokens"`
}

type googleSession struct {
	Account Account `json:"account"`
	Tokens  Tokens  `json:"tokens"`
	Created bool    `json:"created"`
}

type googleRequest struct {
	IDToken string `json:"idToken"`
}

type nameRequest struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
}

type logInRequest struct {
	Email    string `json:"email"`
	Password string `json:"password"`
}

type refreshRequest struct {
	RefreshToken string `json:"refreshToken"`
}

func (h handler) signUp(w http.ResponseWriter, r *http.Request) error {
	var in SignUpInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, tokens, err := h.service.SignUp(r.Context(), in)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusCreated, session{a, tokens})
	return nil
}

func (h handler) logIn(w http.ResponseWriter, r *http.Request) error {
	var in logInRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, tokens, err := h.service.LogIn(r.Context(), in.Email, in.Password)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, session{a, tokens})
	return nil
}

func (h handler) refresh(w http.ResponseWriter, r *http.Request) error {
	var in refreshRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	tokens, err := h.service.Refresh(r.Context(), in.RefreshToken)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, tokens)
	return nil
}

func (h handler) logOut(w http.ResponseWriter, r *http.Request) error {
	var in refreshRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	if err := h.service.LogOut(r.Context(), in.RefreshToken); err != nil {
		return err
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

func (h handler) google(w http.ResponseWriter, r *http.Request) error {
	var in googleRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, tokens, created, err := h.service.SignInWithGoogle(r.Context(), in.IDToken)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, googleSession{a, tokens, created})
	return nil
}

func (h handler) me(w http.ResponseWriter, r *http.Request) error {
	a, err := h.service.Account(r.Context(), AccountID(r.Context()))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, a)
	return nil
}

func (h handler) updateMe(w http.ResponseWriter, r *http.Request) error {
	var in nameRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, err := h.service.UpdateName(r.Context(), AccountID(r.Context()), in.FirstName, in.LastName)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, a)
	return nil
}

type deleteRequest struct {
	Reason string `json:"reason"`
}

type deleteResponse struct {
	DeletesAt time.Time `json:"deletesAt"`
}

func (h handler) deleteMe(w http.ResponseWriter, r *http.Request) error {
	var in deleteRequest
	if r.ContentLength != 0 {
		if err := httpx.DecodeJSON(w, r, &in); err != nil {
			return err
		}
	}
	at, err := h.service.DeleteAccount(r.Context(), AccountID(r.Context()), in.Reason)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusAccepted, deleteResponse{at})
	return nil
}

func toHTTP(err error) error {
	if v, ok := errors.AsType[*ValidationError](err); ok {
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "invalid_" + v.Field, Message: v.Error()}
	}
	switch {
	case errors.Is(err, ErrEmailTaken):
		return &httpx.Error{Status: http.StatusConflict, Code: "email_taken",
			Message: "An account already uses this email."}
	case errors.Is(err, ErrWrongCredentials):
		return &httpx.Error{Status: http.StatusUnauthorized, Code: "wrong_credentials",
			Message: "Wrong email or password."}
	case errors.Is(err, ErrInvalidToken), errors.Is(err, ErrNotFound):
		return &httpx.Error{Status: http.StatusUnauthorized, Code: "invalid_token",
			Message: "Log in again."}
	case errors.Is(err, ErrGoogleToken):
		return &httpx.Error{Status: http.StatusUnauthorized, Code: "invalid_google_token",
			Message: "Google sign-in didn't go through. Try again."}
	case errors.Is(err, ErrGoogleUnavailable):
		return &httpx.Error{Status: http.StatusServiceUnavailable, Code: "google_unavailable",
			Message: "Google sign-in isn't available yet."}
	case errors.Is(err, ErrThrottled):
		return &httpx.Error{Status: http.StatusTooManyRequests, Code: "too_many_requests",
			Message: "Too many tries. Wait a while and try again."}
	case errors.Is(err, ErrWrongPassword):
		return &httpx.Error{Status: http.StatusForbidden, Code: "wrong_password",
			Message: "That isn't your current password."}
	case errors.Is(err, ErrGoogleTaken):
		return &httpx.Error{Status: http.StatusConflict, Code: "google_taken",
			Message: "This Google account is linked to another account."}
	case errors.Is(err, ErrPasswordRequired):
		return &httpx.Error{Status: http.StatusConflict, Code: "password_required",
			Message: "Set a password before unlinking Google."}
	case errors.Is(err, ErrWrongCode):
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: "wrong_code",
			Message: "That code isn't right."}
	case errors.Is(err, ErrTooManyAttempts):
		return &httpx.Error{Status: http.StatusTooManyRequests, Code: "too_many_attempts",
			Message: "Too many wrong codes. Ask for a new one."}
	case errors.Is(err, ErrCodeExpired):
		return &httpx.Error{Status: http.StatusGone, Code: "code_expired",
			Message: "This code has expired. Ask for a new one."}
	case errors.Is(err, ErrResetTokenExpired):
		return &httpx.Error{Status: http.StatusGone, Code: "reset_expired",
			Message: "This reset has expired. Start again."}
	}
	return err
}

type resetRequest struct {
	Email string `json:"email"`
}

type resetRequested struct {
	ExpiresIn int `json:"expiresIn"`
}

type verifyRequest struct {
	Email string `json:"email"`
	Code  string `json:"code"`
}

type verified struct {
	ResetToken string `json:"resetToken"`
	ExpiresIn  int    `json:"expiresIn"`
}

type completeRequest struct {
	ResetToken string `json:"resetToken"`
	Password   string `json:"password"`
}

func (h handler) requestReset(w http.ResponseWriter, r *http.Request) error {
	var in resetRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	if err := h.service.RequestPasswordReset(r.Context(), in.Email, clientIP(r)); err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusAccepted, resetRequested{int(resetCodeTTL.Seconds())})
	return nil
}

func (h handler) verifyReset(w http.ResponseWriter, r *http.Request) error {
	var in verifyRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	token, err := h.service.VerifyResetCode(r.Context(), in.Email, in.Code, clientIP(r))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, verified{token, int(resetTokenTTL.Seconds())})
	return nil
}

func (h handler) completeReset(w http.ResponseWriter, r *http.Request) error {
	var in completeRequest
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	a, tokens, err := h.service.CompletePasswordReset(r.Context(), in.ResetToken, in.Password)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, session{a, tokens})
	return nil
}

func clientIP(r *http.Request) string {
	addr, err := netip.ParseAddrPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	ip := addr.Addr().Unmap()
	if ip.Is6() {
		network, _ := ip.Prefix(64)
		return network.String()
	}
	return ip.String()
}
