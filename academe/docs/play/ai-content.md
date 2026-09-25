# Generative AI: how ACADEMe meets Play's AI-Generated Content policy

Sources:
[Understanding Google Play's AI-Generated Content policy](https://support.google.com/googleplay/android-developer/answer/14094294),
[Developer Program Policy](https://support.google.com/googleplay/android-developer/answer/17190352),
[Enabling safe AI experiences on Google Play (Android Developers Blog, June 2024)](https://android-developers.googleblog.com/2024/06/enabling-safe-ai-experiences.html).

## Are we in scope?

Yes. The policy covers "text-to-text AI chatbot apps, in which the AI generated
chatbot interaction is a central feature". ASKMe (Pebby) is a central feature.
Scan's "Check my answer" marks and "lessons made from notes" are also generated
by the model. The exemption for "productivity tools with incidental AI" does not
fit us.

## What the policy requires, and where we stand

| Requirement | How we meet it | Status |
|---|---|---|
| The app must not generate offensive content: anything banned by the Inappropriate Content policies, content that exploits or abuses children, or content that deceives users | Pebby's system prompt (`server/internal/chat/sarvam.go`) limits it to study help for an Indian school student of a given class and tells it to refuse anything unsafe or unrelated to studying. The model is Sarvam's `sarvam-105b` | Partly. There is no second-pass output filter. See "Next steps" |
| Users can report or flag offensive AI output **in the app, without leaving it** | A **Report** (flag) icon under every Pebby answer opens a sheet: "It's wrong", "It's harmful or unsafe", "It's rude or offensive", "Something else". It calls `POST /chat/messages/{id}/report`, which stores the report in `chat_reports` | **Done** for ASKMe answers |
| Developers use reports to inform filtering and moderation | Someone reads `chat_reports` every week (query below) and tightens the prompt or adds filters | Process, not code. Must be staffed |
| Tell users content is AI-generated | Pebby is presented as the AI tutor; the privacy policy and terms say answers are AI-generated and can be wrong | Done in the policy pages. Consider a one-line note on the ASKMe empty state |

## What the in-app Report action does (built)

- Where: every Pebby reply in ASKMe, in the action row after thumbs up, thumbs
  down, copy and (on the last answer) try again. Icon: `Icons.flag_outlined`,
  tooltip "Report". Files: `lib/ui/askme/widgets/reply_actions.dart`,
  `lib/ui/askme/widgets/report_sheet.dart`.
- Flow: tap → bottom sheet "Report this answer" with four reasons → pick one →
  the sheet closes → snackbar "Thanks. We'll review this answer." or "Couldn't
  send the report. Try again." The student never leaves the app.
- API: `POST /chat/messages/{id}/report` with `{"reason": "wrong" | "harmful" |
  "offensive" | "other", "note": "optional, up to 500 characters"}` → `204`.
  Only the student's own Pebby answers can be reported (`404` otherwise).
  Reporting again replaces the earlier report.
- Storage: `chat_reports (message_id, account_id, reason, note, created_at)`,
  deleted with the account (cascade) when it's purged.

Weekly review query:

```sql
SELECT r.created_at, r.reason, r.note, m.body AS answer,
       (SELECT body FROM chat_messages q
        WHERE q.thread_id = m.thread_id AND q.id < m.id
        ORDER BY q.id DESC LIMIT 1) AS question
FROM chat_reports r JOIN chat_messages m ON m.id = r.message_id
WHERE r.created_at > now() - interval '7 days'
ORDER BY r.reason = 'harmful' DESC, r.created_at DESC;
```

## Gaps and next steps

1. **Report on other AI output.** "Check my answer" results and lessons made
   from notes are AI-generated too but have no Report button yet. Add the same
   sheet to the marks screen and the lesson player for AI-made decks (a
   `POST /scans/{id}/report` or a generic report route).
2. **Output moderation.** Add a cheap check before an answer is shown: a
   keyword list for sexual content, self-harm and slurs in all five languages,
   and/or a second model call asking "is this safe for a 12-year-old?". Children
   are in the audience, so this matters more than for a general chatbot.
3. **Self-harm and abuse.** If a student writes about self-harm or abuse, Pebby
   should answer kindly and show a helpline (Tele-MANAS 14416, Childline 1098)
   rather than refuse. Put this in the system prompt and test it.
4. **Red-team before launch.** Try jailbreaks in English, Hinglish, Hindi,
   Telugu, Tamil and Bengali; record results in `tasks/`.
5. **Alert on harmful reports.** Email support@academe.cc when a `harmful`
   report comes in, instead of waiting for the weekly review.
