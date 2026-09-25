package email

import (
	"bytes"
	"encoding/json"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/google/go-cmp/cmp"
)

func fakeResend(t *testing.T) (*Resend, *resendRequest) {
	t.Helper()
	var got resendRequest
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost || r.Header.Get("Authorization") != "Bearer re_test" || r.Header.Get("Content-Type") != "application/json" {
			t.Errorf("request = %s auth %q type %q, want POST, Bearer re_test, application/json", r.Method, r.Header.Get("Authorization"), r.Header.Get("Content-Type"))
		}
		dec := json.NewDecoder(r.Body)
		dec.DisallowUnknownFields()
		if err := dec.Decode(&got); err != nil {
			t.Error(err)
		}
		_, _ = w.Write([]byte(`{"id":"e1"}`))
	}))
	t.Cleanup(srv.Close)
	c := NewResend("re_test", "", srv.Client())
	c.URL = srv.URL
	return c, &got
}

func containsAll(t *testing.T, what, s string, wants ...string) {
	t.Helper()
	for _, want := range wants {
		if !strings.Contains(s, want) {
			t.Errorf("%s does not contain %q", what, want)
		}
	}
}

func TestResendSendsTheReset(t *testing.T) {
	c, got := fakeResend(t)
	if err := c.SendReset(t.Context(), Reset{AccountID: "a1", To: "maya@example.com", Code: "042917", LinkToken: "tok_en-1"}); err != nil {
		t.Fatalf("SendReset() = %v, want nil", err)
	}
	want := resendRequest{From: DefaultFrom, To: []string{"maya@example.com"}, ReplyTo: SupportAddress, Subject: "Your ACADEMe code is 042917"}
	if diff := cmp.Diff(want, resendRequest{From: got.From, To: got.To, ReplyTo: got.ReplyTo, Subject: got.Subject}); diff != "" {
		t.Errorf("SendReset() envelope mismatch (-want +got):\n%s", diff)
	}
	link := "https://academe.cc/reset-password?c=tok_en-1"
	containsAll(t, "html", got.HTML, ">0<", ">4<", ">7<", "Reset password", `href="`+link+`"`, "v:roundrect", "Expires in 15 minutes", "pebby-shy.png")
	containsAll(t, "text", got.Text, "042917", link, "15 minutes", "ignore this email")
}

func TestResendGoogleOnly(t *testing.T) {
	c, got := fakeResend(t)
	if err := c.SendReset(t.Context(), Reset{To: "ada@gmail.com", GoogleOnly: true}); err != nil {
		t.Fatalf("SendReset() = %v", err)
	}
	containsAll(t, "html", got.HTML, "Continue with Google", `href="https://academe.cc/open"`, "Open ACADEMe")
	containsAll(t, "text", got.Text, "Continue with Google", "https://academe.cc/open")
	if strings.Contains(got.Text, "code") || strings.Contains(got.HTML, "reset-password") {
		t.Errorf("google-only email offers a code or reset link: %q", got.Text)
	}
}

func TestResendWelcomeEscapesTheName(t *testing.T) {
	c, got := fakeResend(t)
	if err := c.SendWelcome(t.Context(), Welcome{AccountID: "a1", To: "maya@example.com", FirstName: "Ma\r\nya <b>&"}); err != nil {
		t.Fatalf("SendWelcome() = %v", err)
	}
	if got.Subject != "Welcome to ACADEMe, Maya <b>&" {
		t.Errorf("subject = %q, want the name without control characters", got.Subject)
	}
	containsAll(t, "html", got.HTML, "Welcome to ACADEMe, Maya &lt;b&gt;&amp;!", "Open ACADEMe", "pebby-wave.png")
	if strings.Contains(got.HTML, "<b>&") {
		t.Errorf("html contains the unescaped name")
	}
	containsAll(t, "text", got.Text, "Welcome to ACADEMe, Maya <b>&!", "https://academe.cc/open")

	if err := c.SendWelcome(t.Context(), Welcome{To: "x@example.com", FirstName: `<script>alert("x")</script>' "`}); err != nil {
		t.Fatalf("SendWelcome() = %v", err)
	}
	containsAll(t, "html", got.HTML, "&lt;script&gt;alert(&#34;x&#34;)&lt;/script&gt;&#39; &#34;!")
	if strings.Contains(got.HTML, "<script") {
		t.Errorf("html contains a script tag from the name")
	}

	if err := c.SendWelcome(t.Context(), Welcome{To: "x@example.com"}); err != nil || got.Subject != "Welcome to ACADEMe" {
		t.Errorf("SendWelcome(no name) = %v with subject %q, want Welcome to ACADEMe", err, got.Subject)
	}
}

func TestResendDeletionNotice(t *testing.T) {
	c, got := fakeResend(t)
	if err := c.SendDeletionNotice(t.Context(), "maya@example.com"); err != nil {
		t.Fatalf("SendDeletionNotice() = %v", err)
	}
	if got.Subject != "Your ACADEMe account deletion request" || got.ReplyTo != SupportAddress {
		t.Errorf("subject/reply-to = %q %q", got.Subject, got.ReplyTo)
	}
	containsAll(t, "html", got.HTML, "Contact support", "mailto:support@academe.cc?subject=Delete%20my%20ACADEMe%20account", "Me &gt; Account &gt; Delete my account")
	containsAll(t, "text", got.Text, "Me > Account > Delete my account", "Reply to this email")
}

func TestEveryEmailSharesTheLayout(t *testing.T) {
	for name, m := range allMessages(t) {
		t.Run(name, func(t *testing.T) {
			containsAll(t, "html", m.HTML,
				`<meta name="color-scheme" content="light dark">`,
				`src="https://academe.cc/email/logo.png"`,
				"<!--[if mso]>", "<!--[if !mso]><!-->",
				`max-width:600px`,
				"You&#39;re getting this email because",
				"mailto:support@academe.cc", "ACADEMe · <a href=\"https://academe.cc\"",
			)
			containsAll(t, "text", m.Text, "You're getting this email because", "support@academe.cc", "ACADEMe · https://academe.cc")
			for _, banned := range []string{"data:image", "<script", "{{", "ZgotmplZ"} {
				if strings.Contains(m.HTML, banned) {
					t.Errorf("html contains %q", banned)
				}
			}
			if strings.Contains(m.Text, "<") && name != "welcome" {
				t.Errorf("text part contains markup: %q", m.Text)
			}
		})
	}
}

func TestResendRejected(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, `{"message":"The academe.cc domain is not verified"}`, http.StatusForbidden)
	}))
	t.Cleanup(srv.Close)
	c := NewResend("k", DefaultFrom, srv.Client())
	c.URL = srv.URL
	err := c.SendReset(t.Context(), Reset{To: "a@b.co", Code: "123456", LinkToken: "x"})
	if err == nil || !strings.Contains(err.Error(), "403") {
		t.Errorf("SendReset() = %v, want a 403 error", err)
	}
}

func TestLogShowsTheCodeOnlyInDev(t *testing.T) {
	for _, show := range []bool{false, true} {
		var buf bytes.Buffer
		l := Log{Logger: slog.New(slog.NewJSONHandler(&buf, nil)), ShowCode: show}
		if err := l.SendReset(t.Context(), Reset{AccountID: "a1", To: "maya@example.com", Code: "123456", LinkToken: "secretlink"}); err != nil {
			t.Fatal(err)
		}
		if err := l.SendWelcome(t.Context(), Welcome{AccountID: "a1", To: "maya@example.com"}); err != nil {
			t.Fatal(err)
		}
		line := buf.String()
		if !strings.Contains(line, "reset code sent") || !strings.Contains(line, "a1") || strings.Contains(line, "maya@example.com") {
			t.Errorf("log = %s, want the account ID and no email", line)
		}
		if strings.Contains(line, "123456") != show || strings.Contains(line, "secretlink") != show {
			t.Errorf("ShowCode=%v: log = %s", show, line)
		}
	}
}

func allMessages(t *testing.T) map[string]message {
	t.Helper()
	all := map[string]message{}
	for name, build := range map[string]func() (message, error){
		"reset":    Reset{Code: "042917", LinkToken: "Xq3vP0kE2mR8sT1uW5yZ7a"}.message, //nolint:gosec
		"google":   Reset{GoogleOnly: true}.message,
		"welcome":  Welcome{FirstName: "Maya"}.message,
		"deletion": deletionMessage,
	} {
		m, err := build()
		if err != nil {
			t.Fatalf("render %s = %v", name, err)
		}
		all[name] = m
	}
	return all
}

func TestWritePreviews(t *testing.T) {
	dir := os.Getenv("ACADEME_EMAIL_PREVIEW")
	if dir == "" {
		t.Skip("set ACADEME_EMAIL_PREVIEW to a directory to write previews")
	}
	assets, err := filepath.Abs("../site/email")
	if err != nil {
		t.Fatal(err)
	}
	if err := os.MkdirAll(dir, 0o750); err != nil { //nolint:gosec
		t.Fatal(err)
	}
	for name, m := range allMessages(t) {
		page := strings.ReplaceAll(m.HTML, SiteURL+"/email/", "file://"+assets+"/")
		if err := os.WriteFile(filepath.Join(dir, name+".html"), []byte(page), 0o600); err != nil { //nolint:gosec
			t.Fatal(err)
		}
		text := "Subject: " + m.Subject + "\n\n" + m.Text
		if err := os.WriteFile(filepath.Join(dir, name+".txt"), []byte(text), 0o600); err != nil { //nolint:gosec
			t.Fatal(err)
		}
	}
}
