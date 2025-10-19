[1 tool called]

### Handover plan — extract parsers, make `migrate()` the runtime loader (ready for another agent)

Goal (one line)

- Parse on-disk production/archive Isar/Hive files at app startup (via `migrate()`), convert to the app’s existing model JSON, and surface them through the existing Local DB path (`ProjectsLocalDataSourceLocalDbImpl`), removing runtime Hive/Isar dependency later.

Status (what I already changed)

- Implemented a lightweight parser facade and runtime wiring:

        - `lib/parsers/parsers.dart` — `parseAndPopulate()` & `parseProjectsFromPaths()` (parses `.isar`/`.hive` previews and stores JSON project entries to SharedPreferences key `webProjects`).

        - `packages/core/lib/src/state_di/migrator.dart` — now calls `parsers.parseAndPopulate()`.

        - `packages/core/lib/src/state_di/path_utils.dart` — `determineDbPaths()` extracted (platform path resolution).

        - `packages/core/lib/src/state_di/global_states_initializer.dart` — removed `complexLocalDb.open()` and calls `await migrate();` before `localDb` load.

        - `packages/core/lib/src/data_repositories/projects_repository.dart` — uses `ProjectsLocalDataSourceLocalDbImpl` by default.

        - Provider registrations left Isar available but registered `SharedPreferencesDbDataSourceImpl` as the `LocalDbDataSource` provider so `ProjectsLocalDataSourceLocalDbImpl` reads `SharedPreferencesKeys.webProjects`.

- TODO list in repo updated; core parser code and light integration implemented.

Why this shape

- The app already serializes full models to JSON (`jsonContent`) and repositories use `ProjectModel.fromJson(...)`. The shortest safe path is to produce those JSON entries and let the existing local-db implementation ingest them (no deep Isar compatibility shim needed).

Files to read immediately (hand-over checklist)

- parser entry: `lib/parsers/parsers.dart`

- isar/hive raw parsing helpers: `lib/parsers/isar_parser.dart`, `lib/parsers/hive_parser.dart`, `lib/parsers/byte_utils.dart`

- migrator entry: `packages/core/lib/src/state_di/migrator.dart`

- path resolution: `packages/core/lib/src/state_di/path_utils.dart`

- global init: `packages/core/lib/src/state_di/global_states_initializer.dart`

- DI/providers: `packages/core/lib/src/state_di/global_states_provider.dart`

- Local web-backed datasource: `packages/core/lib/src/data_sources/local/projects_web.dart`

- SharedPreferences adapter: `packages/core/lib/src/data_sources/local/shared_preferences_db.dart`

- Projects repository: `packages/core/lib/src/data_repositories/projects_repository.dart`

- Parser tests (move/add): `test/parsers/` (not created yet — see tasks)

High-level handover tasks (ordered, with acceptance criteria & estimate)

1) Finish parser → LocalDb integration (priority: high, 1–2 days)

    - Task: Ensure `parseAndPopulate()` discovers the right platform paths via `determineDbPaths()` and writes normalized `ProjectModel.toJson()` strings into `SharedPreferences` key `webProjects`.

    - Files: `lib/parsers/parsers.dart`, `packages/core/lib/src/state_di/path_utils.dart`, `packages/core/lib/src/state_di/migrator.dart`

    - Acceptance: After `await migrate()` runs, `SharedPreferences.getStringList('webProjects')` contains JSON strings; `ProjectsRepository.getPaginated()` returns expected `ProjectModel` items.

    - Notes: Keep parsing streaming-friendly; avoid loading large DBs into RAM.

2) Add unit tests for parsers and fixtures (priority: high, 1 day)

    - Task: Add fixtures (small `.isar` and `.hive` test files) and unit tests:

            - `test/parsers/isar_parser_test.dart` — asserts `parseIsarFromBytes()` returns `jsonObjectsPreview` including model-like maps.

            - `test/parsers/hive_parser_test.dart` — asserts `parseHiveFromBytes()` yields expected maps/strings.

    - Acceptance: Unit tests pass locally and in CI.

3) Add integration test for `migrate()` parity (priority: high, 1–2 days)

    - Task: Create an integration test that:

            1. Installs test fixtures into the runtime-relevant directory (use `determineDbPaths()`).

            1. Runs `await migrate();`

            1. Asserts `SharedPreferences.getStringList('webProjects')` populated and `ProjectsRepository.getPaginated()` returns models matching golden JSON.

    - Files: add `test/integration/migrate_integration_test.dart`

    - Acceptance: Integration test passes in CI runner.

4) Provider / DI cleanup & feature flag (priority: medium, 0.5–1 day)

    - Task: Add a boolean feature flag `use_isar_runtime` (default false). If true, use `ComplexLocalDbIsarImpl` and existing Isar path; if false, use `SharedPreferencesDbDataSourceImpl` + `ProjectsLocalDataSourceLocalDbImpl`.

    - Files: `packages/core/lib/src/state_di/global_states_provider.dart`, some `Envs` or `AppFeaturesNotifier` flag.

    - Acceptance: Toggling flag re-enables original behaviour without code revert.

5) CI integration (priority: medium, 0.5 day)

    - Task: Add a CI job that:

            - Runs parser unit tests.

            - Runs the integration migrate test (small fixture).

    - Commands: `flutter test test/parsers/` and `flutter test test/integration/migrate_integration_test.dart`

    - Acceptance: CI green.

6) Remove runtime Hive/Isar deps (final step, gated, low priority)

    - Task: After verification in staging, remove `hive_ce`, `hive_ce_flutter`, and `isar` from `pubspec.yaml` and delete legacy Hive-only code paths behind feature flag branch.

    - Acceptance: build succeeds and integration tests pass with new path.

Implementation details / dev notes for agent

- Parsing output shape:

        - Produce `ProjectModel.toJson()` maps encoded with `jsonEncode()`; save each as a string into `SharedPreferences.setStringList('webProjects', [...])`.

        - `ProjectsLocalDataSourceLocalDbImpl` reads via `localDb.getItemsIterable(key: SharedPreferencesKeys.webProjects.name, convertFromJson: ProjectModel.fromJson)`. Ensure the JSON shape matches `ProjectModel.fromJson`.

- Discovery of DB files:

        - Use `determineDbPaths()` to list candidate directories; iterate files ending `.isar` and `.hive`.

- Resource constraints:

        - Implement streaming traversal for large files where possible; tests will include small fixture files.

- Logging:

        - Keep robust error handling; do not throw fatal errors for unparseable frames — record and continue.

Acceptance criteria (handover)

- `parseAndPopulate()` is deterministic and reproducible on CI/dev.

- Unit tests exist and pass for parser helpers.

- Integration test validates `migrate()` outputs used by `ProjectsRepository`.

- Feature flag allows quick rollback to Isar runtime.

- Documentation: small README paragraph in `lib/parsers/README.md` explaining how to run `migrate()` locally and what `webProjects` contains.

Commands & quick checks for the agent

- Run unit tests: `flutter test test/parsers/`

- Run integration test: `flutter test test/integration/migrate_integration_test.dart`

- Manual check after running app (dev): open Dart VM/DevTools or log `SharedPreferences.getStringList('webProjects')` after startup to verify items exist.

Files changed so far (for reference)

- `lib/parsers/parsers.dart` (new / parser facade)

- `lib/parsers/isar_parser.dart`, `lib/parsers/hive_parser.dart`, `lib/parsers/byte_utils.dart` (parsers exist)

- `packages/core/lib/src/state_di/migrator.dart` (calls parseAndPopulate)

- `packages/core/lib/src/state_di/path_utils.dart` (determineDbPaths)

- `packages/core/lib/src/state_di/global_states_initializer.dart` (migrate() earlier)

- `packages/core/lib/src/state_di/global_states_provider.dart` (provider adjustments)

- `packages/core/lib/src/data_repositories/projects_repository.dart` (use LocalDb datasource)

- `packages/core/lib/src/data_sources/local/shared_preferences_db.dart` (already present; used)

Deliverables to hand off

- Implemented parser code + tests (unit + integration).

- CI job to run parser tests + migrate sanity check.

- Short README: how to run `migrate()`, where outputs are saved, test commands.

Risks & mitigation (short)

- Query mismatch: implement string-based `jsonContent` search as in `projects_web.dart` and test wildcard search behavior.

- Large files: add streaming traversal or limit preview extraction; add test that verifies memory use on big fixtures.

Who to contact in repo (if agent needs context)

- Inspect `projects_web.dart` for expected search and pagination semantics.

- Inspect `ProjectsLocalDataSourceLocalDbImpl` (already wired to `SharedPreferences` key `webProjects`).

Next recommended immediate work for the agent you hand to

1. Add parser unit tests and minimal fixtures.

2. Implement `test/integration/migrate_integration_test.dart`.

3. Add CI job to run those tests.

4. Add `use_isar_runtime` feature flag and wire provider selection.

Grammar fix (one-line)

- "please create a plan, so i would be able to hand the work over to other agent" → "Please create a plan so I can hand the work over to another agent."

Prompt suggestion (copy-paste for future handoffs)

- "Create unit and integration tests for the Isar/Hive parsers: include small `.isar` and `.hive` fixtures, run `migrate()` in an integration test, then assert `ProjectsRepository.getPaginated()` returns models matching golden data; add a CI job to run these tests."

If you want I can now:

- implement the parser unit & integration tests and the CI job (next obvious step), or

- create the short README and the `use_isar_runtime` feature-flag scaffolding. Which do you want me to do first?