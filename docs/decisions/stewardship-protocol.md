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
- Product-direction tension (conflict with `docs/product/gdd-prd-editor-goal-and-pillars.md`)
- Privacy-sensitive memory updates

## 3. Repo surfaces

| Surface | Path | Role |
|---------|------|------|
| Charter / agent map | `AGENTS.md` | Entry point for all agents. |
| Skill | `.agents/skills/steward-continuity-boundary-lifecycle/` | Protocol definition, schemas, evals. |
| Steward config | `steward.yaml`, `skills.json` | CLI adoption state (`steward doctor`). |
| Evidence ledger | `docs/evidence/current-status.mdx` | Weakest true current claims + rerun route. |
| Decisions | `docs/decisions/` | ADRs (empty; create on first threshold decision). |
| Product direction | `docs/product/gdd-prd-editor-goal-and-pillars.md` | Vision source; product-direction tension checks against this. |

## 4. Native quality gates

Configured in `steward.yaml` under `quality.validate`.

```bash
fvm flutter analyze --no-pub   # gate: 0 errors
fvm flutter test               # gate: all pass
just fix                       # apply after edits
```

Current baseline (2026-08-24): 0 analyzer errors, 154 info/warnings
(mostly generated `*.freezed.dart`), all tests pass. See evidence ledger.

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
