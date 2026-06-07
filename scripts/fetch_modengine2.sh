#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
LOCK_FILE="$REPO_ROOT/scripts/modengine2.lock"
VENDOR_DIR="$REPO_ROOT/vendor/modengine2"
ZIP_PATH="$REPO_ROOT/vendor/modengine2.zip"
VERSION_FILE="$VENDOR_DIR/.version"

if [[ ! -f "$LOCK_FILE" ]]; then
  echo "✗ Lock file not found: $LOCK_FILE" >&2
  exit 1
fi

URL="$(grep -E '^URL=' "$LOCK_FILE" | cut -d= -f2-)"
VERSION="$(grep -E '^VERSION=' "$LOCK_FILE" | cut -d= -f2-)"
SHA256="$(grep -E '^SHA256=' "$LOCK_FILE" | cut -d= -f2-)"

if [[ "$URL" == "TBD" || "$VERSION" == "TBD" || "$SHA256" == "TBD" ]]; then
  echo "✗ scripts/modengine2.lock still has TBD placeholders." >&2
  echo "  Fill in URL, VERSION, and SHA256 for the ModEngine2 build." >&2
  exit 1
fi

if [[ -f "$VERSION_FILE" ]] && [[ "$(cat "$VERSION_FILE")" == "$VERSION" ]]; then
  echo "✓ ModEngine2 $VERSION already cached at $VENDOR_DIR"
  exit 0
fi

mkdir -p "$REPO_ROOT/vendor"
echo "→ Downloading ModEngine2 $VERSION..."
wget -q "$URL" -O "$ZIP_PATH"

echo "→ Verifying SHA256..."
ACTUAL="$(sha256sum "$ZIP_PATH" | awk '{print $1}')"
if [[ "$ACTUAL" != "$SHA256" ]]; then
  echo "✗ SHA256 mismatch." >&2
  echo "  expected: $SHA256" >&2
  echo "  got:      $ACTUAL" >&2
  rm -f "$ZIP_PATH"
  exit 1
fi

echo "→ Extracting..."
rm -rf "$VENDOR_DIR"
mkdir -p "$VENDOR_DIR"
unzip -q "$ZIP_PATH" -d "$VENDOR_DIR"
echo "$VERSION" > "$VERSION_FILE"

echo "✓ ModEngine2 $VERSION ready at $VENDOR_DIR"
