# ADR 0006 — Session ≠ world; the workspace-aware session registry

- Status: Accepted
- Date: 2026-09-06
- North Star impact: `clarifies` (of ADR 0003's single-instance-per-workspace
  mandate — it is preserved; the session concept is separated from it)
- Builds on: [0003](0003-agents-live-in-docs.md) (runtime/world/actor
  model), pairs with [0005](0005-doc-multiplayer-over-convergence-kernel.md)

## Context

Today `HarnessSessionView` conflates two things: `id + cwd` — a session
*is* a world binding. Consequences:

- The UI cannot show **several sessions for one workspace**, or sessions
  grouped across a workspace set — a real product gap (operator console
  needs the workspace → sessions overview).
- Multiplayer (ADR 0005) would be impossible to express honestly: several
  peers on one workspace must not mean several daemons.

ADR 0003 makes single-instance-per-workspace **mandatory**: two daemons on
one workspace = two worlds = broken single-writer. That law is correct and
is not relaxed here.

## Decision

**A session is not a world.**

- **World** — the workspace-bound mutable state actors act on. One world
  per workspace, one daemon, single-writer (ADR 0003, unchanged).
- **Session** — a transcript/conversation projection onto that world, plus
  its stream of proposals (agent edits land staged; ADR 0002 P4). Many
  sessions, humans, and actors may read and propose on one world; only
  the daemon's writer moves the world.

Registry model (replaces the flat `List<HarnessSessionView>`):

```
Workspace (bound, ≤1 world/daemon)
  └─ Sessions[]   (transcript projections + proposal streams)
       └─ Actors[] (agency-holding entities; brains are data, ADR 0003)
```

- A doc binds to a workspace (or workspace set); each binding carries its
  own session(s). Opening a second session on the same workspace creates
  a second projection — never a second daemon.
- This is **local-first**: the registry split ships as a pure local UX
  change (see PLAN Phase 5a) with zero sync dependencies. Multiplayer
  (ADR 0005) layers onto it afterwards.

## Consequences

- `HarnessSessionController` schema changes: workspace becomes the
  grouping key; sessions are children; `createSession(cwd)` becomes
  session creation *on* a bound workspace.
- The session/workspace overview renders on one grid (DESIGN.md
  discipline): workspaces as small-caps section labels, sessions as
  indented small multiples.
- Honest refusal stays: binding a second daemon to a bound workspace is a
  hard error, surfaced as data, not silently allowed.

## Non-claims

- No claim that N sessions on one world is safe for *concurrent writes to
  the same turn*; sessions are independent streams — cross-session task
  isolation follows the harness's new-task goal isolation open problem
  (tracked harness-side; this product pulls, never implements).
