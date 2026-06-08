# Multi-Game Support

## Context

Three games are in scope: Dark Souls III, Elden Ring, Dark Souls: Remastered. Each gets a game folder under the current **data dir** (see [Data Directory Management](./data-dir-management.md) for how the data dir is chosen and moved). Games are **activated on demand** — the app never pre-creates folders for games the user hasn't asked for.

Game folder path:
- Default data dir: `<ME2 folder>/<game.slug>/`
- Custom data dir: `<data dir>/me2_pack_loader/modengine2/<game.slug>/`

Game slugs (matching folder names in the user's examples):
- `dark_souls_3`
- `elden_ring`
- `dark_souls_remastered`

## Goal

`Game` is a first-class concept across the data model and UI. Activating a new game is a deliberate one-time action that creates its game folder and seeds it with `default.toml` + `config.toml`.

## Approach

### Game enum

```dart
enum Game {
  darkSouls3('Dark Souls III', 'dark_souls_3', 'ds3'),
  eldenRing('Elden Ring', 'elden_ring', 'er'),
  darkSoulsRemastered('Dark Souls: Remastered', 'dark_souls_remastered', 'dsr-like');

  final String displayName;
  final String slug;          // folder name
  final String me2GameFlag;   // value for ME2 launcher `-t` flag
  const Game(this.displayName, this.slug, this.me2GameFlag);
}
```

(`me2GameFlag` for DSR depends on the fork — placeholder until URL is confirmed.)

### State

- `PreferencesService`:
  - `getActivatedGames()` / `setActivatedGames(Set<Game>)` — persisted as comma-separated slugs.
  - `getCurrentGame()` / `setCurrentGame(Game)`.
  - (Data-dir storage lives in the pointer config, not prefs — see Data Directory Management.)
- New `GameBloc`:
  - States: `GamesInitial`, `GamesLoaded(activated, current)`.
  - Events: `GamesLoadRequested`, `GameActivated(Game)`, `GameSelected(Game)`.
- On `GameActivated`:
  1. Ask `DataDirService` for the current games-root path; create `<root>/<game.slug>/` if missing.
  2. Create `default.toml` seeded with ME2 defaults if no `*.toml` files exist.
  3. Write `default.toml`'s contents into `config.toml`.
  4. Add to activated set, set as current, persist.

### UI

- Game switcher in the AppBar (replaces the in-sidebar selector). Shows activated games + an "+ Add game…" entry.
- "+ Add game…" opens a dialog: pick one of the not-yet-activated games → confirm → dispatches `GameActivated`.
- Switching to a different activated game causes `ConfigBloc` to reload from that game's base dir.

## Files

- `lib/models/game.dart` — new.
- `lib/bloc/game/game_bloc.dart` + `game_event.dart` + `game_state.dart` — new.
- `lib/services/preferences_service.dart` — extend with activated-games + current-game.
- `lib/screens/home_screen.dart` — wire the AppBar switcher to `GameBloc`; empty state when no games activated.
- `lib/widgets/game_switcher.dart` — new.
- `lib/widgets/add_game_dialog.dart` — new.

(Onboarding screen changes live in Data Directory Management.)

## Verification

1. Fresh install (after data dir set per Data Directory Management) → home screen shows empty state + "Add game…" button.
2. Activate DS3 → `<games-root>/dark_souls_3/default.toml` + `config.toml` created.
3. Activate ER → switcher shows DS3 + ER; switching reloads the right pack list.
4. Restart → activated set and last-current game persist.
5. Switching back to a previously activated game doesn't recreate files.
