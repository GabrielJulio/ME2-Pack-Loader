# Tasks

## Phase 0 — Project Setup
- [x] Run `flutter create` scaffold (Linux only)
- [x] Add dependencies: `flutter_bloc`, `toml`, `file_picker`, `shared_preferences`, `path`
- [x] Set up folder structure (`models/`, `services/`, `bloc/`, `screens/`, `widgets/`, `utils/`)

## Models
- [x] `Mod` model with `copyWith`
- [x] `GameConfig` model with `copyWith`

## Services
- [x] `slugify` utility (`utils/slugify.dart`)
- [x] `preferences_service.dart` — store/retrieve ModEngine2 folder path and one-time flags
- [x] `config_service.dart` — resolve config file, read TOML, write TOML, touch timestamp, create default
- [x] `mod_service.dart` — create/delete folder, check empty, import files, check slug uniqueness

## BLoC — Setup
- [x] `setup_event.dart`
- [x] `setup_state.dart`
- [x] `setup_bloc.dart`

## BLoC — Config
- [x] `config_event.dart`
- [x] `config_state.dart`
- [x] `config_bloc.dart` (load, all CRUD events, each writes to disk immediately)

## Screens
- [x] `onboarding_screen.dart` — first-run folder picker
- [x] `home_screen.dart` — sidebar + mod list layout
- [x] `steam_setup_screen.dart` — placeholder Steam launch command instructions

## Widgets
- [x] `settings_panel.dart` — mod loader, loose params, scylla hide, debug toggles
- [x] `mod_list.dart` — ReorderableListView
- [x] `mod_list_tile.dart` — toggle, name, empty warning, edit/delete buttons, drag handle
- [x] `create_edit_mod_dialog.dart` — name, slug preview, uniqueness check, file import
- [x] `delete_mod_dialog.dart` — confirmation dialog
- [x] `external_dll_list.dart` — add, remove, reorder DLLs

## App Wiring
- [x] `main.dart` — startup: check prefs, touch timestamp, route to onboarding or home
- [x] `app.dart` — MaterialApp setup

## Major Milestones
- [ ] First run: onboarding → folder selection → loads real config  *(code complete — needs test run)*
- [ ] Mod CRUD fully working end-to-end  *(code complete — needs test run)*
- [ ] TOML written correctly on every change  *(code complete — needs test run)*
- [x] Multiple UI layout options
- [x] Add Gnome Layout
- [x] All Layouts must be Dark themed
- [x] AppImage build for Linux  *(script at `scripts/build_appimage.sh` — needs icon at `packaging/me2_pack_loader.png`)*

## Freezed
- [ ] Dark Souls 3 — full support
- [ ] Bazzite — tested and supported
- [ ] Auto-update via GitHub releases (AppImage)
- [ ] Windows build support
- [ ] Elden Ring — support
