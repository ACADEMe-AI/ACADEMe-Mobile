package lang

import (
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"testing"
)

func TestNormalize(t *testing.T) {
	cases := map[string]string{
		"": "en", "EN": "en", "hi": "hi", "HI": "hi", "te-IN": "en", "ta": "ta", "bn": "bn", "as": "as", "AS": "as", "fr": "en",
	}
	for in, want := range cases {
		if got := Normalize(in); got != want {
			t.Fatalf("Normalize(%q)=%q want %q", in, got, want)
		}
	}
}

func TestSupported(t *testing.T) {
	yes := []string{"en", "EN", "hi", "as", "AS", " bn "}
	for _, in := range yes {
		if !Supported(in) {
			t.Fatalf("Supported(%q)=false want true", in)
		}
	}
	no := []string{"", "fr", "te-IN", "xyz", "hinglish"}
	for _, in := range no {
		if Supported(in) {
			t.Fatalf("Supported(%q)=true want false", in)
		}
	}
}

func TestEnglishName(t *testing.T) {
	cases := map[string]string{
		"as": "Assamese", "AS": "Assamese", "bn": "Bengali", "fr": "English", "": "English",
	}
	for in, want := range cases {
		if got := EnglishName(in); got != want {
			t.Fatalf("EnglishName(%q)=%q want %q", in, got, want)
		}
	}
}

func TestCodesMatchNames(t *testing.T) {
	if len(Codes) != len(englishNames) {
		t.Fatalf("Codes len %d != englishNames len %d", len(Codes), len(englishNames))
	}
	for _, code := range Codes {
		if !Supported(code) {
			t.Fatalf("Codes entry %q missing from englishNames", code)
		}
	}
}

func TestOpenAPILanguageEnumMatchesCodes(t *testing.T) {
	path := filepath.Join("..", "..", "openapi.yaml")
	raw, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read openapi: %v", err)
	}
	re := regexp.MustCompile(`language:\s*\{\s*type:\s*string,\s*enum:\s*\[([^\]]+)\]`)
	m := re.FindSubmatch(raw)
	if m == nil {
		t.Fatal("profile language enum not found in openapi.yaml")
	}
	parts := strings.Split(string(m[1]), ",")
	got := make([]string, 0, len(parts))
	for _, p := range parts {
		got = append(got, strings.TrimSpace(p))
	}
	if len(got) != len(Codes) {
		t.Fatalf("openapi language enum %v len %d, want Codes %v", got, len(got), Codes)
	}
	for i, code := range Codes {
		if got[i] != code {
			t.Fatalf("openapi language enum[%d]=%q want %q (full %v)", i, got[i], code, got)
		}
	}
}
