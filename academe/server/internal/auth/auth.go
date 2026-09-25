package auth

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"errors"
	"fmt"
	"log/slog"
	"net/mail"
	"strings"
	"sync"
	"time"
	"unicode/utf8"
)

var (
	ErrEmailTaken       = errors.New("email already has an account")
	ErrWrongCredentials = errors.New("wrong email or password")
	ErrInvalidToken     = errors.New("invalid token")
	ErrNotFound         = errors.New("account not found")
)

const (
	accessTokenTTL  = 15 * time.Minute
	refreshTokenTTL = 30 * 24 * time.Hour

	minPasswordLength = 8
	maxPasswordLength = 128
	maxNameLength     = 100
	maxEmailLength    = 254
)

type Account struct {
	ID          string `json:"id"`
	FirstName   string `json:"firstName"`
	LastName    string `json:"lastName"`
	Email       string `json:"email"`
	HasPassword bool   `json:"hasPassword"`
	GoogleEmail string `json:"googleEmail,omitempty"`
}

type Tokens struct {
	AccessToken  string `json:"accessToken"`
	RefreshToken string `json:"refreshToken"`
	ExpiresIn    int    `json:"expiresIn"`
}

type SignUpInput struct {
	FirstName string `json:"firstName"`
	LastName  string `json:"lastName"`
	Email     string `json:"email"`
	Password  string `json:"password"`
}

type ValidationError struct {
	Field   string
	Problem string
}

func (e *ValidationError) Error() string { return e.Field + " " + e.Problem }

type Store interface {
	CreateAccount(ctx context.Context, a Account, passwordHash string) (Account, error)
	AccountByEmail(ctx context.Context, email string) (Account, string, error)
	AccountByID(ctx context.Context, id string) (Account, error)
	AccountByGoogleSubject(ctx context.Context, subject string) (Account, error)
	CreateGoogleAccount(ctx context.Context, a Account, subject string) (Account, error)
	LinkGoogle(ctx context.Context, accountID, subject, email string, at time.Time) error
	AddGoogle(ctx context.Context, accountID, subject, email string) error
	RemoveGoogle(ctx context.Context, accountID string) error
	PasswordHash(ctx context.Context, accountID string) (string, error)
	ChangePassword(ctx context.Context, accountID, oldHash, newHash string, at time.Time) error
	UpdateName(ctx context.Context, id, firstName, lastName string) (Account, error)
	ScheduleDeletion(ctx context.Context, id, reason string, at time.Time) error
	CancelDeletion(ctx context.Context, id string) error
	PurgeDeleted(ctx context.Context, requestedBefore time.Time) ([]string, error)
	PurgeExpired(ctx context.Context, now time.Time) error
	CreateSession(ctx context.Context, accountID string, tokenHash []byte, expires time.Time) error
	RotateSession(ctx context.Context, oldHash, newHash []byte, expires time.Time) (string, error)
	DeleteSession(ctx context.Context, tokenHash []byte) error
	CreateResetCode(ctx context.Context, accountID string, codeHash, linkHash []byte, expires time.Time) error
	ClaimResetLink(ctx context.Context, linkHash []byte) (ResetCode, error)
	ClaimResetAttempt(ctx context.Context, accountID string) (ResetCode, error)
	MarkResetCodeUsed(ctx context.Context, codeID string, tokenHash []byte, at time.Time) error
	CompleteReset(ctx context.Context, tokenHash []byte, verifiedAfter time.Time, passwordHash string, at time.Time) (string, error)
	TokensValidAfter(ctx context.Context, accountID string) (time.Time, error)
}

type SubscriberDeleter interface {
	DeleteSubscriber(ctx context.Context, accountID string) error
}

type Service struct {
	store       Store
	tokenKey    []byte
	google      GoogleVerifier
	mailer      Mailer
	limits      resetLimits
	entry       entryLimits
	dummyHash   string
	subscribers SubscriberDeleter
	revoked     *revocations
	logger      *slog.Logger
	background  sync.WaitGroup
}

func (s *Service) SetSubscriberDeleter(d SubscriberDeleter) { s.subscribers = d }

func NewService(store Store, tokenKey []byte, google GoogleVerifier, mailer Mailer) *Service {
	return &Service{
		store:     store,
		tokenKey:  tokenKey,
		google:    google,
		mailer:    mailer,
		limits:    newResetLimits(),
		entry:     newEntryLimits(),
		dummyHash: hashPassword(rand.Text()),
		revoked:   newRevocations(),
		logger:    slog.New(slog.DiscardHandler),
	}
}

func (s *Service) SignUp(ctx context.Context, in SignUpInput) (Account, Tokens, error) {
	in.FirstName = strings.TrimSpace(in.FirstName)
	in.LastName = strings.TrimSpace(in.LastName)
	in.Email = normalizeEmail(in.Email)
	if err := in.validate(); err != nil {
		return Account{}, Tokens{}, err
	}
	a, err := s.store.CreateAccount(ctx, Account{
		FirstName: in.FirstName,
		LastName:  in.LastName,
		Email:     in.Email,
	}, hashPassword(in.Password))
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("sign up: %w", err)
	}
	tokens, err := s.startSession(ctx, a.ID)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("sign up: %w", err)
	}
	s.welcome(ctx, a)
	return a, tokens, nil
}

func (s *Service) LogIn(ctx context.Context, email, password string) (Account, Tokens, error) {
	if utf8.RuneCountInString(password) > maxPasswordLength {
		return Account{}, Tokens{}, ErrWrongCredentials
	}
	a, hash, err := s.store.AccountByEmail(ctx, normalizeEmail(email))
	if errors.Is(err, ErrNotFound) {
		_, _ = checkPassword(password, s.dummyHash)
		return Account{}, Tokens{}, ErrWrongCredentials
	}
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("log in: %w", err)
	}
	if hash == "" {
		_, _ = checkPassword(password, s.dummyHash)
		return Account{}, Tokens{}, ErrWrongCredentials
	}
	ok, err := checkPassword(password, hash)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("log in: %w", err)
	}
	if !ok {
		return Account{}, Tokens{}, ErrWrongCredentials
	}
	tokens, err := s.startSession(ctx, a.ID)
	if err != nil {
		return Account{}, Tokens{}, fmt.Errorf("log in: %w", err)
	}
	return a, tokens, nil
}

func (s *Service) SignInWithGoogle(ctx context.Context, idToken string) (Account, Tokens, bool, error) {
	if s.google == nil {
		return Account{}, Tokens{}, false, ErrGoogleUnavailable
	}
	identity, err := s.google.Verify(ctx, idToken)
	if err != nil {
		return Account{}, Tokens{}, false, fmt.Errorf("google sign-in: %w", err)
	}
	a, created, err := s.googleAccount(ctx, identity)
	if err != nil {
		return Account{}, Tokens{}, false, fmt.Errorf("google sign-in: %w", err)
	}
	tokens, err := s.startSession(ctx, a.ID)
	if err != nil {
		return Account{}, Tokens{}, false, fmt.Errorf("google sign-in: %w", err)
	}
	if created {
		s.welcome(ctx, a)
	}
	return a, tokens, created, nil
}

func (s *Service) googleAccount(ctx context.Context, identity GoogleIdentity) (Account, bool, error) {
	a, err := s.store.AccountByGoogleSubject(ctx, identity.Subject)
	if err == nil || !errors.Is(err, ErrNotFound) {
		return a, false, err
	}
	a, _, err = s.store.AccountByEmail(ctx, identity.Email)
	if err == nil {
		at := revocationTime()
		if err := s.store.LinkGoogle(ctx, a.ID, identity.Subject, identity.Email, at); err != nil {
			return Account{}, false, err
		}
		s.revokeAccessTokens(a.ID, at)
		a.HasPassword, a.GoogleEmail = false, identity.Email
		return a, false, nil
	}
	if !errors.Is(err, ErrNotFound) {
		return Account{}, false, err
	}
	a, err = s.store.CreateGoogleAccount(ctx, Account{
		FirstName: clip(strings.TrimSpace(identity.GivenName)),
		LastName:  clip(strings.TrimSpace(identity.FamilyName)),
		Email:     identity.Email,
	}, identity.Subject)
	return a, err == nil, err
}

func (s *Service) UpdateName(ctx context.Context, id, firstName, lastName string) (Account, error) {
	firstName, lastName = strings.TrimSpace(firstName), strings.TrimSpace(lastName)
	if err := validateNames(firstName, lastName); err != nil {
		return Account{}, err
	}
	a, err := s.store.UpdateName(ctx, id, firstName, lastName)
	if err != nil {
		return Account{}, fmt.Errorf("update name: %w", err)
	}
	return a, nil
}

const (
	DeletionGrace     = 30 * 24 * time.Hour
	maxDeletionReason = 500
)

func (s *Service) DeleteAccount(ctx context.Context, id, reason string) (time.Time, error) {
	reason = strings.TrimSpace(reason)
	if utf8.RuneCountInString(reason) > maxDeletionReason {
		return time.Time{}, &ValidationError{"reason", "is too long"}
	}
	now := revocationTime()
	if err := s.store.ScheduleDeletion(ctx, id, reason, now); err != nil {
		return time.Time{}, fmt.Errorf("schedule deletion: %w", err)
	}
	s.revokeAccessTokens(id, now)
	return now.Add(DeletionGrace), nil
}

func (s *Service) PurgeDeleted(ctx context.Context) (int64, error) {
	ids, err := s.store.PurgeDeleted(ctx, time.Now().Add(-DeletionGrace))
	if err != nil {
		return 0, fmt.Errorf("purge deleted accounts: %w", err)
	}
	var errs []error
	for _, id := range ids {
		if s.subscribers == nil {
			break
		}
		if err := s.subscribers.DeleteSubscriber(ctx, id); err != nil {
			errs = append(errs, fmt.Errorf("delete subscriber %s: %w", id, err))
		}
	}
	return int64(len(ids)), errors.Join(errs...)
}

func (s *Service) Refresh(ctx context.Context, refreshToken string) (Tokens, error) {
	next := rand.Text()
	accountID, err := s.store.RotateSession(ctx,
		hashToken(refreshToken), hashToken(next), time.Now().Add(refreshTokenTTL))
	if err != nil {
		return Tokens{}, fmt.Errorf("refresh: %w", err)
	}
	return s.tokens(accountID, next), nil
}

func (s *Service) LogOut(ctx context.Context, refreshToken string) error {
	if err := s.store.DeleteSession(ctx, hashToken(refreshToken)); err != nil {
		return fmt.Errorf("log out: %w", err)
	}
	return nil
}

func (s *Service) Account(ctx context.Context, id string) (Account, error) {
	a, err := s.store.AccountByID(ctx, id)
	if err != nil {
		return Account{}, fmt.Errorf("get account: %w", err)
	}
	return a, nil
}

func (s *Service) startSession(ctx context.Context, accountID string) (Tokens, error) {
	if err := s.store.CancelDeletion(ctx, accountID); err != nil {
		return Tokens{}, fmt.Errorf("cancel deletion: %w", err)
	}
	refresh := rand.Text()
	if err := s.store.CreateSession(ctx, accountID,
		hashToken(refresh), time.Now().Add(refreshTokenTTL)); err != nil {
		return Tokens{}, fmt.Errorf("create session: %w", err)
	}
	return s.tokens(accountID, refresh), nil
}

func (s *Service) tokens(accountID, refreshToken string) Tokens {
	return Tokens{
		AccessToken:  signAccessToken(s.tokenKey, accountID, time.Now()),
		RefreshToken: refreshToken,
		ExpiresIn:    int(accessTokenTTL.Seconds()),
	}
}

func validateNames(firstName, lastName string) error {
	switch {
	case firstName == "":
		return &ValidationError{"firstName", "is required"}
	case utf8.RuneCountInString(firstName) > maxNameLength:
		return &ValidationError{"firstName", "is too long"}
	case lastName == "":
		return &ValidationError{"lastName", "is required"}
	case utf8.RuneCountInString(lastName) > maxNameLength:
		return &ValidationError{"lastName", "is too long"}
	}
	return nil
}

func clip(name string) string {
	if runes := []rune(name); len(runes) > maxNameLength {
		return string(runes[:maxNameLength])
	}
	return name
}

func (in SignUpInput) validate() error {
	if err := validateNames(in.FirstName, in.LastName); err != nil {
		return err
	}
	if len(in.Email) > maxEmailLength || !isEmail(in.Email) {
		return &ValidationError{"email", "is not an email address"}
	}
	return validatePassword(in.Password)
}

func isEmail(s string) bool {
	addr, err := mail.ParseAddress(s)
	return err == nil && addr.Address == s
}

func normalizeEmail(email string) string {
	return strings.ToLower(strings.TrimSpace(email))
}

func hashToken(token string) []byte {
	sum := sha256.Sum256([]byte(token))
	return sum[:]
}
