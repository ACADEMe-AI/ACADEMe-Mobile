# Hosting test report

Independent check of the hosting workstream (`tasks/reports/hosting.md`, `docs/hosting.md`).
Nothing was created or changed on Railway or in DNS.

## Results

| # | Check | Result |
|---|---|---|
| 1a | `docker build` of `server/` | PASS, 27.3 MB, `User` = 65532 (distroless nonroot) |
| 1b | Run against a throwaway `postgres:18` container, random port 35049, `PORT` set, `ACADEME_ADDR` unset | PASS, listened on `[::]:35049`, migrations created the tables |
| 1c | `GET /healthz` | PASS, `{"status":"ok"}` |
| 1d | Process user (`docker top`) | PASS, uid 65532 |
| 1e | SIGTERM (`docker stop`) | PASS, logged "shutting down", exit code 0 |
| 1f | Cleanup | PASS, containers, network and test image removed |
| 2a | `config.go` PORT fallback (`ACADEME_ADDR` → `:$PORT` → `:8080`) | PASS; added `server/internal/config/config_test.go` covering all three |
| 2b | `ACADEME_CLIENT_IP_HEADER` + `httpx.TrustClientIP` | PASS: no-op when unset, ignores unparseable values and comma lists, wired outermost in `main.go`, test covers v4, v6, garbage and unset |
| 2c | IP spoofing | PASS with conditions (below) |
| 2d | Postgres pool override (`pool_max_conns` in the URL) | PASS |
| 2e | Dockerfile | PASS |
| 2f | `.dockerignore` | FIXED (below) |
| 2g | `railway.json` against `https://railway.com/railway.schema.json` | PASS: every key exists; `DOCKERFILE`, `ON_FAILURE` valid; `asia-southeast1-eqsg3a` is the documented Singapore ID; `/healthz` matches the server route |
| 3a | `lib/config/environment.dart` | PASS: release `https://api.academe.cc`, otherwise `http://10.0.2.2:8080` |
| 3b | Android release refuses cleartext | PASS: network security config only in `src/debug`; no `usesCleartextTraffic` anywhere; merged release manifest has targetSdk 36 and no cleartext flag |
| 4 | Runbook CLI commands against `railway --help` (CLI 5.62.1, the latest on npm) | PASS after one fix (below) |
| 5 | gofmt, `go vet ./...`, `golangci-lint run` (whole module), `go test -race ./...` with the test DB, govulncheck | PASS: all clean, full suite green, 0 reachable vulns. The billing breakage noted in the hosting report is gone |

## Fixes made

- `server/.dockerignore`: `.env` and `*_test.go` only matched at the root of the build
  context, so a nested `.env` would have gone into the build stage. It now uses `**/`
  patterns and also excludes `.env*`, `*.pem`, `*.key`, `*.p12`, `*.dump` and `testdata`.
  I checked this with a build of a scratch context that had nested `.env`, `.env.production`, `.pem` and `.key` files, and none of them were copied.
  The final image only ever held the static binary, and the repo-root `.env` is outside
  the `server/` context, but secrets should not reach the build cache either.
- `docs/hosting.md`: `railway usage limit` on its own only shows the limit. The correct command is
  `railway usage limit set --target workspace --soft 40 --hard 50`. Also changed the image size to ~27 MB.
- `tasks/reports/hosting.md`: added the usage-limit command to the command block and
  corrected the `.dockerignore` description.

## Runbook commands verified (flags exist in CLI 5.62.1)

`init --name/--workspace`, `add --database postgres`, `add --service api`,
`service scale --service … southeast-asia=1 us-west=0 …`, `postgres pitr enable --service`,
`variable set --service --skip-deploys KEY=VAL…` and `--stdin` with a single KEY,
`up --service --ci -m`, `deployment list --service`, `logs --service --lines/--http`,
`domain <host> --service --port`, `domain status <host> --service`,
`service source connect --repo --branch --service`, `postgres pgbouncer add --pool-mode`,
`postgres ha convert --replicas`, `metrics --service`, `run --service … -- cmd`,
`usage limit set`.

## Unverifiable without touching Railway

- The service name that `railway add --database postgres` creates is assumed to be `Postgres`. Every later
  `--service Postgres` and the `${{Postgres.DATABASE_URL}}` reference depend on it. Check it with
  `railway service list` right after that command.
- Whether `service scale` moves an existing volume-backed Postgres cleanly, and whether passing
  `=0` for regions the service never used is accepted. Do it before any data exists, as the
  runbook says, and confirm the region in the dashboard.
- `DATABASE_PUBLIC_URL` in the pg_dump recipe needs the Postgres TCP proxy, which the template
  enables by default. That proxy also exposes Postgres publicly with its password.
- The dashboard log filter syntax `@level:ERROR`.
- The TXT verification host format that `railway domain` prints. Copy it exactly as printed.

## What the user must know

- Client IP trust: Railway's docs only say X-Real-IP identifies the client IP.
  They do not say whether the edge overwrites a value the client sends. Railway Station threads and
  several public fixes say the edge now overwrites any client-supplied `X-Real-IP` after an
  earlier spoofing report. `ACADEME_CLIENT_IP_HEADER=X-Real-IP` is therefore safe only while
  every request arrives through Railway's HTTP edge. Never add a TCP proxy to the `api` service,
  and do not reuse this setting behind another host without checking it. Other services on the private
  network can still set the header, which is acceptable because they are ours. The server does not log the client
  IP, so there is no in-app way to confirm this after deploy. Confirm it once rate limits exist.
- Profile builds (`--profile`) default to `http://10.0.2.2:8080` but have no cleartext
  allowance, so a profile build needs `--dart-define=API_BASE_URL=https://…`.
- `drainingSeconds: 30` is longer than the server's 10 s shutdown, which is correct.

Sources: [Railway specs and limits](https://docs.railway.com/networking/public-networking/specs-and-limits),
[Railway regions](https://docs.railway.com/reference/deployment-regions),
[Railway config schema](https://railway.com/railway.schema.json),
[Station: X-Real-IP can't be trusted](https://station.railway.com/questions/edge-proxy-x-forwarded-for-and-x-real-ip-c5a50049),
[Station: which header to rely on](https://station.railway.com/questions/which-header-should-i-rely-on-for-real-c-d78a6f96).
