package lang

import "testing"

func TestNormalize(t *testing.T) {
	cases := map[string]string{
		"": "en", "EN": "en", "hi": "hi", "HI": "hi", "te-IN": "en", "ta": "ta", "bn": "bn", "fr": "en",
	}
	for in, want := range cases {
		if got := Normalize(in); got != want {
			t.Fatalf("Normalize(%q)=%q want %q", in, got, want)
		}
	}
}
