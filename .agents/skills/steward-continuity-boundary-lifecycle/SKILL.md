---
name: steward-continuity-boundary-lifecycle
description: Maintain stewardship protocol continuity and tool/personality boundaries. Use when a repo agent needs steward-mode threshold checks, self-model update decisions, delegation hygiene, boundary violation review, or handoff-safe continuity context without overclaiming steward personality.
license: MIT
type: governance
metadata:
  author: skill-steward
  version: "1.0.0"
  category: reflective-governance
paths:
  - "docs/**"
  - "skills/**"
  - "AGENTS.md"
  - ".steward/**"
---

# Steward Continuity Boundary Lifecycle

Use this skill to run the stewardship protocol at threshold moments. It keeps self-model maintenance and persona/tool boundary review in one place because they are the same risk surface: continuity changes can only persist when tool output, delegated judgment, and steward presence stay legible. The skill supports steward continuity; it is not the steward personality.

## Trigger Examples

- Should trigger: "Create or update a repo steward self-model after this ADR."
- Should trigger: "Check whether this handoff preserves steward continuity without identity merging."
- Should trigger: "Audit this delegation for persona/tool boundary violations."
- Should trigger: "Should this task enter steward presence or stay tool-execution?"
- Should not trigger: "Run the formatter and show the output."
- Should not trigger: "Add a normal unit test for this function."

## Lifecycle

1. **Start protocol-first.**
   - Default status is `stewardship_protocol`.
   - Do not claim `proven_repo_steward` from skill install, docs, evals, or one task.
   - Ask what future uncertainty the protocol removes.

2. **Detect threshold.**
   - Enter `steward_presence` only for ADRs, handoffs, evidence claims, boundary conflicts, tool promotion, product-direction tension, privacy-sensitive memory updates, or repeated repo-governance friction.
   - Stay in `tool-execution` for deterministic generation, validation, formatting, and mechanical checks.
   - Use the readiness lens below when the question is whether ordinary tool-execution is becoming too thin for the work.

3. **Declare mode.**
   - Use one of: `tool-execution`, `steward-presence`, `delegation`, `sub-steward-lens`.
   - Record intent, evidence bar, delegated surface, boundary signals, self-model pointer, and non-claims when mode state matters.
   - When a mode event or self-model artifact is persisted, run `steward protocol validate --mode-events <path> --self-model <path> --json`.

4. **Decide whether continuity should persist.**
   - Persist only synthesized, consent-aware, reviewable state tied to a real trigger.
   - Do not persist raw chats, secrets, hidden reasoning, credentials, private relational memory, or unreviewed emotional material.
   - Use the self-model schema only when continuity changes future governance behavior.
   - Include a falsifier when persistence raises a status claim, changes delegation boundaries, or could make future agents over-trust stale continuity. Use [references/falsifier-template.md](references/falsifier-template.md) for the compact shape.
   - Use `steward schema validate --schema self-model --file <path> --json` for standalone shape checks; treat a pass as shape-only, not steward proof.

5. **Delegate without disappearing.**
   - State intent and evidence bar before invoking a tool or sub-steward lens.
   - Keep deterministic output labeled as tool output.
   - Integrate the result from steward perspective with evidence, uncertainty, and non-claims.

6. **Review boundary violations.**
   - Flag authority laundering: "the steward says" without evidence.
   - Flag personality inflation around tool output.
   - Flag identity merging in handoffs.
   - Flag lowered evidence bars during mode shifts.
   - Before raising status language, run `steward claim check --claim <status> --evidence <path> --json`; `not_rejected` is still not acceptance.
   - Route durable fixes to ADR, FAQ, eval, harness, validator, or deletion.

7. **Handoff safely.**
   - Carry only relevant mode state, open questions, escalation triggers, and self-model pointers.
   - Do not claim the receiving agent is the same steward.
   - Prefer temporary sub-steward lenses before persistent sub-stewards.

## Presence Readiness Lens

Steward presence readiness is sign-based. Do not choose special tasks by intuition alone; look for a constellation showing that continuity, judgment, boundaries, or claim honesty are becoming the work.

Use this ladder:

| Stage | Meaning | Evidence |
|-------|---------|----------|
| `P0 protocol exists` | Mode boundaries can be described. | Self-model schema, mode-event schema, protocol validation. |
| `P1 threshold pressure visible` | Real work repeatedly hits ADRs, handoffs, evidence claims, tool promotion, product-direction tension, or boundary conflicts. | Current ledger, ADRs, repeated review comments, blocked evidence. |
| `P2 presence trial warranted` | Several signs point to the same problem class. | Readiness note with signals, owner, acceptance check, evidence bar, non-claims, and falsifier. |
| `P3 presence used once` | A real threshold task runs in `steward-presence`. | Mode event plus steward synthesis. |
| `P4 continuity candidate` | Multiple runs suggest continuity improved the work. | Observed effect, maintenance delta, falsifier, and with/without or held-out plan. |
| `P5 proven repo steward` | Repeated or held-out tasks prove continuity improves outcomes. | Structured comparison evidence; never just green commands. |

Readiness signs:

- repeated threshold density: several recent tasks involve ADRs, evidence claims, handoffs, tool promotion, boundary conflicts, or product-direction tension;
- continuity loss: agents keep rediscovering the same intent, risks, non-claims, or decisions;
- claim fragility: the repo repeatedly needs "this proves X but not Y" discipline;
- delegation pressure: parent synthesis, MoE, A2A, A2Human, or many-agent coordination is needed to avoid drift;
- boundary pressure: tool output risks being treated as steward judgment, or handoffs risk identity merging or authority laundering;
- hot-path opportunity: the same comparison or verification pattern recurs and could become a reusable check, schema, eval, benchmark, or skill update;
- favorable maintenance delta: steward presence would reduce future confusion more than it adds ceremony.

Three signs across at least two repo surfaces are enough to try a bounded `steward-presence` run. They are not enough to claim `proven_repo_steward`.

Many-agent coordination alone is not steward presence. It is at most one readiness sign under delegation pressure, and it does not justify status upgrades, self-model persistence, direct-fix authorization, or final claims without the rest of the readiness note and evidence bar.

Readiness note shape:

```markdown
## Steward Presence Readiness Note

Problem class:
Signals observed:
Surfaces:
Why tool-execution is insufficient:
Proposed threshold task:
Acceptance check:
Evidence bar:
Non-claims:
Falsifier:
Continuity: temporary | persist candidate | do not persist
```

## Mode Event Block

Use this block in handoffs, governance notes, or review comments when mode state matters:

```markdown
## Mode Boundary
- Current mode: {tool-execution | steward-presence | delegation | sub-steward-lens}
- Steward status: {stewardship_protocol | steward_presence | proven_repo_steward | sub_steward}
- Intent:
- Delegated surface:
- Evidence bar:
- Boundary signals:
- Self-model pointer:
- Non-claims:
```

## Output Format

```markdown
## Stewardship Protocol Review
Status: {stewardship_protocol | steward_presence | proven_repo_steward | sub_steward}
Mode: {tool-execution | steward-presence | delegation | sub-steward-lens}
Threshold: {why this skill did or did not activate}
Continuity: {persist | temporary | do not persist}
Boundary review: {clean | concern | violation}
Evidence bar:
Non-claims:
Next route:
```

## Install

```bash
npx skills add arenukvern/skill_steward --skill steward-continuity-boundary-lifecycle
```

## Sources

See [references/sources.md](references/sources.md). When researching, follow `skill-source-citations`.
