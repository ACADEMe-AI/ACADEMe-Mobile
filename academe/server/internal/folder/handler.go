package folder

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
	route("GET /folders", h.list)
	route("POST /folders", h.create)
	route("GET /folders/{id}", h.detail)
	route("PUT /folders/{id}", h.update)
	route("DELETE /folders/{id}", h.delete)
	route("POST /folders/{id}/chapters", h.addChapters)
	route("POST /folders/{id}/notes", h.addNote)
	route("DELETE /folders/{id}/items/{item}", h.deleteItem)
	route("POST /folders/{id}/todos", h.addTodo)
	route("PUT /folders/{id}/todos/{todo}", h.setTodo)
	route("DELETE /folders/{id}/todos/{todo}", h.deleteTodo)
	route("GET /today", h.today)
}

type handler struct {
	service *Service
}

type folderList struct {
	Folders []Summary `json:"folders"`
}

type folderInput struct {
	Name    string `json:"name"`
	DueOn   string `json:"dueOn"`
	Reminds *bool  `json:"reminds"`
}

type chaptersInput struct {
	ChapterIDs []string `json:"chapterIds"`
}

type noteInput struct {
	Text string `json:"text"`
}

type todoInput struct {
	Title string `json:"title"`
	Day   string `json:"day"`
}

type todoDoneInput struct {
	Done bool `json:"done"`
}

func account(r *http.Request) string { return auth.AccountID(r.Context()) }

func (h handler) day(r *http.Request) (Day, error) {
	offset := 0
	if raw := r.URL.Query().Get("offset"); raw != "" {
		n, err := strconv.Atoi(raw)
		if err != nil {
			return Day{}, ErrBadDate
		}
		offset = n
	}
	return h.service.Day(r.URL.Query().Get("today"), offset)
}

func id64(r *http.Request, name string) (int64, error) {
	n, err := strconv.ParseInt(r.PathValue(name), 10, 64)
	if err != nil {
		return 0, ErrNotFound
	}
	return n, nil
}

func (h handler) list(w http.ResponseWriter, r *http.Request) error {
	day, err := h.day(r)
	if err != nil {
		return toHTTP(err)
	}
	folders, err := h.service.List(r.Context(), account(r), day)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, folderList{folders})
	return nil
}

func (h handler) detail(w http.ResponseWriter, r *http.Request) error {
	day, err := h.day(r)
	if err != nil {
		return toHTTP(err)
	}
	d, err := h.service.Detail(r.Context(), account(r), r.PathValue("id"), day)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, d)
	return nil
}

func (h handler) today(w http.ResponseWriter, r *http.Request) error {
	day, err := h.day(r)
	if err != nil {
		return toHTTP(err)
	}
	t, err := h.service.Today(r.Context(), account(r), day)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, t)
	return nil
}

func (h handler) create(w http.ResponseWriter, r *http.Request) error {
	var in folderInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	f, err := h.service.Create(r.Context(), account(r), in.Name, in.DueOn)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusCreated, f)
	return nil
}

func (h handler) update(w http.ResponseWriter, r *http.Request) error {
	var in folderInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	reminds := in.Reminds == nil || *in.Reminds
	f, err := h.service.Update(r.Context(), account(r), r.PathValue("id"), in.Name, in.DueOn, reminds)
	if err != nil {
		return toHTTP(err)
	}
	httpx.WriteJSON(w, http.StatusOK, f)
	return nil
}

func (h handler) delete(w http.ResponseWriter, r *http.Request) error {
	return noContent(w, h.service.Delete(r.Context(), account(r), r.PathValue("id")))
}

func (h handler) addChapters(w http.ResponseWriter, r *http.Request) error {
	var in chaptersInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.AddChapters(r.Context(), account(r), r.PathValue("id"), in.ChapterIDs))
}

func (h handler) addNote(w http.ResponseWriter, r *http.Request) error {
	var in noteInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.AddNote(r.Context(), account(r), r.PathValue("id"), in.Text))
}

func (h handler) deleteItem(w http.ResponseWriter, r *http.Request) error {
	item, err := id64(r, "item")
	if err != nil {
		return toHTTP(err)
	}
	return noContent(w, h.service.DeleteItem(r.Context(), account(r), r.PathValue("id"), item))
}

func (h handler) addTodo(w http.ResponseWriter, r *http.Request) error {
	var in todoInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	return noContent(w, h.service.AddTodo(r.Context(), account(r), r.PathValue("id"), in.Title, in.Day))
}

func (h handler) setTodo(w http.ResponseWriter, r *http.Request) error {
	var in todoDoneInput
	if err := httpx.DecodeJSON(w, r, &in); err != nil {
		return err
	}
	todo, err := id64(r, "todo")
	if err != nil {
		return toHTTP(err)
	}
	return noContent(w, h.service.SetTodoDone(r.Context(), account(r), r.PathValue("id"), todo, in.Done))
}

func (h handler) deleteTodo(w http.ResponseWriter, r *http.Request) error {
	todo, err := id64(r, "todo")
	if err != nil {
		return toHTTP(err)
	}
	return noContent(w, h.service.DeleteTodo(r.Context(), account(r), r.PathValue("id"), todo))
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
		return &httpx.Error{Status: http.StatusNotFound, Code: "folder_not_found", Message: "That folder doesn't exist."}
	case errors.Is(err, ErrBadName):
		return unprocessable("invalid_name")
	case errors.Is(err, ErrBadText):
		return unprocessable("invalid_text")
	case errors.Is(err, ErrBadTitle):
		return unprocessable("invalid_title")
	case errors.Is(err, ErrBadDate):
		return unprocessable("invalid_date")
	case errors.Is(err, ErrBadChapter):
		return unprocessable("invalid_chapter")
	}
	return err
}
