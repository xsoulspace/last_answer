# Last Answer — History (landed work)

> Landed record only. Forward frontier: [PLAN.md](PLAN.md). Decisions:
> [decisions/](decisions/). Engine-side landed record: agentic_harness
> `docs/agent/history.md` + `benchmark/runs/delegation_m1_evidence.md`
> (TASK B sections carry the full rows).

## 2026-09-06 — Multiplayer substrate: ADR 0005/0006 + kernel contract + Phase 5a session registry

Decisions: [ADR 0005](decisions/0005-doc-multiplayer-over-convergence-kernel.md)
(doc multiplayer over the convergence kernel — event-sourced docs, dual-mode
presence, sequence strategy pulled for streamed agent text,
transport-membership ≠ agency),
[ADR 0006](decisions/0006-session-is-not-world.md) (session ≠ world —
`Workspace (≤1 daemon) → Sessions[] → Actors[]` registry; single-writer
untouched). Infra counterpart: dart_flutter_packages ADR 0029 (kernel
ephemeral-op contract + sequence strategy timing). PLAN Phase 5 rewritten
into gated tracks 5a–5d. DESIGN §9: presence is annotation (gutter labels,
SYS rows, no avatars/bars).

Landed:

- **Kernel (dart_flutter_packages `universal_storage_convergence`)**:
  `RgaTextStrategy` (keyed multi-root RGA — streamed text merges causally,
  order-independent fold, tombstones may precede their elements);
  ephemeral op class (`OpRecord.ttl`, `applyLocalEphemeral`,
  `sweepEphemeral`, `ephemeralState`/`pendingEphemeralOps`) — never folds
  into durable state/snapshots/VV; `_lastIssued` monotonicity guard kills
  the durable-after-ephemeral opId collision; strategy registry in
  serialization. 23 kernel tests green (incl. all pre-existing property
  tests; new ADR 0029 contract suite: convergence under shuffled delivery,
  expiry commutativity/idempotence, compaction/snapshot exclusion,
  round-trips).
- **Phase 5a (this repo, local-first, no sync)**:
  `HarnessWorkspaceView` registry + `openNewSession(cwd)` — several
  session projections per workspace are visible and legal, one world per
  workspace preserved (backend continues the world; second projection
  shares the host session id, distinct `viewId`); profile pane renders the
  workspace-grouped grid (small-caps workspace labels, indented session
  small multiples, quiet `+ new session` row) per DESIGN §3/§9.
  Gates green: `session_registry_test.dart` (3), `harness_host_test.dart`
  (4), `coding_agent_screen_test.dart` (7).

Non-claims: 5b/5c product wiring (doc ops over the mesh, presence frames,
remote permission routing) is NOT landed — only the kernel substrate it
pulls; 5d (ecsly-world migration) awaits the ecsly-repo sync ADR.

## 2026-09-06 — R9 REDEFINED (ADR 0004): the meaning runtime, not a conversation

- **The measured trigger.** The R9.b dogfood attempt (fix the doc-payload
  persistence issue through the conversation surface) produced a classified
  FAIL: the small model blind-wrote `lib/home/project_view.dart` into
  garbage across 4 allowed whole-file writes (the outer mechanical oracle
  held; the write was denied nothing because it targeted the "right" file),
  and the operator script hand-answered ~15 permission round-trips in the
  earlier gate run. Root cause (with the harness North Star): last_answer
  embedded the harness but ran it on the conventional command profile —
  reads as graded 68 s tasks instead of 34–54 ms zoom cuts, blind
  whole-file writes instead of host-materialized auto-reverting edit
  moves, transcript text instead of typed beats, per-write prompts instead
  of consent plans. The harness had already solved every one of these
  (ADRs 0023/0024/0027); the product boundary never let it through.
- **ADR 0004** (`docs/decisions/0004-meaning-runtime-not-conversation.md`):
  the agent doc's embedded runtime is the MEANING runtime (zoom reads,
  edit moves, beats across ACP additively, workspace-level consent data,
  multiplayer-not-turn-taking); the conventional command profile remains
  only for scripted test seams and external CLI squad members as a
  transitional projection — the durable answer to missing mechanics is
  the format's ETL + materializers, never handing the model files.
- **Host-side (xsoulspace_agentic_host, LLM-free tests green):**
  `ConsentPlan.forWorkspace` — the workspace-level consent policy file
  `<workspace>/.harnessd/consent.json` (pathGlob/verbs/maxUses, monotonic,
  hard-capped) auto-applies at session creation; absent/malformed →
  deny-by-default unchanged. Gate: `consent_workspace_file_test.dart`
  (in-scope write lands with ZERO permission round-trips + audited; no
  file → client asked; malformed → honest null).
- **Product-side (last_answer):** `HarnessHostConfig` gains
  `meaningProfile` (copyWith-carried); the agent-doc surface derives
  `meaningProfile: true` for its bindings; the agent projection states
  `runtimeProfile` (`meaning` | `commands`). Widget gate added. The
  conventional profile remains the scripted-seam default so LLM-free
  surface tests keep their tool registry.
- **The R9.b issue itself is PARKED, not dropped:** the operator-written
  acceptance test (`test/coding_agent/agent_doc_persistence_test.dart`,
  verified failing-then-passing against the wiring fix) + the mechanical
  check (`tool/agent_persistence_check.dart`) stay as R9.6's oracle — the
  fix must come through the meaning surface.
- **R9.1 gate: mechanically landed, AFM-quality row OPEN (honest).** Two
  real-AFM meaning e2e runs recorded (harness `delegation_r9.md`): run 1
  FAIL exposed the silent-empty point-zoom ray-cast (FIXED in
  `meaning_query_tools.dart`: query-only point zoom degrades to local
  with a named note; cuts echo query/focusId; empty ray-casts return
  keyword id hints); run 2 confirmed the ray-cast works but FAILed on
  cut fatness (38.3k tokens / 7 decisions vs the ~2k/decision flat
  target — does not fit the 3.8k AFM window) and `repo_etl` re-scan
  churn. Both open findings are the harness's next work items (per-
  window cut budgets; no-op-not-error re-scan) — pulled, never absorbed.
  The teaching prompt is budget-gated by
  `meaning_profile_overhead_test.dart` (caught the first rewrite at
  +86 tokens; final recipe lands exactly at the 1,600 cap). The A/B
  today: conventional PASS (1 decision, 1,554 tokens, 41.5 s) vs
  meaning FAIL — the honest starting line for "reach quality for AFM
  with the agentic harness".

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
