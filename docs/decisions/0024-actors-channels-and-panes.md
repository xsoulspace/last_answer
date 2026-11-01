# ADR 0024 — Actors and channels, not chats; panes, not a fixed center

- Status: Accepted (approved by Anton Malofeev, 2026-10-29)
- Date: 2026-10-29
- North Star impact: `refines` — the conversation-first product of
  [0023](0023-chat-first-product-and-retire-materialization.md) gets its
  product vocabulary and its shell corrected: the objects are actors and
  channels, the shell is a pane tree, and the durable-thread substrate is
  unchanged.
- Builds on: [0023](0023-chat-first-product-and-retire-materialization.md)
  (chat-first product, own ecsai agents first — this ADR amends 0023's
  product word and shell direction where they overlap),
  [0010](0010-one-harness-doc-surface-unification.md) (chat as a projection,
  never a document store),
  [0007](0007-actor-roster-and-multiplayer-identity.md) (actor roster and
  multiplayer identity).
- Harness dependencies (referenced, never imported): ecsai_harness ADR 0115
  (tasks and durable conversation as realm abilities over one uniform verb
  surface), ADR 0116 (actors, not workers — the peer-coordination
  vocabulary), ADR 0107 (one world per realm, projects as scopes, durable
  state out of `.dart_tool`).

## Context

The chat-first decision (ADR 0023) fixed the product entry on
actor-to-actor conversation over the ecsai world's durable threads. Two
things in it were provisional: the word "chat", and the implied shape of
the surface — one conversation center flanked by chrome. Three facts
sharpened both:

- The harness settled its own vocabulary: actors, not workers (ADR 0116) —
  internal bots and external humans/agents are equals — and durable
  conversation and tasks are realm abilities every client calls through one
  uniform surface (ADR 0115). "Chat" names a legacy feature of the old app,
  not an object in this world. The rail of a conversation product should
  list WHO can be reached — identities — not a pile of transcripts.
- The Zed lesson: a fixed center area with sidebars cannot host the real
  variety of surfaces this product needs (direct conversations, channels,
  the browser, the world inspector, project documents, settings) without
  making one of them second-class. Zed's answer — the whole center is a
  pane tree of tab groups that split and serialize — is the answer here,
  and it dissolves navigation instead of decorating it.
- The substrate is already correct and needs no change: durable threads and
  beats with explicit addressing; actors are durable world records; the
  roster (ADR 0007) gives them user-facing identity; and the world has ONE
  realm control store with projects as scopes (ADR 0107).

This ADR records the vocabulary and the shell. It amends 0023 where they
overlap — 0023 said "chat", 0024 corrects the product word and the shell.
The durable-thread substrate, the own-agents-first ordering, and the
configuration-in-Settings law carry over unchanged.

## Decision

1. **Actors are the primary object; "chat" is retired as a product word.**
   The rail lists identities, not conversations:
   - **Actors** — humans, model bots, external agents; mechanics later.
   - **Channels** — named group spaces with mixed membership (like Discord
     channels): one space, several actors of different kinds.
   - **DMs** — actor-to-actor direct threads.

   Mapping to the substrate, one line each, no second vocabulary: an
   **actor** is a durable `realm_actors` record plus a roster
   `ActorProfile` (ADR 0007); a **channel** is a durable thread with named
   membership registered in an LA-owned `channels` collection in the same
   realm control store; a **DM** is a two-member thread. "New chat" is
   replaced by "message an actor" and "open or create a channel".

2. **Identity markers are derived, not authored.** Avatars are
   deterministic identicons derived from the actor id — stable across
   devices, no image assets. Kind badges come from the roster kind; presence
   shows online while the actor's listener loop is running, otherwise the
   world's `lastSeenAt`. The human-readable mapping (id → name, identicon,
   badge, presence) is UI over the records, never a second identity system.

3. **The center is not fixed — the app is a pane tree** (the Zed lesson).
   Leaves show surfaces: an actor DM, a channel, the browser, the world
   inspector, project documents, settings. Leaves stack into tab groups;
   groups split on either axis; the tree serializes (per project scope) and
   reopens as it was. Every window-capable surface is window-agnostic by
   construction; tear-out into separate OS windows is a later, desktop-only
   rendering concern that requires no data-model change.

4. **Navigation dissolves.** No home route, no project list as the app's
   face, no Workbench entry, no greeting header. Ideas and Notes remain
   project content, reachable through search and a Projects section of the
   rail — content in the tree, not navigation chrome. Settings is a surface
   (a tab in the pane tree), not a modal; it keeps the Agents & Models pane
   from [0023](0023-chat-first-product-and-retire-materialization.md)
   (actor creation, agent servers, observability).

5. **Store law (conformance, not a new decision).** The realm world the
   product's conversation rides is the ONE realm control store under
   `~/.xsoulspace/worlds/local/` (ecsai ADR 0107). Durable state never
   lands in `.dart_tool` or app-private directories. Last Answer enrolls as
   a project scope; workspace binding follows ADR 0107 §D3 (the seat binds
   a project, not a workspace).

## Non-goals

- Multi-window tear-out — a later desktop slice; the pane-tree data model
  already supports it.
- Drag-to-rearrange panes — command-driven splits come first.
- Mechanics as a new `ActorKind` — a later kernel-doc change, not a
  product-side extension.

## Falsifier

This decision is being violated — revise rather than layer — if actors and
channels come to require a second identity system beside the roster/realm
records, or if the pane tree grows surface-specific layout code (a
special-cased center for one surface). Durable conversation state appearing
outside the realm control store is the same violation wearing the store's
clothes.
