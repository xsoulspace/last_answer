# Shell redesign — rail, views, per-view tabs (2026-11-05)

Status: **proposal** (owner-directed analysis). Supersedes nothing; amends the
direction of [unified-views.md](unified-views.md) and
[shell-de-material-plan.md](shell-de-material-plan.md) where named below.
Evidence base: live app (debug build, 2026-11-05), `fmtk` captures
(`flutter_layer` + `desktop_window`), `semantic_snapshot`, code reading of
`lib/shell/*`, `lib/coding_agent/*`, `packages/core/lib/src/theme/*`, and a
full surface inventory of `lib/`.

## 0. The fast loop (how this analysis should be done, and how the rebuild will be verified)

The 2026-11-05 analysis pass lost most of its time to OS-level workarounds
(AppleScript clicks, window hunting across displays, screen-region captures).
None of it was necessary. The toolkit already ships the right verbs:

| Need | Tool | Notes |
|---|---|---|
| Screenshot while iterating | `fmtk exec --name get_screenshots --args '{"mode":"flutter_layer"}'` | VM-based, captures the Flutter layer only. Independent of window position, display, focus, and Screen Recording permission. Works with the window off-screen or occluded. |
| Truth capture (final check) | same, `{"mode":"desktop_window"}` | The macOS host capture. Exists for apps whose surfaces are **native-only** (or to prove native overlays like the embedded webview). Needs `--flutter-device macos --flutter-project-dir …` + Screen Recording. Use once per phase, not per iteration. |
| Edit → see | `fmtk exec --name hot_reload_and_capture` | One call: hot reload + capture. This is the design-TDD loop; a shell change is provable in seconds. |
| Interact | `semantic_snapshot` → `tap_widget` / `enter_text` / `press_key` / `hover` | Refs are session-scoped to the last snapshot. **Blocked today by finding D2** (the chrome exposes no semantics); Phase 2 unblocks it. |
| Navigate state | the app's own MCP tools (`realm_chat_open_dm`, `app_navigate`, `app_inspector`, `agent_doc_create`, `browser_window`, …) | Integration-level drivers; ~60 registered. They are also the acceptance surface: whatever a tool can do, a human must be able to do from chrome. |
| Regression | `snapshot create --check --diff`, `get_app_errors` after every capture | UI-state diffs + runtime error budget as gates. |
| CI-like gate | `tool/gates/*` + `flutter_mcp_harness` scenarios | The repo already pins the harness; add a `gate-shell` scenario per phase. |

Rule for the rebuild: **no OS automation (System Events / universal-automation)
in the loop at all.** If a step needs it, the app is missing a seam (semantics,
shortcut, or MCP tool) and that missing seam is itself a defect to fix.

### Why `flutter_layer` was not used on 2026-11-05 (answer to the owner's question)

`get_screenshots` with `mode` omitted runs the toolkit's **auto** policy: on a
macOS host with Screen Recording granted it prefers `desktop_window` as the
"truth" mode, because `flutter_layer` cannot see native surfaces (the embedded
webview, native dialogs) — that mode was introduced exactly as the workaround
for apps whose UI is native-only. Last Answer is Flutter-first, so for
*iteration* the preference is backwards: `desktop_window` dragged in window
position (the window sat at x=-853 on a second display), focus races, and
permission preflights, while `flutter_layer` needed none of it and returned a
clean capture on the first explicit ask. Auto is right for truth checks;
explicit `flutter_layer` is right for the loop. The 2026-11-05 pass never asked
explicitly — that omission, not a toolkit limitation, caused the detour.

## 1. Diagnosis — why the current build "works very strange"

### D1. The visual identity does not exist in code
- `packages/core/lib/src/theme/material_theme.dart:9,26` ships **stock
  `ThemeData.light()` / `ThemeData.dark()`**; the seeded themes built from
  `AppColors.primary1` are commented out. The DESIGN.md token table
  (`canvas #0B1114`, `surface #111A1E`, `accent #8DDCC2`, type scale) has
  **zero hits** in `lib/` and `packages/core/lib/` — it is prose only.
- Consequences visible in captures: the active-tab underline and pin accent are
  **Material default purple**; surfaces are one flat near-black with no
  layering; the macOS titlebar band renders **olive-green** (a leftover of the
  pre-pivot palette path) — the only saturated color in the app is an accident.
- Three competing palettes coexist: stock Material seed, legacy `AppColors`
  green/red (Figma-era brainstorming app), procedural actor HSL
  (`actor_avatar.dart:29-82`), plus ~43 literal `Colors.*` / hex leaks.
- The core text theme is `@Deprecated GoogleFonts.notoColorEmojiTextTheme()`
  (`app_text_styles.dart:3-4`) — bypassed only because the seeded bases are
  unused.
- The tab label renders UPPERCASE ("CONVERSATIONS") while the shell's own law
  (`shell_theme.dart:39-41`) forbids case tricks for hierarchy.

### D2. The de-Material pass removed semantics with the Material
`semantic_snapshot` over the whole running shell returns **four nodes** (two
empty-state texts, the People pin, one unlabeled button). The rail rows, tab
pills, dock pills, `+` button and search field are bare
`MouseRegion`+`GestureDetector` containers (`shell_theme.dart:91-144`,
`center_tabs.dart`, `view_dock.dart`) with no `Semantics` wrapper: invisible to
screen readers, to `tap_widget`, and to any agent driving the UI. The
"widget keys are the agent's UI contract" law (DESIGN §6) is satisfied by
`ValueKey`s that only tests can see. Keyboard is equally thin: `⌘T` dispatched
through the engine reports `handled: false` whenever the shell's `Focus` is not
the primary focus owner — the shortcut contract is focus-fragile.

### D3. The structure drifted away from the original idea
The intended model was: **left rail + views (Zed/VSCode anatomy), each view
owning a Safari-like tab strip**. WAVE 5 collapsed that into ONE global top tab
bar spanning the window plus a right dock of pins. Observed costs:
- Tabs no longer belong to a view, so "open Boards in a second tab" and
  "two documents side by side" are unexpressible; the bar mixes view kinds and
  conversation identities in one strip.
- The dock duplicates the center (capture: the same empty sentence rendered
  twice, 400 px apart) and adds a second taxonomy (tab vs pin vs dock-focus)
  for one layout state.
- The default landing is a **void**: center and dock both say "Select a
  conversation from the rail." Nothing about the user's work is visible on
  open — no open permissions, no running tasks, no recent verdicts, no last
  document. North Star §6 ("every state renders") is violated by the first
  state the user sees.
- Settings cannot be a view (its close button pops the route), so the one
  place operators configure agents lives outside the shell grammar.

### D4. The operator cycle is half-missing for humans, fully present for agents
- The app registers ~60 MCP tools (`app_navigate`, `realm_chat_*`,
  `agent_doc_*`, `doc_state`, `mesh_tasks`, `browser_window`, storage/mesh
  verbs). An agent can open documents, delegate, answer permissions, read
  verdicts. **A human clicking the shipped shell cannot open a document at
  all**: the projects list was retired and nothing replaced it; routes exist
  (`router.dart:36-59`) but no chrome reaches them.
- `terminal` and `threads` views are placeholder sentences
  (`surfaces.dart:261-274`); `filesystem` lists folder *paths*, no tree, no
  viewer (`workspace_files_tab.dart`); mesh task rows (status/verdict/spend)
  are buried in Settings → Agents & Models as bare `ListTile`s with 1 s
  polling; permissions are only visible inside an open agent doc or the
  inspector rule; there is no status edge (DESIGN §30) anywhere in chrome.
- Net: the app is more operable by agents than by its human owner — an
  inversion of "the human is sovereign" as an *experience*, even though the
  authority model is correct.

### D5. Five design vocabularies coexist
Legacy mobile (`lib/_library`, `idea/`, `note/`, `ui_pay/`: AppColors, AppBars,
emoji keyboards) · stock-Material Settings (`Scaffold+AppBar+TabBar`) ·
de-Material shell · coding_agent Tufte grid (52 px gutter, 9.5 px letterspaced
small caps, `[bracket]` actions — a private style system duplicated per file,
small-caps the shell law rejects) · external inspector package + workbench
(own themes, one cream `MaterialApp`). Every new surface picks a dialect at
random; that is most of the "strange".

## 2. Target architecture — rail + views + per-view tabs

Keep what proved itself: one window, one surface registry
(`surfaces.dart`), the `ViewLayout` persistence discipline, widget-key
contracts, miniwindows, the world inspector as an opt-in spatial view, the
actor rail's roster model.

### 2.1 Anatomy
```
┌ window ────────────────────────────────────────────────┐
│ rail (56 px icons │ 240 px expanded)  │  active view    │
│  ─ views: Conversations, Documents,   │  ┌ view tabbar ┐│  ← Safari-like,
│    Boards, Browser, Files, Inspector, │  │ tabs of THIS ││    per view
│    Terminal, Threads, People          │  │ view only    ││
│  ─ roster: actors, channels (open     │  ├──────────────┤│
│    inside Conversations view)         │  │ view content ││
│  ─ human row + settings               │  │              ││
│                                       │  └──────────────┘│
│ status edge (one honest line: mesh · backend · daemon · │
│              attention: n permissions, m running)       │
└────────────────────────────────────────────────────────┘
```
- **Rail = activity bar + roster**, exactly the original idea. Top section
  switches views (icon + label when expanded, `⌘1..⌘9`); middle section lists
  actors/channels as *destinations inside* the Conversations view (selecting
  one opens/focuses its tab there, not in the rail's own coordinate space);
  bottom is the human row + settings-as-view.
- **Each view owns its tab strip and tab state**: `shell.views.v3` =
  `{activeView, perView: {viewId: {tabs:[…], active}}, miniwindows}`.
  Conversations: one tab per open thread (world face is a tab too).
  Documents: one tab per open doc (this is the missing human doc navigation).
  Boards: one tab per board. Browser: one tab per window (the embedded
  browser's own windows registry already models this). Inspector/People/
  Terminal/Threads: single-tab views (strip hidden, not removed).
- **Safari behaviors, per strip**: `⌘T` new tab *in the active view*, `⌘W`
  close, `⌘⇧[`/`]` switch, middle-click close, compress-to-icon on overflow
  rightmost-first (already implemented in `center_tabs.dart:_computeTabModes` —
  reuse), drag-reorder later.
- **Retire the right dock.** Pins become miniwindows (the mechanism already
  exists and persists) — one presentation for "keep an eye on this", not two
  taxonomies. The 240 px column returns as the rail's expanded width, not a
  second content column.
- **Status edge** at the window bottom: mesh/relay state, primary backend,
  daemon reachability, and the attention count (open permissions + running
  tasks) as one source-honest line; clicking opens the relevant view tab. This
  is the operator's ambient awareness, and the landing surface's seed.
- **Landing state**: Conversations view restores its last tabs; if none, the
  view shows an **inbox**: open permissions (reject-first), running/queued
  tasks with spend, last verdicts, recent beats across threads — assembled
  from the same projections the MCP tools read (`realm_chat_state`,
  `mesh_tasks`, permission router). One screen, one decision at a time
  (North Star §6), nothing held in working memory.

### 2.2 Surfaces to add or promote (operator cycle completeness)
1. **Documents view** (new): workspace doc tree + open docs as tabs; hosts
   `AgentDocSurface` and `DocView` unchanged inside tabs; creation reachable
   by human click (today only MCP/debug).
2. **Threads view**: harness thread list + beat tail (the placeholder's
   promise), read-only projection over the session registry the inspector
   already polls.
3. **Terminal view**: embed a real terminal (package decision separate;
   `xterm`-class widget or PTY bridge) — until then keep the honest note but
   route the status edge's "arm ecsaid" instruction into a one-click action.
4. **Boards view** promotion: mesh task rows (verdict/spend/status) render as
   board cards' settle data, not Settings ListTiles; the claim→run→settle loop
   gets a visible lane.
5. **Settings as a view** (embedding seam: replace `Navigator.pop` close with
   a view-close callback), so the shell grammar has no exceptions.
6. **⌘K command palette** over the unified search (actors, channels, docs,
   views, actions) — the rail search field becomes its trigger.

### 2.3 Semantics and keyboard as first-class chrome (unblocks the loop)
Every interactive chrome widget gets a `Semantics` button/label whose name is
its widget key (`rail.view.boards`, `view.tabs.new`, …). This simultaneously
fixes screen readers, `tap_widget`-drivable UI, and the agent contract law.
Shortcuts register on a shell-level `Focus` that requests primary focus on
window focus gain (fixes the `⌘T handled:false` class). Acceptance: a
`semantic_snapshot` of the idle shell lists every rail entry, every open tab,
the composer, and the status edge.

> **v4 amendment (2026-11-08, DESIGN.md v2 implementation):** the key
> grammar follows the group-scoped anatomy. `rail.view.<kindId>` now names
> the ACTION BAR's kind buttons (the click-then-cycle law), `rail.search` /
> `rail.settings` ride the bar; the persistent roster rows (`rail.actor.*`,
> `rail.channel.*`, `rail.workspace.*`) retired with the room list — rooms
> are picker rows (`newtab.entry.<surfaceId>`, plus `newtab.instance.<kind>`,
> `newtab.create.<flow>`, `newtab.runway.<format>`). Strips are keyed per
> PANE GROUP: `view.strip.<group>`, `view.group.{back,forward,split,fold}.<group>`,
> `view.strip.add.<group>`; tab keys are unchanged (`view.tab.<id>`,
> `view.tab.close.<id>`). The unread badge is kind-level
> (`rail.unread.conversations`). `worldchat.typing` moved from header text
> to the HUD pulse's Semantics label; `worldchat.close` lives in the actor
> card (`worldchat.card`, `worldchat.actorCard`). `rail_sem_probe_test.dart`
> and `command_palette_test.dart` own this contract.

## 3. Design language — light, Apple-inspired, UX-needs-first

Principle: **materials and depth only where they carry a UX fact.** Apple is an
inspiration for restraint, vibrancy and motion — not a skin to copy; every
choice below names the need it serves.

- **Tokens first (Phase 0).** Implement the DESIGN.md table as the single
  source in `packages/core` theme: `ColorScheme.fromSeed` from the accent
  (`#8DDCC2` dark / `#176D58` light) with explicit surface overrides
  (`canvas/surface/surfaceRaised/surfaceOverlay`), the type scale as
  `TextTheme`, one mono token, spacing/radius constants. Delete `AppColors`
  and the deprecated emoji text theme; migrate the ~43 literal color leaks by
  codemap-assisted sweep. Light theme is first-class and default-on-light-OS;
  dark stays the inspector-friendly reference.
- **Super-light feel = layering by alpha, not by boxes.** Regions separated by
  hairlines; hierarchy by tone/size/spacing (existing law, now actually
  shipped). Row density 28–34 px, tabular numerals for time/spend.
- **Glass (vibrancy) with a job, in three places only**: (1) the per-view tab
  strip and rail header, as a translucent band over scrolling content so
  context survives scroll (macOS: real `BackdropFilter` blur 20–30 σ over a
  0.7-alpha surface; other platforms: alpha-only fallback — no fake blur);
  (2) floating layers (menus, popovers, miniwindows, ⌘K palette): one blurred
  overlay surface + hairline + the existing single offset shadow; (3) the
  status edge when it overlays content in miniwindows. Reading surfaces
  (conversation, docs, diffs) stay solid — contrast and ADHD-attention law
  beat decoration. This amends DESIGN.md §"Elevation and motion" ("no glass
  blur as decoration"): blur is allowed only as a *layering fact* on the three
  named surfaces, never on content.
- **Motion**: 120–150 ms settle on hover/selection; tab switch = 180 ms
  horizontal slide + fade of the strip only (content swaps instantly —
  orientation over theater); miniwindow open = scale-from-pill 200 ms spring;
  all gated by reduced-motion.
- **Identity**: actor marks stay procedural HSL (law-compliant) but gain one
  shared saturation/lightness pair with the theme accent family; presence is
  text + a 6 px state dot, never color alone.
- **Not-copied-Apple checklist**: no fake traffic-light spacing on non-macOS,
  no SF Symbols lookalikes (keep the one outline icon family), no system-blue
  accents, no vibrancy on web/android (alpha fallback), sentence case
  everywhere (kills the UPPERCASE tab drift).

## 4. Migration plan (large scale, gated)

Each phase ends green on: `fvm flutter analyze`, shell tests, a `fmtk`
`flutter_layer` capture reviewed against the phase's acceptance list, and
`snapshot diff` vs the phase-start baseline. Hot-reload loop throughout
(`hot_reload_and_capture`); `desktop_window` truth capture once per phase.

- **Phase 0 — tokens & themes (1 PR).** Core theme rewrite; delete dead
  palettes; shell/colors extension re-derived from real tokens; golden
  captures light+dark. Risk: global visual change, zero behavior change.
- **Phase 1 — shell skeleton rebuild.** New `ShellScaffold`: rail (views +
  roster + human), view host, per-view tab strips, status edge; `ViewLayout`
  v2→v3 migration; dock retired (pins → miniwindows); settings seam. Surfaces
  port unchanged into tabs. This is the "rebuild from scratch" slice — the
  registry and surface widgets survive, the composition does not.
- **Phase 2 — semantics, keyboard, palette of actions.** Semantics on all
  chrome (acceptance: full-shell `semantic_snapshot`), shell-level focus +
  shortcuts, ⌘K palette, rail search as trigger. Unblocks `tap_widget`-driven
  integration scenarios.
- **Phase 3 — operator surfaces.** Documents view (human doc navigation +
  agent-doc creation), Threads view, Boards↔mesh-task merge, permission inbox
  in the landing state, terminal decision doc.
- **Phase 4 — vocabulary collapse.** Settings-as-view; restyle or quarantine
  legacy idea/note surfaces behind Documents; Tufte grid of `agent_doc_surface`
  re-tokened onto the shared scale (keep its information design, lose its
  private styles); inspector theme mapped to tokens.
- **Phase 5 — gates as product.** `gate-shell` harness scenario: boot →
  snapshot → open each view via semantics → ⌘T/⌘W round-trip → permission
  inbox render → capture diff. Runs in CI alongside `gate-multiplayer`.

Explicitly kept: surface registry, ViewLayout persistence discipline,
widget-key contract, miniwindows, world inspector (opt-in spatial view),
mesh/board substrates, the 60-tool MCP surface (it becomes the acceptance
mirror of human chrome). Explicitly retired: global top bar, right dock,
`AppColors`, emoji text theme, stock ThemeData, uppercase labels, Settings-as-
route, OS-automation-dependent testing.

## 5. Open questions for the owner

1. Rail default: icon-only 56 px expanding on hover/click (VSCode activity
   bar), or always-expanded 240 px with a collapse toggle (current rail)?
   Proposal: expanded default on ≥1280 px windows, icon-only below.
2. Conversations: keep Discord-style grouped beats (current) or move to the
   doc-grid transcript style? Proposal: keep beats; the doc grid belongs to
   Documents.
3. Terminal: ship a real PTY in Phase 3, or keep the honest placeholder until
   the harness exposes a session-PTY verb? Proposal: placeholder + status-edge
   action now, PTY when `ecsai` exposes one.
4. Glass on the tab strip: acceptable performance cost on low-end web/PWA
   (BackdropFilter is expensive)? Proposal: blur on macOS/desktop only,
   alpha-only elsewhere, decided per-platform at Phase 1.
