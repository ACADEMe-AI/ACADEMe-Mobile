package lessons

import (
	"encoding/json"
	"errors"
	"fmt"
	"math/rand/v2"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"academe/server/internal/study"
)

const (
	minCards   = 6
	maxCards   = 12
	maxOptions = 4
	forbidden  = "$\\\t\f\r\b"
)

var (
	ErrNoJSON     = errors.New("no JSON object in the reply")
	ErrBadDeck    = errors.New("lesson breaks the generator rules")
	thinking      = regexp.MustCompile(`(?s)<think>.*?</think>`)
	objectStart   = regexp.MustCompile(`\{\s*["}]`)
	trailingComma = regexp.MustCompile(`,(\s*[}\]])`)
	stepLabel     = regexp.MustCompile(`^(?i)(\s*step\s*[0-9]+\s*[:.)–-]\s*)+`)
	wordRoot      = regexp.MustCompile(`\b[Rr]oot ([0-9]+)\b`)
	spacedRoot    = regexp.MustCompile(`([0-9]) √`)
	caretPower    = regexp.MustCompile(`\^\(?(-?[0-9]+)\)?`)
	superDigit    = strings.NewReplacer("0", "⁰", "1", "¹", "2", "²", "3", "³", "4", "⁴", "5", "⁵", "6", "⁶", "7", "⁷", "8", "⁸", "9", "⁹", "-", "⁻")
	crossOption   = regexp.MustCompile(`\b(Both|Neither|Only)\b.*\b[A-D]\b|(?i)\b(all|none) of the above\b`)
	byPosition    = regexp.MustCompile(`(?i)\b(options?|choices?|reactions?|statements?|answers?)\s*\(?([a-d]|[0-9])\)?(\W|$)|\b(first|second|third|fourth|last)\s+(option|choice)`)
)

func extractJSON(reply string) ([]byte, error) {
	reply = thinking.ReplaceAllString(reply, "")
	at := objectStart.FindStringIndex(reply)
	if at == nil {
		return nil, ErrNoJSON
	}
	rest := reply[at[0]:]
	raw, err := firstValue(rest)
	if err == nil {
		return raw, nil
	}
	if fixed, fixErr := firstValue(trailingComma.ReplaceAllString(rest, "$1")); fixErr == nil {
		return fixed, nil
	}
	if se, ok := errors.AsType[*json.SyntaxError](err); ok {
		at := int(se.Offset)
		return nil, fmt.Errorf("%w: %w near %q", ErrNoJSON, se, rest[max(0, at-40):min(len(rest), at+20)])
	}
	return nil, fmt.Errorf("%w: %w", ErrNoJSON, err)
}

func firstValue(s string) ([]byte, error) {
	var raw json.RawMessage
	if err := json.NewDecoder(strings.NewReader(s)).Decode(&raw); err != nil {
		return nil, err
	}
	return raw, nil
}

func parseDeck(j Job, reply string) (study.Deck, error) {
	raw, err := extractJSON(reply)
	if err != nil {
		return study.Deck{}, err
	}
	cards, err := decodeCards(raw)
	if err != nil {
		return study.Deck{}, err
	}
	d := study.Deck{
		ID: j.ID(), Board: j.Board, Class: j.Class, Subject: j.Subject.Subject,
		ChapterNumber: j.Chapter.Number, ChapterTitle: j.Chapter.Title, Position: j.Position,
		Title: j.Lesson().Title, Language: j.Language(), Cards: cards,
	}
	for i := range d.Cards {
		rewrite(&d.Cards[i], plainMaths)
		for k, step := range d.Cards[i].Steps {
			d.Cards[i].Steps[k] = stepLabel.ReplaceAllString(step, "")
		}
	}
	if err := check(d); err != nil {
		return study.Deck{}, err
	}
	d.Cards[0].Minutes = d.Minutes()
	for i := range d.Cards {
		if d.Cards[i].Kind == study.Example {
			d.Cards[i].Remember = ""
		}
	}
	shuffleOptions(d.Cards)
	return d, nil
}

func decodeCards(raw []byte) ([]study.Card, error) {
	var loose struct {
		Cards []map[string]any `json:"cards"`
	}
	if err := json.Unmarshal(raw, &loose); err != nil {
		return nil, fmt.Errorf("%w: %w", ErrNoJSON, err)
	}
	for _, c := range loose.Cards {
		if c["kind"] != study.Quiz {
			delete(c, "answer")
			continue
		}
		text, ok := c["answer"].(string)
		if !ok {
			continue
		}
		options, _ := c["options"].([]any)
		text = strings.TrimSpace(text)
		c["answer"] = -1
		if i := slices.IndexFunc(options, func(o any) bool { return o == text }); i >= 0 {
			c["answer"] = i
		} else if n, err := strconv.Atoi(text); err == nil {
			c["answer"] = n
		} else if i := slices.Index([]string{"A", "B", "C", "D"}, strings.ToUpper(text)); i >= 0 {
			c["answer"] = i
		}
	}
	fixed, err := json.Marshal(loose)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrNoJSON, err)
	}
	var body struct {
		Cards []study.Card `json:"cards"`
	}
	if err := json.Unmarshal(fixed, &body); err != nil {
		return nil, fmt.Errorf("%w: %w", ErrNoJSON, err)
	}
	return body.Cards, nil
}

func check(d study.Deck) error {
	if err := study.Validate(d); err != nil {
		return err
	}
	if n := len(d.Cards); n < minCards || n > maxCards {
		return fmt.Errorf("%w: %d cards, want %d to %d", ErrBadDeck, n, minCards, maxCards)
	}
	for i, c := range d.Cards {
		if c.Kind == study.Quiz && (len(c.Options) > maxOptions || len(slices.Compact(slices.Sorted(slices.Values(c.Options)))) != len(c.Options)) {
			return fmt.Errorf("%w: card %d: a quiz needs at most %d different options", ErrBadDeck, i+1, maxOptions)
		}
		if slices.ContainsFunc(c.Options, crossOption.MatchString) {
			return fmt.Errorf("%w: card %d: an option points at other options; every option must stand on its own", ErrBadDeck, i+1)
		}
		if ref := positionalReference(c); ref != "" {
			return fmt.Errorf("%w: card %d: the why says %q; the options are shuffled, so name each option by its words", ErrBadDeck, i+1, ref)
		}
		for _, text := range texts(c) {
			if strings.ContainsAny(text, forbidden) {
				return fmt.Errorf("%w: card %d: write maths as plain text with no $ or backslash (no LaTeX)", ErrBadDeck, i+1)
			}
		}
	}
	return nil
}

func positionalReference(c study.Card) string {
	for _, m := range byPosition.FindAllStringSubmatch(c.Why, -1) {
		if m[2] == "" || !slices.ContainsFunc(c.Options, func(o string) bool { return strings.EqualFold(strings.TrimSpace(o), m[2]) }) {
			return strings.TrimSpace(m[0])
		}
	}
	return ""
}

func plainMaths(s string) string {
	s = spacedRoot.ReplaceAllString(wordRoot.ReplaceAllString(s, "√$1"), "$1√")
	return caretPower.ReplaceAllStringFunc(s, func(m string) string {
		return superDigit.Replace(caretPower.FindStringSubmatch(m)[1])
	})
}

func rewrite(c *study.Card, f func(string) string) {
	for _, p := range []*string{&c.Title, &c.Body, &c.Remember, &c.Question, &c.Why} {
		*p = f(*p)
	}
	for _, list := range [][]string{c.Goals, c.Steps, c.Points, c.Options} {
		for i := range list {
			list[i] = f(list[i])
		}
	}
	for i := range c.Rows {
		c.Rows[i].Term, c.Rows[i].Value = f(c.Rows[i].Term), f(c.Rows[i].Value)
	}
}

func texts(c study.Card) []string {
	out := []string{c.Title, c.Body, c.Remember, c.Question, c.Why}
	out = append(out, c.Goals...)
	out = append(out, c.Steps...)
	out = append(out, c.Points...)
	out = append(out, c.Options...)
	for _, r := range c.Rows {
		out = append(out, r.Term, r.Value)
	}
	return out
}

func shuffleOptions(cards []study.Card) {
	for i, c := range cards {
		if c.Kind != study.Quiz {
			continue
		}
		order := rand.Perm(len(c.Options)) //nolint:gosec
		options := make([]string, len(order))
		answer := 0
		for to, from := range order {
			options[to] = c.Options[from]
			if from == *c.Answer {
				answer = to
			}
		}
		cards[i].Options, cards[i].Answer = options, &answer
	}
}

type verdict struct {
	OK     bool     `json:"ok"`
	Issues []string `json:"issues"`
}

func parseVerdict(reply string) (verdict, error) {
	raw, err := extractJSON(reply)
	if err != nil {
		return verdict{}, err
	}
	var v verdict
	if err := json.Unmarshal(raw, &v); err != nil {
		return verdict{}, fmt.Errorf("%w: %w", ErrNoJSON, err)
	}
	if !v.OK && len(v.Issues) == 0 {
		return verdict{}, fmt.Errorf("%w: not ok but no issues listed", ErrNoJSON)
	}
	return v, nil
}
