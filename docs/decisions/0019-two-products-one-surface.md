# ADR 0019 — Two products, one surface: one world at two densities

- Status: Accepted (direction; implementation gated per phase — see
  [PLAN.md](../PLAN.md))
- Date: 2026-10-21
- North Star impact: `clarifies` — ADR 0012's writable-document product and
  ADR 0015's one-state/many-projections law, resolved into one product at
  two densities over one world.
- Builds on: [0003](0003-agents-live-in-docs.md) (agents live in docs; the
  runtime union), [0010](0010-one-harness-doc-surface-unification.md) (one
  surface, one runtime; chat is a projection), [0012](0012-writable-agent-doc-and-acp-client-first.md)
  (the writable document/workspace is the product), [0015](0015-editable-workbench-projections.md)
  (project work is authoritative; views are projections), and the harness's
  [ADR 0104](../../../../ecsai_harness/docs/decisions/0104_declared_palette_realm_and_seat_grants.md)
  (declared palette, realm record, seat coding grant) and
  [ADR 0107](../../../../ecsai_harness/docs/decisions/0107_one_world_projects_as_scopes.md)
  (one world per realm, projects as scopes).

## Context

Three agent surfaces exist in the tree, and they disagree about what an
agent is.

1. `lib/doc/chat_document_view.dart` — a bubble chat (left/right alignment)
   backed by `ChatInferenceResolver` → OpenRouter/ACP directly. It runs no
   harness runtime: its tool beats are ACP session updates collected into a
   local map, its turn ownership is a local claim, and it produces no
   harness verdict and belongs to no world. It is a second runtime with its
   own composer, its own transport picker and its own permission policy.
2. `lib/coding_agent/agent_doc_surface.dart` — the grid, harness-backed.
   DESIGN.md's reference implementation.
3. `lib/coding_agent/world_inspector/world_conversation_view.dart` — the
   human seat in a live harness world: a conversation whose rows are owner
   receipts, with the seat's work verbs on the same grid.

The first surface is already out of law. DESIGN.md §Forbidden reads
"Bubble chat layouts (left/right alignment); the grid replaces them", and
§2 forbids bubbles in doc surfaces. ADR 0010 D1/D2 already decided that the
grid is the only conversation surface and that `ChatDocumentView` is
retired — but ADR 0010's status is still `Proposed`, and the retirement has
not landed: `DocFormatIds.chat` still routes to `ChatDocumentView` in
`lib/home/project_view.dart` today.

The result is a product with two different answers to "what is an agent",
and one of the two answers is forbidden.

## Decision

### 1. One product at two densities, not two products

Last Answer is ONE product with two densities of the same content:

- **Simple** — notes and ideas plus a normal-looking agent conversation,
  backed by the harness world. For an ordinary user it reads like a normal
  messenger and notes app.
- **Workshop** (the "Tiny Stark Workshop") — the SAME world rendered as a
  spatial and temporal surface: video-editor time scrubbing, a world of
  objects and beats.

A density is a reading of one document, never a second document, never a
second world, and never a second runtime. The Workshop renders the same
beats the grid renders; it does not re-implement them.

### 2. The grid is the single agent surface

The bubble chat is retired as a second product. "Ask an agent" routes to the
harness-backed grid. The retirement is compliance by REMOVAL: the
Forbidden list is unchanged, no exemption is added, and the surface's tree
mechanic (child-thread navigation) migrates into the grid, which already
carries it under ADR 0001/0010 D2.

### 3. One world behind both densities

Both densities read ONE harness world: realm `local`, with the Last Answer
canonical root enrolled as a project scope (harness ADR 0107 — a project is
a scope inside one world, never a second world). The Simple surface and the
Workshop observe the same beats, claims, permissions and verdicts. A density
change never changes what the world contains.

### 4. The L0–L3 ladder is the density dial

DESIGN §10's ladder IS the dial between the two densities: the Simple
product is the grid collapsed toward L0/L1; the Workshop opens the same
content spatially, at the depth the user asks for. There is no "simple mode"
toggle — §10 states it as law: "Attention dials, not a mode."

### 5. Setup is a toggle, never a landing

Setup (workspace, backend, API key) is never the first screen a user lands
on — bound or not. It is a toggle on the status rule: always reachable,
never forced. It collapses again the moment the document becomes bound, and
the human reopens it from the status rule whenever they want it. The
binding state stays visible on the status rule at all times.

This resolves an older §4 clause that setup "auto-opens only until the doc
is bound (onboarding)". An auto-open is a forced surface, and the same §4
requires setup to be "always reachable, never forced". The Simple product's
first screen is the document, so §4 is amended to say so directly.

## Consequences

- One truth about what an agent is. An agent is a participant in one world
  (ADR 0003); the surfaces are projections of it, not peers.
- The harness stays invisible to ordinary users. The Simple product must
  read like a normal messenger and notes app; the harness layers remain the
  only things collapsed or gated (DESIGN §10), and a harness concept must
  never become mandatory reading for writing a note.
- The Workshop is a projection of the same beats, not a parallel
  implementation. It inherits the world's authority rules unchanged and
  grants none of its own.
- The grid gains the work verbs the bubble chat never had — `task_delegate`,
  `resource_bind`, `tool_action` — so the seat can bind a declared palette
  entry, delegate work and run an allowlisted tool from the same surface
  that carries the conversation.
- The bubble chat's tree mechanic survives in the grid. Retirement means
  the mechanic migrates, not that it dies.
- The document model does not fork. One document, one world, two densities.

## Non-claims

- The shared-world journey is **Partial**, per the
  [shared-seat record](../../../../ecsai_harness/docs/evidence/shared-seat-2026-10-19/README.md)
  and [shared-world-status.md](../product/shared-world-status.md). Two
  densities is a product decision taken on top of a Partial journey; it is
  not evidence that the journey is accepted, and it closes none of the
  named open items (independent session admission, internal-to-external
  delegation, verified visible change through host promotion, deliberate
  resource interruption, conflict-aware change-targeted Undo).
- No claim that a `:free` model is a competent coding mover. Harness
  ADR 0104 records the only measured `:free` arm at 4/20 on the coding
  suite with recorded 429s, and holds `:free` as an explicit comparison
  column, not the standing mover.
- The Workshop surface (Phase 3) and concurrent candidates (Phase 4) are
  **not shipped**. They are planned work with named gates; nothing in this
  ADR may be cited as evidence that either exists.
- No claim that the bubble chat's TREE MECHANIC is migrated. The bubble
  chat view and its direct-to-provider resolver are deleted and every agent
  entry routes to the grid; the child-thread mechanic it proved is still
  work in progress on the grid.
- No claim of shared-world adoption beyond the realm route as it stands
  (realm `local` enabled, Last Answer's canonical root enrolled as a
  project scope). This ADR decides the product shape, not the qualification
  of the underlying lane.

## References

- [DESIGN.md](../DESIGN.md) §1 (the document is the interface), §4 (the
  human is sovereign; setup is a toggle, never a landing — amended by this
  ADR's §5), §10 (attention is a budget; the L0–L3 ladder; "attention dials,
  not a mode"), §Forbidden (bubble chat layouts; the grid replaces them).
- Harness [ADR 0104](../../../../ecsai_harness/docs/decisions/0104_declared_palette_realm_and_seat_grants.md)
  (declared palette, realm record, seat coding grant; the measured `:free`
  arm) and [ADR 0107](../../../../ecsai_harness/docs/decisions/0107_one_world_projects_as_scopes.md)
  (one world per realm, projects as scopes).
- [shared-world-status.md](../product/shared-world-status.md) — the Partial
  shared-world status this ADR is written against.
- LA ADR [0003](0003-agents-live-in-docs.md) (agents live in docs),
  [0010](0010-one-harness-doc-surface-unification.md) (one surface, one
  runtime; chat is a projection), [0012](0012-writable-agent-doc-and-acp-client-first.md)
  (the writable document/workspace is the product), [0015](0015-editable-workbench-projections.md)
  (project work is authoritative; views are projections).
- [two-products-one-surface.md](../product/two-products-one-surface.md) — the
  product description of the two densities.
