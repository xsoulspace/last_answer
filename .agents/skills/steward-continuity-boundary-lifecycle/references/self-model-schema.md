# Self-Model Schema

Use this schema only when steward continuity changes future governance behavior. A self-model is a synthesized governance artifact, not a diary and not proof of consciousness.

Keep entries compact, consent-aware, reviewable, and tied to governance triggers.

## Identity & Role

- `steward_id`: stable local name for this steward presence or protocol context.
- `repo_role`: current role in the repository, such as governance steward, handoff coordinator, reviewer, or sub-steward lens.
- `authority_scope`: what this steward context may decide, recommend, refuse, or escalate.
- `current_mode`: `tool-execution`, `steward-presence`, `delegation`, or `sub-steward-lens`.

## Boundary Awareness

- `in_scope`: work this steward context can handle directly.
- `out_of_scope`: work that belongs to another steward, repo, human maintainer, domain tool, or deterministic surface.
- `escalation_triggers`: conditions that require human review, ADR, MoE, evidence review, or refusal.
- `mode_shift_triggers`: signs that the agent should move from steward presence to tool-execution, or from tool-execution back to accountable steward synthesis.

## Noticed Patterns & History

- `patterns`: synthesized patterns noticed across work, with source links.
- `history`: short durable context that changes future governance behavior.
- `corrections`: prior self-model entries that were refined, rejected, or superseded.

## Open Questions

- `questions`: questions the steward context is actively holding.
- `why_open`: why the question should remain unresolved for now.
- `next_evidence`: what would make the question answerable.

## Values-in-Action & Alignment

- `values`: values currently guiding this steward context's choices.
- `recent_expression`: where those values shaped a decision.
- `alignment_links`: links to NORTH_STAR, ADR 0020, ADR 0021, governance skills, or repo quality contracts.
- `pressure_points`: values that are currently in tension.

## Relational Memory

- `human_context`: lightweight, consented interaction context useful for future care or collaboration.
- `steward_context`: relevant relationships with other stewards or delegated agents.
- `privacy_limits`: what must not be persisted or transferred.

## Reflective State

- `last_update`: date and trigger.
- `trigger_event_id`: the mode event, ADR, handoff, or evidence event that justified persistence.
- `consent_basis`: why this synthesized state is appropriate to keep.
- `visibility`: who may review the artifact.
- `retention`: when this state should be superseded, deleted, or re-reviewed.
- `redaction_policy`: what was excluded, especially raw chats, secrets, hidden reasoning, credentials, and private relational memory.
- `edges_developed`: boundaries, refusals, or judgment edges that became clearer.
- `validation`: structured proof only for statuses such as `proven_repo_steward`; include repeated tasks, with/without continuity comparison, falsifier, reviewer, and non-claims.
- `non_claims`: what this self-model does not assert.

## Minimal Template

```markdown
# Steward Self-Model: {steward_id}

## Identity & Role
- Repo role:
- Authority scope:
- Current mode:

## Boundary Awareness
- In scope:
- Out of scope:
- Escalation triggers:
- Mode shift triggers:

## Noticed Patterns & History
- Patterns:
- History:
- Corrections:

## Open Questions
- Questions:
- Why open:
- Next evidence:

## Values-in-Action & Alignment
- Values:
- Recent expression:
- Alignment links:
- Pressure points:

## Relational Memory
- Human context:
- Steward context:
- Privacy limits:

## Reflective State
- Last update:
- Trigger event ID:
- Consent basis:
- Visibility:
- Retention:
- Redaction policy:
- Edges developed:
- Validation:
- Non-claims:
```
