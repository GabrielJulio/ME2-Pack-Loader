# 05 — Desktop-Aware Theme

## Context

The user shouldn't pick a layout. The app detects the desktop environment and accent at startup and picks GNOME or Material automatically. Manual switcher remains only behind `kDebugMode`.

## Goal

- GNOME detected **and** accent readable → GNOME layout with that accent.
- GNOME detected **and** accent missing → Material (red).
- Not GNOME (or not Linux) → Material (red).

## Approach

### Detection — obeys ADR-0001

`lib/services/desktop_environment_service.dart`:
- `Future<bool> isGnome()` — guard with `Platform.isLinux`; on Linux, check `XDG_CURRENT_DESKTOP` env var contains `GNOME`.
- `Future<Color?> gnomeAccentColor()` — `Platform.isLinux` guard; calls `gsettings get org.gnome.desktop.interface accent-color` via `Process.run`. Returns null on non-Linux, non-GNOME, missing key, or unrecognised value.

Mapping from GNOME accent name → hex (matches the upstream GNOME palette):

| Name | Hex |
|---|---|
| blue | `#3584E4` |
| teal | `#2190A4` |
| green | `#3A944A` |
| yellow | `#C88800` |
| orange | `#ED5B00` |
| red | `#E62D42` |
| pink | `#D56199` |
| purple | `#9141AC` |
| slate | `#6F8396` |

### Wiring

- `LayoutBloc` on `LayoutStarted`:
  - If `kDebugMode` and a manual override exists in prefs → honour it.
  - Else call `DesktopEnvironmentService` and resolve:
    - `isGnome() && accent != null` → `LayoutState.gnome(accentColor)`.
    - Anything else → `LayoutState.material`.
- `GnomeLayout` accepts an `accentColor` parameter (defaults to `#8AB4F8` for `kDebugMode` previews).

### UI changes

- **Remove** the `PopupMenuButton` layout switcher from the AppBar in production builds.
- In `kDebugMode`, keep it (now with options: Auto / GNOME / Material). "Auto" clears the override and re-runs detection.

## Files

- `lib/services/desktop_environment_service.dart` — new.
- `lib/bloc/layout/layout_bloc.dart` — call detection on `LayoutStarted`; honour override only in dev.
- `lib/models/layout_type.dart` — add `auto`.
- `lib/widgets/gnome_layout.dart` — accept `accentColor` param.
- `lib/screens/home_screen.dart` — switcher hidden behind `kDebugMode`.

## Verification

1. Run on GNOME 47+ with accent set to red → GNOME layout with `#E62D42`.
2. Run on GNOME 46 (no accent key) → Material (red).
3. Run on KDE → Material.
4. Run on Windows → Material (no detection runs).
5. Dev build → switcher visible; release build → not visible.
