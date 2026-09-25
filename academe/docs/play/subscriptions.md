# ACADEMe Pro: subscription setup, copy and required disclosures

Sources:
[Subscriptions policy](https://support.google.com/googleplay/android-developer/answer/9900533),
[Payments policy](https://support.google.com/googleplay/android-developer/answer/9858738).

## The plan

| | Monthly | Annual |
|---|---|---|
| Price | ₹200 / month | ₹1,999 / year |
| Introductory offer | First month ₹100, new subscribers only | none |
| Renewal | Automatic every month | Automatic every year |
| What it unlocks | No daily limits on Pebby (ASKMe), Scan and Check my answer; swipe lessons made from notes | same |

Free plan today (server defaults, `ACADEME_FREE_LIMITS`): 10 Pebby questions,
3 scans and 1 answer check a day; lessons from notes are Pro only. Limits reset
at midnight India time.

## Play Console setup

Monetise → Products → Subscriptions → Create subscription.

1. Product ID `academe_pro` (must match what the app and RevenueCat use; check
   with the billing workstream before creating, product IDs can't be reused).
   Name "ACADEMe Pro".
2. Base plans: `monthly` (auto-renewing, 1 month, ₹200) and `annual`
   (auto-renewing, 1 year, ₹1,999). Set India price; let Play convert others
   only if other countries are enabled.
3. Offer on `monthly`: `first-month` → Eligibility "New customer acquisition:
   never had this subscription" → one phase "Single payment / discounted
   recurring price", 1 billing period at ₹100. Tag it so RevenueCat picks it.
4. Grace period: 7 days. Account hold: 30 days (Play defaults are fine).
5. Real-time developer notifications → RevenueCat's Pub/Sub topic.
6. Benefits (up to 4, shown in the Play subscription page): "No daily limits on
   Pebby", "Unlimited homework scans", "Unlimited answer checks", "Lessons from
   your notes".

## What the paywall must show (policy checklist)

Every item is required by the Subscriptions policy. The paywall is built by the
billing workstream; this is the acceptance list.

- [ ] The **full billed price and period** for each option, as the main
      number: "₹200 a month", "₹1,999 a year". A per-month equivalent for the
      annual plan ("about ₹167 a month") may appear only as smaller secondary
      text next to ₹1,999. Showing ₹167 as the headline for a yearly charge is
      a named violation.
- [ ] The **introductory offer terms before purchase**: "₹100 for your first
      month, then ₹200 a month". Say when the price changes ("from the second
      month") and that it's for new subscribers only. Show the offer only when
      Play says the user is eligible (RevenueCat's `introPrice` / eligibility
      check); otherwise show ₹200.
- [ ] **Auto-renewal**: "Renews automatically until you cancel."
- [ ] **How to cancel**: "Cancel any time in Google Play > Payments and
      subscriptions." plus a working "Manage subscription" link in the app for
      subscribers: `https://play.google.com/store/account/subscriptions?sku=academe_pro&package=com.academe.flutter`.
- [ ] **What Pro includes** and that ACADEMe **works without it** (the free
      plan with daily limits).
- [ ] A clear **close / "Not now"** control on every paywall. No paywall in
      onboarding (USP 6), and never block the setup sheet.
- [ ] Prices come from Play (`StoreProduct.priceString`), not hard-coded, so
      they are localised and always match what Play charges. `ProOffer.defaults`
      in `lib/domain/models/pro.dart` should only be a loading placeholder.
- [ ] No fake urgency (countdowns, "only today") and no pre-selected annual
      plan that hides the monthly one.
- [ ] Deleting the ACADEMe account does not cancel the Play subscription: say
      so on the delete screen and on `academe.cc/delete-account` (the web page
      already does).

## Paste-ready copy

Paywall, under the plan buttons:

```
Monthly: ₹100 for your first month, then ₹200 a month.
Yearly: ₹1,999 a year (about ₹167 a month).
Billed through Google Play. Renews automatically until you cancel.
Cancel any time in Google Play > Payments and subscriptions.
ACADEMe stays free to use with daily limits.
```

Monthly button (eligible for the offer): `₹100 for 1 month, then ₹200/month`
Monthly button (not eligible): `₹200 a month`
Annual button: `₹1,999 a year`

Subscriber screen (Me > ACADEMe Pro):

```
ACADEMe Pro · Monthly
Renews on 25 October 2026 for ₹200.
[Manage in Google Play]
```

Cancelled but still active: `Pro until 25 October 2026. It won't renew.`

## Under-18 buyers

Most students are minors. Purchases go through the Google account on the
phone; in India, under-13 accounts are Family Link accounts where the parent
approves purchases. The terms of use say a parent or guardian is responsible for
purchases. Don't design the paywall to pressure children (no streak-loss
threats tied to buying, no "your friends have Pro").
