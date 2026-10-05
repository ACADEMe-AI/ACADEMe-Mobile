package config_test

import (
	"testing"

	"academe/server/internal/config"
)

func TestAddr(t *testing.T) {
	tests := []struct {
		name, addr, port, want string
	}{
		{"default", "", "", ":8080"},
		{"railway port", "", "9000", ":9000"},
		{"explicit addr wins", "127.0.0.1:7000", "9000", "127.0.0.1:7000"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Setenv("ACADEME_DATABASE_URL", "postgres://x")
			t.Setenv("ACADEME_TOKEN_KEY", "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=")
			t.Setenv("ACADEME_ADDR", tt.addr)
			t.Setenv("PORT", tt.port)
			c, err := config.FromEnv()
			if err != nil {
				t.Fatal(err)
			}
			if c.Addr != tt.want {
				t.Errorf("Addr = %q, want %q", c.Addr, tt.want)
			}
		})
	}
}

func TestAuthLimitScale(t *testing.T) {
	t.Setenv("ACADEME_DATABASE_URL", "postgres://x")
	t.Setenv("ACADEME_TOKEN_KEY", "MDEyMzQ1Njc4OWFiY2RlZjAxMjM0NTY3ODlhYmNkZWY=")
	for raw, want := range map[string]int{"": 1, "50": 50} {
		t.Setenv("ACADEME_AUTH_LIMIT_SCALE", raw)
		c, err := config.FromEnv()
		if err != nil || c.AuthLimitScale != want {
			t.Errorf("FromEnv() with scale %q = %d, %v; want %d", raw, c.AuthLimitScale, err, want)
		}
	}
	t.Setenv("ACADEME_AUTH_LIMIT_SCALE", "0")
	if _, err := config.FromEnv(); err == nil {
		t.Error("FromEnv() with scale 0 succeeded, want an error")
	}
}
