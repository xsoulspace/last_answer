# Last Answer — History (landed work)

> Landed record only. Forward frontier: [PLAN.md](PLAN.md). Decisions:
> [decisions/](decisions/). Engine-side landed record: agentic_harness
> `docs/agent/history.md` + `benchmark/runs/delegation_m1_evidence.md`
> (TASK B sections carry the full rows).

## 2026-09-05 — R9.a: the missing verbs (headless doc lifecycle + escalation)

- **Three new MCP/intent entries** (`lib/coding_agent/agent_mcp_tools.dart`,
  mcp_toolkit + intentcall `AgentCallEntry`, same `debugSurface` pattern):
  `agent_doc_create` (create + open through the app's own
  `OpenedProjectNotifier.createAgentProject` path via a debug-only app hook
  on the home shell; returns docId), `agent_doc_bind` (workspace + check
  override DIRECTLY onto the doc payload via `onDocChanged` — never a form
  fill, per the Phase-1.5 measurement), `agent_task_guide` (escalation
  guidance as a host-injected decision: recorded on the turn it responds
  to as a first-class GUIDE grid row + composer pre-fill "continue with
  guidance…", continuation delegated immediately; monotonic — one guidance
  per ended turn).
- **The agent projection grew the fields the driver needs**:
  `checkCommand` (the doc's `--check`) and `lastGuidance` join
  `agent_doc_state`'s JSON.
- **Headless gate GREEN** (`tool/r9a_gate.sh`, zero GUI clicks, zero field
  fills): create → bind (this repo + `dart tool/agent_fixture/main.dart`)
  → delegate → permission round-trips through the intent → verdict read
  back. Final run **PASS** (backend `apple_foundation_afm`, 1 decision,
  3 rounds, 1,552 tokens, wall 43.6 s; fixture oracle exit 0, fixture
  restored). Run 1 was an honest FAIL turn whose wandering model attempted
  TEN off-task `lib/main.dart` writes — every one REJECTED through
  `agent_permission_answer` (deny-by-default held on the intent path too).
  Rows + findings: harness `benchmark/runs/delegation_r9.md`.
- **Widget gates** (`test/coding_agent/agent_intents_test.dart`): create
  returns the created docId (+ honest refusal when the hook is unwired);
  bind persists the payload, refreshes the daemon config, refuses relative
  paths; guide FAIL → GUIDE row → continuation PASS, with no-session and
  mid-turn refusals. All driven through the REAL intent entries
  (`AgentCallEntry.invokeDirect`) on the real surface keys. 16/16 green.
- Findings (rows in `delegation_r9.md`): create→open lag (drivers poll
  `agent_doc_state` for the docId; create doubles as the app-readiness
  probe); the scripted seam's `handlerFactory` is per-turn (shared mover
  instance for per-turn state); the in-loop `run` tool cannot execute the
  fixture check from the jail while the outer oracle can (repair-hint
  candidate).

## 2026-09-05 — Phase 1.5: THE HUMAN GATE (AFM + harness usable in the GUI, no terminal)

- **Bridge dylib bundling** (Runner build phase):
  `macos/Runner/bundle_afm_bridge.sh` runs after the Flutter Assemble embed
  and copies `libxs_fm_bridge.dylib` (hook output, with a
  `tool/build_bridge.sh` fallback) into `last_answer.app/Contents/MacOS/`;
  the loader's executable-relative resolution makes it work with NO env
  vars. `XS_FM_BRIDGE_PATH` remains the override. Gates: clean-env
  `flutter build macos --debug` green; the real-app AFM e2e
  (`integration_test/coding_agent_afm_e2e_test.dart`) **PASS with a fully
  clean environment** (1 decision, 1,360 tokens, 28.8 s); the self-profile
  gate on this repo green with no bridge env var (1 decision, 1,591
  tokens, 43.3 s). Row: harness
  `benchmark/runs/delegation_phase1_5.md`.
- **Workspace picker** (product UI): the workspace field gained a folder
  button (`file_selector` `getDirectoryPath`) filling the SAME field —
  persistence unchanged (pinned on delegate); the text field stays for
  power users. Widget-gated (fake platform, cancel path included).
- **Honest empty state** (product UI): an agent doc with no bound
  workspace shows a four-step guide (bind a workspace; what a task
  sentence is; writes ask permission; where the verdict lands). Widget-
  gated (guide on unbound, hidden when the binding exists).
- **Check override field** (`coding_agent.check`): the doc payload's
  `checkCommand` is now editable in the UI (whitespace-split argv, no
  shell) — a repo whose convention oracle is `flutter test` needs the
  targeted override for a usable loop. Persisted via controller listener
  (semantic fill never fires `onChanged` — measured).
- **OpenRouter key UX verified from the GUI**: missing-key = honest
  pre-session config error surface (`coding_agent.error`), no session
  created, never a mid-turn crash (widget-gated, env-key-aware skip).
- **GUI human loop GREEN on this codebase** (driven through the
  established `flutter-mcp-toolkit` console + the app's own MCP/intent
  entries): doc create → bind → check override → delegate → permission
  round-trips (allow lands the write; reject never lands; deny-by-default
  held on every off-task write) → escalation round-trip (honest FAIL turn
  1 → guided round 2) → **verdict banner PASS** (1 decision, 17 rounds,
  2,360 tokens, 34.8 s) → fixture oracle exit 0 → fixture restored. Row
  + findings: harness `benchmark/runs/delegation_phase1_5.md`.
- Fixes found BY the loop (product-side, widget-gated):
  `cancelCurrent` rejects a pending permission (the human's stop breaks
  the round-trip); doc-payload config (backend + check) re-derived before
  every turn; doc payload persisted BEFORE backend switches (a stale-
  payload race had reverted a switch and launched a real AFM session);
  the runtime API key is carried through config re-derivation (device-
  local, never doc data).
- Filed (harness/bridge-side, evidence doc): unanswered-permission
  5-minute stall loop; cancel not turn-interrupting; intermittent
  first-write-without-permission (F3); bridge crash on cancel during a
  live tool call (`postToolCall` barrier-sync — stack captured);
  small-model off-task wandering on this repo (build-hook churn; the
  outer oracle held every time). Phase 2 (runtime seam + squad UX) is now
  unblocked.

- **Adapted to the harness refactor (ADR 0025/0026)** by the concurrent
  session: the daemon/ACP host policy moved to `xsoulspace_agentic_host`
  (`HarnessEmbed` + `HarnessBackendBinding`, provider-thin
  apple_foundation). Product-side policy (config, check override,
  consent) stayed here; all gates re-validated green against it: clean-env
  build + bundled dylib, AFM e2e PASS (1 decision, 1,323 tokens, 44.4 s),
  self-profile PASS (1 decision, 1,554 tokens, 41.5 s).
- **Gate hardening (found BY the loop):** the self-profile run's
  wandering model once overwrote the gate's own test file through the
  blanket auto-allow — the scripted user-actor now allows ONLY
  fixture-path writes (deny-by-default everywhere else); the fixture
  check switched to plain `dart <file>` (`dart run` hits the build-hook
  churn every grade — dogfood finding confirmed twice more). Runtime
  labels state the model policy: AFM = real work, OpenRouter (deepseek-
  v4-flash) = backup.
## 2026-09-04 — TASK B: the harness embedded (first domain host)

- `HarnessAcpBackend` re-exported from
  `xsoulspace_inference_apple_foundation`; `lib/coding_agent/harness_host.dart`
  owns the daemon lifecycle IN-PROCESS (AcpStdioServer over an in-memory
  duplex channel + AcpClient). Per-workspace worlds and snapshot stores
  stay backend-owned (R7c). User task input = host-injected decision
  (`session/prompt`); approvals ride the existing
  `session/request_permission` round-trip — no second protocol.
- Backend switch (AFM on-device ↔ OpenRouter): `HarnessHostConfig.copyWith`
  + `HarnessSessionController.switchBackend` (restarts the daemon; the
  per-workspace snapshot store restores the world — R7c `loadSession`,
  proven scripted). OpenRouter key: UI field or env; unresolvable key =
  honest pre-session config error.
- Gates green: 3 host e2e tests (allow → PASS + write lands; reject →
  FAIL + write never lands; lifecycle + per-workspace continuation) and
  the widget gate (delegate → permission prompt → allow → verdict
  surfaces). AFM e2e as the real macOS app: `verdict: PASS`
  (1 decision, ~1.4k tokens, ~29 s). Known constraint recorded: the app
  cannot resolve the bridge code asset yet — `XS_FM_BRIDGE_PATH` points
  at the hook-built dylib (Runner bundling is Phase 1.5).

## 2026-09-04 — ADR 0003 + Phase 1: agents live in docs

- ADR 0003 (`docs/decisions/0003-agents-live-in-docs.md`): runtime ⊃
  world(s) ⊃ actor(s) ontology; topology = task/CLI-dependent DATA (open
  problem, honest refusal); multi-workspace near-term (workspace set,
  sessions per workspace, cross-world tasks out of scope); composition
  law table (infrastructure never imports this product); experience packs
  recorded as a future direction (future ADR, zero code).
- Product model (`packages/core`): `DocFormatIds.agent` +
  `AgentDocModel` (workspace set, backend, check override — syncable doc
  data) as a nullable payload on `ProjectModel.doc`;
  `ProjectModel.emptyAgent()`; `OpenedProjectNotifier.createAgentProject`.
- Surface: `AgentDocSurface` (doc-bound; workspace prefill from payload;
  persistence via `onDocChanged`; `debugState`/`debugSurface` for the
  agent projection) replaces the standalone screen (ProjectView dispatch
  by `formatId`; home app-bar icon creates agent docs; standalone route +
  `ScreenPaths.codingAgent` removed).
- Agent/intent projection (`lib/coding_agent/agent_mcp_tools.dart`,
  registered debug/profile in `main.dart`): `agent_doc_state`,
  `agent_task_delegate`, `agent_permission_answer` — mcp_toolkit +
  intentcall `AgentCallEntry`, the `DocView.debugDocState` pattern.
- Harness support (product-agnostic): `HarnessAcpBackend(checkCommand:)`
  — the doc binding's declarative `--check` (empty = D8 workspace
  convention decides).
- Gates green: 5 unit/widget tests (incl. doc payload pins workspace +
  projection live); AFM e2e through the doc surface as the real macOS app
  (PASS, ~29 s); **self-profile gate** — an agent doc bound to THIS repo
  fixed a committed deliberately-failing fixture (`tool/agent_fixture/`,
  honest oracle that fails until the agent acts; fixture restored after
  each run) on-device, PASS.
- Dogfooding findings (rows + details in agentic_harness
  `benchmark/runs/delegation_m1_evidence.md`, Phase 1 section): stale-world
  leak (per-workspace store carried the previous goal → store wiped per
  gate run; goal isolation is an open problem); R5 triviality hit the
  first self-profile shape (fixed by the honest fixture oracle);
  small-model cwd confusion on the run tool (outer oracle held);
  `dart run` in-app triggers build-hook churn; `File.existsSync` returns
  false for directories.
