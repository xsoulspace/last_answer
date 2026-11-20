<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# HEADLESS_CORE_KNOWLEDGE.md

The pure-Dart domain core: the recursive document model (ADR 0001), its
storage repositories (ADR 0002), the doc↔kernel replication layer (ADR 0005),
and the agent transports (ACP runtime, inference ports, permission routing).
**No Flutter dependencies** — consumed by the app (`lib/`, `packages/core`
wiring), the headless `bin/` CLI (ADR 0034), and tests.

## Folder grammar (mirrors lib/, ADR 0034)

| Folder                  | Owns                                                  | Key files                                                                                                                                                                                                                              |
| ----------------------- | ----------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `lib/data_models/`      | Serializable domain value types                       | `document_node.dart` (ADR 0001), `perm_request.dart`, `actor_roster.dart` (ADR 0007), `harness_turn.dart`, `agent_doc_projections.dart`, `discussions.dart`                                                                            |
| `lib/data_replication/` | The doc↔op layer over `universal_storage_convergence` | `doc_replica.dart` (ADR 0005 lane map — wire-stable, never rename casually), `doc_replica_store.dart`, `mesh_aware_document_repository.dart`, `doc_sync_participant.dart`                                                              |
| `lib/data_storage/`     | The repository ladder                                 | `document_repository.dart` (interface), `storage_document_repository.dart`, `in_memory_document_repository.dart`                                                                                                                       |
| `lib/data_agents/`      | Agent transports + the doc inference port             | `acp_agent_runtime.dart`, `acp_agent_runtime_registry.dart`, `doc_inference_port.dart` (ADR 0002 P5), `acp_doc_inference_port.dart`, `openrouter_doc_inference_port.dart`, `chat_permission_policy.dart`, `permission_doc_router.dart` |
| `lib/services/`         | Orchestration over the domain                         | `chat_document_service.dart`, `document_agent_service.dart`, `headless_agent_harness.dart` (scripted engine), `kernel_conversation.dart` (ADR 0025 thread/beat verbs)                                                                  |
| `lib/workbench/`        | Workbench verbs (proposal/adopt/undo)                 | `workbench.dart`                                                                                                                                                                                                                       |

Barrels are the public API: each folder has one, and `lib/headless_core.dart`
exports only the folder barrels. Deep imports across folders are illegal
(relative imports reach only within a folder).

## Laws

- **Flutter-free.** `package:flutter/` must never appear here (verify with
  `grep -r "package:flutter/" lib/` — the bin-gates rule depends on it).
- **Wire stability.** Lane registry names in `doc_replica.dart` and the
  persisted JSON shapes are contracts across replicas; changes need an ADR
  and a migration story.
- **No app imports.** Nothing here imports `package:lastanswer` — the
  dependency points the other way. App-side pure logic that the domain needs
  moves HERE, not the reverse.
- **Late-bound seams, never statics.** Mutable app wiring (e.g. the mesh
  replica store arriving after the provider tree builds) is injected — see
  `DocReplicaStoreRef`; no static getter seams.

## How to extend

- New serializable value type → `data_models/`.
- New kernel-doc lane or sync behavior → `data_replication/` (+ ADR if the
  wire shape changes).
- New agent transport (a new backend) → `data_agents/` implementing
  `DocInferencePort` or joining `AcpAgentRuntime`.
- The scripted engine for tests/CLI is `HeadlessAgentHarness` +
  `InMemoryDocumentRepository` (see `test/` for the construction recipe).
