package auth

import (
	"errors"
	"net/http"
	"testing"
	"testing/synctest"
	"time"
)

func TestRevokedAccessTokensAcrossInstances(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		store := newFakeStore()
		key := []byte("0123456789abcdef0123456789abcdef")
		this := NewService(store, key, nil, &fakeMailer{})
		other := NewService(store, key, nil, &fakeMailer{})
		a, tokens, err := this.SignUp(t.Context(), SignUpInput{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com", Password: "sunflower"})
		if err != nil {
			t.Fatal(err)
		}
		if _, err := this.Authenticate(t.Context(), tokens.AccessToken); err != nil {
			t.Fatalf("Authenticate before deletion = %v", err)
		}

		time.Sleep(time.Second)
		if _, err := other.DeleteAccount(t.Context(), a.ID, ""); err != nil {
			t.Fatal(err)
		}
		if _, err := other.Authenticate(t.Context(), tokens.AccessToken); !errors.Is(err, ErrInvalidToken) {
			t.Errorf("Authenticate on the revoking instance = %v, want ErrInvalidToken at once", err)
		}
		time.Sleep(revocationCheckTTL - 2*time.Second)
		if _, err := this.Authenticate(t.Context(), tokens.AccessToken); err != nil {
			t.Errorf("Authenticate on another instance inside the cache TTL = %v, want the cached pass", err)
		}
		time.Sleep(2 * time.Second)
		if _, err := this.Authenticate(t.Context(), tokens.AccessToken); !errors.Is(err, ErrInvalidToken) {
			t.Errorf("Authenticate on another instance after the cache TTL = %v, want ErrInvalidToken", err)
		}

		time.Sleep(time.Second)
		_, fresh, err := this.LogIn(t.Context(), "maya@example.com", "sunflower")
		if err != nil {
			t.Fatal(err)
		}
		if _, err := this.Authenticate(t.Context(), fresh.AccessToken); err != nil {
			t.Errorf("Authenticate with a token issued after the deletion = %v, want ok", err)
		}
	})
}

func TestRevocationCacheKeepsLatest(t *testing.T) {
	synctest.Test(t, func(t *testing.T) {
		r := newRevocations()
		later := time.Now()
		r.put("a", later, time.Now())
		if got := r.put("a", later.Add(-time.Hour), time.Now()); !got.Equal(later) {
			t.Errorf("put with a stale value = %v, want the later %v kept", got, later)
		}
		for i := range revocationSweepSize + 1 {
			r.put(string(rune(i)), later, time.Now())
		}
		time.Sleep(revocationCheckTTL)
		r.put("trigger", later, time.Now())
		if len(r.entries) != 1 {
			t.Errorf("entries after a sweep of stale ones = %d, want 1", len(r.entries))
		}
	})
}

func TestGoogleLinkRevokesAccessTokens(t *testing.T) {
	e := newResetEnv(t)
	_, body := e.post(t, "/auth/sign-up", maya)
	access, _ := tokensOf(t, body)
	status, body := e.post(t, "/auth/google", `{"idToken":"maya"}`)
	if status != http.StatusOK {
		t.Fatalf("google sign-in = %d %v", status, body)
	}
	linked, _ := tokensOf(t, body)
	if got := e.me(t, access); got != http.StatusUnauthorized {
		t.Errorf("GET /me with a pre-link access token = %d, want 401", got)
	}
	if got := e.me(t, linked); got != http.StatusOK {
		t.Errorf("GET /me with the linked access token = %d, want 200", got)
	}
}

func TestAccessTokensDifferWithinASecond(t *testing.T) {
	key := []byte("0123456789abcdef0123456789abcdef")
	now := time.Unix(1_800_000_000, 0)
	if signAccessToken(key, "a", now) == signAccessToken(key, "a", now.Add(time.Millisecond)) {
		t.Error("access tokens issued a millisecond apart are identical")
	}
}
