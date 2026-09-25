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
	return a, nil
}

func (f *fakeStore) AccountByEmail(_ context.Context, email string) (Account, string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, a := range f.accounts {
		if a.Email == email {
			return a, f.hashes[a.ID], nil
		}
	}
	return Account{}, "", ErrNotFound
}

func (f *fakeStore) AccountByID(_ context.Context, id string) (Account, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	a, ok := f.accounts[id]
	if !ok {
		return Account{}, ErrNotFound
	}
	return a, nil
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
	return f.accounts[id], nil
}

func (f *fakeStore) CreateGoogleAccount(ctx context.Context, a Account, subject string) (Account, error) {
	a, err := f.CreateAccount(ctx, a, "")
	if err != nil {
		return Account{}, err
	}
	return a, f.LinkGoogle(ctx, a.ID, subject, time.Time{})
}

func (f *fakeStore) LinkGoogle(_ context.Context, accountID, subject string, at time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.google[subject] = accountID
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
	return a, nil
}

type fakeGoogle map[string]GoogleIdentity

func (f fakeGoogle) Verify(_ context.Context, idToken string) (GoogleIdentity, error) {
	identity, ok := f[idToken]
	if !ok {
		return GoogleIdentity{}, ErrGoogleToken
	}
	return identity, nil
}
