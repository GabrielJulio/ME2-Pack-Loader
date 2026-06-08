# Per-Pack Auto-Launch Flag

## Context

Per `refactor.md` D19, a **Pack** can be marked `auto_launch = true` so that the user is sent straight into the game when they click Play in Steam — no configure UI shown. The flag lives inside the pack's TOML so it travels with the pack.

This task needs the Pack List + Management UI (the place to toggle the flag) and Run Modes + Steam Wrapper (the place that honors it) to be in place first.

## Goal

- The pack TOML schema gains an optional `[me2_pack_loader] auto_launch = true` field. ModEngine2 ignores it (unknown section).
- The Pack model carries the flag.
- A toggle in the pack-list overflow (or inline) flips it; the change writes to the pack file immediately.
- In wrapper mode, if the active pack of the locked game has `auto_launch == true`, the app spawns ModEngine2 and exits **without rendering the UI**.

## Approach

### TOML schema

```toml
[me2_pack_loader]
auto_launch = true
```

`ConfigService.read` parses this section if present; falls back to `false`. `ConfigService.write` emits the section only when `autoLaunch == true` (don't pollute packs that haven't opted in).

### Model

`GameConfig` gains `final bool autoLaunch` (default `false`) with `copyWith` support.

### Bloc + UI

- New `ConfigEvent.AutoLaunchToggled` event handled by `ConfigBloc._update` (writes to the editing pack; mirrors to `config.toml` if editing == active).
- Pack list tile shows a small "rocket" icon when `autoLaunch == true` on that pack; the overflow menu offers a "Auto-launch" toggle.
- Alternative: a checkbox in the mod editor's header bar ("Auto-launch this pack from Steam"). Implementer's choice; doesn't change behavior.

### Wrapper short-circuit

In `App` (or whatever ends up routing wrapper mode), the wrapper-mode branch checks:

```
loadedActivePack = PackService.activeSlug(<game folder>)
loadedActivePackConfig = ConfigService.read(<that pack's file>)
if loadedActivePackConfig.autoLaunch:
  spawn ModEngine2 (same code path as the Launch Game button)
  exit(0)
else:
  render the wrapper UI
```

This bypass runs before the layout / theme / pack list is ever built, so the user sees nothing.

### Standalone-mode visibility

In standalone mode the toggle is purely informational (the user is configuring, not launching). The visual indicator (rocket icon, checkbox state) still renders so the user knows which pack auto-launches.

## Files

- `lib/services/config_service.dart` — read/write `[me2_pack_loader].auto_launch`.
- `lib/models/game_config.dart` — add `autoLaunch` field.
- `lib/bloc/config/config_event.dart` — `AutoLaunchToggled`.
- `lib/bloc/config/config_bloc.dart` — handler.
- `lib/widgets/pack_list_tile.dart` — rocket indicator + overflow item OR header checkbox.
- `lib/app.dart` (or wherever wrapper-mode routing lives) — short-circuit check.
- `lib/l10n/app_en.arb` + `app_pt.arb` — new strings.

## Verification

1. Create a pack in standalone; toggle Auto-launch on; the pack's TOML now has `[me2_pack_loader] auto_launch = true`.
2. Toggle off; the section is removed (not left as `false`).
3. Set Auto-launch on the active pack of DS3; click Play in Steam for DS3 → app spawns ModEngine2 and exits without rendering any UI window.
4. Set Auto-launch on a non-active pack; click Play in Steam → wrapper UI renders normally (because the active pack doesn't have the flag).
5. Switch the active pack to the auto-launch-flagged one in standalone; click Play in Steam → no UI; game runs.
6. `flutter analyze` clean.
