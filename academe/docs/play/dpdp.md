# India's DPDP Act 2023 and DPDP Rules 2025: what applies to ACADEMe

This is an engineer's reading of the law to plan the work, **not legal advice**.
Have a lawyer check it before 13 May 2027.

Sources: the Rules as notified,
[G.S.R. 846(E), 13 Nov 2025 (MeitY PDF)](https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf);
[PIB explainer](https://static.pib.gov.in/WriteReadData/specificdocs/documents/2025/nov/doc20251117695301.pdf);
the Act, [DPDP Act 2023 (MeitY PDF)](https://www.meity.gov.in/static/uploads/2024/06/2bf1f0e9f04e6fb4f8fef35e82c42aa5.pdf).

## Timeline

| Date | What starts |
|---|---|
| 13 Nov 2025 | Rules 1, 2, 17–21: definitions and the Data Protection Board |
| 13 Nov 2026 | Rule 4: registration of Consent Managers |
| **13 May 2027** | Rules 3, 5–16, 22, 23 ("eighteen months after the date of publication"): notice, security, breach notice, retention, contact details, **verifiable parental consent**, rights, cross-border. Some law firms count this as 14 May 2027; plan for 13 May. MeitY's commencement notification of the same day brings the Act's Data Fiduciary duties (sections 4–17, including section 9 on children) and penalties into force in the same phase. In January 2026 MeitY floated cutting the window to 12 months for Significant Data Fiduciaries only; that doesn't apply to us unless we are notified as one. Confirm with counsel |

Until then India's older IT Act rules (section 43A and the 2011 SPDI Rules)
apply. They require a published privacy policy, reasonable security and a
grievance officer, all of which we have or are adding now.

## Who we are under the law

- **Data Fiduciary**: the ACADEMe developer/company (fill in the legal name on
  `/privacy`).
- **Data Processors**: Sarvam AI, Railway, Resend, RevenueCat. Google (Sign-In,
  Play Billing) acts mostly as an independent fiduciary for its own data.
- **Children**: under the Act a child is anyone **under 18**. With Class 6–12,
  almost every user is a child.
- **Significant Data Fiduciary**: only if the government notifies us as one
  (volume, sensitivity, risk to children could be factors). Not today.
- **No exemption fits us.** The Fourth Schedule exempts *educational
  institutions* (schools, "institutions of learning that impart education")
  only for tracking and behavioural monitoring for their own educational
  activities or safety. An app company is not an educational institution unless
  counsel says otherwise. Part B exempts only narrow purposes, including
  "confirmation by the Data Fiduciary that the Data Principal is not a child"
  (item 6), which lets us ask age before consent.

## Obligations, what's done and what's missing

| Obligation | Where in the law | Done | Missing |
|---|---|---|---|
| Notice before consent: itemised data, purposes, how to withdraw, how to exercise rights, how to complain to the Board; understandable on its own; English plus any Eighth Schedule language on request | Act s.5, Rule 3 | `/privacy` itemises data and purposes, rights and the Board | A **separate consent notice shown in the app at sign-up** (not just a link), with a consent tick. Translations into Hindi, Telugu, Tamil, Bengali |
| Consent free, specific, informed, unambiguous, with a clear affirmative action; withdrawal as easy as giving it | Act s.6 | Deleting the account withdraws consent | Consent tick at sign-up; record of consent (timestamp, notice version) in the database |
| **Verifiable parental consent before processing any child's data** | Act s.9(1), **Rule 10** | Nothing | The **parent consent flow** below. This is the biggest piece of work |
| No processing likely to harm a child's well-being | Act s.9(2) | No ads, no selling, AI limited to study help, report button | Output moderation (see `ai-content.md`) |
| **No tracking or behavioural monitoring of children, and no targeted advertising at children** | Act s.9(3) | No ads, no analytics, no profiling | **Ask counsel**: is per-student study progress, spaced revision and XP "behavioural monitoring"? We think it is the service the student asked for, but streak nudges and usage-based reminders should be reviewed. Keep any future analytics aggregate and anonymous |
| Reasonable security safeguards: encryption, access control, logs and monitoring, backups, processor contracts | s.8(5), **Rule 6** | HTTPS, argon2id, short-lived tokens, request IDs in logs, account ownership checks on every query | Encryption at rest confirmation for Railway Postgres; backups; **access logs kept 1 year** (Rule 6(1)(e)); data processing agreements with Sarvam, Railway, Resend, RevenueCat |
| Breach notice: to each affected user without delay (what happened, likely impact, what we did, what they can do, a contact); to the Board without delay, detailed report within 72 hours | s.8(6), **Rule 7** | Nothing | A written breach runbook and email template (Resend is ready). Also CERT-In: report cyber incidents within **6 hours** (CERT-In Directions, April 2022) |
| Erase data when the purpose is served or consent is withdrawn; tell processors to erase too | s.8(7) | Account deletion: 30-day grace, then hourly purge cascades every table | Purge must also **delete the RevenueCat customer** (REST API) and ask Sarvam to delete anything it holds. Today neither happens |
| **Keep personal data, traffic data and processing logs for at least 1 year** (for the Seventh Schedule purposes), then erase | **Rule 8(3)** | Web deletion requests kept 1 year | **Conflict with our 30-day purge.** Counsel to confirm what must survive deletion. Likely answer: keep a minimal log (account ID, what was processed, when) for 1 year after processing, not the content. Build before May 2027 |
| 3-year inactivity erasure with 48-hour warning | Rule 8(1)–(2), Third Schedule | n/a | Applies only to large e-commerce, gaming and social media platforms. Not us |
| Publish contact details of a person who answers data questions, in the app and on the website, and in every reply to a rights request | s.8(9), **Rule 9** | `/support` has the Grievance Officer (placeholders) and support@academe.cc; the app's Privacy screen links to it | Fill in the name and address. Add the contact line to support email replies |
| Grievance redressal within **90 days** | s.8(10), s.13, **Rule 14(3)** | Promised on `/support` (acknowledge in 48 h, resolve within 90 days) | A tracked inbox or ticket label for grievances |
| Rights: access (summary of data and processing, processors it went to), correction, completion, updating, erasure, nomination | ss.11–14, Rule 14 | Correction in the app (name, class, board, language); erasure in the app and on the web | **Data export** ("Get a copy of my data" currently sends people to email us). A `GET /me/export` returning JSON of everything we hold would make this self-service. **Nomination** by email only |
| Cross-border transfer allowed unless the government restricts a country | s.16, Rule 15 | Railway Singapore, Resend and RevenueCat US: no restriction notified today | Watch for notifications |
| Consent Managers | s.6(7)–(9), Rule 4 | n/a | Optional to support |

## The parent consent flow we need (Rule 10)

The Rule gives three ways to check the person consenting is an identifiable
adult: (a) reliable identity and age details we already hold, (b) details the
parent provides, (c) a **virtual token from an authorised entity**, including
**DigiLocker**. The Rule's own examples (cases 2 and 4) have a parent who isn't
a user proving they're an adult through government-issued details or
DigiLocker.

Proposed flow:

1. **Age first** (exempt under Part B item 6): at sign-up ask the birth year
   before anything else. 18 or over → normal sign-up.
2. **Under 18**: collect only the student's first name and a parent's email or
   phone, and hold everything else. Show "Ask your parent to approve ACADEMe".
3. The parent gets a link, sees the consent notice (what we collect, why,
   Sarvam, rights), and verifies they're an adult through DigiLocker (age
   token) or an authorised age-verification provider.
4. On consent, create the account. Store: parent contact, verification method
   and reference, notice version, timestamp.
5. Parent dashboard (web page is enough): see the data summary, withdraw
   consent (= delete), change the student's settings.
6. Existing under-18 users: before 13 May 2027, ask for parent consent on next
   launch; after a deadline, freeze processing and delete if not given.

Open questions for counsel: whether "details voluntarily provided" (b) can be a
parent typing a name and birth date (weak), which DigiLocker integration path
is expected, and how to treat 18-year-olds in Class 12.

## Summary of work, in order

1. Fill in the legal name, address and Grievance Officer on the site (now).
2. Delete the RevenueCat customer on purge (now; also a Play deletion
   requirement).
3. Consent notice + tick at sign-up, consent records table (before launch is
   better; required by May 2027).
4. Data processing agreements with Sarvam, Railway, Resend, RevenueCat; ask
   Sarvam about retention of chat and Document AI job data.
5. Breach runbook; CERT-In 6-hour reporting; decide log retention (1 year per
   Rule 6/8, and CERT-In asks for 180 days of logs kept in India, which Railway
   Singapore doesn't satisfy on its own).
6. Data export endpoint and screen.
7. Parent consent flow with DigiLocker (by May 2027).
8. Counsel review of s.9(3) and Rule 8(3).
