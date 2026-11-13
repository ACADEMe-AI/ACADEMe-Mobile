package email

import (
	"bytes"
	"encoding/json"
	"html"
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

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
	link := "https://api.academe.cc/reset-password?c=tok_en-1"
	containsAll(t, "html", got.HTML, ">0<", ">4<", ">7<", "Reset password", `href="`+link+`"`, "v:roundrect", "Expires in 15 minutes", "pebby-shy.png")
	containsAll(t, "text", got.Text, "042917", link, "15 minutes", "ignore this email")
}

func TestResendGoogleOnly(t *testing.T) {
	c, got := fakeResend(t)
	if err := c.SendReset(t.Context(), Reset{To: "ada@gmail.com", GoogleOnly: true}); err != nil {
		t.Fatalf("SendReset() = %v", err)
	}
	containsAll(t, "html", got.HTML, "Continue with Google", `href="https://api.academe.cc/open"`, "Open ACADEMe")
	containsAll(t, "text", got.Text, "Continue with Google", "https://api.academe.cc/open")
	if strings.Contains(got.Text, "code") || strings.Contains(got.HTML, "reset-password") {
		t.Errorf("google-only email offers a code or reset link: %q", got.Text)
	}
}

func TestResendWelcomeEscapesTheName(t *testing.T) {
	c, got := fakeResend(t)
	if err := c.SendWelcome(t.Context(), Welcome{AccountID: "a1", To: "maya@example.com", FirstName: "Ma\r\nya <b>&"}); err != nil {
		t.Fatalf("SendWelcome() = %v", err)
	}
	if got.Subject != "Welcome to ACADEMe" {
		t.Errorf("subject = %q, want the fixed subject without the name", got.Subject)
	}
	containsAll(t, "html", got.HTML, "Welcome to ACADEMe, Maya &lt;b&gt;&amp;!", "Open ACADEMe", "pebby-wave.png")
	if strings.Contains(got.HTML, "<b>&") {
		t.Errorf("html contains the unescaped name")
	}
	containsAll(t, "text", got.Text, "Welcome to ACADEMe, Maya <b>&!", "https://api.academe.cc/open")

	if err := c.SendWelcome(t.Context(), Welcome{To: "x@example.com", FirstName: `<script>alert("x")</script>' "`}); err != nil {
		t.Fatalf("SendWelcome() = %v", err)
	}
	containsAll(t, "html", got.HTML, "&lt;script&gt;alert(&#34;x&#34;)&lt;/script&gt;&#39; &#34;!")
	if strings.Contains(got.HTML, "<script") {
		t.Errorf("html contains a script tag from the name")
	}

	if err := c.SendWelcome(t.Context(), Welcome{To: "x@example.com", FirstName: "Ma\u202eya\u2066 \u0915\u094d\u200d\u0937"}); err != nil || !strings.Contains(got.Text, "Welcome to ACADEMe, Maya \u0915\u094d\u200d\u0937!") {
		t.Errorf("SendWelcome(bidi name) = %v with text %+q, want bidi controls dropped and the joiner kept", err, got.Text)
	}

	if err := c.SendWelcome(t.Context(), Welcome{To: "x@example.com", FirstName: "Call +1-555-0100 or visit evil.example"}); err != nil || got.Subject != "Welcome to ACADEMe" {
		t.Errorf("SendWelcome(spam name) = %v with subject %q, want Welcome to ACADEMe", err, got.Subject)
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

func TestResendFeedback(t *testing.T) {
	c, got := fakeResend(t)
	ticket := FeedbackTicket{
		ID: "fb_1", StudentEmail: "maya@example.com", Category: "bug",
		Message: "App froze\non quiz 3",
	}
	if err := c.SendFeedback(t.Context(), ticket); err != nil {
		t.Fatalf("SendFeedback() = %v", err)
	}
	if got.To[0] != SupportAddress || got.ReplyTo != "maya@example.com" {
		t.Errorf("ops to/reply = %q %q, want support + student reply-to", got.To, got.ReplyTo)
	}
	if !strings.Contains(got.Subject, "bug") {
		t.Errorf("subject = %q", got.Subject)
	}
	containsAll(t, "html", got.HTML, "New in-app feedback", "fb_1", "maya@example.com", "Something isn&#39;t working", "App froze", "Reply to student", "pebby-wave.png")
	containsAll(t, "text", got.Text, "fb_1", "App froze", "Reply to student")

	if err := c.SendFeedbackReceipt(t.Context(), ticket); err != nil {
		t.Fatalf("SendFeedbackReceipt() = %v", err)
	}
	if got.To[0] != "maya@example.com" || got.ReplyTo != SupportAddress {
		t.Errorf("receipt to/reply = %q %q", got.To, got.ReplyTo)
	}
	containsAll(t, "html", got.HTML, "Thanks, we got your message", "Open ACADEMe", "pebby-shy.png")
	containsAll(t, "text", got.Text, "Thanks, we got your message", "https://api.academe.cc/open")
}

func TestEveryEmailSharesTheLayout(t *testing.T) {
	for name, m := range allMessages(t) {
		t.Run(name, func(t *testing.T) {
			containsAll(t, "html", m.HTML,
				`<meta name="color-scheme" content="light dark">`,
				`src="https://api.academe.cc/email/logo.png"`,
				`url(https://api.academe.cc/email/baloo2-800.ttf)`,
				"<!--[if mso]>", "<!--[if !mso]><!-->",
				`max-width:600px`,
				"You&#39;re getting this email because",
				"mailto:support@academe.cc", "ACADEMe · <a href=\"https://api.academe.cc\"",
			)
			containsAll(t, "text", m.Text, "You're getting this email because", "support@academe.cc", "ACADEMe · https://api.academe.cc")
			if strings.Contains(m.HTML, "https://academe.cc") || strings.Contains(m.Text, "https://academe.cc") {
				t.Errorf("%s links to https://academe.cc, want every link on %s", name, SiteURL)
			}
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
		"reset":   Reset{Code: "042917", LinkToken: "Xq3vP0kE2mR8sT1uW5yZ7a"}.message, //nolint:gosec
		"google":  Reset{GoogleOnly: true}.message,
		"welcome": Welcome{FirstName: "Maya"}.message,
		"deletion": func() (message, error) {
			return deletionMessage("")
		},
		"feedback_ops": func() (message, error) {
			return FeedbackTicket{ID: "t1", StudentEmail: "s@ex.com", Category: "feature", Message: "Dark mode"}.opsMessage()
		},
		"feedback_received": func() (message, error) {
			return FeedbackTicket{ID: "t1", StudentEmail: "s@ex.com"}.receivedMessage()
		},
	} {
		m, err := build()
		if err != nil {
			t.Fatalf("render %s = %v", name, err)
		}
		all[name] = m
	}
	return all
}

func TestNormalizeLanguage(t *testing.T) {
	for _, tc := range []struct {
		in, want string
	}{
		{"", "en"}, {"EN", "en"}, {"fr", "en"}, {"hi", "hi"}, {" HI ", "hi"},
		{"te", "te"}, {"ta", "ta"}, {"bn", "bn"}, {"as", "as"}, {"hi-IN", "en"},
	} {
		if got := locale(tc.in).Lang; got != tc.want {
			t.Errorf("locale(%q).Lang = %q, want %q", tc.in, got, tc.want)
		}
	}
}

func TestLocalesRenderSubjectHTMLText(t *testing.T) {
	langs := []string{"en", "hi", "te", "ta", "bn", "as"}
	for _, lang := range langs {
		c := locale(lang)
		t.Run("welcome/"+lang, func(t *testing.T) {
			m, err := Welcome{FirstName: "Maya", Language: lang}.message()
			if err != nil {
				t.Fatalf("Welcome.message() = %v", err)
			}
			if m.Subject != c.WelcomeSubject {
				t.Errorf("subject = %q, want %q", m.Subject, c.WelcomeSubject)
			}
			heading := c.welcomeHeading("Maya")
			containsAll(t, "html", m.HTML, `lang="`+c.Lang+`"`, html.EscapeString(heading), html.EscapeString(c.WelcomeLead), html.EscapeString(c.OpenButton), html.EscapeString(c.Questions))
			containsAll(t, "text", m.Text, heading, c.WelcomeBody, c.OpenButton, c.Questions)
		})
		t.Run("reset/"+lang, func(t *testing.T) {
			m, err := Reset{Code: "042917", LinkToken: "tok", Language: lang}.message()
			if err != nil {
				t.Fatalf("Reset.message() = %v", err)
			}
			wantSubject := strings.ReplaceAll(c.ResetSubject, "%s", "042917")
			if m.Subject != wantSubject {
				t.Errorf("subject = %q, want %q", m.Subject, wantSubject)
			}
			containsAll(t, "html", m.HTML, `lang="`+c.Lang+`"`, html.EscapeString(c.ResetHeading), html.EscapeString(c.ResetButton), html.EscapeString(c.ResetPill), ">0<", ">4<", html.EscapeString(c.ResetIgnore))
			containsAll(t, "text", m.Text, c.ResetHeading, "042917", c.ResetIgnore, c.Questions)
		})
		t.Run("google/"+lang, func(t *testing.T) {
			m, err := Reset{GoogleOnly: true, Language: lang}.message()
			if err != nil {
				t.Fatalf("Reset(google).message() = %v", err)
			}
			if m.Subject != c.GoogleSubject {
				t.Errorf("subject = %q, want %q", m.Subject, c.GoogleSubject)
			}
			containsAll(t, "html", m.HTML, `lang="`+c.Lang+`"`, html.EscapeString(c.GoogleHeading), html.EscapeString(c.GoogleEmphasis), html.EscapeString(c.OpenButton), html.EscapeString(c.GoogleIgnore))
			containsAll(t, "text", m.Text, c.GoogleHeading, c.GoogleBodyText, c.OpenButton)
			if strings.Contains(m.HTML, "reset-password") || strings.Contains(m.Text, "042917") {
				t.Errorf("google-only mail offers a reset link or code")
			}
		})
		t.Run("deletion/"+lang, func(t *testing.T) {
			m, err := deletionMessage(lang)
			if err != nil {
				t.Fatalf("deletionMessage() = %v", err)
			}
			if m.Subject != c.DeletionSubject {
				t.Errorf("subject = %q, want %q", m.Subject, c.DeletionSubject)
			}
			containsAll(t, "html", m.HTML, `lang="`+c.Lang+`"`, html.EscapeString(c.DeletionHeading), html.EscapeString(c.DeletionPath), html.EscapeString(c.DeletionButton), html.EscapeString(c.DeletionIgnore))
			containsAll(t, "text", m.Text, c.DeletionHeading, c.DeletionPath, c.DeletionCantBody)
		})
		t.Run("feedback_received/"+lang, func(t *testing.T) {
			m, err := FeedbackTicket{Language: lang}.receivedMessage()
			if err != nil {
				t.Fatalf("receivedMessage() = %v", err)
			}
			if m.Subject != c.FeedbackSubject {
				t.Errorf("subject = %q, want %q", m.Subject, c.FeedbackSubject)
			}
			containsAll(t, "html", m.HTML, `lang="`+c.Lang+`"`, html.EscapeString(c.FeedbackHeading), html.EscapeString(c.FeedbackLead), html.EscapeString(c.OpenButton), html.EscapeString(c.FeedbackNote))
			containsAll(t, "text", m.Text, c.FeedbackHeading, c.FeedbackLead, c.OpenButton)
		})
	}
}

func TestFeedbackOpsStaysEnglish(t *testing.T) {
	m, err := FeedbackTicket{ID: "t1", StudentEmail: "s@ex.com", Category: "bug", Message: "x", Language: "hi"}.opsMessage()
	if err != nil {
		t.Fatalf("opsMessage() = %v", err)
	}
	containsAll(t, "html", m.HTML, `lang="en"`, "New in-app feedback", "Something isn&#39;t working", "Questions? Write to")
	containsAll(t, "text", m.Text, "New in-app feedback", "Questions? Write to")
	if strings.Contains(m.HTML, "धन्यवाद") || strings.Contains(m.Subject, "फ़ीडबैक") {
		t.Errorf("ops mail localized unexpectedly: subject %q", m.Subject)
	}
}

// Sends real feedback receipt (and ops copy) when ACADEME_LIVE_EMAIL=1 and ACADEME_RESEND_API_KEY is set.
// ACADEME_SEND_SAMPLE_TO defaults to the address under test.
func TestSendFeedbackLive(t *testing.T) {
	if os.Getenv("ACADEME_LIVE_EMAIL") != "1" {
		t.Skip("set ACADEME_LIVE_EMAIL=1 to send real mail")
	}
	key := os.Getenv("ACADEME_RESEND_API_KEY")
	if key == "" {
		t.Skip("ACADEME_RESEND_API_KEY not set")
	}
	to := os.Getenv("ACADEME_SEND_SAMPLE_TO")
	if to == "" {
		t.Skip("ACADEME_SEND_SAMPLE_TO not set")
	}
	c := NewResend(key, os.Getenv("ACADEME_EMAIL_FROM"), &http.Client{Timeout: 15 * time.Second})
	ticket := FeedbackTicket{
		ID:           "sample-" + time.Now().UTC().Format("20060102-150405"),
		StudentEmail: to,
		Category:     "feature",
		Message:      "Sample branded feedback email from ACADEMe dev — safe to ignore. Checking ops + receipt templates match reset/welcome.",
	}
	if err := c.SendFeedbackReceipt(t.Context(), ticket); err != nil {
		t.Fatalf("SendFeedbackReceipt() = %v", err)
	}
	if err := c.SendFeedback(t.Context(), ticket); err != nil {
		t.Fatalf("SendFeedback() = %v", err)
	}
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
