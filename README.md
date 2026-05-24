# ME2-Pack-Loader

> **Work in progress.**

A Flutter desktop GUI for managing [ModEngine2](https://github.com/soulsmods/ModEngine2) mod packs for FromSoftware games. Acts as a Steam wrapper — when launched through Steam, it lets you enable/disable mods, reorder them, and configure ModEngine2 settings, all without manually editing TOML files.

## Major Objectives

| Objective | Status |
|---|---|
| Support Dark Souls 3 | 🚧 In progress |
| Support Elden Ring | ⬜ Planned |
| Support Bazzite (Linux) | 🚧 In progress |
| Support Windows | ⬜ Planned |
| Multiple UI layouts | ⬜ Planned |
| AppImage with auto-updates via GitHub releases | ⬜ Planned |

## How it works

ME2-Pack-Loader reads and writes the ModEngine2 TOML config file (`dark_souls_3.toml`). Each mod is a folder inside the ModEngine2 directory. The app lets you:

- Add, rename, and delete mod folders
- Enable or disable individual mods
- Reorder mods (load order matters)
- Manage external DLLs (e.g. SeamlessCoop)
- Toggle ModEngine2 settings (loose params, debug mode, etc.)

## Requirements

- [ModEngine2](https://github.com/soulsmods/ModEngine2)
- Flutter (for building from source)
- Linux (Bazzite / Steam Deck / any distro with Proton) — Windows support coming later

## Legal

This is an unofficial, community-made tool. It is not affiliated with, endorsed by, or associated with FromSoftware, Inc., Bandai Namco Entertainment, or the ModEngine2 team.

*Dark Souls III* and *Elden Ring* are registered trademarks of FromSoftware, Inc. / Bandai Namco Entertainment Inc. All rights reserved.

> **Online play warning:** Using mods while connected to online services can trigger Easy Anti-Cheat and result in a **permanent ban**. Always launch the game in offline mode when using mods. The authors of this tool take no responsibility for bans, corrupted saves, or any game instability caused by the use of mods.

This application does not include, distribute, or extract any game files or assets. It only manages configuration files for ModEngine2, which must be obtained separately by the user.

The authors are not liable for any damage to your game installation, save files, or online account status resulting from the use of this tool or any mods loaded through it.

ModEngine2 is developed by the [soulsmods](https://github.com/soulsmods/ModEngine2) team and is licensed under the MIT License.

## License

MIT
