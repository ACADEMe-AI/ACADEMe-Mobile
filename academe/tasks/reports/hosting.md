# Hosting report

## Recommendation

Railway, **Singapore** region (`asia-southeast1-eqsg3a`), **Pro plan**.

- Railway has four regions (US West, US East, EU West, Singapore); **no India
  region**. Singapore adds roughly 50–90 ms from Indian cities, which is fine for
  a JSON API whose slow part is Sarvam anyway.
- Pro ($20/month, $20 usage included) is needed for 3 custom domains on one
  service (Hobby allows 2) and for scheduled volume backups (Hobby has none).
  Estimated usage is about $7, so the bill stays around $20.
- DPDP: cross-border transfer is a negative list, nothing is restricted (as of
  August 2026), and Rule 15 applies from 13 May 2027. Singapore is lawful; the
  privacy policy must say where data is stored. Parental consent for under-18s
  applies wherever we host.
- Fly `bom` is in India but had capacity and stuck-deploy incidents in 2026;
  Render Singapore gives the same latency for more money; AWS Mumbai (RDS +
  Lightsail/ECS) is the path if residency or latency becomes a requirement.
  The image and env vars are portable.

## What changed

Server (all built and tested):

- `server/internal/config/config.go`: listen address is `ACADEME_ADDR`, else
  `:$PORT`, else `:8080`. New `ACADEME_CLIENT_IP_HEADER`.
- `server/internal/httpx/middleware.go`: `TrustClientIP(header, next)` sets
  `r.RemoteAddr` from the named header (Railway's edge sets `X-Real-IP`) when
  it parses as an IP; no-op when unset. Wired outermost in `main.go`, so rate
  limiters keyed on `r.RemoteAddr` see the real client. Test:
  `server/internal/httpx/middleware_test.go`.
- `server/internal/postgres/postgres.go`: the 10-connection pool default yields
  to `pool_max_conns` in the database URL.
- `server/Dockerfile`: `-ldflags="-s -w"`. Already distroless static, nonroot.
- `server/.dockerignore`: `.git`, every `.env*`, `*.pem`, `*.key`, `*.p12`, `*.dump`, tests and testdata at any depth, compose file.
- `server/railway.json`: Dockerfile builder, `/healthz` check (60 s), restart on
  failure, overlap 20 s, draining 30 s, 1 replica in Singapore.

App:

- `lib/config/environment.dart`: `API_BASE_URL` defaults to
  `https://api.academe.cc` when `kReleaseMode`, `http://10.0.2.2:8080` otherwise.
- Android: checked, no change needed. Only `src/debug` has the network security
  config allowing cleartext to `10.0.2.2`/`localhost`; release has none and
  targets Flutter's default SDK, so cleartext is refused.

Docs: `docs/hosting.md` covers architecture, env vars, cost, runbook, DNS,
backup/restore, rollbacks, monitoring, scaling path, the comparison, and the
pre-launch checklist.

## How it was tested

- `docker build` → 26.4 MB image, runs as uid 65532.
- Ran it against local Postgres (throwaway database `academe_hosting`, dropped
  afterwards) with `PORT=9000` and no `ACADEME_ADDR`: migrations applied,
  listened on `[::]:9000`, `/healthz` → `{"status":"ok"}`, `docker stop` →
  "shutting down", exit 0.
- `go test -race ./internal/httpx/`, `golangci-lint` clean on httpx and postgres,
  govulncheck clean, gofmt clean. `flutter analyze` clean on `environment.dart`.
- Not done: `go vet ./cmd/...` and the full suite, because `internal/billing`
  is mid-change by another agent (`undefined: ErrPurchaseInUse`).
  `golangci-lint` flags gosec G304 at `config.go:70` (`os.ReadFile` of the
  service-account path) in the billing agent's code.

## Findings the user should know

- **academe.cc DNS today** (Namecheap nameservers): the apex has two A records,
  Namecheap parking `162.255.119.53` **and** Vercel `216.198.79.1`, and `www`
  is a CNAME to Vercel. Pointing them at Railway replaces whatever the Vercel
  project serves. Mail forwarding (MX `eforward*` + SPF) stays as it is.
- Namecheap supports a flattened apex through an **ALIAS** record on `@`.
- Railway health checks run only at deploy time. Add an external uptime
  monitor on `/healthz`.
- Postgres created by `railway add` starts in the workspace's default region.
  Move it to Singapore before any data is written (command below) and check it
  in the dashboard.

## Secrets list (re-grepped at the end)

In the code now: `ACADEME_ADDR`, `ACADEME_DATABASE_URL`, `ACADEME_TOKEN_KEY`,
`ACADEME_CLIENT_IP_HEADER`, `ACADEME_SARVAM_API_KEY`, `ACADEME_SARVAM_MODEL`,
`ACADEME_GOOGLE_CLIENT_IDS`, `ACADEME_RESEND_API_KEY`, `ACADEME_EMAIL_FROM`,
`ACADEME_EMAIL_DEV`, `ACADEME_GOOGLE_PLAY_SERVICE_ACCOUNT`,
`ACADEME_BILLING_RTDN_SECRET`, `ACADEME_FREE_LIMITS`, plus Railway's `PORT`.
Announced for RevenueCat, not in the code yet: `ACADEME_REVENUECAT_SECRET_KEY`,
`ACADEME_REVENUECAT_WEBHOOK_AUTH`. Production values are in `docs/hosting.md`.
Before deploying, run
`grep -rhoE 'ACADEME_[A-Z_]+' server --include='*.go' | sort -u`.

App release defines: `GOOGLE_SERVER_CLIENT_ID`, `REVENUECAT_GOOGLE_API_KEY`
(later `REVENUECAT_APPLE_API_KEY`). `API_BASE_URL` is not needed for release.

## Needs the user

1. Approve the Railway project, the services, the deploy and the DNS change.
2. Upgrade the Railway workspace to Pro.
3. Provide the Google OAuth client IDs, the Resend API key (and verify
   academe.cc in Resend), and the RevenueCat secret key.
4. In RevenueCat, set the webhook URL `https://api.academe.cc/billing/revenuecat/webhook`
   with the Authorization value generated below.
5. Add the Namecheap records that `railway domain` prints.

## Known limits and future work

- No rate limits yet. The client IP is ready for them.
- Postgres major-version upgrades on Railway mean a dump and restore.
- Move to Mumbai (AWS `ap-south-1`) if latency or residency requires it.
- Connect GitHub auto-deploys once the repo is pushed (root `/server`).

## Command block

This is the fastest path, about 15 minutes plus DNS propagation. Run it from
the repo after the user approves. Fill in the four `export` lines first. Lines
starting with `#` are shell notes and are not run.

```sh
cd /Users/sst/conductor/workspaces/academe-mobile/carthage/academe/server

export GOOGLE_CLIENT_IDS='<web-client-id>,<android-client-id>'
export RESEND_API_KEY='<resend key>'
export REVENUECAT_SECRET_KEY='<revenuecat secret key>'
export RC_WEBHOOK_AUTH="$(openssl rand -hex 32)"

railway init --name academe
railway usage limit set --target workspace --soft 40 --hard 50
railway add --database postgres
railway service scale --service Postgres southeast-asia=1 us-west=0 us-east=0 eu-west=0
railway postgres pitr enable --service Postgres
railway add --service api

railway variable set --service api --skip-deploys \
  'ACADEME_DATABASE_URL=${{Postgres.DATABASE_URL}}' \
  PORT=8080 \
  ACADEME_CLIENT_IP_HEADER=X-Real-IP \
  ACADEME_SARVAM_MODEL=sarvam-105b \
  'ACADEME_EMAIL_FROM=ACADEMe <no-reply@academe.cc>' \
  "ACADEME_GOOGLE_CLIENT_IDS=$GOOGLE_CLIENT_IDS"
openssl rand -base64 32 | tr -d '\n' | railway variable set ACADEME_TOKEN_KEY --stdin --service api --skip-deploys
sed -n 's/^SARVAM_API_KEY=//p' ../.env | tr -d '"\n\r' | railway variable set ACADEME_SARVAM_API_KEY --stdin --service api --skip-deploys
printf %s "$RESEND_API_KEY" | railway variable set ACADEME_RESEND_API_KEY --stdin --service api --skip-deploys
printf %s "$REVENUECAT_SECRET_KEY" | railway variable set ACADEME_REVENUECAT_SECRET_KEY --stdin --service api --skip-deploys
printf %s "$RC_WEBHOOK_AUTH" | railway variable set ACADEME_REVENUECAT_WEBHOOK_AUTH --stdin --service api --skip-deploys

railway up --service api --ci -m "first production deploy"
railway deployment list --service api
railway logs --service api --lines 50

railway domain api.academe.cc --service api --port 8080
railway domain academe.cc --service api --port 8080
railway domain www.academe.cc --service api --port 8080

# Namecheap → academe.cc → Advanced DNS:
#   delete the A records on @ (162.255.119.53, 216.198.79.1) and the www CNAME to Vercel
#   add CNAME api → <target printed for api.academe.cc>
#   add ALIAS @   → <target printed for academe.cc>
#   add CNAME www → <target printed for www.academe.cc>
#   add each TXT verification record exactly as printed
#   keep MX eforward* and the SPF TXT
# Dashboard → Postgres → Backups: enable Daily and Weekly; confirm Region = Southeast Asia for both services
# RevenueCat → Integrations → Webhooks: URL https://api.academe.cc/billing/revenuecat/webhook, Authorization = value of $RC_WEBHOOK_AUTH

railway domain status api.academe.cc --service api
curl -fsS https://api.academe.cc/healthz
curl -fsS -o /dev/null -w '%{http_code}\n' https://academe.cc/
```

If `railway init` asks for a workspace, pick the one on Pro, or pass
`--workspace <name>`.
