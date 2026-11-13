package site

import (
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestResolveLang(t *testing.T) {
	tests := []struct {
		name   string
		query  string
		accept string
		want   string
	}{
		{"default", "", "", "en"},
		{"query hi", "hi", "", "hi"},
		{"query te", "te", "", "te"},
		{"query ta", "ta", "", "ta"},
		{"query bn", "bn", "", "bn"},
		{"query as", "as", "", "as"},
		{"query en", "en", "", "en"},
		{"unknown query falls back to accept", "fr", "hi", "hi"},
		{"unknown both", "fr", "de", "en"},
		{"accept hi", "", "hi", "hi"},
		{"accept hi-IN", "", "hi-IN,hi;q=0.9,en;q=0.8", "hi"},
		{"accept te-IN", "", "te-IN", "te"},
		{"query wins over accept", "bn", "hi", "bn"},
		{"case insensitive query", "HI", "", "hi"},
		{"whitespace query", " ta ", "", "ta"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			req := httptest.NewRequestWithContext(t.Context(), http.MethodGet, "/privacy", nil)
			if tc.query != "" {
				q := req.URL.Query()
				q.Set("lang", tc.query)
				req.URL.RawQuery = q.Encode()
			}
			if tc.accept != "" {
				req.Header.Set("Accept-Language", tc.accept)
			}
			if got := resolveLang(req); got != tc.want {
				t.Errorf("resolveLang() = %q, want %q", got, tc.want)
			}
		})
	}
}

func TestLangQuery(t *testing.T) {
	if got := langQuery("en"); got != "" {
		t.Errorf("langQuery(en) = %q, want \"\"", got)
	}
	if got := langQuery("hi"); got != "?lang=hi" {
		t.Errorf("langQuery(hi) = %q, want ?lang=hi", got)
	}
}

func TestLocalizedLegalPages(t *testing.T) {
	mux, _, _ := newSite(t)
	tests := []struct {
		path string
		lang string
		want []string
	}{
		{"/privacy", "hi", []string{`lang="hi"`, "गोपनीयता नीति", "गोपनीयता", "Hyderabad, Telangana, India", "support@academe.cc", "/privacy?lang=hi", "com.academe.flutter", "Google Cloud"}},
		{"/terms", "te", []string{`lang="te"`, "వినియోగ నిబంధనలు", "గోప్యత", "Hyderabad, Telangana", "support@academe.cc", "/terms?lang=te"}},
		{"/support", "ta", []string{`lang="ta"`, "உதவி", "ACADEMe Grievance Officer", "Hyderabad, Telangana, India", "support@academe.cc", "/support?lang=ta"}},
		{"/delete-account", "bn", []string{`lang="bn"`, "অ্যাকাউন্ট মুছুন", "support@academe.cc", "/delete-account?lang=bn", "RevenueCat"}},
		{"/privacy", "en", []string{`lang="en"`, "Privacy policy", "Privacy", `href="/privacy"`, "Google Cloud"}},
	}
	for _, tc := range tests {
		t.Run(tc.path+"_"+tc.lang, func(t *testing.T) {
			url := tc.path
			if tc.lang != "en" {
				url += "?lang=" + tc.lang
			}
			rec := httptest.NewRecorder()
			mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), "GET", url, nil))
			body := rec.Body.String()
			if rec.Code != http.StatusOK {
				t.Fatalf("GET %s = %d, want 200", url, rec.Code)
			}
			if got := rec.Header().Get("Content-Language"); got != tc.lang {
				t.Errorf("Content-Language = %q, want %q", got, tc.lang)
			}
			for _, w := range tc.want {
				if !strings.Contains(body, w) {
					t.Errorf("GET %s missing %q", url, w)
				}
			}
			if strings.Contains(body, "FILL:") {
				t.Errorf("GET %s contains FILL placeholder", url)
			}
			if tc.lang != "en" && strings.Contains(body, `href="/privacy"`) && !strings.Contains(body, `href="/privacy?lang=`) {
				t.Errorf("GET %s has bare /privacy link without lang", url)
			}
		})
	}
}

func TestAcceptLanguageSelectsBody(t *testing.T) {
	mux, _, _ := newSite(t)
	req := httptest.NewRequestWithContext(t.Context(), "GET", "/support", nil)
	req.Header.Set("Accept-Language", "bn-IN,bn;q=0.9")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	body := rec.Body.String()
	if rec.Code != http.StatusOK || !strings.Contains(body, "সহায়তা") {
		t.Errorf("GET /support with Accept-Language bn = %d, want Bengali support copy", rec.Code)
	}
	if !strings.Contains(body, `lang="bn"`) {
		t.Errorf("html lang = want bn")
	}
}

func TestDefaultURLIsEnglish(t *testing.T) {
	mux, _, _ := newSite(t)
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, httptest.NewRequestWithContext(t.Context(), "GET", "/privacy", nil))
	body := rec.Body.String()
	if !strings.Contains(body, `lang="en"`) || !strings.Contains(body, "Privacy policy") {
		t.Errorf("GET /privacy without lang should be English")
	}
	if strings.Contains(body, "?lang=") {
		t.Errorf("GET /privacy English page should not emit ?lang= in links: found in body")
	}
}

func TestDeleteAccountKeepsLangOnPost(t *testing.T) {
	mux, _, _ := newSite(t)
	form := "email=riya%40example.com"
	req := httptest.NewRequestWithContext(t.Context(), "POST", "/delete-account?lang=hi", strings.NewReader(form))
	req.Header.Set("Content-Type", "application/x-www-form-urlencoded")
	rec := httptest.NewRecorder()
	mux.ServeHTTP(rec, req)
	body := rec.Body.String()
	if rec.Code != http.StatusOK || !strings.Contains(body, "अनुरोध मिल गया") {
		t.Errorf("POST /delete-account?lang=hi = %d, want Hindi confirmation", rec.Code)
	}
	if !strings.Contains(body, `lang="hi"`) || !strings.Contains(body, "गोपनीयता") {
		t.Errorf("POST confirmation should keep Hindi chrome")
	}
}
