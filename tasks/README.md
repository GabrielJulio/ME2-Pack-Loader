# Tasks

Forward-looking implementation plans. Each file is self-contained: Context, Goal, Approach, Files, Verification.

## Ground rules from grilling session

- Read [CONTEXT.md](../CONTEXT.md) before starting any task — terms are precise.
- Read [docs/adr/](../docs/adr/) for project-wide conventions.
- Platform-specific code obeys ADR-0001: Flutter/Dart → pub package → native command, in that order.

## Order of execution

Dependencies cascade — recommended order:

1. **[01-bundled-modengine.md](01-bundled-modengine.md)** — fetch script + bundle ME2 with the app.
2. **[02-multi-game-support.md](02-multi-game-support.md)** — `Game` enum, packs root, on-demand activation.
3. **[03-mod-packs.md](03-mod-packs.md)** — named `<slug>.toml` files + `config.toml` mirror + activate flow.
4. **[04-material-red-accent.md](04-material-red-accent.md)** — swap Material accent to red.
5. **[05-desktop-aware-theme.md](05-desktop-aware-theme.md)** — auto-pick GNOME vs Material at startup; remove user-visible layout switcher.
6. **[06-steam-launch-command.md](06-steam-launch-command.md)** — real per-game command with copy + instructions, auto-open on game activation.
