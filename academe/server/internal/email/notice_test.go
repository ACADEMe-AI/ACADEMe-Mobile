package email

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func TestResendSendsANotice(t *testing.T) {
	var got noticeRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if err := json.NewDecoder(r.Body).Decode(&got); err != nil {
			t.Error(err)
		}
		_, _ = w.Write([]byte(`{"id":"e1"}`))
	}))
	t.Cleanup(srv.Close)
	c := NewResend("re_test", DefaultFrom, srv.Client())
	c.URL = srv.URL

	if err := c.SendNotice(t.Context(), "maya@example.com", "Hello", "Body"); err != nil {
		t.Fatalf("SendNotice() = %v, want nil", err)
	}
	want := noticeRequest{From: DefaultFrom, To: []string{"maya@example.com"}, ReplyTo: SupportAddress, Subject: "Hello", Text: "Body"}
	if diff := cmp.Diff(want, got); diff != "" {
		t.Errorf("SendNotice() request mismatch (-want +got):\n%s", diff)
	}
}
