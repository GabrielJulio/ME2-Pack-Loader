# New Onboarding + Startup Routing

## Context

Today the running app still routes through the legacy `SetupBloc`, which checks the `mod_engine_dir` pref and shows an "Choose ModEngine2 folder" picker. That entire path is obsolete — the **Data Dir** + **Pointer config** model from the Data Directory Management service replaces it. Nothing else can flow through the new world until this routing changes.

This is the first task in the UI integration batch (decisions in `refactor.md` D12, D17).

## Goal

A fresh install boots into a new onboarding screen where the user picks the **Data Dir** location (default vs. custom). After picking, the app lands on the home screen. Subsequent launches skip onboarding. `SetupBloc` and its files are gone.

## Approach

### Routing signal

A new `onboarding_completed` bool in `PreferencesService` (default `false`). When true, the router skips onboarding regardless of `DataDirService.probe()`. Set to `true` at the end of the new onboarding flow.

### New onboarding screen (Standalone mode)

Single screen with two big cards/buttons:

- **Use default location** — writes `pointer.json` via `DataDirService.setDataDir(null)`; sets `onboarding_completed = true`.
- **Choose a folder** — opens a system folder picker; on selection, writes via `DataDirService.setDataDir(<path>)`; sets `onboarding_completed = true`.

No disk-space check on first launch (nothing to move yet). Confirmation toast / brief snackbar is fine.

After either choice → app navigates to the home screen (which will show the Multi-Game empty state once that task lands).

### App-level routing

`lib/app.dart` becomes a top-level `StartupRouter` widget:

```
On boot:
  prefs.onboarding_completed?
    no  → OnboardingScreen
    yes → HomeScreen
```

Missing-data-dir recovery is a separate routing branch added by its own task — for this task, treat `MissingDataDir` the same as `CustomDataDir` (the recovery task will intercept it later).

### Legacy cleanup (folded in)

This task also deletes:
- `lib/bloc/setup/` directory (bloc + event + state files)
- `PreferencesService._keyModEngineDir` + `getModEngineDir` / `setModEngineDir`
- `MODENGINE_DIR` env-var dev override in `HomeScreen`

`HomeScreen` loses its `modEngineDir` constructor field. For this task, hardcode the home screen to show a placeholder/empty body until the Multi-Game task wires the real content.

## Files

- `lib/services/preferences_service.dart` — add `getOnboardingCompleted()` / `setOnboardingCompleted(true)`; drop the mod-engine-dir methods.
- `lib/screens/onboarding_screen.dart` — rewrite (default / custom data dir picker).
- `lib/app.dart` — rewrite routing; drop `SetupBloc` provider.
- `lib/screens/home_screen.dart` — drop `modEngineDir` field; placeholder body for now.
- `lib/bloc/setup/` — delete.
- `lib/l10n/app_en.arb` + `app_pt.arb` — new keys for the new onboarding strings.

## Verification

1. Fresh install (delete shared prefs + `pointer.json`) → app boots to new onboarding screen.
2. Click "Use default" → home screen loads; `pointer.json` written with `null`; `onboarding_completed = true`.
3. Restart app → skips onboarding, lands on home screen directly.
4. Click "Choose a folder" → folder picker opens; pick `/tmp/me2-data` → `pointer.json` written with that path; home screen loads.
5. `flutter analyze` clean.
6. `grep -r "SetupBloc\|mod_engine_dir\|MODENGINE_DIR" lib/` → no matches.
