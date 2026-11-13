package auth

import (
	"crypto"
	"crypto/rand"
	"crypto/rsa"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"errors"
	"math/big"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"
	"time"
)

type googleSigner struct {
	key *rsa.PrivateKey
	kid string
}

func (g googleSigner) sign(t *testing.T, header, claims map[string]any) string {
	t.Helper()
	segment := func(v map[string]any) string {
		raw, err := json.Marshal(v)
		if err != nil {
			t.Fatal(err)
		}
		return base64.RawURLEncoding.EncodeToString(raw)
	}
	unsigned := segment(header) + "." + segment(claims)
	digest := sha256.Sum256([]byte(unsigned))
	signature, err := rsa.SignPKCS1v15(rand.Reader, g.key, crypto.SHA256, digest[:])
	if err != nil {
		t.Fatal(err)
	}
	return unsigned + "." + base64.RawURLEncoding.EncodeToString(signature)
}

func newGoogleCerts(t *testing.T, signers ...googleSigner) (*httptest.Server, *atomic.Int32) {
	t.Helper()
	var fetches atomic.Int32
	var keys []map[string]string
	for _, s := range signers {
		keys = append(keys, map[string]string{
			"kid": s.kid,
			"kty": "RSA",
			"alg": "RS256",
			"n":   base64.RawURLEncoding.EncodeToString(s.key.N.Bytes()),
			"e":   base64.RawURLEncoding.EncodeToString(big.NewInt(int64(s.key.E)).Bytes()),
		})
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		fetches.Add(1)
		_ = json.NewEncoder(w).Encode(map[string]any{"keys": keys})
	}))
	t.Cleanup(srv.Close)
	return srv, &fetches
}

func newSigner(t *testing.T, kid string) googleSigner {
	t.Helper()
	key, err := rsa.GenerateKey(rand.Reader, 2048)
	if err != nil {
		t.Fatal(err)
	}
	return googleSigner{key: key, kid: kid}
}

func TestGoogleIDTokensVerify(t *testing.T) {
	google := newSigner(t, "key-1")
	stranger := newSigner(t, "key-1")
	certs, _ := newGoogleCerts(t, google)
	verifier := NewGoogleIDTokens([]string{"academe-web"}, certs.URL, certs.Client())

	header := map[string]any{"alg": "RS256", "kid": "key-1"}
	claims := func(change func(map[string]any)) map[string]any {
		c := map[string]any{
			"iss":            "https://accounts.google.com",
			"aud":            "academe-web",
			"sub":            "1234",
			"exp":            time.Now().Add(time.Hour).Unix(),
			"email":          "Ada@Gmail.com",
			"email_verified": true,
			"given_name":     "Ada",
			"family_name":    "Lovelace",
		}
		if change != nil {
			change(c)
		}
		return c
	}
	valid := google.sign(t, header, claims(nil))

	tests := []struct {
		name  string
		token string
	}{
		{name: "other audience", token: google.sign(t, header, claims(func(c map[string]any) { c["aud"] = "someone-else" }))},
		{name: "other issuer", token: google.sign(t, header, claims(func(c map[string]any) { c["iss"] = "https://evil.example" }))},
		{name: "expired", token: google.sign(t, header, claims(func(c map[string]any) { c["exp"] = time.Now().Add(-2 * time.Minute).Unix() }))},
		{name: "unverified email", token: google.sign(t, header, claims(func(c map[string]any) { c["email_verified"] = false }))},
		{name: "no subject", token: google.sign(t, header, claims(func(c map[string]any) { c["sub"] = "" }))},
		{name: "signed by someone else", token: stranger.sign(t, header, claims(nil))},
		{name: "unknown key", token: google.sign(t, map[string]any{"alg": "RS256", "kid": "key-9"}, claims(nil))},
		{name: "alg none", token: google.sign(t, map[string]any{"alg": "none", "kid": "key-1"}, claims(nil))},
		{name: "tampered claims", token: valid[:len(valid)-8] + "AAAAAAAA"},
		{name: "not a jwt", token: "hello"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			if got, err := verifier.Verify(t.Context(), tc.token); !errors.Is(err, ErrGoogleToken) {
				t.Errorf("Verify = %+v, %v, want ErrGoogleToken", got, err)
			}
		})
	}

	got, err := verifier.Verify(t.Context(), valid)
	want := GoogleIdentity{Subject: "1234", Email: "ada@gmail.com", GivenName: "Ada", FamilyName: "Lovelace"}
	if err != nil || got != want {
		t.Errorf("Verify(valid) = %+v, %v, want %+v", got, err, want)
	}
}

func TestGoogleIDTokensCachesKeys(t *testing.T) {
	google := newSigner(t, "key-1")
	certs, fetches := newGoogleCerts(t, google)
	verifier := NewGoogleIDTokens([]string{"academe-web"}, certs.URL, certs.Client())
	token := func(kid string) string {
		return google.sign(t, map[string]any{"alg": "RS256", "kid": kid}, map[string]any{
			"iss": "accounts.google.com", "aud": "academe-web", "sub": "1",
			"exp": time.Now().Add(time.Hour).Unix(), "email": "a@b.co", "email_verified": true,
		})
	}
	for range 3 {
		if _, err := verifier.Verify(t.Context(), token("key-1")); err != nil {
			t.Fatalf("Verify = %v", err)
		}
	}
	for range 3 {
		_, _ = verifier.Verify(t.Context(), token("unknown"))
	}
	if got := fetches.Load(); got != 1 {
		t.Errorf("certs fetched %d times, want 1", got)
	}
}
