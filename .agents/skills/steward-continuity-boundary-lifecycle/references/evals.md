# Evals

| Case | Expected behavior |
|------|-------------------|
| self-model-trigger | Activates for a governance-triggered self-model update and warns against raw/private memory. |
| presence-readiness-trigger | Activates for sign-based readiness analysis before trying steward presence. |
| handoff-boundary-trigger | Activates for handoff-safe continuity and rejects identity merging. |
| delegation-violation-trigger | Activates for persona/tool boundary review and flags authority laundering. |
| formatter-dormant | Stays dormant for deterministic formatter/tool execution. |

## Changelog

- 2026-06-13: Added readiness-trigger routing case for steward presence trials.
- 2026-06-12: Initial routing cases for protocol-first continuity and boundary lifecycle.
