# ME2 Pack Loader

A Flutter desktop GUI that manages ModEngine2 TOML configs for FromSoftware games. Acts as a Steam launch wrapper.

## Language

### Packs and files

**Pack** (a.k.a. **mod pack**):
A named ModEngine2 TOML config for a single game, stored as `<slug>.toml` in the game's base directory. A pack does not own mod folders — it references shared folders in the game directory by name and decides which are enabled and in what order.
_Avoid_: Profile, preset, configuration

**Active pack**:
The pack currently mirrored into `config.toml`. ModEngine2 always reads `config.toml`, so the active pack is what Steam launches. Only one pack is active at a time per game.
_Avoid_: Selected pack, current pack (those refer to UI focus, not launch target)

**`config.toml`**:
Reserved filename in each game base directory. Holds a copy of the active pack's contents. Rewritten whenever the user activates a different pack. Never appears in the packs list in the UI.
_Avoid_: Treating it as a regular pack

**Mod folder**:
A directory inside a game's base directory containing the actual mod files. Shared across all packs for that game. The folder name is its identity (referenced from packs as `path` / `name`).
_Avoid_: Mod, mod directory

### Locations

**Packs root**:
The single directory the user picks at onboarding, under which the app creates one subfolder per game. Each subfolder is that game's base directory.
_Avoid_: Mod root, base directory (use "base directory" only when scoped to a specific game)

**Game base directory**:
A subfolder of the packs root, dedicated to one game (`ds3/`, `er/`, `dsr/`). Holds that game's mod folders, packs, and `config.toml`.
_Avoid_: Game folder, game dir

**Bundled ModEngine2**:
A single ModEngine2 build (DSR-compatible fork, also runs DS3 and ER) that ships with the app. The user cannot point at their own ModEngine2 install. Ships as a **pre-cache** inside the AppImage / `.msi` and is extracted into `path_provider`'s app-support directory on first launch (and re-extracted when the pre-cache's version differs).
_Avoid_: User-supplied ModEngine2, external launcher

**Pre-cache**:
The ModEngine2 copy shipped inside the install package (AppImage bundle or MSI install dir). Read-only at runtime; the source for extraction into the writable support directory.

### Activation and games

**Game activation**:
A user action that creates the game's base directory and `default.toml` and adds the game to the active set. Games are activated on demand; the app never pre-creates folders for games the user hasn't asked for.
_Avoid_: Adding a game (use "activate")

**Activate (a pack)**:
Click action that copies the pack's contents into `config.toml`, making it the active pack for that game. Distinct from opening a pack for editing.
