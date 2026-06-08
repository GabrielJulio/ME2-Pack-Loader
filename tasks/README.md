# Tasks

Forward-looking implementation plans. Each file is self-contained: Context, Goal, Approach, Files, Verification. Move a file to [`done/`](./done/) once its verification steps all pass.

## Ground rules

- Read [CONTEXT.md](../CONTEXT.md) before starting any task — terms are precise.
- Read [docs/adr/](../docs/adr/) for project-wide architectural decisions.
- Read [AGENTS.md](../AGENTS.md) for project guidance and naming conventions (e.g. game names are always full in user-facing text).
- Read [refactor.md](../refactor.md) for autonomous decisions I've taken while executing tasks.
- Platform-specific code obeys ADR-0001: Flutter/Dart → pub package → native command, in that order.
- User-facing strings live in `lib/l10n/app_en.arb` + `lib/l10n/app_pt.arb` — never as hardcoded literals.
- Game names in user-facing text are always full ("Dark Souls III", "Elden Ring", "Dark Souls: Remastered") — never `DS3` / `ER` / `DSR`.

## Execution order

Filenames carry no numbers; execution order lives here.

### Foundation (other tasks depend on this one being done)

1. **[Bundled ModEngine2](./bundled-modengine.md)** — fetch script + pre-cache extraction. *Blocked externally on the upstream ModEngine2 fork URL.*

### UI integration batch (the bar: "user can actually use the app")

These cover the gap between the service layer (already in `done/`) and a working app.

```
new-onboarding-and-startup-routing
 ├─► missing-data-dir-recovery
 ├─► app-preferences-screen
 └─► multi-game-activation-flow
      ├─► pack-list-and-management
      │     └─► per-pack-auto-launch (joins with run-modes)
      └─► run-modes-and-steam-wrapper
            └─► per-pack-auto-launch
```

In practical order:

2. **[New Onboarding + Startup Routing](./new-onboarding-and-startup-routing.md)** — drop `SetupBloc`, new data-dir picker, routing through the new world. Unblocks everything else.
3. **[Multi-Game Activation Flow](./multi-game-activation-flow.md)** — `GameBloc` at app level, AppBar game switcher, Add Game dialog, empty state.
4. **[Pack List + Management UI](./pack-list-and-management.md)** — sidebar pack list with click-to-activate, edit-without-activate, create/rename/delete dialogs.
5. **[Run Modes + Steam Wrapper](./run-modes-and-steam-wrapper.md)** — CLI parsing, Steam command rewrite, wrapper-mode UI + subprocess launch, persisted GNOME detection, first-time-via-Steam onboarding fallthrough.
6. **[Per-Pack Auto-Launch](./per-pack-auto-launch.md)** — TOML field + toggle UI + wrapper-mode short-circuit. Needs both Pack List and Run Modes.

Independent of the chain above; can be done any time after task 2:

7. **[Missing Data-Dir Recovery](./missing-data-dir-recovery.md)** — recovery screen when the data drive is unreachable on boot.
8. **[App Preferences Screen](./app-preferences-screen.md)** — gear icon → Storage (move data dir w/ disk-space check) / Language / About.
