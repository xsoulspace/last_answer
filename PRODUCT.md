# Product

<!-- impeccable:product-schema 1 -->

## Platform

adaptive

## Users

Primary users are people who organize their work in local workspaces and want to think, write, browse, and collaborate with human and AI actors in the same place. The shell direction is desktop-led; the product also targets mobile and web.

## Product Purpose

Last Answer is a cross-platform, local-first workspace for notes, ideas, documents, and agent-assisted work. It gives a person one place to work with other participants, follow what they are doing, and move between conversation and the material being changed. Success means people can return to understandable, attributable work and remain in control of what an actor may do.

## Positioning

Last Answer treats a workspace and its typed project state as the shared source of truth. Conversation, actor activity, browser sessions, and spatial inspection are connected views of that work. The first external-agent direction is Last Answer launching ACP agents; inbound operator access is a later gate.

## Operating Context

People work across one or more workspaces, each of which may include several folders and nested workspace relationships. They open actors, channels, files, browser sessions, and other surfaces together, often in long sessions with interruptions. They need to resume prior state, understand who acted, and inspect permissions or outcomes without making harness details mandatory reading.

## Capabilities and Constraints

- The application is built with Flutter and targets desktop, web, and mobile.
- Workspaces, actors, channels, durable conversations, and pane-tree shell concepts are established in the repository's accepted product decisions.
- The same surface can appear as a side-panel tab, a workspace pane, or an in-app miniwindow.
- The world inspector is a spatial and temporal view of the same world. It is an optional work surface, not a separate authority.
- Local-first behavior, explicit network use, deny-by-default permissions, attributable history, and honest status are product constraints.
- Current status and maturity vary by capability. This record describes product intent and does not claim every described workflow is complete or accepted.
- The primary shell adapts its composition by available width and input method while keeping one product language across desktop, web, and mobile.

## Evidence on Hand

- Repository product decisions and implementation: `docs/NORTH_STAR.mdx`, `docs/product/agents-in-docs.md`, and accepted ADRs 0024–0027.
- Owner-provided visual references in the 2026-10-30 design request: an actor/channel conversation shell and two spatial world-inspector explorations. These are references, not product evidence or implementation requirements.
- Do not invent usage metrics, customer claims, or live-world data for visual concepts. Mark illustrative interface data as synthetic.

## Product Principles

1. One workspace, several connected views.
2. The human can understand, constrain, and stop actor work.
3. Work survives interruption with clear attribution and history.
4. Local data and explicit network boundaries come before convenience.
5. More capable views add depth without making the everyday surface harder to use.

