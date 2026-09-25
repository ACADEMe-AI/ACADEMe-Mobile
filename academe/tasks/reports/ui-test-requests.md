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
