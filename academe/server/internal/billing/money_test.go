package billing

import (
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/google/go-cmp/cmp"

	"academe/server/internal/httpx"
)

func hook(t *testing.T, ts testServer, body string) {
	t.Helper()
	if status, out := ts.do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {webhook}}, body); status != http.StatusOK {
		t.Fatalf("webhook = %d %v, want 200", status, out)
	}
}

func planOf(t *testing.T, ts testServer, account string) map[string]any {
	t.Helper()
	_, body := ts.do(t, http.MethodGet, "/me/plan", as(account), "")
	return body
}

func TestSandboxOnlyForTesters(t *testing.T) {
	ts := newTestServer(t, false, webhook)
	later := time.Now().Add(time.Hour)
	hook(t, ts, testEvent{"s1", "INITIAL_PURCHASE", riya, later, time.Now()}.bodyIn("SANDBOX"))
	if p := planOf(t, ts, riya); p["plan"] != "free" {
		t.Errorf("plan after a sandbox purchase by a non-tester = %v, want free", p["plan"])
	}
	ts.service.SetTesters([]string{riya})
	hook(t, ts, testEvent{"s2", "INITIAL_PURCHASE", riya, later, time.Now()}.bodyIn("SANDBOX"))
	if p := planOf(t, ts, riya); p["plan"] != "pro" {
		t.Errorf("plan after a sandbox purchase by a tester = %v, want pro", p["plan"])
	}
	hook(t, ts, testEvent{"s3", "INITIAL_PURCHASE", arjun, later, time.Now()}.bodyIn("SANDBOX"))
	if p := planOf(t, ts, arjun); p["plan"] != "free" {
		t.Errorf("arjun (not a tester) after a sandbox purchase = %v, want free", p["plan"])
	}
	ts.service.SetTesters([]string{"*"})
	hook(t, ts, testEvent{"s4", "INITIAL_PURCHASE", arjun, later, time.Now()}.bodyIn("SANDBOX"))
	if p := planOf(t, ts, arjun); p["plan"] != "pro" {
		t.Errorf("arjun with testers=* = %v, want pro", p["plan"])
	}
}

func TestPromotionalGraceAndExtension(t *testing.T) {
	ts := newTestServer(t, false, webhook)
	promo := fmt.Sprintf(`{"api_version":"1.0","event":{"id":"p1","type":"NON_RENEWING_PURCHASE","app_user_id":%q,"product_id":"rc_promo_academe_pro_lifetime","entitlement_ids":["academe_pro"],"period_type":"PROMOTIONAL","expiration_at_ms":null,"event_timestamp_ms":%d,"store":"PROMOTIONAL","environment":"PRODUCTION"}}`, riya, time.Now().UnixMilli())
	hook(t, ts, promo)
	if p := planOf(t, ts, riya); p["plan"] != "pro" || p["expiresAt"] != nil || p["platform"] != "promotional" || p["autoRenew"] != false {
		t.Errorf("plan after a lifetime promotional grant = %v, want pro with no expiry", p)
	}
	past := time.Now().Add(-time.Hour)
	grace := time.Now().Add(3 * 24 * time.Hour)
	billingIssue := fmt.Sprintf(`{"api_version":"1.0","event":{"id":"b1","type":"BILLING_ISSUE","app_user_id":%q,"product_id":"academe_pro:monthly","entitlement_ids":["academe_pro"],"expiration_at_ms":%d,"grace_period_expiration_at_ms":%d,"event_timestamp_ms":%d,"store":"PLAY_STORE","environment":"PRODUCTION"}}`,
		arjun, past.UnixMilli(), grace.UnixMilli(), time.Now().UnixMilli())
	hook(t, ts, billingIssue)
	p := planOf(t, ts, arjun)
	expires, _ := time.Parse(time.RFC3339Nano, fmt.Sprint(p["expiresAt"]))
	if p["plan"] != "pro" || p["state"] != "billing_issue" || !expires.Equal(time.UnixMilli(grace.UnixMilli())) {
		t.Errorf("plan in the grace period = %v, want pro until the grace period ends", p)
	}
	hook(t, ts, testEvent{"x1", "SUBSCRIPTION_EXTENDED", arjun, time.Now().Add(40 * 24 * time.Hour), time.Now().Add(time.Second)}.body())
	if p := planOf(t, ts, arjun); p["plan"] != "pro" || p["state"] != "active" {
		t.Errorf("plan after SUBSCRIPTION_EXTENDED = %v, want pro active", p)
	}
}

func TestExpirationAsksRevenueCat(t *testing.T) {
	ts := newTestServer(t, true, webhook)
	hook(t, ts, testEvent{"1", "INITIAL_PURCHASE", riya, time.Now().Add(time.Hour), time.Now()}.body())
	ts.revenueCat.set(riya, rcCustomer{active: activeJSON("entl1", nil), subscriptions: subscriptionJSON("promotional", "null", "active", "will_not_renew", "production", true, "academe_pro")}, 0)
	hook(t, ts, testEvent{"2", "EXPIRATION", riya, time.Now().Add(-time.Minute), time.Now().Add(time.Second)}.body())
	if p := planOf(t, ts, riya); p["plan"] != "pro" || p["platform"] != "promotional" || p["expiresAt"] != nil {
		t.Errorf("plan after the Play subscription expired but a lifetime grant remains = %v, want lifetime pro", p)
	}
	ts.revenueCat.set(riya, rcCustomer{}, http.StatusInternalServerError)
	if status, _ := ts.do(t, http.MethodPost, "/billing/revenuecat/webhook", http.Header{"Authorization": {webhook}}, testEvent{"3", "EXPIRATION", riya, time.Now(), time.Now().Add(2 * time.Second)}.body()); status != http.StatusBadGateway {
		t.Errorf("EXPIRATION while RevenueCat is down = %d, want 502 so RevenueCat retries", status)
	}
}

func TestTransferKeepsOrdering(t *testing.T) {
	ts := newTestServer(t, false, webhook)
	start := time.Now()
	hook(t, ts, testEvent{"1", "INITIAL_PURCHASE", riya, start.Add(time.Hour), start}.body())
	hook(t, ts, fmt.Sprintf(`{"api_version":"1.0","event":{"id":"2","type":"TRANSFER","transferred_from":[%q,"$RCAnonymousID:x"],"transferred_to":[%q],"event_timestamp_ms":%d,"store":"PLAY_STORE","environment":"PRODUCTION"}}`, riya, arjun, start.Add(time.Minute).UnixMilli()))
	hook(t, ts, testEvent{"3", "RENEWAL", riya, start.Add(time.Hour), start.Add(30 * time.Second)}.body())
	if p := planOf(t, ts, riya); p["plan"] != "free" {
		t.Errorf("riya after a late RENEWAL from before the transfer = %v, want free", p["plan"])
	}
}

func TestSyncIsRateLimited(t *testing.T) {
	ts := newTestServer(t, true, "")
	for i := range syncsPerMinute {
		if status, _ := ts.do(t, http.MethodPost, "/billing/sync", as(riya), ""); status != http.StatusOK {
			t.Fatalf("sync #%d = %d, want 200", i+1, status)
		}
	}
	if status, body := ts.do(t, http.MethodPost, "/billing/sync", as(riya), ""); status != http.StatusTooManyRequests || errorCode(body) != "too_many_requests" {
		t.Errorf("sync #%d = %d %v, want 429 too_many_requests", syncsPerMinute+1, status, body)
	}
	if status, _ := ts.do(t, http.MethodPost, "/billing/sync", as(arjun), ""); status != http.StatusOK {
		t.Errorf("sync for another account = %d, want 200", status)
	}
}

func TestSubscriberParsesRevenueCatV2(t *testing.T) {
	rc := &fakeRevenueCat{customers: map[string]rcCustomer{}}
	server := httptest.NewServer(rc)
	t.Cleanup(server.Close)
	client := NewRevenueCat("sk_test", server.URL, server.Client())
	grace := time.Date(2026, 10, 28, 10, 0, 0, 0, time.UTC)
	rc.set(riya, rcCustomer{
		active:        activeJSON("entl2", nil) + "," + activeJSON("entl1", &grace),
		subscriptions: subscriptionJSON("play_store", `"prodx"`, "expired", "will_not_renew", "production", false, "academe_pro") + "," + subscriptionJSON("test_store", `"prodm"`, "in_grace_period", "will_renew", "sandbox", true, "academe_pro"),
	}, 0)
	rc.set(arjun, rcCustomer{active: activeJSON("entl1", nil), purchases: `{"object":"purchase","id":"p1","product_id":"prodl","status":"owned","environment":"sandbox","store":"test_store","store_purchase_identifier":"t1","entitlements":{"object":"list","items":[{"id":"entl1","lookup_key":"academe_pro"}],"next_page":null}}`}, 0)
	rc.set(nobody, rcCustomer{active: activeJSON("entl2", nil)}, 0)
	tests := []struct {
		name, id string
		want     *Entitlement
	}{
		{"subscription in grace", riya, &Entitlement{Platform: "test_store", ProductID: "academe_pro", BasePlanID: "monthly", Token: "GPA.1", State: "billing_issue", ExpiresAt: &grace, AutoRenew: true, Sandbox: true}},
		{"lifetime purchase", arjun, &Entitlement{Platform: "test_store", ProductID: "lifetime", Token: "t1", State: "active", Sandbox: true}},
		{"another entitlement only", nobody, nil},
		{"never seen", "22222222-2222-4333-8444-555555555555", nil},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := client.Subscriber(t.Context(), tc.id, EntitlementID)
			if err != nil {
				t.Fatal(err)
			}
			if got != nil {
				got.Raw, got.EventAt = nil, time.Time{}
			}
			if diff := cmp.Diff(tc.want, got); diff != "" {
				t.Errorf("Subscriber() diff (-want +got):\n%s", diff)
			}
		})
	}
	rc.mu.Lock()
	calls := rc.calls
	rc.mu.Unlock()
	if calls > 3+4*3 {
		t.Errorf("RevenueCat called %d times, want the catalog loaded once", calls)
	}
	e := Entitlement{State: "active", ExpiresAt: &grace}
	if !e.active(grace.Add(-time.Millisecond)) || e.active(grace) {
		t.Error("active() around the expiry is wrong: want active a millisecond before, inactive at the instant")
	}
}

func TestDeleteSubscriber(t *testing.T) {
	rc := &fakeRevenueCat{customers: map[string]rcCustomer{}}
	server := httptest.NewServer(rc)
	t.Cleanup(server.Close)
	client := NewRevenueCat("sk_test", server.URL, server.Client())
	if err := client.DeleteSubscriber(t.Context(), riya); err != nil {
		t.Fatalf("DeleteSubscriber() = %v, want nil", err)
	}
	rc.set(arjun, rcCustomer{}, http.StatusInternalServerError)
	if err := client.DeleteSubscriber(t.Context(), arjun); err == nil {
		t.Error("DeleteSubscriber() when RevenueCat fails = nil, want an error")
	}
	rc.mu.Lock()
	defer rc.mu.Unlock()
	if len(rc.deleted) != 1 || rc.deleted[0] != riya {
		t.Errorf("deleted %v, want [%s]", rc.deleted, riya)
	}
}

func TestLimitMessageNamesTheFeature(t *testing.T) {
	err, ok := errors.AsType[*httpx.Error](HTTPError(&LimitError{Feature: AskMe, Limit: 10}))
	if !ok || err.Message != "You've used today's free ASKMe messages." || err.Status != http.StatusPaymentRequired {
		t.Errorf("HTTPError(askme limit) = %+v, want 402 naming ASKMe messages", err)
	}
}
