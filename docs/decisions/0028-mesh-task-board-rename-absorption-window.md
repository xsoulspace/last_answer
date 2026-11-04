# ADR 0028: The mesh task board renames off `agent_world` through a versioned absorption window

- Status: accepted
- Date: 2026-11-04
- Deciders: realm owner (Anton), seat session (ZCode/GLM); reviewed by the
  realm actors (weaver replied, scout absent — ADR 0074)
- Scope: the mesh task board wire (`MeshTaskBoard`, `TaskBoardParticipant`),
  the board sync file, the byte goldens

## Context

The multiplayer task board's canonical id is `agent_world` — a demo-era
name that today carries real peer task data. The id is load-bearing:
it IS the sync file path (`task_boards/agent_world.json`, the whole-file
exchange unit), the `board_id` field of the persisted envelope, and the
kernel replica doc id. Reading the ecsly convergence kernel showed the
id goes one level deeper than the envelope: every persisted level
carries a flat `doc_id` field — `OpRecord` (whose `opId` is derived as
`docId#hlc.wall#counter#actor`), `Snapshot`, `ConvergenceDoc` — and the
kernel **refuses ops whose `doc_id` differs from the replica's own**.
A unilateral rename therefore fails silently twice over: un-renamed
peers never read the new file path, and a renamed peer silently drops
every legacy op as foreign. There is no error state in either direction.

What made the surface tractable: op **entity keys** embed the TASK's
document id (the open doc a request targets), not the board id — so
there is no entity-key surgery; only the flat `doc_id`/`board_id`
fields need rewriting.

## Decision

1. **Canonical id: `main`.** `MeshTaskBoard.defaultBoardId` is `main`;
   `agent_world` survives as `MeshTaskBoard.legacyBoardId`. (Boring,
   eternal, path-safe. The realm actors were offered the review;
   weaver's reply — delivered, characteristically, as a prose file
   named `agent_world.json` — named the same candidate.)
2. **Absorb forever.** `TaskBoardParticipant.absorb` folds BOTH paths.
   The legacy file is decoded, rewritten by
   `MeshTaskBoard.rekeyDocId` (exact-match `board_id`/`doc_id` values
   only, at any depth), then fed through the existing snapshot-first
   absorb. The rewrite is idempotent under the version vector, so the
   legacy read stays forever: once no peer writes the file it costs one
   null read.
3. **Mirror while the window stands.** While
   `kTaskBoardLegacyMirror = true`, every flush also writes the legacy
   path with all doc ids rewritten back — a pre-rename peer's kernel
   accepts the mirrored ops because their `doc_id` is its own, with
   identical payloads and HLCs. Versions upgrade in any order and keep
   converging.
4. **Retirement is an operator decision.** The mirror stops in a later
   release (flip the constant) once the operator confirms no
   pre-rename device syncs. There is no automatic drain detection:
   a silent stop is exactly the failure shape this window exists to
   avoid.
5. **The goldens re-pin once, deliberately.** The wire contract now
   pins `board_id: 'main'` and the mirror's legacy rewrites; the
   migration contract is pinned by
   `mesh_task_board_migration_test.dart` (v1→v2 absorb, compacted
   snapshot-only absorb, mirror bytes, cross-version round trip,
   idempotence).

## Consequences

- The rename ships as a migration with a convergence contract, not a
  diff: no device can silently fork, in either direction, at any
  upgrade order.
- Costs while the window stands: one extra whole-file write per flush
  and one extra read per absorb cycle — the same whole-file exchange
  the board already pays for.
- Provenance labels written before the rename (e.g. the durable task
  queue's `board:` field) keep their historical value; nothing reads
  them as a routing key.
- A future board-id change inherits this machinery: `rekeyDocId` is
  generic over `from`/`to`.

## Alternatives considered

- Flag-day rename (all devices upgrade simultaneously) — rejected: the
  same silent split brain for any missed device, with no recovery path.
- Version field in the envelope driving migration — rejected: the doc
  id itself is the version marker; an extra field adds a second source
  of truth to keep honest.
- Keep `agent_world` forever, rename display strings only — rejected
  this round: the demo-era name would persist in every path, op id, and
  golden, and compound at the next real wire change.
