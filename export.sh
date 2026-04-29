#!/usr/bin/env bash
# Render Example.html to a vector PDF at exactly 48" × 36" landscape.
# Uses headless Chrome's print-to-pdf, which preserves vector text and keeps
# file size small (typically 1-3 MB vs. 15 MB from the in-page html2canvas path).

set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
SRC="$DIR/Example.html"
OUT="${1:-$DIR/ASIO-poster.pdf}"

CHROME_CANDIDATES=(
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
  "/Applications/Chromium.app/Contents/MacOS/Chromium"
  "/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
)

CHROME=""
for c in "${CHROME_CANDIDATES[@]}"; do
  if [[ -x "$c" ]]; then CHROME="$c"; break; fi
done

if [[ -z "$CHROME" ]]; then
  echo "error: could not find Chrome/Chromium/Brave/Edge. Install one or edit CHROME_CANDIDATES." >&2
  exit 1
fi

if [[ ! -f "$SRC" ]]; then
  echo "error: $SRC not found" >&2
  exit 1
fi

echo "rendering: $SRC"
echo "chrome:   $CHROME"
echo "output:   $OUT"

"$CHROME" \
  --headless=new \
  --disable-gpu \
  --no-sandbox \
  --hide-scrollbars \
  --virtual-time-budget=30000 \
  --run-all-compositor-stages-before-draw \
  --print-to-pdf-no-header \
  --no-pdf-header-footer \
  --default-background-color=00000000 \
  --print-to-pdf="$OUT" \
  "file://$SRC"

echo
echo "done. PDF written to: $OUT"

if command -v pdfinfo >/dev/null 2>&1; then
  echo
  pdfinfo "$OUT" | grep -E '^(Pages|Page size|File size):' || true
fi
