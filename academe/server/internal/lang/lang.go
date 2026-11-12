package lang

import "strings"

var Codes = []string{"en", "hi", "te", "ta", "bn", "as"}

var englishNames = map[string]string{
	"en": "English",
	"hi": "Hindi",
	"te": "Telugu",
	"ta": "Tamil",
	"bn": "Bengali",
	"as": "Assamese",
}

func Normalize(code string) string {
	code = strings.ToLower(strings.TrimSpace(code))
	if Supported(code) {
		return code
	}
	return "en"
}

func Supported(code string) bool {
	_, ok := englishNames[strings.ToLower(strings.TrimSpace(code))]
	return ok
}

func EnglishName(code string) string {
	if name, ok := englishNames[Normalize(code)]; ok {
		return name
	}
	return "English"
}
