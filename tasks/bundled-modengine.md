# Bundled ModEngine2

## Context

The user can't be expected to find and install the right ModEngine2 themselves, and DSR requires a fork of ModEngine2 that isn't on the upstream repo. We ship a single ModEngine2 build with the app — the DSR-compatible fork, which also runs DS3 and ER (decision confirmed in grilling).

## Goal

The app always knows where to find a working ModEngine2 launcher. The user never picks a folder for it; never even sees the term.

## Approach

### Source

- One ModEngine2 build: the DSR-compatible fork.
- Download URL: **TBD — user to supply.** Placeholder in fetch script.
- License: MIT, redistributable. Add `NOTICE.md` at repo root with attribution.

### Acquisition (build time)

`scripts/fetch_modengine2.sh`:
1. Reads pinned version + SHA256 + URL from `scripts/modengine2.lock` (a tiny key/value file).
2. Downloads to `vendor/modengine2.zip` (gitignored).
3. Verifies SHA256; aborts if mismatch.
4. Extracts to `vendor/modengine2/`.
5. Idempotent: if `vendor/modengine2/.version` matches the lock, skip.

CI / AppImage build runs this script before `flutter build linux`.

### Runtime location (always the ME2 folder)

The ME2 binary lives at `<app folder>/modengine2/`, fixed regardless of data dir choice (see [Data Directory Management](./done/data-dir-management.md)):
- Linux: `~/.local/share/me2_pack_loader/modengine2/`
- Windows: `%APPDATA%\me2_pack_loader\modengine2\`

Per ADR-0001, the app folder is resolved via `path_provider`'s `getApplicationSupportDirectory()`.

### Population per platform

Both packaged platforms ship a **pre-cache** of ME2 inside the install/bundle. The app checks the support dir on every launch; if `modengine2_launcher.exe` is missing or the version file doesn't match the pre-cache, it extracts from the pre-cache.

| Platform | Pre-cache location | Resolved by |
|---|---|---|
| Linux (AppImage) | `AppDir/usr/share/modengine2/` (lives at `$APPDIR/usr/share/modengine2/` once mounted) | `Platform.environment['APPDIR']` |
| Windows (`.msi`) | `<install_dir>\modengine2\` (e.g. `C:\Program Files\me2_pack_loader\modengine2\`) | `Platform.resolvedExecutable`'s parent dir |
| Dev (`flutter run`) | `<repo>/vendor/modengine2/` | env-var `ME2_BUNDLE_DIR=<repo>/vendor/modengine2` |

Same extraction logic on Linux and Windows: read pre-cache → write to support dir → record version. Idempotent.

### Service

`lib/services/modengine_locator.dart`:
- `Future<Directory> resolve()`:
  1. Compute ME2 folder path (`<app folder>/modengine2/`).
  2. If `launcher.exe` present and `.version` matches pre-cache `.version` → return.
  3. Else locate pre-cache (`ME2_BUNDLE_DIR` env > `APPDIR/usr/share/modengine2` on Linux > install-dir on Windows).
  4. Extract pre-cache → ME2 folder. Write `.version`.
  5. Return ME2 folder path.
- `Future<File> launcherExe()` → returns absolute path to `modengine2_launcher.exe`.
- Caches the resolved path for the session.

## Files

- `vendor/modengine2.zip` — gitignored, fetched at build
- `vendor/modengine2/` — gitignored, extracted
- `scripts/fetch_modengine2.sh` — new
- `scripts/modengine2.lock` — new (URL, version, SHA256)
- `scripts/build_appimage.sh` — invoke fetch script; copy `vendor/modengine2/` into `AppDir/usr/share/modengine2/`
- `lib/services/modengine_locator.dart` — new
- `pubspec.yaml` — add `path_provider`
- `NOTICE.md` — new (ME2 fork attribution + license)
- `.gitignore` — add `vendor/`

## Verification

1. `bash scripts/fetch_modengine2.sh` → downloads, extracts, no errors on re-run.
2. `flutter run -d linux` with `ME2_BUNDLE_DIR=<repo>/vendor/modengine2` → `ModEngineLocator` extracts to support dir and returns the launcher path.
3. AppImage built and opened on a clean machine → ME2 extracted to the ME2 folder (`~/.local/share/me2_pack_loader/modengine2/`), launcher exe present.
4. Re-launch → version files match → no re-extraction.
5. Bump pre-cache version (simulate update) → re-extraction triggered, support dir refreshed.
6. (When Windows MSI lands) Install → first launch extracts from `<install_dir>\modengine2\` to the ME2 folder (`%APPDATA%\me2_pack_loader\modengine2\`).
