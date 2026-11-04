package auth

import (
	"errors"
	"testing"
	"time"
)

func TestVerifyAccessToken(t *testing.T) {
	key := []byte("0123456789abcdef0123456789abcdef")
	now := time.Unix(1_800_000_000, 0)
	valid := signAccessToken(key, "account-1", now.Add(-accessTokenTTL+time.Minute))

	tests := []struct {
		name  string
		key   []byte
		token string
		now   time.Time
		want  string
	}{
		{name: "valid", key: key, token: valid, now: now, want: "account-1"},
		{name: "expired", key: key, token: valid, now: now.Add(time.Minute)},
		{name: "other key", key: []byte("another key, also thirty-two by"), token: valid, now: now},
		{name: "account swapped", key: key, token: "account-2" + valid[len("account-1"):], now: now},
		{name: "no signature", key: key, token: "account-1", now: now},
		{name: "empty", key: key, token: "", now: now},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, _, err := verifyAccessToken(tc.key, tc.token, tc.now)
			if tc.want == "" {
				if !errors.Is(err, ErrInvalidToken) {
					t.Errorf("verifyAccessToken(%q) = %q, %v, want ErrInvalidToken", tc.token, got, err)
				}
				return
			}
			if err != nil || got != tc.want {
				t.Errorf("verifyAccessToken(%q) = %q, %v, want %q", tc.token, got, err, tc.want)
			}
		})
	}
}
