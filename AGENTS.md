# AGENTS.md

Single source of truth for project guidance directed at AI agents and contributors. Tool-specific files (`CLAUDE.md`, `.cursor/`, etc.) point here.

## Project

ME2-Pack-Loader is a Flutter desktop GUI for managing [ModEngine2](https://github.com/soulsmods/ModEngine2) mod packs for FromSoftware games. It reads and writes ModEngine2 TOML config files so users can manage mods without editing TOMLs by hand.

- **Bundle ID:** `br.eti.gabrieljuliobs.me2_pack_loader`
- **Current scope:** Dark Souls III on Linux
- **Planned:** Elden Ring, Dark Souls: Remastered, Windows support — see [tasks/](./tasks/) and [README](./README.md)

## Where to look

| Concern | File |
|---|---|
| Domain language / glossary | [CONTEXT.md](./CONTEXT.md) |
| Architectural decisions | [docs/adr/](./docs/adr/) |
| Forward-looking task plans | [tasks/](./tasks/) |
| Completed task plans (archive) | [tasks/done/](./tasks/done/) |

## Naming and language

- **Game names in user-facing text** (UI strings, README, error messages, dialogs) — always use the **full name**: "Dark Souls III", "Elden Ring", "Dark Souls: Remastered". Never use abbreviations like `DS3`, `ER`, `DSR` in anything the end user can see.
- Abbreviations are fine in code identifiers, file/folder slugs, dev docs (tasks, ADRs, CONTEXT.md), and comments.
- Follow [CONTEXT.md](./CONTEXT.md) for canonical domain terms (Pack, Active pack, Game folder, Data dir, etc.). When code or text uses a term that conflicts with the glossary, the glossary wins.
- **User-facing strings live in ARB files**, not as hardcoded literals. Once [tasks/02](./tasks/02-translations.md) lands, every string the user sees comes from `lib/l10n/app_en.arb` + `lib/l10n/app_pt.arb`, accessed via `AppLocalizations.of(context)`. Any new user-facing text added by later tasks must extend both files in lockstep.

## Platform abstraction

Per [ADR-0001](./docs/adr/0001-platform-abstraction-order.md): for anything platform-specific, prefer **Flutter/Dart cross-platform API → pub package → native command/subprocess**, in that order. Always guard with `Platform.isLinux` / `Platform.isWindows`; return a sentinel value on the unsupported platform rather than erroring.

## TOML config structure (reference)

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

The app manages this file: toggling `enabled` on mods, adding/removing entries in `mods` and `external_dlls`, and toggling top-level extension flags. Per [ADR-0002](./docs/adr/0002-config-toml-as-launch-mirror.md), `config.toml` is the launch mirror — the active pack is copied into it.

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

**Layout switching:** `HomeScreen` provides both `ConfigBloc` and `LayoutBloc`. A `PopupMenuButton` in the AppBar dispatches `LayoutSelected`; the body switches between `_DefaultLayout` (sidebar + main) and `GnomeLayout` (NavigationRail + pages). The choice is persisted via `PreferencesService`. (The user-visible switcher will be removed in [tasks/07](./tasks/07-desktop-aware-theme.md); the layouts themselves stay.)

**TOML writes:** Every `ConfigBloc` mutation calls `ConfigService.write` before emitting the new state — the file is always in sync with the UI.

**Dev override:** Set `MODENGINE_DIR` env var to point at a real ModEngine2 folder while running with `flutter run`. (Will be replaced by `ME2_BUNDLE_DIR` per [tasks/01](./tasks/01-bundled-modengine.md).)

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
- Icon: `packaging/me2_pack_loader.png` (256×256)

## Platform target

Currently Linux only — only the `linux/` directory is relevant. Windows support is planned for a later update; do not add other platform folders yet.
