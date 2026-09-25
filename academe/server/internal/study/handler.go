package study

import (
	"errors"
	"log/slog"
	"net/http"
	"strconv"

	"academe/server/internal/auth"
	"academe/server/internal/httpx"
)

type Guard func(httpx.HandlerFunc) httpx.HandlerFunc

func RegisterRoutes(mux *http.ServeMux, logger *slog.Logger, s *Service, requireAccount Guard) {
	h := handler{s}
	route := func(pattern string, f httpx.HandlerFunc) {
		mux.Handle(pattern, httpx.Handle(logger, requireAccount(f)))
	}
	mux.Handle("GET /study/decks", httpx.Gzip(httpx.Handle(logger, requireAccount(h.list))))
	route("GET /study/decks/{id}", h.deck)
	route("POST /study/decks/{id}/answers", h.answer)
	route("PUT /study/decks/{id}/completion", h.complete)
	route("PUT /study/decks/{id}/position", h.position)
	route("PUT /study/kept", h.keep)
	route("DELETE /study/kept/{deck}/{card}", h.unkeep)
	route("GET /study/review", h.review)
	route("POST /study/review", h.rate)
	route("GET /study/chapter-results", h.chapterResults)
	route("PUT /study/chapter-results/{id}", h.saveChapterResult)
}

type handler struct {
	service *Service
}

type deckList struct {
	Decks    []LessonSummary  `json:"decks"`
	Chapters []ChapterSummary `json:"chapters"`
}

type answerInput struct {
	Card   int `json:"card"`
	Choice int `json:"choice"`
}

type completionInput struct {
	Correct int `json:"correct"`
}

type positionInput struct {
	Card int `json:"card"`
}

type cardRef struct {
	DeckID string `json:"deckId"`
	Card   int    `json:"card"`
}

type ratingInput struct {
	DeckID string `json:"deckId"`
	Card   int    `json:"card"`
	Rating string `json:"rating"`
}

type reviewList struct {
	Items []ReviewItem `json:"items"`
}

type resultList struct {
	Results []ChapterResult `json:"results"`
}

type scoreInput struct {
	Correct int `json:"correct"`
	Total   int `json:"total"`
}

func account(r *http.Request) string { return auth.AccountID(r.Context()) }

func (h handler) list(w http.ResponseWriter, r *http.Request) error {
	subject := r.URL.Query().Get("subject")
	decks, err := h.service.Decks(r.Context(), account(r), subject)
	if err != nil {
		return err
	}
	if decks == nil {
		decks = []LessonSummary{}
	}
	chapters, err := h.service.Chapters(r.Context(), account(r), subject)
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, deckList{decks, chapters})
	return nil
}

func (h handler) deck(w http.ResponseWriter, r *http.Request) error {
	d, err := h.service.DeckFor(r.Context(), account(r), r.PathValue("id"))
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, d)
	return nil
}

func (h handler) answer(w http.ResponseWriter, r *http.Request) error {
	var in answerInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	res, err := h.service.Answer(r.Context(), account(r), r.PathValue("id"), in.Card, in.Choice)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, res)
	return nil
}

func (h handler) complete(w http.ResponseWriter, r *http.Request) error {
	var in completionInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.Complete(r.Context(), account(r), r.PathValue("id"), in.Correct))
}

func (h handler) position(w http.ResponseWriter, r *http.Request) error {
	var in positionInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.SavePosition(r.Context(), account(r), r.PathValue("id"), in.Card))
}

func (h handler) keep(w http.ResponseWriter, r *http.Request) error {
	var in cardRef
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.Keep(r.Context(), account(r), in.DeckID, in.Card))
}

func (h handler) unkeep(w http.ResponseWriter, r *http.Request) error {
	card, err := strconv.Atoi(r.PathValue("card"))
	if err != nil {
		return toHTTP(ErrBadCard)
	}
	return noContent(w, h.service.Unkeep(r.Context(), account(r), r.PathValue("deck"), card))
}

func (h handler) review(w http.ResponseWriter, r *http.Request) error {
	items, err := h.service.Review(r.Context(), account(r), r.URL.Query().Get("chapter"))
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, reviewList{items})
	return nil
}

func (h handler) rate(w http.ResponseWriter, r *http.Request) error {
	var in ratingInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.Rate(r.Context(), account(r), in.DeckID, in.Card, in.Rating))
}

func (h handler) chapterResults(w http.ResponseWriter, r *http.Request) error {
	results, err := h.service.ChapterResults(r.Context(), account(r))
	if err != nil {
		return err
	}
	httpx.WriteJSON(w, http.StatusOK, resultList{results})
	return nil
}

func (h handler) saveChapterResult(w http.ResponseWriter, r *http.Request) error {
	var in scoreInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.SaveChapterResult(r.Context(), account(r), r.PathValue("id"), in.Correct, in.Total))
}

func noContent(w http.ResponseWriter, err error) error {
	if err != nil {
		return toHTTP(err)
	}
	w.WriteHeader(http.StatusNoContent)
	return nil
}

func toHTTP(err error) error {
	unprocessable := func(code string) error {
		return &httpx.Error{Status: http.StatusUnprocessableEntity, Code: code, Message: err.Error()}
	}
	switch {
	case errors.Is(err, ErrNotFound):
		return &httpx.Error{Status: http.StatusNotFound, Code: "deck_not_found", Message: "That lesson doesn't exist."}
	case errors.Is(err, ErrNoChapter):
		return &httpx.Error{Status: http.StatusNotFound, Code: "chapter_not_found", Message: "That chapter doesn't exist."}
	case errors.Is(err, ErrNotKept):
		return &httpx.Error{Status: http.StatusNotFound, Code: "not_kept", Message: err.Error()}
	case errors.Is(err, ErrBadCard):
		return unprocessable("invalid_card")
	case errors.Is(err, ErrNotQuiz):
		return unprocessable("invalid_card")
	case errors.Is(err, ErrBadChoice):
		return unprocessable("invalid_choice")
	case errors.Is(err, ErrBadScore):
		return unprocessable("invalid_score")
	case errors.Is(err, ErrBadRating):
		return unprocessable("invalid_rating")
	}
	return err
}
