# Agents in Docs — goal, pillars, phases

> Product spec for the direction decided in
> [ADR 0003 — Agents live in docs](../decisions/0003-agents-live-in-docs.md),
> clarified by [ADR 0012](../decisions/0012-writable-agent-doc-and-acp-client-first.md).
> Companion (engine-side, product-agnostic): agentic_harness
> `docs/agent/PLAN.md` (R8 track) and `pipeline_coding.md`.

## Goal

Any document in last_answer can be a **writable shared workspace** where
humans and agents work on the same evolving content. The typed document/
meaning graph is the collaborative state; conversations, ACP streams, task
boards and harness activity are attributed projections and history, not the
document itself. Workspace contents are addressable to authorized sessions
through stable projections; code edits are materialized and verified by the
workspace owner.

**Coding is the first domain** (the workspace oracle makes it verifiable);
general agents follow. The first external-agent direction is Last Answer as
an ACP client launching ACP agents such as Codex and Pi. Only after that
shared-document path is proven do we expose Last Answer for an external ACP
client or operator to drive through ACP server, CLI, MCP or IntentCall. Local
same-device collaboration is the first proof; mesh peers and opt-in
Internet/VPS transport extend the same world later.

## Pillars

1. **The writable document is the shared world.** Human edits, agent
   proposals, threads and workspace/file projections refer to the same
   typed meaning graph. The UI, activity transcript, ACP sessions and
   agent-facing intents are projections of that state. The owner
   materializes code changes to the filesystem and runs the workspace
   oracle; no peer or transcript becomes a competing source of truth.
2. **One ACP client seam, many agents.** First Last Answer launches
   Codex, Pi and compatible ACP agents through capability-negotiated ACP.
   Do not build vendor-specific execution protocols. An external ACP
   client connecting to Last Answer is the reverse direction and remains
   a later phase, after the outbound client path is proven.
3. **The human stays sovereign.** Permissions deny-by-default; budgets are
   monotonic and visible; verdicts and failures are data on the doc; the
   escalation round-trip ("guide the task") is a first-class UI state.
4. **Per-actor settings and honest credentials.** Each actor binding
   declares its runtime, capabilities and permission policy. Application
   credentials remain device-local; external ACP agents retain their own
   authentication. Network execution is explicitly disclosed and
   consented. Sharing a document or model never grants authority.
5. **One world, several connected participants.** The local workspace
   owner is the single code materializer/oracle. Authorized actors on
   other sessions/devices may read and propose in the same shared graph;
   mesh is the first remote path, VPN/Internet/VPS relay is later.
   Cross-workspace tasks, execution handoff and unsupported topologies
   remain named refusals.

## Phases (each shippable alone)

> Forward tracking lives in [docs/PLAN.md](../PLAN.md) (production path,
> gates, ledger); the landed record in [docs/history.md](../history.md).
> The agent handoff brief is
> [docs/HANDOFF-agents-in-docs.md](../HANDOFF-agents-in-docs.md). Existing
> AFM/provider and harness gates remain evidence requirements; they do not
> replace the document-first product outcome.

### Phase 1 — AgentDoc format + view (coding first) — **LANDED 2026-09-04**

- Landed: `DocFormatIds.agent` + `AgentDocModel` payload (workspace set,
  backend, check override) on `ProjectModel.doc`; `AgentDocSurface` in the
  ProjectView dispatch; home entry creates agent docs; MCP/intent entries
  (`agent_doc_state`, `agent_task_delegate`, `agent_permission_answer`);
  the daemon accepts the doc's `checkCommand` (the product `--check`).
- Verified: scripted widget e2e (delegate → permission → verdict → doc
  payload pins workspace); real-AFM e2e as the macOS app; **self-profile
  gate** — an agent doc bound to this repo fixed a committed failing
  fixture on-device (honest oracle, restored after each run). Rows:
  harness `benchmark/runs/delegation_m1_evidence.md` (Phase 1 section).
- Scope: this is the structural document/view landing. It does not prove a
  writable shared workspace, arbitrary ACP-agent interoperability,
  cross-device completion or the first product slice in ADR 0012.

Original plan (superseded by the landed state above):

- `ProjectModel.doc` `formatId: 'agent'`: workspace set (start: one),
  roster, board, batched transcript blocks, permission log.
- Move `lib/coding_agent/` machinery into a `DocFormatView`; the standalone
  screen path redirects to a doc. Proven behavior unchanged: embedded
  daemon, backend switch (AFM ⇄ OpenRouter), permission round-trip, verdict
  surfacing, snapshot restore.
- Doc ↔ runtime lifecycle: archiving the doc detaches the surface; the
  daemon is device-local (idle-exit, crash recovery); reopening re-attaches
  via the snapshot store.

### Phase 2 — Writable shared document + outbound ACP client (C0–C6)

- Make the agent document the editable shared meaning/document graph;
  transcript and ACP events are projections with stable IDs, attributed
  diffs, threads, permissions and durable history.
- Last Answer acts as ACP client and launches a negotiated ACP agent
  against the same workspace/document state. Codex and Pi are the first
  independent interoperability fixtures; do not claim untested optional
  ACP capabilities or arbitrary-agent compatibility.
- The embedded harness and ACP runtime consume one document/world state,
  one permission boundary and one owner materializer. Human edits remain
  possible while an agent works; conflicts are visible and history is
  recoverable.
- The initial acceptance workload is one local device/workspace and one
  foreground task. Cross-device mesh and external operators are later
  stages, not substitutes for this proof.

### Phase 3 — Broader squads + cross-device shared-world collaboration

- Extend the local runtime union to multiple ACP agents and squads on one
  document/workspace, with attributed activity and one code materializer.
- Then extend the same document/world graph to another authorized device
  over the existing mesh, preserving peer identity, origin-bound
  permissions, attributed proposals and one code-workspace materializer.
- Gate: real multi-agent edits and real two-device document/file
  projections and permission round-trip converge or produce a named
  divergence. Internet/VPS relay, background prompts and asynchronous
  fallback remain separately gated transport work (ADR 0008).

### Phase 4 — External operator ingress (reverse direction)

- After Phase 2 is proven, expose a production surface for an external
  ACP client, CLI, MCP or IntentCall operator to act on Last Answer's
  shared document/world.
- All entry paths reuse the same typed state, permissions, proposals,
  materializer and oracle; debug intents do not prove production access.

### Phase 5 — One general (non-code) agent domain

- One prose domain (research or PRD doc) on the **evidence tier** — never
  the code-law `pass` tier. Different tool surface, different verification;
  proves "general agents" is real before any framework push.

### Phase 6 — Internet/VPS transport and experience packs

- Internet/VPS access uses the same authenticated shared world and
  local-first operations; no server becomes a workspace materializer or
  stores plaintext workspace content. Follow ADR 0008's opt-in encrypted
  relay and remote-access gates.
- Future direction (needs its own ADR): **experience packs** — portable,
  host-verifiable projections of an agent's accumulated interactions
  (shared memory / personality across projects). No implementation until
  the writable document, ACP-agent and remote-collaboration gates are
  proven.

## Non-goals

- No second protocol; no product types leaked into infrastructure packages
  (ADR 0003 composition law).
- No cross-workspace task coordination (yet); no generic topology engine
  (topology is declared data).
- No external ACP-client ingress before the outbound Last Answer ACP
  client-to-agent path is proven.
- No Internet/VPS relay or multi-device execution handoff in the first
  local shared-document slice.
- No chunk-per-block transcript sync; no world snapshots in the doc store.
- No "agentify every doc type" before Phase 5 proves one evidence-tier
  domain.
