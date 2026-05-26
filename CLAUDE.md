# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

ME2-Pack-Loader is a Flutter desktop GUI for managing [ModEngine2](https://github.com/soulsmods/ModEngine2) mod packs for FromSoftware games. It reads and writes ModEngine2 TOML config files to enable/disable mods and external DLLs without manually editing them.

- **Current scope:** Dark Souls 3, Linux only
- **Planned:** Elden Ring support, Windows support
- **Bundle ID:** `br.eti.gabrieljuliobs.me2_pack_loader`

### ModEngine2 layout (reference, not shipped with the app)

```
/mnt/storage/launchers/mod_engine_2/
  config_darksouls3.toml      # TOML config the app manages
  modengine2_launcher.exe
  modengine2/
  mod/                        # default mod pack directory
  texture/                    # texture mod pack directory
  SeamlessCoop/               # external DLL pack
```

### TOML config structure

```toml
[modengine]
debug = false
external_dlls = ["SeamlessCoop/ds3sc.dll"]

[extension.mod_loader]
enabled = true
loose_params = false
mods = [
    { enabled = true, name = "default", path = "mod" },
    { enabled = true, name = "texture", path = "texture" }
]

[extension.scylla_hide]
enabled = false
```

The app manages this file: toggling `enabled` on mods, adding/removing entries in `mods` and `external_dlls`, and toggling top-level extension flags.

## Architecture

```
lib/
  main.dart / app.dart          # entry point, MaterialApp (dark theme forced)
  models/                       # Mod, GameConfig, LayoutType
  services/                     # ConfigService (TOML), ModService (fs), PreferencesService
  bloc/config/                  # ConfigBloc — all TOML mutations, writes on every event
  bloc/setup/                   # SetupBloc — first-run folder selection
  bloc/layout/                  # LayoutBloc — persisted layout preference
  screens/                      # OnboardingScreen, HomeScreen, SteamSetupScreen
  widgets/                      # ModList, GnomeLayout, SettingsPanel, ExternalDllList, dialogs
  utils/slugify.dart
```

**Layout switching:** `HomeScreen` provides both `ConfigBloc` and `LayoutBloc`. A `PopupMenuButton` in the AppBar dispatches `LayoutSelected`; the body switches between `_DefaultLayout` (sidebar + main) and `GnomeLayout` (NavigationRail + pages). The choice is persisted via `PreferencesService`.

**TOML writes:** Every `ConfigBloc` mutation calls `ConfigService.write` before emitting the new state — the file is always in sync with the UI.

**Dev override:** Set `MODENGINE_DIR` env var to point at a real ModEngine2 folder while running with `flutter run`.

## Commands

```sh
# Run on Linux
flutter run -d linux

# Run against a real ModEngine2 folder
MODENGINE_DIR=/mnt/storage/launchers/mod_engine_2 flutter run -d linux

# Build release
flutter build linux

# Build AppImage (requires packaging/me2_pack_loader.png icon)
bash scripts/build_appimage.sh

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart
```

## AppImage packaging

- Script: `scripts/build_appimage.sh` (auto-downloads `appimagetool` if not on PATH)
- Desktop entry: `packaging/me2_pack_loader.desktop`
- **Icon required:** add a 256×256 PNG at `packaging/me2_pack_loader.png` before running the script

## Platform target

Currently Linux only — only the `linux/` directory is relevant. Windows support is planned for a later update; do not add other platform folders yet.
