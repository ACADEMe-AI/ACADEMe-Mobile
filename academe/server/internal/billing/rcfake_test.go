package billing

import (
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"
)

type rcCustomer struct {
	active, subscriptions, purchases string
}

type fakeRevenueCat struct {
	mu        sync.Mutex
	customers map[string]rcCustomer
	status    int
	deleted   []string
	calls     int
}

const rcCatalog = `/v2/projects/proj1/`

func (f *fakeRevenueCat) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.calls++
	path := r.URL.Path
	rest, inProject := strings.CutPrefix(path, rcCatalog+"customers/")
	id, tail, _ := strings.Cut(rest, "/")
	c, known := f.customers[id]
	switch {
	case r.Header.Get("Authorization") != "Bearer sk_test":
		w.WriteHeader(http.StatusUnauthorized)
	case path == "/v2/projects":
		_, _ = fmt.Fprint(w, `{"items":[{"id":"proj1","name":"ACADEMe","object":"project"}],"next_page":null,"object":"list"}`)
	case path == rcCatalog+"entitlements":
		_, _ = fmt.Fprint(w, `{"items":[{"id":"entl1","lookup_key":"academe_pro","object":"entitlement"},{"id":"entl2","lookup_key":"other","object":"entitlement"}],"object":"list"}`)
	case path == rcCatalog+"products":
		_, _ = fmt.Fprint(w, `{"items":[{"id":"prodm","store_identifier":"academe_pro:monthly","type":"subscription"},{"id":"prodl","store_identifier":"lifetime","type":"non_consumable"}],"object":"list"}`)
	case !inProject:
		w.WriteHeader(http.StatusNotFound)
	case f.status != 0:
		w.WriteHeader(f.status)
	case r.Method == http.MethodDelete:
		f.deleted = append(f.deleted, id)
		_, _ = fmt.Fprint(w, `{"object":"customer","id":"c","deleted_at":1}`)
	case !known:
		w.WriteHeader(http.StatusNotFound)
		_, _ = fmt.Fprint(w, `{"type":"resource_missing"}`)
	case tail == "":
		_, _ = fmt.Fprintf(w, `{"object":"customer","id":"c","project_id":"proj1","first_seen_at":1,"active_entitlements":{"object":"list","items":[%s],"next_page":null}}`, c.active)
	case tail == "subscriptions":
		_, _ = fmt.Fprintf(w, `{"object":"list","items":[%s],"next_page":null}`, c.subscriptions)
	case tail == "purchases":
		_, _ = fmt.Fprintf(w, `{"object":"list","items":[%s],"next_page":null}`, c.purchases)
	default:
		w.WriteHeader(http.StatusNotFound)
	}
}

func (f *fakeRevenueCat) set(id string, c rcCustomer, status int) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.customers[id], f.status = c, status
}

func activeJSON(entitlementID string, expires *time.Time) string {
	at := "null"
	if expires != nil {
		at = fmt.Sprint(expires.UnixMilli())
	}
	return fmt.Sprintf(`{"object":"customer.active_entitlement","entitlement_id":%q,"expires_at":%s}`, entitlementID, at)
}

func subscriptionJSON(store, product, status, autoRenewal, environment string, givesAccess bool, lookupKey string) string {
	return fmt.Sprintf(`{"object":"subscription","id":"sub1","customer_id":"c","product_id":%s,"starts_at":1,"current_period_starts_at":1,"current_period_ends_at":2,"gives_access":%t,"pending_payment":false,"auto_renewal_status":%q,"status":%q,"entitlements":{"object":"list","items":[{"object":"entitlement","id":"x","lookup_key":%q,"display_name":"Pro"}],"next_page":null},"environment":%q,"store":%q,"store_subscription_identifier":"GPA.1","ownership":"purchased"}`,
		product, givesAccess, autoRenewal, status, lookupKey, environment, store)
}

func subscriberJSON(expires time.Time, unsubscribed bool) rcCustomer {
	autoRenewal := "will_renew"
	if unsubscribed {
		autoRenewal = "will_not_renew"
	}
	return rcCustomer{
		active:        activeJSON("entl1", &expires),
		subscriptions: subscriptionJSON("play_store", `"prodm"`, "active", autoRenewal, "production", true, "academe_pro"),
	}
}
