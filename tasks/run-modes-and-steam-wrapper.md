# Run Modes + Steam Wrapper

## Context

Today the app boots into a single mode (manager UI). The plan introduces two distinct **Run Modes** (`refactor.md` D15):

- **Standalone mode** — direct launch, full manager UI.
- **Wrapper mode** — launched by Steam with `--game <slug> --mode run -- <launch chain>`. UI is locked to the named game; clicking "Launch Game" spawns ModEngine2 with the captured **Launch chain** and exits the app (`refactor.md` D16).

`SteamCommandService` already builds a per-game command but in the old shape (no wrapper, no `%command%` pass-through). `SteamSetupScreen` shows that command. Neither is consumed by a working wrapper-mode launch flow.

This task wires the full thing end-to-end and bundles three closely-related pieces (`refactor.md` D17, D20):

1. The CLI argv parser and routing-by-mode.
2. The wrapper UI shape (locked game switcher, Launch button) and subprocess spawn.
3. The first-time-via-Steam onboarding fallthrough and persisted GNOME detection.

## Goal

After this task:
- A user can paste the new Steam command into Steam's Launch Options. Clicking Play in Steam opens the app in wrapper mode locked to that game.
- The user sees the same two-pane layout as standalone, but with the game switcher rendered read-only and a prominent **Launch Game** action in the AppBar.
- Clicking Launch Game spawns ModEngine2 (with the captured Proton + game-exe chain) as a subprocess and the app exits immediately.
- If the user has never set up the app before, the onboarding screens run inline first, auto-activate the locked game, then continue into the wrapper UI.
- GNOME-or-not + accent color are persisted on the first standalone run and re-used in wrapper mode so Proton doesn't flip the layout.

## Approach

### Argv parsing

A small `lib/cli/runtime_args.dart` parses `argv` into:

```dart
class RuntimeArgs {
  final RunMode mode;            // RunMode.standalone | RunMode.wrapper
  final Game? lockedGame;        // populated when mode == wrapper
  final List<String> launchChain; // tokens after `--`; empty in standalone
}
```

Parsing rules:
- `--mode run` → wrapper mode (else standalone).
- `--game <slug>` → resolves to a `Game` value via `Game.fromSlug`. Required in wrapper mode; else error.
- Everything after `--` is the captured launch chain.

`main.dart` parses argv, builds `RuntimeArgs`, passes it into `App`.

### Steam command shape

`SteamCommandService.buildCommand` is rewritten to emit:

```sh
bash -c '<absolute-path-to-app> --game <slug> --mode run -- "${@:1:$(($#-1))}"' -- %command%
```

The absolute path comes from `Platform.resolvedExecutable`. `SteamSetupScreen` already renders the result; this task only updates the builder + tests.

### Routing — wrapper mode

`StartupRouter` learns to branch on `RuntimeArgs.mode`:

- `standalone` → existing routing.
- `wrapper` →
  - If `onboarding_completed == false` → onboarding inline, then auto-activate `RuntimeArgs.lockedGame`, then continue to wrapper UI.
  - If onboarded but `lockedGame` not in activated set → silently activate it (no Add Game dialog needed; Steam already told us which game).
  - Else → straight to wrapper UI.

`GameBloc.current` in wrapper mode is forced to `RuntimeArgs.lockedGame` (overriding prefs). On wrapper exit the prefs `current_game` is **not** modified.

### Wrapper UI

- Same two-pane layout as standalone (pack list + mod editor).
- Game switcher widget renders as a read-only pill ("Dark Souls III") when the bloc is in wrapper mode.
- AppBar gains a prominent **Launch Game** filled button (right side).
- App Preferences gear icon is hidden in wrapper mode (the user came in to play, not configure).
- Steam Setup button is hidden (the user already pasted the command).

### Launch Game action

On tap:
1. Resolve `me2LauncherPath` via `ModEngineLocator.production().launcherExe()`.
2. Resolve `gameBaseDir` via `DataDirService` + `lockedGame.slug`.
3. Construct the subprocess argv:
   - First element: the first token of `launchChain` (e.g. Proton).
   - Rest: the remaining `launchChain` tokens, plus the ModEngine2 launcher, plus `-t <gameFlag>`, plus `-c config.toml`.
   - `cwd = gameBaseDir`.
4. `Process.start(...).detached()` — fire-and-forget; Steam sees that subprocess as the running game.
5. `exit(0)` — drop our window. Steam's "Game running" indicator stays alive as long as the subprocess does.

If the active pack has `auto_launch = true` (the Auto-Launch task), the same code path runs **without showing the UI** — the wrapper boots, computes everything, spawns, exits.

### Persisted GNOME detection

`PreferencesService` gains `is_gnome` (bool) and `gnome_accent_hex` (nullable string).

`LayoutBloc.LayoutStarted` in **standalone mode** runs the live `DesktopEnvironmentService` detection and writes the result to prefs.

`LayoutBloc.LayoutStarted` in **wrapper mode** reads from prefs only. If the value is missing (user pasted Steam command before ever launching standalone — see "first-time-via-Steam" above), falls back to Material.

`LayoutBloc` gains a `RunMode` constructor field to know which branch to take.

## Files

- `lib/cli/runtime_args.dart` — new.
- `lib/main.dart` — parse argv, build `RuntimeArgs`, inject into `App`.
- `lib/app.dart` — accept `RuntimeArgs`, branch routing on mode, override `GameBloc.current` in wrapper mode.
- `lib/screens/wrapper_launch_screen.dart` — new (the AppBar + Launch button + body). Reuses the standalone two-pane content.
- `lib/services/steam_command_service.dart` — rewrite output shape.
- `lib/screens/steam_setup_screen.dart` — no shape change; just sources the new command string.
- `lib/services/preferences_service.dart` — add `is_gnome` / `gnome_accent_hex` getters/setters.
- `lib/bloc/layout/layout_bloc.dart` — accept `RunMode`; branch detection vs. read-prefs.
- `lib/widgets/game_switcher.dart` — read-only variant.
- `lib/widgets/launch_game_button.dart` — new (real implementation; replaces the disabled placeholder).
- `lib/l10n/app_en.arb` + `app_pt.arb` — new strings.

## Verification

1. `flutter run -d linux` (no extra args) → standalone mode (regression test).
2. `flutter run -d linux --dart-entrypoint-args="--game ds3 --mode run -- echo proton --steam-args fake.exe"` → wrapper mode for DS3; game switcher is a pill; Launch Game visible; gear icon hidden.
3. Click Launch Game → subprocess spawns with the captured chain prepended to the ME2 launcher path. App exits.
4. Paste the new Steam command into Steam Properties for an actual game → clicking Play in Steam opens the wrapper. Launch Game spawns ModEngine2; the game runs; Steam shows the game as running until the subprocess dies.
5. Fresh install + Steam click (no prior standalone run) → onboarding inline → auto-activate locked game → wrapper UI.
6. GNOME standalone first launch → `is_gnome=true` + accent saved in prefs.
7. Subsequent wrapper-mode run under Proton (where live detection would report Windows) → app reads prefs, keeps GNOME layout + accent.
8. `flutter analyze` clean.
