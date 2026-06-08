# ME2-Pack-Loader

> **Work in progress.**

A Flutter desktop GUI for managing [ModEngine2](https://github.com/soulsmods/ModEngine2) mod packs for FromSoftware games. Acts as a Steam wrapper — when launched through Steam, it lets you enable/disable mods, reorder them, and configure ModEngine2 settings, all without manually editing TOML files.

> Read in [Português (Brasil)](./README.pt-BR.md).

> For contributors / AI agents — start with [AGENTS.md](./AGENTS.md).

## Games supported

| Game | Status |
|---|---|
| Dark Souls III | 🚧 Service layer ready, UI not wired |
| Elden Ring | 🚧 Service layer ready, UI not wired |
| Dark Souls: Remastered | 🚧 Service layer ready, UI not wired |

## Features the user can interact with today

- Mod folder management — add, rename, delete
- Enable, disable, and reorder mods (load order matters)
- External DLL management (e.g. SeamlessCoop)
- ModEngine2 settings toggles (loose params, debug mode, Scylla Hide)
- Material and GNOME themes (auto-detected at startup)
- Switch UI language between English and Brazilian Portuguese
- Runs on Linux (Bazzite / Steam Deck / any distro with Proton)

> **Important note about scope.** Multi-game switching, named mod packs, the new Steam wrapper, and the new data-dir picker are all built at the service + bloc + test layer but not yet exposed in the UI — see the "UI integration batch" in the [tasks/](./tasks/) folder. The bar for moving anything into the user-facing feature list above is "the user can use it end-to-end."

## Roadmap

Decisions that shape the plans are recorded in [`docs/adr/`](./docs/adr/), project terminology in [`CONTEXT.md`](./CONTEXT.md), and autonomous mid-execution calls in [`refactor.md`](./refactor.md).

[`tasks/README.md`](./tasks/README.md) is the source of truth for execution order. Highlights:

### Foundation (external blocker)

- [Bundled ModEngine2](./tasks/bundled-modengine.md) — waiting on the upstream ModEngine2 fork URL.

### UI integration batch (in dependency order)

1. [New Onboarding + Startup Routing](./tasks/new-onboarding-and-startup-routing.md)
2. [Multi-Game Activation Flow](./tasks/multi-game-activation-flow.md)
3. [Pack List + Management UI](./tasks/pack-list-and-management.md)
4. [Run Modes + Steam Wrapper](./tasks/run-modes-and-steam-wrapper.md)
5. [Per-Pack Auto-Launch](./tasks/per-pack-auto-launch.md)

Independent side-branches (parallelizable after #1):

- [Missing Data-Dir Recovery](./tasks/missing-data-dir-recovery.md)
- [App Preferences Screen](./tasks/app-preferences-screen.md)

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

ModEngine2 itself is bundled with the app, so you don't need to install it separately (see [Bundled ModEngine2](./tasks/bundled-modengine.md)).

## Legal

This is an unofficial, community-made tool. It is not affiliated with, endorsed by, or associated with FromSoftware, Inc., Bandai Namco Entertainment, or the ModEngine2 team.

*Dark Souls III* and *Elden Ring* are registered trademarks of FromSoftware, Inc. / Bandai Namco Entertainment Inc. All rights reserved.

> **Online play warning:** Using mods while connected to online services can trigger Easy Anti-Cheat and result in a **permanent ban**. Always launch the game in offline mode when using mods. The authors of this tool take no responsibility for bans, corrupted saves, or any game instability caused by the use of mods.

This application does not include, distribute, or extract any game files or assets. It only manages configuration files for ModEngine2, which must be obtained separately by the user.

The authors are not liable for any damage to your game installation, save files, or online account status resulting from the use of this tool or any mods loaded through it.

ModEngine2 is developed by the [soulsmods](https://github.com/soulsmods/ModEngine2) team and is licensed under the MIT License.

## License

MIT
