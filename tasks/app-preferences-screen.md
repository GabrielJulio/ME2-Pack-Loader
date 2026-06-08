# App Preferences Screen

## Context

App-level settings (move the **Data Dir**, change language, view About) currently have inconsistent homes: the `LanguageSelector` is inlined into the sidebar / GNOME About page; "Move data dir" has no UI at all (`DataDirService.moveTo` is callable from tests only); the About blurb lives only inside the GNOME layout's nav rail.

This task consolidates them into a single `AppPreferencesScreen` reachable from a gear icon in the AppBar.

## Goal

- A gear icon in the AppBar opens the `AppPreferencesScreen` as a modal route.
- The screen has three sections: **Storage**, **Language**, **About**.
- Storage shows the current data-dir location and lets the user move it (with disk-space check) or return to default.
- Language section is the existing `LanguageSelector` widget.
- About section moves out of the GNOME nav rail into this screen so both layouts get the same About.

## Approach

### Entry point

- AppBar gains a leading-actions gear icon (`Icons.settings`) with tooltip "Preferences".
- In wrapper mode (a later task) the gear is hidden.
- Tap → `Navigator.push` with the new `AppPreferencesScreen`.

### Screen layout

Single-column scrollable view with three section cards:

#### Storage

- **Current location**: shows the path (or "Default — `<app folder>/modengine2/`").
- **Total mod data size**: result of `DataDirService.directorySize(gamesRoot)` (cached for the session). Pretty-formatted (`12.4 GB`).
- **Move…** button → folder picker → on selection:
  1. Run `DataDirService.checkSpace(<picked>)`.
  2. Render the verdict inline (icons + numbers + verdict message):
     - `enough` → green check + "Plenty of room." + Confirm button.
     - `tight` → amber warning + "Very tight — only X will be free after the move." + Confirm button (warning-styled).
     - `insufficient` → red error + "Not enough free space." + Confirm disabled.
  3. On confirm → call `DataDirService.moveTo(newDataDir: picked, gameFolderSlugs: <activated.map(slug)>)` → snackbar success → close picker.
- **Return to default** button → same flow but with `null`.

#### Language

The existing `LanguageSelector` widget (unchanged from the Translations task), inside a card.

#### About

Moved verbatim from `gnome_layout.dart`'s `_AboutPage`:
- App icon + name + version
- Description
- Unofficial-tool disclaimer
- Online-play warning

After the move, GNOME nav rail's About entry is removed (the gear icon supersedes it). The Debug page also moves out of the rail into a hidden-by-default section under About (or behind a tap-count gesture) — decision deferred to the implementer; not central to this task.

### Disk-space check UX

The picker → verdict → confirm flow is **all within the same modal**, not separate routes. Cancelling at any step returns to the Storage section view.

## Files

- `lib/screens/app_preferences_screen.dart` — new.
- `lib/widgets/storage_panel.dart` — new (moves data dir, runs the disk-space flow).
- `lib/widgets/about_panel.dart` — new (extracted from `gnome_layout.dart`).
- `lib/widgets/gnome_layout.dart` — remove About + Debug entries from nav rail.
- `lib/widgets/language_selector.dart` — remove from the Material sidebar and the GNOME About page (now lives only inside AppPreferences).
- `lib/screens/home_screen.dart` — add gear icon in AppBar.
- `lib/l10n/app_en.arb` + `app_pt.arb` — new strings.

## Verification

1. Tap gear in AppBar → AppPreferencesScreen opens.
2. Storage section shows current location + total size.
3. Tap Move… → folder picker → pick `/tmp/me2-storage` (lots of free space) → verdict "enough" + Confirm → game folders move, pointer updates, snackbar.
4. Move to a path on a tight drive → "tight" verdict + warning-styled confirm; proceeding works.
5. Move to a path with insufficient space → "insufficient" + Confirm disabled.
6. Return to default → game folders move back, pointer cleared.
7. Change language in Language section → UI flips immediately, persists.
8. Language selector and About no longer appear in the sidebar or GNOME nav rail (only in AppPreferences).
9. `flutter analyze` clean.
