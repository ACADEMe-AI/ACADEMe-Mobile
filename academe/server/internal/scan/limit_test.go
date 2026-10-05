package scan

import (
	"bytes"
	"context"
	"errors"
	"log/slog"
	"mime/multipart"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"academe/server/internal/billing"
	"academe/server/internal/httpx"
	"academe/server/internal/sarvam"
)

type fakeLimiter struct {
	proOnly map[billing.Feature]bool
	taken   []billing.Feature
	refunds []billing.Feature
}

func (f *fakeLimiter) Take(_ context.Context, _ string, feature billing.Feature) error {
	if f.proOnly[feature] {
		return &billing.LimitError{Feature: feature}
	}
	f.taken = append(f.taken, feature)
	return nil
}

func (f *fakeLimiter) Refund(_ context.Context, _ string, feature billing.Feature) {
	f.refunds = append(f.refunds, feature)
}

func TestLimits(t *testing.T) {
	store, folders := newFakeStore(), &fakeFolders{}
	limiter := &fakeLimiter{proOnly: map[billing.Feature]bool{billing.Lessons: true}}
	s := NewService(store, &fakeReader{text: "Light bends"}, &fakeModel{}, fakeProfiles{}, &fakeLessons{}, folders)
	s.SetLimiter(limiter)
	ctx := t.Context()

	sc, err := s.Read(ctx, "riya", Notes, []sarvam.Page{{Name: "page.jpg", Data: []byte("x")}})
	if err != nil {
		t.Fatal(err)
	}
	_, err = s.SaveNotes(ctx, "riya", sc.ID, "f1", true)
	httpErr, ok := errors.AsType[*httpx.Error](toHTTP(err))
	if !ok || httpErr.Status != http.StatusPaymentRequired || httpErr.Code != "pro_only" || len(folders.notes) != 0 {
		t.Errorf("SaveNotes(makeLesson) on free = %v, notes %v; want 402 pro_only and nothing saved", err, folders.notes)
	}
	if _, err := s.SaveNotes(ctx, "riya", sc.ID, "f1", false); err != nil || len(folders.notes) != 1 {
		t.Errorf("SaveNotes(just the notes) = %v, want the notes saved", err)
	}

	check, err := s.Read(ctx, "riya", Check, []sarvam.Page{{Name: "page.jpg", Data: []byte("x")}})
	if err != nil {
		t.Fatal(err)
	}
	if _, err := s.Check(ctx, "riya", check.ID, ""); !errors.Is(err, ErrFailed) {
		t.Fatalf("Check() with no model reply = %v, want ErrFailed", err)
	}
	want := []billing.Feature{billing.Scan, billing.Scan, billing.Check}
	if len(limiter.taken) != 3 || limiter.taken[2] != want[2] || len(limiter.refunds) != 1 || limiter.refunds[0] != billing.Check {
		t.Errorf("taken %v, refunded %v; want %v and a refund for the failed check", limiter.taken, limiter.refunds, want)
	}
}

func TestUploadIsReadOnlyAfterTheQuotaCheck(t *testing.T) {
	big := func(n int) (string, *bytes.Buffer) {
		var body bytes.Buffer
		mw := multipart.NewWriter(&body)
		part, err := mw.CreateFormFile("page", "a.jpg")
		if err != nil {
			t.Fatal(err)
		}
		if _, err := part.Write(bytes.Repeat([]byte("x"), n)); err != nil {
			t.Fatal(err)
		}
		if err := mw.WriteField("mode", "solve"); err != nil {
			t.Fatal(err)
		}
		if err := mw.Close(); err != nil {
			t.Fatal(err)
		}
		return mw.FormDataContentType(), &body
	}
	tests := []struct {
		name        string
		proOnly     bool
		size        int
		wantStatus  int
		wantCode    string
		wantRead    bool
		wantRefunds int
	}{
		{"over the quota", true, maxUploadBytes - 1<<20, http.StatusPaymentRequired, "pro_only", false, 0},
		{"page too big", false, maxPageBytes + 1, http.StatusUnprocessableEntity, "invalid_pages", false, 1},
		{"upload too big", false, maxUploadBytes + 1, http.StatusRequestEntityTooLarge, "too_large", false, 1},
		{"fits", false, 1 << 20, http.StatusCreated, "id", true, 0},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			limiter := &fakeLimiter{proOnly: map[billing.Feature]bool{billing.Scan: tc.proOnly}}
			reader := &fakeReader{text: "Light bends"}
			s := NewService(newFakeStore(), reader, &fakeModel{}, fakeProfiles{}, &fakeLessons{}, &fakeFolders{})
			s.SetLimiter(limiter)
			mux := http.NewServeMux()
			RegisterRoutes(mux, slog.New(slog.DiscardHandler), s, guard)
			ct, body := big(tc.size)
			req := httptest.NewRequestWithContext(t.Context(), http.MethodPost, "/scans", body)
			req.Header.Set("Authorization", "Bearer riya")
			req.Header.Set("Content-Type", ct)
			rec := httptest.NewRecorder()
			httpx.WithRequestID(mux).ServeHTTP(rec, req)
			if rec.Code != tc.wantStatus || !strings.Contains(rec.Body.String(), `"`+tc.wantCode+`"`) {
				t.Errorf("POST /scans with %d bytes = %d %s, want %d %s", tc.size, rec.Code, rec.Body, tc.wantStatus, tc.wantCode)
			}
			if read := reader.pages > 0; read != tc.wantRead || len(limiter.refunds) != tc.wantRefunds {
				t.Errorf("POST /scans with %d bytes read pages %v, refunds %v; want %v, %d", tc.size, read, limiter.refunds, tc.wantRead, tc.wantRefunds)
			}
		})
	}

	limiter := &fakeLimiter{proOnly: map[billing.Feature]bool{billing.Scan: true}}
	s := NewService(newFakeStore(), &fakeReader{text: "x"}, &fakeModel{}, fakeProfiles{}, &fakeLessons{}, &fakeFolders{})
	s.SetLimiter(limiter)
	opened := false
	_, err := s.ReadUpload(t.Context(), "riya", func() (Mode, []sarvam.Page, error) {
		opened = true
		return Solve, []sarvam.Page{{Name: "page.jpg", Data: []byte("x")}}, nil
	})
	if _, ok := errors.AsType[*billing.LimitError](err); !ok || opened {
		t.Errorf("ReadUpload() over the quota = %v, opened the upload %v; want a LimitError before opening it", err, opened)
	}
}
