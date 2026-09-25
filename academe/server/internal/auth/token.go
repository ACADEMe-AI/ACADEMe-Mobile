package auth

import (
	"crypto/hmac"
	"crypto/sha256"
	"encoding/base64"
	"strconv"
	"strings"
	"time"
)

func signAccessToken(key []byte, accountID string, issued time.Time) string {
	payload := accountID + "." + strconv.FormatInt(issued.UnixMicro(), 10)
	return payload + "." + base64.RawURLEncoding.EncodeToString(mac(key, payload))
}

func verifyAccessToken(key []byte, token string, now time.Time) (string, time.Time, error) {
	i := strings.LastIndexByte(token, '.')
	if i < 0 {
		return "", time.Time{}, ErrInvalidToken
	}
	payload, signature := token[:i], token[i+1:]
	got, err := base64.RawURLEncoding.DecodeString(signature)
	if err != nil || !hmac.Equal(got, mac(key, payload)) {
		return "", time.Time{}, ErrInvalidToken
	}
	accountID, issuedAt, ok := strings.Cut(payload, ".")
	if !ok {
		return "", time.Time{}, ErrInvalidToken
	}
	micros, err := strconv.ParseInt(issuedAt, 10, 64)
	issued := time.UnixMicro(micros)
	if err != nil || !now.Before(issued.Add(accessTokenTTL)) {
		return "", time.Time{}, ErrInvalidToken
	}
	return accountID, issued, nil
}

func mac(key []byte, payload string) []byte {
	m := hmac.New(sha256.New, key)
	m.Write([]byte(payload))
	return m.Sum(nil)
}
