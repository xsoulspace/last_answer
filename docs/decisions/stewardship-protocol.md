# Stewardship Protocol — Last Answer

Operational protocol for AI agents and human collaborators adopting the
[`steward-continuity-boundary-lifecycle`](../../.agents/skills/steward-continuity-boundary-lifecycle/SKILL.md)
skill in this repository. This doc is the repo-local instantiation; the skill is
the general protocol.

Status: `stewardship_protocol` · Mode: `tool-execution` (default)

## 1. Modes

| Mode | When | Evidence bar |
|------|------|--------------|
| `tool-execution` | Deterministic work: codegen, formatting, tests, mechanical refactors, docs edits. | Tool output, labeled as tool output. |
| `steward-presence` | Threshold moments only (see §2). | Synthesis + evidence + non-claims. |
| `delegation` | Invoking sub-agents or tools with stated intent. | Intent + evidence bar declared before delegation; results integrated from steward perspective. |
| `sub-steward-lens` | Temporary bounded perspective for review. | Temporary by default; never persistent identity. |

## 2. Threshold moments (enter `steward-presence`)

- ADRs and architecture decisions (`docs/decisions/`)
- Handoffs between agents or sessions
- Evidence claims (anything written to `docs/evidence/`)
- Boundary conflicts (persona vs tool output, authority laundering)
- Tool promotion (promoting a script/check into a harness action)
- Product-direction tension (reconcile `docs/NORTH_STAR.mdx`, accepted
  product ADRs such as ADR 0012, `docs/PLAN.md`, and the product pillars)
- Privacy-sensitive memory updates

## 3. Repo surfaces

| Surface | Path | Role |
|---------|------|------|
| Charter / agent map | `AGENTS.md` | Entry point for all agents. |
| Skill | `.agents/skills/steward-continuity-boundary-lifecycle/` | Protocol definition, schemas, evals. |
| Steward config | `steward.yaml`, `skills.json` | CLI adoption state (`steward doctor`). |
| Evidence ledger | `docs/evidence/current-status.mdx` | Weakest true current claims + rerun route. |
| Decisions | `docs/decisions/` | Accepted and proposed ADRs; check status and superseding clarifications. |
| Product direction | `docs/NORTH_STAR.mdx`, `docs/PLAN.md`, `docs/decisions/0012-writable-agent-doc-and-acp-client-first.md`, `docs/product/gdd-prd-editor-goal-and-pillars.md` | North Star, active sequence, product decision and pillars; reconcile them together. |

## 4. Native quality gates

Configured in `steward.yaml` under `quality.validate`.

```bash
fvm flutter analyze --no-pub   # gate: 0 errors
fvm flutter test               # gate: all pass
just fix                       # apply after edits
```

Historical baseline (2026-08-24): 0 analyzer errors, 154 info/warnings
(mostly generated `*.freezed.dart`), all tests passed at that time. See
the evidence ledger for the current measured baseline; historical passes do
not establish current runtime or release readiness.

## 5. Persistence rules

Persist continuity state (self-models, mode events) only when:

1. **Synthesized** — not raw chat or hidden reasoning.
2. **Consent-aware** — nothing private or unreviewable.
3. **Reviewable** — a human can read and contest it.
4. **Triggered** — tied to a real mode event, ADR, handoff, or claim.
5. **Falsified** — includes a falsifier if it raises any status claim
   (use [`references/falsifier-template.md`](../../.agents/skills/steward-continuity-boundary-lifecycle/references/falsifier-template.md)).

Validate artifacts:

```bash
steward protocol validate --mode-events <path.jsonl> --self-model <path.json> --json
steward schema validate --schema self-model --file <path> --json
```

A validation pass proves shape only — never steward status.

## 6. Status ladder (readiness)

Follow the skill's P0–P5 ladder. Current level: **P0** — protocol exists,
schemas and validators available, no threshold pressure recorded yet.
Do not advance without readiness signs across at least two repo surfaces
(see skill's *Presence Readiness Lens*).

## Falsifier

- Claim constrained: "This repo runs the stewardship protocol at P0."
- Failure mode: protocol docs drift from actual behavior (skill removed,
  steward.yaml stale, evidence ledger abandoned).
- Check: `steward doctor` reports valid config; evidence ledger updated
  within the last meaningful task.
- Evidence that would reject: missing skill directory, invalid config,
  or ledger untouched across multiple governance-relevant tasks.
- Rerun or review trigger: any ADR, handoff, or evidence claim.
- Non-claims: does not assert presence readiness (P1+), maturity, or
  proven steward status.

## Non-claims

- Installing the skill or CLI does **not** prove steward capability.
- Green gates do **not** prove product correctness or release readiness.
- This document does **not** claim any agent (including its author) is
  "the steward" — it defines a protocol any competent agent can run.
