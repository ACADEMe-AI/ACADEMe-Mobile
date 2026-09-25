package email

import (
	"bytes"
	_ "embed"
	"fmt"
	htmltemplate "html/template"
	"strings"
	texttemplate "text/template"
)

type Reset struct {
	AccountID  string
	To         string
	Code       string
	GoogleOnly bool
}

type message struct {
	Subject string
	HTML    string
	Text    string
}

//go:embed reset.html
var resetHTML string

//go:embed reset.txt
var resetText string

var (
	htmlPage  = htmltemplate.Must(htmltemplate.New("reset.html").Parse(resetHTML))
	plainPage = texttemplate.Must(texttemplate.New("reset.txt").Parse(resetText))
)

type resetView struct {
	GoogleOnly bool
	Digits     []string
	Code       string
}

func render(r Reset) (message, error) {
	view := resetView{GoogleOnly: r.GoogleOnly, Code: r.Code, Digits: strings.Split(r.Code, "")}
	var html, text bytes.Buffer
	if err := htmlPage.Execute(&html, view); err != nil {
		return message{}, fmt.Errorf("render reset html: %w", err)
	}
	if err := plainPage.Execute(&text, view); err != nil {
		return message{}, fmt.Errorf("render reset text: %w", err)
	}
	subject := "Your ACADEMe code is " + r.Code
	if r.GoogleOnly {
		subject = "Log in to ACADEMe with Google"
	}
	return message{Subject: subject, HTML: html.String(), Text: text.String()}, nil
}
