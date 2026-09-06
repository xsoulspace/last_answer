# ADR 0005 — Doc multiplayer over the convergence kernel

- Status: Accepted (direction; implementation gated per phase — see
  [PLAN.md](../PLAN.md) Phase 5)
- Date: 2026-09-06
- North Star impact: `clarifies` (of ADR 0003's single-writer law and the
  Phase 5 sketch; no North Star amendment)
- Builds on: [0001](0001-recursive-document-node-model.md) (recursive
  document model), [0003](0003-agents-live-in-docs.md) (runtime/world/actor
  model, ACP vocabulary), [0006](0006-session-is-not-world.md)
  (session ≠ world — written together with this ADR)
- Infra dependencies (referenced, never imported — composition law):
  convergence kernel
  (`dart_flutter_packages/docs/decisions/0011_convergence_kernel_dual_mode.md`,
  package `universal_storage_convergence`), mesh transport
  (`dart_flutter_packages/docs/decisions/0010_mesh_sync_architecture.md`,
  packages `universal_storage_mesh` / `universal_storage_mesh_transport`),
  kernel contract extension
  (`dart_flutter_packages/docs/decisions/0029_convergence_kernel_presence_and_sequence_strategy.md`)

## Context

A document in last_answer must be a place where a human **and several
agents, on several devices and from several apps, work together** — the
MMO framing: one authoritative simulation, many clients, many channels.
Execution does not run on all devices: agents run on the device that owns
the workspace; every other peer holds a replica plus input rights. The
mesh transport (signed QR pairing, relay-as-node, anti-entropy) already
exists; the convergence kernel (op log + snapshots, HLC, version vectors,
pluggable merge strategies) already exists and is explicitly declared a
sub-star serving both mesh sync and ecsly world sync.

Two facts force decisions now:

1. **The harness streams text.** Agent output arrives as incremental text
   streams (reasoning beats, streaming turns). As soon as a second peer is
   connected, streamed text must merge — so the kernel's sequence/text
   merge strategy (deferred as "later phase" by kernel ADR 0011) is pulled
   **now**, scoped to block text content.
2. **Agents must see the room.** Parallel work and debugging from agents
   require presence to be machine-readable, not just UI state — "who is
   watching this doc" is an agent-visible fact (AI-native), not a widget.

## Decision

### 1. Docs are event-sourced over the kernel; last_answer never merges by hand

Every doc change is an `OpRecord` (kernel type); state is always
`fold(snapshot ∪ ops)`. last_answer chooses merge strategies and
compaction policies from what the kernel exposes and never hand-rolls
ordering, version vectors, or fold rules (kernel ADR 0011 sub-star
discipline).

### 2. Op mapping v1 (business-level contract)

| Doc data | Op shape | Strategy |
| --- | --- | --- |
| Transcript turns | op per turn, keyed by turn id | LWW map (monotone growth; VV dedupe) |
| Board rows / task claims | op per row, keyed by row id | LWW map |
| Doc metadata, settings | keyed ops | LWW map (kernel v1) |
| Block-graph fields | op per field per node | LWW map |
| Block child order | op per node → `(parent, fractional order key)` | LWW map (Figma-style; fractional rebalancing is a last_answer policy, not a kernel type) |
| Block text content (incl. streamed agent text) | sequence ops | **Sequence merge strategy** (RGA/YATA family behind the kernel `MergeStrategy` seam) — pulled forward per infra ADR 0029 |

### 3. Topology and authority

- The device that owns the workspace is the **simulation authority**:
  agents execute there; world snapshots stay device-local.
- Every other paired peer holds a **replica** with input rights: text
  edits, task claims, permission answers, proposals — delivered as ops.
- Single-writer is preserved exactly as ADR 0003 mandates: one world per
  workspace. Multiplayer multiplies *readers and proposers*, never
  writers. Sessions are projections (see ADR 0006).
- Cross-workspace task coordination remains a non-goal (ADR 0003).

### 4. Presence is dual-mode

- **Transport-level ephemeral frames** (unlogged, die on disconnect) drive
  live UI — joins, leaves, typing/streaming indicators. Presence SHOULD
  die on disconnect by design; kernel durability semantics are wrong for it.
- **Kernel-queryable ephemeral registry** (TTL'd ephemeral ops, never
  compacted into snapshots) answers agent queries: "who is connected to
  this doc, since when, doing what" is readable state, on the same
  convergence path. This is the AI-native half; infra ADR 0029 defines
  the kernel contract.
- Both modes derive from the same peer events; the kernel side is
  authoritative for agent queries.

### 5. Join model: transport membership ≠ agency

- Mesh pairing (QR) grants **transport membership** — replica sync only.
- Joining a doc session — acting on it — goes through the existing ACP /
  IntentCall intent surface (`agent.task.delegate`,
  `agent.permission.answer`, …). No second protocol (ADR 0003).
- Permissions stay deny-by-default **per device**: a remote permission
  request renders in the owner's flow identical to a local one (plus an
  origin label), with reject-first ordering, recorded as data on the turn.
  A joined agent from another app can never act without a visible,
  vetoable permission.

### 6. Non-conflation

`xsoulspace_platform_multiplayer_interface` (Steam/Yandex game-session
capabilities) is an unrelated domain. Doc multiplayer does not enter
through it and must not share its vocabulary.

## Non-claims

- Not full co-editing conflict UX yet: v1 gates are replica + input +
  permission routing, not simultaneous human typing in one block.
- No cross-workspace task coordination; N sessions on one world is in
  scope (ADR 0006), N worlds in one task is not.
- The convergence property rests on the kernel's property tests (infra
  ADR 0011), not on last_answer-side proofs.

## Gates

Gates live in [PLAN.md](../PLAN.md) Phase 5 (5a–5d). The headline gate
remains: **two devices, one doc, one workspace, two sessions open, a
permission answered from the second device, transcript identical on both,
zero new protocol.**
