# ACADEMe server — engineering rules

Every change to the Go backend follows these rules. They are distilled from the
official Go docs and the Google and Uber style guides, saved verbatim in
`../docs/go-reference/` — read the file named in brackets when a rule needs
more context. Where the guides disagree, Google's wins.

A change is not done until the checks in **Definition of done** pass.

## 1. Shape of the service

- One module, `academe/server`, one binary: `cmd/academe-api`. [go-module-layout]
- Everything else lives under `internal/`, so nothing outside this module can
  import it. [go-module-layout]
- **Package by feature, not by layer.** `internal/auth` holds the auth types,
  service, store and handlers together — not `models/`, `services/`,
  `handlers/` folders. [google-go-style-best-practices "Package size",
  go-blog-package-names]
- Shared plumbing gets its own small package, named for what it does:
  `internal/httpx` (JSON, errors, middleware), `internal/postgres`
  (pool, migrations), `internal/config`.
- `main` only wires things together: read config, open the pool, build the
  services, start the server, shut down cleanly. No logic. [uber-go-style
  "Exit in Main"]

```
server/
  cmd/academe-api/main.go
  internal/
    config/        env → Config, validated at start
    httpx/         JSON decode/encode, error envelope, middleware
    postgres/      pool, migrations (embedded from postgres/migrations/)
    auth/          sign-up, log-in, tokens, password hashing
    <feature>/     one per product area
  openapi.yaml     the contract the Flutter app codes against
  compose.yaml     local PostgreSQL
  Dockerfile
```

## 2. Naming

[effective-go "Names", go-wiki-code-review-comments, google-go-style-decisions]

- Packages: short, lowercase, one word. **No `util`, `common`, `helpers`,
  `models`, `base`.**
- **No stutter**: `auth.Service`, not `auth.AuthService`; `account.New`, not
  `account.NewAccount`.
- MixedCaps; initialisms keep one case: `ID`, `URL`, `HTTP`, `JSON`
  (`userID`, `ParseURL`, never `userId`).
- Receivers: one or two letters, the same on every method of a type. Never
  `this` or `self`.
- No `Get` prefix on getters: `Owner()`, not `GetOwner()`.
- One-method interfaces end in `-er`. Interfaces are declared by the package
  that **uses** them, not the one that implements them, and only when there
  are two implementations or a test needs a fake. [google-go-style-decisions
  "Interfaces"]
- Sentinel errors `ErrEmailTaken`; error types `ValidationError`.

## 3. Errors

[go-blog-errors, go-blog-error-handling, go-wiki-code-review-comments]

- Every error is handled. `_ =` only where the error can't happen or can't be
  acted on (a failed write after the status is sent).
- **Wrap with context as you return**, using `%w`:
  `fmt.Errorf("create account: %w", err)`. The chain reads like a trace.
- Error strings: lowercase, no trailing punctuation, no "failed to".
- Compare with `errors.Is` / `errors.AsType`, never `==` on wrapped errors or
  string matching.
- Domain failures the caller acts on are **sentinel errors in the feature
  package** (`auth.ErrEmailTaken`). The HTTP layer maps them to status codes —
  **only** the HTTP layer knows about status codes.
- **Handle an error once**: log it *or* return it, never both. Handlers log
  unexpected errors at the edge; everything below just returns.
- Clients never see internal error text. Unexpected errors become a generic
  500 with a request ID; the detail goes to the log.
- No `panic` for anything a request can cause. [go-wiki-code-review-comments
  "Don't Panic"]

## 4. Context and lifetimes

[go-blog-context, go-blog-context-and-structs, uber-go-style]

- `ctx context.Context` is the first parameter of every function that does I/O
  or can block. Pass the request's context all the way to the database.
- **Never store a context in a struct.**
- Context values only for request-scoped data crossing API boundaries: request
  ID, authenticated user ID. Never for optional parameters.
- **No goroutine without an owner and an end.** Use `sync.WaitGroup.Go` (Go
  1.25) or `errgroup`, and stop it on shutdown. No fire-and-forget.
  [uber-go-style "Don't fire-and-forget goroutines", go-1.25-release-notes]
- No mutable package-level state and no `init()` with side effects. Build
  dependencies in `main` and pass them in. [uber-go-style "Avoid init()",
  "Avoid Mutable Globals"]

## 5. HTTP

[go-blog-routing-enhancements, go-security-best-practices, go-1.25-release-notes]

- **Standard library router**: `http.NewServeMux` with method + path patterns,
  `mux.HandleFunc("POST /auth/sign-up", …)`, `r.PathValue("id")`. No router
  framework unless the standard one demonstrably falls short.
- No version prefix on routes. Installed apps can't be forced to update, so
  **the API only ever changes additively**: new endpoints and new response
  fields are fine; renaming, removing or changing the meaning of a field or
  route is not. A change that can't be additive gets a new route alongside
  the old one, and the old one stays until no supported app calls it.
- Health check at `GET /healthz`.
- `http.Server` always sets `ReadHeaderTimeout`, `ReadTimeout`, `WriteTimeout`
  and `IdleTimeout`. The zero values wait forever.
- Request bodies: `http.MaxBytesReader` first, then decode JSON with
  `DisallowUnknownFields`. Reject, don't guess.
- JSON field names are **camelCase**, matching the Flutter models, set with
  explicit struct tags on every marshalled field. [uber-go-style "Use field tags
  in marshaled structs"]
- One error shape for every failure:
  `{"error": {"code": "email_taken", "message": "…", "requestId": "…"}}`.
  The `code` is stable and the app switches on it; `message` is for humans.
- Graceful shutdown: `signal.NotifyContext` for SIGINT/SIGTERM, then
  `srv.Shutdown` with a deadline.
- Middleware, outermost first: request ID → recover → access log. Feature
  handlers return errors through `httpx.Handle`; each feature maps its own
  errors to `*httpx.Error` in one `toHTTP` function.

## 6. Database

[go-database-*, go-tutorial-database-access]

- PostgreSQL through **pgx v5** and its pool.
- **Every query is parameterised** (`$1, $2`). Never build SQL with
  `fmt.Sprintf` or `+`. [go-database-sql-injection]
- Every call takes the request context, so a dropped request cancels its
  query. [go-database-cancel-operations]
- `rows.Close()` deferred and `rows.Err()` checked after every loop.
- Transactions: `defer tx.Rollback(ctx)` straight after `Begin`, then
  `Commit`. The deferred rollback is a no-op after commit.
  [go-database-execute-transactions]
- Pool limits set explicitly, not left at defaults.
  [go-database-manage-connections]
- Schema changes are numbered SQL files in `internal/postgres/migrations/`
  (`0002_<name>.sql`), embedded with
  `embed`, applied in order at start-up and recorded in a table. Never edit a
  migration that has run anywhere; add a new one.
- SQL lives in the feature's `store.go`, next to the code that calls it.
- `pgx.ErrNoRows` becomes the feature's own not-found error at the store
  boundary; nothing above the store imports pgx.

## 7. Security

[go-security-best-practices, go-vulnerability-management]

- Passwords hashed with **argon2id** (`golang.org/x/crypto/argon2`), per-user
  random salt, parameters stored with the hash. Never logged, never returned.
- Random values — tokens, salts, IDs — from `crypto/rand` only.
- Compare secrets with `crypto/subtle.ConstantTimeCompare`.
- Secrets (database URL, signing keys, Google client IDs) come from the
  environment, are validated at start-up, and are never committed.
- Log user IDs, not emails, names or tokens.
- Auth endpoints get rate limits before public launch.
- Access tokens carry their issue time in microseconds. A password reset, a
  Google link and an account deletion request set `accounts.tokens_valid_after`
  in the same transaction, and `RequireAccount` rejects older tokens. Each
  instance caches that time per account for 30 seconds and updates its own
  cache at once, so other instances may accept a revoked token for up to 30 s.
- `govulncheck` passes before every merge.

## 8. Logging

[go-blog-slog]

- `log/slog` with the JSON handler, built in `main` and passed down. No
  `log.Printf`, no `fmt.Println`.
- Key–value pairs, never interpolated strings:
  `logger.InfoContext(ctx, "account created", "userID", id)`.
- Every line from a request carries its `requestID`.
- Levels: `Error` for something an engineer must look at, `Warn` for
  degraded-but-working, `Info` for lifecycle events. No `Debug` in hot paths.

## 9. Dependencies

[go-managing-dependencies]

- Standard library first. A new dependency needs a one-line reason in the
  change description.
- Approved so far: `github.com/jackc/pgx/v5`, `golang.org/x/crypto`,
  `github.com/google/go-cmp` (tests), `golang.org/x/vuln` (tool).
- Dev tools are module tools (`go get -tool …`, run with `go tool …`), so
  everyone uses the same version.
- `go mod tidy` leaves no diff.

## 10. Comments and documentation

- **No comments.** No doc comments, no package comments, no `ponytail:`, no
  `TODO`, in Go, SQL or YAML. Names carry the meaning; reasons that matter go
  in this file.
- The only exceptions are compiler and linter directives: `//go:embed`,
  `//nolint:<linter>`.
- `openapi.yaml` changes in the same commit as the handler it describes; it
  is the documentation.

## 11. Testing

[go-blog-subtests, go-wiki-table-driven-tests, go-wiki-test-comments,
google-go-style-best-practices "Tests"]

- Table-driven tests with `t.Run(tc.name, …)`.
- Failure messages say what was called, what came back, what was wanted:
  `SignUp(%q) = %v, want %v`. Got before want.
- Compare structs with `cmp.Diff(want, got)`, not `reflect.DeepEqual`.
- Handlers are tested through `httptest` against the real mux and
  middleware, with an in-memory fake store.
- Stores are tested against a real PostgreSQL named in
  `ACADEME_TEST_DATABASE_URL`, each test in a fresh schema; the test skips when
  it is unset.
- `t.Context()` for contexts in tests; `testing/synctest` for anything that
  waits on time. [go-1.25-release-notes]
- Fakes over mocks. No mocking framework.
- Every test file runs clean under `-race`.

## 12. Running locally

```
docker compose up -d --wait
export ACADEME_DATABASE_URL='postgres://academe:academe@localhost:5432/academe?sslmode=disable'
export ACADEME_TOKEN_KEY=$(openssl rand -base64 32)   # new key = apps refresh once
export ACADEME_ADDR=:8080                             # default
export ACADEME_GOOGLE_CLIENT_IDS=<web>,<android>,<ios> # optional; unset = Google returns 503
export ACADEME_SARVAM_API_KEY=<key>                   # optional; unset = ASKMe and Scan return 503
export ACADEME_SARVAM_MODEL=sarvam-105b               # default
export ACADEME_REVENUECAT_SECRET_KEY=<sk_…>            # optional; unset = /billing/sync returns 503
export ACADEME_REVENUECAT_WEBHOOK_AUTH='Bearer <long random>' # optional; unset = the webhook returns 503
export ACADEME_FREE_LIMITS=askme=10,scan=3,check=1,lessons=0 # default; -1 = unlimited, 0 = Pro only
go run ./cmd/academe-api
```

`ACADEME_GOOGLE_CLIENT_IDS` lists the OAuth client IDs whose Google ID tokens
the server accepts (the `aud` claim). With the `google_sign_in` plugin on
Android the token's audience is the **web** client ID passed as
`serverClientId`.

From the Pixel 10 emulator the Mac is `http://10.0.2.2:<port>`.

## 13. Definition of done

Run from `server/`:

```
gofmt -l .                       # prints nothing
go vet ./...
golangci-lint run                # config in .golangci.yml
ACADEME_TEST_DATABASE_URL=$ACADEME_DATABASE_URL go test -race ./...
go tool govulncheck ./...        # no vulnerability our code calls
```

Then run the Flutter app on the Pixel 10 against the local server for any
change the app can see.

Then tick the task in `../tasks/roadmap.md` and add a line to its change log.
