#!/usr/bin/env bash
set -euo pipefail

APPNAME="ME2-Pack-Loader"
BINARY="me2_pack_loader"
APPDIR="AppDir"
ICON="packaging/${BINARY}.png"

echo "→ Building Flutter release..."
flutter build linux --release

echo "→ Setting up AppDir..."
rm -rf "$APPDIR"
mkdir -p \
  "$APPDIR/usr/bin" \
  "$APPDIR/usr/lib" \
  "$APPDIR/usr/share/icons/hicolor/256x256/apps"

cp -r build/linux/x64/release/bundle/. "$APPDIR/usr/"

mv "$APPDIR/usr/$BINARY" "$APPDIR/usr/bin/$BINARY"

cp "packaging/${BINARY}.desktop" "$APPDIR/"

if [[ -f "$ICON" ]]; then
  cp "$ICON" "$APPDIR/usr/share/icons/hicolor/256x256/apps/${BINARY}.png"
  ln -sf "usr/share/icons/hicolor/256x256/apps/${BINARY}.png" "$APPDIR/${BINARY}.png"
else
  echo "⚠ Icon not found at $ICON — AppImage will have no icon."
  echo "  Add a 256×256 PNG at that path and re-run this script."
fi

ln -sf "usr/bin/$BINARY" "$APPDIR/AppRun"

APPIMAGETOOL="$(command -v appimagetool 2>/dev/null || true)"
if [[ -z "$APPIMAGETOOL" ]]; then
  echo "→ Downloading appimagetool..."
  APPIMAGETOOL="/tmp/appimagetool"
  wget -q \
    "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage" \
    -O "$APPIMAGETOOL"
  chmod +x "$APPIMAGETOOL"
fi

echo "→ Packaging AppImage..."
ARCH=x86_64 "$APPIMAGETOOL" "$APPDIR" "${APPNAME}.AppImage"
echo "✓ ${APPNAME}.AppImage created"
