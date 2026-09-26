# ADR 0013 — Mesh task board over the ecsly world-sync substrate

- Status: Accepted (console slice; the full two-device run remains the
  human gate in [multiplayer-device-gates](../product/multiplayer-device-gates.md))
- Date: 2026-09-26
- North Star impact: `strengthens` — the shared document/workspace is the
  collaboration surface; the task board is one more durable projection of
  shared work, not a second canonical store.
- Builds on: [0003](0003-agents-live-in-docs.md) (runtime/world/actor
  ontology, no second protocol), [0005](0005-doc-multiplayer-over-convergence-kernel.md)
  (docs event-sourced over the convergence kernel; transport membership ≠
  agency), [0006](0006-session-is-not-world.md) (session ≠ world), and the
  ecsly repo's world-sync decision
  (`ecsly/docs/decisions/0001_world_sync_over_convergence_kernel.md` plus
  its live-bridge counterpart `0002_live_world_delta_bridge.md`).

## Context

PLAN 6.C names the mesh console: a phone task op reaches the macOS owner,
the owner executes, the verdict returns to the phone, over the existing
convergence/ACP contracts. The multiplayer substrate (doc replicas, roster,
presence, permission routing) already rides the convergence kernel; what
was missing was (a) the live ecsly World→delta bridge (PLAN 5.G5) and (b) a
shared, agent-readable record of *tasks* — who requested what, where it
ran, and what the verdict was — replicating between at least two mesh
peers on a CRDT base with periodic snapshot recovery (PLAN 5.G3).

`ecsly_world_sync` is the kernel-consuming adapter with exactly this
shape: stable-identity keys, one LWW kernel op per keyed value, VV-diff
anti-entropy, snapshot serving for compacted/lagging replicas. Last Answer
had pre-staged its path dependencies but never consumed them.

## Decision

1. **The cross-device task console rides `ecsly_world_sync`.** One
   `MeshTaskBoard` per device wraps one `WorldSync` kernel doc
   (`boardId: 'agent_world'`). Task rows are keyed world state:
   `task/<docId>/<taskLocalId>` with `title`/`status`/`origin`/
   `createdAt`/`verdict` fields, one kernel op per field change. No new
   protocol: the board file rides the same mesh exchange as the roster
   (`task_boards/agent_world.json`), with kernel-level delta/snapshot
   absorption on receive.

2. **Dispatch is an op; execution stays with the workspace owner.** A peer
   writes a `requested` row (`mesh_task_dispatch` verb). The device with
   the bound workspace and a live harness controller auto-runs it through
   the existing delegate path (ACP/AFM backend, deny-by-default
   permissions unchanged) and writes `running` → `completed`/`failed` with
   an honest verdict map (`verdict`/`stopReason`, spend figures only when
   actually parsed — never zeroed or invented). Peers are replicas with
   input rights (ADR 0005 §3); the owner alone executes and materializes.

3. **Periodic snapshots are policy, invoked at the sync cycle.** Each sync
   cycle runs `DocReplicaStore.compactAll()` and board compaction above a
   log threshold; compacted replicas recover lagging peers through the
   kernel's `needsSnapshotFor`/`snapshotFor`/`adoptSnapshot` across the
   store/mesh seam. A periodic sync timer (`startPeriodicSync`) makes the
   cadence real without changing the anti-entropy contract.

4. **Hermetic gates.** The mesh store location honors
   `LAST_ANSWER_MESH_STORE` on dart:io platforms so gate scripts never
   depend on `~/Documents` TCC grants.

## Non-claims

- The full two-device console journey (real phone, real relay, live ACP
  agent) has not been re-run by this decision; the T3 gate script gained
  the console steps and the human runs it. Unit/widget gates prove the
  routing, auto-run, verdict write-back and convergence over fakes and a
  scripted harness.
- Verdict *rows* replicate; token-level streaming of a running turn to the
  peer does not (PLAN 6.C's "streamed phone verdict" stays open).
- No document content moves through the board; agent-doc content stays on
  the doc-replica lanes (ADR 0005 §2). The board records task facts only.
- ecsly `World` objects themselves are still not hosted by Last Answer;
  the live bridge is consumed where worlds exist (ecsly repo). Kernel
  publication (removing the path-override bootstrap) remains external.
