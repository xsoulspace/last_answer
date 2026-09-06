# ADR 0007 — Actor roster and multiplayer identity (peers carry actors)

- Status: Accepted (direction; implementation gated per phase — see
  [PLAN.md](../PLAN.md) Phase 5)
- Date: 2026-09-06
- North Star impact: `clarifies` (of ADR 0003's actor model — actors were
  already "agency-holding entities"; this gives them user-facing identity)
- Builds on: [0003](0003-agents-live-in-docs.md) (actors, brains as data),
  [0005](0005-doc-multiplayer-over-convergence-kernel.md) (join model),
  [0006](0006-session-is-not-world.md) (Sessions → Actors registry)
- Infra dependencies (referenced, never imported): dart_flutter_packages
  ADR 0031 (presence topology; frames authenticate PEERS, actors ride
  payloads; roster syncs as durable ops)

## Context

Multiplayer sessions need a stable vocabulary for WHO is working, beyond
devices: a device hosts several actors (AFM, pi, a scripted mover, the
human), the same actor identities recur across days and devices, and other
people's clients join with their own actors. Two identity layers must not
be conflated:

- **Peer** — the device, authenticated by pairing identity keys. Frames
  authenticate peers (infra ADR 0031 §3). Spoofing a peer is a security
  problem.
- **Actor** — agency within a session: a model with a role, an agent
  runtime, a human. Actors are data (ADR 0003), recur, and should feel
  persistent ("the actor I usually work with"), not per-session ghosts.

## Decision

### 1. ActorProfile: stable, user-scoped, shareable

`ActorProfile { actorId, displayName, kind (model | agent | human),
brainRef (backend/model identity), role }` — `actorId` is stable across
devices and sessions. Profiles live in a **roster** that syncs as durable
kernel ops (LWW map) alongside other synced doc data — so a user's roster
follows their devices automatically ("automatically share the same
actors"). Roster edits are ordinary local-first edits; no account, no
server (mesh law, ADR 0010 infra).

### 2. Presence keys are (peerId, actorId)

An actor is live **on a peer**: presence announcements (ephemeral ops per
infra ADR 0031) reference a roster `actorId` inside the authenticated
peer frame. The same `actorId` live on two devices renders with a peer
annotation — the roster is the dedupe key, the peer is the location.
Presence folding stays kernel-owned (ADR 0029 §1); the roster is ordinary
durable state, never special-cased.

### 3. An actor announcement never grants authority

Joining with an actor profile is NOT delegation. Agency flows only through
the existing intents and the permission round-trip — deny-by-default per
device, reject-first, recorded as data (ADR 0005 §5, North Star value
path 1). A joined actor from another app is a label on a session row until
a human grants it work.

### 4. UI: the roster is a PROFILE pane section, on the grid

- PROFILE gains an `ACTORS` section (DESIGN §4 — one simple place):
  roster entries as small multiples (name, kind, brain, role), add/remove
  in-flow, no forms-as-pages.
- Session rows (ADR 0006 registry) list their actors; live actors show the
  gutter-label treatment from DESIGN §9 (peer/actor labels, no avatars).
- Actor labels extend the existing gutter vocabulary; `YOU` remains the
  human's label. A model+role actor renders its small-caps name
  (`AFM-CODER`, `PI`, …) — same size, same tracking.

## Non-claims

- No actor-level permission model yet (permissions remain per-device
  round-trips; per-actor budgets are a later, separately gated decision).
- No cross-device actor *handoff* (an actor's live session does not
  migrate mid-task; the roster only shares identity, not execution).
- Roster sync inherits the kernel's convergence properties — no roster
  UI merge conflicts are designed for in v1.

## Consequences

- `HarnessSessionView`/actor registry gains profile references (ADR 0006
  registry's `Actors[]` becomes roster-backed).
- The doc-surface gutter, presence tracker, and permission flow read one
  actor identity — one state, many projections (DESIGN §5).
