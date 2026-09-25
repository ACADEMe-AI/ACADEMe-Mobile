package httpx

import (
	"context"
	"crypto/rand"
	"log/slog"
	"net/http"
	"net/netip"
	"runtime/debug"
	"strings"
	"time"
)

type requestIDKey struct{}

func WithRequestID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		id := rand.Text()
		w.Header().Set("X-Request-Id", id)
		next.ServeHTTP(w, r.WithContext(context.WithValue(r.Context(), requestIDKey{}, id)))
	})
}

func TrustClientIP(header string, next http.Handler) http.Handler {
	if header == "" {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if ip, err := netip.ParseAddr(strings.TrimSpace(r.Header.Get(header))); err == nil {
			r.RemoteAddr = netip.AddrPortFrom(ip, 0).String()
		}
		next.ServeHTTP(w, r)
	})
}

func RequestID(ctx context.Context) string {
	id, _ := ctx.Value(requestIDKey{}).(string)
	return id
}

func Recover(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		defer func() {
			v := recover()
			if v == nil {
				return
			}
			if v == http.ErrAbortHandler { //nolint:errorlint
				panic(v)
			}
			logger.ErrorContext(r.Context(), "panic",
				"requestID", RequestID(r.Context()),
				"panic", v,
				"stack", string(debug.Stack()))
			writeError(w, r, errInternal)
		}()
		next.ServeHTTP(w, r)
	})
}

func LogRequests(logger *slog.Logger, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)
		logger.InfoContext(r.Context(), "request",
			"requestID", RequestID(r.Context()),
			"method", r.Method,
			"path", r.URL.Path,
			"status", rec.status,
			"duration", time.Since(start))
	})
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (s *statusRecorder) WriteHeader(status int) {
	s.status = status
	s.ResponseWriter.WriteHeader(status)
}

func (s *statusRecorder) Unwrap() http.ResponseWriter { return s.ResponseWriter }
