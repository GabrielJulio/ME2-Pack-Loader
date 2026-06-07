# 06 — Material Red Accent

## Context

Current Material theme uses orange (`#FF8A70`). Change to red. Quick, isolated.

## Goal

Swap the Material accent without disturbing the GNOME accent (blue / system-detected) or the rest of the ME2 Obsidian palette.

## Approach

Update the two accent constants in `lib/app.dart`:

| Role | Old | New |
|---|---|---|
| Accent | `#FF8A70` | `#E5484D` |
| Accent Hover | `#FFA18C` | `#FF6369` |

All Switch / Button / focus-ring / selected-tab tinting flows from these via the `ColorScheme`. No other file changes.

## Files

- `lib/app.dart`

## Verification

1. `flutter run -d linux` → Material accents are red on Switches, FilledButtons, focus rings, and accent text.
2. Switch to GNOME layout (dev mode) → still blue / GNOME-detected accent (untouched).
3. Contrast on background `#070607` still readable.
