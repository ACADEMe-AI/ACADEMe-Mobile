#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
pages="$root/server/internal/site/pages"
if grep -rn 'FILL:' "$pages" 2>/dev/null; then
  echo "Legal placeholders remain in site pages (see docs/play/legal-entity.md)." >&2
  exit 1
fi
echo "No FILL: placeholders in site pages."
