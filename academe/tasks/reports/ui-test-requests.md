# UI test requests

## Notifications permission (from the notifications tester)

Pixel 10, fresh install (`adb uninstall com.academe.flutter` first). Details in `tasks/reports/notifications-test.md`.

1. Create a folder with a date and reminders on. The primer sheet appears once. "Not now" closes it with no system dialog. Relaunch: no primer. Me → Reminders and goal shows "Not allowed" + "Turn on notifications", and tapping it shows the system dialog.
2. Fresh install: primer → Allow → system Allow. Me shows "Allowed", and `adb shell dumpsys alarm | grep com.academe.flutter` lists alarms.
3. Primer → Allow → Don't allow. Me shows "Turn on in Settings", which opens the app's notification settings page. Turn it on and press back: Me shows "Allowed" with no restart, and the alarms are present.
4. After allowing, turn notifications off in Settings and come back. Me shows "Not allowed" + "Turn on in Settings".
5. Dragging the primer down acts like Not now: no system dialog, and the primer doesn't come back.
6. Screenshot the primer in light and dark: Pebby, title, three lines and two buttons all fit.

## Password reset (from the password-reset tester)

Pixel 10, local server with `ACADEME_EMAIL_DEV=1` (the code is printed in the server log as `"msg":"reset code sent",…,"code":"NNNNNN"`). Details in `tasks/reports/password-reset-test.md`.

1. **Full journey**: sign up with an email account and log out. Log in → email → "Forgot password?": the email is pre-filled. Send code → Check your email. Type the code from the log: it verifies on the 6th digit with no tap. New password (use show/hide, check the 8+ indicator) → Save and log in → celebration → home. Log out, then log in with the old password (Wrong email or password) and with the new one (home).
2. **Paste code**: copy text containing the code with other characters (for example `Your code: 482 913.`) to the clipboard (`adb shell` input or a notes app), then tap "Paste code". The six boxes fill with the digits only and it verifies automatically. Also long-press the field and use the system Paste.
3. **Countdown**: on Check your email, "You can ask for a new code in 0:30" counts down each second to 0:00, then becomes "Didn't get it? Send a new code". Tap it: "Sending a new code…", then "New code sent. You can ask again in 0:30". The old code is now refused and the new one from the log works.
4. **Lockout**: enter 5 wrong codes. Boxes 1–4 turn red with "That code isn't right". On the 5th, the field locks with "Too many wrong codes" and "Send a new code" is offered at once, with no countdown. The right code can't be entered. A new code works.
5. **Throttle**: ask for a code 4 times in an hour for one email. The 4th shows the too-many-tries message and the app stays usable.
6. Screenshot all three screens at 1.0× and 1.3× font scale, with the keyboard up: nothing is clipped, and Pebby changes pose (thinking, encouraging, celebrating).

## Report sheet and Privacy screen (from the legal and Play tester)

Pixel 10, signed-in account, server with `ACADEME_SARVAM_API_KEY` set. Details in `tasks/reports/legal-play-test.md`.

1. **Report on every answer**: in ASKMe, ask two questions. Under each Pebby answer the action row shows thumbs up, thumbs down, copy, (last answer only) try again, then a flag icon with the tooltip "Report" (long-press). Student messages have no flag.
2. **Report flow**: tap the flag. The sheet "Report this answer" lists "It's wrong", "It's harmful or unsafe", "It's rude or offensive", "Something else". Pick one: the sheet closes and the snackbar says "Thanks. We'll review this answer." A row appears in `chat_reports` with that reason. Report the same answer again with another reason: still one row, reason replaced.
3. **Dismiss**: open the sheet and drag it down or tap outside. No snackbar, no row in `chat_reports`.
4. **Offline**: turn on airplane mode, report an answer: the snackbar says "Couldn't send the report. Try again." and the app stays usable.
5. **Privacy screen**: Me → Privacy and terms. Four summary lines, then Documents (Privacy policy, Terms of use) and Your data (Get a copy of my data, Grievance Officer, Email support@academe.cc). Each link opens the browser at https://academe.cc/privacy, /terms, /support and /support#grievance (the page scrolls to "Grievance Officer"). Until academe.cc points at the server the pages won't load; the check is that the right URL opens and the app doesn't crash. With no browser available, the snackbar "Open … in your browser" shows.
6. Help screen shows support@academe.cc (not help@academe.app).
7. Screenshot the Report sheet and the Privacy screen in light and dark, at 1.0× and 1.3× font scale: nothing clipped, sheet fits above the navigation bar.

## Account settings (from the account-settings builder)

Pixel 10, local server with migration 0021 applied, `ACADEME_GOOGLE_CLIENT_IDS` and `GOOGLE_SERVER_CLIENT_ID` set for the Google checks. Details in `tasks/reports/account-settings.md`.

1. **Email account**: sign up with email. Me → Account shows Email, "Change password", and "Link Google" with "Not linked". No "coming soon" anywhere on the screen.
2. **Change password**: tap Change password. The button stays disabled until both fields are filled and the new one is 8+ characters (the indicator turns green). A wrong current password shows "That isn't your current password." and the screen stays open. The right one pops back with "Password changed. Other devices have been logged out." The app keeps working (open ASKMe or Study) with no log-in prompt. Log out and log in with the old password (refused) and the new one (home).
3. **Other device revoked**: log in to the same account on a second emulator or a fresh install first. After step 2, the other device is sent to log-in on its next request.
4. **Throttle**: enter a wrong current password 5 times. The 6th try shows "That's a lot of tries…".
5. **Link Google**: tap Link Google. The Google picker opens; pick an account. The row becomes "Google" with that Gmail address and a "Google linked" snackbar. Log out, then Continue with Google logs into the same account, and email log-in with the password still works. Close the picker once: nothing shows. Try linking a Google account that already has its own ACADEMe account: "That Google account is linked to another ACADEMe account."
6. **Unlink**: tap the linked Google row. The "Unlink Google?" sheet shows Keep Google / Unlink. Keep changes nothing. Unlink shows "Not linked" and a snackbar.
7. **Google-only**: sign up with Continue with Google. Account shows "Set a password" and "Google" with the Gmail address. Tapping Google says to set a password first, with no sheet. Set a password (no current-password field): "Password set. You can now log in with your email too." The row now reads "Change password". Log out and log in with the email and new password.
8. **Delete account**: Me → Account → Delete my account. The Subscription group shows the Google Play notice. As a free student there's no Manage subscription row. As Pro (a test purchase or the server plan), "Manage subscription" opens Google Play's subscriptions page for com.academe.flutter.
9. Screenshot Account (email-linked, Google-only, and linked with a long Gmail address), the password screen with the keyboard up, the unlink sheet, and Delete account, in light and dark at 1.0× and 1.3× font scale. Long emails end in "…" and nothing is clipped.

## ACADEMe Pro: paywall, limits and Test Store (from the Pro plan tester)

Pixel 10, local server with `ACADEME_SARVAM_API_KEY` set. Details in `tasks/reports/pro-plan-test.md`. Leave `REVENUECAT_ENTITLEMENT` unset (it defaults to `academe_pro`).

1. **No key**: run a debug build without `REVENUECAT_GOOGLE_API_KEY`. Me shows the Pro card ("Go Pro"). Tap it: the paywall shows Pebby, the benefits, the Monthly and Annual tiles (Annual preselected, "Best value") with the fallback prices: Annual headline "₹1,999/year" with "About ₹167/month · save 17% · renews automatically" in small text only; Monthly "₹100 for the first month, then ₹200/month" and "Renews automatically". Continue shows "Purchases aren't available on this device" and nothing crashes. Restore purchases does the same. The small print "Renews automatically. Cancel anytime in Google Play." and the Terms and Privacy links are visible without clipping.
2. **Limit sheet after 10 ASKMe messages**: as a free student (server default `askme=10`), send 10 messages. The 11th fails: the failed bubble shows Go Pro and the limit sheet opens, saying the limit and that it comes back at midnight, with "Go Pro" and "Maybe later". Maybe later closes it; Go Pro opens the paywall. Tap "try again" on the last answer: it also shows the limit (retry now counts as a message). Check `/me/plan` shows `usedToday.askme` = 10.
3. **Scan limits**: read 3 scans, the 4th opens the limit sheet. Check my answer twice: the 2nd opens the sheet. Notes → Make a lesson: the Pro-only sheet, and "Just keep the notes" saves the notes.
4. **Pro card and Manage (server-side Pro)**: turn Pro on without a store by posting a webhook to the local server (`ACADEME_REVENUECAT_WEBHOOK_AUTH` set, event `INITIAL_PURCHASE`, `environment` `PRODUCTION`, `entitlement_ids` `["academe_pro"]`, the account UUID as `app_user_id`, `expiration_at_ms` 30 days ahead, `event_timestamp_ms` now in milliseconds). Pull to refresh or reopen Me: the Pro card reads Pro / "Manage". Manage shows "You're on Pro", the renew date, "Manage in Google Play" and "Restore purchases". Send an `EXPIRATION` event: the card goes back to "Go Pro" and ASKMe hits the limit again.
5. **Test Store purchase**: debug build only (a Test Store key in a release build crashes on purpose), with `--dart-define=REVENUECAT_GOOGLE_API_KEY=<REVENUE_CAT_SDK_KEY from .env>` and the server run with `ACADEME_REVENUECAT_SECRET_KEY=<REVENUE_CAT_API_KEY from .env>` and `ACADEME_BILLING_TESTERS=*` (Test Store purchases are sandbox). Sign up a fresh account, open the paywall: the tiles show the Test Store prices for Monthly and Annual only (no Lifetime). Pick Monthly → Continue → in the Test Store dialog choose the successful purchase. "Welcome to ACADEMe Pro" shows, the paywall closes, the Pro card reads Pro, and ASKMe works past 10. `/me/plan` shows plan pro, platform `test_store`. Then log out, log back in, open Manage → Restore purchases: Pro stays. Also try the failed-purchase and cancel options: failed shows an error notice, cancel is silent.
6. Screenshot the paywall (no key and Test Store prices), the limit sheet, Manage and the Pro card (Free and Pro) in light and dark at 1.0× and 1.3× font scale: nothing clipped, the annual caption fits.

## Reset links and the web reset page (from the emails tester)

Pixel 10, local server with `ACADEME_EMAIL_DEV=1` so the log prints the code and link. Details in `tasks/reports/emails-test.md`.

1. **App link, cold start**: force-stop the app. Sign up (or use) an email account, tap Forgot password on another device or `curl -XPOST http://localhost:8080/auth/password-reset -d '{"email":"..."}'`, and copy the `c=` value from the server log. Run `adb shell am start -a android.intent.action.VIEW -d 'academe://reset?c=<token>' com.academe.flutter`. The New password screen shows (not the splash, not Welcome). Type a new password and tap Save and log in: you land on Home. Log out and log in with the new password.
2. **App link, app running**: with the app open on Home, request another reset and run the same `adb` command. New password slides in on top. Press back: you return to where you were.
3. **Expired or used link**: run the `adb` command again with the token from step 1. Save shows the expired message with Start again; Start again opens Forgot password.
4. **Back from a cold-start link**: repeat step 1 with a fresh token, but press back on New password instead of saving. The splash plays and then Welcome (or Home when logged in) shows. The app does not close on the first back.
5. **Unknown links are ignored**: `adb shell am start -a android.intent.action.VIEW -d 'academe://open' com.academe.flutter` brings the app to the front without pushing a second splash. `academe://somethingelse` does not open the app (the intent filter only accepts the `reset` and `open` hosts).
6. **https link (unverified)**: `adb shell am start -a android.intent.action.VIEW -d 'https://academe.cc/reset-password?c=<token>'` offers the browser (App Links are not verified until `ACADEME_ANDROID_CERT_SHA256` is set and academe.cc serves `/.well-known/assetlinks.json`). With `adb shell pm set-app-links --package com.academe.flutter 1 academe.cc` followed by the same command, the app opens on New password.
7. **Web reset page in Chrome on the emulator** (needs a server built after the emails-test fix, which lets the reset cookie work over plain http on 10.0.2.2): request a reset, then open `http://10.0.2.2:8080/reset-password?c=<token>` in Chrome on the emulator. The themed page shows Pebby, "Choose a new password", two password fields and a purple Save new password button. Try mismatched passwords ("The two passwords don't match"), then save: "Password changed". Reload the same URL and save again: "This link has expired". Log in in the app with the new password. Tap "Open in the app" on a fresh link's page: the app opens on New password. Screenshot the form, the success and the expired pages in light and dark.
