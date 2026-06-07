# Refactor log — decisions taken while executing tasks 03–08

A running list of branch points hit while restructuring the code. Each entry shows the possibilities considered and the decision actually taken. Override any of these by editing the table — the next pass will re-read this file.

---

## D5 — Replace or repurpose `SetupBloc`?

Today's `SetupBloc` checks if a "ModEngine2 folder" pref is set and routes to onboarding or home. Task 03 makes that pref obsolete — the data-dir pointer replaces it.

| Possibility | What it means |
|---|---|
| **(a) Remove `SetupBloc` entirely** | ✓ TAKEN. App reads `DataDirService.probe()` at startup; routes to onboarding if `DefaultDataDir` + no games activated, recovery dialog if `MissingDataDir`, else home. Simpler — one source of truth. |
| (b) Repurpose `SetupBloc` as a `StartupBloc` | Same logic wrapped in a bloc. Keeps the pattern. Slight indirection cost. |

**Decision taken: (a).** Removing `SetupBloc`; routing decision lives in a small startup widget that consults `DataDirService` + `PreferencesService.getActivatedGames`.

---

## D6 — Where do "Move data dir" + "Language" + future app prefs live?

There's no dedicated settings screen yet. Today the GNOME layout has an About page; the Material layout has a sidebar with ModEngine2-specific toggles. App-level settings (data dir, language, eventually Steam command revisit) need a home.

| Possibility | Layout |
|---|---|
| **(a) New `AppPreferencesScreen` reachable from a gear icon in the AppBar** | ✓ TAKEN. One screen, both layouts, sections: Storage / Language / About. Discoverable. |
| (b) Inline into existing layouts | Material sidebar grows; GNOME About page grows. Inconsistent across layouts. |
| (c) GNOME-only via the existing About page; Material gets no UI for these | Saves work but Material users can't move data dir. |

**Decision taken: (a).** New `AppPreferencesScreen` with a gear icon in the AppBar. The existing ModEngine2-toggles `SettingsPanel` stays where it is (it's per-pack config, not app prefs).

---

## D7 — What does `initializeGameFolder` (passed to `GameBloc`) actually do?

When a user activates a game for the first time, the game folder gets created. The bloc calls `initializeGameFolder(dir)` to seed it.

| Possibility | Behaviour |
|---|---|
| **(a) Always create `default.toml` + activate it (copy to `config.toml`)** | ✓ TAKEN. First activation always lands the user in a working state with one pack ready. |
| (b) Only create `default.toml`; user must click to activate | More clicks but more transparent. |
| (c) Detect existing TOMLs in the folder and activate the most-recent | Migration-friendly. Skipped per Q3=A (no migration). |

**Decision taken: (a).** Game activation creates `default.toml` AND mirrors it to `config.toml`. Lives in `GameFolderInitializer` that uses `PackService.create` + `PackService.activate` + the `defaultPackContent` constant.

---

## D8 — How invasive is the `ConfigBloc` rework for task 05?

`ConfigBloc` today loads/mutates one TOML. After task 05 it needs to handle multi-pack state.

| Possibility | Approach |
|---|---|
| **(a) Extend `ConfigBloc`** | ✓ TAKEN (confirmed by Q2). State adds `packs`, `editingPackSlug`, `activePackSlug`. Existing mutation events apply to the editing pack. MVP-scoped: editing == active for now (only auto-loaded default pack), multi-pack UI is a later slice. |
| (b) Split into `PackBloc` + `EditorBloc` | Rejected per Q2. |

**Decision taken: (a).** Extended with `packSlug` for now. Mutations write to both `<slug>.toml` and `config.toml`. Multi-pack list UI deferred to a follow-up slice.
