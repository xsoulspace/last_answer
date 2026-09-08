# ADR 0009 — Session registry and many-worlds debug state

- Status: **Accepted** (direction; migration gated per §Gates)
- Date: 2026-09-08
- North Star impact: `enables` — value path 3 (one state, many projections)
  and value path 5 (headless-capable console) both require that the
  typed state be reachable **without a UI widget**.
- Builds on: [0003](0003-agents-live-in-docs.md) (agents live in docs),
  [0006](0006-session-is-not-world.md) (a session is not the world —
  sessions are projections and can be many),
  [0007](0007-actor-roster-and-multiplayer-identity.md) (presence is
  identity, never authority)
- Infra dependencies (referenced, never imported): `xsoulspace_agentic_host`
  (harnessd daemon — sessions with **no UI at all** are its normal mode);
  `xsoulspace_agentic_harness_flutter_profiler` (host-side profiler, the
  intended consumer of the registry).

## Context

The MCP/intent surface (`lib/coding_agent/agent_mcp_tools.dart`) resolves
"the open agent doc" through **static globals on the widget class**:

- `AgentDocSurface.debugState` and `AgentDocSurface.debugSurface`
  (`agent_doc_surface.dart:57–60`) — single slots, overwritten by
  whichever surface built last; dispose clears only if `identical`.
- `agent_doc_state` takes an **empty input schema** — no doc/session
  selector exists. `agent_task_delegate` and `agent_permission_answer`
  grab `debugSurface` unconditionally.

This was verified on 2026-09-08 against the working tree. It was correct
for Phase 1 (one doc, one surface, one device) and is structurally wrong
for everything the product already commits to.

## Problem

With "many worlds" — the term for the already-decided shape of this
product (multiple docs, mesh peers, shadow viewers, headless daemon
sessions) — the globals break in three concrete ways:

1. **Two agent docs open** (desktop split view, two windows): the
   last-built surface owns the slot; the other doc is invisible to the
   verbs — or worse, `agent_task_delegate` **silently delegates to the
   wrong doc**. The state carries `docId`, but the verb cannot use it
   because there is no selector.
2. **Host + shadow ambiguity**: `debugState` and `shadowDoc` are separate
   slots. A peer hosting one doc while viewing another (both supported)
   already has an unresolved collision the code hopes away.
3. **Headless sessions cannot be represented at all.** The harnessd daemon
   runs sessions with no widget in the process; a static on a Flutter
   widget class can never be their source of truth. A UI-owned global is
   structurally incapable of being the substrate of a headless-first
   inspector.

## Decision

**D1 — A session registry, owned by the host layer, is the one index of
live sessions.**

```
HarnessSessionRegistry (host layer, pure Dart — no Flutter)
  ├─ sessions: Map<SessionId, SessionHandle>  // UI or headless, equal citizens
  ├─ register / unregister                    // surfaces, daemon runners,
  │                                           // shadow viewers, tests
  └─ resolve(id?) → handle                    // explicit id, or the
                                              // focused/only session
```

- Keyed by session id (for docs: the deterministic `agent-<docId>`
  replica id already used by the mesh wiring). Handles expose the same
  typed state today's `debugState` carries, plus the intent-action seam
  `debugSurface` carries (delegate, permission answer).
- **Registration is presence, not authority** (ADR 0007 §3 analogy):
  registering a surface grants no ownership of the doc, only
  observability and intent routing.
- UI surfaces register on open / unregister on dispose; daemon runners
  register at spawn; tests register scripted seams. Nothing about the
  registry requires a widget tree.

**D2 — MCP/intent verbs gain an optional `docId` (session id) parameter.**

- Default (parameter absent): resolve the **only** session; if several
  are live, resolve the **focused** one; if still ambiguous, return an
  error that **names the live sessions** — never a silent wrong-target
  answer (DESIGN §6: honest surfaces).
- This is backward compatible with today's verbs and today's tests
  (single-open-doc behavior is unchanged).

**D3 — The registry is the inspector's headless substrate.**
`xsoulspace_agentic_harness_flutter_profiler` (and its future pure-Dart
protocol layer) consumes the registry — not any widget static. The
Flutter profiler panes are **one reader** of the registry; MCP verbs and
headless drivers are others. This is what makes "an AI agent debugs the
harness without UI" structural rather than promised.

**D4 — Widget statics become thin adapters during migration.**
`AgentDocSurface.debugState` keeps its signature for existing tests but
delegates to the registry (read-through, write-through). No parallel
truth remains after the migration gate.

## Open questions

1. **Focus semantics** — what makes a session "focused" across windows
   and mesh peers? Candidate: last UI interaction, device-local, never
   synced. To be decided when the two-surface gate runs.
2. **Registry sync scope** — the registry is device-local (live sessions
   are facts about *this* device). Remote sessions are observed through
   the mesh doc ops, not through registry replication. Confirm when the
   inspector goes cross-peer.

## Gates

1. **Two-surface gate**: two agent docs open simultaneously; each MCP
   verb targeting each doc by id returns that doc's state; no-target
   verbs resolve focused-or-error correctly. Scripted, widget-driven on
   real keys.
2. **Headless gate**: registry + profiler protocol answer
   "what beats ran / what context was assembled / spend" for a daemon
   session **with no Flutter in the process**.
3. **Adapter removal gate**: after migration, deleting the widget
   statics' storage (keeping delegating signatures for one release)
   leaves all tests green.
