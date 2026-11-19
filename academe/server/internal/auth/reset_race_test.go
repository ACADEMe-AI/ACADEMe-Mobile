package auth

import (
	"errors"
	"strconv"
	"sync"
	"testing"
)

func parallel(n int, run func(i int) error) []error {
	errs := make([]error, n)
	var wg sync.WaitGroup
	for i := range n {
		wg.Go(func() { errs[i] = run(i) })
	}
	wg.Wait()
	return errs
}

func count(errs []error, target error) int {
	n := 0
	for _, err := range errs {
		if errors.Is(err, target) || (target == nil && err == nil) {
			n++
		}
	}
	return n
}

func TestPasswordResetRacesPostgres(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	mailer := &fakeMailer{}
	s := NewService(store, []byte("0123456789abcdef0123456789abcdef"), nil, mailer)
	ctx := t.Context()
	if _, _, err := s.SignUp(ctx, SignUpInput{FirstName: "Maya", LastName: "Rao", Email: "maya@example.com", Password: "correct horse"}); err != nil {
		t.Fatal(err)
	}
	const racers = 40
	request := func() string {
		t.Helper()
		if err := s.RequestPasswordReset(ctx, " Maya@Example.COM ", "198.51.100.1"); err != nil {
			t.Fatalf("RequestPasswordReset = %v", err)
		}
		return mailer.last(t).Code
	}
	verify := func(code string, i int) (string, error) {
		return s.VerifyResetCode(ctx, "maya@example.com", code, "203.0.113."+strconv.Itoa(i))
	}

	code := request()
	errs := parallel(racers, func(i int) error {
		_, err := verify(wrongCode(code), i)
		return err
	})
	if got := count(errs, ErrWrongCode); got != maxResetAttempts-1 {
		t.Errorf("%d parallel wrong codes: %d wrong_code, want %d", racers, got, maxResetAttempts-1)
	}
	if got := count(errs, ErrTooManyAttempts); got != racers-maxResetAttempts+1 {
		t.Errorf("%d parallel wrong codes: %d too_many_attempts, want %d", racers, got, racers-maxResetAttempts+1)
	}
	if _, err := verify(code, 99); !errors.Is(err, ErrTooManyAttempts) {
		t.Errorf("right code after a burned race = %v, want ErrTooManyAttempts", err)
	}

	code = request()
	tokens := make([]string, racers)
	errs = parallel(racers, func(i int) error {
		var err error
		tokens[i], err = verify(code, i)
		return err
	})
	if got := count(errs, nil); got != 1 {
		t.Fatalf("%d parallel right codes: %d tokens, want 1 (errors %v)", racers, got, errs)
	}
	var token string
	for i, err := range errs {
		if err == nil {
			token = tokens[i]
		}
	}

	errs = parallel(racers, func(i int) error {
		_, _, err := s.CompletePasswordReset(ctx, token, "new password "+strconv.Itoa(i))
		return err
	})
	if got := count(errs, nil); got != 1 {
		t.Errorf("%d parallel completes: %d succeeded, want 1 (errors %v)", racers, got, errs)
	}
	if got := count(errs, ErrResetTokenExpired); got != racers-1 {
		t.Errorf("%d parallel completes: %d reset_expired, want %d", racers, got, racers-1)
	}
}

func TestResetCodeAndLinkRacePostgres(t *testing.T) {
	store := NewPostgresStore(openTestPool(t))
	mailer := &fakeMailer{}
	s := NewService(store, []byte("0123456789abcdef0123456789abcdef"), nil, mailer)
	ctx := t.Context()
	for round := range 20 {
		address := "maya" + strconv.Itoa(round) + "@example.com"
		if _, _, err := s.SignUp(ctx, SignUpInput{FirstName: "Maya", LastName: "Rao", Email: address, Password: "correct horse"}); err != nil {
			t.Fatal(err)
		}
		if err := s.RequestPasswordReset(ctx, address, "198.51.100."+strconv.Itoa(round)); err != nil {
			t.Fatal(err)
		}
		sent := mailer.last(t)
		tokens := make([]string, 2)
		errs := parallel(2, func(i int) error {
			var err error
			ip := "203.0.113." + strconv.Itoa(round*2+i)
			if i == 0 {
				tokens[i], err = s.VerifyResetCode(ctx, address, sent.Code, ip)
			} else {
				tokens[i], err = s.RedeemResetLink(ctx, sent.LinkToken, ip)
			}
			return err
		})
		if got := count(errs, nil); got != 1 {
			t.Fatalf("round %d: code and link raced: %d reset tokens, want exactly 1 (errors %v)", round, got, errs)
		}
		for i, err := range errs {
			if err != nil && !errors.Is(err, ErrCodeExpired) && !errors.Is(err, ErrResetTokenExpired) {
				t.Errorf("round %d: loser %d = %v, want an expired error", round, i, err)
			}
		}
	}
}
