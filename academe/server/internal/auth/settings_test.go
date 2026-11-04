package auth

import (
	"net/http"
	"strconv"
	"testing"
)

func TestChangePassword(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	access, refresh := tokensOf(t, body)
	_, other := call(t, srv, "POST", "/auth/log-in", "", `{"email":"maya.rao@example.com","password":"sunflower"}`)
	otherAccess, otherRefresh := tokensOf(t, other)

	tests := []struct {
		name       string
		body       string
		wantStatus int
		wantCode   string
	}{
		{"short new password", `{"currentPassword":"sunflower","newPassword":"short"}`, http.StatusUnprocessableEntity, "invalid_password"},
		{"wrong current password", `{"currentPassword":"sunflowers","newPassword":"marigold1"}`, http.StatusForbidden, "wrong_password"},
		{"missing current password", `{"newPassword":"marigold1"}`, http.StatusForbidden, "wrong_password"},
		{"unknown field", `{"password":"marigold1"}`, http.StatusBadRequest, ""},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			status, body := call(t, srv, "POST", "/me/password", access, tc.body)
			if status != tc.wantStatus || (tc.wantCode != "" && errorCode(body) != tc.wantCode) {
				t.Errorf("POST /me/password %s = %d %q, want %d %q", tc.body, status, errorCode(body), tc.wantStatus, tc.wantCode)
			}
		})
	}

	status, body := call(t, srv, "POST", "/me/password", access, `{"currentPassword":"sunflower","newPassword":"marigold1"}`)
	if status != http.StatusOK {
		t.Fatalf("POST /me/password = %d %v, want 200", status, body)
	}
	fresh, _ := tokensOf(t, body)
	if status, _ := call(t, srv, "GET", "/me", fresh, ""); status != http.StatusOK {
		t.Errorf("GET /me with the new token = %d, want 200", status)
	}
	for name, token := range map[string]string{"this device's old token": access, "another device's token": otherAccess} {
		if status, _ := call(t, srv, "GET", "/me", token, ""); status != http.StatusUnauthorized {
			t.Errorf("GET /me with %s = %d, want 401", name, status)
		}
	}
	for _, token := range []string{refresh, otherRefresh} {
		if status, _ := call(t, srv, "POST", "/auth/refresh", "", `{"refreshToken":"`+token+`"}`); status != http.StatusUnauthorized {
			t.Errorf("refresh with a revoked session = %d, want 401", status)
		}
	}
	if status, _ := call(t, srv, "POST", "/auth/log-in", "", `{"email":"maya.rao@example.com","password":"sunflower"}`); status != http.StatusUnauthorized {
		t.Errorf("log-in with the old password = %d, want 401", status)
	}
	if status, _ := call(t, srv, "POST", "/auth/log-in", "", `{"email":"maya.rao@example.com","password":"marigold1"}`); status != http.StatusOK {
		t.Errorf("log-in with the new password = %d, want 200", status)
	}
}

func TestChangePasswordThrottlesGuesses(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	access, _ := tokensOf(t, body)
	for i := range passwordChecksPerHour {
		guess := `{"currentPassword":"guess` + strconv.Itoa(i) + `","newPassword":"marigold1"}`
		if status, body := call(t, srv, "POST", "/me/password", access, guess); errorCode(body) != "wrong_password" {
			t.Fatalf("guess %d = %d %q, want wrong_password", i, status, errorCode(body))
		}
	}
	status, body := call(t, srv, "POST", "/me/password", access, `{"currentPassword":"sunflower","newPassword":"marigold1"}`)
	if status != http.StatusTooManyRequests || errorCode(body) != "too_many_requests" {
		t.Errorf("POST /me/password after %d guesses = %d %q, want 429 too_many_requests", passwordChecksPerHour, status, errorCode(body))
	}
}

func TestSetPasswordOnGoogleAccount(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`)
	access, _ := tokensOf(t, body)

	status, body := call(t, srv, "POST", "/me/password", access, `{"newPassword":"marigold1"}`)
	if status != http.StatusOK || body["account"].(map[string]any)["hasPassword"] != true {
		t.Fatalf("set a password on a Google account = %d %v, want 200 with hasPassword", status, body)
	}
	if status, _ := call(t, srv, "POST", "/auth/log-in", "", `{"email":"ada@gmail.com","password":"marigold1"}`); status != http.StatusOK {
		t.Errorf("email log-in after setting a password = %d, want 200", status)
	}
	if status, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`); status != http.StatusOK || body["account"].(map[string]any)["hasPassword"] != true {
		t.Errorf("Google sign-in after setting a password = %d %v, want the password kept", status, body)
	}
}

func TestLinkAndUnlinkGoogle(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	access, _ := tokensOf(t, body)
	_, adaBody := call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`)
	adaAccess, _ := tokensOf(t, adaBody)

	if _, body := call(t, srv, "GET", "/me", access, ""); body["hasPassword"] != true || body["googleEmail"] != nil {
		t.Errorf("GET /me before linking = %v, want hasPassword and no googleEmail", body)
	}
	if status, body := call(t, srv, "POST", "/me/google", access, `{"idToken":"forged"}`); status != http.StatusUnauthorized || errorCode(body) != "invalid_google_token" {
		t.Errorf("link with a forged token = %d %q, want 401 invalid_google_token", status, errorCode(body))
	}
	if status, body := call(t, srv, "POST", "/me/google", access, `{"idToken":"new-student"}`); status != http.StatusConflict || errorCode(body) != "google_taken" {
		t.Errorf("link Ada's Google to Maya = %d %q, want 409 google_taken", status, errorCode(body))
	}
	status, body := call(t, srv, "POST", "/me/google", access, `{"idToken":"maya"}`)
	if status != http.StatusOK || body["googleEmail"] != "maya.rao@example.com" || body["hasPassword"] != true {
		t.Fatalf("link Google = %d %v, want 200 with googleEmail and the password kept", status, body)
	}
	if status, body := call(t, srv, "GET", "/me", access, ""); status != http.StatusOK || body["googleEmail"] != "maya.rao@example.com" {
		t.Errorf("GET /me after linking = %d %v, want the same token still working and googleEmail", status, body)
	}
	if status, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"maya"}`); status != http.StatusOK || body["account"].(map[string]any)["hasPassword"] != true {
		t.Errorf("Google sign-in after linking = %d %v, want Maya with her password kept", status, body)
	}

	status, body = call(t, srv, "DELETE", "/me/google", access, "")
	if status != http.StatusOK || body["googleEmail"] != nil {
		t.Errorf("unlink Google = %d %v, want 200 without googleEmail", status, body)
	}
	if status, body := call(t, srv, "DELETE", "/me/google", adaAccess, ""); status != http.StatusConflict || errorCode(body) != "password_required" {
		t.Errorf("unlink a Google-only account = %d %q, want 409 password_required", status, errorCode(body))
	}
	if status, _ := call(t, srv, "DELETE", "/me/google", "", ""); status != http.StatusUnauthorized {
		t.Errorf("unlink without a token = %d, want 401", status)
	}
}

func TestLinkGoogleUnavailable(t *testing.T) {
	srv := newTestServerWith(t, nil)
	_, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	access, _ := tokensOf(t, body)
	if status, body := call(t, srv, "POST", "/me/google", access, `{"idToken":"maya"}`); status != http.StatusServiceUnavailable || errorCode(body) != "google_unavailable" {
		t.Errorf("link without Google configured = %d %q, want 503 google_unavailable", status, errorCode(body))
	}
}
