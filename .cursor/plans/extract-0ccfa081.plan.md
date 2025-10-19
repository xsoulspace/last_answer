<!-- 0ccfa081-73b0-4211-9cbf-aab78eb6470e 4aeccc2e-e2eb-4716-a06a-d9c19c5a0bcf -->
# Extract parsers into packages/parsers and make migrate() the runtime parser

## Overview

Extract existing Isar/Hive parsing logic into a small library package `packages/parsers` and make `migrate()` the single in-app entrypoint that locates archive DB files, parses them, and populates the app's local data structures before the UI starts. Archives are assumed identical to production files and tags may be ignored (data is in `jsonContent`).

## Assumptions (confirmed)

- Archive files are identical to production files. (you chose: a)
- Tags can be ignored for migration because the full model JSON is saved in `jsonContent`.

## High-level approach

- Create `packages/parsers` (library-only) and move `lib/parsers/*.dart` there. Expose a concise API:
- `Future<void> parseAndPopulate({required ComplexLocalDb targetDb})`
- `Future<List<Map<String,dynamic>>> parseProjectsFromPaths(List<String> paths)`
- Reuse and extract path resolution logic from `packages/core/lib/src/state_di/migrator.dart` into `packages/core/lib/src/state_di/path_utils.dart` with `List<String> determineDbPaths()` so both the parser library and `migrate()` use the same rules.
- Make `migrate()` call `packages/parsers.parseAndPopulate(...)` which will parse Isar/Hive archives and populate a small `ComplexLocalDbLocalImpl` (in-memory or JSON-backed) that satisfies `ComplexLocalDb`.
- Modify DI/provider registration so `ComplexLocalDb` resolves to `ComplexLocalDbLocalImpl` at runtime (non-web) or allow a feature-flag to keep Isar runtime temporarily.
- Edit `packages/core/lib/src/state_di/global_states_initializer.dart` to remove `await dto.complexLocalDb.open();` and call `await migrate();` before `dto.localDbDataSource.onLoad();` so local datasources see parsed data.
- Keep `ProjectsRepository` behavior unchanged at call sites: it will still call `getAll`, `getPaginated`, and `fromJson` — the parser must produce `ProjectModel` JSON compatible with `ProjectModel.fromJson()`.

## Concrete file targets & minimal edits (what to change)

- Move parser source
- Move: `lib/parsers/isar_parser.dart`, `lib/parsers/hive_parser.dart`, `lib/parsers/byte_utils.dart`, `lib/parsers/__init.dart`, `lib/parsers/README.md` → `packages/parsers/lib/`
- Extract path helper
- New: `packages/core/lib/src/state_di/path_utils.dart` — implement `List<String> determineDbPaths()` extracted from `migrator.dart`'s platform logic.
- Parser library
- New: `packages/parsers/lib/parsers.dart` exporting `parseAndPopulate` and `parseProjectsFromPaths`.
- Migrate (runtime loader)
- Edit: `packages/core/lib/src/state_di/migrator.dart` — replace file-reading stub with call to `packages/parsers.parseAndPopulate(targetDb: context.read<ComplexLocalDb>() /* or provide target */)`; ensure it returns after population.
- Global initializer
- Edit: `packages/core/lib/src/state_di/global_states_initializer.dart` — remove `await dto.complexLocalDb.open();` and call `await migrate();` before `dto.localDbDataSource.onLoad();`.
- DI/provider registration
- Edit: `packages/core/lib/src/state_di/global_states_provider.dart` — register `ComplexLocalDbLocalImpl` (new) for non-web platforms or make provider select between `ComplexLocalDbLocalImpl` and `ComplexLocalDbIsarImpl` behind a flag.
- Local DB adapter
- New: `packages/core/lib/src/data_sources/local/local_db_impl.dart` (or adapt existing LocalDb implementation) that `parseAndPopulate` will populate (it must expose the same methods repositories expect or allow repositories to use LocalDb datasource).
- Tests
- Move/adjust tests from `test/parsers/*` → `packages/parsers/test/` and add integration tests validating `migrate()` parity with current Isar reads.

## Data mapping rules (must preserve app semantics)

- For each project produced by the parser, ensure either:
- produce a `Map<String,dynamic>` identical to `ProjectModel.toJson()` so callers use `ProjectModel.fromJson(...)` as today, or
- populate target `ComplexLocalDb` so that `ProjectsRepository` queries (via `ProjectsLocalDataSourceLocalDbImpl`) return `ProjectModel` objects.
- Preserve ID strings: use `modelIdStr` (or Hive keys) for `ProjectModelId.value`.
- Preserve `jsonContent` semantics: store `jsonEncode(project.toJson())` if populating a wrapper similar to Isar's `ProjectIsarCollection`.
- Tags can be ignored for storage because filtering uses `jsonContent` and repositories parse models from JSON.

## Tests and acceptance criteria

- Unit tests: parser library must parse sample `.isar` and `.hive` archive fixtures into `ProjectModel` JSON that equals models produced by current Isar runtime.
- Integration test: calling `migrate()` at app startup results in `ProjectsRepository.getAll()` and `getPaginated()` returning the same values as the current Isar runtime path (search, pagination and sort semantics must match).
- CI: add a job that runs parser unit tests and a quick `migrate()` sanity check on CI runner (use small fixtures).

## Rollback / feature-flagging

- Add a boolean feature flag `use_isar_runtime` (default `false` for rollout). When `true` keep current Isar runtime path.
- Keep Isar/Hive code in the repo until CI and staging prove parity; remove deps only after full verification.

## Risks & mitigations

- Query semantics differences (Isar `jsonContentMatches`) — mitigation: implement search using `jsonContent` string matching in local implementation or ensure `ProjectsLocalDataSourceLocalDbImpl` can run equivalent filters.
- Large DB files — mitigation: use streaming parsing and incremental population; do not decode entire DB into memory at once.

---

I will now create a short, ordered todo list for implementation if you want me to proceed with edits.

### To-dos

- [ ] Create `packages/parsers` library and move `lib/parsers/*` into it, export parsing API
- [ ] Create `packages/core/lib/src/state_di/path_utils.dart` and implement `determineDbPaths()` (extract logic from `migrator.dart`)
- [ ] Implement `parseAndPopulate` and `parseProjectsFromPaths` in `packages/parsers` to produce ProjectModel JSON or populate a `ComplexLocalDbLocalImpl`
- [ ] Add `ComplexLocalDbLocalImpl` or adapt existing LocalDb impl to accept parsed data and expose query methods used by repositories
- [ ] Change `packages/core/lib/src/state_di/migrator.dart` to call `packages/parsers.parseAndPopulate(...)` and return after population
- [ ] Edit `packages/core/lib/src/state_di/global_states_initializer.dart` to remove `await dto.complexLocalDb.open();` and call `await migrate();` before `dto.localDbDataSource.onLoad();`
- [ ] Update `packages/core/lib/src/state_di/global_states_provider.dart` to register `ComplexLocalDbLocalImpl` for runtime (or select via feature flag)
- [ ] Move/update parser tests to `packages/parsers/test/`, add integration tests for `migrate()` parity, and add CI job for parser sanity checks
- [ ] After verification, remove Hive/Isar runtime deps from `pubspec.yaml` and delete legacy Hive code behind feature-flag branch