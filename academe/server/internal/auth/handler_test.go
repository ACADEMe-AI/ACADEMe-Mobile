package auth

import (
	"encoding/json"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/google/go-cmp/cmp"

	"academe/server/internal/httpx"
)

var testGoogle = fakeGoogle{
	"new-student": {Subject: "g-1", Email: "ada@gmail.com", GivenName: "Ada", FamilyName: "Lovelace"},
	"maya":        {Subject: "g-2", Email: "maya.rao@example.com", GivenName: "Maya", FamilyName: "R"},
}

func newTestServer(t *testing.T) *httptest.Server {
	t.Helper()
	return newTestServerWith(t, testGoogle)
}

func newTestServerWith(t *testing.T, google GoogleVerifier) *httptest.Server {
	t.Helper()
	logger := slog.New(slog.DiscardHandler)
	mux := http.NewServeMux()
	RegisterRoutes(mux, logger, NewService(newFakeStore(), []byte("0123456789abcdef0123456789abcdef"), google, &fakeMailer{}))
	srv := httptest.NewServer(httpx.WithRequestID(httpx.Recover(logger, mux)))
	t.Cleanup(srv.Close)
	return srv
}

func call(t *testing.T, srv *httptest.Server, method, path, token, body string) (int, map[string]any) {
	t.Helper()
	req, err := http.NewRequestWithContext(t.Context(), method, srv.URL+path, strings.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	if token != "" {
		req.Header.Set("Authorization", "Bearer "+token)
	}
	res, err := srv.Client().Do(req)
	if err != nil {
		t.Fatal(err)
	}
	raw, err := io.ReadAll(res.Body)
	if closeErr := res.Body.Close(); err == nil {
		err = closeErr
	}
	if err != nil {
		t.Fatal(err)
	}
	var got map[string]any
	if len(raw) > 0 {
		if err := json.Unmarshal(raw, &got); err != nil {
			t.Fatalf("%s %s: body %q is not JSON: %v", method, path, raw, err)
		}
	}
	return res.StatusCode, got
}

func errorCode(body map[string]any) string {
	e, _ := body["error"].(map[string]any)
	code, _ := e["code"].(string)
	return code
}

const maya = `{"firstName":" Maya ","lastName":"Rao","email":"Maya.Rao@Example.com","password":"sunflower"}`

func TestSignUp(t *testing.T) {
	tests := []struct {
		name       string
		body       string
		wantStatus int
		wantCode   string
	}{
		{name: "missing first name", body: `{"firstName":" ","lastName":"Rao","email":"a@b.co","password":"sunflower"}`,
			wantStatus: 422, wantCode: "invalid_firstName"},
		{name: "bad email", body: `{"firstName":"Maya","lastName":"Rao","email":"maya","password":"sunflower"}`,
			wantStatus: 422, wantCode: "invalid_email"},
		{name: "named email", body: `{"firstName":"Maya","lastName":"Rao","email":"Maya <a@b.co>","password":"sunflower"}`,
			wantStatus: 422, wantCode: "invalid_email"},
		{name: "short password", body: `{"firstName":"Maya","lastName":"Rao","email":"a@b.co","password":"1234567"}`,
			wantStatus: 422, wantCode: "invalid_password"},
		{name: "unknown field", body: `{"firstName":"Maya","role":"admin"}`,
			wantStatus: 400, wantCode: "invalid_json"},
		{name: "two objects", body: maya + maya,
			wantStatus: 400, wantCode: "invalid_json"},
		{name: "not json", body: `hello`,
			wantStatus: 400, wantCode: "invalid_json"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			status, body := call(t, newTestServer(t), "POST", "/auth/sign-up", "", tc.body)
			if status != tc.wantStatus || errorCode(body) != tc.wantCode {
				t.Errorf("sign-up %s = %d %q, want %d %q", tc.body, status, errorCode(body), tc.wantStatus, tc.wantCode)
			}
		})
	}
}

func TestSessionLifecycle(t *testing.T) {
	srv := newTestServer(t)

	status, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	if status != http.StatusCreated {
		t.Fatalf("sign-up = %d %v, want 201", status, body)
	}
	wantAccount := map[string]any{
		"id": "account-1", "firstName": "Maya", "lastName": "Rao", "email": "maya.rao@example.com",
		"hasPassword": true,
	}
	if diff := cmp.Diff(wantAccount, body["account"]); diff != "" {
		t.Errorf("sign-up account mismatch (-want +got):\n%s", diff)
	}

	if status, body := call(t, srv, "POST", "/auth/sign-up", "", maya); status != http.StatusConflict || errorCode(body) != "email_taken" {
		t.Errorf("second sign-up = %d %q, want 409 email_taken", status, errorCode(body))
	}

	for _, password := range []string{"sunflowers", ""} {
		login := `{"email":"maya.rao@example.com","password":"` + password + `"}`
		if status, body := call(t, srv, "POST", "/auth/log-in", "", login); status != http.StatusUnauthorized || errorCode(body) != "wrong_credentials" {
			t.Errorf("log-in with %q = %d %q, want 401 wrong_credentials", password, status, errorCode(body))
		}
	}
	if status, body := call(t, srv, "POST", "/auth/log-in", "", `{"email":"nobody@example.com","password":"sunflower"}`); status != http.StatusUnauthorized || errorCode(body) != "wrong_credentials" {
		t.Errorf("log-in unknown email = %d %q, want 401 wrong_credentials", status, errorCode(body))
	}

	status, body = call(t, srv, "POST", "/auth/log-in", "", `{"email":" MAYA.RAO@example.com","password":"sunflower"}`)
	if status != http.StatusOK {
		t.Fatalf("log-in = %d %v, want 200", status, body)
	}
	tokens := body["tokens"].(map[string]any)
	access, refresh := tokens["accessToken"].(string), tokens["refreshToken"].(string)

	if status, body := call(t, srv, "GET", "/me", access, ""); status != http.StatusOK || body["email"] != "maya.rao@example.com" {
		t.Errorf("me = %d %v, want 200 with Maya's account", status, body)
	}
	if status, _ := call(t, srv, "GET", "/me", "", ""); status != http.StatusUnauthorized {
		t.Errorf("me without a token = %d, want 401", status)
	}

	status, body = call(t, srv, "POST", "/auth/refresh", "", `{"refreshToken":"`+refresh+`"}`)
	if status != http.StatusOK || body["refreshToken"] == refresh {
		t.Fatalf("refresh = %d %v, want 200 with a new refresh token", status, body)
	}
	rotated := body["refreshToken"].(string)
	if status, body := call(t, srv, "POST", "/auth/refresh", "", `{"refreshToken":"`+refresh+`"}`); status != http.StatusUnauthorized || errorCode(body) != "invalid_token" {
		t.Errorf("reusing a rotated refresh token = %d %q, want 401 invalid_token", status, errorCode(body))
	}

	if status, _ := call(t, srv, "POST", "/auth/log-out", "", `{"refreshToken":"`+rotated+`"}`); status != http.StatusNoContent {
		t.Errorf("log-out = %d, want 204", status)
	}
	if status, _ := call(t, srv, "POST", "/auth/refresh", "", `{"refreshToken":"`+rotated+`"}`); status != http.StatusUnauthorized {
		t.Errorf("refresh after log-out = %d, want 401", status)
	}
}

func tokensOf(t *testing.T, body map[string]any) (access, refresh string) {
	t.Helper()
	tokens, ok := body["tokens"].(map[string]any)
	if !ok {
		t.Fatalf("no tokens in %v", body)
	}
	return tokens["accessToken"].(string), tokens["refreshToken"].(string)
}

func TestGoogleSignIn(t *testing.T) {
	srv := newTestServer(t)

	status, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`)
	if status != http.StatusOK || body["created"] != true {
		t.Fatalf("first google sign-in = %d %v, want 200 created", status, body)
	}
	wantAccount := map[string]any{
		"id": "account-1", "firstName": "Ada", "lastName": "Lovelace", "email": "ada@gmail.com",
		"hasPassword": false, "googleEmail": "ada@gmail.com",
	}
	if diff := cmp.Diff(wantAccount, body["account"]); diff != "" {
		t.Errorf("google account mismatch (-want +got):\n%s", diff)
	}

	status, body = call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`)
	if status != http.StatusOK || body["created"] != false || body["account"].(map[string]any)["id"] != "account-1" {
		t.Errorf("second google sign-in = %d %v, want 200 same account, not created", status, body)
	}

	if status, body := call(t, srv, "POST", "/auth/log-in", "", `{"email":"ada@gmail.com","password":"anything1"}`); status != http.StatusUnauthorized || errorCode(body) != "wrong_credentials" {
		t.Errorf("password log-in to a google-only account = %d %q, want 401 wrong_credentials", status, errorCode(body))
	}

	if status, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"forged"}`); status != http.StatusUnauthorized || errorCode(body) != "invalid_google_token" {
		t.Errorf("google sign-in with a bad token = %d %q, want 401 invalid_google_token", status, errorCode(body))
	}
}

func TestGoogleSignInLinksEmailAccount(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	_, oldRefresh := tokensOf(t, body)

	status, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"maya"}`)
	if status != http.StatusOK || body["created"] != false || body["account"].(map[string]any)["firstName"] != "Maya" {
		t.Fatalf("google sign-in to an email account = %d %v, want 200 linked, names kept", status, body)
	}
	if status, _ := call(t, srv, "POST", "/auth/refresh", "", `{"refreshToken":"`+oldRefresh+`"}`); status != http.StatusUnauthorized {
		t.Errorf("refresh with a pre-link session = %d, want 401", status)
	}
	if status, _ := call(t, srv, "POST", "/auth/log-in", "", `{"email":"maya.rao@example.com","password":"sunflower"}`); status != http.StatusUnauthorized {
		t.Errorf("log-in with the pre-link password = %d, want 401", status)
	}
}

func TestGoogleSignInUnconfigured(t *testing.T) {
	srv := newTestServerWith(t, nil)
	if status, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`); status != http.StatusServiceUnavailable || errorCode(body) != "google_unavailable" {
		t.Errorf("google sign-in without client IDs = %d %q, want 503 google_unavailable", status, errorCode(body))
	}
}

func TestUpdateMe(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/google", "", `{"idToken":"new-student"}`)
	access, _ := tokensOf(t, body)

	tests := []struct {
		name       string
		token      string
		body       string
		wantStatus int
		wantCode   string
	}{
		{name: "no token", body: `{"firstName":"A","lastName":"B"}`, wantStatus: 401, wantCode: "invalid_token"},
		{name: "blank last name", token: access, body: `{"firstName":"Ada","lastName":"  "}`, wantStatus: 422, wantCode: "invalid_lastName"},
		{name: "unknown field", token: access, body: `{"email":"x@y.co"}`, wantStatus: 400, wantCode: "invalid_json"},
		{name: "renamed", token: access, body: `{"firstName":" Augusta ","lastName":"King"}`, wantStatus: 200},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			status, body := call(t, srv, "PATCH", "/me", tc.token, tc.body)
			if status != tc.wantStatus || errorCode(body) != tc.wantCode {
				t.Errorf("PATCH /me %s = %d %q, want %d %q", tc.body, status, errorCode(body), tc.wantStatus, tc.wantCode)
			}
		})
	}
	if _, body := call(t, srv, "GET", "/me", access, ""); body["firstName"] != "Augusta" || body["lastName"] != "King" {
		t.Errorf("me after rename = %v, want Augusta King", body)
	}
}

func TestDeleteMe(t *testing.T) {
	srv := newTestServer(t)
	_, body := call(t, srv, "POST", "/auth/sign-up", "", maya)
	access, refresh := tokensOf(t, body)

	if status, _ := call(t, srv, "DELETE", "/me", "", ""); status != http.StatusUnauthorized {
		t.Errorf("DELETE /me without a token = %d, want 401", status)
	}
	if status, body := call(t, srv, "DELETE", "/me", access, `{"reason":"`+strings.Repeat("x", 501)+`"}`); status != http.StatusUnprocessableEntity || errorCode(body) != "invalid_reason" {
		t.Errorf("DELETE /me with a long reason = %d %q, want 422 invalid_reason", status, errorCode(body))
	}
	status, body := call(t, srv, "DELETE", "/me", access, `{"reason":"I don't use it enough"}`)
	if status != http.StatusAccepted || body["deletesAt"] == nil {
		t.Fatalf("DELETE /me = %d %v, want 202 with deletesAt", status, body)
	}
	if status, _ := call(t, srv, "POST", "/auth/refresh", "", `{"refreshToken":"`+refresh+`"}`); status != http.StatusUnauthorized {
		t.Errorf("refresh after delete = %d, want 401 (sessions ended)", status)
	}
	if status, _ := call(t, srv, "POST", "/auth/log-in", "", `{"email":"maya.rao@example.com","password":"sunflower"}`); status != http.StatusOK {
		t.Errorf("log-in within 30 days = %d, want 200 (deletion cancelled)", status)
	}
}

func TestPurgeDeleted(t *testing.T) {
	store := newFakeStore()
	s := NewService(store, []byte("0123456789abcdef0123456789abcdef"), nil, &fakeMailer{})
	a, _, err := s.SignUp(t.Context(), SignUpInput{FirstName: "Maya", LastName: "Rao", Email: "m@example.com", Password: "sunflower"})
	if err != nil {
		t.Fatal(err)
	}
	if err := store.ScheduleDeletion(t.Context(), a.ID, "", time.Now().Add(-DeletionGrace-time.Hour)); err != nil {
		t.Fatal(err)
	}
	n, err := s.PurgeDeleted(t.Context())
	if err != nil || n != 1 {
		t.Fatalf("PurgeDeleted() = %d, %v, want 1 account", n, err)
	}
	if _, err := store.AccountByID(t.Context(), a.ID); !errors.Is(err, ErrNotFound) {
		t.Errorf("account after purge: %v, want ErrNotFound", err)
	}
}
