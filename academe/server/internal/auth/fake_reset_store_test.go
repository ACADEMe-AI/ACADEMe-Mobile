package auth

import (
	"bytes"
	"context"
	"strconv"
	"time"
)

type fakeReset struct {
	code      ResetCode
	linkHash  []byte
	accountID string
	usedAt    time.Time
	tokenHash []byte
	completed bool
}

func (f *fakeStore) CreateResetCode(_ context.Context, accountID string, codeHash, linkHash []byte, expires time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, r := range f.resets {
		if r.accountID == accountID && r.usedAt.IsZero() {
			r.usedAt = time.Now()
		}
	}
	f.resets = append(f.resets, &fakeReset{
		code:      ResetCode{ID: "reset-" + strconv.Itoa(len(f.resets)+1), Hash: codeHash, Expires: expires},
		accountID: accountID,
		linkHash:  linkHash,
	})
	return nil
}

func (f *fakeStore) ClaimResetLink(_ context.Context, linkHash []byte) (ResetCode, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, r := range f.resets {
		if bytes.Equal(r.linkHash, linkHash) && r.usedAt.IsZero() {
			r.code.Attempts++
			return r.code, nil
		}
	}
	return ResetCode{}, ErrResetTokenExpired
}

func (f *fakeStore) ClaimResetAttempt(_ context.Context, accountID string) (ResetCode, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for i := len(f.resets) - 1; i >= 0; i-- {
		if r := f.resets[i]; r.accountID == accountID && r.usedAt.IsZero() {
			r.code.Attempts++
			return r.code, nil
		}
	}
	return ResetCode{}, ErrCodeExpired
}

func (f *fakeStore) MarkResetCodeUsed(_ context.Context, codeID string, tokenHash []byte, at time.Time) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, r := range f.resets {
		if r.code.ID == codeID && r.usedAt.IsZero() {
			r.usedAt, r.tokenHash = at, tokenHash
			return nil
		}
	}
	return ErrCodeExpired
}

func (f *fakeStore) CompleteReset(_ context.Context, tokenHash []byte, verifiedAfter time.Time, passwordHash string, at time.Time) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, r := range f.resets {
		if r.tokenHash == nil || !bytes.Equal(r.tokenHash, tokenHash) || r.completed || !r.usedAt.After(verifiedAfter) {
			continue
		}
		if f.hashes[r.accountID] == "" {
			return "", ErrResetTokenExpired
		}
		r.completed = true
		f.hashes[r.accountID] = passwordHash
		f.validAfter[r.accountID] = at
		for hash, s := range f.sessions {
			if s.accountID == r.accountID {
				delete(f.sessions, hash)
			}
		}
		return r.accountID, nil
	}
	return "", ErrResetTokenExpired
}
