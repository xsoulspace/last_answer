# DESIGN — the Last Answer workspace

> **v2 amendment (2026-11-08):** the two-layer law — *calm chrome,
> living creatures* — and the shadcn-discipline neutral palette. The
> chrome layer keeps every rule below; the creature layer amends exactly
> three clauses (motion, identity, pills), each marked **v2** in place.
> The owner approved the base mockup on 2026-11-08 and directed four
> additions, now law here and in the mockup: the compact actor HUD,
> threads over the conversation graph-tree, point/select/comment over
> live web + native previews, and the tab law — the strip is the
> universal content surface, the rail an activity bar. The interactive mockup remains the
> gate artifact; until the owner's final nod on the additions,
> implemented surfaces keep the v1 tokens.

This document defines durable visual and interaction rules for Last Answer product UI. The main desktop shell is the reference; each surface inherits its tokens and can add only the controls its job needs. Product truth belongs in [PRODUCT.md](../PRODUCT.md); this file is the visual system, not a claim that every planned capability is implemented.

## Direction

Last Answer is a calm, precise workroom for people and the actors they invite into their work. **Conversation is the primary interaction mode** (v2): rooms with actors are the front door — every other pane (documents, inspector, browser, terminal, settings) is a companion to the rooms, not a competing destination. Work starts from a sentence to an actor; tasks are tools that emerge from conversation, never the door. The shell is present but quiet; the work in each pane carries the attention.

The visual references contribute two useful ideas. The conversation reference has a legible participant list and familiar writing surface. The inspector references make a large shared world explorable through spatial layout, selection, and time. Keep the everyday shell readable and ordinary; let spatial visualization appear where it carries meaning, inside the inspector pane.

The mode is **Operate**. The user is here to work, switch context, inspect, and make decisions. Optimize for orientation, direct manipulation, keyboard access, recovery, and long sessions. This is an application surface, not a promotional dashboard.

**The two-layer law (v2).** The chrome — every navigation, list, form, tab, edge and dialog — is *calm*: shadcn-grade neutral discipline, hairlines, flat surfaces, one shadow, zero decoration. The life lives in ONE layer: the *creatures* — the actors' procedural marks are small living beings whose state is the world's own truth (narration, presence, settlements). Chrome never animates for its own sake; creatures never carry chrome's job. The dial is "expressive cozy": warm, discoverable charm at the identity layer; an undistracting professional instrument everywhere else.

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

Use a restrained neutral palette suited to long desktop sessions. **v2: zinc-family neutrals** (the shadcn discipline — warmless grays that make content the only color) with the **glade green accent kept** as the product's one signature hue. Dark is the initial reference theme because it supports a spacious inspector canvas, but light is a first-class theme with equal hierarchy and contrast. Derive all widget colors from the semantic theme tokens below; do not create a competing palette per surface.

| Token | Dark reference (v2) | Light reference (v2) | Use |
|---|---|---|---|
| `canvas` | `#09090B` | `#FAFAFA` | App and canvas background |
| `surface` | `#18181B` | `#FFFFFF` | Pane and navigator surfaces |
| `surfaceRaised` | `#27272A` | `#F4F4F5` | Selected rows and quiet raised regions |
| `surfaceOverlay` | `#323236` | `#E9E9EC` | Menus, popovers, floating windows |
| `ink` | `#F4F4F5` | `#18181B` | Primary text and icons |
| `inkMuted` | `#A1A1AA` | `#52525B` | Secondary labels and descriptions |
| `inkQuiet` | `#71717A` | `#71717A` | Timestamps and tertiary metadata |
| `rule` | `#27272A` | `#E4E4E7` | Region boundaries and separators |
| `accent` | `#8DDCC2` | `#176D58` | Keyboard focus, active marker, primary action — the glade, kept |
| `ring` (v2) | `#8DDCC2` | `#176D58` | The focus ring: a 2px offset outline on keyboard travel, never on hover |
| `danger` | `#F87171` | `#DC2626` | Destructive or failed state |
| `caution` | `#FBBF24` | `#B45309` | Pending or attention-needed state |
| `success` | `#8DDCC2` | `#176D58` | Confirmed success |

Treat these as starting theme values, not hard-coded widget colors. Validate normal text to at least 4.5:1, large text to 3:1, and focus/selected indicators to at least 3:1 against adjacent surfaces. If a theme cannot meet that, adjust the theme token rather than making individual labels brighter by hand.

Actor identity is stable and derived from the actor record. Use the deterministic identicon and kind label; avoid random saturated avatar colors. Presence is explicit text where it matters and a small, accessible state mark in dense lists. Never rely on color alone. **v2: the identicon is a creature** — see "The creature layer".

### Typography

Use a highly legible interface sans for navigation and prose, with tabular numerals for time, counts, and budgets. **v2: the interface sans is Inter (SIL OFL), bundled** — the shadcn look is Inter-geometry, and a bundled face makes every platform render the same law; the platform system stack is the fallback. Use a restrained monospace only for code, paths, and measured values. Do not use typewriter styling as generic “technical” decoration.

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
- Controls and selected rows: 6–8 px corner radius. Floating windows and anchored menus: 10–12 px. Avoid pill shapes except for compact status tokens whose shape conveys a real state (v2: the rail's unread badge and the chat's jump-to-latest control are exactly such tokens — the exception, not a new freedom).
- Pane edges align to one grid. Do not add nested cards to represent hierarchy; use indentation, typography, spacing, and selection.

### Elevation and motion

The pane canvas is flat. Menus, popovers, and miniwindows use one quiet raised surface with a thin edge and a soft shadow offset down by 4–6 px. Do not stack multiple shadows or use glass blur as decoration.

Hover and selection settle in 100–150 ms. Split, tab, and panel transitions are brief and reversible. Motion explains where a pane went or what selection changed; **the chrome layer has no ambient loops, pulsing, or attention-seeking animation** (v2 wording: the ban binds chrome; the creature layer's motion law follows). Respect reduced-motion settings.

**Creature-layer motion (v2).** Creatures animate ONLY on events, never idly: a blink when their beat lands, a squish-and-return on identity tap (≤250 ms), mood transitions with the narration state (150–250 ms), and ONE settlement celebration — a hop plus a small confetti burst (≤400 ms, once per settled PASS). No creature motion while the human is typing or reading mid-scroll; no loops; no sound. Under reduced-motion, creatures are static — state renders through posture alone (the motion-free truth of the same facts). Chrome motion budgets are unchanged by this layer.

### Iconography and identity

Use a single 1.75–2 px outline icon family with a consistent 16/18/20 px size set. Icons accompany ambiguous actions; remove icons that merely repeat visible labels. Use a clear selected treatment, not a filled icon button for every control. Actor marks come from stable identity data; names remain the primary identification.

**The creature layer (v2).** The actor's procedural mark is a small living being, not a logo: the six existing shape families (triad, diamond, leaf, bars, ring, peaks) become SPECIES — deterministic from the actor id, exactly as today's identicon — now with eyes that carry the world's own truth: awake/asleep with the daemon, thinking/generating with the narration state, a settled-PASS celebration, a squish when tapped. The laws:

- **A creature's state is world truth, never decorative fiction.** It sleeps only when the daemon is down; it thinks only when the loop says so. No invented moods, no mascots that talk unasked.
- **Species carries the variety that color must not**: hues stay deterministic and muted (the no-rainbow law stands); shape, eyes and posture do the individuating.
- **The 22 px rail avatar is the creature's everyday home.** Larger creature moments belong to empty and first-run states only (the landing inbox greeter, the first-run "meet your actor", the sleeping-world status edge) — never over content, never between the human and a decision.
- **Creatures ride LaWorld**: their state components live in the in-process ecsly World (fed by the journal fold), animated by fixed-step systems, painted through selector-scoped CustomPainter windows — no setState animation controllers, no per-frame whole-tree rebuilds.
- The kind label (M/A/H) and presence dot remain: a creature never becomes the ONLY carrier of actor type or presence (color-alone and shape-alone bans).

**The compact actor HUD (v2, owner law 2026-11-08).** A room header carries IDENTITY and MOOD, nothing else: creature (20 px, eyes carrying the state), the actor's name, one 6 px pulse while the loop cycles, and a single card button. The facts a debugger needs (brain cast, health, seat, grants, memory) live one tap away in the actor card popover, mono 10.5 px, never in the header line. The law: **the header is game-light — if a fact is not identity or live state, it does not sit between the human and the conversation.** Status words ("thinking", "idle") are titles and creature eyes, not header text; Codex/Cursor/ZCode restraint is the bar, the creature is the difference.

**Threads: the conversation is a graph-tree (v2, Discord law).** Every beat can branch; a branch is its own room with a parent link, not a copy. In the trunk, a branch shows as a thread chip under its parent beat — branch glyph, the faces of who replied, reply count, last activity — and never as nested indentation (depth is unreadable past one level). The chip opens a side pane: parent quote on an accent bar, the branch's beats, its own composer. Unread law rides the same receipts: a thread's unread is a member's fact, badged on the chip and the rail row alike. Actor↔actor rooms and threads share one mechanic: addressing joins, watching does not.

**Point, select, comment: the product is a comment surface (v2, Cursor law).** Any running artifact — web preview in the tokenized loopback, native screen on device — can enter pick mode: point selects one element (accent outline + mono selector tag), select-area draws a dashed marquee over a region. A comment pin on a selection is NOT an annotation tool: sending it mints an addressed beat in the docked room carrying a ref chip (pin · selector · surface), so the actor's reply, work card and attributed diff return to the same thread, and "keep" applies the staged change where the pin points. One picker over web AND native; the ref chip is the contract that keeps a comment addressable after the surface re-renders.

**Tabs are the universal content surface (v2, owner law).** The strip carries the browser/VS Code law: everything openable — a room, a thread, an artifact, a design surface (the web/native picker), an actor page, and every future format (image editing/generation, video, audio, multitrack timelines) — opens as a TAB: persisted by ViewLayout, closable with ×, re-openable from the action bar or the new-tab picker. **Tabs are instances, not singletons**: the same kind opens N times (two design surfaces side by side, each with its own pins, dock and ref chips), because surfaces, editors and rooms all carry per-instance state. **Splits are core, not later**: the split control moves the active tab into a second pane, each pane owning its own tab group — two tabs' content at once, the VS Code anatomy; the comment loop's sanctioned home is a conversation in one pane and its design surface in the other. **The title bar is gone**: traffic lights share the one tab row (Safari/Discord anatomy); rounded compact tabs (27 px, radius 8) are the only chrome up top. **The rail is a Discord-style action bar, mostly unnecessary by design**: rounded-square icons per tab kind with unread pips and an active pip; a click opens the kind's first tab and further clicks CYCLE its open tabs — fast navigation among similar tabs, never a persistent list column (room discovery lives in the + picker and the palette). The new-tab picker enumerates the format registry: rows openable today plus named runway rows as honest absences. Onboarding/first-run is a BOOT state, never a tab. Usability consequence: a working set is a SET OF TABS ACROSS PANES — restorable, shareable as a layout — and a new content kind is a new tab-view registration on the format registry, never a new shell.

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

- A fixed chat center with all other surfaces treated as secondary tools. (v2 note: conversation is the primary INTERACTION mode — the door — but the pane law stands: artifacts, inspector and terminal are peers of the rooms, never hidden tools of a chat app.)
- A second navigation system inside inspector, browser, or settings that duplicates workspace navigation.
- Rainbow actor colors, decorative node clouds, status dashboards, or metrics without a source and task purpose.
- Rounded boxes around every control, message bubbles, or cards used only to partition the layout.
- Small caps as a replacement for hierarchy, tiny low-contrast timestamps, and color-only state.
- Creature motion that carries no world fact (v2): an idly dancing mascot, a mood with no source, a celebration for nothing settled.
- Fake live data. Concept material uses clearly identified synthetic examples.
