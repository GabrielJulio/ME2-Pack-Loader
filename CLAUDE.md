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

## Commands

```sh
# Run on Linux
flutter run -d linux

# Build release
flutter build linux

# Analyze (lint)
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart
```

## Platform target

Currently Linux only — only the `linux/` directory is relevant. Windows support is planned for a later update; do not add other platform folders yet.
