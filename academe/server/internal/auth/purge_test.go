package auth

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/google/go-cmp/cmp"
)

type fakeSubscribers struct {
	deleted []string
	err     error
}

func (f *fakeSubscribers) DeleteSubscriber(_ context.Context, accountID string) error {
	f.deleted = append(f.deleted, accountID)
	return f.err
}

func TestPurgeDeletesSubscribers(t *testing.T) {
	tests := []struct {
		name    string
		err     error
		wantErr bool
	}{
		{"deleted", nil, false},
		{"store down", errors.New("revenuecat down"), true},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			store := newFakeStore()
			s := NewService(store, []byte("0123456789abcdef0123456789abcdef"), nil, &fakeMailer{})
			subscribers := &fakeSubscribers{err: tc.err}
			s.SetSubscriberDeleter(subscribers)
			a, _, err := s.SignUp(t.Context(), SignUpInput{FirstName: "Maya", LastName: "Rao", Email: "m@example.com", Password: "sunflower"})
			if err != nil {
				t.Fatal(err)
			}
			if err := store.ScheduleDeletion(t.Context(), a.ID, "", time.Now().Add(-DeletionGrace-time.Hour)); err != nil {
				t.Fatal(err)
			}
			n, err := s.PurgeDeleted(t.Context())
			if n != 1 || (err != nil) != tc.wantErr {
				t.Errorf("PurgeDeleted() = %d, %v; want 1 purged, error %v", n, err, tc.wantErr)
			}
			if diff := cmp.Diff([]string{a.ID}, subscribers.deleted); diff != "" {
				t.Errorf("deleted subscribers (-want +got):\n%s", diff)
			}
		})
	}
}
