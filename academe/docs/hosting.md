# Hosting

The Go API and PostgreSQL run on **Railway**, region **Southeast Asia
(Singapore, `asia-southeast1-eqsg3a`)**. Railway has no India region; its four
regions are US West, US East, EU West (Amsterdam) and Singapore.

```
 Android app ──HTTPS──▶ api.academe.cc ─┐
 Browser    ──HTTPS──▶ academe.cc      ─┤  Railway edge (TLS, X-Real-IP)
                       www.academe.cc  ─┘        │
                                                 ▼
                                   service "api"  (server/Dockerfile, 1 replica)
                                   /healthz, JSON logs, migrations at start
                                                 │  private network (WireGuard)
                                                 ▼
                                   service "Postgres" (volume, backups, PITR)
                                   postgres.railway.internal:5432
```

One image serves the API and the public pages (privacy, terms, delete-account,
landing) from `internal/site`. The app talks only to `api.academe.cc`.

## What the server does for Railway

| Concern | How |
|---|---|
| Port | `ACADEME_ADDR`, else `:$PORT` (Railway injects it), else `:8080` |
| Image | multi-stage, `CGO_ENABLED=0`, `-trimpath -ldflags="-s -w"`, `distroless/static-debian12:nonroot` (uid 65532), ~27 MB |
| Migrations | applied at start under an advisory lock, before the port opens |
| Health | `GET /healthz` pings Postgres; Railway waits for a 2xx before switching traffic |
| Zero downtime | `overlapSeconds: 20`, `drainingSeconds: 30`; SIGTERM → `srv.Shutdown` with 10 s |
| Pool | 10 connections; override with `?pool_max_conns=N` on the database URL |
| Client IP | `ACADEME_CLIENT_IP_HEADER=X-Real-IP` makes `r.RemoteAddr` the address Railway's edge saw. Unset = the TCP peer. Only set it behind a proxy that overwrites the header |
| Logs | `slog` JSON on stdout; Railway indexes `level` and `msg` and every other key |
| Config as code | `server/railway.json`: Dockerfile builder, health check, restart on failure, Singapore region |

Railway limits worth knowing: 15 min max request, 5 min idle, 32 KB headers,
TLS 1.2/1.3, HTTP/2. Health checks run only at deploy time, not continuously.

## Environment variables (service `api`)

| Variable | Production value | Required |
|---|---|---|
| `ACADEME_DATABASE_URL` | `${{Postgres.DATABASE_URL}}` (reference variable, private network) | yes |
| `ACADEME_TOKEN_KEY` | `openssl rand -base64 32`, piped in with `--stdin` | yes |
| `PORT` | `8080` (pins the port the domain targets) | yes |
| `ACADEME_CLIENT_IP_HEADER` | `X-Real-IP` | yes |
| `ACADEME_SARVAM_API_KEY` | Sarvam key (repo `.env` `SARVAM_API_KEY`) | ASKMe and Scan |
| `ACADEME_SARVAM_MODEL` | `sarvam-105b` (default) | no |
| `ACADEME_GOOGLE_CLIENT_IDS` | web, Android and iOS OAuth client IDs, comma-separated | Google sign-in |
| `ACADEME_RESEND_API_KEY` | Resend API key | password-reset mail |
| `ACADEME_EMAIL_FROM` | `ACADEMe <no-reply@academe.cc>` (domain verified in Resend) | with Resend |
| `ACADEME_EMAIL_DEV` | leave **unset** in production (`1` logs reset codes) | no |
| `ACADEME_REVENUECAT_SECRET_KEY` | RevenueCat secret API key (Project settings → API keys) | purchases |
| `ACADEME_REVENUECAT_WEBHOOK_AUTH` | random string, `openssl rand -hex 32`; same value in RevenueCat webhook "Authorization header" | purchases |
| `ACADEME_GOOGLE_PLAY_SERVICE_ACCOUNT` | service-account JSON (inline, starts with `{`), only while the config still reads it | legacy billing |
| `ACADEME_BILLING_RTDN_SECRET` | random string, only while the config still reads it | legacy billing |
| `ACADEME_FREE_LIMITS` | e.g. `askme=10,scan=3`; unset = built-in defaults | no |
| `ACADEME_ADDR` | leave unset | no |

Check the list against the code before each deploy:

```
grep -rhoE 'ACADEME_[A-Z_]+' server --include='*.go' | sort -u
```

RevenueCat dashboard: webhook URL `https://api.academe.cc/billing/revenuecat/webhook`,
authorization header = `ACADEME_REVENUECAT_WEBHOOK_AUTH`.

App release build defines: `API_BASE_URL` defaults to `https://api.academe.cc` in
release (`http://10.0.2.2:8080` in debug/profile), plus
`GOOGLE_SERVER_CLIENT_ID`, `REVENUECAT_GOOGLE_API_KEY` (public SDK key `goog_…`),
later `REVENUECAT_APPLE_API_KEY`. Release Android builds have no network
security config, so cleartext is refused (targetSdk ≥ 28); the cleartext
allowance for `10.0.2.2`/`localhost` lives only in `src/debug`.

## Plan and cost

Use the **Pro** plan ($20/month, $20 usage included):

- Hobby allows 2 custom domains per service; we need 3 (`api`, apex, `www`).
- Scheduled volume backups are Pro only; this database holds children's data.

Estimated usage at launch (a few thousand students):

| Item | Size | Monthly |
|---|---|---|
| api | ~0.1 GB RAM, ~0.05 vCPU avg | ~$2 |
| Postgres | ~0.3 GB RAM, ~0.05 vCPU, 1–2 GB volume | ~$4 |
| Backups + PITR archive | incremental, compressed | < $1 |
| Egress | JSON only, a few GB | < $1 |
| **Total** | | **~$7 usage → covered by the $20 Pro fee** |

Sarvam, Resend and RevenueCat are billed separately. Set a hard limit:
`railway usage limit set --target workspace --soft 40 --hard 50` (or Workspace → Usage).

## Deploy runbook

Prerequisites: workspace on Pro; Sarvam key in `.env`; Resend key and
RevenueCat keys at hand; Namecheap login for `academe.cc`.

The exact commands are in `tasks/reports/hosting.md` ("Command block"). In order:

1. `railway init --name academe` in `server/` (links the directory).
2. `railway add --database postgres`, then move it to Singapore:
   `railway service scale --service Postgres southeast-asia=1 us-west=0 us-east=0 eu-west=0`
   (confirm in Postgres → Settings → Region). Do this before any data exists.
3. `railway postgres pitr enable --service Postgres`; in the dashboard,
   Postgres → Backups → enable **Daily** and **Weekly**.
4. `railway add --service api`, set variables with `--skip-deploys`, secrets via `--stdin`.
5. `railway up --service api --ci` from `server/`: builds `Dockerfile`, runs
   migrations, waits for `/healthz`.
6. `railway domain api.academe.cc --service api --port 8080`, same for
   `academe.cc` and `www.academe.cc`. Each prints a CNAME target and a TXT record.
7. Add the records at Namecheap (below), wait for `railway domain status`
   to show the certificate, then `curl https://api.academe.cc/healthz`.
8. Later: connect GitHub for auto-deploys:
   `railway service source connect --repo <owner/repo> --branch main --service api`,
   with the service's Root Directory set to `/server` and config path
   `/server/railway.json`.

## DNS at Namecheap (Advanced DNS for academe.cc)

Today `academe.cc` has two A records (Namecheap parking `162.255.119.53` and
Vercel `216.198.79.1`) and `www` is a CNAME to Vercel. Those go; mail
forwarding (MX `eforward*.registrar-servers.com` and the SPF TXT) stays.

| Type | Host | Value | Note |
|---|---|---|---|
| CNAME | `api` | `<target>.up.railway.app` from `railway domain api.academe.cc` | |
| ALIAS | `@` | `<target>.up.railway.app` from `railway domain academe.cc` | delete both `@` A records first; ALIAS is Namecheap's flattened CNAME and coexists with the MX records |
| CNAME | `www` | `<target>.up.railway.app` from `railway domain www.academe.cc` | replaces the Vercel CNAME |
| TXT | `_railway-verify.<host>` (exact host printed by the CLI) | printed value | one per domain; without it Railway answers 404 |
| TXT/CNAME/MX | as shown in Resend → Domains | DKIM, SPF and return-path for sending mail | |

If the ALIAS does not verify, move the nameservers to Cloudflare (free)
and use CNAME flattening with the proxy off (DNS only). TTL: Automatic. Railway
issues Let's Encrypt certificates once the CNAME resolves (renewed at 30 days left).

## Backups and restore

- **Volume backups** (Pro): daily kept 6 days, weekly kept 27 days, monthly
  kept 89 days. Restore: Postgres → Backups → Restore → review the staged change
  → Deploy. Restores go to a new volume in the same project and environment.
- **PITR** (`railway postgres pitr`): WAL archived with pgBackRest, ~4 weeks window.
- **Off-platform copy**, weekly and before every risky migration:

  ```
  railway run --service Postgres -- sh -c 'docker run --rm postgres:18 pg_dump "$DATABASE_PUBLIC_URL" -Fc' > academe-$(date +%F).dump
  docker run --rm -i postgres:18 pg_restore --clean --no-owner -d "$TARGET_URL" < academe-YYYY-MM-DD.dump
  ```

  Store dumps encrypted (they contain personal data) and delete after 30 days.

## Rollbacks

- Code: Railway dashboard → api → Deployments → a previous deploy → **Redeploy**
  (or `railway up` from the previous git commit).
- Migrations only go forward and are additive, so an older image runs against a
  newer schema. A destructive migration needs a manual dump first.
- Variables: every change creates a new deployment; revert the value and redeploy.

## Monitoring

- Logs: `railway logs --service api` (stream), `railway logs --http`,
  `--lines 200`, filter in the dashboard with `@level:ERROR`.
- Metrics: `railway metrics --service api` (CPU, RAM, HTTP).
- Uptime: Railway's health check only runs at deploy time, so add an external
  monitor (Better Stack or UptimeRobot free tier) on
  `https://api.academe.cc/healthz` every minute, alerting by email.
- Dashboard → Observability → alerts on CPU > 80 % and memory > 80 %.
- Usage alerts: Workspace → Usage → email at 75 % of the limit.

## Scaling path

1. Raise pool size (`?pool_max_conns=20`) and give Postgres more RAM; Railway
   scales vertically up to the plan limit without config.
2. More API replicas: `numReplicas` in `railway.json` (stateless, safe).
3. PgBouncer: `railway postgres pgbouncer add --service Postgres --pool-mode transaction`.
4. HA / read replica: `railway postgres ha convert --service Postgres --replicas 2`.
5. India latency or data residency: move to AWS `ap-south-1` (RDS + ECS/Fargate
   or Lightsail) or Fly `bom` when needed; the image and env vars are portable,
   the move is a `pg_dump` / `pg_restore` plus a DNS change.

## Why Railway, Singapore

| | Latency from India | Postgres | Ops effort | Cost at launch | Notes |
|---|---|---|---|---|---|
| **Railway (Singapore)** | ~50–90 ms | managed template, backups, PITR, HA | lowest; CLI already logged in | ~$20 | no India region |
| Fly.io (`bom`) | ~10–40 ms | Fly Managed Postgres, `bom` availability varies | medium | ~$40+ | `bom` had capacity and stuck-deploy incidents in 2026 |
| Render (Singapore) | ~50–90 ms | managed, PITR on paid tiers | low | ~$26+ | same geography as Railway, no advantage |
| AWS Lightsail / RDS Mumbai | ~10–40 ms | Lightsail DB or RDS | highest (IAM, VPC, TLS, deploys) | ~$30+ | data in India |

DPDP: the Act uses a negative list for cross-border transfer and no country is
restricted as of August 2026; Rule 15 applies from 13 May 2027. Hosting in
Singapore is lawful today; the privacy policy must say data is stored outside
India. Children's data needs verifiable parental consent regardless of where it
is hosted. A Mumbai move stays open (see scaling path).

## Pre-launch checklist

- [ ] Workspace on Pro; usage limit set
- [ ] Postgres region is Singapore, same as api
- [ ] Daily + weekly backups on, PITR on, one restore rehearsed
- [ ] `ACADEME_TOKEN_KEY` generated fresh, never reused from dev
- [ ] `ACADEME_EMAIL_DEV` unset
- [ ] `ACADEME_CLIENT_IP_HEADER=X-Real-IP`
- [ ] Rate limits on sign-up, log-in and password reset
- [ ] `https://api.academe.cc/healthz` → 200; `http://` redirects to HTTPS
- [ ] Privacy, terms and delete-account pages load on `academe.cc`
- [ ] RevenueCat webhook points at the API with the auth header; test event returns 2xx
- [ ] Resend domain verified; a reset email arrives
- [ ] Google OAuth client IDs include the Play-signing SHA-1 Android client
- [ ] Release APK built without `API_BASE_URL` talks to production
- [ ] External uptime monitor on `/healthz`
- [ ] CORS: not needed (mobile app only; public pages are same-origin)
- [ ] Secrets rotation: a new `ACADEME_TOKEN_KEY` makes every app refresh its
      access token once; API keys rotate by setting the new value, which
      redeploys with zero downtime
