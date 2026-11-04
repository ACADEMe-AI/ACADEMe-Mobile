package appconfig

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestRequireBuildBlocksAPI(t *testing.T) {
	p := Policy{MinBuild: 10}
	next := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	h := RequireBuild(p, next)

	req := httptest.NewRequest(http.MethodGet, "/me/plan", nil)
	req.Header.Set("X-App-Build", "9")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusForbidden {
		t.Fatalf("old build = %d, want 403", rec.Code)
	}

	req = httptest.NewRequest(http.MethodGet, "/app/config", nil)
	rec = httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("/app/config = %d, want 204", rec.Code)
	}

	req = httptest.NewRequest(http.MethodPost, "/billing/revenuecat/webhook", nil)
	rec = httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if rec.Code != http.StatusNoContent {
		t.Fatalf("webhook = %d, want 204", rec.Code)
	}
}

func TestRequireBuildAllowsCurrent(t *testing.T) {
	p := Policy{MinBuild: 8}
	called := false
	h := RequireBuild(p, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		called = true
		w.WriteHeader(http.StatusOK)
	}))
	req := httptest.NewRequest(http.MethodGet, "/me/profile", nil)
	req.Header.Set("X-App-Build", "8")
	rec := httptest.NewRecorder()
	h.ServeHTTP(rec, req)
	if !called || rec.Code != http.StatusOK {
		t.Fatalf("build 8: called=%v code=%d", called, rec.Code)
	}
}
