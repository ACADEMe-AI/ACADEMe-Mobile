# Pro limits (3×)

Free daily caps come from `ACADEME_FREE_LIMITS` (defaults: askme 10, scan 3, check 1, lessons 0).

Pro multiplies each positive daily cap by **3** (30 / 9 / 3). Lessons stay unlimited on Pro.

A **weekly combined pool** equals `7 ×` the sum of positive daily caps for the tier (Free 98, Pro 294). It is a safety cap; daily caps bind first.

Resets: daily at **midnight IST**; weekly on **Monday 00:00 IST**.

`GET /me/plan` adds `usedWeek`, `weekLimit`, and `weekResetsAt`.
