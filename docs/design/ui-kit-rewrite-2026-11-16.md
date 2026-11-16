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
