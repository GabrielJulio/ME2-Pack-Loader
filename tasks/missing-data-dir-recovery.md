# Missing Data-Dir Recovery

## Context

The **Data Dir** can become unreachable between launches — typically when the user's external drive is unplugged. `DataDirService.probe()` detects this and returns `MissingDataDir(path)`, but the app currently crashes (no UI branch handles that case).

## Goal

When the app boots and finds `MissingDataDir`, the user is shown a recovery dialog before anything else loads. From there they can retry, relocate, or revert to default.

## Approach

### Routing branch

`StartupRouter` (added in New Onboarding) gains a third branch:

```
On boot:
  prefs.onboarding_completed?
    no  → OnboardingScreen
    yes → DataDirService.probe()
            MissingDataDir → MissingDataDirRecoveryScreen
            else           → HomeScreen
```

### Recovery screen

Full-screen modal blocking the home screen. Translated text:

- Headline: "Your mods folder is unavailable"
- Body: "<path> can't be reached. The disk may be unplugged."
- Three buttons:
  - **Retry** → re-runs `probe()`; on success, routes to HomeScreen.
  - **Choose a new location** → folder picker → `DataDirService.setDataDir(<new>)`. **Caveat:** no data is migrated; the previous Game folders are still on the unreachable drive. Warn the user inline.
  - **Use default location** → `DataDirService.setDataDir(null)`. Same data-stranding caveat shown inline.

The "no migration" warning sits visibly above the action buttons; the user understands they'll need to plug the drive back in or move folders manually to recover their packs.

### Service contract

No service changes required — `DataDirService` already exposes `probe()`, `setDataDir()`, and the `DataDirStatus` sealed class.

## Files

- `lib/screens/missing_data_dir_recovery_screen.dart` — new.
- `lib/app.dart` — add the third routing branch.
- `lib/l10n/app_en.arb` + `app_pt.arb` — recovery strings.

## Verification

1. Set `pointer.json` to point at `/nonexistent/path`, ensure `onboarding_completed = true`, launch → recovery screen appears.
2. Click Retry while the path is still missing → stays on recovery.
3. Create the missing directory → Retry → routes to HomeScreen.
4. From recovery, Choose new location → folder picker → pick `/tmp/recover` → pointer updates; HomeScreen loads with empty games list (previous packs not migrated).
5. From recovery, Use default → pointer cleared; HomeScreen loads.
6. `flutter analyze` clean.
