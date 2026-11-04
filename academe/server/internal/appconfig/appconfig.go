package appconfig

import (
	"log/slog"
	"net/http"
	"strconv"
	"strings"

	"academe/server/internal/httpx"
)

const defaultPlayURL = "https://play.google.com/store/apps/details?id=com.academe.flutter"

type Policy struct {
	MinBuild         int
	RecommendedBuild int
	UpdateMessage    string
	UpdateURL        string
}

func (p Policy) public() map[string]any {
	url := p.UpdateURL
	if url == "" {
		url = defaultPlayURL
	}
	msg := p.UpdateMessage
	if msg == "" {
		msg = "Update ACADEMe from Google Play to keep studying."
	}
	return map[string]any{
		"minBuild":          p.MinBuild,
		"recommendedBuild":  p.RecommendedBuild,
		"updateMessage":     msg,
		"updateUrl":         url,
	}
}

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, p Policy) {
	mux.Handle("GET /app/config", httpx.Handle(logger, func(w http.ResponseWriter, r *http.Request) error {
		httpx.WriteJSON(w, http.StatusOK, p.public())
		return nil
	}))
}

func RequireBuild(p Policy, next http.Handler) http.Handler {
	if p.MinBuild <= 0 {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if exemptBuildCheck(r.Method, r.URL.Path) {
			next.ServeHTTP(w, r)
			return
		}
		build, _ := strconv.Atoi(strings.TrimSpace(r.Header.Get("X-App-Build")))
		if build >= p.MinBuild {
			next.ServeHTTP(w, r)
			return
		}
		httpx.WriteJSON(w, http.StatusForbidden, map[string]any{
			"error": map[string]any{
				"code":    "upgrade_required",
				"message": "This app version is too old. Update from Google Play.",
				"details": map[string]any{"minBuild": p.MinBuild},
			},
		})
	})
}

func exemptBuildCheck(method, path string) bool {
	if path == "/healthz" || path == "/app/config" {
		return true
	}
	if strings.HasPrefix(path, "/.well-known/") {
		return true
	}
	if path == "/billing/revenuecat/webhook" {
		return true
	}
	switch path {
	case "/", "/privacy", "/terms", "/support", "/delete-account", "/reset-password":
		return true
	}
	if path == "/delete-account" && method == http.MethodPost {
		return true
	}
	if strings.HasPrefix(path, "/email/") {
		return true
	}
	return false
}

func ParsePolicy(minBuild, recommendedBuild int, message, url string) Policy {
	return Policy{
		MinBuild:         minBuild,
		RecommendedBuild: recommendedBuild,
		UpdateMessage:    strings.TrimSpace(message),
		UpdateURL:        strings.TrimSpace(url),
	}
}

func LogPolicy(logger *slog.Logger, p Policy) {
	if p.MinBuild > 0 {
		logger.Info("app update policy", "minBuild", p.MinBuild, "recommendedBuild", p.RecommendedBuild)
	}
}
