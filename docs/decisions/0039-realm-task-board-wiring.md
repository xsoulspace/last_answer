# ADR 0039: Realm task board wiring — one substrate, two projections, issuance parity

- Status: Accepted; stages 1–4 landed (uncommitted dev at the time of writing).
- Date: 2026-11-23
- Decision-maker: user, in review of the board↔agent-task wiring analysis.
- Amends: [0013](0013-mesh-task-board-over-ecsly-world-sync.md) (board = projection, dispatch is an op); [ecsly-boards-extraction](../design/ecsly-boards-extraction.md) (stages 2/3 split across this ADR and the parallel merge lane).

## Context

The app shipped three disjoint task substrates: the realm durable queue
(`durable_tasks` in the `RealmControlStore` journal — what every `task
op:create` writes), the `MeshTaskBoard` CRDT (peer doc-turn delegation),
and the `PlanningBoardReplica` CRDT (the Boards tab grid). Everything an
agent issued landed in the queue, which the board never rendered; the
board's planning cards were writable by no agent verb. The Boards tab
said so itself: "the durable task queue is not on this board (the
harness feed is unwired)". The queue→card feed (ADR 0140,
`task_row_feed.dart` + the host's `JournalTaskRowSource`) was
landed-but-unwired.

## Decision

One substrate, two projections, issuance parity — implemented in four
stages, under three owner decisions:

1. **Workspace scoping is a FILTER, never separate boards** (owner):
   all tasks live on one substrate; "all / per workspace" is a view
   choice.
2. **ACP delegated turns stay honest-but-invisible** (owner): they are
   never queue rows, but carry a DIRECT LINK to the session (the doc
   whose bridge served the turn, stamped into the settlement verdict).
3. **Quick win first; duplicate-collapse in parallel** (owner): the
   feed/render wiring landed first; a parallel lane extracted
   `LwwReplicaCore` and rebased both CRDT replicas onto it (extraction
   stages 2/3 storage slice, byte-identical wire, goldens green).

### Stage 1 — the coordination board (the quick win)

The durable queue is RENDERED, not mirrored: `RealmTaskBoard`
(`lib/ui_boards/realm_task_board.dart`) reads the `WorldTaskRow`s the
world-state service already folds from `durable_tasks`
(`world_state_service.dart` — the same journal the daemon and every
seat write), and renders them in the FIVE canonical lanes of
`BoardTaskStatus` via `cardStatusOfQueue` (the ONE-vocabulary law:
queue words never leak; `unknown` renders `failed` — an unproven
outcome is a visible failure). The honest banner is gone. The old
`BoardTaskStatus` World+feed path (`TaskRowFeedResource` over
`JournalTaskRowSource`) stays the post-merge route for when cards must
live in one ecsly World with decomposition edges — it is deliberately
NOT installed now: rendering from the journal projection creates no
third store.

### Stage 2 — the configurable view

Workspace filter (`all workspaces` / per `projectId` — the join rides
new additive `WorldTaskRow.projectId`), origin attribution (`by
<actorId> · to <addressees> · @<project>` on every row — who announced
it, who works it), all as view state. Planning cards keep their
fractional-rank lanes; mesh rows keep their section.

### Stage 3 — attention as a preset

"Requires attention" is a filter over the same rows: non-terminal
tasks, durable cancels riding live work (`cancelRequested` — an
attention fact, kept visible), and unproven settlements (`unknown`).
The landing inbox keeps its list role; the board is the lane-shaped
projection of the same journal. Neither is canonical.

### Stage 4 — issuance parity

- **Delegate from a card** (ADR 0013: dispatch is an op): a planning
  card row gains a quiet delegate op when the shell mounts the seam;
  the seam admits the card through the app's OWN harness seat
  (`SupervisorService.resolveAgentClient` → `task op:create` — no new
  world, no new identity). Provenance (cardId→taskId) rides an
  app-side ledger (`BoardDelegationLedger`, SharedPreferences) —
  deliberately NOT a replica field: the planning wire is byte-frozen
  and planning cards must not become journal rows. A refusal renders
  in words; the board never claims a delegation the world did not
  admit.
- **ACP session links** (owner decision 2): the bridge stamps the
  serving `docId` into the settlement verdict
  (`mesh_board_bridge.dart`); the mesh section renders a direct link
  that opens the `doc:<docId>` tab. No docId in the verdict, no link —
  nothing invented.

## Laws preserved

- The queue is the lifecycle authority; a card renders it, never
  invents truth (ADR 0013, `task_card_mapping.dart` authority law).
- Planning cards do not become journal rows (extraction doc law).
- No accept/claim verbs on the agent surface (ADR 0118): the delegate
  op ADMITS work; the queue's own leases staff it.
- The board never dispatches by itself: no seam mounted, no op
  rendered.
- Absorb, never rename: the mesh `task/<docId>/<localId>` keys and the
  additive `realm-task/<taskId>` namespace keep resolving forever; this
  ADR renders the queue without introducing a third id scheme.

## Consequences

- Agent-issued work is visible where humans plan, with honest state —
  the "requires attention" asymmetry between surfaces is gone.
- The `WorldTaskRow` gained additive fields (`projectId`, `actorId`,
  `cancelRequested`) — shaping is tolerant of older rows.
- The coordination board reads the world-state projection's 5s poll —
  journal watch-driven folds (the `LaWorldFeed` cadence) can replace
  the poll later without a UI change.
- The delegation ledger is UI-lane state; a lost row degrades to a
  card without provenance while the coordination board still shows the
  task (honest absence).
- Post-merge follow-up (open): when the unified card World exists,
  move the coordination rendering onto the `TaskRowFeedResource` path
  and retire the poll; also unify `TaskBoardParticipant`/
  `PlanningBoardParticipant` behind one participant seam over
  `LwwReplicaCore` (merge lane follow-ups).

## Verification

- New: `test/coding_agent/realm_task_board_test.dart` (lanes, honesty
  mapping, filters, attention preset, detail-pane parity), 
  `test/coding_agent/board_delegation_test.dart` (admit, refusal,
  no-seam-no-op, ledger persistence, doc link), plus the merge lane's
  `lww_replica_core_test.dart`.
- Green: the whole boards lane incl. the byte-exact wire goldens,
  ADR 0028 migration window, planning sync, and
  `mesh_board_bridge_test` with the verdict docId stamp.
- `fvm flutter analyze`: zero errors.
