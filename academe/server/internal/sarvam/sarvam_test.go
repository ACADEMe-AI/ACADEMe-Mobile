package sarvam

import (
	"archive/zip"
	"bytes"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync/atomic"
	"testing"
	"time"
)

func TestDigitisePollsAndReadsTheMarkdown(t *testing.T) {
	var polls atomic.Int32
	var srv *httptest.Server
	srv = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Header.Get("api-subscription-key") != "k" && r.URL.Path != "/file.zip" {
			t.Errorf("%s without the key", r.URL.Path)
		}
		switch r.URL.Path {
		case "/doc/job/digitise":
			r.Body = http.MaxBytesReader(w, r.Body, 1<<20)
			if err := r.ParseMultipartForm(1 << 20); err != nil { //nolint:gosec
				t.Fatal(err)
			}
			if r.FormValue("output_format") != "md" || r.FormValue("language") != "hi-IN" {
				t.Errorf("form = %v", r.Form)
			}
			f, _, err := r.FormFile("file")
			if err != nil {
				t.Fatal(err)
			}
			raw, _ := io.ReadAll(f)
			zr, err := zip.NewReader(bytes.NewReader(raw), int64(len(raw)))
			if err != nil || len(zr.File) != 2 || zr.File[0].Name != "page_001.jpg" {
				t.Errorf("upload zip = %v, %v", zr, err)
			}
			_ = json.NewEncoder(w).Encode(map[string]string{"job_id": "j1", "status": "pending"})
		case "/doc/job/j1/status":
			status := "running"
			if polls.Add(1) > 1 {
				status = "completed"
			}
			_ = json.NewEncoder(w).Encode(map[string]string{"status": status})
		case "/doc/job/j1/download-url":
			_ = json.NewEncoder(w).Encode(map[string]string{"method": "GET", "url": srv.URL + "/file.zip"})
		case "/file.zip":
			var buf bytes.Buffer
			zw := zip.NewWriter(&buf)
			m, _ := zw.Create("metadata/page_001.json")
			_, _ = m.Write([]byte("{}"))
			d, _ := zw.Create("document.md")
			_, _ = d.Write([]byte("  2x + 3y = 11\n"))
			_ = zw.Close()
			_, _ = w.Write(buf.Bytes())
		default:
			t.Errorf("unexpected %s", r.URL.Path)
		}
	}))
	t.Cleanup(srv.Close)
	c := &Client{DocURL: srv.URL + "/doc", Key: "k", HTTP: srv.Client(), Poll: time.Millisecond, Deadline: time.Second}

	text, err := c.Digitise(t.Context(), []Page{{Name: "a.jpg", Data: []byte("x")}, {Name: "b.jpg", Data: []byte("y")}}, "hi-IN")
	if err != nil || text != "2x + 3y = 11" {
		t.Fatalf("Digitise() = %q, %v; want the markdown text", text, err)
	}
}

func TestChat(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var in chatRequest
		_ = json.NewDecoder(r.Body).Decode(&in)
		if in.Model != "m" || len(in.Messages) != 2 {
			t.Errorf("request = %+v", in)
		}
		_, _ = io.WriteString(w, `{"choices":[{"message":{"role":"assistant","content":"  hi  "}}]}`)
	}))
	t.Cleanup(srv.Close)
	c := &Client{ChatURL: srv.URL, Key: "k", Model: "m", HTTP: srv.Client()}
	got, err := c.Chat(t.Context(), []Message{{Role: "system", Content: "s"}, {Role: "user", Content: "u"}}, 0.2)
	if err != nil || !strings.EqualFold(got, "hi") {
		t.Fatalf("Chat() = %q, %v", got, err)
	}
}
