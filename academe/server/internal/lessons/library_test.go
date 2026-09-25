package lessons

import (
	"encoding/json"
	"io/fs"
	"os"
	"path"
	"strings"
	"testing"

	"academe/server/internal/study"
	"academe/server/internal/syllabus"
)

func TestGeneratedDecksMatchThePlanAndRules(t *testing.T) {
	syllabi, err := syllabus.Load()
	if err != nil {
		t.Fatal(err)
	}
	planned := map[string]Job{}
	for _, j := range Jobs(syllabi, Filter{}) {
		planned[j.ID()] = j
	}
	root := os.DirFS("../study/decks")
	err = fs.WalkDir(root, ".", func(p string, e fs.DirEntry, err error) error {
		if err != nil || e.IsDir() || path.Ext(p) != ".json" || strings.HasSuffix(p, study.ReviewSuffix) {
			return err
		}
		raw, err := fs.ReadFile(root, p)
		if err != nil {
			return err
		}
		var d study.Deck
		if err := json.Unmarshal(raw, &d); err != nil {
			t.Errorf("%s: %v", p, err)
			return nil
		}
		if path.Base(p) != d.ID+".json" {
			t.Errorf("%s holds deck %q; the file must be named after the id", p, d.ID)
		}
		if d.GeneratedBy == nil {
			return nil
		}
		j, ok := planned[d.ID]
		switch {
		case !ok:
			t.Errorf("%s: %s is not a planned lesson", p, d.ID)
		case p != j.Path("."):
			t.Errorf("%s: a generated deck belongs at %s", p, j.Path("."))
		case d.Title != j.Lesson().Title || d.ChapterTitle != j.Chapter.Title:
			t.Errorf("%s: titled %q in %q, but the syllabus plans %q in %q; the chapter was renumbered, so regenerate it", p, d.Title, d.ChapterTitle, j.Lesson().Title, j.Chapter.Title)
		}
		if d.Approved() {
			if err := check(d); err != nil {
				t.Errorf("%s is approved but breaks the rules: %v", p, err)
			}
		}
		return nil
	})
	if err != nil {
		t.Fatal(err)
	}
}
