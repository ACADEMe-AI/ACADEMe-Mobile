package billing

import (
	"encoding/json"
	"fmt"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

const (
	riya    = "7c9e6679-7425-40de-944b-e07fc1f90ae7"
	arjun   = "0b6f1c1e-7c4b-4b8e-9d7e-3c8a5e2f1a90"
	nobody  = "11111111-2222-4333-8444-555555555555"
	webhook = "Bearer hook-secret"
)

type fakeRevenueCat struct {
	mu          sync.Mutex
	subscribers map[string]string
	status      int
	deleted     []string
}

func (f *fakeRevenueCat) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()
	id, ok := strings.CutPrefix(r.URL.Path, "/v1/subscribers/")
	switch {
	case r.Header.Get("Authorization") != "Bearer sk_test":
		w.WriteHeader(http.StatusUnauthorized)
	case !ok:
		w.WriteHeader(http.StatusNotFound)
	case f.status != 0:
		w.WriteHeader(f.status)
	case r.Method == http.MethodDelete:
		f.deleted = append(f.deleted, id)
		_, _ = fmt.Fprint(w, `{"deleted":true}`)
	default:
		body, ok := f.subscribers[id]
		if !ok {
			body = `{"subscriber":{"entitlements":{},"subscriptions":{}}}`
		}
		_, _ = fmt.Fprint(w, body)
	}
}

func (f *fakeRevenueCat) set(id, body string, status int) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.subscribers[id], f.status = body, status
}

func subscriberJSON(expires time.Time, unsubscribed bool) string {
	unsubscribe := "null"
	if unsubscribed {
		unsubscribe = `"2026-09-20T00:00:00Z"`
	}
	return fmt.Sprintf(`{"request_date":"2026-09-25T00:00:00Z","subscriber":{"entitlements":{"pro":{"expires_date":%q,"grace_period_expires_date":null,"product_identifier":"academe_pro:monthly","purchase_date":"2026-09-01T00:00:00Z"}},"subscriptions":{"academe_pro":{"store":"play_store","product_plan_identifier":"monthly","store_transaction_id":"GPA.1","unsubscribe_detected_at":%s,"billing_issues_detected_at":null,"is_sandbox":true}}}}`,
		expires.UTC().Format(time.RFC3339), unsubscribe)
}

type testServer struct {
	revenueCat *fakeRevenueCat
	store      *fakeStore
	url        string
}

func newTestServer(t *testing.T, withKey bool, webhookAuth string) testServer {
	t.Helper()
	rc := &fakeRevenueCat{subscribers: map[string]string{}}
	rcServer := httptest.NewServer(rc)
	t.Cleanup(rcServer.Close)
	var client *RevenueCat
	if withKey {
		client = NewRevenueCat("sk_test", rcServer.URL, rcServer.Client())
	}
	store := newFakeStore(riya, arjun)
	service := NewService(store, testLimits, client)
	mux := http.NewServeMux()
	logger := slog.New(slog.NewTextHandler(io.Discard, nil))
	guard := func(next httpx.HandlerFunc) httpx.HandlerFunc {
		return func(w http.ResponseWriter, r *http.Request) error {
			return next(w, r.WithContext(auth.WithAccountID(r.Context(), r.Header.Get("Account"))))
		}
	}
	RegisterRoutes(mux, logger, service, guard, webhookAuth)
	mux.Handle("POST /use", httpx.Handle(logger, guard(func(w http.ResponseWriter, r *http.Request) error {
		if err := service.Take(r.Context(), auth.AccountID(r.Context()), Feature(r.URL.Query().Get("feature"))); err != nil {
			return HTTPError(err)
		}
		w.WriteHeader(http.StatusNoContent)
		return nil
	})))
	api := httptest.NewServer(mux)
	t.Cleanup(api.Close)
	return testServer{revenueCat: rc, store: store, url: api.URL}
}

func (ts testServer) do(t *testing.T, method, path string, header http.Header, body string) (int, map[string]any) {
	t.Helper()
	req, err := http.NewRequestWithContext(t.Context(), method, ts.url+path, strings.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	for k, v := range header {
		req.Header[k] = v
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer resp.Body.Close() //nolint:errcheck
	var out map[string]any
	_ = json.NewDecoder(resp.Body).Decode(&out)
	return resp.StatusCode, out
}

func as(account string) http.Header { return http.Header{"Account": {account}} }

func errorCode(body map[string]any) string {
	e, _ := body["error"].(map[string]any)
	code, _ := e["code"].(string)
	return code
}

func TestPlanAndLimitErrors(t *testing.T) {
	ts := newTestServer(t, false, "")
	status, body := ts.do(t, http.MethodGet, "/me/plan", as(riya), "")
	limits, _ := body["limits"].(map[string]any)
	if status != http.StatusOK || body["plan"] != "free" || limits["askme"] != 2.0 || limits["lessons"] != 0.0 || body["expiresAt"] != nil {
		t.Fatalf("GET /me/plan = %d %v, want free with limits", status, body)
	}
	tests := []struct {
		name, feature, code string
		status              int
	}{
		{"first check", "check", "", http.StatusNoContent},
		{"second check", "check", "limit_reached", http.StatusPaymentRequired},
		{"lesson from notes", "lessons", "pro_only", http.StatusPaymentRequired},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			status, body := ts.do(t, http.MethodPost, "/use?feature="+tc.feature, as(riya), "")
			if status != tc.status || errorCode(body) != tc.code {
				t.Fatalf("POST /use?feature=%s = %d %v, want %d %q", tc.feature, status, body, tc.status, tc.code)
			}
			if tc.code != "" {
				details, _ := body["error"].(map[string]any)["details"].(map[string]any)
				if details["feature"] != tc.feature || details["resetsAt"] == nil {
					t.Errorf("details = %v, want the feature and resetsAt", details)
				}
			}
		})
	}
	if status, body := ts.do(t, http.MethodPost, "/billing/sync", as(riya), ""); status != http.StatusServiceUnavailable || errorCode(body) != "billing_unavailable" {
		t.Errorf("sync without a secret key = %d %v, want 503 billing_unavailable", status, body)
	}
}

func TestSync(t *testing.T) {
	ts := newTestServer(t, true, "")
	ts.revenueCat.set(riya, subscriberJSON(time.Now().Add(30*24*time.Hour), false), 0)
	status, body := ts.do(t, http.MethodPost, "/billing/sync", as(riya), "")
	limits, _ := body["limits"].(map[string]any)
	if status != http.StatusOK || body["plan"] != "pro" || body["productId"] != "academe_pro" || body["basePlanId"] != "monthly" ||
		body["platform"] != "play_store" || body["autoRenew"] != true || limits["askme"] != nil {
		t.Fatalf("sync = %d %v, want pro on the monthly plan", status, body)
	}
	ts.revenueCat.set(riya, subscriberJSON(time.Now().Add(time.Hour), true), 0)
	if _, body := ts.do(t, http.MethodPost, "/billing/sync", as(riya), ""); body["plan"] != "pro" || body["state"] != "canceled" || body["autoRenew"] != false {
		t.Errorf("sync after cancelling = %v, want pro, canceled, not renewing", body)
	}
	ts.revenueCat.set(riya, `{"subscriber":{"entitlements":{},"subscriptions":{}}}`, 0)
	if _, body := ts.do(t, http.MethodPost, "/billing/sync", as(riya), ""); body["plan"] != "free" {
		t.Errorf("sync with no entitlement = %v, want free", body)
	}
	ts.revenueCat.set(riya, "", http.StatusInternalServerError)
	if status, body := ts.do(t, http.MethodPost, "/billing/sync", as(riya), ""); status != http.StatusBadGateway || errorCode(body) != "billing_failed" {
		t.Errorf("sync when RevenueCat fails = %d %v, want 502 billing_failed", status, body)
	}
}

type testEvent struct {
	id, kind, user string
	expires        time.Time
	at             time.Time
}

func (e testEvent) body() string {
	expiration := "null"
	if !e.expires.IsZero() {
		expiration = fmt.Sprint(e.expires.UnixMilli())
	}
	return fmt.Sprintf(`{"api_version":"1.0","event":{"id":%q,"type":%q,"app_user_id":%q,"original_app_user_id":%q,"aliases":[],"product_id":"academe_pro:monthly","entitlement_ids":["pro"],"period_type":"NORMAL","purchased_at_ms":1,"expiration_at_ms":%s,"event_timestamp_ms":%d,"store":"PLAY_STORE","environment":"SANDBOX","original_transaction_id":"GPA.1"}}`,
		e.id, e.kind, e.user, e.user, expiration, e.at.UnixMilli())
}

func TestWebhookAuth(t *testing.T) {
	ev := testEvent{id: "e1", kind: "INITIAL_PURCHASE", user: riya, expires: time.Now().Add(time.Hour), at: time.Now()}.body()
	if status, _ := newTestServer(t, false, "").do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {webhook}}, ev); status != http.StatusServiceUnavailable {
		t.Errorf("webhook without auth configured = %d, want 503", status)
	}
	ts := newTestServer(t, false, webhook)
	tests := []struct {
		name, auth, body string
		status           int
	}{
		{"no header", "", ev, http.StatusUnauthorized},
		{"wrong header", "Bearer nope", ev, http.StatusUnauthorized},
		{"not an event", webhook, `{"event":{}}`, http.StatusBadRequest},
		{"test event", webhook, `{"api_version":"1.0","event":{"id":"t","type":"TEST","app_user_id":"x"}}`, http.StatusOK},
		{"anonymous user", webhook, testEvent{id: "e2", kind: "INITIAL_PURCHASE", user: "$RCAnonymousID:abc", expires: time.Now().Add(time.Hour), at: time.Now()}.body(), http.StatusOK},
		{"unknown account", webhook, testEvent{id: "e3", kind: "INITIAL_PURCHASE", user: nobody, expires: time.Now().Add(time.Hour), at: time.Now()}.body(), http.StatusOK},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if status, body := ts.do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {tc.auth}}, tc.body); status != tc.status {
				t.Errorf("webhook = %d %v, want %d", status, body, tc.status)
			}
		})
	}
	if _, body := ts.do(t, http.MethodGet, "/me/plan", as(riya), ""); body["plan"] != "free" {
		t.Errorf("plan after rejected webhooks = %v, want free", body["plan"])
	}
}

func TestWebhookEvents(t *testing.T) {
	ts := newTestServer(t, true, webhook)
	start := time.Now().Add(-time.Hour)
	later := time.Now().Add(30 * 24 * time.Hour)
	tests := []struct {
		event       testEvent
		plan, state string
		autoRenew   bool
	}{
		{testEvent{"1", "INITIAL_PURCHASE", riya, later, start}, "pro", "active", true},
		{testEvent{"2", "RENEWAL", riya, later, start.Add(time.Minute)}, "pro", "active", true},
		{testEvent{"3", "PRODUCT_CHANGE", riya, later, start.Add(2 * time.Minute)}, "pro", "active", true},
		{testEvent{"4", "CANCELLATION", riya, later, start.Add(3 * time.Minute)}, "pro", "canceled", false},
		{testEvent{"5", "UNCANCELLATION", riya, later, start.Add(4 * time.Minute)}, "pro", "active", true},
		{testEvent{"6", "BILLING_ISSUE", riya, later, start.Add(5 * time.Minute)}, "pro", "billing_issue", true},
		{testEvent{"7", "SUBSCRIPTION_PAUSED", riya, later, start.Add(6 * time.Minute)}, "pro", "paused", false},
		{testEvent{"1", "EXPIRATION", riya, start, start.Add(7 * time.Minute)}, "pro", "paused", false},
		{testEvent{"8", "RENEWAL", riya, later, start.Add(-time.Minute)}, "pro", "paused", false},
		{testEvent{"9", "EXPIRATION", riya, start, start.Add(8 * time.Minute)}, "free", "", false},
	}
	for _, tc := range tests {
		t.Run(tc.event.id+" "+tc.event.kind, func(t *testing.T) {
			if status, body := ts.do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {webhook}}, tc.event.body()); status != http.StatusOK {
				t.Fatalf("webhook = %d %v, want 200", status, body)
			}
			_, body := ts.do(t, http.MethodGet, "/me/plan", as(riya), "")
			state, _ := body["state"].(string)
			if body["plan"] != tc.plan || state != tc.state || body["autoRenew"] != tc.autoRenew {
				t.Errorf("plan = %v %q autoRenew %v, want %s %q %v", body["plan"], state, body["autoRenew"], tc.plan, tc.state, tc.autoRenew)
			}
		})
	}

	t.Run("TRANSFER", func(t *testing.T) {
		ts.do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {webhook}}, testEvent{"10", "RENEWAL", riya, later, time.Now()}.body())
		ts.revenueCat.set(arjun, subscriberJSON(later, false), 0)
		transfer := fmt.Sprintf(`{"api_version":"1.0","event":{"id":"11","type":"TRANSFER","app_user_id":%q,"transferred_from":[%q],"transferred_to":[%q],"event_timestamp_ms":%d,"store":"PLAY_STORE"}}`,
			arjun, riya, arjun, time.Now().UnixMilli())
		if status, body := ts.do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {webhook}}, transfer); status != http.StatusOK {
			t.Fatalf("transfer = %d %v, want 200", status, body)
		}
		if _, body := ts.do(t, http.MethodGet, "/me/plan", as(riya), ""); body["plan"] != "free" {
			t.Errorf("riya after the transfer = %v, want free", body["plan"])
		}
		if _, body := ts.do(t, http.MethodGet, "/me/plan", as(arjun), ""); body["plan"] != "pro" {
			t.Errorf("arjun after the transfer = %v, want pro", body["plan"])
		}
	})
}

func TestDeleteSubscriber(t *testing.T) {
	rc := &fakeRevenueCat{subscribers: map[string]string{}}
	server := httptest.NewServer(rc)
	t.Cleanup(server.Close)
	client := NewRevenueCat("sk_test", server.URL, server.Client())
	if err := client.DeleteSubscriber(t.Context(), riya); err != nil {
		t.Fatalf("DeleteSubscriber() = %v, want nil", err)
	}
	rc.set(arjun, "", http.StatusInternalServerError)
	if err := client.DeleteSubscriber(t.Context(), arjun); err == nil {
		t.Error("DeleteSubscriber() when RevenueCat fails = nil, want an error")
	}
	rc.mu.Lock()
	defer rc.mu.Unlock()
	if len(rc.deleted) != 1 || rc.deleted[0] != riya {
		t.Errorf("deleted %v, want [%s]", rc.deleted, riya)
	}
}
