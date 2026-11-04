package site

import (
	"encoding/json"
	"fmt"
	"net/http"
	"regexp"
)

const androidPackage = "com.academe.flutter"

var certFingerprint = regexp.MustCompile(`^([0-9A-F]{2}:){31}[0-9A-F]{2}$`)

func serveEmailAsset(w http.ResponseWriter, r *http.Request) {
	h := w.Header()
	h.Set("Cache-Control", "public, max-age=604800")
	h.Set("Access-Control-Allow-Origin", "*")
	h.Set("X-Content-Type-Options", "nosniff")
	http.ServeFileFS(w, r, emailAssets, "email/"+r.PathValue("name")) //nolint:gosec
}

type assetLink struct {
	Relation []string    `json:"relation"`
	Target   assetTarget `json:"target"`
}

type assetTarget struct {
	Namespace    string   `json:"namespace"`
	PackageName  string   `json:"package_name"`
	Fingerprints []string `json:"sha256_cert_fingerprints"`
}

func assetLinks(certs []string) (http.HandlerFunc, error) {
	for _, c := range certs {
		if !certFingerprint.MatchString(c) {
			return nil, fmt.Errorf("android certificate fingerprint %q is not 32 colon-separated hex bytes", c)
		}
	}
	body, err := json.Marshal([]assetLink{{
		Relation: []string{"delegate_permission/common.handle_all_urls"},
		Target:   assetTarget{Namespace: "android_app", PackageName: androidPackage, Fingerprints: certs},
	}})
	if err != nil {
		return nil, fmt.Errorf("encode asset links: %w", err)
	}
	return func(w http.ResponseWriter, r *http.Request) {
		if len(certs) == 0 {
			http.NotFound(w, r)
			return
		}
		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Cache-Control", "public, max-age=3600")
		_, _ = w.Write(body)
	}, nil
}
