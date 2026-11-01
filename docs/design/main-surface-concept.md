# Main surface concept — one workspace, many views

**Status:** design proposal, 2026-10-30  
**Surface mode:** Operate  
**Product reference:** [PRODUCT.md](../../PRODUCT.md)  
**System:** [DESIGN.md](../DESIGN.md)

## What the product is trying to make possible

Last Answer gives a person one continuous workspace for working with other people and AI actors. They can talk, browse, edit, inspect activity, and move between these surfaces without losing the context of the work. The workspace and its project state remain the shared source of truth. A chat transcript, an actor view, or a spatial inspector helps the person read that work; none becomes a competing workspace.

The interface needs to answer three questions quickly:

1. **Where am I working?** Keep the current workspace and pane arrangement visible and recoverable.
2. **Who or what is involved?** Make actors, channels, browser sessions, files, and current permissions findable in one navigation system.
3. **What changed, and what can I do next?** Show attributed work in the active pane, with a direct path to context or a deeper inspector when needed.

## Concept: a calm instrument panel for active work

The shell is a thin frame around a pane canvas. It borrows the conversation reference's obvious actor/channel navigation and the inspector explorations' large, explorable world canvas. It does not make the full app resemble a monitoring dashboard: the map and time controls appear only when the world inspector is open.

### Main desktop composition

Use a 1440 × 900 reference frame with four distinct regions:

- **Global rail, 56–64 px:** stable destinations and workspace access, including universal search. Avoid a crowded strip of equally important icons; use short labels on hover and accessible names at all times.
- **Workspace navigator, 248–280 px:** current workspace selector, search, workspace roots, then actors and channels. Actor rows carry name, kind, and concise presence or last activity. Channel rows carry name and a one-line recent preview. Keep section disclosure and create actions near the section they affect.
- **Pane canvas, flexible:** a quiet tab bar above the active surface. Tabs name their destination (for example, `# research`, `World`, `Browser`) and offer close, split, and add-pane actions from a consistent menu. The active conversation fills the pane without bubbles. Its text column stays readable; the composer anchors to the bottom edge.
- **Context panel, 260–300 px, optional:** details for the active selection. In a channel, show members and shared files. In the inspector, show the selected object, its source, and available actions. In a browser, show page/session context. Hiding the panel gives the canvas more room and does not hide status needed for a decision.

The initial shell should have a focused default: one workspace, one open conversation pane, a small set of actor/channel destinations, and a closed or narrow context panel. A user should be able to start writing without first configuring a layout.

### Conversation pane

Use a concrete synthetic example: `# field notes`, with a human, one named research actor, and one invited reviewer. Make authors and times easy to scan while keeping message text visually dominant. Show one ordinary message, one actor response, and one compact permission or task state only if the scenario needs it. Do not use large headers, decorative avatars, metric bars, or bubbles. The composer has a clear prompt, attachment affordance, and send action; it stays in the same place as the conversation grows.

The context panel answers “who is here?” and “what belongs to this channel?” It is not a mandatory roster dashboard. Presence distinguishes active, idle, and away with a quiet mark plus text or accessible label.

### World inspector pane

Opening `World` replaces the active pane content while preserving the shell and pane tree. The world canvas occupies most of the available area. A modest top row names the view and the current scope; a bottom time control appears only when the user is exploring historical change. Search, filter, and view controls remain reachable from the inspector pane.

At overview zoom, show a handful of labeled project scopes with a small number of meaningful relationships. On approach, expose actors and event clusters. Selection opens grounded detail in the context panel or a compact inspector drawer. The user can jump from an object to its source conversation, workspace, or event. Every spatial control has a readable list/detail route and keyboard action.

Keep graph and timeline content out of the everyday conversation shell. Use synthetic fixture labels whenever the concept does not depict a live connected world.

### Future surfaces

The pane contract must work for a browser tab, terminal, settings, and a document editor without a new app-wide navigation model. The shell provides the workspace name, pane identity, split/tab actions, search, and context panel. Each surface provides its own content, toolbar, and meaningful state. Miniwindows reuse the same surface identity and actions at a smaller presentation size.

## Design system at a glance

The exact reference tokens and states live in [DESIGN.md](../DESIGN.md). The main product decisions are:

- deep blue-green neutral surfaces, with a considered light theme;
- one seafoam focus/action accent and semantic danger/caution colors;
- stable actor identity marks rather than random saturated avatars;
- compact, readable sans-serif UI type with tabular time and count values;
- 4 px spacing base, modest corner radii, hairlines between regions, and one restrained floating-layer shadow;
- no message bubbles, card walls, decorative gradients, or permanent dashboard metrics;
- brief, reversible motion that explains pane, selection, or panel changes.

## Interaction priorities

- Universal search opens from one stable shortcut and finds actors, channels, workspaces, files, and pane surfaces.
- Opening a destination reuses or opens its stable surface identity; it does not create a parallel “chat app.”
- Split and close actions are available from the pane tab and keyboard. Closing the final pane returns to a workspace-focused empty state with a clear next action.
- Context panel follows the current selection, but can be pinned or hidden without changing shared state.
- Pane arrangement is personal view state; shared edits, conversation beats, and task outcomes remain attributed project state.
- Permission requests and failure states stay in the active work context and explain the action available to the user.

## Concept image prompts prepared for image generation

Image role: the supplied screenshots are **references**, not edit targets. Use the actor/channel screen for navigation and conversation density; use the two dark inspector explorations for canvas scale, semantic zoom, and a restrained spatial palette. Do not copy their exact labels, proportions, or metric headers.

### Concept image A — conversation shell

Use case: ui-mockup  
Asset type: high-fidelity desktop application concept, 1440 × 900  
Primary request: show Last Answer as a cohesive shared workspace for humans and AI actors. The frame contains a narrow global rail, a workspace navigator with a few actors and channels, a pane tab row, one open text-native group conversation, and an optional contextual member panel. Give the writing surface the largest share of attention. Use short, plausible synthetic content with clear authorship and timestamps.  
Style/medium: polished, realistic desktop product UI, precise spacing, restrained controls, crisp type, not a marketing page  
Composition/framing: straight-on full application window, legible at presentation size; show the pane boundaries and one clear active destination  
Color palette: deep blue-green neutral surfaces, soft near-white ink, a single seafoam accent, quiet neutral actor marks  
Constraints: no message bubbles, no cards around every section, no decorative metrics, no fake real customer data, no logos beyond the text name “Last Answer”  
Avoid: copying any reference screenshot pixel-for-pixel, rainbow avatars, overlarge toolbar chrome, unreadable micro-text, gradients, glowing effects

### Concept image B — world inspector inside the workspace

Use case: ui-mockup  
Asset type: high-fidelity desktop application concept, 1440 × 900  
Primary request: show the same Last Answer shell with the World Inspector open as an ordinary pane. A large spatial canvas shows a small, labeled set of workspace scopes, actors, and meaningful relationships. A contextual panel explains the selected object and links it to its source. A restrained timeline sits at the bottom of the canvas. The navigator, pane tabs, and shell identity remain consistent with the conversation concept.  
Style/medium: precise product interface with a readable semantic graph; use crisp lines and restrained node marks rather than atmospheric network art  
Composition/framing: straight-on full application window; canvas is the largest region; labels and selection hierarchy are readable  
Color palette: same deep blue-green system as Concept A; seafoam selection/focus, muted blue relationship lines, semantic amber only for attention-needed state  
Constraints: synthetic data clearly labeled; one-world view with workspace scopes, not separate worlds; keep shell controls and selected-object details visible; spatial controls have a simple list alternative suggested by a visible control  
Avoid: oversized counts in the header, dense unlabeled node clouds, bloom/glow, pseudo-3D decoration, copied reference layout

### Concept image C — pane system and settings

Use case: ui-mockup  
Asset type: high-fidelity desktop application concept, 1440 × 900  
Primary request: show Last Answer with a two-pane workspace: a browser surface on one side and a compact actor conversation or terminal surface on the other, with the pane tree and tabs making their relationship clear. Include a settings destination in the navigator or tab list, but keep settings out of the active work area. Demonstrate that future surfaces fit the same shell.  
Style/medium: polished functional desktop product UI, distinct content types, quiet chrome and precise alignment  
Composition/framing: straight-on application window with a clear split divider, tab identities, and one selected pane  
Color palette: same neutral and seafoam tokens as Concepts A and B  
Constraints: shell remains recognizable; show functional titles and state; no duplicate sidebars inside panes; synthetic content only  
Avoid: nested rounded cards, many competing controls, fake terminal output presented as a real result, decorative server/activity dashboards

## Open decisions

- Confirm whether the product should be treated as one adaptive design language on every platform or gain distinct native layouts on mobile.
- Confirm whether the global rail should retain text labels at desktop widths or rely on a compact labeled-on-hover arrangement.
- Select a preferred generated concept before any UI implementation is treated as visual acceptance.

