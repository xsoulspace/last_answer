# Unified views — top bar, tabs, pinning (analysis, 2026-11-02)

The owner's directive: *"right column and central column are views. Above it
we should have top bars with tabs — anything central and right needs to be
open [as tabs]. With ability to pin view."* Plus: **DOCS → FILESYSTEM** (it
is the filesystem view). This document is the requested analysis — Jony Ive
and Notion perspectives — before any code moves.

## 1. What the owner is actually saying

Today the window has **two tab systems and a gate**:

1. the CENTER strip (conversations, browser, inspector, newtab picker) —
   `shell.tabs.v1`;
2. the RIGHT column's own strip (People / Browser / Files / Terminal /
   Threads / Docs) — `ContextColumnController`;
3. a width gate + visibility toggle deciding whether the right column
   exists at all.

The owner collapses all of that into ONE concept: **a view**. The same
People view, Browser view, Filesystem view, conversation view can be:

- **open** — a tab in the ONE top bar (visible in the center);
- **pinned** — docked persistently beside the center (what the right
  column today is, minus its private tab taxonomy);
- later: **floating** (the miniwindow — ADR 0027) and **OS-windowed**.

The right column is not a *kind* of content. It is a *presentation*: the
dock where pinned views live. The center strip and the panel strip were two
names for the same object.

## 2. Jony Ive — the subtraction

- **Two tab strips are two mental models for one idea.** The user must
  learn which strip means what — an implementation detail (center pane vs
  context pane) leaking into the interface as structure. A view is a view;
  *where it lives is a decision, not a taxonomy.*
- **The gate is conditional structure the user must hold in mind** (it
  exists at ≥980px unless hidden; it remembers a toggle). Under the unified
  model the law is simpler and absolute: *the dock shows what you pinned;
  if you pinned nothing, there is no dock.* The window's width still gates
  the dock's FIT, never its EXISTENCE.
- **The top bar earns its height by being the single map of the session**:
  what is open, what is pinned, nothing else. Tabs as quiet text + ✕ +
  pin mark; the `+` opens the picker; the accent underline marks the
  focused view. Nothing else in the bar.
- Subtraction list that follows: `ContextColumnTab` (the private enum) —
  deleted; the panel's private strip as a *separate concept* — deleted
  (the dock keeps a thin pinned-views strip, but it renders ONE registry);
  the header toggle — repurposed from "show/hide the panel" to
  "unpin/pin the focused dock view" (the concept survives, the vocabulary
  becomes view-native).

## 3. Notion — content independent of container

- Notion's law: any page opens **full width**, in **side peek**, or in a
  **window** — the container is a choice the reader makes per moment, and
  content never changes identity when the container changes. Our Browser
  view today exists TWICE (a center spec and a panel tab) with two
  embeddings — under the unified registry it is ONE spec with two
  presentations, exactly the ADR 0027 shape already proven by
  `SurfaceSpec.builder`.
- **Side peek = pin.** Notion's peek exists to hold a REFERENCE beside the
  thing you work on. Pinning is the durable form of that: pin what you
  reference continuously (People while talking, Filesystem while working,
  Terminal while acting). The DEFAULT pinned set should reflect the working
  set, not a taxonomy: **People pinned by default; everything else
  unpinned.**
- **Views are blocks**: the SAME `SurfaceSpec` renders as tab, dock view,
  miniwindow content. ADR 0027 named this ("one surface, three
  presentations") — the owner's directive completes it: the top bar unifies
  the first two presentations, pinning is the bridge, miniwindows become
  "detach to floating".

## 4. The system (concrete)

**Views (one registry, `surfaces.dart`):**
conversations, browser, inspector, filesystem (RENAMED from docs; absorbs
the current Files view — the workspace folder tree is its root), people,
terminal, threads — plus conversation views (`dm:`/`channel:`). Every view
is center-tab-able; every STATIC view is pin-able. Conversation views are
pin-able too (a pinned dm: peek in the dock = the observability goal from
wave 3, landed in-dock).

**Layout state (one document, `shell.views.v2`, migrated once from
`shell.tabs.v1` + panel defaults):**

```
ViewLayout {
  tabs: [viewId]        // the top bar, in order (newtab picker included)
  active: int           // the focused center view
  pinned: [viewId]      // the dock, in order (deduped against nothing —
                        // a view may be BOTH pinned and open as a tab;
                        // Notion allows a page in peek AND in a tab)
}
```

Migration: existing `shell.tabs.v1` → `tabs`/`active`; People pinned by
default (the panel's current default tab); picker law unchanged.

**Laws:**
- One top bar above BOTH the center and the dock: `[tabs …] [+]`.
- Pin/unpin: a pin glyph on every static view's tab, and an unpin glyph on
  every dock view's header. Pin from tab → appended to the dock; unpin →
  removed (stays open as a tab if it was one, else just closes).
- The dock renders the PINNED views (thin strip of the pinned views' names
  + the focused one's content — the current panel anatomy, now generic).
- The rail is NOT a view: it is the navigation root (people are beings, not
  tabs) — unchanged, per the wave-2 law.
- Boot restore: tabs + pinned + active all restore; the picker never
  persists (existing law).
- Width: below 980 the dock hides (its pinned views remain open as state;
  the bar shows a dock glyph to focus one full-width) — the gate governs
  FIT, not existence.

**Renames:** `docs` → **filesystem** everywhere user-visible (picker hint:
"Browse the workspace's folder tree and files"); the Files view merges into
it as the workspace root. `ContextColumnTab` dies; keys migrate:
`shell.contextTab.*` → view keys (`view.tab.<id>` top bar,
`view.dock.<id>` dock).

## 5. Slices

1. **ViewLayout model + migration + top bar move** (center_tabs state
   becomes ViewLayout; the strip moves to the window's top bar, above the
   Row; the dock reads `pinned`).
2. **View unification** (people/terminal/threads/filesystem become
   SurfaceSpecs; DOCS→FILESYSTEM rename + Files merge; the dock hosts
   pinned specs; panel keys migrate).
3. **Pin affordances** (glyphs, dock/undock, defaults, tests).
4. **Design pass** on the new bar (the Linear law already in DESIGN.md).

Parallelizable: 1+2 sequential (same files), 3 after, 4 last (the loop).

## 6. What I propose NOT to do (v1)

- No drag-between-bar-and-dock (buttons only; drag is a named follow-up).
- No split center (the center stays one focused view; the dock is the
  standing second surface — unchanged law).
- No stacked dock (the dock shows one focused pinned view with a thin
  selector — Notion peek, not VSCode stacked panels).
- Terminal/Threads stay honest quiet states until they have real content.

## 7. The one open product choice — RESOLVED (owner, 2026-11-02)

**Dock anatomy: Safari tabs.** The owner's answer with a Safari tab-bar
screenshot (favicon pills, compress-to-icons under count, collapsible
groups): the dock is a **vertical Safari-style pill strip of pinned
views** — identity icon/avatar + short title when room, icon-only under
pressure, tap focuses, the focused pin's content fills the dock below the
strip. Pills sustain MANY pinned views cheaply (identity at a glance), so
pinning stops being a two-at-a-time compromise. The same compression law
governs the TOP BAR (title truncates → icon pill; the ACTIVE tab never
loses its title). Conversation GROUPING (a collapsible "Lab 4" pill with a
count, exactly the screenshot's "Figma 3") is the named follow-up — it
changes the tab model (tabs inside groups), so it lands after the
unification proves out.
