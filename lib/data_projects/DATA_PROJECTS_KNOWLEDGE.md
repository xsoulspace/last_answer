# DATA_PROJECTS_KNOWLEDGE.md

**Owns:** the projects concern — `ProjectModel`/`SaveModel` (ADR 0011
world-model lineage), the projects/tags data sources (interfaces/local) and
repositories, the projects + opened-project + tags + paged-list notifiers,
idea questions, and the legacy Hive/Isar migration with its parsers.

**Key files:** `project_models.dart` (the freezed model library),
`projects_repository.dart` (data + `TagsRepository`), `projects_notifier.dart`
(hot path: every doc save funnels through `updateEditingProject`),
`opened_project_notifier.dart`, `migrations/migrate_from_hive_isar.dart`,
`doc_body_storage.dart` (the `docs/<id>.json` body plane ADR 0002 uses).

**How to extend:** a new project-model field goes in `project_models.dart`
+ `just gen`; a new query verb through `ProjectsRepository`; document
bodies are headless_core territory (ADR 0002) — this folder holds only the
listing stubs and the doc-body path helpers. KNOWN INVERSION to invert
behind an interface: `projects_repository.dart` imports
`ui_settings/features/storage_backends_state.dart`.
