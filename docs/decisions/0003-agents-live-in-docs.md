# ADR 0003 — Agents live in docs; the runtime/world/actor model; the composition law

- Status: Accepted (direction; implementation gated per phase — see
  [Agents in Docs](../product/agents-in-docs.md))
- Date: 2026-09-04
- Builds on: [0001](0001-recursive-document-node-model.md) (recursive
  document model), [ADR 0015 of agentic_harness]
  (`dart_flutter_packages/docs/decisions/0015_domains_live_in_hosts_core_stays_generic.md`
  — domains live in hosts, core stays generic)
- Product context: last_answer is the **first composition product** — it
  depends on many independently developed products (agentic_harness,
  xsoulspace_inference_*, IntentCall, agentic_executables, universal_storage
  mesh, dart_acp_toolkit).

## Context

The coding agent shipped as a standalone screen
(`lib/coding_agent/`) with one embedded runtime (the harness daemon). The
product direction is larger: agents become **documents** — first-class
shareable, archivable, syncable objects like notes and ideas — where a
human and many agents work the same task surface; coding is the first
domain, general agents follow.

Three structural facts constrain the design:

1. **The actor model is not what we first said.** "The agent is an actor in
   the runtime" is true *by construction of our first implementation*, not
   by definition. The honest ontology is:

   - **Runtime** — the machinery that makes agents act (the embedded harness
     daemon; a spawned CLI agent such as pi/opencode/claude-code; a remote
     mover brain).
   - **World** — the shared mutable state actors act on. A world is bound to
     a **workspace** (the delegated directory; its snapshot store lives at
     `<workspace>/.dart_tool/harnessd_store/`).
   - **Actor** — an agency-holding entity inside a world. Several actors may
     share one brain (one model, many actors — the harness squad); one brain
     may drive a world remotely (remote mover); a CLI agent may be a world of
     its own with actors inside it (pi spawns its own subagents).

   The **topology** — one world/one actor; one world/N actors; N worlds/one
   brain; N worlds/N brains — is **task- and CLI-dependent data**, not code.
   Which topology a task uses is an **open problem** we have not solved; this
   ADR does not freeze it. The host names the topology per task and refuses
   unsupported combinations honestly.

2. **Workspaces: one doc may bind to several.** Zed, Codex and others already
   support multi-root workspaces, and monorepos make it the normal case.
   Single-instance-per-workspace remains MANDATORY (two daemons on one
   workspace = two worlds = broken single-writer). Near-term shape: a doc
   binds to a **workspace set**; each workspace maps to its own session/world;
   one task = one workspace. Cross-workspace tasks (a squad spanning worlds)
   are explicitly **out of scope** until the one-world squad discipline is
   proven at that scale.

3. **The composition law.** last_answer composes infrastructure products;
   infrastructure never imports last_answer:

   | Product | Role | Depends on last_answer? |
   | --- | --- | --- |
   | agentic_harness | generic loop, seams, oracles, daemon | **never** |
   | xsoulspace_inference_* | model backends (AFM, OpenRouter) | **never** |
   | IntentCall | intent registry + projection (MCP/ACP/platform) | **never** |
   | agentic_executables | canonical rows, repair packs, verify wires | **never** |
   | dart_acp_toolkit | ACP v1 transport | **never** |
   | universal_storage / mesh | storage + device sync | **never** |
   | **last_answer** | composition product: docs, UI, hosts | — (composes all) |

   Integration happens ONLY over stable seams: ACP (transport), IntentCall
   (intent projection), AE wire types (canonical rows/repair packs), the
   harness's public host surface (`HarnessAcpBackend`, snapshots). Each
   product stays independently developable and testable.

## Decision

1. **Agents live in docs.** A new `ProjectModel.doc` format (`formatId`:
   `agent`) is the product surface for agents — same lifecycle as
   note/idea/doc: created, edited, archived, shared, mesh-synced. The
   standalone coding-agent screen is absorbed into this doc view; coding is
   the FIRST domain, general agents follow (one evidence-tier domain before
   any generic "agents everywhere" push).

2. **Runtime seam lives in the host, as a union.** `AgentRuntimeHandle` =
   embedded harness (in-process ACP daemon, `HarnessHost`) **|** spawned ACP
   CLI agent (`AcpAgentRuntime` + catalog) **|** (future) remote-mover brain.
   Everything speaks the ACP vocabulary (`session/prompt`,
   `session/request_permission`, `session/propose_move`) — **no second
   protocol**, ever. Worlds nest fractally (pi inside last_answer is a world
   inside a world); composition works precisely because every level speaks
   the same primitives.

3. **State split is law**: transcripts, task board, roster, settings and the
   permission log are **doc data** (synced, archived, shareable). World
   snapshots and the meaning tree stay **device-local** (`.dart_tool/`) — the
   tree re-derives, it is never restored from the doc store.

4. **Multi-workspace near-term; cross-world later.** Doc binds to a workspace
   set; sessions are keyed per workspace; one daemon process MAY host several
   worlds (one per workspace) with per-workspace single-instance locks
   unchanged. Cross-workspace task coordination waits for evidence.

5. **Agent-friendly = projections of the same typed state.** The UI renders
   the board/transcript/permissions; the agent-facing surface is the SAME
   state projected as canonical rows (AE `ProblemRowWire`-compatible) and as
   registered IntentCall intents (`agent.doc.create`, `agent.task.delegate`,
   `agent.permission.answer`, `agent.task.guide`). pi (or any agent) operates
   last_answer through intents/deep-links — not through screenshots.

6. **Shared memory / personality is a direction, not a feature.** An agent's
   accumulated experience across projects could become a portable,
   host-verifiable **experience pack** (data, like repair packs; memory as
   re-derivable projection, never a log). Zero implementation until the
   one-workspace loop is proven; future ADR required.

## Consequences

- The coding-agent screen becomes the first `formatId: 'agent'` view (Phase
  2 of [Agents in Docs](../product/agents-in-docs.md)); its proven machinery
  (embedded daemon, permission round-trip, backend switch, snapshot restore)
  moves, unchanged in behavior, into the doc surface.
- Runtime settings become **per-agent-binding data** on the doc roster
  (backend, model, key, profile, permission default) — no global agent
  config.
- The harness, IntentCall, AE and inference packages continue to develop
  independently; last_answer composes and must never leak product types into
  them (enforced by the table above; violations are ADR-level bugs).
- Topology support is declarative and honest: unsupported combinations fail
  with named errors, never silent degradation.
- Archiving an agent doc archives the *surface*; a live daemon is a
  device-local resource with its own lifecycle (idle-exit, crash recovery) —
  the doc re-attaches on reopen via the snapshot store.
