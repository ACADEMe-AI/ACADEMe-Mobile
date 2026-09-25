package site

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"errors"
	"net/http"
	"regexp"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Resetter interface {
	ResetWithLink(ctx context.Context, linkToken, password, ip string) error
}

func (s *site) formToken(nonce, link string) string {
	m := hmac.New(sha256.New, s.formKey)
	m.Write([]byte("reset-form\x00" + nonce + "\x00" + link))
	return base64.RawURLEncoding.EncodeToString(m.Sum(nil))
}

func resetCookie(r *http.Request, value string, maxAge int) *http.Cookie {
	c := &http.Cookie{Name: "academe-reset", Value: value, Path: "/", MaxAge: maxAge, HttpOnly: true, SameSite: http.SameSiteStrictMode}
	if r.TLS != nil || r.Header.Get("X-Forwarded-Proto") == "https" {
		c.Name, c.Secure = "__Host-academe-reset", true
	}
	return c
}

var linkPattern = regexp.MustCompile(`^[A-Za-z0-9_-]{1,64}$`)

func validLink(link string) bool {
	return linkPattern.MatchString(link)
}

func (s *site) resetForm(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	link := r.URL.Query().Get("c")
	if !validLink(link) {
		s.render(w, r, http.StatusBadRequest, "reset.html", view{Broken: true})
		return
	}
	nonce := rand.Text()
	http.SetCookie(w, resetCookie(r, nonce, 3600))
	s.render(w, r, http.StatusOK, "reset.html", view{Link: link, FormToken: s.formToken(nonce, link)})
}

func (s *site) resetPassword(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Cache-Control", "no-store")
	r.Body = http.MaxBytesReader(w, r.Body, 4<<10)
	if err := r.ParseForm(); err != nil {
		s.render(w, r, http.StatusBadRequest, "reset.html", view{Broken: true})
		return
	}
	link, token := r.PostFormValue("c"), r.PostFormValue("t")
	cookie, err := r.Cookie(resetCookie(r, "", 0).Name)
	if err != nil || !validLink(link) || !hmac.Equal([]byte(token), []byte(s.formToken(cookie.Value, link))) {
		s.render(w, r, http.StatusForbidden, "reset.html", view{Broken: true})
		return
	}
	v := view{Link: link, FormToken: token}
	password := r.PostFormValue("password")
	if password != r.PostFormValue("confirm") {
		v.Problem = "The two passwords don't match. Type the same password twice."
		s.render(w, r, http.StatusUnprocessableEntity, "reset.html", v)
		return
	}
	err = s.resets.ResetWithLink(r.Context(), link, password, clientIP(r))
	if _, ok := errors.AsType[*auth.ValidationError](err); ok {
		v.Problem = "Use 8 to 128 characters for your new password."
		s.render(w, r, http.StatusUnprocessableEntity, "reset.html", v)
		return
	}
	switch {
	case err == nil:
		http.SetCookie(w, resetCookie(r, "", -1))
		s.render(w, r, http.StatusOK, "reset.html", view{Done: true})
	case errors.Is(err, auth.ErrResetTokenExpired), errors.Is(err, auth.ErrTooManyAttempts):
		s.render(w, r, http.StatusGone, "reset.html", view{Expired: true})
	case errors.Is(err, auth.ErrThrottled):
		v.Problem = "Too many tries from this network. Wait an hour and try again."
		s.render(w, r, http.StatusTooManyRequests, "reset.html", v)
	default:
		s.logger.ErrorContext(r.Context(), "web password reset failed", "requestID", httpx.RequestID(r.Context()), "error", err)
		http.Error(w, "Something went wrong on our side. Please email support@academe.cc.", http.StatusInternalServerError)
	}
}
