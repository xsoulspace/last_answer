# AGENTS.md — Last Answer

Guidance for AI agents working in this repository.

## Project intention

**Last Answer** (`lastanswer`) is a cross-platform Flutter app (mobile, desktop, web/PWA) for fast idea brainstorming and quick notes. Core concepts:

- **Ideas** — answer guided questions about a topic to flesh out an idea (Five Why's / PDSA style).
- **Notes** — messenger-style writing (bottom-up), with per-social-network character limits and sharing.
- Folders, backup & restore (files/clipboard), dark/light themes, EN/IT/RU localizations.
- Privacy-first: project data is local-first; there is no server-side project store. Future peer/VPS relay is an opt-in transport roadmap with separate privacy and encryption gates. Firebase is used only for analytics/crash reporting.

The product direction (see `docs/decisions/0012-writable-agent-doc-and-acp-client-first.md` and `docs/product/gdd-prd-editor-goal-and-pillars.md`) is a writable shared document/workspace: humans and agents edit the same evolving state; conversations and harness events are projections with durable diffs, threads, and provenance. First Last Answer acts as an ACP client and launches ACP agents such as Codex or Pi against that state. Remote mesh/VPS participation follows the local proof; an external ACP client operating Last Answer is a later, separate direction.

## North Star & design law

- **North Star**: [docs/NORTH_STAR.mdx](docs/NORTH_STAR.mdx) — any
  document is a writable shared workspace for humans and agents; ACP
  client-to-agent comes first, remote collaboration and external operator
  ingress are staged. Value paths + non-goals live there.
- **Design law**: [docs/DESIGN.md](docs/DESIGN.md) — document-first,
  text-native surfaces on one grid (Tufte × Müller-Brockmann), ink is
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

<!-- codemap-index:start -->
# Codemap — navigate this repo

Discover once per session: `resources/read` `codemap://surface/v1`, or `map_surface`.
Then call `map_index` with `operation=`. The transport refuses retired names
(`map_index_search`, `map_index_query`, `map_index_build`, and the other `map_index_*` tools).

Pass `"root": "/Users/antonio/xs/storage_problem/last_answer"` when the client cwd is not this repo.

1. **Start** — `map_doctor`, then `map_index` `{"operation":"build","root":"/Users/antonio/xs/storage_problem/last_answer","ignore_prefixes":["build/","dist/",".dart_tool/","target/"]}`, then `map_index` `{"operation":"context_map","root":"/Users/antonio/xs/storage_problem/last_answer","limit":24}`.
2. **Find** — `operation=search` and `query`. Concept-shaped queries add `"mode":"bm25"`.
3. **Before an edit** — `operation=query`, `kind=impact`, `symbol` = `rel/path.ext::unit.name` from search. `kind=context` returns the node and its edges. `kind=trace` also needs `target`.
4. **One evidence packet** — `operation=evidence` with `purpose` (`understand`, `impact`, or `trace`) and `budget_bytes`. Open the exact original with `operation=expand` and the handle in `meta.expansion`.
5. **Before commit** — `operation=changes`.
6. **On every answer** — read `freshness` and `meta.transport`. Ordinary reads refresh a stale index. `freshness_policy=refuse` starts no repair. Navigation facts are review leads; they do not authorize adoption.

CLI, from the codemap checkout:

`~/xs/codemap/.venv/bin/python ~/xs/codemap/engines/versions/py_engine/codemap_cli.py --json exec <index_command> --args '{"root":"/Users/antonio/xs/storage_problem/last_answer",...}'`

Parser edges only. Unresolved calls stay in the payload.
<!-- codemap-index:end -->
