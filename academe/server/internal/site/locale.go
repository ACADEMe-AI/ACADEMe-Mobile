package site

import (
	"net/http"
	"strings"
)

const defaultLang = "en"

var supportedLangs = map[string]bool{
	"en": true,
	"hi": true,
	"te": true,
	"ta": true,
	"bn": true,
}

type chrome struct {
	Privacy             string
	Terms               string
	DeleteAccount       string
	Support             string
	FooterRunBy         string
	FooterQuestions     string
	PrivacyPolicy       string
	TermsOfUse          string
	DeleteYourAccount   string
	SupportAndGrievance string
}

var chromes = map[string]chrome{
	"en": {
		Privacy:             "Privacy",
		Terms:               "Terms",
		DeleteAccount:       "Delete account",
		Support:             "Support",
		FooterRunBy:         "ACADEMe is run by ACADEMe, Hyderabad, Telangana, India.",
		FooterQuestions:     "Questions:",
		PrivacyPolicy:       "Privacy policy",
		TermsOfUse:          "Terms of use",
		DeleteYourAccount:   "Delete your account",
		SupportAndGrievance: "Support and grievances",
	},
	"hi": {
		Privacy:             "गोपनीयता",
		Terms:               "शर्तें",
		DeleteAccount:       "अकाउंट हटाएँ",
		Support:             "सहायता",
		FooterRunBy:         "ACADEMe को ACADEMe चलाता है, Hyderabad, Telangana, India।",
		FooterQuestions:     "सवाल:",
		PrivacyPolicy:       "गोपनीयता नीति",
		TermsOfUse:          "उपयोग की शर्तें",
		DeleteYourAccount:   "अपना अकाउंट हटाएँ",
		SupportAndGrievance: "सहायता और शिकायतें",
	},
	"te": {
		Privacy:             "గోప్యత",
		Terms:               "నిబంధనలు",
		DeleteAccount:       "ఖాతా తొలగించండి",
		Support:             "సహాయం",
		FooterRunBy:         "ACADEMe ను ACADEMe నడుపుతుంది, Hyderabad, Telangana, India.",
		FooterQuestions:     "ప్రశ్నలు:",
		PrivacyPolicy:       "గోప్యతా విధానం",
		TermsOfUse:          "వినియోగ నిబంధనలు",
		DeleteYourAccount:   "మీ ఖాతాను తొలగించండి",
		SupportAndGrievance: "సహాయం మరియు ఫిర్యాదులు",
	},
	"ta": {
		Privacy:             "தனியுரிமை",
		Terms:               "விதிமுறைகள்",
		DeleteAccount:       "கணக்கை நீக்கு",
		Support:             "உதவி",
		FooterRunBy:         "ACADEMe-ஐ ACADEMe நடத்துகிறது, Hyderabad, Telangana, India.",
		FooterQuestions:     "கேள்விகள்:",
		PrivacyPolicy:       "தனியுரிமைக் கொள்கை",
		TermsOfUse:          "பயன்பாட்டு விதிமுறைகள்",
		DeleteYourAccount:   "உங்கள் கணக்கை நீக்குங்கள்",
		SupportAndGrievance: "உதவி மற்றும் குறைகள்",
	},
	"bn": {
		Privacy:             "গোপনীয়তা",
		Terms:               "শর্তাবলী",
		DeleteAccount:       "অ্যাকাউন্ট মুছুন",
		Support:             "সহায়তা",
		FooterRunBy:         "ACADEMe পরিচালনা করে ACADEMe, Hyderabad, Telangana, India।",
		FooterQuestions:     "প্রশ্ন:",
		PrivacyPolicy:       "গোপনীয়তা নীতি",
		TermsOfUse:          "ব্যবহারের শর্তাবলী",
		DeleteYourAccount:   "আপনার অ্যাকাউন্ট মুছুন",
		SupportAndGrievance: "সহায়তা ও অভিযোগ",
	},
}

type pageView struct {
	view
	Lang string
	Q    string
	Nav  chrome
}

func resolveLang(r *http.Request) string {
	if lang := normalizeLang(r.URL.Query().Get("lang")); supportedLangs[lang] {
		return lang
	}
	for _, part := range strings.Split(r.Header.Get("Accept-Language"), ",") {
		tag := strings.TrimSpace(strings.SplitN(part, ";", 2)[0])
		if lang := normalizeLang(tag); supportedLangs[lang] {
			return lang
		}
		if i := strings.IndexByte(tag, '-'); i > 0 {
			if lang := normalizeLang(tag[:i]); supportedLangs[lang] {
				return lang
			}
		}
	}
	return defaultLang
}

func normalizeLang(raw string) string {
	return strings.ToLower(strings.TrimSpace(raw))
}

func langQuery(lang string) string {
	if lang == "" || lang == defaultLang {
		return ""
	}
	return "?lang=" + lang
}

func chromeFor(lang string) chrome {
	if c, ok := chromes[lang]; ok {
		return c
	}
	return chromes[defaultLang]
}

func (s *site) page(r *http.Request, v view) pageView {
	lang := resolveLang(r)
	return pageView{view: v, Lang: lang, Q: langQuery(lang), Nav: chromeFor(lang)}
}
