# ADR 0011 — Multiplayer sessions: parallel actors, mechanical branching, the queue as graph

- Status: **Proposed**
- Date: 2026-09-08
- North Star impact: `strengthens` — the MMO framing of value path 4/6
  (many actors, all local-first) and value path 2 (verifiable work: a
  mechanical actor is an oracle, not a hope).
- Builds on: [0003](0003-agents-live-in-docs.md) (runtime/world/actor
  ontology; actors are data), [0006](0006-session-is-not-world.md)
  (single-writer worlds, sessions as projections),
  [0007](0007-actor-roster-and-multiplayer-identity.md) (roster, presence
  keys, identity layering), [0008](0008-local-first-model-federation.md)
  (two-lane world law), [0010](0010-one-harness-doc-surface-unification.md)
  (one surface; the queue lives in `xsoulspace_agentic_doc`).
- Infra dependencies (referenced, never imported): agentic harness North
  Star (graph-native beat memory; the agency/mechanical split — "all
  other work is mechanical and never touches an LLM"; plans as derived
  projections, harness ADR 0009).

## Context

Conventional agent apps and CLIs model **one session per agent**: a
pipeline of turns between one human and one model, with the session as a
private channel. Our ontology (ADR 0003) never had this constraint — an
actor is *any agency-holding entity in a world*, and the harness already
runs on the stronger claim: the beat graph is the memory, mechanical
(deterministic, LLM-free) work is the default, and model calls are the
exception worth spending.

Two consequences were explicitly claimed by the owner (2026-09-08) and
had no decision recorded:

1. **Sessions themselves are multiplayer** — not one agent per session,
   but parallel actors (human, model, agent runtime, *mechanical
   actors*) sharing one session stage; sessions branch mechanically, by
   actor.
2. **The user message queue is part of the beat graph** — the harness's
   future mechanical projection mechanics can deterministically branch,
   validate, check, and guess what would work in future; queued user
   messages fall inside these branches, not beside them.

## Problem

Without a decision, the queue gets built as an app-level FIFO
(`ChatGPT-style` UX bolted beside the harness), and parallel agents get
shoehorned into N singleton sessions with N composers — reintroducing
the "session = private channel" category error ADR 0006 abolished, and
wasting the harness's graph-native determinism on a list.

## Decision

**D1 — A session is a multiplayer stage, not a 1:1 channel.**
A session hosts any number of actors concurrently (ADR 0007 roster;
presence keys `(peerId, actorId)`) — and "any" is load-bearing: models
on phones, web peers, and desktops, agent runtimes, mechanical actors,
and **several humans side by side**. A session with two humans, two
models on two devices, and a validator actor is the intended shape, not
an edge case. The composer is the *human's* row of the stage, not the
stage's owner — and with several humans, each human has their own. Parallel delegated tasks in one
session/world follow ADR 0006's single-writer law and ADR 0008's lane
law (Lane 1 code workspaces: one writer device, others contribute
remote actors; Lane 2 doc worlds: the CRDT kernel is the single world,
per-device actors publish move ops).

**D2 — Mechanical actors are first-class actors.**
An actor may be human, model, agent runtime — or **mechanical**: a
composable deterministic decision-maker (validator, repair-ladder step,
queue pump, branch checker). Mechanical actors run LLM-free (harness
law), appear in the roster like any actor, and their beats are honest
data (gutter label `MEC`, budgeted per DESIGN §10). This is the
composability that makes the harness powerful: deterministic behavior
is *composed into* the stage, not bolted around it.

**D3 — The queue is a graph region, not a list.**
The user message queue lives **inside the beat graph**:

- A steered (queued) message is a **queued beat anchored to the
  frontier** — visible, editable, cancellable (product semantics in the
  [conversation model](../product/conversation-model.md)).
- **Branching the frontier branches the queue with it.** A fork of the
  graph partitions queued messages per branch; the human selects which
  branch advances. The queue is therefore not FIFO but a **frontier
  with candidate continuations** — the mechanical projection machinery
  can validate/check/guess candidate branches deterministically
  (cost-free, LLM-free), and *promoting a branch remains a human act*
  (sovereignty; the golden rule: no silent rewrites of the head).
- Until the mechanical projection tier lands, the queue degrades
  honestly to a linear frontier (one branch, the drawn one) — the UX
  never promises a tree it cannot yet run.

**D4 — Attribution on the grid.**
Every beat and every queued row carries its actor's gutter label
(`YOU`, agent names, `SYS`, `PERM`, `MEC`). A mechanically-added beat
says so; a queued message says its queue state (`STEER`, position).
Unattributable action is a review blocker (DESIGN §6).

**D5 — Queues are lanes, and there are many.**
A queue is not one global list. A **queue is a directed actor→actor
lane**: a queued message is queued *for* a specific actor — the steer
target. One session runs many lanes concurrently: human→model,
human→mechanical, a second human→the same model, model→model
(delegation chains). Each lane has its own frontier and its own
observable state; every lane renders on the same grid, attributed per
D4 and layered per DESIGN §10 (a lane you are not addressing collapses
to an L0/L1 line; open it to L2/L3 when wanted). Branching partitions
**lanes**, not just rows. The default composer lane is
human→the session's active agent; every other lane is opt-in and
equally first-class. There is no lane the human cannot observe.

## Implementation mapping — the queue rides the frontier

Harness ADR 0009's amendment (2026-09-08, "the frontier IS the
prediction path") is the mechanical substrate this ADR predicted. The
mapping is direct:

| ADR 0011 concept | Harness ADR 0009 mechanism |
|---|---|
| A queued (steered) message | A **step** on the frontier graph: `claim` = the message text, `status: open`. Steps record *intent* (beats record what happened) — a queued message is exactly a step, not a beat. |
| Enqueue = consent | Consent is given at enqueue; a **mechanical actor (the queue pump)** may work consented ready steps — amendment item 3 (accelerate-and-predict), zero tokens. |
| Delivery of the next turn | Through the existing decision flow: `openFreshDecision` host-injected fresh decisions — **never a new loop** (amendment item 2). |
| `StepAction(toolName, arguments)` | The pump's delivery is a mechanical action slot (`deliver_user_turn`-shaped), resolved — not composed. |
| Branch candidates validated ahead of the model | `projectPlanFrontier` traversal over explicit edges; mechanical verification via `verify_step`-class predicates; `StepStatus` flips `open → verified/superseded`. |
| Edit queued / cancel queued | Edit the step's claim before it is worked; cancel = `superseded` (queryable — revision history preserved for free). |
| Send-now interrupt | Rejects the pending permission, stops the turn at the **beat boundary**, verdict lands with partial spend, then the immediate message is delivered via `openFreshDecision`. |
| Lanes (D5) | Per directed actor→actor frontier region; entries keyed `(from, to)`. First implementation: the default lane only, data-shaped so lanes are additive. |

Migration honesty: until `xsoulspace_agentic_doc` materializes queue
entries as frontier entities, the first implementation carries queue
state in the doc payload (durable, syncable) with step-shaped semantics
(`open | superseded | delivered`); the ADR 0011 graph gate ("no
app-level queue state survives snapshot/restore") is the migration
gate, not the first gate.

## Open questions

1. **Where does a branch of a not-yet-sent message live?** A queued
   message is text the user still owns; its branch candidates need a
   home in the doc store (child-node-of-queued-beat vs device-local
   staging). Decide with the `xsoulspace_agentic_doc` materialization
   design; the gate below does not require it.
2. **Lane identity in the doc store** — a lane is keyed by its directed
   actor pair (`from→to`); whether the pair is stored on the beat, the
   lane register, or both is a materialization decision for
   `xsoulspace_agentic_doc` (ADR 0010 D4).
3. **Parallel agents per session cap** — one model per actor is data
   (ADR 0007 `brainRef`), but concurrency limits per brain
   (`maxInFlight`) may serialize the stage. Treat as harness scheduling
   data, not product law.

## Gates

1. **Queue-graph gate**: two queued messages; a mechanical check actor
   validates a branch candidate; the human advances branch B; the queue
   state after the fork is derivable from the beat graph alone (no
   app-level queue state survives a snapshot/restore).
2. **Multi-lane, multi-human gate**: two human actors and one model in
   one session; each human queues into their own lane (different
   steer targets, one lane targeting the mechanical actor); every lane
   observable and attributed on every peer's grid; both verdicts land
   with their own spend.
3. **Parallel-actor gate** (extends PLAN 6.D): two model actors + one
   mechanical actor share one doc session; each beat names its actor;
   verdicts are per-actor; the roster shows all three.
4. **Headless queue gate**: the entire lane/branch state is readable
   through the profiler protocol (ADR 0009 D3) with no UI in the
   process.
