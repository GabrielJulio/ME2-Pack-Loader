# ME2-Pack-Loader

> **Work in progress.**

A Flutter desktop GUI for managing [ModEngine2](https://github.com/soulsmods/ModEngine2) mod packs for FromSoftware games. Acts as a Steam wrapper — when launched through Steam, it lets you enable/disable mods, reorder them, and configure ModEngine2 settings, all without manually editing TOML files.

> For contributors / AI agents — start with [AGENTS.md](./AGENTS.md).

## Games supported

| Game | Status |
|---|---|
| Dark Souls III | ✅ |
| Elden Ring | ✅ |
| Dark Souls: Remastered | 🚧 Planned |

## Features

- Mod folder management — add, rename, delete
- Enable, disable, and reorder mods (load order matters)
- External DLL management (e.g. SeamlessCoop)
- ModEngine2 settings toggles (loose params, debug mode, Scylla Hide)
- Material and GNOME themes
- Runs on Linux (Bazzite / Steam Deck / any distro with Proton)

## Roadmap

Decisions that shape the plans are recorded in [`docs/adr/`](./docs/adr/) and project terminology in [`CONTEXT.md`](./CONTEXT.md).

### WIP

Plans drafted and ready to execute. Each file is self-contained (Context / Goal / Approach / Files / Verification).

| Objective | Plan |
|---|---|
| Bundle ModEngine2 (no user-supplied install) | [tasks/01](./tasks/01-bundled-modengine.md) |
| Translations (English + Brazilian Portuguese) | [tasks/02](./tasks/02-translations.md) |
| Data directory management (default vs. custom disk) | [tasks/03](./tasks/03-data-dir-management.md) |
| Multi-game support (Dark Souls III, Elden Ring, Dark Souls: Remastered) | [tasks/04](./tasks/04-multi-game-support.md) |
| Mod packs (named TOMLs per game, activate flow) | [tasks/05](./tasks/05-mod-packs.md) |
| Material red accent | [tasks/06](./tasks/06-material-red-accent.md) |
| Desktop-aware theme (auto-detect GNOME accent) | [tasks/07](./tasks/07-desktop-aware-theme.md) |
| Steam launch command (copy-paste with instructions) | [tasks/08](./tasks/08-steam-launch-command.md) |

### Planned

Future objectives without an implementation plan yet.

- Support Windows (`.msi` installer)
- AppImage with auto-updates via GitHub releases

## Known Bugs

- **Window title bar not themed** — the native GTK title bar (minimize, maximize, close buttons) does not fully pick up the app's color scheme on all desktop environments.

## How it works

Each game has a **base directory** containing its mod folders and one or more **packs** (named TOML configs). A pack selects which mods are enabled and in what order. Activating a pack mirrors it into the game's `config.toml` — that's the file ModEngine2 actually reads, so the Steam launch command stays the same regardless of which pack is active.

## Requirements

- Flutter (for building from source)
- Linux (Bazzite / Steam Deck / any distro with Proton) — Windows support coming later

ModEngine2 itself is bundled with the app, so you don't need to install it separately (see [tasks/01](./tasks/01-bundled-modengine.md)).

## Legal

This is an unofficial, community-made tool. It is not affiliated with, endorsed by, or associated with FromSoftware, Inc., Bandai Namco Entertainment, or the ModEngine2 team.

*Dark Souls III* and *Elden Ring* are registered trademarks of FromSoftware, Inc. / Bandai Namco Entertainment Inc. All rights reserved.

> **Online play warning:** Using mods while connected to online services can trigger Easy Anti-Cheat and result in a **permanent ban**. Always launch the game in offline mode when using mods. The authors of this tool take no responsibility for bans, corrupted saves, or any game instability caused by the use of mods.

This application does not include, distribute, or extract any game files or assets. It only manages configuration files for ModEngine2, which must be obtained separately by the user.

The authors are not liable for any damage to your game installation, save files, or online account status resulting from the use of this tool or any mods loaded through it.

ModEngine2 is developed by the [soulsmods](https://github.com/soulsmods/ModEngine2) team and is licensed under the MIT License.

## License

MIT
