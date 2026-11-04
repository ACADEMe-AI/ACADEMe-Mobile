#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"

: "${GOOGLE_SERVER_CLIENT_ID:?Export GOOGLE_SERVER_CLIENT_ID (web OAuth client ID)}"
: "${REVENUECAT_GOOGLE_API_KEY:?Export REVENUECAT_GOOGLE_API_KEY (public goog_… key, not test_)}"

if [[ "$REVENUECAT_GOOGLE_API_KEY" == test_* ]]; then
  echo "REVENUECAT_GOOGLE_API_KEY must be the Play public key (goog_…), not Test Store (test_…)" >&2
  exit 1
fi

flutter build appbundle --release \
  --dart-define=GOOGLE_SERVER_CLIENT_ID="$GOOGLE_SERVER_CLIENT_ID" \
  --dart-define=REVENUECAT_GOOGLE_API_KEY="$REVENUECAT_GOOGLE_API_KEY"

aab="$root/build/app/outputs/bundle/release/app-release.aab"
if ! strings "$aab" | grep -q 'https://api.academe.cc'; then
  echo "api.academe.cc not found in bundle (release API_BASE_URL check)" >&2
  exit 1
fi
if strings "$aab" | grep -q 'test_'; then
  echo "test_ RevenueCat key material found in bundle" >&2
  exit 1
fi
echo "Built $aab with GOOGLE_SERVER_CLIENT_ID and REVENUECAT_GOOGLE_API_KEY dart-defines."
