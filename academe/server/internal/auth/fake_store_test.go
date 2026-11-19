package auth

import (
	"context"
	"strconv"
	"sync"
	"time"
)

type fakeSession struct {
	accountID string
	expires   time.Time
}

type fakeDeletion struct {
	reason string
	at     time.Time
}

type fakeStore struct {
	mu         sync.Mutex
	accounts   map[string]Account
	hashes     map[string]string
	google     map[string]string
	gmail      map[string]string
	sessions   map[string]fakeSession
	deletions  map[string]fakeDeletion
	resets     []*fakeReset
	validAfter map[string]time.Time
}

func newFakeStore() *fakeStore {
	return &fakeStore{
		accounts:   map[string]Account{},
		hashes:     map[string]string{},
		google:     map[string]string{},
		gmail:      map[string]string{},
		sessions:   map[string]fakeSession{},
		deletions:  map[string]fakeDeletion{},
		validAfter: map[string]time.Time{},
	}
}

func (f *fakeStore) CreateAccount(_ context.Context, a Account, passwordHash string) (Account, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, existing := range f.accounts {
		if existing.Email == a.Email {
			return Account{}, ErrEmailTaken
		}
	}
	a.ID = "account-" + strconv.Itoa(len(f.accounts)+1)
	f.accounts[a.ID] = a
	f.hashes[a.ID] = passwordHash
	return f.view(a.ID), nil
}

func (f *fakeStore) view(id string) Account {
	a := f.accounts[id]
	a.HasPassword = f.hashes[id] != ""
	a.GoogleEmail = f.gmail[id]
	return a
}

func (f *fakeStore) AccountByEmail(_ context.Context, email string) (Account, string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, a := range f.accounts {
		if a.Email == email {
			return f.view(a.ID), f.hashes[a.ID], nil
		}
	}
	return Account{}, "", ErrNotFound
}

func (f *fakeStore) AccountByID(_ context.Context, id string) (Account, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if _, ok := f.accounts[id]; !ok {
		return Account{}, ErrNotFound
	}
	return f.view(id), nil
}

func (f *fakeStore) CreateSession(_ context.Context, accountID string, tokenHash []byte, expires time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.sessions[string(tokenHash)] = fakeSession{accountID, expires}
	return nil
}

func (f *fakeStore) RotateSession(_ context.Context, oldHash, newHash []byte, expires time.Time) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	old, ok := f.sessions[string(oldHash)]
	if !ok || !time.Now().Before(old.expires) {
		return "", ErrInvalidToken
	}
	delete(f.sessions, string(oldHash))
	f.sessions[string(newHash)] = fakeSession{old.accountID, expires}
	return old.accountID, nil
}

func (f *fakeStore) DeleteSession(_ context.Context, tokenHash []byte) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	delete(f.sessions, string(tokenHash))
	return nil
}

func (f *fakeStore) AccountByGoogleSubject(_ context.Context, subject string) (Account, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	id, ok := f.google[subject]
	if !ok {
		return Account{}, ErrNotFound
	}
	return f.view(id), nil
}

func (f *fakeStore) CreateGoogleAccount(ctx context.Context, a Account, subject string) (Account, error) {
	a, err := f.CreateAccount(ctx, a, "")
	if err != nil {
		return Account{}, err
	}
	if err := f.LinkGoogle(ctx, a.ID, subject, a.Email, time.Time{}); err != nil {
		return Account{}, err
	}
	return f.AccountByID(ctx, a.ID)
}

func (f *fakeStore) LinkGoogle(_ context.Context, accountID, subject, email string, at time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.google[subject] = accountID
	f.gmail[accountID] = email
	f.validAfter[accountID] = at
	f.hashes[accountID] = ""
	for hash, session := range f.sessions {
		if session.accountID == accountID {
			delete(f.sessions, hash)
		}
	}
	return nil
}

func (f *fakeStore) ScheduleDeletion(_ context.Context, id, reason string, at time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if _, ok := f.accounts[id]; !ok {
		return ErrNotFound
	}
	f.deletions[id] = fakeDeletion{reason: reason, at: at}
	f.validAfter[id] = at
	for hash, s := range f.sessions {
		if s.accountID == id {
			delete(f.sessions, hash)
		}
	}
	return nil
}

func (f *fakeStore) CancelDeletion(_ context.Context, id string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	delete(f.deletions, id)
	return nil
}

func (f *fakeStore) PurgeDeleted(_ context.Context, requestedBefore time.Time) ([]string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	var ids []string
	for id, d := range f.deletions {
		if d.at.Before(requestedBefore) {
			delete(f.accounts, id)
			delete(f.hashes, id)
			delete(f.deletions, id)
			ids = append(ids, id)
		}
	}
	return ids, nil
}

func (f *fakeStore) PurgeExpired(context.Context, time.Time) error { return nil }

func (f *fakeStore) TokensValidAfter(_ context.Context, accountID string) (time.Time, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if _, ok := f.accounts[accountID]; !ok {
		return time.Time{}, ErrNotFound
	}
	return f.validAfter[accountID], nil
}

func (f *fakeStore) UpdateName(_ context.Context, id, firstName, lastName string) (Account, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	a, ok := f.accounts[id]
	if !ok {
		return Account{}, ErrNotFound
	}
	a.FirstName, a.LastName = firstName, lastName
	f.accounts[id] = a
	return f.view(id), nil
}

func (f *fakeStore) PasswordHash(_ context.Context, accountID string) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if _, ok := f.accounts[accountID]; !ok {
		return "", ErrNotFound
	}
	return f.hashes[accountID], nil
}

func (f *fakeStore) ChangePassword(_ context.Context, accountID, oldHash, newHash string, at time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if _, ok := f.accounts[accountID]; !ok || f.hashes[accountID] != oldHash {
		return ErrWrongPassword
	}
	f.hashes[accountID] = newHash
	f.validAfter[accountID] = at
	for hash, s := range f.sessions {
		if s.accountID == accountID {
			delete(f.sessions, hash)
		}
	}
	return nil
}

func (f *fakeStore) AddGoogle(_ context.Context, accountID, subject, email string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if owner, ok := f.google[subject]; ok && owner != accountID {
		return ErrGoogleTaken
	}
	for s, owner := range f.google {
		if owner == accountID {
			delete(f.google, s)
		}
	}
	f.google[subject] = accountID
	f.gmail[accountID] = email
	return nil
}

func (f *fakeStore) RemoveGoogle(_ context.Context, accountID string) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.hashes[accountID] == "" {
		return ErrPasswordRequired
	}
	for s, owner := range f.google {
		if owner == accountID {
			delete(f.google, s)
		}
	}
	delete(f.gmail, accountID)
	return nil
}

type fakeGoogle map[string]GoogleIdentity

func (f fakeGoogle) Verify(_ context.Context, idToken string) (GoogleIdentity, error) {
	identity, ok := f[idToken]
	if !ok {
		return GoogleIdentity{}, ErrGoogleToken
	}
	return identity, nil
}
