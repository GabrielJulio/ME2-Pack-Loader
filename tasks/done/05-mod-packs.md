# 05 — Mod Packs

## Context

Today the app loads one fixed TOML and writes back to it. Users want named, switchable packs per game (e.g. "convergence", "vanilla+", "seamless"). The launch command stays stable across switches by mirroring the active pack into a reserved `config.toml` (see ADR-0002).

## Goal

Per-game pack management: list, create, activate, edit, rename, delete. The UI surfaces "Active" status; clicking a pack activates it; editing has a separate affordance.

## Approach

### File layout (per game base directory)

```
<root>/ds3/
  mod/                          ← mod folders (shared across packs)
  convergence/
  texture/
  default.toml                  ← a pack
  convergence.toml              ← another pack
  config.toml                   ← active-pack mirror (managed by app)
```

### Discovery

`PackService.list(Directory baseDir)`:
- Glob `*.toml`, exclude `config.toml`.
- Return `List<Pack>` sorted by `mtime` desc.

### Default pack on app load

On opening a game, load the **most-recently-modified `<slug>.toml`** into the editor. This is the UI default — it does not necessarily equal the active pack (which is `config.toml`'s mirror source).

### First-run per game (from task 04)

If no packs exist, create `default.toml` and activate it (copy to `config.toml`).

### Activate flow

`PackBloc` event `PackActivated(Pack p)`:
1. `configService.write(<baseDir>/config.toml, p.contents)`.
2. Touch `p.file` mtime so it remains the UI default on next load.
3. Emit new state with `activePackSlug` updated.

### Edit flow

Editing is the existing mod toggle / reorder / DLL flow, but scoped to whichever pack the user opened. Writes go to `<slug>.toml`. **If the pack being edited is the active pack, the same write also updates `config.toml`** (the mirror stays in sync). Auto-save remains (write on every event), no explicit "Save" button.

### Pack actions

In the pack list:
- **Single click on a pack row** → `PackActivated(pack)`. The list updates the "Active" badge.
- **Pencil icon / edit affordance** → opens that pack in the editor without activating.
- **Overflow menu** → Rename, Delete.

### Naming

- New pack: dialog with a name field, live `slugify(name)` preview. Reject if slug equals `config` or collides with an existing pack.
- Rename: dialog with name field; renames the file on disk.

## Models / state

- `lib/models/pack.dart`:
  ```dart
  class Pack {
    final String slug;       // == filename minus .toml
    final File file;
    final DateTime modifiedAt;
  }
  ```
- `ConfigState.ConfigLoaded` gains `String activePackSlug` and `String editingPackSlug`.

## Files

- `lib/models/pack.dart` — new.
- `lib/services/pack_service.dart` — new (list/create/rename/delete; activate = mirror to `config.toml`).
- `lib/services/config_service.dart` — generalised to accept any pack file path; `config.toml` writes go through here too.
- `lib/bloc/config/config_bloc.dart` — events: `PackActivated`, `PackOpenedForEditing`, `PackCreated`, `PackRenamed`, `PackDeleted`. Edits propagate to `config.toml` iff `editingPackSlug == activePackSlug`.
- `lib/widgets/pack_list.dart` — new (above the mod list in both layouts).
- `lib/widgets/create_pack_dialog.dart` — new.

## Verification

1. Fresh DS3 activation → `default.toml` + `config.toml` exist, both have identical content.
2. Toggle a mod in `default.toml` → both files updated.
3. Create `convergence` → file appears; not yet active; "Active" badge stays on `default`.
4. Click `convergence` row → `config.toml` overwritten with convergence's content; badge moves.
5. Open `default` via pencil icon, toggle a mod → `default.toml` updated, `config.toml` untouched.
6. Restart → most-recently-modified pack auto-loads in the editor; active pack unchanged.
7. Try to name a new pack "config" → rejected with explanation.
8. Delete the active pack → fall back to next-most-recent (which gets activated); if none, recreate `default.toml`.
