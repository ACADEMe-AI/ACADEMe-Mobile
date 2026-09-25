#!/usr/bin/env bash
set -uo pipefail

cd "$(dirname "$0")/.."
device="${UI_TEST_DEVICE:-emulator-5554}"
out="build/ui-test"
adb=(adb -s "$device")
defines=()
[ -n "${API_BASE_URL:-}" ] && defines+=(--dart-define="API_BASE_URL=$API_BASE_URL")

journeys=("$@")
if [ ${#journeys[@]} -eq 0 ]; then
  for f in integration_test/*_test.dart; do journeys+=("$(basename "$f" _test.dart)"); done
fi

wake() {
  "${adb[@]}" shell svc power stayon true >/dev/null
  "${adb[@]}" shell input keyevent KEYCODE_WAKEUP >/dev/null
  "${adb[@]}" shell wm dismiss-keyguard >/dev/null
}
wake
"${adb[@]}" shell settings put system screen_off_timeout 1800000 >/dev/null

record_pid=""
start_recording() {
  local journey=$1
  "${adb[@]}" shell rm -f "/sdcard/uitest-$journey-*.mp4" >/dev/null
  (
    part=0
    while true; do
      part=$((part + 1))
      "${adb[@]}" shell screenrecord --bit-rate 4000000 --time-limit 170 "/sdcard/uitest-$journey-$part.mp4" || break
    done
  ) &
  record_pid=$!
}

stop_recording() {
  local journey=$1
  [ -z "$record_pid" ] && return
  kill "$record_pid" 2>/dev/null
  "${adb[@]}" shell pkill -INT screenrecord >/dev/null 2>&1
  sleep 2
  for f in $("${adb[@]}" shell ls "/sdcard/uitest-$journey-*.mp4" 2>/dev/null | tr -d '\r'); do
    "${adb[@]}" pull "$f" "$out/$journey/" >/dev/null 2>&1
    "${adb[@]}" shell rm -f "$f" >/dev/null
  done
  record_pid=""
}

tap_node() {
  local pattern=$1 tries=${2:-20}
  for _ in $(seq "$tries"); do
    "${adb[@]}" shell uiautomator dump /sdcard/uitest-ui.xml >/dev/null 2>&1
    local xml bounds
    xml=$("${adb[@]}" shell cat /sdcard/uitest-ui.xml 2>/dev/null)
    bounds=$(printf '%s' "$xml" | tr '>' '\n' | grep -E "$pattern" | head -1 | sed -nE 's/.*bounds="\[([0-9]+),([0-9]+)\]\[([0-9]+),([0-9]+)\]".*/\1 \2 \3 \4/p')
    if [ -n "$bounds" ]; then
      read -r x1 y1 x2 y2 <<<"$bounds"
      "${adb[@]}" shell input tap $(((x1 + x2) / 2)) $(((y1 + y2) / 2))
      return 0
    fi
    sleep 1
  done
  echo "ui_test: no node matching $pattern" >&2
  return 1
}

push_image() {
  local file=$1
  "${adb[@]}" shell rm -f /sdcard/Pictures/uitest-*.png >/dev/null
  "${adb[@]}" push "integration_test/assets/$file" "/sdcard/Pictures/uitest-$file" >/dev/null
  "${adb[@]}" shell content call --method scan_volume --uri content://media --arg external_primary >/dev/null 2>&1
  "${adb[@]}" shell am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file:///sdcard/Pictures/uitest-$file" >/dev/null 2>&1
}

handle() {
  local journey=$1 command=$2 arg=${3:-}
  case "$command" in
    start) wake; start_recording "$journey" ;;
    shot) "${adb[@]}" shell dumpsys power | grep -q "mWakefulness=Awake" || wake
      "${adb[@]}" exec-out screencap -p >"$out/$journey/$(date +%H%M%S)-$arg.png" ;;
    push) push_image "$arg" ;;
    pick-photo) tap_node 'content-desc="(Photo|Image)[^"]*"|resource-id="[^"]*icon_thumbnail"' 30 ;;
    allow) tap_node 'text="Allow"|resource-id="com.android.permissioncontroller:id/permission_allow_button"' 15 ;;
    deny) tap_node "text=\"Don.t allow\"|resource-id=\"com.android.permissioncontroller:id/permission_deny_button\"" 15 ;;
    back) "${adb[@]}" shell input keyevent KEYCODE_BACK ;;
    grant-notifications) "${adb[@]}" shell pm grant com.academe.flutter android.permission.POST_NOTIFICATIONS ;;
  esac
}

summary=()
started=$(date +%s)
for journey in "${journeys[@]}"; do
  rm -rf "${out:?}/$journey"
  mkdir -p "$out/$journey"
  began=$(date +%s)
  case "$journey" in
    notifications*)
      "${adb[@]}" shell pm revoke com.academe.flutter android.permission.POST_NOTIFICATIONS >/dev/null 2>&1
      "${adb[@]}" shell pm clear-permission-flags com.academe.flutter android.permission.POST_NOTIFICATIONS user-set user-fixed >/dev/null 2>&1
      ;;
  esac
  while IFS= read -r line; do
    printf '%s\n' "$line"
    if [[ "$line" =~ UITEST\ ([a-z-]+)\ ?(.*)$ ]]; then
      handle "$journey" "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}" </dev/null
    fi
  done < <(flutter test "integration_test/${journey}_test.dart" -d "$device" ${defines[@]+"${defines[@]}"} 2>&1 | tee "$out/$journey/log.txt")
  stop_recording "$journey"
  result=PASS
  grep -q "All tests passed" "$out/$journey/log.txt" || result=FAIL
  summary+=("$result $journey $(($(date +%s) - began))s")
done

printf '\n'
printf '%s\n' "${summary[@]}" | tee "$out/summary.txt"
echo "total $(($(date +%s) - started))s" | tee -a "$out/summary.txt"
! grep -q '^FAIL' "$out/summary.txt"
