# UI kit rewrite — `la_ui` (2026-11-16)

Owner-directed program: replace the Material component layer with a
widgets-layer-only kit that carries the DESIGN.md law (shadcn zinc
discipline × Discord grammar × Linear density), with two v6 owner
decisions: **squircle corners** and the **chrome event-motion
amendment**. Hard cuts authorized. Supersedes the paint-level
`shell-de-material-plan.md` (2026-10-30), which fixed colors; this
program replaces **grammar and metrics**.

## 1. Critique — why themed Material still reads ugly

`packages/core/lib/src/theme/material_theme.dart` re-skins Material
(NoSplash, zinc scheme, Inter, quiet component themes) and it is still
Material, because ThemeData changes paint, not grammar:

1. **Metrics fight the grid.** M3 buttons default to 40 px height /
   64 px min width / labelLarge type; shell rows are 34 px and the UI
   type scale is 12–14 px. Vertical rhythm breaks at every button.
2. **Two hover systems.** Shell surfaces use ink-alpha fills
   (0.05/0.09); Material widgets use M3 state layers with their own
   animation. Hover feels physically different between surfaces.
3. **Component grammar.** AlertDialog's 24 px padding + right-aligned
   text-button action row; DropdownButton's underlined trigger +
   elevated Material menu; TextField+InputDecoration's fill/border/
   helper model vs. the borderless-field law; SnackBar's bottom bar
   vs. corner toasts; ListTile's 56 px leading metric vs. 34 px rows.
4. **The focus-ring law had no carrier.** DESIGN.md v2 defines a 2 px
   offset ring on keyboard travel; no widget implemented it. A law
   without a component is a suggestion — ~10 ad-hoc hover-alpha sites
   proved the drift.
5. **The reference implementation violated its own law.**
   `agent_doc_surface.dart` (the DESIGN.md exemplar per AGENTS.md) was
   the densest Material file: 15 TextButton, 15 InkWell, 7 TextField,
   1 DropdownButton.
6. **Ambient Material.** `common_imports.dart` blanket-exported
   `flutter/material.dart` (+ unused `blur`, + `flutter_animate` under
   a no-ambient-motion law), so drift was the default state and
   unenforceable.

Three UI generations coexisted: the dead pre-pivot kits
(`packages/ui_kit` 16 files / 4 consumers; `lib/_library/widgets`
36 files / 28 consumers — Material+Cupertino+ad-hoc dialects), raw
Material via common_imports (~310 buttons, ~130 overlay sites, ~100
fields, ~44 ListTiles), and the genuinely custom new shell chrome
(ShellTokens/ShellRow — one primitive deep).

## 2. Decisions (owner, 2026-11-16)

- **Squircle**: continuous-curvature superellipse corners (Discord/iOS
  grammar) for every kit-drawn fill, control and floating surface.
  Implemented as a `ShapeBorder` (`SquircleShape`) so it composes with
  `ShapeDecoration`, clipping and `Ink`-free painting. Radii values
  unchanged (6–8 controls, 10–12 floating, n≈4 superellipse exponent
  scaled by radius).
- **Chrome event-motion amendment (DESIGN.md v6)**: chrome may carry
  event-driven motion answering an action (press settle, overlay
  scale+fade, toast slide, confirm hop). Ambient loops/pulsing stay
  banned; reduced-motion disables chrome motion. Creatures keep their
  own layer.
- **Hard cuts authorized**: delete `lib/_library` and
  `packages/ui_kit`; cut `material`, `blur`, `flutter_animate` from
  `common_imports.dart`; Material imports in `lib/` only via a
  shrinking CI-enforced allowlist.
- **Phase 6 (MaterialApp → WidgetsApp) deferred** — pure engine
  purity, real cost (localizations, page transitions), zero pixels.

## 3. Architecture — `packages/la_ui`

Widgets-layer only: `flutter/widgets|painting|rendering|gestures|
semantics|animation` + `flutter_portal` (Radix-portal equivalent,
already an app dependency). **Never** `package:flutter/material.dart`
(CI gate). Colors/type/motion come from a `LaUiTheme` ThemeExtension
registered by the app from the existing `LaPalette` zinc tokens; the
kit ships dark/light defaults so it works standalone.

Custom RenderObject/paint is used where it earns its keep: the
superellipse path, focus-ring painting, toggle/spinner/slider chrome,
press-scale transforms. Text input wraps `EditableText` (widgets
layer) — the engine (IME, selection handles, a11y) is kept, the
Material decoration model is replaced. Menus/popovers/tooltips ride
`flutter_portal`. Dialogs ride `showGeneralDialog`. Toasts ride the
root `Overlay`.

### L0 tokens (in-kit, fed by app)

`LaUiTheme`: canvas/surface/surfaceRaised/surfaceOverlay/ink/inkMuted/
inkQuiet/rule/accent/onAccent/ring/danger/caution/success; hover &
pressed state alphas (ONE hover system); type scale (micro 11, compact
12, body 14, emphasis 15, section 18, display 24 — Inter via ambient
DefaultTextStyle/Theme); radii (control 8, floating 11, small 6) as
squircles; motion (fast 120 ms, settle 150 ms, overlay 140 ms,
easeOutCubic-ish curves); the one floating shadow.

### L1 primitives

| Kit component | Replaces | Grammar |
|---|---|---|
| `LaPressable` | InkWell, Material, hand-rolled MouseRegion+GestureDetector | one hover/focus/press/disabled state machine; paints state layer; hosts ring |
| `LaFocusRing` | — (law had no carrier) | 2 px offset accent ring, keyboard travel only (`FocusManager.highlightMode`) |
| `LaButton` (+ `.icon`, `.ghost/primary/secondary/destructive/link`) | TextButton, FilledButton, ElevatedButton, OutlinedButton, IconButton | sizes sm 28 / md 34 (row-grid matched) / icon 28·34; press settle scale 0.98 (v6) |
| `LaField` / `LaTextArea` | TextField, TextFormField, UiTextField | borderless on surface, `field` fill on hover, ring on focus; prefix/suffix slots; honest error line; counter slot; EditableText engine |
| `LaMenu` / `LaMenuItem` / `LaContextMenu` | PopupMenuButton, MenuAnchor, PopupButton | portal popover, 32 px rows, check marks, separators, destructive variant, keyboard nav |
| `LaSelect` | DropdownButton, DropdownButtonFormField, SegmentedButton(menu-shaped) | quiet trigger + chevron, portal listbox, check on selected |
| `LaDialog` / `LaConfirm` / `showLaDialog` / `LaSheet` | showDialog, AlertDialog, Dialog, SimpleDialog, showModalBottomSheet | title/description/body/footer; quiet scrim 60 %; scale+fade 140 ms (v6) |
| `LaToast` | SnackBar, ui_kit toasts | corner-stacked (bottom-right desktop / top phone), info/success/danger + action, slide-in (v6) |
| `LaTooltip` | Tooltip | portal, 600 ms wait, overlay surface, micro type |
| `LaRow` | ListTile, ExpansionTile shell, HoverableListTile, ShellRow | leading/title/meta/trailing, 34 compact / 44 touch, selection + unread-badge slots |
| `LaSwitch` / `LaCheckbox` / `LaRadio` | Switch, Checkbox, Radio | painted, shadcn shapes, 150 ms thumb settle |
| `LaSlider` | Slider | painted track/thumb, accent fill |
| `LaSpinner` / `LaProgress` | CircularProgressIndicator, LinearProgressIndicator, UiCircularProgress, state_loader | painted arc / 2 px determinate bar |
| `LaPill` / `LaBadge` | Chip, Badge, ad-hoc unread Containers | the v2 pill-exception tokens, first class |
| `LaHairline` | Divider | 1 px rule token |
| `LaScaffold` / `LaTopBar` | Scaffold, AppBar | canvas + SafeArea body; quiet 44 px top bar (leading/title/trailing), hairline under |
| `LaScrollArea` | Scrollbar+Material scroll behavior | thin 6 px scrollbar, kit ScrollBehavior |
| `SquircleShape` / `squirclePath` | RoundedRectangleBorder, BorderRadius | superellipse border+clip, the v6 corner law |

### L2 patterns (composed in-app, not in kit)

command palette, the v5 spreadsheet-tree table rows, settings rows,
empty states, danger zone, attach menu — all rebuilt over L1.

### L3 creature/gamification

unchanged law: creatures ride LaWorld + `CreatureMark`; kit exposes
event-motion hooks only; no ambient chrome loops.

## 4. Phases

- **0** — kit skeleton: tokens, squircle, pressable, focus ring,
  button, row, hairline, scaffold/topbar; app wiring (LaUiTheme
  registered in `material_theme.dart`, `la_ui` exported from
  `common_imports.dart`); CI gate script.
- **0b** — full kit: field, menu/select, dialog/sheet, toast,
  tooltip, toggles, slider, progress, pill, scroll area.
- **1** — buttons sweep (~310 sites), biggest visual delta.
- **2** — overlays sweep: dialogs (~46+36), toasts (~18),
  dropdowns/menus (~25), tooltips (~32).
- **3** — fields: `agent_doc_surface.dart` rewritten FIRST as the new
  reference implementation, then composer + ~100 TextField sites.
- **4** — lists & legacy screens: ListTile→LaRow, Scaffold/AppBar→
  LaScaffold/LaTopBar across idea/note/home/settings/other/doc/
  workspaces/onboarding/browser/workbench/ui_pay.
- **5** — hard cuts: delete `lib/_library/` + `packages/ui_kit` (core
  consumers fixed first), cut material/blur/flutter_animate exports
  from `common_imports.dart` (widgets.dart exported instead),
  allowlist + CI gate armed, flutter_animate call sites replaced with
  kit motion.
- **6** — deferred (WidgetsApp).

## 5. Enforcement

- `tool/check_ui_gates.dart` (just recipe): fails when
  `packages/la_ui` imports material, or `lib/` imports material
  outside `docs`-recorded allowlist (`lib/main.dart`,
  `lib/main_prod.dart`, `lib/other/last_answer_app.dart`,
  `lib/router.dart`, `lib/app_scaffold.dart`, theme plumbing in
  `packages/core` — shrinking over time).
- Widget keys frozen through the sweep (agent UI contract).
- Verification loop: `fvm flutter analyze` + tests per phase;
  fmtk native screenshots per surface (v4 evidence law); contrast
  floor 4.5:1 / 3:1 unchanged.

## 6. Wave log

- 2026-11-16: program opened; owner decisions squircle + v6 motion
  amendment; DESIGN.md amended; this doc landed.
- 2026-11-16 (kit): `packages/la_ui` landed — 20 source files,
  widgets-layer only, 8/8 smoke tests, analyze clean. `LaUiThemeProvider`
  registered in the MaterialApp builder, fed by `laUiThemeFromPalette`
  (lib/ui/la_ui_bridge.dart). Root Scaffold sites (router.dart,
  app_scaffold.dart) and creature_mark.dart converted. CI gate
  `tool/check_ui_gates.dart` + `just ui-gates` + allowlist armed.
- 2026-11-16 (sweep dispatch): five lanes — pilot
  (agent_doc_surface.dart + its six tests), A (lib/shell + test/shell,
  incl. ShellColors/ShellRow re-based on kit tokens with frozen APIs),
  B (lib/coding_agent minus pilot file + test/coding_agent, with
  wave-2a/2b preservation rules), C (settings/agent_config/doc/other/
  onboarding/ui_pay + core's ui_kit decoupling; FIRST ATTEMPT FAILED
  NO-OP — re-dispatched), D (legacy idea/note/home/browser/workbench +
  `lib/widgets/legacy_kit/` functional-helper ports, blur-free).
- 2026-11-16 (incident): one agent ran an unauthorized `git add -A &&
  git commit` (0deb48b1) mixing the owner's in-flight wave-2b work,
  the kit, lane edits and `packages/la_ui/build/` artifacts. Undone
  with `git reset --mixed HEAD~1`; all content intact; all lanes
  re-warned (A, B, D, pilot explicitly denied; suspicion falls on the
  failed lane-C run). Law restated: agents never write git; the
  steward owns history.
- 2026-11-16 (kit fix from lane feedback): `showLaMenuAt` now closes
  on item activation (shared `wrapLaMenuEntriesCloseOnActivate`
  grammar with `LaMenuAnchor`) and returns a `LaMenuHandle`
  (close() + closed Future) — lane A's shell_menu.dart workaround
  prompted it. Kit re-verified green after the change.
- 2026-11-16 (kit extension from lane feedback): `LaMenuItem` grew
  `key:` (frozen agent-UI contract keys, e.g. `worldchat.ctx.*`) and
  `tooltip:` (the v4 honest-DISABLED law); rows render as the public
  `LaMenuRow` so tests assert `tester.widget<LaMenuRow>(find.byKey(
  k)).item.enabled/tooltip`. `LaSelectableText`,
  `LaSelectableRegionControls`, `LaSelectionToolbar`,
  `LaSelectionLabels` landed for the SelectableText replacement.
  Ownership carve-out: lane B owns the four
  `test/shell/world_chat_*` test files; lane A owns the rest of
  `test/shell/**`.
- 2026-11-16 (PAUSE for subagent model change — owner-directed):
  all lanes stopped; tree compiles (0 errors / 6 warnings / ~190
  infos incl. pre-existing). LANDED at pause: pilot COMPLETE
  (agent_doc_surface.dart — 38 Material sites converted, 65 keys
  frozen byte-identical, 19/19 lane tests green; reference exemplar);
  lane A shell conversions (residual Material in lib/shell = 0);
  lane B 23 coding_agent files; lane C-retry 33 settings-cluster
  files; lane D 24 legacy-screen files + 15 legacy_kit ports
  (residual 0 in screens). Known test-harness law recorded:
  LaTooltip/LaMenuAnchor need a Portal ancestor in test pumps.
- 2026-11-16/17 (continuation round, owner-directed resume after
  subagent model change): pilot COMPLETE (reference rewrite, 19/19
  tests); lane A-cont test pass COMPLETE (205/206 in test/shell; it
  also fixed a real kit bug — LaSpinner's inherited lookup in
  initState — and converted pane_strip's overflow menu to
  LaMenuAnchor(alignRight)); lane C absorbed by the coordinator after
  its retry died on a concurrency limit: settings tab grammar
  rewritten (AppBar+TabBar → LaTopBar + kit tab strip; TabBarView →
  PageView, TabController dropped), core decoupled from ui_kit
  (Toasts→LaToast, showWarningDialog→showLaConfirm, google_sign_in
  spinner), supporter _FadeIn lint, and ALL lane-C suites green
  (settings 47, doc 38, agent_config 16, onboarding 5); lane D-cont
  COMPLETE (99/99 in its scope, 15/15 legacy_kit ports verified, 0
  _library imports left in its dirs). app_shell_test's cross-lane
  failure fixed via a stable `settings.close` key on the kit close
  button (CupertinoCloseButton by-type tap retired).
- 2026-11-17 (kit hardening from lane feedback): `laHasPortal` +
  graceful degradation — LaTooltip/LaMenuAnchor/LaSelect render
  trigger-only in bare hosts (no PortalNotFoundError on every mount);
  `LaScaffold` installs the kit body DefaultTextStyle (bare-Text trap
  the workbench hit); `showLaMenuAt` post-frame measure-and-correct
  for real menu widths at screen edges; LaSpinner mount regression
  test (normal + reduced motion). Kit: analyze clean, 9/9 tests.
- 2026-11-17 (integration + hard cuts COMPLETE): lane B-cont closed the
  program (115/115 in its scope, composer verified honest — all 4947
  lines read, every frozen worldchat.* key survived). Coordinator
  integration fixes: settings tab grammar rewritten onto the kit
  (AppBar+TabBar → LaTopBar + `LaTabStrip` [promoted to kit],
  TabBarView → PageView, TabController dropped); account views'
  NestedScrollView/SliverAppBar/TabBar → the same strip + PageView;
  `LaSelectionArea` (arbitrary-child SelectableRegion) added to the
  kit for SelectionArea sites; `LaDialog` grew the viewport height cap
  (0.9) and Wrap actions — live-caught by the consent tests (an
  off-screen trigger at y=1204 in a 600px window); mini_window and 8
  Icons-only imports triaged (`show Icons` or removed); core fully
  decoupled from ui_kit (Toasts→LaToast, showWarningDialog→
  showLaConfirm). HARD CUTS: common_imports now exports widgets.dart +
  la_ui + `material show Colors, Icons, ThemeMode` + CupertinoPageRoute;
  blur/flutter_animate/ui_kit dependencies removed; `lib/_library/`
  and `packages/ui_kit/` DELETED; `just ui-gates` GREEN (allowlist:
  last_answer_app engine host, workbench_candidate_main acceptance
  runner, app_info showLicensePage — each with a reason). l10n:
  selectionCut/Copy/Paste/SelectAll keys (EN/IT/RU) mirrored into the
  committed generated S*.dart (intl_utils 2.8.17 has a parse bug on
  this project; the generated files are maintained in-step) and
  bridged in the MaterialApp builder. FULL SUITE: 1059 passed / 9
  skipped / 0 real failures (bot_context_plan flaky under parallel
  load, green twice in isolation). Workspace analyze: 0 errors.
