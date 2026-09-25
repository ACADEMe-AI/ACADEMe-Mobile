package auth

import (
	"crypto/rand"
	"crypto/subtle"
	"encoding/base64"
	"errors"
	"fmt"
	"strings"
	"unicode/utf8"

	"golang.org/x/crypto/argon2"
)

const (
	argonMemoryKiB = 19 * 1024
	argonTime      = 2
	argonThreads   = 1
	argonKeyLength = 32
	saltLength     = 16
)

var errMalformedHash = errors.New("malformed password hash")

var b64 = base64.RawStdEncoding

func hashPassword(password string) string {
	salt := make([]byte, saltLength)
	_, _ = rand.Read(salt)
	key := argon2.IDKey([]byte(password), salt, argonTime, argonMemoryKiB, argonThreads, argonKeyLength)
	return fmt.Sprintf("$argon2id$v=%d$m=%d,t=%d,p=%d$%s$%s",
		argon2.Version, argonMemoryKiB, argonTime, argonThreads,
		b64.EncodeToString(salt), b64.EncodeToString(key))
}

func checkPassword(password, hash string) (bool, error) {
	parts := strings.Split(hash, "$")
	if len(parts) != 6 || parts[1] != "argon2id" {
		return false, errMalformedHash
	}
	var version int
	if _, err := fmt.Sscanf(parts[2], "v=%d", &version); err != nil || version != argon2.Version {
		return false, errMalformedHash
	}
	var memory, time uint32
	var threads uint8
	if _, err := fmt.Sscanf(parts[3], "m=%d,t=%d,p=%d", &memory, &time, &threads); err != nil {
		return false, errMalformedHash
	}
	salt, err := b64.DecodeString(parts[4])
	if err != nil {
		return false, errMalformedHash
	}
	want, err := b64.DecodeString(parts[5])
	if err != nil || len(want) != argonKeyLength {
		return false, errMalformedHash
	}
	got := argon2.IDKey([]byte(password), salt, time, memory, threads, argonKeyLength)
	return subtle.ConstantTimeCompare(got, want) == 1, nil
}

func validatePassword(password string) error {
	switch {
	case utf8.RuneCountInString(password) < minPasswordLength:
		return &ValidationError{"password", fmt.Sprintf("must be at least %d characters", minPasswordLength)}
	case utf8.RuneCountInString(password) > maxPasswordLength:
		return &ValidationError{"password", fmt.Sprintf("must be at most %d characters", maxPasswordLength)}
	}
	return nil
}
