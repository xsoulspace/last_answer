# R9.1 handover — the meaning runtime (AFM quality frontier)

Repo: `~/xs/storage_problem/last_answer` (product) +
`~/xs/storage_problem/dart_flutter_packages` (harness monorepo).
macOS-first. CONCURRENT SESSIONS are active — wait for `flutter analyze`
to settle; never absorb another session's fixes.

## Read first

1. `docs/decisions/0004-meaning-runtime-not-conversation.md` — the law:
   the agent doc's embedded runtime is the MEANING runtime; the
   conversation is a projection, never the engine. Conventional command
   profile = scripted seams + CLI squad members only.
2. `docs/PLAN.md` §R9 (R9.1–R9.6, each names its gate).
3. `../dart_flutter_packages/pkgs/xsoulspace_agentic_harness/benchmark/runs/delegation_r9.md`
   — all rows + findings 6–12 (corruption trigger, A/B, open items).
4. `pkgs/xsoulspace_agentic_harness/docs/north_star_agentic_harness.mdx`
   — flat tokens/decision is THE claim; the harness is the amplifier.
5. Harness ADRs 0027 (reads are not builds; consent plans), 0018 (zoom
   vocabulary), 0023/0024 (fs as projection target).

## Landed (do not redo)

- **Workspace consent file** `<ws>/.harnessd/consent.json`
  (pathGlob/verbs/maxUses) auto-applies at session creation — host-side
  (`ConsentPlan.forWorkspace` + `createSession` wiring;
  `consent_workspace_file_test.dart`, 3 green). Deny-by-default outside.
- **`meaningProfile` on agent docs** — surface derives `true`; agent
  projection states `runtimeProfile`; widget gate in
  `test/coding_agent/agent_intents_test.dart`.
- **meaning_zoom tiny-model fixes** (`meaning_query_tools.dart`):
  query-only point zoom degrades to `local` with a named note; every cut
  echoes query/focusId; empty ray-cast returns keyword-matched id hints.
- **Teaching prompt** = concrete discovery recipe, budget-gated at
  exactly 1,600 tokens by `meaning_profile_overhead_test.dart` (it
  catches prompt bloat — respect it).
- **Parked for R9.6** (verified failing oracles, NOT debt):
  `test/coding_agent/agent_doc_persistence_test.dart` +
  `tool/agent_persistence_check.dart` — the persistence fix must come
  through the meaning surface.

## THE OPEN GATE (R9.1 closes when this row PASSes)

Real-AFM meaning e2e on the fixture:
`env -u XS_FM_BRIDGE_PATH LASTANSWER_REPO=$PWD LASTANSWER_AFM_MEANING=1 \
  flutter test integration_test/coding_agent_afm_meaning_e2e_test.dart -d macos`
Current A/B: conventional PASS (1 decision, 1,554 tok, 41.5 s) vs meaning
FAIL ×2 (rows in delegation_r9.md).

## Work items, in order

1. **INVESTIGATE A — native AFM session context accumulation
   (hypothesis, UNPROVED — prove or kill it first).** Suspicion: the
   Apple-side session (`xs_fm` native session via
   `xsoulspace_inference_apple_foundation` + bridge) ACCUMULATES context
   across decisions — schema + cut + streamed transcript appended every
   round — so tokens/decision GROW even though our projection is
   budgeted. Evidence that demands it: run 2 spent 38,299 tokens over 7
   decisions (~7.6k/decision) while the cut is capped at 2,048 and the
   fixed surface is 1,600 — ~4k/round is unaccounted for by our
   projection. Method: instrument the actual per-decision prompt size
   (log in the client, or read native context usage), scripted-vs-AFM
   comparison; the growth curve across rounds is the tell (ours is flat
   by construction; if the measured curve climbs, the accumulation is
   native). If real: the fix belongs in the client/session lifecycle
   (session reset per decision, or explicit context control) — NEVER by
   shrinking the cut to compensate.
2. **INVESTIGATE B — cut composition: wiring vs mechanics.** Verdict so
   far: the mechanics COMPOSE correctly (facet ray-cast hits, budget
   trim enforced, repair hints); the failures were (a) an interface trap
   (point+query silently empty — FIXED) and (b) parameterization —
   `maxNodes` 48 + verbose node props make fat cuts, and the budget is a
   constant instead of derived from the model window (P1
   maxContextTokens). Confirm with a scripted probe: query
   "agent_fixture" must yield `sym_tool_agent_fixture_*` within budget;
   then implement lean node JSON + per-window cut budget in
   `meaning_tree.dart` / `meaning_query_tools.dart` (harness-side,
   never product-side). If A proves accumulation, re-measure before
   tuning — the cut may already fit.
3. **`repo_etl` re-scan churn** (`agentic_workspace/repo_etl_tool.dart`
   — COORDINATE, the concurrent session owns it): a second scan returns
   `ok:false "tree already built"` → the model loops on refresh.
   Make a no-op honest (`ok:true` + `already_built` note) or a
   bounce-with-repair the model follows.
4. **Then the redefined R9 ladder** (PLAN.md §R9): R9.2 beats over ACP
   (typed additive `session/update` kinds; transcript becomes derived
   from beats) → R9.3 consent UI (PROFILE pane edits the workspace
   consent file, renders the audit log) → R9.4 beat grid + message
   queue → R9.5 board + squad (`TaskRowWire`, `AgentRuntimeHandle`)
   → R9.6 the dogfood row → pi demoted.

## Discipline

Honest oracles (the fixture fails until the agent acts); every number
states backend, decision path, tokens source, n; failures are named
data, never dropped; infrastructure never imports last_answer; drive the
app through intents (`flutter-mcp-toolkit exec --name fmt_client_tool
--toolName agent_*`) and re-snapshot before EVERY interaction; the
monorepo is shared — orchestrate and escalate, never absorb.
