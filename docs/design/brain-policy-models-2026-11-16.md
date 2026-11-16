# Brain policy — models without palette words (2026-11-16)

Owner-approved redesign of the Models surface. Supersedes the *naming* of
[models-management-refactor-2026-11-14.md](models-management-refactor-2026-11-14.md);
its candidate state machine, verbs and laws stay.

## Owner directives (2026-11-16)

1. The word "palette" dies from user surfaces. Adding a model = choose
   provider → choose model, using what is already configured.
2. Bindings become "brain"; managed automatically as much as possible.
3. Self-explanatory to a zero-knowledge user: every row reads as a
   sentence about behavior, never a config fact.
4. Full UI/UX rewrite authorized if needed (ecsly + ecsly_flutter +
   the shell's shadcn-ish kit).
5. The user sets a global model set with escalation/usage conditions,
   overrides the set per actor, and the actor rebinds itself within
   its set.

Owner decisions: policy lives in the **harness** (single source; the
daemon executes escalation); commit to **A→B→C as one program**;
self-rebind is **ON by default, togglable globally, overridable per
actor**; escalation narration in Observe.

## The mental model

```
1. MODELS          what the world can reach, grouped by where it runs
2. BRAIN POLICY    the world default: which model thinks first,
                   what to try when it is down or stuck
3. ACTOR BRAIN     what one actor uses now; Automatic (follows the
                   world policy) or its own ordered set
```

The conditions are already measured by the world — provider failures
with cooldown + auto-revive (ADR 0135), stall ×3 → one promotion (ADR
0122), the dispatch ceiling (ADR 0130). The UI narrates what the world
does; the user only declares intent (the order).

## Vocabulary law

| Dies from user surfaces        | Becomes                          |
|--------------------------------|----------------------------------|
| palette                        | (nothing; world default)         |
| `Palette · <entryId>` label    | pretty model name ("Qwen3.7 Plus") with the entry id as the mono subtitle |
| rung                           | position in the policy order ("thinks first", "if … is down or stuck") |
| lane                           | "where it runs" chip (remote / loopback / subscription / on-device) |
| binding                        | "uses" (actor chips on a model row) |
| primary radio                  | position 1 IS the default (the `primary` mark is maintained by the order, see Stage A) |

Config keys (`model_palette`, `realm_actor_escalation`) absorb — they
stay until Stage B replaces them (ADR 0028 absorb-not-rename
precedent). Internal class names (`PaletteConfig`, `CastBrainDecl`,
`brainCast`) are not user surfaces and keep.

## Stage A — language + automation (LA only, no harness change)

Landed in this doc's commit:

- **Labels**: `Palette · <id>` → pretty model name everywhere the brain
  is picked or shown (`actor_brain.dart`, shared helper in
  `palette_lanes.dart`); the entry id stays as the mono subtitle — it
  is the stable handle agents reference.
- **Policy sentences**: the Bindings lens renders the order as
  sentences — position 1 "thinks first", every following row "if
  <previous> is down or stuck". The `→ next` chip and the primary
  radio die.
- **Position-1-is-default invariant**: `PaletteCandidateModel.moveCast`
  now maintains the persisted `primary` mark — the first generative row
  always carries it. One concept, not two.
- **Escalation narration**: `ActorTelemetry` parses the flattened
  `escalatedFrom` the daemon already records in `tool_loop_telemetry`;
  the Observe ledger shows "stalled → tried <model>" instead of a bare
  `stalled` chip. The world says what it did.
- **System lanes**: decision-role rows collapse under one header with
  one sentence ("the world's own quick decisions — leave these
  alone"). A layperson learns they exist and not to touch them.
- **Actor chips cap**: a model row shows up to three actor chips, then
  "+N more" — the first 2000-actor mitigation (full projection work is
  Stage C).
- **Actor card**: "Brain (model)" → "Brain".

**Widget-key migration note (agent UI contract, DESIGN.md):** the row
key `models.rung.<id>` and the verb keys `models.cast.<id>.up/down`
are UNCHANGED. The radio verb key `models.cast.<id>.primary` is
REMOVED — the persisted default is position 1 now; agents that pressed
that radio should move the row to the top instead (`models.cast.<id>.up`).
New keys: `models.systemLanes` (the collapsible header).

## Stage B — the contract (harness ADR 0143 + LA surface)

Harness (`ecsai_harness`), ADR 0143:

- A declared **brain policy** section absorbs the two authoring
  surfaces (cast order + `realm_actor_escalation`): one ordered list,
  escalation = the next entry in the order on stall/failure, one
  promotion per dispatch. Explicit `realm_actor_escalation` rows
  override the derived adjacency while they exist (absorb window).
- The actor row gains **`brainSet`** (an ordered subset of declared
  entries). `brainCast` stays the current pick. ensure/bind preserve
  both.
- **Self-rebind law**: an actor may `actor_bind` its own brain within
  its allowed set (its `brainSet`, else the declared palette) —
  default ON; the global toggle `realm_actor_self_bind` turns it off;
  the per-actor row field overrides the global. `bind` validates
  against the allowed set and the refusal NAMES it.

LA: the Brain override card (Automatic | own set + self-switch state),
reading and writing through `actor_ensure`/`actor_bind` — no new
mechanism, a product surface over existing verbs.

## Stage C — components (landed) and the selector migration (deliberately not taken)

**Landed**: the policy surface's reusable atoms extracted into
[lib/shell/models/policy_components.dart](../../../lib/shell/models/policy_components.dart)
— `policySentenceFor` (the behavior sentence the actor card can speak
too) and `EscalationNarration` (the promotion chip); both lenses use
them. `BrainOverrideCard` exists as the Brain-set section of the shared
actor editor (stage B). `ProviderGroup`/`ModelRow` stay inline in the
Catalog lens for now — extracting them churns a just-stabilized file
for no behavior change; they are a mechanical follow-up when the
Catalog grows again.

**Deliberately NOT taken — the ecsly-selector read model.** The
original stage-C premise ("no candidate-file dance in the read path")
turned out already satisfied: the lenses read WORLD TRUTH through
`WorldStateService` (the durable realm store); the candidate model is
edit-state by design. The ecsly selectors (`EcsWorldSelector`) select
from the ECS world — mirroring realm rows into ECS components would
create a SECOND source of truth, the duplication class ADR 0013
forbids. The migration becomes right only if/when the durable store
and the ECS world converge on one plane; revisiting then is a
one-ADR decision, not a lens rewrite.

## Non-goals

- No per-actor credentials, no actor-side `palette_apply` (the owner's
  money and keys stay owner-only).
- No automatic ladders the user did not declare: the order is intent;
  conditions are telemetry, not authoring.
- No rename of durable config keys in Stage A; Stage B absorbs them
  behind the policy section.
