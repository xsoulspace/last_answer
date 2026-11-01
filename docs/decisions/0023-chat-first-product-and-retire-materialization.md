# ADR 0023 — Chat-first product; materialization retired; own ecsai agents first

- Status: Accepted (approved by Anton Malofeev, 2026-10-29)
- Date: 2026-10-29
- North Star impact: `refines` — the conversation surface becomes the single
  product entry; the document remains the shared state, and the harness
  materialization/proposal pipeline is retired as a product path.
- Builds on: [0012](0012-writable-agent-doc-and-acp-client-first.md)
  (writable shared documents, ACP direction), [0003](0003-agents-live-in-docs.md)
  (runtime/world/actor composition law),
  [0008](0008-local-first-model-federation.md) (local-first model federation —
  now realized through small local models rather than proposal
  materialization), [0019](0019-two-products-one-surface.md) (one product,
  density dial — Simple density wins by default).

## Context

The writable-document program ordered its consumer path (C0–C6) around a
proposal→review→materialize→verify pipeline for code workspaces. That
pipeline did not survive contact with real use: the materialization approach
failed, and its supporting machinery (meaning experiments, conventional
change proposals, candidate verification) drifted out of sync with the
evolving harness (ecsai) contracts — visible as the persistent meaning-lane
test failures in October 2026.

At the same time the repository accumulated three overlapping agent
surfaces (messenger chat, the harness grid with its setup toggle-wall, and
a dead inference-port seam), a conversation UI that exposed model/backend
configuration inline, and several visualization ventures (workshop, mesh
console, world inspector) that never became daily-use surfaces.

External agent availability sharpened the picture: the Gemini CLI path is
deprecated by product decision; Codex is reachable only through a
third-party ACP adapter that is currently broken upstream; and the local
model stack (qwen-class small models with LoRA adapters, served through the
ecsai world's native Metal runtimes) works with the small context windows
that hosted frontier models do not exercise.

The conversation substrate itself is landed in the harness (ADR 0115/0116
actor vocabulary): one authority law for all actors — internal bots and
external humans/agents alike — durable threads and beats with explicit
addressing (`say`/`wait`/`read`/`list` over the `thread` verb family),
`DurableRealmSeat` and `ProfileActorAuthority` for seated credentials and
profiles, and the local model casts (qwen, lfm) wired into the realm
worker. What remained undesigned at the time of the inference-experiment
fork was exactly the product shape of conversation directions between actor
kinds; this ADR records it.

## Decision

1. **Chat-first product — chat is actor-to-actor conversation.** "Chat"
   means conversations between actors in the ecsai world, in every pairing:
   internal↔internal, external↔internal, and external↔external (the human
   is an external actor; so is a coding agent like Codex). The surface is a
   projection of the world's durable conversation ability (threads + beats,
   explicit addressing: a beat wakes exactly the actors it names — landed in
   the harness as the `thread` verb family and `RealmActorSession`). A
   person converses with a bot the same way bots converse with each other
   and the same way one converses with Codex: open a thread, say, wait,
   read, work. The chat document surface
   (`lib/doc/chat_document_view.dart`) renders this projection; the harness
   grid, its SETUP toggle-wall, and the per-document backend pickers are
   retired from the main surface (code stays, unrouted).

1a. **Actors are created, not configured per chat.** A first-class product
   action — "create an actor" (a bot, like a grok bot): name, role, and a
   model binding from the declared palette (local qwen-class/LoRA casts or a
   remote entry from the configuration document), persisted as an
   `ActorProfile` in the actor roster (ADR 0007: kind model/agent/human,
   user-scoped, syncable). The conversation list shows actors and their
   threads; presence and addressing come from the world, never from a chat
   document's private metadata.

   > 2026-10-29 amendment ([ADR 0024](0024-actors-channels-and-panes.md)):
   > the product word "chat" is retired — actors and channels are the
   > objects; the shell is a pane tree; the durable-thread substrate is
   > unchanged.

2. **Configuration lives in Settings, never in the conversation.** One
   place — the Agents & Models settings pane over the single
   `agent_config.json` document (Zed-style, user-editable). The conversation
   surface shows exactly one model pill at the composer, backed by that
   configuration. One decision per screen: what to say, and which model
   answers.

3. **Own agents first.** The primary coding agents are OURS: actors in the
   ecsai world (the harness conversation seat), with configurable models —
   local (qwen-class, LoRA-adapted, small context windows — a first-class
   constraint the world already supports, not a bug to route around) and
   remote declared through the same configuration file. Codex remains an
   OPTIONAL external integration over ACP, clearly third-party, and never a
   dependency of the product. The Gemini path is deprecated: it stays
   out of default catalogs and pickers and receives no further investment.

4. **No Zed dependency.** Zed-published packages entered the codebase
   accidentally (agent catalog defaults, install commands). The product must
   not require any Zed component. Third-party entries in the agent catalog
   name their own install path as data, never as load-bearing dependency.

5. **Visualizations stop.** No further workshop, mesh-console, or 3D
   investment. The world inspector survives in one place: a Settings/menu
   entry, justified only when we need to observe the world to understand how
   it works. The mesh moves to Settings as well (pairing and relay are
   configuration, not surfaces).

6. **Materialization is retired.** No proposal→consent→materialize→verify
   pipeline work; the meaning-lane suites that encode it are skipped with a
   pointer to this ADR, not repaired. Agent file effects use the direct,
   permission-gated world tool path: an agent writes into its bound
   workspace where the write should land — landing correctness is the gate;
   code quality is the agent's problem. There is one writer rule still: the
   bound workspace the human chose.

7. **The three-conversation proof.** The product is "working" when:
   - **Conversation 1 (external↔internal)** — the human creates an internal
     actor (a qwen 0.6b-class + LoRA bot) and converses with it through the
     chat surface, inside the ecsai world. Small context window is the
     accepted, designed-for condition.
   - **Conversation 2 (workspace work)** — a chosen workspace is bound, the
     bound actor's ecsai tools perform coding work, and generated code —
     even broken code — lands in the right place in that workspace,
     visibly, with the permission round-trip intact.
   - **Conversation 3 (internal↔internal)** — two created bots exchange
     addressed beats in one thread and the surface renders both sides; the
     same primitive carries external↔external later (e.g. the human and a
     coding agent like Codex in one thread, or two external agents), which
     needs no new protocol — only external actors joining the same world
     threads.

## Acceptance direction

The existing chat lane is green (doc/agent_config suites, 2026-10-29), the
actor roster is landed (ADR 0007), and the ecsai world conversation and
consent/work-verb contracts are green in the harness; the work is the
wiring, not new protocol: render world threads as the chat surface, mint
actors through the roster with model bindings from the declared palette,
and the Settings-side model configuration. Navigation changes put the world
inspector and mesh pairing into Settings/menu. Each conversation above is a
human-executed gate recorded in the evidence ledger with the exact model,
adapter, and workspace.

## Non-goals

- No repair of the meaning/materialization lanes.
- No second protocol: ACP remains the only external agent vocabulary; the
  ecsai world seat is our own agent path, not a new wire protocol.
- No hosted-first claims: local models are the default first conversation;
  remote models are declared configuration, never silent fallback.
- No external ACP client connecting TO Last Answer (unchanged from
  [0012](0012-writable-agent-doc-and-acp-client-first.md)).

## Falsifier

This decision is wrong if, after the conversations above, the local
small-model path cannot hold a coherent coding conversation within its
context budget even for bounded tasks — i.e., if the small-window support
that motivated ecsai cannot actually carry the primary agent experience.
Then the own-agents-first ordering must be revisited against remote-model
configuration as the primary path.
