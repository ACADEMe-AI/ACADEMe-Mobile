package billing

import (
	"cmp"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"slices"
	"strings"
	"sync"
	"time"
)

const (
	RevenueCatAPI = "https://api.revenuecat.com"
	EntitlementID = "academe_pro"
	catalogTTL    = 10 * time.Minute
)

var errNotFound = errors.New("revenuecat resource missing")

type RevenueCat struct {
	secretKey string
	apiURL    string
	client    *http.Client

	mu       sync.Mutex
	project  string
	ids      map[string]string
	products map[string]string
	loadedAt time.Time
}

func NewRevenueCat(secretKey, apiURL string, client *http.Client) *RevenueCat {
	return &RevenueCat{secretKey: secretKey, apiURL: apiURL, client: client}
}

func (rc *RevenueCat) call(ctx context.Context, method, path string, out any) error {
	req, err := http.NewRequestWithContext(ctx, method, rc.apiURL+"/v2"+path, http.NoBody)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+rc.secretKey)
	resp, err := rc.client.Do(req)
	if err != nil {
		return fmt.Errorf("%w: %w", ErrStore, err)
	}
	defer resp.Body.Close() //nolint:errcheck
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	switch {
	case err != nil:
		return fmt.Errorf("%w: %w", ErrStore, err)
	case resp.StatusCode == http.StatusNotFound:
		return errNotFound
	case resp.StatusCode != http.StatusOK:
		return fmt.Errorf("%w: %s %s status %d", ErrStore, method, path, resp.StatusCode)
	case out == nil:
		return nil
	}
	if err := json.Unmarshal(body, out); err != nil {
		return fmt.Errorf("%w: %w", ErrStore, err)
	}
	return nil
}

type list[T any] struct {
	Items []T `json:"items"`
}

type catalogItem struct {
	ID              string `json:"id"`
	LookupKey       string `json:"lookup_key"`
	StoreIdentifier string `json:"store_identifier"`
}

func (rc *RevenueCat) catalog(ctx context.Context) (string, map[string]string, map[string]string, error) {
	rc.mu.Lock()
	defer rc.mu.Unlock()
	if rc.project != "" && time.Since(rc.loadedAt) < catalogTTL {
		return rc.project, rc.ids, rc.products, nil
	}
	var projects, entitlements, products list[catalogItem]
	if err := rc.call(ctx, http.MethodGet, "/projects", &projects); err != nil {
		return "", nil, nil, fmt.Errorf("list projects: %w", err)
	}
	if len(projects.Items) != 1 {
		return "", nil, nil, fmt.Errorf("%w: the secret key sees %d projects, want 1", ErrStore, len(projects.Items))
	}
	project := "/projects/" + url.PathEscape(projects.Items[0].ID)
	if err := rc.call(ctx, http.MethodGet, project+"/entitlements?limit=100", &entitlements); err != nil {
		return "", nil, nil, fmt.Errorf("list entitlements: %w", err)
	}
	if err := rc.call(ctx, http.MethodGet, project+"/products?limit=100", &products); err != nil {
		return "", nil, nil, fmt.Errorf("list products: %w", err)
	}
	rc.project, rc.ids, rc.products, rc.loadedAt = project, map[string]string{}, map[string]string{}, time.Now()
	for _, e := range entitlements.Items {
		rc.ids[e.LookupKey] = e.ID
	}
	for _, p := range products.Items {
		rc.products[p.ID] = p.StoreIdentifier
	}
	return rc.project, rc.ids, rc.products, nil
}

type grants struct {
	Entitlements list[catalogItem] `json:"entitlements"`
	Environment  string            `json:"environment"`
	Store        string            `json:"store"`
	ProductID    string            `json:"product_id"`
}

func (g grants) has(lookupKey string) bool {
	return slices.ContainsFunc(g.Entitlements.Items, func(e catalogItem) bool { return e.LookupKey == lookupKey })
}

type subscription struct {
	grants
	GivesAccess bool   `json:"gives_access"`
	Status      string `json:"status"`
	AutoRenewal string `json:"auto_renewal_status"`
	StoreID     string `json:"store_subscription_identifier"`
}

type activeEntitlement struct {
	EntitlementID string `json:"entitlement_id"`
	ExpiresAt     *int64 `json:"expires_at"`
}

type purchase struct {
	grants
	Status  string `json:"status"`
	StoreID string `json:"store_purchase_identifier"`
}

func (rc *RevenueCat) Subscriber(ctx context.Context, appUserID, lookupKey string) (*Entitlement, error) {
	project, ids, products, err := rc.catalog(ctx)
	if err != nil {
		return nil, err
	}
	customer := project + "/customers/" + url.PathEscape(appUserID)
	var c struct {
		Active list[activeEntitlement] `json:"active_entitlements"`
	}
	if err := rc.call(ctx, http.MethodGet, customer, &c); errors.Is(err, errNotFound) {
		return nil, nil
	} else if err != nil {
		return nil, fmt.Errorf("get customer: %w", err)
	}
	i := slices.IndexFunc(c.Active.Items, func(a activeEntitlement) bool { return a.EntitlementID == ids[lookupKey] })
	if i < 0 {
		return nil, nil
	}
	e := &Entitlement{Platform: "promotional", State: "active", EventAt: time.Now()}
	if ms := c.Active.Items[i].ExpiresAt; ms != nil {
		t := time.UnixMilli(*ms)
		e.ExpiresAt = &t
	}
	var subs list[subscription]
	if err := rc.call(ctx, http.MethodGet, customer+"/subscriptions?limit=100", &subs); err != nil {
		return nil, fmt.Errorf("list subscriptions: %w", err)
	}
	var source grants
	if j := slices.IndexFunc(subs.Items, func(s subscription) bool { return s.GivesAccess && s.has(lookupKey) }); j >= 0 {
		s := subs.Items[j]
		source, e.Token = s.grants, s.StoreID
		e.AutoRenew = s.AutoRenewal != "will_not_renew" && s.AutoRenewal != "will_pause" && s.Store != "promotional"
		switch {
		case s.Store == "promotional":
		case s.Status == "in_grace_period" || s.Status == "in_billing_retry":
			e.State = "billing_issue"
		case s.Status == "paused" || s.AutoRenewal == "will_pause":
			e.State = "paused"
		case s.AutoRenewal == "will_not_renew":
			e.State = "canceled"
		}
	} else {
		var buys list[purchase]
		if err := rc.call(ctx, http.MethodGet, customer+"/purchases?limit=100", &buys); err != nil {
			return nil, fmt.Errorf("list purchases: %w", err)
		}
		if j := slices.IndexFunc(buys.Items, func(p purchase) bool { return p.Status == "owned" && p.has(lookupKey) }); j >= 0 {
			source, e.Token = buys.Items[j].grants, buys.Items[j].StoreID
		}
	}
	e.Platform = cmp.Or(source.Store, e.Platform)
	e.Sandbox = source.Environment == "sandbox"
	e.ProductID, e.BasePlanID, _ = strings.Cut(cmp.Or(products[source.ProductID], source.ProductID), ":")
	raw, err := json.Marshal(map[string]any{"customer": c, "source": source})
	if err != nil {
		return nil, err
	}
	e.Raw = raw
	return e, nil
}

func (rc *RevenueCat) DeleteSubscriber(ctx context.Context, appUserID string) error {
	project, _, _, err := rc.catalog(ctx)
	if err != nil {
		return err
	}
	if err := rc.call(ctx, http.MethodDelete, project+"/customers/"+url.PathEscape(appUserID), nil); err != nil && !errors.Is(err, errNotFound) {
		return fmt.Errorf("delete customer: %w", err)
	}
	return nil
}

type event struct {
	ID               string   `json:"id"`
	Type             string   `json:"type"`
	AppUserID        string   `json:"app_user_id"`
	ProductID        string   `json:"product_id"`
	NewProductID     string   `json:"new_product_id"`
	EntitlementIDs   []string `json:"entitlement_ids"`
	ExpirationAtMs   *int64   `json:"expiration_at_ms"`
	GraceExpiresAtMs *int64   `json:"grace_period_expiration_at_ms"`
	Environment      string   `json:"environment"`
	EventTimestampMs int64    `json:"event_timestamp_ms"`
	Store            string   `json:"store"`
	TransactionID    string   `json:"original_transaction_id"`
	TransferredFrom  []string `json:"transferred_from"`
	TransferredTo    []string `json:"transferred_to"`
	raw              json.RawMessage
}

func parseEvent(body []byte) (event, error) {
	var envelope struct {
		Event json.RawMessage `json:"event"`
	}
	var ev event
	if json.Unmarshal(body, &envelope) != nil || json.Unmarshal(envelope.Event, &ev) != nil || ev.ID == "" || ev.Type == "" {
		return event{}, ErrBadEvent
	}
	ev.raw = envelope.Event
	return ev, nil
}

var eventStates = map[string]struct {
	state     string
	autoRenew bool
}{
	"INITIAL_PURCHASE":            {"active", true},
	"RENEWAL":                     {"active", true},
	"PRODUCT_CHANGE":              {"active", true},
	"UNCANCELLATION":              {"active", true},
	"SUBSCRIPTION_EXTENDED":       {"active", true},
	"NON_RENEWING_PURCHASE":       {"active", false},
	"TEMPORARY_ENTITLEMENT_GRANT": {"active", false},
	"CANCELLATION":                {"canceled", false},
	"BILLING_ISSUE":               {"billing_issue", true},
	"SUBSCRIPTION_PAUSED":         {"paused", false},
	"EXPIRATION":                  {"expired", false},
}

func (ev event) grants(entitlement string) bool {
	return slices.Contains(ev.EntitlementIDs, entitlement)
}

func (ev event) entitlement() (Entitlement, bool) {
	s, ok := eventStates[ev.Type]
	if !ok {
		return Entitlement{}, false
	}
	product, basePlan, _ := strings.Cut(cmp.Or(ev.NewProductID, ev.ProductID), ":")
	e := Entitlement{
		Platform:   strings.ToLower(ev.Store),
		ProductID:  product,
		BasePlanID: basePlan,
		Token:      ev.TransactionID,
		State:      s.state,
		AutoRenew:  s.autoRenew && ev.ExpirationAtMs != nil,
		Raw:        ev.raw,
		EventAt:    time.UnixMilli(ev.EventTimestampMs),
		Sandbox:    ev.Environment == "SANDBOX",
	}
	if ev.ExpirationAtMs != nil {
		ms := *ev.ExpirationAtMs
		if ev.GraceExpiresAtMs != nil {
			ms = max(ms, *ev.GraceExpiresAtMs)
		}
		t := time.UnixMilli(ms)
		e.ExpiresAt = &t
	}
	return e, true
}

func isUUID(s string) bool {
	if len(s) != 36 || s[8] != '-' || s[13] != '-' || s[18] != '-' || s[23] != '-' {
		return false
	}
	_, err := hex.DecodeString(strings.ReplaceAll(s, "-", ""))
	return err == nil
}
