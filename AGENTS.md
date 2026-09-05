# AGENTS.md — Last Answer

Guidance for AI agents working in this repository.

## Project intention

**Last Answer** (`lastanswer`) is a cross-platform Flutter app (mobile, desktop, web/PWA) for fast idea brainstorming and quick notes. Core concepts:

- **Ideas** — answer guided questions about a topic to flesh out an idea (Five Why's / PDSA style).
- **Notes** — messenger-style writing (bottom-up), with per-social-network character limits and sharing.
- Folders, backup & restore (files/clipboard), dark/light themes, EN/IT/RU localizations.
- Privacy-first: all user data stays on the device; no server-side storage of projects. Firebase is used only for analytics/crash reporting.

The long-term product direction (see `docs/product/gdd-prd-editor-goal-and-pillars.md`) is a document-centric editor: "the document is the product" — edit, discuss any span, and act with AI on the selection without leaving the doc, with pluggable inference backends (no vendor lock-in).

## North Star & design law

- **North Star**: [docs/NORTH_STAR.mdx](docs/NORTH_STAR.mdx) — any
  document is a place where a human and agents work together; last_answer
  becomes the operator console. Value paths + non-goals live there.
- **Design law**: [docs/DESIGN.md](docs/DESIGN.md) — text-first
  conversation surfaces on one grid (Tufte × Müller-Brockmann), ink is
  data, the human is sovereign, widget keys are the agent's UI contract.
  Binding for ALL product UI; the agent-doc surface
  (`lib/coding_agent/agent_doc_surface.dart`) is the reference
  implementation. Read it before building any new view.

## Tech stack

- Flutter / Dart (SDK `^3.12.0`), managed with **FVM** (`fvm flutter ...`, `fvm dart ...`).
- Dart workspace monorepo: packages live under `packages/*` (incl. `packages/core`).
- Code generation via `build_runner` + freezed/json_serializable.
- Routing: `go_router`. State: `provider` + hooks (`flutter_hooks`, `life_hooks`).

## Commands

```bash
just gen                  # build_runner codegen
just fix                  # fvm dart fix --apply
fvm flutter analyze       # static analysis
fvm flutter test          # tests
```

Prefer `just` recipes over raw commands where available.

## Conventions

- Follow `analysis_options.yaml`; run `just fix` after edits.
- Regenerate code with `just gen` after changing models; don't hand-edit `*.g.dart` / `*.freezed.dart`.
- Keep changes minimal and consistent with existing architecture in `lib/` and `packages/core`.
- Update translations when touching user-facing strings (EN/IT/RU).
- Respect the license: PolyForm Noncommercial 1.0.0 — don't add code incompatible with it.

## Stewardship protocol

This repo adopts the [`steward-continuity-boundary-lifecycle`](.agents/skills/steward-continuity-boundary-lifecycle/SKILL.md) skill, with repo-local operational detail in [`docs/decisions/stewardship-protocol.md`](docs/decisions/stewardship-protocol.md).

- Default mode is **tool-execution**; enter **steward-presence** only at threshold moments (ADRs, handoffs, evidence claims, boundary conflicts, tool promotion, product-direction tension, privacy-sensitive memory updates).
- Default status is `stewardship_protocol`. Never claim `proven_repo_steward` from installs, green builds, or a single task.
- Label deterministic tool output as tool output; integrate results from steward perspective with evidence and non-claims.
- Persist continuity state only when synthesized, consent-aware, reviewable, and tied to a real trigger. Include a falsifier when persistence raises a status claim.
- On handoff, carry only relevant mode state, open questions, escalation triggers, and self-model pointers; do not claim the receiving agent is the same steward.
- Tooling: `steward doctor` (adoption state), `steward map` (agent map), evidence ledger at `docs/evidence/current-status.mdx`.
