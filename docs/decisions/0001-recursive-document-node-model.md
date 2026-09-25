# ADR 0001 — Recursive Document Node Model

- Status: **Implemented** (v1 — block-granularity anchors, linear view, localDb + filesystem body storage)
- Date: 2026-02-06
- Implemented: 2026-08-24 (see `docs/evidence/current-status.mdx`)
- Supersedes: thread-as-message-list model (`DocThreadModel` keyed by `SpanId` inside
  `ProjectModelDoc`, see `packages/core/lib/src/data_models/project.dart`)

## Context

The current doc model stores threads as flat message lists inside the document object,
keyed by block ID. Discussion cannot nest, cannot contain structure, and has no path to
influence the head text. The product direction ([Documents — Goal & Pillars](/product/gdd-prd-editor-goal-and-pillars))
requires: any span opens its own document; children are themselves documents (recursion);
conclusions are pushed back by the author and children collapse into an archive;
formats are templates rather than sealed types.

Decisions settled in design discussion:

1. One node type. No `ThreadDoc` subtype.
2. No special merge machinery for collapsing: the author rewrites the head span manually
   or asks the agent to rewrite that exact part, then collapses the child.
3. Lazy resolution of descendants; light annotation on spans with unarchived children.
4. Agent writes at cursor / on selected part.
5. Templates are pre-saved docs; formats are metadata.
6. Storage capability decided per backend: **nesting of documents requires the
   filesystem backend**.

## Decision

### Node model

One unified node type for all documents:

```
DocumentNode {
  id: PersistentId
  kind: 'doc'                      // only 'doc' today; extensible later
  formatId: string?                // replaces DocKind {gdd, prd}; template metadata
  blocks: List<Block>              // typed blocks: heading | paragraph | list | …
  parentDocId: PersistentId?       // null = root/head document
  anchorSpan: AnchorSpan?          // required when parentDocId != null
  status: open | collapsed         // collapsed ⇒ archived, never deleted
  spanSnapshot: string?            // snapshot of anchored text at creation ("history note")
  createdAt, updatedAt
}

AnchorSpan {
  blockId: BlockId                 // block-granularity anchoring in v1
  prefixHash?: string              // reserved; sub-block UI is deferred for v1
  suffixHash?: string
}
```

Rules:

- **Recursion** falls out: a child is a full `DocumentNode`; its blocks are selectable,
  so it can open grandchildren. Depth is unbounded but navigated via a linear
  back-stack + breadcrumb first; tree/map are later _views over the same store_.
- **Snapshot on creation**: every child stores the text it anchored. Cheap, and
  future-proofs against edits, sync bugs, and storage migrations.
- **Collapse**: author applies the outcome to the head span (manual rewrite or explicit
  agent rewrite of that part), then sets `status = collapsed`. Collapsed children remain
  queryable forever; they are the document's creation history.
- **Agent writes** at the cursor or on the selected part when explicitly invoked. Agent
  output never silently modifies the head.
- **Lazy descendant info**: no eager tree materialization. A span shows a light
  annotation if it has non-collapsed descendants (resolved lazily).
- **Persistent IDs everywhere** (node id, block id). IDs must survive sync/export so
  anchors stay valid across devices and the planned migration to `~/xs/ecsly`.
- **Sub-block anchors are deferred for v1**: `AnchorSpanModel.prefixHash` /
  `suffixHash` exist as forward-compatible fields, but no user-facing sub-block anchor
  selection or resolution is implemented in v1.

### Formats & templates

- Remove the sealed `DocKind {gdd, prd}` enum from the model; replace with optional
  `formatId` metadata. Existing docs migrate: `docKind` → `formatId: 'gdd' | 'prd'`.
- GDD/PRD "creation" becomes instantiation of pre-saved template documents.
- `formatId` accepts custom string values, but format packs (template + suggested
  Select→Do actions + prompt hints) are deferred; no installable extension system is
  implemented for v1. Nothing format-specific lives in core models.

### Storage

- Capability matrix per backend: localDb may keep a single-project JSON blob, but
  **document nesting requires the filesystem backend** (one file per node, embeds as
  relative paths, children discoverable by reference). Design the repository interface
  against filesystem semantics now so backends converge instead of diverging.

## Consequences

Positive:

- Threads gain full document powers (structure, media blocks, their own threads) with
  zero new types.
- Creation history is preserved by construction (collapsed nodes persist).
- Formats/extensibility need no model changes — templates and metadata only.
- Views (linear, tree, map) become renderings over one store, not separate features.

Costs / risks:

- Migration needed: `DocThreadModel` → child `DocumentNode`s; `DocKind` → `formatId`.
- Anchor rot on edited heads — mitigated by creation snapshots shown as history notes.
- Deep recursion can disorient users until breadcrumbs/badges exist; ship navigation
  affordances with the first recursive flow, not after.
- Nesting gated on filesystem backend creates sequencing pressure on the storage work.

## Falsifier / review triggers

Revisit this ADR if any of these turn out true in practice:

- Users regularly need sub-block (character-range) anchors before block anchoring feels
  workable — then extend `AnchorSpan` (already shaped for it).
- Collapse-by-manual-rewrite proves too heavy (frequent long diffs) — then add a
  review-diff promotion action as an _addition_, keeping manual as default.
- Lazy descendant annotation performs badly on large graphs — then introduce a bounded
  eager index as a cache, not as source of truth.
