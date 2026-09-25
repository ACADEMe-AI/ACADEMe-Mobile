package billing

import (
	"cmp"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"slices"
	"strings"
	"time"
)

const (
	RevenueCatAPI = "https://api.revenuecat.com"
	EntitlementID = "pro"
)

type RevenueCat struct {
	secretKey string
	apiURL    string
	client    *http.Client
}

func NewRevenueCat(secretKey, apiURL string, client *http.Client) *RevenueCat {
	return &RevenueCat{secretKey: secretKey, apiURL: apiURL, client: client}
}

type subscriberResponse struct {
	Subscriber struct {
		Entitlements map[string]struct {
			ExpiresDate            *time.Time `json:"expires_date"`
			GracePeriodExpiresDate *time.Time `json:"grace_period_expires_date"`
			ProductIdentifier      string     `json:"product_identifier"`
		} `json:"entitlements"`
		Subscriptions map[string]struct {
			Store                   string     `json:"store"`
			ProductPlanIdentifier   string     `json:"product_plan_identifier"`
			StoreTransactionID      string     `json:"store_transaction_id"`
			UnsubscribeDetectedAt   *time.Time `json:"unsubscribe_detected_at"`
			BillingIssuesDetectedAt *time.Time `json:"billing_issues_detected_at"`
		} `json:"subscriptions"`
	} `json:"subscriber"`
}

func (rc *RevenueCat) Subscriber(ctx context.Context, appUserID string) (*Entitlement, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, rc.apiURL+"/v1/subscribers/"+url.PathEscape(appUserID), http.NoBody)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "Bearer "+rc.secretKey)
	resp, err := rc.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrStore, err)
	}
	defer resp.Body.Close() //nolint:errcheck
	body, err := io.ReadAll(io.LimitReader(resp.Body, 1<<20))
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrStore, err)
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("%w: status %d", ErrStore, resp.StatusCode)
	}
	var out subscriberResponse
	if err := json.Unmarshal(body, &out); err != nil {
		return nil, fmt.Errorf("%w: %w", ErrStore, err)
	}
	pro, ok := out.Subscriber.Entitlements[EntitlementID]
	if !ok {
		return nil, nil
	}
	product, basePlan, _ := strings.Cut(pro.ProductIdentifier, ":")
	sub, ok := out.Subscriber.Subscriptions[pro.ProductIdentifier]
	if !ok {
		sub = out.Subscriber.Subscriptions[product]
	}
	e := &Entitlement{
		Platform:   sub.Store,
		ProductID:  product,
		BasePlanID: cmp.Or(basePlan, sub.ProductPlanIdentifier),
		Token:      sub.StoreTransactionID,
		State:      "active",
		ExpiresAt:  pro.ExpiresDate,
		AutoRenew:  sub.UnsubscribeDetectedAt == nil && sub.Store != "promotional" && pro.ExpiresDate != nil,
		Raw:        body,
		EventAt:    time.Now(),
	}
	if g := pro.GracePeriodExpiresDate; g != nil && e.ExpiresAt != nil && g.After(*e.ExpiresAt) {
		e.ExpiresAt = g
	}
	switch {
	case sub.BillingIssuesDetectedAt != nil:
		e.State = "billing_issue"
	case sub.UnsubscribeDetectedAt != nil:
		e.State = "canceled"
	}
	return e, nil
}

func (rc *RevenueCat) DeleteSubscriber(ctx context.Context, appUserID string) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodDelete, rc.apiURL+"/v1/subscribers/"+url.PathEscape(appUserID), http.NoBody)
	if err != nil {
		return err
	}
	req.Header.Set("Authorization", "Bearer "+rc.secretKey)
	resp, err := rc.client.Do(req)
	if err != nil {
		return fmt.Errorf("%w: %w", ErrStore, err)
	}
	defer resp.Body.Close() //nolint:errcheck
	if resp.StatusCode != http.StatusOK && resp.StatusCode != http.StatusNotFound {
		return fmt.Errorf("%w: delete status %d", ErrStore, resp.StatusCode)
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
	"INITIAL_PURCHASE":    {"active", true},
	"RENEWAL":             {"active", true},
	"PRODUCT_CHANGE":      {"active", true},
	"UNCANCELLATION":      {"active", true},
	"CANCELLATION":        {"canceled", false},
	"BILLING_ISSUE":       {"billing_issue", true},
	"SUBSCRIPTION_PAUSED": {"paused", false},
	"EXPIRATION":          {"expired", false},
}

func (ev event) grantsPro() bool {
	return slices.Contains(ev.EntitlementIDs, EntitlementID)
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
	}
	if ev.ExpirationAtMs != nil {
		t := time.UnixMilli(*ev.ExpirationAtMs)
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
