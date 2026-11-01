# DESIGN — the Last Answer workspace

This document defines durable visual and interaction rules for Last Answer product UI. The main desktop shell is the reference; each surface inherits its tokens and can add only the controls its job needs. Product truth belongs in [PRODUCT.md](../PRODUCT.md); this file is the visual system, not a claim that every planned capability is implemented.

## Direction

Last Answer is a calm, precise workroom for people and the actors they invite into their work. Its main surface makes the workspace feel continuous: actors, conversations, browser tabs, files, settings, and the world inspector are panes onto one shared workspace. The shell is present but quiet; the work in each pane carries the attention.

The visual references contribute two useful ideas. The conversation reference has a legible participant list and familiar writing surface. The inspector references make a large shared world explorable through spatial layout, selection, and time. Keep the everyday shell readable and ordinary; let spatial visualization appear where it carries meaning, inside the inspector pane.

The mode is **Operate**. The user is here to work, switch context, inspect, and make decisions. Optimize for orientation, direct manipulation, keyboard access, recovery, and long sessions. This is an application surface, not a promotional dashboard.

## One workspace, many panes

- Workspaces are the primary scope. The current workspace is always identifiable and can be changed without losing open work.
- Actors and channels are destinations and participants. Search and navigation find identities, threads, files, and panes from the same workspace.
- The center is a serializable pane tree. A pane may show a conversation, document, browser session, world inspector, terminal, or settings. Tabs and splits organize these surfaces; no surface owns a permanent privileged center.
- A surface has one identity and behavior across a context-panel tab, a workspace pane, and an in-app miniwindow. These presentations do not create separate data or controls.
- Settings open as a workspace surface. Context panels are optional companions to the selected pane, not required steps in a separate mode.
- Selection, layout, and zoom are view state. They must not silently mutate shared project meaning.

## Main shell composition

At desktop width, use a narrow global rail, a workspace navigator, a flexible pane canvas, and an optional context panel. Keep the hierarchy stable while letting the user resize or collapse supporting columns.

1. **Global rail** — workspace access, universal search, recent activity, and stable destinations. Icons use one consistent stroke library and have accessible names. The rail does not reorder itself.
2. **Workspace navigator** — the selected workspace, its roots, actor roster, channels, and open/recent destinations. Use concise headings and rows. Search is always reachable; avoid turning the navigator into a collection of boxed widgets.
3. **Pane canvas** — a quiet tab strip and the active surface. Tab groups can split in either axis. Each tab shows a short title, an optional state marker, and a close affordance. New-pane discovery is searchable and lists concrete destinations.
4. **Context panel** — details for the selected pane or object: members and presence for a channel, page information for a browser, selected-object details for the inspector. It can be hidden without hiding essential state.
5. **Status edge** — a compact, source-honest line for sync, connection, permission, or task state when relevant. Do not place aggregate world counts here by default.

The default conversation pane is text-native. Authors and timestamps align consistently; messages are not left/right bubbles. The composer stays in a stable location, supports a quiet expanded state, and keeps send and attachment actions visible without a heavy container. Permissions, failures, and task outcomes appear in the conversation's flow with clear attribution and an explicit next action.

## World inspector as a shell surface

The inspector uses the same workspace chrome and pane rules as every other destination. It has a large canvas for the one-world view, a selection-driven detail region, and an optional timeline when time is part of the question. Canvas actions and keyboard/accessibility alternatives operate on the same supported state.

Use semantic zoom: at overview, show project scopes and meaningful relationships; on approach, reveal actors and events; on selection, show their details and available actions. Keep labels readable, preserve user placement when possible, and distinguish authoritative relationships from personal arrangement. Filters must respect visibility before layout or decoration. The timeline controls the view's historical cut; it must not imply live authority when showing a synthetic or historical fixture.

The graph, timeline, filters, event list, and selected-object details are inspector content. Do not promote inspector counters or a glowing network visualization into permanent shell chrome. Label synthetic or historical data visibly.

## Visual system

### Palette

Use a restrained, blue-green neutral palette suited to long desktop sessions. Dark is the initial reference theme because it supports a spacious inspector canvas, but light is a first-class theme with equal hierarchy and contrast. Derive all widget colors from the semantic theme tokens below; do not create a competing palette per surface.

| Token | Dark reference | Light reference | Use |
|---|---|---|---|
| `canvas` | `#0B1114` | `#F6F8F7` | App and canvas background |
| `surface` | `#111A1E` | `#FFFFFF` | Pane and navigator surfaces |
| `surfaceRaised` | `#172328` | `#EEF2F0` | Selected rows and quiet raised regions |
| `surfaceOverlay` | `#1D2B30` | `#E7EDEA` | Menus, popovers, floating windows |
| `ink` | `#E5ECE9` | `#192522` | Primary text and icons |
| `inkMuted` | `#B0BFBA` | `#53635E` | Secondary labels and descriptions |
| `inkQuiet` | `#879A94` | `#687872` | Timestamps and tertiary metadata |
| `rule` | `#2B3A3F` | `#D9E1DD` | Region boundaries and separators |
| `accent` | `#8DDCC2` | `#176D58` | Keyboard focus, active marker, primary action |
| `danger` | `#F18A83` | `#B33935` | Destructive or failed state |
| `caution` | `#E8BD71` | `#875A12` | Pending or attention-needed state |
| `success` | `#8DDCC2` | `#176D58` | Confirmed success |

Treat these as starting theme values, not hard-coded widget colors. Validate normal text to at least 4.5:1, large text to 3:1, and focus/selected indicators to at least 3:1 against adjacent surfaces. If a theme cannot meet that, adjust the theme token rather than making individual labels brighter by hand.

Actor identity is stable and derived from the actor record. Use the deterministic identicon and kind label; avoid random saturated avatar colors. Presence is explicit text where it matters and a small, accessible state mark in dense lists. Never rely on color alone.

### Typography

Use a highly legible interface sans for navigation and prose, with tabular numerals for time, counts, and budgets. Use a restrained monospace only for code, paths, and measured values. Do not use typewriter styling as generic “technical” decoration.

| Role | Size / line height | Weight | Use |
|---|---:|---:|---|
| Micro | 11 / 16 | 450–500 | Timestamps, quiet state labels |
| Compact | 12 / 17 | 400–500 | Navigator metadata, controls |
| Body | 14 / 20 | 400 | Conversation and document text |
| Emphasis | 15 / 21 | 550–600 | Pane title, selected actor |
| Section | 18 / 24 | 600 | Surface heading |
| Display | 24 / 30 | 600 | Empty-state or settings title only |

Sentence case is the default. Establish hierarchy through size, weight, and spacing, not letter-spaced small caps. Keep long reading measure comfortable; let content surfaces use their own width within the pane.

### Spacing and geometry

- Base spacing unit: 4 px. Common steps: 4, 8, 12, 16, 24, 32.
- Navigator rows: 34–38 px, with a 28–32 px minimum interactive target only where density requires it; touch layouts use at least 44 px targets.
- Region separators: one-pixel hairline. Use whitespace within a region and lines only between meaningful regions.
- Controls and selected rows: 6–8 px corner radius. Floating windows and anchored menus: 10–12 px. Avoid pill shapes except for compact status tokens whose shape conveys a real state.
- Pane edges align to one grid. Do not add nested cards to represent hierarchy; use indentation, typography, spacing, and selection.

### Elevation and motion

The pane canvas is flat. Menus, popovers, and miniwindows use one quiet raised surface with a thin edge and a soft shadow offset down by 4–6 px. Do not stack multiple shadows or use glass blur as decoration.

Hover and selection settle in 100–150 ms. Split, tab, and panel transitions are brief and reversible. Motion explains where a pane went or what selection changed; no ambient loops, pulsing, or attention-seeking animation. Respect reduced-motion settings.

### Iconography and identity

Use a single 1.75–2 px outline icon family with a consistent 16/18/20 px size set. Icons accompany ambiguous actions; remove icons that merely repeat visible labels. Use a clear selected treatment, not a filled icon button for every control. Actor marks come from stable identity data; names remain the primary identification.

## Responsive behavior

- **Wide desktop (≥1440 px):** navigator, pane canvas, and optional context panel can coexist. Preserve a generous minimum width for the active pane.
- **Compact desktop (1024–1439 px):** navigator can collapse to the global rail; context details become a temporary side panel. Keep the active pane and tab strip visible.
- **Narrow web/tablet (600–1023 px):** show one primary pane; navigator and context panel slide in as explicitly opened drawers. Preserve keyboard and back-navigation behavior.
- **Phone (<600 px):** one pane at a time. Keep workspace, back, pane-switch, and search actions reachable; do not compress the desktop columns. Splits become a pane switcher. Context details open as a pushed sheet or route with a clear return path.

Responsive changes alter presentation, not workspace contents, permissions, or view identity. Reopening a workspace should restore its pane tree as supported by the platform.

## Interaction and state

- Keyboard is first-class on desktop: search, switch pane, close pane, split, and move focus between navigator, canvas, and context panel.
- Direct manipulation and keyboard/accessibility actions call the same product handlers.
- Selection is visible at a glance. Focus is distinct from selection and remains visible on both themes.
- Empty, loading, offline, denied, stale, and error states explain what happened and the available next action. Do not substitute a spinner for durable status.
- Queued or pending work remains inspectable after navigation. Returning to a surface reconstructs its useful state.
- Search covers actors, channels, workspaces, and openable surfaces. Results name their type and location so similar items are distinguishable.
- Destructive actions are undoable when the owning data contract permits it; otherwise describe the consequence before the action.

## Accessibility

Support keyboard navigation, screen-reader names and roles, platform text scaling, reduced motion, visible focus, and high contrast. Do not convey actor type, presence, selection, permission, or verdict by color alone. Keep canvas nodes selectable by keyboard and offer a readable list or detail alternative. Touch targets are at least 44 × 44 px on touch platforms.

## Extension contract for future panes

A new surface (including terminal, world inspector, browser, or document editor) must specify:

- its stable surface identity and user-facing title;
- its natural initial pane size and whether it can appear in a side panel or miniwindow;
- what selection/context it contributes to the shared context panel;
- its keyboard actions and accessible alternative for direct manipulation;
- loading, empty, permission, failure, offline, and recovery states;
- which state is shared project meaning and which state is personal arrangement.

It inherits the shell's type, spacing, focus, selection, surface, and motion tokens. It may add semantic colors only when they represent a durable domain state and meet contrast requirements.

## Avoid

- A fixed chat center with all other surfaces treated as secondary tools.
- A second navigation system inside inspector, browser, or settings that duplicates workspace navigation.
- Rainbow actor colors, decorative node clouds, status dashboards, or metrics without a source and task purpose.
- Rounded boxes around every control, message bubbles, or cards used only to partition the layout.
- Small caps as a replacement for hierarchy, tiny low-contrast timestamps, and color-only state.
- Fake live data. Concept material uses clearly identified synthetic examples.
