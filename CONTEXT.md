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

**App folder**:
The fixed-location, app-managed directory at `~/.local/share/me2_pack_loader/` (Linux) or `%APPDATA%\me2_pack_loader\` (Windows). Holds the bundled ModEngine2, the pointer config, and other internal state. Never moves.
_Avoid_: AppData, support dir (those are platform-specific implementations)

**ME2 folder**:
`<app folder>/modengine2/`. Contains the extracted ModEngine2 binary (launcher exe + its own DLLs) and, when the data dir is the default, the per-game subfolders directly underneath it.
_Avoid_: Mod engine dir

**Data dir**:
The directory under which game folders live. Defaults to `<ME2 folder>` itself (so game folders nest inside the ME2 folder); the user can override to any folder on any disk, in which case games live at `<data dir>/me2_pack_loader/modengine2/<game>/`. Mobile — can be moved later from settings, with a disk-space check. The chosen path is stored in the pointer config.
_Avoid_: Packs root, mods root

**Game folder** (a.k.a. game base directory):
The folder dedicated to one game, holding its mod folders, packs, and `config.toml`. Lives at `<data dir>/me2_pack_loader/modengine2/<game.slug>/` (or `<ME2 folder>/<game.slug>/` in the default-data-dir case).
_Avoid_: Game dir, base dir

**Pointer config**:
A small JSON file in the app folder recording where the data dir currently lives. On launch, the app reads this; if the path is unreachable (disk removed), it prompts the user to relocate.

**Bundled ModEngine2**:
A single ModEngine2 build (DSR-compatible fork, also runs DS3 and ER) that ships with the app. The user cannot point at their own ModEngine2 install. Ships as a **pre-cache** inside the AppImage / `.msi` and is extracted into the ME2 folder on first launch (and re-extracted when the pre-cache's version differs).
_Avoid_: User-supplied ModEngine2, external launcher

**Pre-cache**:
The ModEngine2 copy shipped inside the install package (AppImage bundle or MSI install dir). Read-only at runtime; the source for extraction into the ME2 folder.

### Activation and games

**Game activation**:
A user action that creates the game's base directory and `default.toml` and adds the game to the active set. Games are activated on demand; the app never pre-creates folders for games the user hasn't asked for.
_Avoid_: Adding a game (use "activate")

**Activate (a pack)**:
Click action that copies the pack's contents into `config.toml`, making it the active pack for that game. Distinct from opening a pack for editing.
