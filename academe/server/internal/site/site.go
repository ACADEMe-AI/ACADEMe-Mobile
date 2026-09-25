package site

import (
	"bytes"
	"context"
	"embed"
	"fmt"
	"html/template"
	"log/slog"
	"net/http"
	"net/mail"
	"net/netip"
	"strings"

	"academe/server/internal/httpx"
)

//go:embed pages/*.html
var pages embed.FS

//go:embed email
var emailAssets embed.FS

const maxEmailLength = 254

type Store interface {
	RequestDeletion(ctx context.Context, email, ip string) (bool, error)
}

type Mailer interface {
	SendDeletionNotice(ctx context.Context, to string) error
}

type Options struct {
	Store        Store
	Mailer       Mailer
	Resets       Resetter
	FormKey      []byte
	AndroidCerts []string
}

type view struct {
	Sent      bool
	Invalid   bool
	Email     string
	Link      string
	FormToken string
	Problem   string
	Broken    bool
	Expired   bool
	Done      bool
}

type site struct {
	logger  *slog.Logger
	store   Store
	mailer  Mailer
	resets  Resetter
	formKey []byte
	pages   map[string]*template.Template
}

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, o Options) error {
	s := &site{logger: logger, store: o.Store, mailer: o.Mailer, resets: o.Resets, formKey: o.FormKey, pages: map[string]*template.Template{}}
	layout, err := template.ParseFS(pages, "pages/layout.html")
	if err != nil {
		return fmt.Errorf("parse layout: %w", err)
	}
	routes := map[string]string{
		"/{$}":            "index.html",
		"/privacy":        "privacy.html",
		"/terms":          "terms.html",
		"/delete-account": "delete.html",
		"/support":        "support.html",
		"/open":           "open.html",
		"/reset-password": "reset.html",
	}
	for path, file := range routes {
		t, err := layout.Clone()
		if err == nil {
			_, err = t.ParseFS(pages, "pages/"+file)
		}
		if err != nil {
			return fmt.Errorf("parse %s: %w", file, err)
		}
		s.pages[file] = t
		if file == "reset.html" {
			continue
		}
		mux.HandleFunc("GET "+path, func(w http.ResponseWriter, r *http.Request) {
			s.render(w, r, http.StatusOK, file, view{})
		})
	}
	mux.HandleFunc("POST /delete-account", s.requestDeletion)
	mux.HandleFunc("GET /reset-password", s.resetForm)
	mux.HandleFunc("POST /reset-password", s.resetPassword)
	mux.HandleFunc("GET /email/{name}", serveEmailAsset)
	links, err := assetLinks(o.AndroidCerts)
	if err != nil {
		return err
	}
	mux.HandleFunc("GET /.well-known/assetlinks.json", links)
	return nil
}

func (s *site) requestDeletion(w http.ResponseWriter, r *http.Request) {
	r.Body = http.MaxBytesReader(w, r.Body, 4<<10)
	if err := r.ParseForm(); err != nil {
		s.render(w, r, http.StatusBadRequest, "delete.html", view{Invalid: true})
		return
	}
	address, ok := parseEmail(r.PostFormValue("email"))
	if !ok {
		s.render(w, r, http.StatusUnprocessableEntity, "delete.html", view{Invalid: true, Email: r.PostFormValue("email")})
		return
	}
	fresh, err := s.store.RequestDeletion(r.Context(), address, clientIP(r))
	if err != nil {
		s.logger.ErrorContext(r.Context(), "deletion request failed", "requestID", httpx.RequestID(r.Context()), "error", err)
		http.Error(w, "Something went wrong on our side. Please email support@academe.cc.", http.StatusInternalServerError)
		return
	}
	if fresh && s.mailer != nil {
		if err := s.mailer.SendDeletionNotice(r.Context(), address); err != nil {
			s.logger.ErrorContext(r.Context(), "deletion confirmation not sent", "requestID", httpx.RequestID(r.Context()), "error", err)
		}
	}
	s.render(w, r, http.StatusOK, "delete.html", view{Sent: true})
}

func (s *site) render(w http.ResponseWriter, r *http.Request, status int, file string, v view) {
	var buf bytes.Buffer
	if err := s.pages[file].ExecuteTemplate(&buf, "layout", v); err != nil {
		s.logger.ErrorContext(r.Context(), "render page", "requestID", httpx.RequestID(r.Context()), "page", file, "error", err)
		http.Error(w, "Something went wrong on our side.", http.StatusInternalServerError)
		return
	}
	h := w.Header()
	h.Set("Content-Type", "text/html; charset=utf-8")
	h.Set("Content-Security-Policy", "default-src 'none'; style-src 'unsafe-inline'; img-src 'self' data:; font-src 'self'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'")
	h.Set("X-Content-Type-Options", "nosniff")
	h.Set("Referrer-Policy", "no-referrer")
	w.WriteHeader(status)
	_, _ = w.Write(buf.Bytes())
}

func parseEmail(raw string) (string, bool) {
	raw = strings.ToLower(strings.TrimSpace(raw))
	if raw == "" || len(raw) > maxEmailLength {
		return "", false
	}
	addr, err := mail.ParseAddress(raw)
	if err != nil || addr.Address != raw {
		return "", false
	}
	return raw, true
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
