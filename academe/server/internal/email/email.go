package email

import (
	"bytes"
	"embed"
	"fmt"
	"html"
	htmltemplate "html/template"
	"net/url"
	"strings"
	texttemplate "text/template"
	"unicode"
)

const (
	siteHost       = "api.academe.cc"
	SiteURL        = "https://" + siteHost
	OpenURL        = SiteURL + "/open"
	SupportAddress = "support@academe.cc"
	supportURL     = "mailto:" + SupportAddress + "?subject=Delete%20my%20ACADEMe%20account"
)

type Reset struct {
	AccountID  string
	To         string
	Code       string
	LinkToken  string
	GoogleOnly bool
	Language   string
}

type Welcome struct {
	AccountID string
	To        string
	FirstName string
	Language  string
}

type message struct {
	Subject string
	HTML    string
	Text    string
}

type button struct {
	Label string
	URL   string
}

type page struct {
	Lang          string
	Site          string
	Host          string
	Subject       string
	Preheader     string
	Reason        string
	Questions     string
	Pebby         string
	Heading       string
	Lead          string
	Body          string
	Before        string
	Emphasis      string
	After         string
	Ignore        string
	Pill          string
	CodePrompt    string
	OpenTitle     string
	CantTitle     string
	CantBody      string
	Button        button
	Code          string
	Digits        []string
	TicketID      string
	CategoryLabel string
	StudentEmail  string
	Message       string
	MessageHTML   htmltemplate.HTML
}

//go:embed templates
var files embed.FS

var outlook = htmltemplate.FuncMap{
	"officeSettings": func() htmltemplate.HTML {
		return `<!--[if mso]><noscript><xml><o:OfficeDocumentSettings><o:PixelsPerInch>96</o:PixelsPerInch></o:OfficeDocumentSettings></xml></noscript><![endif]-->`
	},
	"outlookOpen": func() htmltemplate.HTML {
		return `<!--[if mso]><table role="presentation" width="600" align="center" cellpadding="0" cellspacing="0" border="0"><tr><td><![endif]-->`
	},
	"outlookClose":  func() htmltemplate.HTML { return `<!--[if mso]></td></tr></table><![endif]-->` },
	"notOutlook":    func() htmltemplate.HTML { return `<!--[if !mso]><!-->` },
	"endNotOutlook": func() htmltemplate.HTML { return `<!--<![endif]-->` },
	"preheaderPad": func() htmltemplate.HTML {
		return htmltemplate.HTML(strings.Repeat("&#847;&zwnj;&nbsp;", 60)) //nolint:gosec
	},
	"outlookButton": func(b button) htmltemplate.HTML {
		return htmltemplate.HTML(fmt.Sprintf(`<!--[if mso]><v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="%s" style="height:58px;v-text-anchor:middle;width:340px;" arcsize="28%%" strokecolor="#12141A" strokeweight="2px" fillcolor="#564CF1"><w:anchorlock/><center style="color:#FFFFFF;font-family:Arial,sans-serif;font-size:18px;font-weight:bold;">%s</center></v:roundrect><![endif]-->`, //nolint:gosec
			html.EscapeString(b.URL), html.EscapeString(b.Label)))
	},
}

type pair struct {
	html *htmltemplate.Template
	text *texttemplate.Template
}

var templates = parseTemplates("reset", "google", "welcome", "deletion", "feedback_ops", "feedback_received")

func parseTemplates(names ...string) map[string]pair {
	htmlLayout := htmltemplate.Must(htmltemplate.New("").Funcs(outlook).ParseFS(files, "templates/layout.html"))
	textLayout := texttemplate.Must(texttemplate.New("").ParseFS(files, "templates/layout.txt"))
	parsed := map[string]pair{}
	for _, name := range names {
		parsed[name] = pair{
			html: htmltemplate.Must(htmltemplate.Must(htmlLayout.Clone()).ParseFS(files, "templates/"+name+".html")),
			text: texttemplate.Must(texttemplate.Must(textLayout.Clone()).ParseFS(files, "templates/"+name+".txt")),
		}
	}
	return parsed
}

func render(name string, p page) (message, error) {
	t := templates[name]
	p.Site, p.Host = SiteURL, siteHost
	var h, txt bytes.Buffer
	if err := t.html.ExecuteTemplate(&h, "layout", p); err != nil {
		return message{}, fmt.Errorf("render %s html: %w", name, err)
	}
	if err := t.text.ExecuteTemplate(&txt, "layout", p); err != nil {
		return message{}, fmt.Errorf("render %s text: %w", name, err)
	}
	return message{Subject: p.Subject, HTML: h.String(), Text: txt.String()}, nil
}

func ResetURL(linkToken string) string {
	return SiteURL + "/reset-password?c=" + url.QueryEscape(linkToken)
}

func (r Reset) message() (message, error) {
	c := locale(r.Language)
	if r.GoogleOnly {
		return render("google", page{
			Lang:      c.Lang,
			Subject:   c.GoogleSubject,
			Preheader: c.GooglePreheader,
			Reason:    c.GoogleReason,
			Questions: c.Questions,
			Pebby:     "pebby-wave.png",
			Heading:   c.GoogleHeading,
			Lead:      c.GoogleLead,
			Before:    c.GoogleBefore,
			Emphasis:  c.GoogleEmphasis,
			After:     c.GoogleAfter,
			Body:      c.GoogleBodyText,
			Ignore:    c.GoogleIgnore,
			Button:    button{c.OpenButton, OpenURL},
		})
	}
	return render("reset", page{
		Lang:       c.Lang,
		Subject:    fmt.Sprintf(c.ResetSubject, r.Code),
		Preheader:  c.ResetPreheader,
		Reason:     c.ResetReason,
		Questions:  c.Questions,
		Pebby:      "pebby-shy.png",
		Heading:    c.ResetHeading,
		Lead:       c.ResetLeadHTML,
		Body:       c.ResetLeadText,
		Pill:       c.ResetPill,
		CodePrompt: c.ResetCodePrompt,
		Ignore:     c.ResetIgnore,
		Button:     button{c.ResetButton, ResetURL(r.LinkToken)},
		Code:       r.Code,
		Digits:     strings.Split(r.Code, ""),
	})
}

func (w Welcome) message() (message, error) {
	c := locale(w.Language)
	name := strings.TrimSpace(strings.Map(dropControl, w.FirstName))
	return render("welcome", page{
		Lang:      c.Lang,
		Subject:   c.WelcomeSubject,
		Preheader: c.WelcomePreheader,
		Reason:    c.WelcomeReason,
		Questions: c.Questions,
		Pebby:     "pebby-wave.png",
		Heading:   c.welcomeHeading(name),
		Lead:      c.WelcomeLead,
		Body:      c.WelcomeBody,
		Button:    button{c.OpenButton, OpenURL},
	})
}

func deletionMessage(language string) (message, error) {
	c := locale(language)
	return render("deletion", page{
		Lang:      c.Lang,
		Subject:   c.DeletionSubject,
		Preheader: c.DeletionPreheader,
		Reason:    fmt.Sprintf(c.DeletionReason, siteHost),
		Questions: c.Questions,
		Pebby:     "pebby-shy.png",
		Heading:   c.DeletionHeading,
		Lead:      c.DeletionLead,
		OpenTitle: c.DeletionOpenTitle,
		Before:    c.DeletionBefore,
		Emphasis:  c.DeletionPath,
		After:     c.DeletionAfter,
		CantTitle: c.DeletionCantTitle,
		CantBody:  c.DeletionCantBody,
		Ignore:    c.DeletionIgnore,
		Button:    button{c.DeletionButton, supportURL},
	})
}

type FeedbackTicket struct {
	ID           string
	StudentEmail string
	Category     string
	Message      string
	Language     string
}

func feedbackCategoryLabel(category string) string {
	switch category {
	case "wrong_answer":
		return "Report a wrong answer"
	case "bug":
		return "Something isn't working"
	case "feature":
		return "Suggest a feature"
	default:
		return category
	}
}

func (t FeedbackTicket) opsMessage() (message, error) {
	c := locales["en"]
	reply := "mailto:" + t.StudentEmail + "?subject=" + url.QueryEscape("Re: your ACADEMe feedback")
	return render("feedback_ops", page{
		Lang:          c.Lang,
		Subject:       "ACADEMe feedback (" + t.Category + ")",
		Preheader:     "Reply to reach the student. Ticket " + t.ID + ".",
		Reason:        "You're getting this email because a student sent feedback from the ACADEMe app.",
		Questions:     c.Questions,
		Pebby:         "pebby-wave.png",
		Heading:       "New in-app feedback",
		TicketID:      t.ID,
		CategoryLabel: feedbackCategoryLabel(t.Category),
		StudentEmail:  t.StudentEmail,
		Message:       t.Message,
		MessageHTML:   htmltemplate.HTML(html.EscapeString(t.Message)), //nolint:gosec // escaped
		Button:        button{"Reply to student", reply},
	})
}

func (t FeedbackTicket) receivedMessage() (message, error) {
	c := locale(t.Language)
	return render("feedback_received", page{
		Lang:      c.Lang,
		Subject:   c.FeedbackSubject,
		Preheader: c.FeedbackPreheader,
		Reason:    c.FeedbackReason,
		Questions: c.Questions,
		Pebby:     "pebby-shy.png",
		Heading:   c.FeedbackHeading,
		Lead:      c.FeedbackLead,
		Ignore:    c.FeedbackNote,
		Button:    button{c.OpenButton, OpenURL},
	})
}

func dropControl(r rune) rune {
	if unicode.IsControl(r) || unicode.Is(unicode.Bidi_Control, r) {
		return -1
	}
	return r
}
