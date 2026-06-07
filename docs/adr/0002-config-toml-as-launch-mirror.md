# `config.toml` is the launch mirror, not a real pack

ModEngine2 always reads a fixed-name config file. To let the user paste the Steam launch command **once** and then switch packs freely in-app, we reserve `config.toml` per-game as a copy of the active pack's contents. Activating a pack rewrites `config.toml`; editing the active pack also propagates to `config.toml` so the mirror never drifts. `config.toml` is invisible in the UI — only `<slug>.toml` files are listed as packs.

Considered alternatives: (a) baking the pack name into the Steam command (would force the user to re-paste on every pack switch), (b) using a shell snippet in the command to resolve "latest pack" (`ls -t`, fragile). The mirror approach keeps the Steam command literal and stable while preserving in-app pack switching.
