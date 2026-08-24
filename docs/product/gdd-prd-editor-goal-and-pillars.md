# Documents — Goal & Pillars

> Supersedes the earlier "GDD / PRD Editor — Goal & Pillars". GDD/PRD are no longer
> product types; they are the first two **format templates** of a general recursive
> document system.

## Goal (one sentence)

**The document is the product: you write, select any span, and that span opens its own
document — a discussion you can dive into recursively and collapse back into the head,
without ever leaving the surface.**

---

## Problem we solve

- Discussing a fragment means leaving the doc: comments live in another UI, AI in
  another app. Context is lost; round-trips add friction.
- Threads-as-comment-lists dead-end: the outcome of a discussion has no way to *become*
  the text. The conversation and the document diverge.
- Fixed doc types (GDD, PRD, note) don't scale: every new format would be a feature.
- Future media (images, video, generated assets) don't fit a text-only block model.

We want a **recursive document**: a document whose any span can open a child document;
the child is itself selectable; conclusions are pushed back into the head by the author.

---

## Pillars

These five pillars define what "done" looks like and how we make decisions.

### 1. The document is the product — edit freely

- **What:** Free, fluid editing. Optional structure (headings, lists) supports formats
  without getting in the way. The doc is always the source of truth.
- **Success:** Editing feels as fluid as the best notes experience.
- **Why:** If editing isn't free, users leave the surface and the goal collapses.

### 2. Select → Do (the 10x interaction)

- **What:** Selection defines scope. Selecting (or focusing) a span surfaces a small
  contextual action set: Discuss, Ask AI, Expand, Summarise, plus refinement tools
  (Find root cause, Test one change, … — see [refinement tools](/product/refinement-tools)).
- **Success:** One gesture, no mode switch, first action < 300 ms.
- **Why:** This is the entry point to recursion. Without it, threads are buried UI.

### 3. Discussion is writing — threads are documents (recursive)

- **What:** Every span can open a **child document** — not a comment list. The child is
  a full document: editable, structured, itself selectable, so it can open children of
  its own. Every child stores a **snapshot of the span it anchors** (a history note),
  so the origin survives later edits.
- **Lifecycle:** each child is `open` while being worked on; when its conclusion is
  applied, the author updates the head span (manual rewrite, agent rewrite of that
  exact part, or direct typing) and marks the child `collapsed`. Collapsed children are
  archived, never deleted — the creation history is part of the product.
- **Views, not modes:** linear reading (vertical scroll), page flow, tree, map — all are
  **views over the same node store**, added gradually. We start with a simple vertical
  scroll + breadcrumb back-stack; deeper views (tree/map) come later.
- **Discovery at depth:** breadcrumbs ("Act 2 › why this scene fails › counterargument"),
  thread-count badges on spans, and a light annotation on spans with un-archived
  descendants (resolved lazily).
- **Success:** Diving into a span and climbing back feels like turning pages, not
  managing windows; nothing is ever lost.
- **Why:** This converts discussion from metadata into authored content.

### 4. Extensible formats — templates, not types

- **What:** There is one document node type. A **format** is optional metadata
  (`formatId`) plus a **template** — a pre-saved starter document — and optionally a set
  of suggested Select→Do actions. GDD and PRD are the first two templates. Users can add
  their own formats (extension/skill mechanism, pi-style runtime modding).
- **Success:** Creating a "PRD" is instantiating a template; installing a new format
  requires no app release.
- **Why:** Formats as sealed enums would kill the ecosystem story.

### 5. Pluggable inference (AI)

- **What:** The app depends on an **inference interface**, not a provider (implementations
  in packages, e.g. `xsoulspace_inference`). The agent participates inside documents: it
  writes **at the cursor or on the selected part** when asked. Agent output lands in the
  open context (thread document / selection); promoting it into the head is always an
  explicit human act.
- **Success:** Ask AI on a span → result appears in place; adopting it is one visible
  action. No vendor lock-in, no silent rewrites of the head.
- **Why:** Trust and optionality keep teams on the one surface.

---

## How the pillars work together

| User intent                  | Pillar(s)        | Outcome                                                        |
| ---------------------------- | ---------------- | -------------------------------------------------------------- |
| Write / restructure          | 1                | Doc updates immediately; source of truth.                      |
| "Discuss this span"          | 2 + 3            | Child document opens anchored to the span; stay on the surface.|
| Dive deeper into a reply     | 3                | Recursion: the child is selectable too.                        |
| Conclusion reached           | 3 (+5)           | Head span rewritten (manually or via agent); child collapsed & archived. |
| "Start a PRD"                | 4                | Instantiate the PRD template doc.                              |
| Install a new format         | 4                | Runtime extension adds template + actions.                     |
| "Ask AI about this"          | 2 + 5            | Selection + context → inference; output lands in place.        |

**Golden rule:** If a feature makes the user leave the document surface to discuss,
use AI, or change format, it violates the goal. Second rule: the head is edited by the
author (or by an explicitly requested agent rewrite of a chosen part) — never silently.

---

## Non-goals (for this phase)

- Real-time multiplayer/presence.
- Cloud sync of document contents (privacy-first, on-device; filesystem backend enables nesting).
- Character-precise sub-block anchors — **block-granularity anchoring ships first**; finer spans come after the recursive model proves out.
- Tree/map views — the node store is built view-agnostic, but only linear/scroll views ship initially.

## Roadmap notes (block types & media)

Block types are open-ended from day one: `heading`, `paragraph`, `list` now; `image`,
`video`, `embed-link`, `generated asset` next. This unlocks the long-term direction of
working with movies/images (generating media as first-class blocks), which pairs with
the filesystem storage migration.

## References

- Data model & lifecycle: ADR — Recursive Document Node Model (`docs/decisions/0001-recursive-document-node-model.md`).
- Refinement actions: [Decision & refinement tools](/product/refinement-tools).
- Storage direction: filesystem universal storage (per-backend capability matrix).
