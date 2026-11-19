package ai

import (
	"errors"
	"fmt"
	"net/http"
)

var ErrUnavailable = errors.New("ai provider unavailable")

type StatusError struct {
	Provider string
	Code     int
	Detail   string
}

func (e *StatusError) Error() string {
	return fmt.Sprintf("%s status %d: %s", e.Provider, e.Code, e.Detail)
}

func (e *StatusError) Is(target error) bool {
	return target == ErrUnavailable && (e.Code == http.StatusUnauthorized || e.Code == http.StatusPaymentRequired ||
		e.Code == http.StatusForbidden || e.Code == http.StatusTooManyRequests || e.Code >= http.StatusInternalServerError)
}
