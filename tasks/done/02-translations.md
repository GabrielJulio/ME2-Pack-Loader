# 02 — Translations (English + Brazilian Portuguese)

## Context

All user-facing strings are currently hardcoded English. We support two languages: English (default) and Brazilian Portuguese (`pt_BR`, served to any `pt-*` system locale). The app detects the system locale on first launch and stores it as a fixed preference; the user can override in settings later. Beyond the app, the project's README also gets a Brazilian Portuguese translation.

Per [AGENTS.md](../AGENTS.md): game names stay as their official titles in both locales ("Dark Souls III", "Elden Ring", "Dark Souls: Remastered"). Never translated.

## Goal

Translation infrastructure in place + **every existing user-facing string** wrapped via `flutter_localizations` with English and pt-BR translations + `README.pt-BR.md` mirroring `README.md`. This task is *done* when those three things are complete. Strings introduced by later tasks (03–08) are *not* in scope here — each downstream task carries the obligation to extend `app_en.arb` and `app_pt.arb` with its own new keys, per the rule in [AGENTS.md](../AGENTS.md#naming-and-language).

## Approach

### Library: `flutter_localizations` + `intl` + ARB

Aligns with [ADR-0001](../docs/adr/0001-platform-abstraction-order.md) — official Flutter abstraction, no extra runtime dependency. Codegen via `flutter gen-l10n`.

### Files

```
pubspec.yaml                          # add flutter_localizations + intl
l10n.yaml                             # codegen config (arb-dir, template-arb-file, etc.)
lib/l10n/
  app_en.arb                          # English template, source of truth for keys
  app_pt.arb                          # Brazilian Portuguese
```

`app_en.arb` is the template. Each key has an `@key` metadata entry with description for translators. `app_pt.arb` only carries translated values.

### Locale resolution

Two-state preference (`en` or `pt`) — see grilled decision. No "follow system" mode after first launch.

`lib/services/preferences_service.dart`:
- `Future<String?> getLocale()` — returns `en` / `pt` / null.
- `Future<void> setLocale(String code)`.

On app startup:
1. Read prefs.
2. If null (first launch):
   - Inspect `WidgetsBinding.instance.platformDispatcher.locales`.
   - If any matches `pt-*` → store `pt`.
   - Else → store `en`.
3. Pass the stored code as the `Locale` to `MaterialApp.locale`.

### Settings UI

A new "Language" section in settings:
- Two-option selector: "English" / "Português (Brasil)".
- Changing dispatches `LocaleChanged(code)` to a new `LocaleBloc`, which writes prefs and emits a new state. `MaterialApp` rebuilds with the new locale.

### Wrapping existing strings

Every literal in `lib/` that the user sees gets pulled into ARB. Code reads it via `AppLocalizations.of(context).<key>`. Examples to cover (non-exhaustive):
- AppBar title, "Launch Game", "Set up Steam"
- Mod list headers, empty-state copy, tooltips
- Create / Edit / Delete pack dialogs
- Settings labels (Mod Loader, Loose Params, Scylla Hide, Debug Mode)
- Snackbars and validation messages

Keep keys lowerCamelCase and descriptive: `appBarTitle`, `launchGameButton`, `modListEmpty`, etc.

### README translation

- `README.pt-BR.md` — same structure as `README.md`, Brazilian Portuguese.
- Add a language-switcher line near the top of each:
  - In `README.md`: `> Read in [Português (Brasil)](./README.pt-BR.md).`
  - In `README.pt-BR.md`: `> Read in [English](./README.md).`
- Game names, ADR references, file paths, and the term `ModEngine2` stay as-is.

### Knock-on for downstream tasks

Outside this task's "done" scope, but enforced by [AGENTS.md](../AGENTS.md#naming-and-language): every downstream task that introduces user-facing strings (03, 04, 05, 08) must extend both ARB files with its own keys as part of its own implementation, and include "all new strings present in both ARB files" in its own verification list.

## Files

- `pubspec.yaml` — add `flutter_localizations: { sdk: flutter }` and `intl: ^any`. Set `flutter.generate: true`.
- `l10n.yaml` — new.
- `lib/l10n/app_en.arb` — new.
- `lib/l10n/app_pt.arb` — new.
- `lib/app.dart` — wire `localizationsDelegates`, `supportedLocales`, `locale` from `LocaleBloc`.
- `lib/bloc/locale/locale_bloc.dart` (+ event/state) — new.
- `lib/services/preferences_service.dart` — extend with `getLocale` / `setLocale`.
- `lib/widgets/language_selector.dart` — new.
- Every screen/widget under `lib/` that holds user-facing literals.
- `README.pt-BR.md` — new.
- `README.md` — add language-switcher line near the top.

## Verification

1. `LANG=pt_BR.UTF-8 flutter run -d linux` on a fresh install → app launches in Portuguese.
2. `LANG=en_US.UTF-8 flutter run -d linux` on a fresh install → app launches in English.
3. Change to the other language in Settings → all UI text flips immediately, persists across restart.
4. `flutter gen-l10n` runs cleanly, no missing-key warnings.
5. Every string in `lib/` that renders to a user (verified by grep for `Text('...'`, `tooltip:`, `label:`, etc.) is sourced from `AppLocalizations` — no hardcoded user-visible English literals remain.
6. `README.pt-BR.md` exists; structure and section count match `README.md`; language switcher in both.
7. Game names ("Dark Souls III", "Elden Ring", "Dark Souls: Remastered") appear unchanged in both locales.
