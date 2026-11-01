# ADR 0027 — Miniwindows: one surface, three presentations

- Status: Accepted (owner-approved design direction; recorded 2026-10-30)
- Date: 2026-10-30
- North Star impact: `refines` — the writable shared workspace gains a
  window class: the same surface can be watched in a small pane while
  the user works elsewhere, and actors' actions become observable
  without rearranging the shell.
- Builds on: [0024](0024-actors-channels-and-panes.md) (panes, not a
  fixed center), [0026](0026-workspaces-multi-root-nesting-as-graph.md)
  (format; the workspace container these windows float above),
  [DESIGN](../DESIGN.md) §2–3 (quiet chrome, hairlines) and §8 (widget
  keys are the UI contract).

## Context

The owner's model: ONE surface, THREE presentations — a right-panel
tab, a center tab, and a WINDOW. Whatever a surface shows (an agent
conversation, an inspector, later: harness world data per actor) must
be watchable in a small window the user parks beside their work,
several at a time. Flutter desktop multi-window is still immature —
no stable in-framework API, and every candidate package is a
platform-channel science project — but the window *interface* is
already stable: open by id, close, move, focus, z-order. That
interface can be proven now with zero new dependencies.

## Decision

1. **One surface class, three presentations.** A surface is a stable
   id (`dm:iris`, `inspector`) plus a content builder and an initial
   size (`MiniWindowSpec`). Panel tab, center tab and window are views
   of the same class; the controller interface is
   presentation-independent and outlives any one presentation.

2. **v1 is the floating in-app overlay.** `MiniWindowLayer` stacks the
   open windows above the app's child: opaque surface fill, one
   hairline border (theme `outlineVariant`), a small-caps title bar
   that doubles as the drag handle, a quiet `✕` close, clipped
   content. Windows intercept gestures only inside their bounds.
   `MiniWindowController` is a plain `ChangeNotifier` (no Provider
   scope — the integrator supplies it): `open` (idempotent on id —
   re-opening focuses the existing window and keeps its original
   spec), `close`, `moveTo`, `focus`; z-order is list order, last is
   front. Drags clamp loosely (≥56 px of the window stays visible
   horizontally; the title bar stays reachable). When a real OS-window
   backing arrives, it implements this same controller contract and
   callers do not change.

3. **Keys are the contract** (DESIGN §8): `miniwindow.<id>` (window
   root), `miniwindow.<id>.close`, `miniwindow.layer`. Tests and agent
   drivers use the real keys.

4. **v1 is session-scoped.** No persistence: positions and z-order die
   with the app run. This is a deliberate cut, not an oversight.

## Non-goals (this slice)

- **No real OS windows.** The floating overlay is the first cut of the
  window presentation; a native multi-window backing is a named
  follow-up once Flutter desktop multi-window matures (or a package
  proves itself). No window package is added now.
- **No resize.** v1 windows are fixed at `initialSize`; resize handles
  are a follow-up.
- **No persistence** of positions or z-order (decision 4).
- **No harness content binding yet.** Harness world data (presence,
  tasks, claims per actor) lands behind a content seam — the spec's
  builder — in a later wave. Deliberately not now: the ecsai harness
  is mid reliability-refactor (its `changesSince` streaming fix is
  unverified; the `task_delegate` verb was removed by its ADR 0118),
  and Last Answer binds only stable surfaces.

## Falsifier

This decision is being violated — revise rather than layer — if a
second window concept appears beside `miniwindow.*` (a parallel
"popup"/"palette" class with its own controller), if the three
presentations fork (a tab presentation re-implements the chrome or
duplicates the controller instead of consuming the same
spec/controller), or if the v1 class grows window/resize package
dependencies before the controller interface has proven itself. A
presentation that stops passing gestures through to the app below
outside its bounds is a bug, not a variant.
