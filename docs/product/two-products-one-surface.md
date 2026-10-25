# Two products, one surface — the two densities

> Product description of the decision recorded in
> [ADR 0019](../decisions/0019-two-products-one-surface.md). The ADR is
> binding; this file describes what the user sees. Design law:
> [DESIGN.md](../DESIGN.md).

Last Answer is ONE product at two densities. Not two products, not two apps,
not two data sources. The same document, the same harness world, read two
ways.

## The Simple product

Notes and ideas plus a normal-looking agent conversation, backed by the
harness world. For an ordinary user it reads like a normal messenger and
notes app: you write, you ask an agent, it answers.

- The agent conversation is the harness-backed grid
  (`lib/coding_agent/agent_doc_surface.dart`). There is no separate chat
  product. "Ask an agent" lands on the grid.
- The harness stays invisible. Beats, verdicts, permissions and spend are
  collapsed layers, never mandatory reading for writing a note (DESIGN §10).
- Setup (workspace, backend, API key) is never the first screen. It is a
  toggle on the status rule — always reachable, never forced — and it
  collapses again the moment the document becomes bound; the binding state
  stays visible on the status rule (DESIGN §4, ADR 0019 §5).

## The Workshop (the "Tiny Stark Workshop")

The SAME world rendered as a spatial and temporal surface: video-editor
time scrubbing over a world of objects and beats.

- It is a projection of the same beats the grid renders, at a different
  depth and a different geometry. It holds no separate truth, no separate
  authority, and no separate runtime.
- The depth between the two is the DESIGN §10 ladder (L0 status rule, L1
  progress, L2 beats, L3 full). The ladder is the dial: the Simple product
  is the grid collapsed toward L0/L1; the Workshop opens the same content
  spatially.
- There is no "simple mode" toggle and no "workshop mode" toggle. The
  ladder is a set of attention dials, not a mode (DESIGN §10).

## Moving between them

Both densities read ONE harness world: realm `local`, with the Last Answer
canonical root enrolled as a project scope (harness ADR 0107). A project is
a scope inside one world, never a second world.

The user moves by changing depth, not by changing product. The same
conversation, the same beats, the same claims and permissions — read as
text, or read as a world. Switching density never changes what the world
contains, and never changes who may act on it.

## What is built today vs planned

|                                                                                                                                      | Status                                  | Gate            |
| ------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------- | --------------- |
| Grid as the single agent surface; the Simple profile on it (setup off the first screen, collapsing on binding)                       | **Landed in the tree; not live-proven** | PLAN.md Phase 1 |
| Seat work verbs on the world conversation seat — `task_delegate`, `resource_bind`, `tool_action` — and a palette-backed model picker | **Landed in the tree; not live-proven** | PLAN.md Phase 2 |
| Workshop foundation: trace DTO v2, `world-at-T` checkpoint/replay, bounded rendering, exploded layers                                | **Planned, not shipped**                | PLAN.md Phase 3 |
| Concurrent candidates: N live candidates from one request                                                                            | **Planned, not shipped**                | PLAN.md Phase 4 |

The bubble chat (`lib/doc/chat_document_view.dart`) and its
direct-to-provider resolver are deleted. `DocFormatIds.chat` survives as
opaque legacy metadata and opens the harness-backed grid; its tree mechanic
migrates into the grid, which already carries it (ADR 0010 D2, ADR 0019 §2).

## Non-claims

- The shared-world journey is **Partial**
  ([shared-world-status.md](shared-world-status.md)). This product shape
  does not make it accepted and closes none of its named open items.
- No claim that a `:free` model is a competent coding mover. Harness
  ADR 0104 records the only measured `:free` arm at 4/20 on the coding
  suite with recorded 429s.
- The Workshop surface and concurrent candidates do not exist yet. They are
  planned work with named gates, not delivered capability.
