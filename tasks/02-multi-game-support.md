# 02 — Multi-Game Support

## Context

Three games are in scope: Dark Souls III, Elden Ring, Dark Souls Remastered. Each gets its own subfolder under the packs root with its own mod folders and packs. Games are **activated on demand** — the app never pre-creates folders for games the user hasn't asked for.

## Goal

`Game` is a first-class concept across the data model and UI. Activating a new game is a deliberate one-time action that creates its base directory and seeds it with `default.toml` + `config.toml`.

## Approach

### Game enum

```dart
enum Game {
  darkSouls3('Dark Souls III', 'ds3', 'ds3'),
  eldenRing('Elden Ring', 'er', 'er'),
  darkSoulsRemastered('Dark Souls Remastered', 'dsr', 'dsr-like');

  final String displayName;
  final String slug;          // folder name under packs root
  final String me2GameFlag;   // value for ME2 launcher `-t` flag
  const Game(this.displayName, this.slug, this.me2GameFlag);
}
```

(`me2GameFlag` for DSR depends on the fork — placeholder until URL is confirmed.)

### State

- `PreferencesService`:
  - `getPacksRoot()` / `setPacksRoot(String)` — replaces the old `mod_engine_dir` key.
  - `getActivatedGames()` / `setActivatedGames(Set<Game>)` — persisted as comma-separated slugs.
  - `getCurrentGame()` / `setCurrentGame(Game)`.
- New `GameBloc`:
  - States: `GamesInitial`, `GamesLoaded(activated, current)`.
  - Events: `GamesLoadRequested`, `GameActivated(Game)`, `GameSelected(Game)`.
- On `GameActivated`:
  1. Create `<packsRoot>/<game.slug>/` if missing.
  2. Create `default.toml` seeded with ME2 defaults if no `*.toml` files exist.
  3. Write `default.toml`'s contents into `config.toml`.
  4. Add to activated set, set as current, persist.

### UI

- Game switcher in the AppBar (replaces the in-sidebar selector). Shows activated games + an "+ Add game…" entry.
- "+ Add game…" opens a tiny dialog: pick one of the not-yet-activated games → confirm → dispatches `GameActivated`.
- Switching to a different activated game causes `ConfigBloc` to reload from that game's base dir.

## Files

- `lib/models/game.dart` — new.
- `lib/bloc/game/game_bloc.dart` + `game_event.dart` + `game_state.dart` — new.
- `lib/services/preferences_service.dart` — extend.
- `lib/screens/onboarding_screen.dart` — text changes to "Choose where to keep your mod packs"; no more ModEngine2 folder pick.
- `lib/screens/home_screen.dart` — wire the AppBar switcher to `GameBloc`; empty state when no games activated.
- `lib/widgets/game_switcher.dart` — new.
- `lib/widgets/add_game_dialog.dart` — new.

## Verification

1. Fresh install → onboarding picks packs root → home screen shows empty state + "Add game…" button.
2. Activate DS3 → `<root>/ds3/default.toml` + `config.toml` created.
3. Activate ER → switcher shows DS3 + ER; switching reloads the right pack list.
4. Restart → activated set and last-current game persist.
5. Switching back to a previously activated game doesn't recreate files.
