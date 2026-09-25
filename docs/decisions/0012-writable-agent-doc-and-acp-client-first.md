# ADR 0012 — Writable shared agent documents; ACP-client-first integration

- Status: Accepted (direction; implementation gated in [PLAN.md](../PLAN.md))
- Date: 2026-09-24
- North Star impact: `strengthens` — the document is the shared working
  surface; conversations and harness activity are projections of work on it.
- Builds on: [0001](0001-recursive-document-node-model.md) (recursive
  documents), [0003](0003-agents-live-in-docs.md) (runtime/world/actor model
  and composition law), [0004](0004-meaning-runtime-not-conversation.md)
  (meaning-first runtime), [0005](0005-doc-multiplayer-over-convergence-kernel.md)
  (shared docs and multiplayer), [0006](0006-session-is-not-world.md)
  (sessions are projections), [0008](0008-local-first-model-federation.md)
  (shared meaning graph and single materializer), [0010](0010-one-harness-doc-surface-unification.md)
  (chat as projection), and [0011](0011-multiplayer-sessions-and-queue-as-graph.md)
  (multiplayer sessions).

## Context

The current consumer plan orders C0–C6 around a safe coding turn: delegate,
review a proposed mutation, verify it, and recover the record. Those are
necessary execution-safety gates, but they do not by themselves prove the
product outcome: a human and agents work directly on one evolving, writable
document/workspace, with history and discussion attached to the work rather
than with conversation as the product.

The existing decisions already provide the intended substrate. The meaning
document graph is shared state; agent sessions are projections onto a
workspace-bound world; code-workspace materialization and its oracle have one
owner. This ADR clarifies the product ordering and the first ACP direction
without replacing those contracts.

## Decision

### 1. The writable document/workspace is the product

- The shared document/meaning operation graph is the canonical durable work
  state. Humans and agents can make attributed edits in the same world;
  concurrent work is visible as document changes, proposals, threads, and
  revision history.
- Typed harness/ACP execution events are authoritative facts for their task
  and are linked into that state; conversation, task board, permission panel,
  and inspector are projections of document operations and execution facts.
  None substitutes for the writable document or its durable edit history.
- Workspace contents are addressable to authorized sessions through stable
  file/document projections. Do not mirror the entire filesystem indiscriminately
  into a transcript or a second document store. Preserve explicit, named
  treatment for unsupported, sensitive, generated, large, or binary content.
- For a code workspace, shared meaning/edit operations are materialized to the
  owner’s filesystem projection and verified there. The workspace owner remains
  the single materializer/oracle authority (ADR 0008); remote peers may read,
  edit the shared document graph, and propose work, but transport membership
  alone does not authorize execution or filesystem writes.
- Use the convergence kernel’s CRDT operations for document state and
  collaborative text. Workspace/file changes carry provenance and source
  revision; conflicting changes must be surfaced and reconciled, never silently
  overwritten.

### 2. Last Answer connects outward to ACP agents first

- First, Last Answer acts as an ACP client and launches ACP agents such as
  Codex or Pi. A negotiated ACP agent is a runtime binding for an agent
  document, not a separate chat product.
- ACP session updates, tool activity, permission requests, proposals, and
  completions are normalized into the same typed shared document/workspace
  state consumed by the human UI, embedded harness, and other sessions.
- Last Answer's ACP adapter/harness integration owns the workspace review
  boundary: authorized reads use stable workspace projections; proposed writes
  become operations/proposals bound to a path and source revision. If an agent
  runtime only supports direct filesystem mutation, isolate it from the
  authoritative workspace and import its diff as a proposal. Only the owner
  materializer applies an approved change. If neither mediation nor isolation
  is enforceable, refuse that runtime for coding rather than allow unobserved
  writes.
- Capability negotiation is authoritative. Unsupported capabilities fail
  visibly; no product support claim is inferred from a process merely launching
  or returning text. Codex and Pi are initial interoperability fixtures, not
  vendor-specific APIs or proof of every optional ACP feature. Test each
  through an ACP-speaking runtime/adapter and record that adapter's version
  and negotiated capabilities; naming a CLI does not claim that its unwrapped
  executable speaks ACP natively.
- Only after this outbound ACP-client-to-agent path is proven may Last Answer
  expose the reverse direction: an external ACP client connecting to Last
  Answer as an ACP agent/server, or operating it through CLI/MCP/IntentCall.
  These are separate adapters and acceptance gates.

### 3. Local collaboration first; remote participation is the same world

- The first implementation proves the shared writable document and one ACP
  agent on the local workspace owner device.
- The same world/document state is designed for authorized participants on
  other devices. Existing mesh convergence and permission routing are the
  first remote path; VPN and opt-in Internet/VPS relay are later transport
  work, not a second document or workspace authority.
- Remote collaboration does not imply remote actor execution handoff, multiple
  filesystem materializers, cross-workspace tasks, or server-side workspace
  storage. Those require their own gates and explicit policy.

## Acceptance direction

The first product slice is one agent document and one code workspace where a
human can edit while an ACP agent works, both observe the same evolving
document state, and edits/proposals/threads/diffs remain attributable and
recoverable after restart. A rejected or conflicting change cannot silently
alter the owner’s filesystem. The live workspace oracle runs at the owner
materializer. PLAN.md defines the implementation and evidence gates.

## Non-goals for the first slice

- An external ACP client connecting to Last Answer; prove Last Answer as ACP
  client first.
- Internet/VPS relay, background execution handoff, or multi-device execution.
- Multiple concurrent filesystem materializers or cross-workspace task
  coordination.
- Copying all workspace bytes into a synced transcript/document payload.

## Falsifier

If the local human + ACP-agent slice cannot edit one shared document graph,
preserve attributed history, and materialize/verify code changes at exactly
one workspace owner while keeping the shared graph canonical (conversation
remains a projection and code changes pass through the owner materializer),
this direction is not implemented; revise this ADR rather than calling a
conversation-only integration complete.
