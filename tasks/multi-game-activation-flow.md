# Multi-Game Activation Flow

## Context

The **`Game` enum**, **`GameBloc`**, and **`GameFolderInitializer`** are all built and unit-tested. None of it is visible in the running app — `HomeScreen`'s placeholder `_GameSelector` still hard-codes a Dark Souls III dropdown with Elden Ring greyed out and DSR missing.

This task wires `GameBloc` into the running app so the user can actually activate / switch between games.

## Goal

After this task lands:
- `GameBloc` is provided at the app level (`refactor.md` D11), above the router.
- The home screen shows a game switcher in its AppBar, an empty state when no games are activated, and the per-game pack/mod editor body when games exist.
- Activating a game seeds it via `GameFolderInitializer` (creates `default.toml`, mirrors to `config.toml`) and lands on that game's view.
- Switching games re-dispatches `ConfigLoadRequested` (`refactor.md` D14) so the body reflects the newly selected game.

## Approach

### App-level wiring

In `lib/app.dart`, `GameBloc` is provided above `StartupRouter`. The bloc loads on construction (`add(GamesLoadRequested())`). Routing reads `GamesLoaded.activated` to pick between empty-state and the populated home view.

### Empty state

When `GamesLoaded.activated.isEmpty` (data dir set, no games yet):

- Centered card: app icon + "No games activated yet" headline + short body text + a prominent **Add game…** button.
- Tapping opens the `AddGameDialog` (see below).
- AppBar still shows the gear icon (App Preferences, when that task lands); game switcher is hidden because there's nothing to switch.

### `AddGameDialog`

- Lists `Game.values` minus already-activated games.
- Each row: full display name + radio/select indicator.
- Cancel + Activate buttons.
- On Activate → `GameBloc.add(GameActivated(<game>))` → bloc creates the folder, runs the initializer, emits with the new game as `current`.

### `GameSwitcher` (AppBar)

When `activated.isNotEmpty`:

- Material layout: `PopupMenuButton` showing the current game's display name and dropdown chevron. Menu lists activated games (each with a "current" check) + a divider + "Add game…" entry.
- GNOME layout: same component, identical look.
- Wrapper mode (a later task — Run Modes + Steam Wrapper): the same widget is rendered read-only (no popup; just the current game's name as a pill).

### `HomeScreen` rewiring

- Drops the `modEngineDir` constructor field (already deleted by the New Onboarding task, this task uses the cleaned-up shape).
- Body subscribes to `GameBloc`: empty state when no games, otherwise the existing two-pane layout for the current game.
- A `BlocListener<GameBloc>` on `current` change dispatches `ConfigBloc.add(ConfigLoadRequested(<new game's folder>))`.
- The legacy `_GameSelector` placeholder is removed.

### Hardcoded DS3 cleanup

- `home_screen.dart`'s `_openSteamSetup` swaps `const game = Game.darkSouls3` for the current game from `GameBloc.state`.
- All other DS3 hard-codes in the running UI go away.

## Files

- `lib/app.dart` — provide `GameBloc` at the top.
- `lib/screens/home_screen.dart` — rewire body around `GameBloc`; drop `_GameSelector`.
- `lib/widgets/game_switcher.dart` — new.
- `lib/widgets/add_game_dialog.dart` — new.
- `lib/widgets/empty_games_view.dart` — new.
- `lib/l10n/app_en.arb` + `app_pt.arb` — new strings.

## Verification

1. Fresh post-onboarding state with no games activated → empty-state card with Add game… button.
2. Activate Dark Souls III → creates `<gamesRoot>/dark_souls_3/default.toml` + `config.toml`; body shows the per-game editor; mod list is the default pack.
3. Activate Elden Ring → switcher now shows both. Switching to ER reloads the editor body. The DS3 mod list is restored on switching back.
4. Activate Dark Souls: Remastered → folder created, editor loads.
5. Restart the app → previously activated games persist; the last `current` game is shown.
6. Re-activating an already-activated game does **not** recreate or overwrite its folder.
7. Steam Setup button uses the **current** game (not hard-coded DS3) for its launcher path resolution.
8. `flutter analyze` clean.
