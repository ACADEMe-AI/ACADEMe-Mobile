package auth

import (
	"context"
	"crypto"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"slices"
	"strings"
	"sync"
	"time"
)

const (
	GoogleCertsURL = "https://www.googleapis.com/oauth2/v3/certs"

	googleKeysTTL      = time.Hour
	googleKeysMinFetch = time.Minute
	googleClockSkew    = time.Minute
)

var (
	ErrGoogleToken       = errors.New("invalid google id token")
	ErrGoogleUnavailable = errors.New("google sign-in is not configured")
)

type GoogleIdentity struct {
	Subject    string
	Email      string
	GivenName  string
	FamilyName string
}

type GoogleVerifier interface {
	Verify(ctx context.Context, idToken string) (GoogleIdentity, error)
}

type GoogleIDTokens struct {
	clientIDs []string
	certsURL  string
	client    *http.Client

	mu        sync.Mutex
	keys      map[string]*rsa.PublicKey
	fetchedAt time.Time
}

func NewGoogleIDTokens(clientIDs []string, certsURL string, client *http.Client) *GoogleIDTokens {
	return &GoogleIDTokens{clientIDs: clientIDs, certsURL: certsURL, client: client}
}

type googleHeader struct {
	Alg string `json:"alg"`
	Kid string `json:"kid"`
}

type googleClaims struct {
	Iss           string `json:"iss"`
	Aud           string `json:"aud"`
	Sub           string `json:"sub"`
	Exp           int64  `json:"exp"`
	Email         string `json:"email"`
	EmailVerified bool   `json:"email_verified"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
}

func (g *GoogleIDTokens) Verify(ctx context.Context, idToken string) (GoogleIdentity, error) {
	parts := strings.Split(idToken, ".")
	if len(parts) != 3 {
		return GoogleIdentity{}, ErrGoogleToken
	}
	var header googleHeader
	if err := decodeSegment(parts[0], &header); err != nil || header.Alg != "RS256" || header.Kid == "" {
		return GoogleIdentity{}, ErrGoogleToken
	}
	signature, err := base64.RawURLEncoding.DecodeString(parts[2])
	if err != nil {
		return GoogleIdentity{}, ErrGoogleToken
	}
	key, err := g.key(ctx, header.Kid)
	if err != nil {
		return GoogleIdentity{}, err
	}
	digest := sha256.Sum256([]byte(parts[0] + "." + parts[1]))
	if rsa.VerifyPKCS1v15(key, crypto.SHA256, digest[:], signature) != nil {
		return GoogleIdentity{}, ErrGoogleToken
	}

	var claims googleClaims
	if err := decodeSegment(parts[1], &claims); err != nil {
		return GoogleIdentity{}, ErrGoogleToken
	}
	switch {
	case claims.Iss != "accounts.google.com" && claims.Iss != "https://accounts.google.com",
		!slices.Contains(g.clientIDs, claims.Aud),
		!time.Now().Add(-googleClockSkew).Before(time.Unix(claims.Exp, 0)),
		claims.Sub == "",
		claims.Email == "",
		!claims.EmailVerified:
		return GoogleIdentity{}, ErrGoogleToken
	}
	return GoogleIdentity{
		Subject:    claims.Sub,
		Email:      normalizeEmail(claims.Email),
		GivenName:  claims.GivenName,
		FamilyName: claims.FamilyName,
	}, nil
}

func (g *GoogleIDTokens) key(ctx context.Context, kid string) (*rsa.PublicKey, error) {
	g.mu.Lock()
	defer g.mu.Unlock()
	age := time.Since(g.fetchedAt)
	key, ok := g.keys[kid]
	if g.keys == nil || age >= googleKeysTTL || (!ok && age >= googleKeysMinFetch) {
		if err := g.fetchKeys(ctx); err != nil {
			return nil, err
		}
		key, ok = g.keys[kid]
	}
	if !ok {
		return nil, ErrGoogleToken
	}
	return key, nil
}

type jsonWebKeys struct {
	Keys []struct {
		Kid string `json:"kid"`
		Kty string `json:"kty"`
		N   string `json:"n"`
		E   string `json:"e"`
	} `json:"keys"`
}

func (g *GoogleIDTokens) fetchKeys(ctx context.Context) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, g.certsURL, http.NoBody) //nolint:gosec
	if err != nil {
		return fmt.Errorf("build google certs request: %w", err)
	}
	res, err := g.client.Do(req) //nolint:gosec
	if err != nil {
		return fmt.Errorf("fetch google certs: %w", err)
	}
	defer res.Body.Close() //nolint:errcheck
	if res.StatusCode != http.StatusOK {
		return fmt.Errorf("fetch google certs: status %d", res.StatusCode)
	}
	var set jsonWebKeys
	if err := json.NewDecoder(res.Body).Decode(&set); err != nil {
		return fmt.Errorf("decode google certs: %w", err)
	}
	keys := make(map[string]*rsa.PublicKey, len(set.Keys))
	for _, k := range set.Keys {
		if k.Kty != "RSA" {
			continue
		}
		n, errN := base64.RawURLEncoding.DecodeString(k.N)
		e, errE := base64.RawURLEncoding.DecodeString(k.E)
		if errN != nil || errE != nil || len(e) > 4 {
			continue
		}
		keys[k.Kid] = &rsa.PublicKey{N: new(big.Int).SetBytes(n), E: int(new(big.Int).SetBytes(e).Int64())}
	}
	g.keys = keys
	g.fetchedAt = time.Now()
	return nil
}

func decodeSegment(segment string, dst any) error {
	raw, err := base64.RawURLEncoding.DecodeString(segment)
	if err != nil {
		return err
	}
	return json.Unmarshal(raw, dst)
}
