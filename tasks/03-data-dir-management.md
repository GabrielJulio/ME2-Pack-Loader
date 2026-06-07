# 03 — Data Directory Management

## Context

Game folders can grow very large (single mods are often 5+ GB). Forcing them onto the system drive risks filling it up. The user picks at first launch where game folders live: the **default location** inside the app folder, or a **custom data dir** on any disk they choose. A pointer config in the app folder records the choice. The user can change their mind later. Both directions of move (default ↔ custom, or custom ↔ custom) run a disk-space check.

The ME2 binary itself always stays in the app folder — it's tiny and tied to app state.

## Goal

A robust data-dir lifecycle: first-launch pick, missing-dir recovery, settings-driven move with disk-space safety. Single source of truth (the pointer config). No silent failures on missing disks.

## Approach

### Layout recap

| Case | App folder | ME2 binary | Game folders (games root) |
|---|---|---|---|
| Default | `<app>` | `<app>/modengine2/` | `<app>/modengine2/<game.slug>/` |
| Custom | `<app>` | `<app>/modengine2/` | `<data dir>/me2_pack_loader/modengine2/<game.slug>/` |

`<app>` resolves via `path_provider.getApplicationSupportDirectory()` (see ADR-0001 for the platform-abstraction order).

### Pointer config

`<app>/pointer.json`:
```json
{ "dataDir": "/mnt/storage/games" }   // null or absent ⇒ default
```

Single file. Written atomically (write to `.tmp`, fsync, rename).

### Service

`lib/services/data_dir_service.dart`:
- `Future<DataDirStatus> probe()`:
  - Reads `pointer.json`.
  - If `dataDir` set and unreachable → `DataDirStatus.missing(path)`.
  - If set and reachable → `DataDirStatus.custom(path)`.
  - If unset → `DataDirStatus.default_`.
- `Future<String> gamesRoot()` — returns `<app>/modengine2/` (default) or `<data dir>/me2_pack_loader/modengine2/` (custom). Creates the directory if missing.
- `Future<DiskCheckResult> checkSpace(String destination)` — returns `{ neededBytes, freeBytes, marginAfterMoveBytes, verdict: enough | tight | insufficient }`. Threshold for `tight`: less than 2 GB free post-move.
- `Future<void> moveTo(String? newDataDir)`:
  - Runs `checkSpace`; aborts on `insufficient`.
  - Computes new games root; copies game folders over (recursive), validates, then deletes the source. Atomic enough: source isn't deleted until copy verifies.
  - Updates `pointer.json`.

### First-launch flow

1. App starts → `DataDirService.probe()`.
2. If `default_`: continue normally. (No dialog. Default is implicit when pointer.json is absent.)
3. If user clicks "Choose data dir" via onboarding/settings → show first-launch dialog (below).

### First-launch dialog (in onboarding)

Modal:
- Headline: "Where should your mods live?"
- Two cards/buttons:
  - **"Use default"** — body text: "Stored at `<app>/modengine2/`. Uses your system drive."
  - **"Choose a folder"** — opens system folder picker. Selected path becomes `<data dir>`; the app creates `<data dir>/me2_pack_loader/modengine2/` and runs `checkSpace`.
- After "Choose a folder": render a small disk-space summary:
  - Enough: "Has X GB free — plenty of room." Confirm button enabled.
  - Tight: "Only Y GB will remain free. Are you sure?" Confirm button enabled with warning style.
  - Insufficient: "Not enough space (need N GB, only M GB free)." Confirm disabled.

### Missing-dir recovery

If `probe()` returns `missing(path)` on startup:
- Block the home screen with a recovery dialog:
  - "Your data dir at `<path>` is unavailable. The disk may be unplugged."
  - Buttons:
    - **"I plugged it back in — retry"** → re-probe.
    - **"Choose a new location"** → folder picker (then disk-space check + copy if data is recoverable; otherwise treats it as an empty new dir).
    - **"Use default"** → switches to default location; warns that previously-stored game folders won't be accessible until the disk reappears.

### Settings: move data dir

A "Storage" section in settings:
- Shows current data dir + total disk usage of game folders.
- **"Move to a different folder"** → folder picker → disk-space check → confirm → move.
- **"Return to default"** → disk-space check → confirm → move back.

### Disk-space check

Computes:
- `neededBytes` = recursive byte sum of every game folder under the current games root.
- `freeBytes` = `df`-equivalent on the destination's filesystem (use Dart `Process.run('df', ...)` on Linux, `GetDiskFreeSpaceEx` on Windows via FFI or a pub package; per ADR-0001 try pub package first).
- `marginAfterMoveBytes` = `freeBytes - neededBytes`.
- Verdict: `enough` (margin ≥ 2 GB), `tight` (0 ≤ margin < 2 GB), `insufficient` (margin < 0).

Run **both** when moving *to* a custom dir and when moving *back to default* — the system drive can be full too.

## Files

- `lib/services/data_dir_service.dart` — new.
- `lib/models/data_dir_status.dart` — new (`default_`, `custom(path)`, `missing(path)`).
- `lib/models/disk_check_result.dart` — new.
- `lib/screens/onboarding_screen.dart` — rewrite with the first-launch dialog.
- `lib/widgets/data_dir_picker_dialog.dart` — new (used by onboarding and settings).
- `lib/widgets/missing_data_dir_dialog.dart` — new.
- `lib/screens/settings_screen.dart` (or section within existing settings) — Storage panel.
- `lib/services/preferences_service.dart` — drop the old `mod_engine_dir` key (now lives in pointer.json).

## Verification

1. Fresh install with no `pointer.json` → app uses default (no dialog).
2. From settings → "Move to different folder" → pick external SSD → enough space → game folders copy, source removed, `pointer.json` updated.
3. Unplug the external SSD, restart → recovery dialog appears.
4. Pick "Use default" in recovery dialog → app continues with empty default games root; warns user.
5. Plug SSD back in → "Retry" succeeds; previous game folders re-appear.
6. Try to move to a destination with insufficient space → blocked with the byte-accurate error.
7. Try to move with tight margin → warning-styled confirm; proceeds if user confirms.
8. Return-to-default after a custom dir → same disk-space check on system drive.
