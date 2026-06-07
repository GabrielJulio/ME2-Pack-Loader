# Single packs root with auto-created game subfolders

The user picks **one** directory at onboarding (the "packs root"). The app creates one subfolder per game beneath it (`ds3/`, `er/`, `dsr/`) as games are activated. The user cannot point each game at a separate folder.

Considered alternative: one folder per game (user picks each one separately). Rejected because it triples onboarding friction, complicates settings UI, and the only real use-case (different drives per game) is rare. If we add it later, it would extend the model rather than break it: the packs root becomes a default, with per-game overrides stored in prefs.
