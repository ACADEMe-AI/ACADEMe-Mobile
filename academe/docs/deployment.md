# Deployment

The API is a containerized Go service deployed to Google Cloud Run as
`academe-api` in `asia-south1` (Mumbai). PostgreSQL remains a managed database
dependency. The deployment provider is not part of the application contract.

## Required runtime settings

Set the variables from `server/AGENTS.md` in the deployment provider's secret
manager. Never commit credentials or provider JSON keys. The service must run
with `ACADEME_AI_PROVIDER=google`, the Google project, Vertex model/location,
Document AI processor, database URL, and token key configured.

Cloud Run should use the `vertex@academe-c9ea5.iam.gserviceaccount.com` service
account directly. Do not upload a service-account JSON key to Cloud Run unless
there is a documented exception.

## Service requirements

- Build from `server/Dockerfile`.
- Pass Cloud Run's `PORT`; the API falls back to `:8080` locally.
- Route public HTTPS traffic to the API container.
- Configure `GET /healthz` as the Cloud Run health check.
- Set `ACADEME_CLIENT_IP_HEADER` only when the reverse proxy overwrites that
  header; leave it unset when the service is directly exposed.
- Run database migrations before accepting traffic.
- Enable automated backups and test a restore before production traffic.
- Keep rollback to the previous application image and database-compatible
  migration in the deployment runbook.

## Release verification

1. Deploy the API with a temporary environment or preview service.
2. Confirm `/healthz` returns `200`.
3. Test sign-up, ASKMe, one-page Scan, and account deletion.
4. Check provider errors, database connectivity, and request IDs.
5. Promote only after the focused and full server tests pass.

Cloud Run service settings, the database provider, DNS records, and operational
credentials must be recorded here whenever they change.
