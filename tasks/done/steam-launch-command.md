# Steam Launch Command

## Context

To use the app, the user pastes a launch command into Steam → Properties → Launch Options. The command wraps Steam's `%command%` and invokes the bundled ME2 launcher with the active game's `config.toml`. Per ADR-0002, `config.toml` is always the launch target, so the command stays stable across pack switches.

## Goal

Provide a copy-paste command per game, with step-by-step instructions. Auto-open the Steam Setup screen the first time a user activates a game. AppBar button to re-open it later.

## Approach

### Command template

```sh
bash -c 'cd "<game_base>" && exec "${@:1:$(($#-1))}" "<me2_launcher>" -t <me2_game_flag> -c config.toml' -- %command%
```

Where:
- `<game_base>` — absolute path to the game's base directory (`<packs_root>/<game.slug>`).
- `<me2_launcher>` — absolute path to `modengine2_launcher.exe` (from `ModEngineLocator.launcherExe()`).
- `<me2_game_flag>` — `Game.me2GameFlag` (`ds3` / `er` / DSR's fork-specific flag).
- `config.toml` — fixed; the active-pack mirror.

`SteamCommandService.buildCommand(Game game)` produces the string.

### When the Steam Setup screen appears

- **Auto** — opened modally the first time a game is activated. Sets a per-game pref `steam_setup_seen_<slug>` after the user closes it.
- **Manually** — AppBar button labelled "Steam command", visible only when a game/pack list is in view (hidden during onboarding or empty-state).

### Screen contents

1. App icon + title "Set up Steam — <Game name>".
2. Numbered instructions:
   1. In Steam, right-click **<Game name>** → Properties.
   2. Under General → Launch Options, paste the command below.
   3. Close Properties and launch the game from Steam as normal.
3. Monospaced command box (`SelectableText`) with a copy button (uses Flutter's `Clipboard.setData`). A snackbar confirms the copy.
4. "Done" button (closes the modal).
5. Live-updates if the active game changes underneath it.

## Files

- `lib/services/steam_command_service.dart` — new.
- `lib/screens/steam_setup_screen.dart` — rewrite around real command.
- `lib/widgets/copyable_command.dart` — small reusable (monospace box + copy icon).
- `lib/services/preferences_service.dart` — extend with `steam_setup_seen_<slug>` flags.
- `lib/bloc/game/game_bloc.dart` — emit a side-effect (or expose the flag) so `HomeScreen` knows to push the modal on first activation.

## Verification

1. Activate DS3 for the first time → Steam Setup auto-opens with the DS3 command containing the right `-t ds3` flag and the active game-base path.
2. Copy → snackbar; clipboard contents match the displayed command.
3. Close → flag set; reactivating DS3 doesn't auto-open it again.
4. Activate ER → Steam Setup auto-opens for ER (different `-t er`, different game-base path).
5. AppBar "Steam command" button → opens the screen for the currently-selected game.
6. Switching the active pack in the app → `config.toml` updates; running the game in Steam now launches the new pack without re-pasting.
