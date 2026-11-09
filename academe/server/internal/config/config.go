package config

import (
	"cmp"
	"encoding/base64"
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
)

type Config struct {
	Addr            string
	DatabaseURL     string
	TokenKey        []byte
	GoogleClientIDs []string
	AIProvider      string
	GoogleProject   string
	GoogleLocation  string
	GoogleModel     string
	GoogleProcessor string
	SarvamAPIKey    string
	SarvamModel     string
	ClientIPHeader  string
	ResendAPIKey    string
	EmailFrom       string
	EmailDev        bool
	AndroidCerts    []string

	RevenueCatSecretKey   string
	RevenueCatWebhookAuth string
	FreeLimits            map[string]int
	AuthLimitScale        int
	BillingTesters        []string
	RevenueCatEntitlement string

	MinBuild         int
	RecommendedBuild int
	UpdateMessage    string
	UpdateURL        string
}

func FromEnv() (Config, error) {
	port := os.Getenv("PORT")
	if port != "" {
		port = ":" + port
	}
	c := Config{
		Addr:            cmp.Or(os.Getenv("ACADEME_ADDR"), port, ":8080"),
		ClientIPHeader:  os.Getenv("ACADEME_CLIENT_IP_HEADER"),
		DatabaseURL:     os.Getenv("ACADEME_DATABASE_URL"),
		AIProvider:      cmp.Or(os.Getenv("ACADEME_AI_PROVIDER"), "google"),
		GoogleProject:   os.Getenv("ACADEME_GOOGLE_PROJECT"),
		GoogleLocation:  cmp.Or(os.Getenv("ACADEME_GOOGLE_LOCATION"), "asia-south1"),
		GoogleModel:     cmp.Or(os.Getenv("ACADEME_GOOGLE_MODEL"), "gemini-3.5-flash-lite"),
		GoogleProcessor: os.Getenv("ACADEME_GOOGLE_DOCUMENT_PROCESSOR"),
		SarvamAPIKey:    os.Getenv("ACADEME_SARVAM_API_KEY"),
		SarvamModel:     cmp.Or(os.Getenv("ACADEME_SARVAM_MODEL"), "sarvam-105b"),
		ResendAPIKey:    os.Getenv("ACADEME_RESEND_API_KEY"),
		EmailFrom:       os.Getenv("ACADEME_EMAIL_FROM"),
		EmailDev:        os.Getenv("ACADEME_EMAIL_DEV") == "1",
	}
	if c.DatabaseURL == "" {
		return Config{}, errors.New("ACADEME_DATABASE_URL is not set")
	}
	key, err := base64.StdEncoding.DecodeString(os.Getenv("ACADEME_TOKEN_KEY"))
	if err != nil || len(key) < 32 {
		return Config{}, errors.New("ACADEME_TOKEN_KEY must be 32+ bytes, base64-encoded")
	}
	c.TokenKey = key
	for id := range strings.SplitSeq(os.Getenv("ACADEME_GOOGLE_CLIENT_IDS"), ",") {
		if id = strings.TrimSpace(id); id != "" {
			c.GoogleClientIDs = append(c.GoogleClientIDs, id)
		}
	}
	for cert := range strings.SplitSeq(os.Getenv("ACADEME_ANDROID_CERT_SHA256"), ",") {
		if cert = strings.ToUpper(strings.TrimSpace(cert)); cert != "" {
			c.AndroidCerts = append(c.AndroidCerts, cert)
		}
	}
	c.AuthLimitScale = 1
	if raw := os.Getenv("ACADEME_AUTH_LIMIT_SCALE"); raw != "" {
		n, err := strconv.Atoi(raw)
		if err != nil || n < 1 {
			return Config{}, errors.New("ACADEME_AUTH_LIMIT_SCALE must be a whole number of 1 or more")
		}
		c.AuthLimitScale = n
	}
	if err := c.billing(); err != nil {
		return Config{}, err
	}
	c.MinBuild = parseNonNegInt(os.Getenv("ACADEME_MIN_BUILD"))
	c.RecommendedBuild = parseNonNegInt(os.Getenv("ACADEME_RECOMMENDED_BUILD"))
	c.UpdateMessage = os.Getenv("ACADEME_UPDATE_MESSAGE")
	c.UpdateURL = os.Getenv("ACADEME_UPDATE_URL")
	return c, nil
}

func parseNonNegInt(raw string) int {
	n, _ := strconv.Atoi(strings.TrimSpace(raw))
	if n < 0 {
		return 0
	}
	return n
}

func (c *Config) billing() error {
	c.RevenueCatSecretKey = os.Getenv("ACADEME_REVENUECAT_SECRET_KEY")
	c.RevenueCatWebhookAuth = os.Getenv("ACADEME_REVENUECAT_WEBHOOK_AUTH")
	c.RevenueCatEntitlement = os.Getenv("ACADEME_REVENUECAT_ENTITLEMENT")
	c.FreeLimits = map[string]int{"askme": 10, "scan": 3, "check": 1, "lessons": 0}
	for id := range strings.SplitSeq(os.Getenv("ACADEME_BILLING_TESTERS"), ",") {
		if id = strings.TrimSpace(id); id != "" {
			c.BillingTesters = append(c.BillingTesters, id)
		}
	}
	for pair := range strings.SplitSeq(os.Getenv("ACADEME_FREE_LIMITS"), ",") {
		if pair = strings.TrimSpace(pair); pair == "" {
			continue
		}
		feature, value, _ := strings.Cut(pair, "=")
		n, err := strconv.Atoi(value)
		if err != nil {
			return fmt.Errorf("ACADEME_FREE_LIMITS: %q is not feature=count", pair)
		}
		if n < 0 {
			delete(c.FreeLimits, feature)
		} else {
			c.FreeLimits[feature] = n
		}
	}
	return nil
}
