# Single data dir, movable between disks

All game folders live under one **data dir**. The user does not point each game at a separate folder. The data dir defaults to inside the app folder (same disk as the app), and the user can override it to any folder on any disk — typically to keep multi-gigabyte mods off the system drive.

Considered alternative: one folder per game (user picks each one separately). Rejected because it triples onboarding friction and the only real use-case (different drives per game) is rare; the actual concern is "mods on the system drive vs a data drive", which is satisfied by a single movable data dir.

Moving the data dir (initial pick to non-default, switching between custom locations, or returning to default) is a deliberate user action gated by a disk-space check.
