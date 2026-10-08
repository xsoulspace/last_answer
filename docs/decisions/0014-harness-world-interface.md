# ADR 0014 — The harness world interface: sectors without borders, palette-first

- Status: Proposed (design; implementation staged in [PLAN.md](../PLAN.md))
- Date: 2026-10-07
- North Star impact: `strengthens` — any document is a shared workspace for
  humans and agents; the harness world is the coordination substrate, and its
  interface must make many-actor collaboration legible without new authority.
- Builds on: [0003](0003-agents-live-in-docs.md) (agents live in docs),
  [0007](0007-actor-roster-and-multiplayer-identity.md) (actor roster and
  identity), [0008](0008-local-first-model-federation.md) (federation and the
  single materializer), [0009](0009-session-registry-and-many-worlds-debug-state.md)
  (many-worlds state), [0012](0012-writable-agent-doc-and-acp-client-first.md)
  (conversation is a projection), [0013](0013-mesh-task-board-over-ecsly-world-sync.md)
  (tasks as world data), and the harness's own contracts (ADR 0072 paired
  worlds, 0074 presence, 0077 seat ergonomics; the single-instance and
  deny-by-default laws).

## Context

The harness is not a chat app and not an editor. It is a persistent WORLD:
any actor — a human, a hosted decision model, an on-device AFM, a local
laya-serve, an external coding agent over ACP, a foreign CLI speaking MCP —
can be present at the same time, see each other, claim work, message, and
pass acceptance. The user's framing is exact: an MMO with any actors and
"no-borders sectors", configurable by the user. The default surface must be
the CURRENT PALETTE — the inspector's ⌘K palette whose roster already IS the
verb set.

Before designing an interface, three questions must be pulled apart, because
MMO intuition conflates them and each has a different right answer here.

### 1. What is a "sector", really?

In MMOs a zone does three jobs at once: it is a VISIBILITY domain (what you
can see), a COORDINATION scope (who you can group with), and an AUTHORITY
fence (which server owns your actions). The critical design error would be to
invent one construct doing all three here. Our authority fences already
exist and must not move: the workspace materializer law (ADR 0008 — the
owner remains the single materializer/oracle), claim exclusivity (one
claimant per step), and the deny-by-default admission law. Re-drawing those
as "sectors" would either weaken them (a border a user-config must not be
able to move) or duplicate them (two fences, one lie).

**Decision: a sector is a LENS, not a fence.** Sectors scope attention —
which presence, tasks, transcripts, and events a surface SHOWS and which
defaults a NEW task picks up — and nothing else. They may overlap; actors
inhabit several at once; crossing one never grants or denies authority.
"No-borders sectors" is therefore taken literally: borders stay exactly
where the existing laws put them; sectors are the user's drawings OVER the
world, the way an MMO's social tabs and custom map markers sit over zones.

### 2. Who is an actor, and where does identity live?

Already solved — seats, `<client>-<role>-<n>` naming, the actor roster,
capability facts. The sector interface must NOT mint a second identity
system: sectors reference existing actor ids, and admission stays a seat/
pairing concern (deny-by-default), never a sector concern. A sector a user
draws can never make a stranger present; it can only decide what the user
LOOKS AT.

### 3. Where does configuration live?

The Zed lesson this repo already applied for agents (ADR 0012's
`agent_config.json`): one editable FILE the human owns beats a settings
maze, and UI is an editor over the file, not the source. Sectors follow the
same shape: a world manifest the user can hand-edit, with palette verbs as
the ergonomic writer. And per ADR 0012's own law — conversation and view are
projections — the manifest is PROJECTED onto surfaces; the harness world's
durable data (tasks, claims, presence, acceptance) does not change shape
because the user redrew their lenses.

## The interface

Three surfaces, one vocabulary, no new chrome:

1. **The inspector is the MAP.** It already observes many-worlds state
   (ADR 0009) and is full-screenable. Sectors render as named overlays:
   the actors and task rows matching each sector group under its name;
   the focused sector dims the rest (fog-of-war as read-budget, not
   access-control — the meaning profile's budgeted zoom, applied to
   attention).
2. **The palette is the VERB SET.** Default experience = today's palette,
   unchanged: one borderless sector named e.g. `world`, everything visible,
   the roster listing actors and their verbs. The palette GAINS exactly
   three sector verbs: `sector:focus <id>`, `sector:pin <doc/task>`,
   `sector:define` (opens the manifest at the right place). Verbs execute
   through the existing registry — the inspector stays read-only, the
   read-only law holds.
3. **Live docs and chats are the WORKBENCH.** A chat or agent doc shows the
   sectors it belongs to (derived from its workspace, tags, bound world —
   the same facts the multiplayer header already shows). Belonging is
   derived, never configured per-surface twice.

### The manifest

```jsonc
// .xsoulspace/world.json (workspace scope) — unioned with the global
// config the same way agent_config already is. Hand-editable; the
// palette writes it; defaults regenerate when absent.
{
  "sectors": [
    // DEFAULT: absent manifest == exactly this. Today's behavior, named.
    {
      "id": "world",
      "name": "World",
      "match": { "everything": true },
      "borders": "none"
    },
    {
      "id": "fleet",
      "name": "Fleet build-out",
      "match": {
        "workspaces": ["~/xs/ecsai_harness", "~/xs/storage_problem"],
        "actors": ["zcode-external-1", "codex-1"],
        "tags": ["fleet"]
      },
      "borders": "none" // or "claims": dim foreign claims, never hide
    }
  ],
  "focus": "world"
}
```

`match` is a QUERY over existing world data (workspace paths, actor ids,
doc tags, bound world ids) — never a container, never a copy. `borders` has
two values only: `none` (pure lens) and `claims` (a RENDERING stance: foreign
claims render dimmed with their owner — honesty on the map, still no denial).
There is deliberately no `hard`.

### What the harness MMO gets from this, concretely

- A human on the phone opens the inspector full-screen, focuses `fleet`,
  and sees exactly the actors, tasks, and transcripts of one effort while
  the world behind keeps running (absence is normal; fog is a dim, not a
  lie).
- Delegation across sectors is ordinary task delegation — acceptance stays
  canonical and frozen; sectors only decide WHERE IT IS VISIBLE and which
  defaults a new task inherits (stage 2).
- "Any actors join" is already the seat/roster/capability path; the sector
  interface adds no admission rule to get wrong.

### Explicitly rejected

- **Sector-scoped permission overrides.** Permissions stay per-chat
  policies (`ChatPermissionPolicy`: ask / workspace edits / full access)
  and per-doc consent. A lens must never carry authority — that way lies a
  checkbox that silently widens what an agent may touch.
- **Hard borders and sector-scoped worlds.** Many worlds exist (paired
  worlds, per-workspace worlds); multiplying them per-sector rebuilds
  sync under a worse name. One world, many lenses.
- **MMO simulation beyond the metaphor.** Health bars, aggro, spawns: the
  useful MMO residue is presence + visibility + grouping, all of which the
  harness already has as world data. The rest is set dressing that would
  cost honesty (rendered state must be real state — DESIGN §6).

## Staged implementation

- **Stage 0 (shipped 2026-10-07):** the palette default, the full-screen
  inspector map, capability-facts advertisement (`device_capabilities`),
  per-chat permission policies, multiplayer chats over the LAN mesh.
- **Stage 1:** the manifest file + loader (same union rule as
  `agent_config`), sector overlays in the inspector and task board, the
  three palette verbs.
- **Stage 2:** sector-aware defaults — new tasks/delegations inherit the
  focused sector's match as their visibility hint; presence grouped by
  sector in the roster.
- **Stage 3:** cross-sector choreography views (a delegation's route shown
  across lenses), still with acceptance unchanged.

## Open questions

- Should `focus` sync across a user's devices over the mesh (attention as
  synced state), or stay device-local like focus markers today? Leaning
  device-local (ADR 0009 §Open questions 1) until a second device shows
  the need.
- Sector membership of a NEW doc: derived from its first workspace bind
  (automatic) or asked at creation (explicit)? Leaning derived; creation
  flows must stay one step.

## Implementation status (2026-10-08): the runtime substrate landed package-side

The sector LENS design here is unchanged, but its Stage-1+ mechanics now
exist one layer down, product-agnostically — `dart_flutter_packages`
[ADR 0047](../../../dart_flutter_packages/docs/decisions/0047_world_layer_zone_journeys.md)
(the world layer: `universal_storage_world`, `MeshWorldSession`,
`ZoneCatalog` as the runtime census this ADR's manifest configures,
`JourneyState` as the border-crossing machine) and
[ADR 0048](../../../dart_flutter_packages/docs/decisions/0048_interest_managed_exchange.md)
(interest-managed mesh exchange — the `sub` frame is the mechanism under
"sectors are lenses, not fences": a sector is now literally a subscription
predicate, with zero authority attached). The harness side of the census
contract is [ADR 0083](https://github.com/xsoulspace/ecsai_harness/blob/main/docs/decisions/0083_beat_census_delta_contract.md) (the beat census contract, harness repo). What
remains LAST ANSWER-side is exactly this ADR's UI plan: the palette sector
verbs, inspector overlays, and the `.xsoulspace/world.json` loader — the
default palette behavior is shipped behavior and stays the default.
