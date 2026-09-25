# Deploy report

## What exists on Railway

| | |
|---|---|
| Workspace | ACADEMe (account academe.noreply@gmail.com) |
| Project | `academe-cc` (id `ba8890bf-6b94-43bf-9afd-3471001139f7`), environment `production` |
| Services | `api` (built from `server/`: Dockerfile + `railway.json`) and `Postgres` (template `postgres-ssl:18`, 500 MB volume) |
| Region | both services and the volume are in `asia-southeast1-eqsg3a` (Southeast Asia, Singapore). I checked this with `railway service list --json` and the GraphQL `volumeInstance.region` |
| PITR | enabled (`railway postgres pitr enable`). This created the bucket `Postgres-PITR` |
| Postgres public TCP proxy | none. Postgres is reachable only over the private network |

The old project `ACADEMe` / `academe-api` was not touched. Every command ran from a
scratch directory linked to `academe-cc`, or passed `--project/--service/--environment`.

## URL and checks

Generated URL: **https://api-production-ac92.up.railway.app** (port 8080)

| Check | Result |
|---|---|
| Build and deploy (`railway up --ci`) | SUCCESS. Migrations ran, `listening addr=[::]:8080` |
| `GET /healthz` | 200 `{"status":"ok"}` |
| `/`, `/privacy`, `/terms`, `/support`, `/delete-account` | all 200 |
| `POST /auth/sign-up` → `GET /me` → `PATCH /me/profile` | 201 → 200 → 200 (`setupDone:true`, `xp:100`) |
| `POST /scans` (PNG rendered with headless Chrome, mode `solve`) | 201 in 25 s. Sarvam Document AI read the title and both questions correctly |
| `POST /chat/messages` (ASKMe) | **FAIL, 500** `tutor reply: sarvam returned no answer`. Cause and fix below |
| `POST /auth/password-reset` for an existing account | **500**. Resend returned 403 "The academe.cc domain is not verified". For an unknown email it returns 202. See below |
| `DELETE /me` on the test account | 202, then `/me` → 401. The account is erased for good on 2026-10-25 |

### ASKMe failure (app code, not hosting)

`sarvam-105b` is a reasoning model. With no `max_tokens` and no `reasoning_effort`,
it spends the default 2048 tokens reasoning (`finish_reason: length`) and returns
empty `content`. I tested the Sarvam API directly with the same prompt:

| Request extra | Time | Completion tokens | Content |
|---|---|---|---|
| none | – | 2048 (length) | empty |
| `"reasoning_effort": null` | 0.8 s | 53 | good answer |
| `"reasoning_effort": "low"` | 20 s | 1825 | good answer |
| `"max_tokens": 8192` | 22 s | 1956 | good answer |

Fix: where the ASKMe (and scan-solve) Sarvam client is built in
`cmd/academe-api/main.go`, set `Reasoning = json.RawMessage("null")` as
`cmd/academe-lessons/main.go` already does, or set a larger `MaxTokens`. After
that, run `railway up` again. No hosting change is needed.

### Password reset

- The email will not send until `academe.cc` is verified in Resend. Log line:
  `send reset code: resend status 403: {"statusCode":403,"message":"The academe.cc domain is not verified. Please, add and verify your domain on https://resend.com/domains","name":"validation_error"}`
- `internal/auth/reset.go:92` turns a send failure into a 500. For an unknown
  email the endpoint returns 202, so while mail is failing the response shows
  whether an account exists. The auth owner should log the error and still
  answer 202.

## DNS records to add at Namecheap (academe.cc → Advanced DNS)

First **delete** both apex A records: Namecheap parking `162.255.119.53` and
Vercel `216.198.79.1`. Also delete the `www` CNAME that points to Vercel. Keep the MX `eforward*` records and the SPF TXT.

For `api.academe.cc`, added on Railway:

| Type | Host | Value |
|---|---|---|
| CNAME | `api` | `qk1tncxf.up.railway.app` |
| TXT | `_railway-verify.api` | `railway-verify=fa95aacad598311e9f2b57e4d015224e71cfb71f5da13c0276b9417c6766b5de` |

For `academe.cc` and `www.academe.cc`, the plan limit blocked adding them, so no
targets exist yet. After upgrading, run:

```
railway domain academe.cc --service api --port 8080 --project ba8890bf-6b94-43bf-9afd-3471001139f7 --environment production
railway domain www.academe.cc --service api --port 8080 --project ba8890bf-6b94-43bf-9afd-3471001139f7 --environment production
```

Each command prints its own target and TXT record. Add them as:

| Type | Host | Value |
|---|---|---|
| ALIAS | `@` | `<target>.up.railway.app` printed for academe.cc |
| TXT | `_railway-verify` (exact host as printed) | printed value |
| CNAME | `www` | `<target>.up.railway.app` printed for www.academe.cc |
| TXT | `_railway-verify.www` (exact host as printed) | printed value |

Resend's DKIM, SPF and return-path records go in the same place (Resend → Domains → academe.cc).

Check progress with `railway domain status api.academe.cc --service api` from a
directory linked to `academe-cc`.

## Plan and limits

- The workspace is on **Hobby, trial** (`customer.state INACTIVE`, `isTrialing true`, $5 credit).
- **Custom domains: 1 per service on this plan.** `academe.cc` and `www` were refused
  with "You have reached the limit for custom domains per service on your plan".
  Pro allows all three.
- **Scheduled volume backups are not available.** The GraphQL
  `volumeInstanceBackupScheduleUpdate` call returned "Not Authorized". PITR is on.
  After upgrading to Pro, go to Dashboard → academe-cc → Postgres → Backups → enable
  **Daily** and **Weekly** (and Monthly if you want it).
- The trial credit will run out. Upgrade the workspace to Pro ($20/month) before
  launch, then set the spending limit:
  `railway usage limit set --target workspace --soft 40 --hard 50`.

## Variables on `api` (names only)

`ACADEME_DATABASE_URL` (reference `${{Postgres.DATABASE_URL}}` → `postgres.railway.internal:5432`),
`ACADEME_TOKEN_KEY` (new, generated and piped in through stdin), `ACADEME_SARVAM_API_KEY`,
`ACADEME_SARVAM_MODEL`, `ACADEME_RESEND_API_KEY`, `ACADEME_EMAIL_FROM`,
`ACADEME_CLIENT_IP_HEADER`, `PORT`, `ACADEME_REVENUECAT_ENTITLEMENT`.

Unset on purpose: `ACADEME_EMAIL_DEV` (never), `ACADEME_GOOGLE_CLIENT_IDS` (no IDs
yet, Google sign-in is disabled), `ACADEME_BILLING_TESTERS`, `ACADEME_FREE_LIMITS`
(the built-in defaults apply), `ACADEME_ADDR`.

**Not set yet: `ACADEME_REVENUECAT_SECRET_KEY` and `ACADEME_REVENUECAT_WEBHOOK_AUTH`.**
The permission system blocked writing these secrets and adding
`REVENUECAT_WEBHOOK_AUTH` to `.env`, so purchase sync is disabled on this deploy.
To set them yourself:

```
cd academe
printf 'REVENUECAT_WEBHOOK_AUTH=%s\n' "$(openssl rand -hex 32)" >> .env
sed -n 's/^REVENUE_CAT_API_KEY=//p' .env | tr -d '"\n\r' | railway variable set ACADEME_REVENUECAT_SECRET_KEY --stdin --service api --environment production --project ba8890bf-6b94-43bf-9afd-3471001139f7
sed -n 's/^REVENUECAT_WEBHOOK_AUTH=//p' .env | tr -d '"\n\r' | railway variable set ACADEME_REVENUECAT_WEBHOOK_AUTH --stdin --service api --environment production --project ba8890bf-6b94-43bf-9afd-3471001139f7
```

Then go to RevenueCat → Project ACADEMe → Integrations → Webhooks. The URL is
`https://api-production-ac92.up.railway.app/billing/revenuecat/webhook` for now, and
`https://api.academe.cc/billing/revenuecat/webhook` once DNS is live. The
Authorization header is the `REVENUECAT_WEBHOOK_AUTH` value in `.env`.

## How to redeploy

Pass the new project explicitly. The `server/` directory is not linked to it.

```
cd academe/server
railway up --ci --project ba8890bf-6b94-43bf-9afd-3471001139f7 --environment production --service api -m "<message>"
```

Use an account token (`RAILWAY_API_TOKEN`) or `railway login` as
academe.noreply@gmail.com. Logs: `railway logs --service api --project ba8890bf-6b94-43bf-9afd-3471001139f7 --environment production --lines 100`.

## What remains

1. Fix ASKMe's Sarvam call (`reasoning_effort: null` or a bigger `max_tokens`) and redeploy. Retest `POST /chat/messages` and scan solve.
2. Make the password reset answer 202 when mail sending fails.
3. Set the two RevenueCat secrets and the webhook (above).
4. Upgrade the workspace to Pro. Add the `academe.cc` and `www.academe.cc` domains, turn on Daily and Weekly backups, and set the usage limit.
5. Add the Namecheap records above and remove the two apex A records and the Vercel `www` CNAME.
6. Verify `academe.cc` in Resend and add its DNS records. Then check that a reset email arrives.
7. Add `ACADEME_GOOGLE_CLIENT_IDS` when the OAuth clients exist.
8. Add an external uptime monitor on `/healthz`.
9. Delete the old `ACADEMe` project when you no longer need it. I left it untouched.
