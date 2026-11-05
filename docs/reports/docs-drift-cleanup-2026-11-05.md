# Docs drift cleanup — plan of record (2026-11-05)

Work order: "Docs drifted while we shipped fast. Clean up what's stale."
This file is the plan's home: it survives a round bound because it is in
the tree, not in the conversation. Pick it up by reading this list against
the files named, then move finished rows to
[history.md](../history.md) with evidence.

## Rule used to decide "stale"

A doc is stale when it states a **current** fact the tree contradicts.
Historical records (history.md, ADR bodies, dated evidence/handoff
snapshots) are **not** stale — they are ledger rows. They get a dated
banner or a "superseded by" pointer, never a rewrite.

## Done

- [x] `docs/product/multiplayer-device-gates.md` — the mesh console row
      named `task_boards/agent_world.json` as the live board path.
      [ADR 0028](../decisions/0028-mesh-task-board-rename-absorption-window.md)
      made `main` canonical; the legacy path is absorbed and mirrored while
      the window stands. Corrected, with the window stated.
      (`git diff docs/product/multiplayer-device-gates.md`)

## Status of the rows (2026-11-05)

Rows 1, 3 and the row-4 banner are landed in the tree — `git diff` is the
evidence. Rows 2, the row-4 fold decision and row 5 remain, and they are
**addressed, not orphaned**: durable task `task-559a9c5746a6549d6f59`
(addressee `weaver`) carries them, so the plan has a worker even if the
conversation goes quiet. Any peer can post progress with `task op:say`;
`task op:show` reads the record.

## Open, in order

1. **DONE** `docs/design/ecsly-boards-extraction.md` — the store-comparison
   table and one participation row still call the CRDT board doc
   `task_boards/agent_world.json`. Same ADR 0028 drift as the row above:
   canonical id is `main`, legacy path absorbed + mirrored. This is a
   design doc read as current, so it needs the correction, not a banner.
2. **Worker-era verbs (`delegate`/`claim`/`progress`/`heartbeat`)** —
   retired by ADR 0118 D3; the harness answers `task`
   op:create/say/show/list/cancel/events/wait. Docs still handing an agent
   the old verbs as if live: `docs/PLAN.md` (the `task_delegate` wiring
   row), `docs/product/two-products-one-surface.md`,
   `docs/product/agents-in-docs.md`,
   `docs/reports/mesh-remote-agent-analysis.md`. Check each: is the verb
   named as a *seat intent on the doc surface* (may be fine) or as the
   *task-board API* (stale)? Annotate, don't delete —
   [ADR 0027](../decisions/0027-miniwindows-one-surface-three-presentations.md)
   already models the honest wording.
3. **DONE** `docs/decisions/0013-mesh-task-board-over-ecsly-world-sync.md` —
   accepted ADR that pins `boardId: 'agent_world'`. Add a one-line
   "id superseded by ADR 0028" pointer under Status; leave the body.
4. **`docs/product/shared-world-status.md`** — dated 2026-10-19 and reads
   as current status. Confirm it is a dated snapshot (banner) or fold the
   still-true remainder into
   [evidence/current-status.mdx](../evidence/current-status.mdx).
5. **Handoff overlap** — `HANDOFF.md`, `HANDOFF-agents-in-docs.md`,
   `HANDOFF-R9.md`, `HANDOFF-R9.1.md`. The R9/R9.1 pair already carries
   "historical handoff; do not execute" banners pointing at
   HANDOFF-agents-in-docs.md. Check the other two for the same treatment
   so exactly one handoff claims to be current.

## Non-goals

- No rewriting of `docs/history.md`, ADR bodies, or dated evidence dirs.
- No link/structure churn beyond the rows above.
- Verification per repo rule: `git diff --check`, changed links resolve,
  and each row names the contradicting source (ADR, code path, or commit).
