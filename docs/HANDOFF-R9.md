# R9 Prompt — the console migration (hand to an AI agent as-is)

You are an autonomous coding agent completing R9: last_answer replaces pi
as the operator console. Work through R9.a → R9.b → R9.c → R9.d in order;
do not skip. macOS-first. Product repo: `~/xs/storage_problem/last_answer`.

## Read first (non-negotiable)

1. `docs/NORTH_STAR.mdx` — the star; R9 is a value path.
2. `docs/decisions/0003-agents-live-in-docs.md` — the law (composition
   law, no second protocol, state split).
3. `docs/DESIGN.md` — UI law (text-first grid, ink is data, human
   sovereignty; widget keys = the agent's UI contract).
4. `docs/PLAN.md` — § R9 (this work) + production path; `docs/history.md`
   — landed, do not redo.
5. `pkgs/xsoulspace_agentic_harness/benchmark/runs/delegation_phase1_5.md`
   — measured findings; do not re-derive them.

## Invariants (breaking one = revert)

- Composition law: infrastructure never imports last_answer; integration
  ONLY over ACP, IntentCall, AE wire types, the host package's public
  surface (`xsoulspace_agentic_host` post ADR 0025/0026).
- State split: transcripts/board/roster/permission log = doc data
  (synced); world snapshots + meaning tree = device-local.
- Deny-by-default permissions; monotonic budgets; failures are data;
  every published number states backend, decision path, tokens source, n.
- Honest oracles only; widget tests drive REAL surface keys
  (`coding_agent.*`); integration gates are env-gated and skip honestly.
- AFM (`apple_foundation_afm`) is the brain for real work; OpenRouter
  (`deepseek/deepseek-v4-flash-0731`) is the labeled backup.
- The monorepo has CONCURRENT sessions: before building, wait for
  `flutter analyze` to settle; never absorb another session's fixes.

## Current state (do not redo)

Phase 1 + 1.5 LANDED: embedded daemon via `HarnessEmbed`, agent-doc
surface (conversation grid, PROFILE/SETUP panes, composer ⏎), intents
`agent_doc_state` / `agent_task_delegate` / `agent_permission_answer`,
dylib bundled in the Runner build phase (no env vars), GUI human loop
PASS, self-profile gate PASS (scoped auto-allow: only fixture-path
writes; check = plain `dart tool/agent_fixture/main.dart`).

## R9.a — intents for the missing verbs (FIRST)

Add three MCP/intent entries next to the existing ones in
`lib/coding_agent/agent_mcp_tools.dart` (mcp_toolkit + intentcall
`AgentCallEntry`, same `debugSurface` pattern):

- `agent_doc_create` — create + open an agent doc (route through
  `OpenedProjectNotifier.createAgentProject`-equivalent), returns docId.
- `agent_doc_bind` — bind workspace (absolute path) + optional check
  override onto the open doc's payload (`AgentDocModel`); persists via
  `onDocChanged`; NEVER via form fills (measured: semantic fill does not
  fire controller listeners).
- `agent_task_guide` — send escalation guidance for the open doc's last
  turn (host-injected decision, monotonic allowance); surfaces as a
  first-class grid state (composer pre-filled "continue with
  guidance…"), not a transcript-only line.

Gate (script, zero GUI clicks, zero field fills): create → bind (this
repo + a fixture check) → delegate → answer permission → read verdict —
all via `flutter-mcp-toolkit exec --name fmt_client_tool --toolName
agent_*` against the running debug app. Widget-test each entry on REAL
keys. Record: one evidence row (backend, decisions, tokens source,
verdict, wall, n).

## R9.b — the dogfood switch

Fix the NEXT last_answer issue exclusively through last_answer: you are
the operator; intents only; AFM on-device; NO terminal for the work
itself (terminal only to launch the app and run the gates). Gate: one
PASS row + one classified FAIL row in
`delegation_phase1_5.md` (or `delegation_r9.md`), each stating backend,
decision path, tokens source, verdict, wall, n. From the first PASS row,
pi is demoted to squad member for this repo — route friction twice into
named failure classes, not new buttons.

## R9.c — board + squad (Phase 2)

- `TaskRowWire` in `~/xs/agentic_executables/…/agentic_executables_wire`
  (NEVER in this product); board in the agent doc reads it.
- `AgentRuntimeHandle` union: embedded harness | spawned ACP CLI
  (`AcpAgentCatalog`), per-binding settings on the doc roster.
- Squad view: single-writer file locks, per-actor verdicts, batched
  transcript segments as doc blocks (never chunk-per-block).
Gate: scripted e2e — embedded + one spawned CLI agent, one doc, one
workspace, disjoint tasks, board drains, idle; human gate re-run with a
CLI binding.

## R9.d — escalation UX completes R9

Guidance answered in-app as the primary path (R9.a's `agent_task_guide`
promoted to the default continuation state). Gate: one full issue cycle
including a FAIL → in-app guidance → PASS, recorded as a row. This is
the R9 completion criterion: pi retired for last_answer work.

## Validation discipline (every task)

- `flutter analyze` clean on touched files; `flutter test` green (the 2
  pre-existing storage failures stay classified — do not absorb).
- AFM gates, clean env (no `XS_FM_BRIDGE_PATH`): `flutter test
  integration_test/coding_agent_afm_e2e_test.dart -d macos`; self-profile:
  `LASTANSWER_REPO=$PWD LASTANSWER_SELF_PROFILE=1` (fixture auto-restores;
  the scripted user-actor allows only fixture-path writes).
- After EVERY landed task: update `docs/history.md`, `docs/PLAN.md`
  ledger, `docs/evidence/current-status.mdx`, and the harness evidence
  ledger. North-Star rule: name the claim, check the weakest proof.
- House rule: the coding agent fixes its own issues through the surface;
  you orchestrate and escalate — do not absorb fixes the harness can do.
  Drive the app via `flutter-mcp-toolkit exec` (re-snapshot before EVERY
  interaction — semantic refs shift after re-renders).
