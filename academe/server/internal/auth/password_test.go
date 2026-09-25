package auth

import "testing"

func TestCheckPassword(t *testing.T) {
	hash := hashPassword("correct horse")
	tests := []struct {
		name     string
		password string
		hash     string
		want     bool
		wantErr  bool
	}{
		{name: "match", password: "correct horse", hash: hash, want: true},
		{name: "wrong password", password: "correct horsE", hash: hash},
		{name: "empty password", password: "", hash: hash},
		{name: "not argon2id", password: "x", hash: "$2a$10$abc", wantErr: true},
		{name: "garbage", password: "x", hash: "nonsense", wantErr: true},
		{name: "bad salt", password: "x", hash: "$argon2id$v=19$m=19456,t=2,p=1$!!$AAAA", wantErr: true},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			got, err := checkPassword(tc.password, tc.hash)
			if (err != nil) != tc.wantErr {
				t.Fatalf("checkPassword(%q) error = %v, want error %v", tc.password, err, tc.wantErr)
			}
			if got != tc.want {
				t.Errorf("checkPassword(%q) = %v, want %v", tc.password, got, tc.want)
			}
		})
	}
}

func TestHashPasswordSaltsEachHash(t *testing.T) {
	if a, b := hashPassword("same"), hashPassword("same"); a == b {
		t.Errorf("hashPassword gave the same hash twice: %s", a)
	}
}
