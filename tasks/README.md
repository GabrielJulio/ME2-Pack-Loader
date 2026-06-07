# Tasks

Forward-looking implementation plans. Each file is self-contained: Context, Goal, Approach, Files, Verification. Move a file to [`done/`](./done/) once its verification steps all pass.

## Ground rules

- Read [CONTEXT.md](../CONTEXT.md) before starting any task — terms are precise.
- Read [docs/adr/](../docs/adr/) for project-wide architectural decisions.
- Read [AGENTS.md](../AGENTS.md) for project guidance and naming conventions (e.g. game names are always full in user-facing text).
- Platform-specific code obeys ADR-0001: Flutter/Dart → pub package → native command, in that order.

## Execution order

Filenames are numbered to match execution order:

1. **[01-bundled-modengine.md](01-bundled-modengine.md)** — fetch script + bundle ModEngine2 with the app (extracted to the fixed ME2 folder).
2. **[02-data-dir-management.md](02-data-dir-management.md)** — data-dir lifecycle: default vs. custom location, missing-disk recovery, disk-space-checked moves. Onboarding screen lives here.
3. **[03-multi-game-support.md](03-multi-game-support.md)** — `Game` enum, on-demand activation, game switcher.
4. **[04-mod-packs.md](04-mod-packs.md)** — named `<slug>.toml` files + `config.toml` mirror + activate flow.
5. **[05-material-red-accent.md](05-material-red-accent.md)** — swap Material accent to red.
6. **[06-desktop-aware-theme.md](06-desktop-aware-theme.md)** — auto-pick GNOME vs Material at startup; remove user-visible layout switcher.
7. **[07-steam-launch-command.md](07-steam-launch-command.md)** — real per-game command with copy + instructions, auto-open on game activation.
