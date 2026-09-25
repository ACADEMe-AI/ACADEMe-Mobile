package auth

import (
	"math"
	"net/http"
	"net/netip"
	"strconv"
	"time"
)

const (
	logInsPerEmailIP   = 10
	logInsPerIPHour    = 50
	signUpsPerIPHour   = 10
	googlePerIPHour    = 30
	logInEmailIPWindow = 15 * time.Minute
)

type entryLimits struct {
	logInEmailIP *limiter
	logInIP      *limiter
	signUpIP     *limiter
	googleIP     *limiter
}

func newEntryLimits() entryLimits {
	return entryLimits{
		logInEmailIP: newLimiter(logInsPerEmailIP, logInEmailIPWindow),
		logInIP:      newLimiter(logInsPerIPHour, time.Hour),
		signUpIP:     newLimiter(signUpsPerIPHour, time.Hour),
		googleIP:     newLimiter(googlePerIPHour, time.Hour),
	}
}

type gate struct {
	limiter *limiter
	key     string
}

func admit(w http.ResponseWriter, gates ...gate) error {
	for _, g := range gates {
		if wait := g.limiter.wait(g.key); wait > 0 {
			w.Header().Set("Retry-After", strconv.Itoa(int(math.Ceil(wait.Seconds()))))
			return toHTTP(ErrThrottled)
		}
	}
	return nil
}

func logInKey(email, ip string) string {
	email = normalizeEmail(email)
	return email[:min(len(email), maxEmailLength)] + " " + ip
}

func clientIP(r *http.Request) string {
	addr, err := netip.ParseAddrPort(r.RemoteAddr)
	if err != nil {
		return r.RemoteAddr
	}
	ip := addr.Addr().Unmap()
	if ip.Is6() {
		network, _ := ip.Prefix(64)
		return network.String()
	}
	return ip.String()
}
