package lessons

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"html/template"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strings"

	"academe/server/internal/study"
)

type reportDeck struct {
	study.Deck
	Issues []string
}

type reportChapter struct {
	Heading string
	Decks   []reportDeck
}

type reportData struct {
	Approved, Draft int
	Chapters        []reportChapter
}

var bold = regexp.MustCompile(`\*\*(.+?)\*\*`)

func rich(s string) template.HTML {
	escaped := template.HTMLEscapeString(s)
	escaped = bold.ReplaceAllString(escaped, "<strong>$1</strong>")
	return template.HTML(strings.ReplaceAll(escaped, "\n", "<br>")) //nolint:gosec
}

var reportPage = template.Must(template.New("report").Funcs(template.FuncMap{"rich": rich, "picked": func(i int, answer *int) bool { return answer != nil && i == *answer }}).Parse(reportHTML))

func WriteReport(out, htmlPath string) (int, error) {
	fsys := os.DirFS(out)
	decks, err := study.ReadDecks(fsys)
	if err != nil {
		return 0, err
	}
	data := reportData{}
	index := map[string]int{}
	for _, d := range decks {
		rd := reportDeck{Deck: d}
		if d.Approved() {
			data.Approved++
		} else {
			data.Draft++
			issues, err := reviewIssues(fsys, d)
			if err != nil {
				return 0, err
			}
			rd.Issues = issues
		}
		heading := fmt.Sprintf("%s Class %d · %s · Chapter %d: %s", d.Board, d.Class, d.Subject, d.ChapterNumber, d.ChapterTitle)
		i, ok := index[heading]
		if !ok {
			i = len(data.Chapters)
			index[heading] = i
			data.Chapters = append(data.Chapters, reportChapter{Heading: heading})
		}
		data.Chapters[i].Decks = append(data.Chapters[i].Decks, rd)
	}
	var buf bytes.Buffer
	if err := reportPage.Execute(&buf, data); err != nil {
		return 0, fmt.Errorf("render report: %w", err)
	}
	if err := os.MkdirAll(filepath.Dir(htmlPath), 0o750); err != nil {
		return 0, fmt.Errorf("create report folder: %w", err)
	}
	if err := os.WriteFile(htmlPath, buf.Bytes(), 0o644); err != nil { //nolint:gosec
		return 0, fmt.Errorf("write report: %w", err)
	}
	return len(decks), nil
}

func reviewIssues(fsys fs.FS, d study.Deck) ([]string, error) {
	name := filepath.ToSlash(filepath.Join(strings.ToLower(d.Board)+"-"+fmt.Sprint(d.Class), d.ID+study.ReviewSuffix))
	raw, err := fs.ReadFile(fsys, name)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, nil
	}
	if err != nil {
		return nil, fmt.Errorf("read %s: %w", name, err)
	}
	var r Review
	if err := json.Unmarshal(raw, &r); err != nil {
		return nil, fmt.Errorf("parse %s: %w", name, err)
	}
	return r.Issues, nil
}

const reportHTML = `<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ACADEMe lesson review</title>
<style>
:root { --ink: #1d1b26; --muted: #6b6878; --line: #e4e1ec; --paper: #ffffff; --page: #f6f4fa; --good: #1f7a4d; --warn: #a15c00; --accent: #5b3fd1; }
* { box-sizing: border-box; }
body { margin: 0; font: 15px/1.5 system-ui, sans-serif; color: var(--ink); background: var(--page); }
main { max-width: 880px; margin: 0 auto; padding: 24px 16px 64px; }
h1 { font-size: 24px; margin: 0 0 4px; }
.meta { color: var(--muted); margin: 0 0 24px; }
details.chapter { background: var(--paper); border: 1px solid var(--line); border-radius: 12px; margin: 0 0 12px; padding: 12px 16px; }
details.chapter > summary { font-weight: 600; cursor: pointer; }
article { border-top: 1px solid var(--line); margin-top: 12px; padding-top: 12px; }
article h2 { font-size: 17px; margin: 0 0 4px; }
.badge { display: inline-block; font-size: 12px; font-weight: 600; border-radius: 99px; padding: 1px 8px; margin-left: 8px; color: #fff; }
.approved { background: var(--good); }
.draft { background: var(--warn); }
.issues { background: #fff6e8; border: 1px solid #f1d3a6; border-radius: 8px; padding: 8px 12px 8px 28px; }
.small { color: var(--muted); font-size: 13px; }
ol.cards { padding-left: 20px; }
ol.cards > li { margin: 0 0 10px; }
.kind { font-size: 11px; text-transform: uppercase; letter-spacing: .06em; color: var(--accent); font-weight: 700; }
table { border-collapse: collapse; margin: 4px 0; }
td { border: 1px solid var(--line); padding: 4px 8px; vertical-align: top; }
.right { color: var(--good); font-weight: 600; }
.tip { color: var(--muted); font-style: italic; }
</style>
</head>
<body>
<main>
<h1>ACADEMe lesson review</h1>
<p class="meta">{{.Approved}} approved · {{.Draft}} drafts. Drafts are not shown to students. Open a chapter to read every card; the tick marks the answer the app will accept.</p>
{{range .Chapters}}<details class="chapter">
<summary>{{.Heading}} ({{len .Decks}})</summary>
{{range .Decks}}<article>
<h2>{{.Position}}. {{.Title}}<span class="badge {{if .Approved}}approved{{else}}draft{{end}}">{{if .Approved}}approved{{else}}draft{{end}}</span></h2>
<p class="small">{{.ID}}{{with .GeneratedBy}} · {{.Model}} · {{.PromptVersion}} · checked {{.CheckedAt.Format "2 Jan 2006"}}{{else}} · written by hand{{end}}</p>
{{if .Issues}}<ul class="issues">{{range .Issues}}<li>{{.}}</li>{{end}}</ul>{{end}}
<ol class="cards">{{range .Cards}}<li><div class="kind">{{.Kind}}</div>
{{if .Title}}<strong>{{.Title}}</strong><br>{{end}}
{{if .Body}}{{rich .Body}}<br>{{end}}
{{if .Goals}}Goals:<ul>{{range .Goals}}<li>{{.}}</li>{{end}}</ul>{{end}}
{{if .Rows}}<table>{{range .Rows}}<tr><td>{{rich .Term}}</td><td>{{rich .Value}}</td></tr>{{end}}</table>{{end}}
{{if .Question}}{{rich .Question}}{{end}}
{{if .Steps}}<ol>{{range .Steps}}<li>{{rich .}}</li>{{end}}</ol>{{end}}
{{if .Options}}{{$answer := .Answer}}<ul>{{range $i, $o := .Options}}<li{{if picked $i $answer}} class="right"{{end}}>{{if picked $i $answer}}✓ {{end}}{{$o}}</li>{{end}}</ul>{{end}}
{{if .Why}}<div class="small">Why: {{rich .Why}}</div>{{end}}
{{if .Points}}<ul>{{range .Points}}<li>{{rich .}}</li>{{end}}</ul>{{end}}
{{if .Remember}}<div class="tip">Remember: {{rich .Remember}}</div>{{end}}
</li>{{end}}</ol>
</article>{{end}}
</details>
{{end}}</main>
</body>
</html>
`
