# Agents in Docs — goal, pillars, phases

> Product spec for the direction decided in
> [ADR 0003 — Agents live in docs](../decisions/0003-agents-live-in-docs.md).
> Companion (engine-side, product-agnostic): agentic_harness
> `docs/agent/PLAN.md` (R8 track) and `pipeline_coding.md`.

## Goal

Any document in last_answer can be a place where a human and agents work
together: tasks are delegated, agents act in a world, work streams back,
permissions are answered, results are verified — from one device or many.
**Coding is the first domain** (the workspace oracle makes it verifiable);
general agents follow.

The end state: last_answer is the primary console (pi today), AFM-first,
with pi and other CLIs as first-class squad members during the transition.

## Pillars

1. **A doc is a shared surface on the world.** The document (transcript,
   board, roster, permission log) is data; the screen is one projection; the
   agent-facing surface (canonical rows + IntentCall intents) is another.
   Mesh sync makes a second device just another subscriber — no new code.
2. **One seam, many runtimes.** Embedded harness daemon, pi, opencode,
   claude-code, gemini, codex — all through the same ACP vocabulary. No
   second protocol. Worlds may nest (a CLI agent is itself a world); every
   level speaks prompt / permission / propose_move.
3. **The human stays sovereign.** Permissions deny-by-default; budgets are
   monotonic and visible; verdicts and failures are data on the doc; the
   escalation round-trip ("guide the task") is a first-class UI state.
4. **Per-agent settings, no global agent config.** Each roster binding
   carries backend (AFM on-device / OpenRouter / CLI), model, profile, key,
   and permission default. AFM is the local-first goal; CLIs are the
   transitional squad.
5. **Honest topology.** 1 world/1 actor, 1 world/N actors (squad),
   N worlds/1 brain (remote mover) are named, data-declared per task;
   unsupported combinations fail with named errors. Cross-world task
   coordination is out of scope until the one-world squad is proven.

## Phases (each shippable alone)

### Phase 1 — AgentDoc format + view (coding first)

- `ProjectModel.doc` `formatId: 'agent'`: workspace set (start: one),
  roster, board, batched transcript blocks, permission log.
- Move `lib/coding_agent/` machinery into a `DocFormatView`; the standalone
  screen path redirects to a doc. Proven behavior unchanged: embedded
  daemon, backend switch (AFM ⇄ OpenRouter), permission round-trip, verdict
  surfacing, snapshot restore.
- Doc ↔ runtime lifecycle: archiving the doc detaches the surface; the
  daemon is device-local (idle-exit, crash recovery); reopening re-attaches
  via the snapshot store.

### Phase 2 — Runtime seam + squad UX

- `AgentRuntimeHandle` union: embedded harness | ACP CLI (catalog: pi,
  opencode, claude-code, gemini, codex). One registry, one permission
  surface, per-binding settings.
- Task board UI: canonical rows (AE `ProblemRowWire`-compatible) so humans
  and agents read the same state. Batched transcript segments (never
  chunk-per-block — sync would die).
- Squad view (harness one-world/N-actors): who holds which file
  (single-writer), whose turn, per-actor verdicts.

### Phase 3 — Agent-friendly surface (IntentCall)

- Register core intents: `agent.doc.create`, `agent.task.delegate`,
  `agent.permission.answer`, `agent.task.guide` → MCP / deep links.
- pi (or any agent) drives last_answer headlessly: same world, same
  permissions, same oracles — the console moves INTO the app.
- Remote mover exposed: the daemon runs model-less; pi's model (or AFM) is
  the brain; last_answer owns loop, budgets, oracles.

### Phase 4 — One general (non-code) agent domain

- One prose domain (research or PRD doc) on the **evidence tier** — never
  the code-law `pass` tier. Different tool surface, different verification;
  proves "general agents" is real before any framework push.

### Phase 5 — Multiplayer (mesh)

- Board + transcripts sync across devices; task assignment and permission
  answers ride the existing round-trip; each device is a player, each agent
  a squad member on the device that owns its workspace.
- Future direction (needs its own ADR): **experience packs** — portable,
  host-verifiable projections of an agent's accumulated interactions
  (shared memory / personality across projects). No implementation until
  Phases 1–3 are proven.

## Non-goals

- No second protocol; no product types leaked into infrastructure packages
  (ADR 0003 composition law).
- No cross-workspace task coordination (yet); no generic topology engine
  (topology is declared data).
- No chunk-per-block transcript sync; no world snapshots in the doc store.
- No "agentify every doc type" before Phase 4 proves one evidence-tier
  domain.
