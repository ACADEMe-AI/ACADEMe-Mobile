package lang

import "strings"

func Normalize(code string) string {
	switch strings.ToLower(strings.TrimSpace(code)) {
	case "hi", "te", "ta", "bn":
		return strings.ToLower(strings.TrimSpace(code))
	default:
		return "en"
	}
}

func Supported(code string) bool {
	switch Normalize(code) {
	case "en", "hi", "te", "ta", "bn":
		return true
	default:
		return false
	}
}
