# Tasks

## Phase 0 — Project Setup
- [ ] Run `flutter create` scaffold (Linux only)
- [ ] Add dependencies: `flutter_bloc`, `toml`, `file_picker`, `shared_preferences`, `path`
- [ ] Set up folder structure (`models/`, `services/`, `bloc/`, `screens/`, `widgets/`, `utils/`)

## Models
- [ ] `ModEntry` model with `copyWith`
- [ ] `ModEngineConfig` model with `copyWith`

## Services
- [ ] `slugify` utility (`utils/slugify.dart`)
- [ ] `preferences_service.dart` — store/retrieve ModEngine2 folder path and one-time flags
- [ ] `config_service.dart` — resolve config file, read TOML, write TOML, touch timestamp, create default
- [ ] `mod_folder_service.dart` — create/delete folder, check empty, import files, check slug uniqueness

## BLoC — Setup
- [ ] `setup_event.dart`
- [ ] `setup_state.dart`
- [ ] `setup_bloc.dart`

## BLoC — Config
- [ ] `config_event.dart`
- [ ] `config_state.dart`
- [ ] `config_bloc.dart` (load, all CRUD events, each writes to disk immediately)

## Screens
- [ ] `onboarding_screen.dart` — first-run folder picker
- [ ] `home_screen.dart` — sidebar + mod list layout
- [ ] `steam_setup_screen.dart` — placeholder Steam launch command instructions

## Widgets
- [ ] `settings_panel.dart` — mod loader, loose params, scylla hide, debug toggles
- [ ] `mod_list.dart` — ReorderableListView
- [ ] `mod_list_tile.dart` — toggle, name, empty warning, edit/delete buttons, drag handle
- [ ] `create_edit_mod_dialog.dart` — name, slug preview, uniqueness check, file import
- [ ] `delete_mod_dialog.dart` — confirmation dialog
- [ ] `external_dll_list.dart` — add, remove, reorder DLLs

## App Wiring
- [ ] `main.dart` — startup: check prefs, touch timestamp, route to onboarding or home
- [ ] `app.dart` — MaterialApp setup

## Major Milestones
- [ ] First run: onboarding → folder selection → loads real config
- [ ] Mod CRUD fully working end-to-end
- [ ] TOML written correctly on every change
- [ ] AppImage build for Linux
- [ ] Auto-update via GitHub releases (AppImage)
- [ ] Windows build support
- [ ] Multiple UI layout options
- [ ] Dark Souls 3 — full support
- [ ] Elden Ring — support
- [ ] Bazzite — tested and supported
