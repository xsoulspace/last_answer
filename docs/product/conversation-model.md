# Conversation model — one surface, mechanical chatness

> Product spec for the unified conversation surface. Implements
> [ADR 0010](../decisions/0010-one-harness-doc-surface-unification.md)
> (one harness, chat is a projection) and
> [ADR 0011](../decisions/0011-multiplayer-sessions-and-queue-as-graph.md)
> (queue as graph). Reviewed against [DESIGN §10](../DESIGN.md)
> (attention is a budget).

## The one move

There is one document. The user opens it and types plain text. Every
conversational capability attaches **mechanically, when used** — never
as a type chosen up front:

- Select a span → *Discuss* / *Ask* → a child document thread opens
  (ADR 0001). The user never "switched to chat mode".
- Delegate a task → the turn materializes as messages on the grid;
  live while running, authored text when cooled.
- The difference between "a doc" and "a chat" is mechanical state in
  the node store, invisible as a category to the user.

## Creation and the rail

- The rail is a fixed-position motor-memory anchor, not a species
  picker: **`+` / Idea / Note** (invariant order, hover-expand labels
  on desktop, no gradient, no decorative chrome — DESIGN §2).
- `+` opens plain text. No format choice. GDD/PRD are deleted
  (never used in production; ADR 0010 D3). `formatId` stays as an
  opaque field for the future extension system — it ships no values.
- Dead ink is deleted (the Bugs bar item with an empty handler).

## The message state machine

```
composing → queued(steer | immediate) → sending → materialized → cooled
```

| State | Renders as | User powers |
|---|---|---|
| composing | composer row | type, branch (child thread), discard |
| queued | `YOU` row + dim `STEER`/`NOW` gutter annotation + position + age | edit in place, cancel, branch, promote to NOW |
| sending | `YOU` row + `···` live row (attributed actor) | — (interrupt already decided) |
| materialized | authored text rows, beats collapsed to L1 | select → discuss/edit/branch |
| cooled | same, editable | edit (adds `EDITED` SYS annotation), branch, archive |

### Semantics (ChatGPT-familiar, grid-native)

- **Steer (default while generating):** the message joins the queue and
  waits for the current turn's verdict, then becomes the next turn's
  prompt. Unsteered messages wait until generation completes.
- **Send immediately (explicit per message):** interrupt. Order of
  operations (DESIGN §4 extended): reject the pending permission first
  → stop the turn **at the next beat boundary** (never mid-tool —
  unknown world states are how oracles rot) → the verdict **lands
  anyway with partial spend** (§6: an interrupted turn still spent
  money; pretending otherwise is dishonest) → the immediate message
  becomes the new turn.
- **Edit queued:** any queued row re-opens in place; it is just text.
- **Multiple queued messages:** sequential turns — one verdict and one
  spend per turn stays honest, and each queued message can still be
  branched before it sends.
- **Queue is a graph region** (ADR 0011 D3): a queued message is a
  queued beat on the frontier; forking the frontier partitions the
  queue per branch; mechanical actors may validate/check candidate
  branches LLM-free; the human promotes a branch. Until the mechanical
  projection tier lands, the queue degrades honestly to a linear
  frontier.
- **Queues are lanes, plural** (ADR 0011 D5): a queue is directed
  actor→actor — a message is queued *for* a specific steer target.
  One session runs many lanes (human→model, human→mechanical, a second
  human→the same model, model→model). Every lane renders on the same
  grid, attributed; a lane you are not addressing stays collapsed
  (L0/L1) until opened. Default composer lane: human→active agent;
  other lanes opt-in, equally first-class, always observable.
- **Widget keys:** `coding_agent.queue.{steer,sendNow,cancel,edit,
  branch}` — the queue is in the debug-state projection (§5), so the
  headless inspector sees the same queue the human does.

## Cooled turns and edit history

- When the verdict lands, the turn **cools**: live beats collapse into
  the turn's text (beats remain reachable at L2/L3 — collapsed, never
  absent).
- Cooled turns are editable like any paragraph. **Per-turn edit history
  first:** an edited turn gains a dim `EDITED` SYS annotation with
  tap-to-expand diff (same mechanic as beats).
- **Node versioning later, opt-in, advanced:** a capability flag
  (`history: node-versioned`) that states its price honestly (space,
  complexity) before enabling (DESIGN §10 dials).

## Multiplayer (already law, restated for this surface)

- Peer turns render with peer gutter labels (§9); a peer's queued
  message renders exactly like a local one with an origin label.
- **Several humans side by side** is a supported shape (ADR 0011 D1):
  each human composes into their own lanes; every lane observable by
  every peer, attributed per ADR 0011 D4.
- Parallel model actors + mechanical actors in one session share the
  grid; every row names its actor (ADR 0011 D4).
- Session registry (ADR 0009) — not widget statics — is how the surface
  registers; two docs open at once is a supported, tested shape.

## Attention discipline (DESIGN §10 applied)

- Default view of a busy turn: L0 status rule + L1 progress. Beats,
  context, meaning cut: two taps away, never pushed.
- Queued rows show position + age (time made visible).
- Return-after-interruption reconstructs: queue, live turn residue,
  pending permission — all durable.
- If any of this surface's machinery becomes mandatory reading for
  writing a plain note, this spec has failed its own review gate.
