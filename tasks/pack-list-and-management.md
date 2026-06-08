# Pack List + Management UI

## Context

`PackService`, the `Pack` model, and `GameFolderInitializer` are tested and ready. `ConfigBloc` was reworked to load the most-recently-modified pack for the current game and to mirror writes to `config.toml`. What's still missing is the **user-visible pack surface**: today the user has no way to see, create, rename, delete, or switch between packs from the app.

This task implements the two-pane layout (`refactor.md` D13): pack list in the sidebar, mod editor in the main panel. It also extends `ConfigBloc` with the events needed for pack CRUD and the click-to-activate / edit-without-activating distinction.

## Goal

The user can manage packs from the UI for whichever game is currently selected:
- See all packs for the current game in the sidebar, with an Active badge on the one mirrored to `config.toml`.
- **Click a pack row to activate it.** Active pack mirror updates immediately.
- **Click the edit (pencil) icon to open the pack in the mod editor without changing the active pack.**
- Create a new pack, rename it, delete it.
- Edits to the editing pack always write to `<slug>.toml`; if that pack is also the active pack, the same edit cascades to `config.toml`.

## Approach

### Bloc state shape

`ConfigState.ConfigLoaded` gains:
- `List<Pack> packs` — ordered as `PackService.list` returns them (mtime desc).
- `String editingPackSlug` — which pack is loaded into the editor.
- `String? activePackSlug` — which pack matches `config.toml`. Computed via `PackService.activeSlug`.

`ConfigLoadRequested` now: list packs → load the most-recent into `config` + `configFile` + `editingPackSlug` → compute `activePackSlug` via `PackService.activeSlug`.

### Bloc events

- `PackActivated(Pack pack)` — calls `PackService.activate(baseDir, pack)`; updates `activePackSlug`; emits.
- `PackOpenedForEditing(Pack pack)` — loads that pack's TOML; updates `editingPackSlug` + `config` + `configFile`; emits. `activePackSlug` untouched.
- `PackCreated(String slug)` — uses `PackService.create(baseDir, slug, currentEditingContent)` so the new pack starts as a fork of what the user was just editing. After creation, reloads the list and emits.
- `PackRenamed(String oldSlug, String newSlug)` — `PackService.rename`. If the renamed pack was the editing/active pack, update slugs accordingly. Reload list.
- `PackDeleted(String slug)` — `PackService.delete`. If the deleted pack was the editing pack, fall back to the next-most-recent (or to `default.toml` if empty). If it was the active pack, activate the new editing pack so `config.toml` stays in sync.

### Mutation cascading

Existing mutation events (`ModToggled`, `DllAdded`, etc.) write to `configFile` (the editing pack). If `editingPackSlug == activePackSlug`, the same change also writes to `<baseDir>/config.toml`. Currently the bloc always writes to both — that's a temporary MVP; this task introduces the distinction.

### UI

#### Sidebar — pack list (Material + GNOME, same widget)

- Header: "Packs" + a `+` icon (opens create dialog).
- One row per pack:
  - Tappable row: **single click activates**; row text shows pack slug + "Active" pill when applicable.
  - Trailing icons: ✏ Edit (opens editor without activating), ⋮ overflow (Rename, Delete).
- The currently-editing pack is highlighted (different background).
- The active pack has the Active badge (regardless of whether it's also the editing pack).

#### Main panel — mod editor

The existing mod list + `SettingsPanel` (ModEngine2 toggles) + `ExternalDllList` move from the sidebar to the main panel. They show the contents of the currently-editing pack.

A small header bar above them: "Editing: <pack name>" plus an Active badge if applicable.

#### GNOME layout

The current 5-tab nav rail (Mods / Settings / External DLLs / Debug / About) gets compressed into the main panel. The nav rail itself becomes the pack list. Same shape as Material — the layout difference is purely the chrome around it.

### Dialogs

- `AddPackDialog` — same shape as `CreateEditModDialog` for mods: name field + slug preview + uniqueness check via `PackService.list`. Rejects "config".
- `RenamePackDialog` — same shape.
- `DeletePackDialog` — confirmation; warns that mod folders are not affected.

## Files

- `lib/bloc/config/config_state.dart` — add `packs`, `editingPackSlug`, `activePackSlug`.
- `lib/bloc/config/config_event.dart` — add `PackActivated`, `PackOpenedForEditing`, `PackCreated`, `PackRenamed`, `PackDeleted`.
- `lib/bloc/config/config_bloc.dart` — handlers + cascading-write logic.
- `lib/widgets/pack_list.dart` — new.
- `lib/widgets/pack_list_tile.dart` — new.
- `lib/widgets/add_pack_dialog.dart` — new.
- `lib/widgets/rename_pack_dialog.dart` — new.
- `lib/widgets/delete_pack_dialog.dart` — new.
- `lib/screens/home_screen.dart` — body restructure: sidebar = pack list, main = mod editor.
- `lib/widgets/gnome_layout.dart` — same layout shape; nav rail becomes pack list.
- `lib/l10n/app_en.arb` + `app_pt.arb` — new strings.

## Verification

1. Game with only `default.toml` activated → sidebar shows one pack with Active badge. Main panel shows its mod list.
2. Create a new pack "convergence" → file `convergence.toml` appears, opens in the editor (editing=convergence, active=default still).
3. Toggle a mod in convergence → `convergence.toml` updates. `config.toml` does NOT update (because convergence isn't active).
4. Click the convergence row → Active badge moves to convergence; `config.toml` matches convergence; subsequent edits cascade to `config.toml`.
5. Rename convergence to "balanced" → file is renamed; UI updates; active pointer survives.
6. Delete the active pack → next-most-recent gets activated; `config.toml` matches it.
7. Delete the last pack → app auto-recreates `default.toml` and activates it.
8. Try to create / rename to "config" → rejected with the translated reserved-name error.
9. Switch games via the AppBar switcher → pack list reloads for the new game.
10. `flutter analyze` clean; all new strings present in both ARB files.
