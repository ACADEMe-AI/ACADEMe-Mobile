# Go reference

Official and widely-adopted Go guidance, saved verbatim so the backend rules in
`server/AGENTS.md` can cite a source instead of memory. Downloaded 2026-09-24
for **Go 1.25** (the installed toolchain is go1.25.5).

| File | What it covers | Source · licence |
|---|---|---|
| `effective-go.html` | The canonical idioms: naming, formatting, errors, concurrency | go.dev · CC BY 4.0 |
| `go-wiki-code-review-comments.md` | What Go reviewers flag: naming, errors, receivers, interfaces | go.dev/wiki · CC BY 4.0 |
| `go-wiki-test-comments.md` | How to write test failures and helpers | go.dev/wiki · CC BY 4.0 |
| `go-wiki-table-driven-tests.md` | The table-driven test pattern | go.dev/wiki · CC BY 4.0 |
| `go-wiki-errors.md` | Error values overview | go.dev/wiki · CC BY 4.0 |
| `google-go-style-{index,guide,decisions,best-practices}.md` | Google's full Go style guide — the most detailed ruleset available | google/styleguide · CC BY 3.0 |
| `uber-go-style.md` | Uber's Go guide: pragmatic do/don't pairs, performance, safety | uber-go/guide · Apache 2.0 |
| `go-module-layout.md` | Official project layout: `cmd/`, `internal/` | go.dev · CC BY 4.0 |
| `go-managing-dependencies.md` | `go.mod`, tidy, tool dependencies | go.dev · CC BY 4.0 |
| `go-blog-package-names.md` | Choosing package names | go.dev blog · CC BY 4.0 |
| `go-blog-errors.md`, `go-blog-error-handling.md` | `%w` wrapping, `errors.Is/As`, error design | go.dev blog · CC BY 4.0 |
| `go-blog-context.md`, `go-blog-context-and-structs.md` | Passing `context.Context`; never storing it | go.dev blog · CC BY 4.0 |
| `go-blog-slog.md` | Structured logging with `log/slog` | go.dev blog · CC BY 4.0 |
| `go-blog-routing-enhancements.md` | `net/http` method + wildcard routing (no router library needed) | go.dev blog · CC BY 4.0 |
| `go-blog-subtests.md`, `go-blog-cover.md` | `t.Run` subtests, coverage | go.dev blog · CC BY 4.0 |
| `go-tutorial-add-a-test.html`, `go-tutorial-fuzz.md` | Unit tests and fuzzing | go.dev · CC BY 4.0 |
| `go-database-*.md`, `go-tutorial-database-access.md` | `database/sql`: queries, transactions, cancellation, pooling, SQL injection | go.dev · CC BY 4.0 |
| `go-security-best-practices.md` | Security checklist: vuln scanning, fuzzing, race detector, vet | go.dev · CC BY 4.0 |
| `go-vulnerability-management.md`, `go-tutorial-govulncheck.md` | `govulncheck` | go.dev · CC BY 4.0 |
| `go-1.25-release-notes.md` | What's current: `WaitGroup.Go`, `testing/synctest`, `http.CrossOriginProtection`, container-aware `GOMAXPROCS`, new vet checks | go.dev · CC BY 4.0 |

Refresh: every file came from `raw.githubusercontent.com` — `golang/website`
(`_content/…`), `golang/wiki`, `google/styleguide` (`gh-pages/go/…`) and
`uber-go/guide`. Re-download on each Go minor release.

## Tools installed alongside

| Tool | Version | Run |
|---|---|---|
| `gofmt` | go1.25.5 | `gofmt -l .` |
| `go vet` | go1.25.5 | `go vet ./...` |
| `golangci-lint` | 2.13.2 (Homebrew) | `golangci-lint run` |
| `govulncheck` | 1.8.0 (`~/go/bin`) | `go tool govulncheck ./...` once added to the module as a tool |
