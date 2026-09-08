# ADR 0010 — One harness: doc surface unification, profiler adoption, format law

- Status: **Proposed** (gates in §Gates; deletion round may proceed
  immediately — it is subtraction and needs no new machinery)
- Date: 2026-09-08
- North Star impact: `strengthens` — value path 3 (text-first surfaces)
  and the design law's "one state, many projections"; kills the largest
  surviving duplication of harness truth.
- Builds on: [0003](0003-agents-live-in-docs.md) (runtime union, ACP
  vocabulary), [0009](0009-session-registry-and-many-worlds-debug-state.md)
  (registry before relocation), [0001](0001-recursive-document-node-model.md)
  (recursive document model), the pillars doc
  (`docs/product/gdd-prd-editor-goal-and-pillars.md` — "formats are
  templates, not types"), harness ADR 0015 (domains live in hosts, core
  stays generic).
- Infra dependencies (referenced, never imported):
  `xsoulspace_agentic_harness` (core), `xsoulspace_agentic_host` (daemon,
  runner, backend bindings), `xsoulspace_inference_*` (providers),
  `xsoulspace_agentic_harness_flutter_profiler` (profiler).

## Context

The product currently ships **two conversation surfaces with two
runtimes**:

- `AgentDocSurface` (`lib/coding_agent/agent_doc_surface.dart`, 2.3k
  lines) — the DESIGN-law reference implementation: one grid, role
  gutter, live beats, verdict rule, PROFILE/SETUP panes, MCP intent
  seam. Runtime: `HarnessSessionController` → harness daemon.
- `ChatDocumentView` (`lib/doc/chat_document_view.dart`) — a second,
  smaller conversation surface with its own composer and runtime
  (`AcpAgentRuntime`), but with the **tree mechanic already proven**:
  breadcrumb navigation into child nodes (`_path`), per-message
  controllers.

In parallel, harness truth is duplicated: last_answer owns
`AgentDocDebugState`, a private profiler pane, and private MCP verbs —
while `xsoulspace_agentic_harness_flutter_profiler` exists to render
"live decision stack, beat status, loop warnings, and the meaning cut
the model sees" per harness ADR 0015. The duplication pattern this
decision kills in the UI (GDD/PRD/Chat species) exists at the package
layer too.

GDD and PRD, the two shipped `formatId` values besides `note`/`idea`/
`chat`/`agent`, were **never used in production** (owner, 2026-09-08).

## Problem

- A user must know the difference between four document species before
  writing a word. This violates the goal sentence ("the user doesn't
  need to know the difference — the difference is mechanical") and
  taxes attention at every entry point.
- Two conversation surfaces drift: the tree mechanic lives in the
  weaker surface; the grid/verdict/permission discipline lives in the
  other. Neither is the product.
- last_answer re-implementing profiler state means two readers see two
  truths about the same session — exactly what DESIGN §5 forbids.

## Decision

**D1 — One surface, one runtime.** `AgentDocSurface` (the grid) is the
only conversation surface. `HarnessSessionController` is the only
runtime; ACP CLI agents are **bindings behind the runtime seam** (the
Phase-2 `AgentRuntimeHandle` union — embedded harness | ACP CLI). The
ACP runtime becomes a backend binding, never a competing surface.

**D2 — Chat is a projection, not a type.** Conversation emerges
mechanically:

- A turn is **message materialization**: while live, the turn renders
  as today (beats, `···`, locked composer); when the verdict lands the
  turn **cools** into authored text nodes in the doc store.
- Cooled turns are editable like any paragraph. History stays in the
  main view, chronological. Any span of any turn (live or cooled) is
  selectable → child document thread (ADR 0001) — the full recursive
  mechanic, proven by `ChatDocumentView`'s breadcrumbs, absorbed into
  the grid.
- `ChatDocumentView` is retired; `DocFormatIds.chat` survives as opaque
  legacy metadata (reads fine, no longer mints a distinct surface).

**D3 — Format law: the field stays, the values go.** `formatId` remains
an opaque string (`''` default) for the future extension/template
system (pillars doc pillar 4). The **starter-template concept ships
nothing today**: no shipped values, no creation-time choice. GDD and
PRD are deleted entirely — ids, seed constructors
(`packages/core/lib/src/data_models/project.dart`), bar items and
notifier methods (`vertical_projects_bar.dart`, `home_screen.dart`,
`opened_project_notifier.dart`), and their widget tests. **No data
migration** (owner, 2026-09-08): production runs ideas and notes only;
nobody uses GDD/PRD/chat.

**D4 — last_answer must not own harness truth.** The PROFILE pane and
`debugState` migrate to the profiler package; last_answer's surfaces
become **adapters** over it:

- `xsoulspace_agentic_harness_flutter_profiler` gains a pure-Dart
  protocol layer (typed snapshots: beats, context assembly, the meaning
  cut, permissions, spend; MCP-verb bindings) beside its Flutter panes —
  headless consumers and grid panes are equal readers of one truth
  (ADR 0009 D3).
- Doc-specific glue extracts to a **new package**,
  `xsoulspace_agentic_doc`: turn ↔ `DocumentNode` materialization, span
  anchoring, child-thread lifecycle, cooled-turn rules, queue-graph
  mechanics (ADR 0011). It consumes harness + host + inference. No UI
  lives there.

**D5 — Capability flags gate harness surfaces per doc and per user.**
The inspector and harness layers are opt-in visibility:
`inspector: none | summary | full` and per-view toggles. Gating decides
**existence**; view toggles decide **openness** (DESIGN §10). Default
for a plain doc: harness machinery invisible until first used.

## Open questions

1. **Interim dual-backend**: does the doc surface host ACP CLI agents
   directly during migration (before the `AgentRuntimeHandle` union
   lands), or does chat retirement wait for Phase 2? Lean: wait — one
   runtime from day one of the merged surface.
2. **RESOLVED (2026-09-08, owner): skip all migrations.** GDD, PRD and
   chat formats have **no production users** (production runs ideas and
   notes only). No conversion path is built: GDD/PRD ids are deleted
   outright (D3); legacy `chat` docs read as plain docs with opaque
   `formatId` metadata — no re-materialization, no conversion step.

## Gates

1. **Deletion round green**: GDD/PRD ids, seeds, bar items, notifier
   methods, tests removed; `fvm flutter analyze` + `fvm flutter test`
   green; rail slimmed (see [conversation model](../product/conversation-model.md)).
2. **Merge gate**: one scripted e2e where a plain doc gains a delegated
   task turn, the turn cools, a span of the cooled turn opens a child
   thread, and the thread conclusion is applied to the head span — all
   through the grid surface, zero new protocol.
3. **Profiler adoption gate**: `agent_doc_state` (and the PROFILE pane)
   render from the profiler package's protocol layer with last_answer's
   private debug-state model deleted; MCP verb contracts unchanged
   (ADR 0009 D2).
