# Boards & tasks: why both exist, and the extraction (revised)

Status: PROPOSAL v2 — revised after owner correction: the package belongs to the
**harness** (`~/xs/ecsai_harness/pkgs/`), it must **use ecsly itself and the other
reusable pieces** (not be a hermetic pure-Dart lib), and it must answer **why
board and tasks logic both exist** before proposing where anything goes.
Date: 2026-11-04. Supersedes v1 of this document (which proposed an
ecsly-plugins/LA-packages pure-Dart extraction — retracted).

## 1. Why we have both board and tasks logic

### Timeline explains the duplication

- **2026-09-26, ADR 0013** (`docs/decisions/0013-mesh-task-board-over-ecsly-world-sync.md`):
  LA builds `MeshTaskBoard` — the only way device A hands work to device B.
  The LAN mesh CRDT was the sole cross-device channel; the harness world was
  machine-local, pre-actor-era, and tasks were not a realm ability yet.
- **2026-10→11, ADRs 0114/0115/0116/0118** (harness): coordination matures into
  ONE realm authority — `RealmControlStore` journal + `DurableTaskQueue`, tasks
  as a realm ability over one uniform verb surface, "one delegation concept
  (create a task and address it)".

The board was invented to fill a hole the queue did not then cover (cross-device).
Once the queue matured, the board became a **second, weaker, parallel
coordination system** — exactly the "second canonical store" ADR 0013 itself
forbade. The implementation violated its own law.

### What each system actually is

| | Realm task queue (`ecsly_tasks`) | LA mesh board (`MeshTaskBoard`) |
|---|---|---|
| Store | journal `durable_tasks/*` in `$worldHome/coordination/` (machine-local) | CRDT doc `task_boards/agent_world.json` (mesh-converged) |
| States | `queued, leased, started, succeeded, failed, cancelled, unknown` | `requested, running, completed, failed` |
| Ids | `task-<sha256(actor|project|requestId)>` | `<docId>#<taskLocalId>`, keys `task/<docId>/<localId>` |
| Acceptance | **frozen check** graded on retained artifact — never self-declared (ADR 0118 D5) | peer-written verdict map |
| Durability | lease + epoch fencing on the execution leg | snapshot-first CRDT absorb |
| Scope | one machine (ADR 0114: "host-local") | many devices offline-first |

### Verdict: what is duplication, what is legitimate

**Duplicated (real):** the concept (work order with claim/run/verdict), the store
(two canonical places defining task truth), and the vocabulary (three delegate
verbs, two state machines, three id schemes). Also duplicated in practice:
LA's `lib/settings/features/supervisor_agent_client.dart:205` still calls
`agent_participation {op:'task_delegate'}` — the post-0118 harness answers
`bounce:'deprecated_verb'` ("create the task instead"). One product path to
realm tasks is **already broken** by the drift.

**Legitimate (keep):**
- *Transport scope.* The journal is one machine; the product is local-first
  multi-device (phone dispatch, desktop runs — the multiplayer gates). Devices
  need an offline-first convergence lane for board state.
- *Acceptance grade.* Realm tasks carry frozen checks; the board's peer
  verdicts are lighter-weight facts.
- *Content vs coordination.* Trello-like planning content (cards, columns,
  plans, decomposition) is **content**, not coordination. Per ADR 0012 the
  writable document is canonical for content; the journal is for coordination
  records. Planning cards must not become journal rows.

**Net answer:** we have both because the board predates the queue and kept
doing transport + store + lifecycle all at once. The fix is not relocating the
board — it is **layering**: one coordination authority, one content substrate,
one ontology package that projects between them.

## 2. Laws that decide the shape

- **ADR 0114** (harness): "Keep one durable ordered coordination authority per
  realm… **The ECS world is a rebuildable execution/projection view**." The
  projection-first role of the board is already written down.
- **ADR 0118 D5** (harness): "One delegation concept (create a task and
  address it)"; the frozen check — never a lease — makes results
  acceptance-grade. No new lifecycle may appear beside `DurableTaskQueue`.
- **ADR 0013** (LA): the board is a durable *projection* of shared work, never
  a second canonical store; dispatch is an op; execution stays with the
  workspace owner.
- **ADR 0012 / NORTH_STAR** (LA): the writable document is canonical for
  content; conversation, task board, permissions are projections. A human
  planning board is a document with structure, synced like every doc.
- **ADR 0116** (harness): "Standalone embeds (Last Answer) get actors, not
  workers. The actor surfaces are Dart libraries first" — LA composes the
  package directly as a library.

## 3. Target architecture

Three layers, only one of which is new:

| Layer | Home | Status |
|---|---|---|
| Coordination authority — `RealmControlStore` + `DurableTaskQueue`, frozen checks | harness `pkgs/ecsly_tasks` | **exists; untouched** (store-pure on purpose; its tests pin the journal frame format) |
| Content substrate — convergence-kernel docs, mesh-synced, local-first | `universal_storage_convergence` + `ecsly_world_sync` | **exists** (the same substrate every LA doc rides) |
| Board/plans **ontology + projection** — ecsly World components, `Plugin`, queue⇄board mapping, sync contract | **NEW harness package** `pkgs/ecsly_boards` | built by this program |

### The new package (`pkgs/ecsly_boards`)

Follows the `ecsly_conversation` precedent (ecsly-typed ontology over ecsly
types; store/host integration lives with the host), not the store-pure
`ecsly_tasks` precedent:

- **Ontology as ecsly components** (`Step`/`Goal` caution: harness
  `xsoulspace_agentic_harness/lib/src/data_models/components.dart` already owns
  execution-scene components, and `ecsly_context` owns `DecompositionAdded`
  events — the ontology must align with, not collide with, these; harness
  ADRs 0009 "goals as vectors, plans as projections" and 0044 "task
  deconstruction as ETL" are the prior art to honor):
  - `board/<id>` metadata, `card/<boardId>/<cardId>` (status, column, rank),
    parent/child decomposition edges, explicit dependency edges, plan
    containers. One LWW op per field.
- **A real ecsly `Plugin`** (`install`/`uninstall`, resources + schedules) so
  the ontology installs on any World — LA, harness inspector, tests.
- **Delegation profile**: mapping between board work-order cards and
  `DurableTaskRecord` (`requested→queued`, `running→started`,
  `completed→succeeded`, `failed→failed`, `cancelled→cancelled`). The queue
  stays the lifecycle authority; the board renders it. Verdict/acceptance
  facts render from `durable_task_results`.
- **Device projection contract**: board state persists as a convergence doc
  (synced over mesh like any doc); remote peers propose ops; the workspace
  owner's harness claims, runs via the queue, and writes results back through
  the same projection. Offline phones keep writing proposed ops — convergence
  merges, the owner applies. This is the current auto-run flow generalized,
  not reinvented.
- **Host seam** (the seam inversion LA needs anyway): `BoardHost` /
  executor interface — claim/run/verdict implemented by the host (LA doc
  surface today; harness actor loops equally able).
- Deps (all existing): `ecsly` (git pin, the established harness route),
  `ecsly_tasks`, `ecsly_world_sync`, `universal_storage_convergence`,
  `ecsly_serialization` (identity model per ecsly ADR 0001).

### What LA deletes / keeps

Deletes: `MeshTaskBoard` (domain moves into the package's projection),
`MeshTaskConsoleView` (dead), the `StorageBackendsNotifier` board singleton,
`AgentDocSurface.meshWiring?.taskBoard` statics as the access path.
Keeps: surfaces (Settings observability, verbs re-wired thin, composer),
`TaskBoardParticipant`-equivalent transport, and the doc surface
*implementing* the package's host seam. The legacy wire shape
(`meshTaskRecordJson`, `AgentDocDebugState.tasks`, `task_boards/*.json`) is
rendered **byte-identically** by the projection until a consciously versioned
contract change updates the frozen gates.

## 4. Migration plan (staged; each landing green before the next)

- **Stage 0 — unblock + characterize.** Migrate
  `supervisor_agent_client.dart` off the retired `task_delegate` verb onto
  `task op:create` / `RealmActorSession` (it is broken against today's
  harness). Golden byte-compat tests for the LA wire shape; existing suites
  (`mesh_task_board_test`, `mesh_storage_task_board_test`,
  `mesh_task_intents_test`) stay green throughout.
- **Stage 1 — package.** `pkgs/ecsly_boards`: ontology components + `Plugin`
  + queue⇄board mapping + host seam, tested against a real journal + World.
  No LA changes yet.
- **Stage 2 — LA adopts.** LA's board becomes the package's projection behind
  the host seam; statics and singleton die; wire goldens keep the multiplayer
  gates green.
- **Stage 3 — collapse.** Delete LA-side domain + dead console; fix the T3
  gate header; the three "task delegate" vocabularies collapse to: realm task
  (authority), board card (projection), chat turn (conversation, stays).
- **Stage 4 — grow.** Plans/decomposition schema v2 + product board UI as an
  LA view; decomposition events aligned with `ecsly_context`
  `DecompositionAdded`; goals/plans aligned with harness ADRs 0009/0044.
  Renames (`agent_world` board id, demo-product "task board" strings) land
  here, as versioned decisions — not cleanup.

## 5. Open decisions

1. **Name**: `ecsly_boards` (recommended) vs `ecsly_plans` vs `ecsly_planning`.
   (`ecsly_tasks` is taken — and must stay the store-pure authority.)
2. **Absorption question**: should `ecsly_tasks` eventually merge into the new
   package? Recommendation: **no** — its zero-dep store purity is load-bearing
   (journal frame format, fencing, guidance are pinned by ~9 test files);
   composition keeps the authority boring.
