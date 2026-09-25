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
	SiteURL        = "https://academe.cc"
	OpenURL        = SiteURL + "/open"
	SupportAddress = "support@academe.cc"
	supportURL     = "mailto:" + SupportAddress + "?subject=Delete%20my%20ACADEMe%20account"
	resetReason    = "You're getting this email because someone asked to reset the password for the ACADEMe account that uses this address."
)

type Reset struct {
	AccountID  string
	To         string
	Code       string
	LinkToken  string
	GoogleOnly bool
}

type Welcome struct {
	AccountID string
	To        string
	FirstName string
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
	Subject   string
	Preheader string
	Reason    string
	Pebby     string
	Heading   string
	Button    button
	Code      string
	Digits    []string
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

var templates = parseTemplates("reset", "google", "welcome", "deletion")

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
	if r.GoogleOnly {
		return render("google", page{
			Subject:   "Log in to ACADEMe with Google",
			Preheader: "Your account uses Google to log in, so there's no password to reset.",
			Reason:    resetReason,
			Pebby:     "pebby-wave.png",
			Button:    button{"Open ACADEMe", OpenURL},
		})
	}
	return render("reset", page{
		Subject:   "Your ACADEMe code is " + r.Code,
		Preheader: "Tap Reset password, or type the code in the app. It expires in 15 minutes.",
		Reason:    resetReason,
		Pebby:     "pebby-shy.png",
		Button:    button{"Reset password", ResetURL(r.LinkToken)},
		Code:      r.Code,
		Digits:    strings.Split(r.Code, ""),
	})
}

func (w Welcome) message() (message, error) {
	name := strings.TrimSpace(strings.Map(dropControl, w.FirstName))
	greeting := "Welcome to ACADEMe"
	if name != "" {
		greeting += ", " + name
	}
	return render("welcome", page{
		Subject:   greeting,
		Preheader: "Your first lesson is ready. Here's how to get started.",
		Reason:    "You're getting this email because you created an ACADEMe account with this address.",
		Pebby:     "pebby-wave.png",
		Heading:   greeting + "!",
		Button:    button{"Open ACADEMe", OpenURL},
	})
}

func deletionMessage() (message, error) {
	return render("deletion", page{
		Subject:   "Your ACADEMe account deletion request",
		Preheader: "Reply from this address to confirm, or delete the account in the app.",
		Reason:    "You're getting this email because someone asked on academe.cc to delete the ACADEMe account that uses this address.",
		Pebby:     "pebby-shy.png",
		Button:    button{"Contact support", supportURL},
	})
}

func dropControl(r rune) rune {
	if unicode.IsControl(r) || unicode.Is(unicode.Bidi_Control, r) {
		return -1
	}
	return r
}
