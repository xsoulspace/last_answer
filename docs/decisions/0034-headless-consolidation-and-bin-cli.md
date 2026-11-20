# ADR 0034: Headless consolidation and the bin/ CLI

Date: 2026-11-20
Status: accepted
Deciders: owner (directed the consolidation + bin CLI), steward-executed
Extends: ADR 0002 (core extraction — closes its open P4 "agent proposal
flow" and P5 "DocInferencePort adapters" rows)

## Context

ADR 0002's charter — "all headless-capable code lives in one package:
packages/headless_core, pure Dart, no Flutter" — was only partially applied:
the document model and repositories lived there, but large pure-Dart pieces
sat in `lib/` (the perm router, the kernel conversation verbs, the actor
roster, the ACP runtime, the inference ports, the doc-sync participant, the
harness turn model, the agent projections). The mesh-aware repository
carried a mutable static seam (`replicaStoreGetter`) that the app shell set
late — app lifecycle leaking into the pure package. And the headless CLI
existed only as a Flutter-embedded entrypoint (`lib/headless_main.dart`,
which wraps the subscription-credential path in `WidgetsFlutterBinding`).

## Decision

1. **Folder grammar inside headless_core** (same rules as the app):
   `data_models/`, `data_replication/`, `data_storage/`, `data_agents/`,
   `services/`, `workbench/` — folder barrels, top barrel exports only
   folder barrels, `HEADLESS_CORE_KNOWLEDGE.md` documents ownership.
2. **Consolidation moves** (app → headless_core): `permission_doc_router`,
   `actor_roster` (flutter/foundation → package:meta), `kernel_conversation`
   (887 lines, the ADR 0025 thread/beat verbs), `acp_agent_runtime` +
   registry, `acp_doc_inference_port`, `openrouter_doc_inference_port`,
   `chat_permission_policy`, `DocInferencePort` + `ChatMessage` (out of
   packages/core — ADR 0002 P5), the `DocSyncParticipant` adapter, the
   `HarnessTurn`/`TurnToolCall`/`TurnPermission`/`HarnessSessionView`/
   `HarnessWorkspaceView` family, and the `AgentDocDebugState`/
   `AgentDocQueueEntry`/`AgentDocMeshStatus` projections.
3. **Pure discussion laws extracted**: `Discussions.childNode` /
   `Discussions.shouldAbandonOnClimb` (ADR 0001 semantics) in
   headless_core; the doc editor keeps the path-stack orchestration.
4. **Purity fix**: `MeshAwareDocumentRepository.replicaStoreGetter` static
   deleted; replaced by an injected `DocReplicaStoreRef` (mutable ref the
   mesh owner fills). No static state in the package.
5. **Top-level `bin/` CLI** (like `tool/`): `bin/doc_cli.dart` runs the
   document/kernel surface — filesystem-backed `StorageDocumentRepository`,
   `DocReplicaStore`, workbench verbs, ACP agents — importing ONLY
   headless_core (+ published pure deps). **Law: `bin/` never imports
   `package:lastanswer` or Flutter**, enforced by a gate.
6. **Two documented CLI tiers** (docs/product/headless-cli.md): the pure
   `bin/` CLI (document domain, no accounts) and the native Flutter CLI
   (`lib/headless_main.dart`, plugin-backed protected account store +
   subscription transports).

## Deviations found during execution (recorded honestly)

- `headless_product_cli.dart` STAYS in the app: its transitive closure
  imports the subscription gateways (`chatgpt_credentials`, `grok_credentials`
  — Flutter via the protected store) and the product tooling
  (`product_autonomy`, `product_workspace_tooling` — Flutter). The pure CLI
  tier speaks the document/ACP surface instead; a future dependency-inverted
  CLI protocol could revisit this.
- `AgentDocShadow` + `AgentDocMeshWiring` stay app-side: their default
  fallbacks read `AgentDocSurface.meshWiring` and the mesh task board
  (`MeshTaskRecord`). Moving them needs the wiring-static inversion —
  follow-up, not a blocker (the moved projections are the shared
  vocabulary the CLI needs).

## Consequences

- The bin CLI gets the full document domain + ACP agent path with zero
  Flutter; ADR 0002's headless story (TUI/CLI/serve) is unblocked.
- headless_core gains pure dependencies: `dart_acp_toolkit`,
  `xsoulspace_agentic_host`, `xsoulspace_inference_acp`,
  `xsoulspace_inference_core`, `xsoulspace_inference_openrouter`,
  `xsoulspace_permission_core`, `universal_storage_mesh`.
- `packages/core` shrinks (doc inference port leaves; the dead
  `ChatDocumentService` provider is cut); its full dissolution is ADR 0035.
- Import law: `bin/` and `lib/` both consume `package:headless_core/…`
  through the barrel; nothing in headless_core points back.

## Falsifiers

If `bin/` scripts keep needing app-side types (the law keeps breaking), the
domain boundary is wrong — either more domain moves into headless_core or
the CLI surface is over-scoped. If headless_core's new dependencies grow
Flutter-ward over time, the consolidation captured a transport layer that
belongs behind a port instead.
