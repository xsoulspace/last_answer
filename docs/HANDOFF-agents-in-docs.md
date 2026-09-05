# Hand-off — Agents in Docs, Phases 1.5–5 (ADR 0003)

You are an autonomous coding agent continuing a multi-agent product
build. Work through this brief top to bottom. Read the listed docs BEFORE
changing anything — the architecture is deliberate; most apparent
shortcuts are forbidden for reasons recorded in ADRs.

## Repos & surfaces

- **Product (you work here):** `~/xs/storage_problem/last_answer` — docs,
  UI, hosts. Flutter app (macOS-first for this work).
- **Infrastructure (you only compose, never modify product-wards):**
  - `~/xs/storage_problem/dart_flutter_packages` — post ADR 0025/0026:
    `pkgs/xsoulspace_agentic_host` (daemon + ACP host policy:
    `HarnessAcpBackend`, `HarnessEmbed`, `runCodingAgentOnce`),
    `pkgs/xsoulspace_agentic_harness` (loop/oracles engine),
    `pkgs/xsoulspace_inference_apple_foundation` (AFM FFI bridge +
    `appleFoundationBinding`), `pkgs/xsoulspace_inference_openrouter`
    (backup provider; model `deepseek/deepseek-v4-flash-0731`).
  - `~/xs/agentic_executables` — canonical rows / repair packs
    (`agentic_executables_wire`).
  - `~/mcp/cline/intentcall` — intent registry (`intentcall_core`) +
    `dart_acp_toolkit` (ACP v1 transport).
  - `~/mcp/cline/mcp_flutter/mcp_toolkit` — the app's MCP projection.

## Read order (non-negotiable)

1. `docs/decisions/0003-agents-live-in-docs.md` — the law for this work.
1b. `docs/NORTH_STAR.mdx` — the product North Star (R9 console migration
   is a value path).
1c. `docs/DESIGN.md` — the design law for product UI (text-first grid,
   ink is data, human sovereignty; widget keys are the agent's UI
   contract).
2. `docs/PLAN.md` (last_answer) — the production path; **Phase 1.5 is your
   first gate**; standing rules.
3. `docs/history.md` (last_answer) — what is landed; do not redo.
4. `docs/product/agents-in-docs.md` — phases, pillars, non-goals.
5. agentic_harness `docs/agent/PLAN.md` (R8) + `docs/agent/architecture.mdx`
   invariants + `pipeline_coding.md` (the law: Agent = G ∘ F).
6. Evidence: agentic_harness `benchmark/runs/delegation_m1_evidence.md`
   (TASK B + Phase 1 rows and dogfooding findings).

## Invariants you must not break

- **Composition law:** infrastructure never imports last_answer. AFM
  bridge/loader work → `xsoulspace_inference_apple_foundation`; loop/oracle
  work → `xsoulspace_agentic_harness`; canonical rows →
  `agentic_executables_wire`; intent projection → IntentCall. last_answer
  owns docs, UI, hosts.
- **No second protocol, ever.** ACP vocabulary (prompt, permission,
  propose_move) is the universe; worlds nest fractally (pi inside
  last_answer is a world inside a world) and compose because every level
  speaks the same primitives.
- **State split is law:** transcripts/board/roster/permission log = doc
  data (synced); world snapshots + meaning tree = device-local
  (`<workspace>/.dart_tool/harnessd_store`), re-derived never restored.
- Deny-by-default permissions; monotonic budgets (never reset); failures
  are data (classified, never dropped); every published number states
  backend, decision path, tokens source, and n.
- **Honest oracles only** (R5): a gate that passes without the agent
  acting is not a gate. The self-profile fixture
  (`tool/agent_fixture/main.dart`, committed failing, restored after each
  run) is the pattern.
- Single-instance-per-workspace is MANDATORY (two daemons = two worlds =
  broken single-writer). Cross-workspace tasks are out of scope.
- Widget tests drive the REAL surface keys
  (`coding_agent.*`); integration gates are env-gated and skip honestly
  when the engine is unavailable; the macOS app needs
  `XS_FM_BRIDGE_PATH` until Phase 1.5 bundles the dylib.
- The monorepo has CONCURRENT sessions (e.g. R7e edits
  `xsoulspace_agentic_dart_meaning` / the AFM package). Before building,
  wait for `flutter analyze` to settle; never absorb another session's
  fixes; escalate instead.

## CURRENT STATE (do not redo)

Landed and gated (details in `docs/history.md` + evidence): embedded
daemon in-process (HarnessHost over an in-memory ACP channel), backend
switch AFM↔OpenRouter with world continuation, agent-doc format +
payload + ProjectView dispatch + home creation, MCP intent entries
(`agent_doc_state`, `agent_task_delegate`, `agent_permission_answer`),
`HarnessAcpBackend(checkCommand:)`, AFM e2e as the real macOS app
(PASS ~29 s), self-profile gate on this repo (PASS, honest fixture
oracle), 5 unit/widget tests green, 40 pass / 2 pre-existing
storage-subsystem failures (classified, unrelated).

## TASK 0 (FIRST) — Phase 1.5: THE HUMAN GATE

Goal: a HUMAN can start working with AFM + the harness in last_answer —
no terminal, no env vars. The gates so far are test-driven; a human has
never used the agent doc. Everything below is ordered; harness-side
phases wait until this is green.

1. **Bundle the bridge dylib** (Runner build phase, last_answer): copy
   `libxs_fm_bridge.dylib` (hook output:
   `pkgs/xsoulspace_inference_apple_foundation/.dart_tool/lib/`) next to
   the executable; the loader already resolves executable-relative paths
   (`library_loader.dart`). Keep `XS_FM_BRIDGE_PATH` working as an
   override. If the hook output is not stable for bundling, extend the
   loader FIRST (in the inference package), never product-side hacks.
2. **Workspace picker** (product UI): replace/augment the raw text field
   with a directory picker (`file_selector` is already a dependency — see
   `lib/doc/chat_document_view.dart` usage); keep the text field for
   power users. Persist into the doc payload as today.
3. **Honest empty state** (product UI): an agent doc with no workspace
   must instruct the human (bind a workspace; what a task sentence is;
   that writes ask permission; where the verdict lands).
4. **Verify the OpenRouter path from the GUI** (key field + apply +
   error surface when the key is missing).
5. **Run the human loop on this codebase**: launch the built app
   (`flutter run -d macos --debug`), create an agent doc, bind
   `~/xs/storage_problem/last_answer`, delegate the
   `tool/agent_fixture/main.dart` task, watch progress, answer the
   permission, read the verdict, confirm the fixture change, restore the
   fixture.
   Gate: the full loop completes in the GUI; record an evidence row
   (backend, decisions, tokens source, verdict, wall, UX gaps found);
   fix or file every gap. Then update `docs/PLAN.md` (ledger) and
   `docs/history.md`.

## TASK 1 — Phase 2: runtime seam + squad UX (per docs/PLAN.md #2)

`AgentRuntimeHandle` union (embedded harness | spawned ACP CLI via
`AcpAgentCatalog`) with per-binding settings on the doc roster; task
board as canonical rows (extend `agentic_executables_wire` if a
`TaskRowWire` is needed — never in this product); batched transcript
segments as doc blocks; squad view (file locks, per-actor verdicts).
Gate: scripted e2e — embedded + spawned CLI agents, one doc, one
workspace, disjoint tasks, board drains, idle; re-run the human gate
with a CLI binding.

## TASK 2 — Phase 3: agent-friendly surface (per docs/PLAN.md #3)

Productionize the four intents through IntentCall (registry → MCP +
deep links); expose the remote mover so the daemon runs model-less with
pi's model (or AFM) as the brain while last_answer owns loop, budgets,
oracles; in-app escalation guidance UI. Gate: pi drives last_answer
headlessly through intents (one full loop, transcript recorded).

## TASK 3 — Phase 4: one general (non-code) domain (per docs/PLAN.md #4)

One prose domain on the evidence tier (never the code-law `pass` tier).
Gate: one delegated task graded honestly (evidence, not pass), failure
classified. No generic "agents everywhere" framework.

## TASK 4 — Phase 5: mesh multiplayer (per docs/PLAN.md #5)

Board + transcripts sync; permission answers from a second device ride
the existing round-trip; snapshots stay device-local. Gate: two devices,
one doc, one task, one cross-device permission answer.

## Validation discipline (every task)

- `flutter analyze` clean on touched files; `flutter test` green in
  last_answer (the 2 pre-existing storage failures stay classified and
  unrelated — do not absorb them).
- AFM gates: `XS_FM_BRIDGE_PATH=<dylib> flutter test
  integration_test/coding_agent_afm_e2e_test.dart -d macos`; self-profile:
  add `LASTANSWER_REPO=$PWD LASTANSWER_SELF_PROFILE=1`.
- Bridge suite (when touching the inference package):
  `sh tool/check_bridge_swift.sh` in that package — 26/26.
- Publish rows in agentic_harness `benchmark/runs/delegation_m1_evidence.md`
  (or a new `delegation_phase<N>.md`) and update last_answer
  `docs/PLAN.md` + `docs/history.md` + `docs/evidence/current-status.mdx`
  after EVERY landed task. North-Star rule: name the exact claim, check
  the weakest proof, route durable truth to ADR/FAQ/check/ledger.
- House rule: the coding agent fixes its own issues (delegated to its
  actors); you orchestrate and escalate — do not absorb fixes the
  harness can do. AFM is the local-first goal; OpenRouter and pi are
  transitional.

## Driving the app externally (the operator path)

The canonical external-driver path is the mcp_toolkit console over the
VM service: launch `flutter run -d macos --debug`; use
`flutter-mcp-toolkit exec --name semantic_snapshot / tap_widget /
enter_text` for the GUI and `exec --name fmt_client_tool --toolName
agent_doc_state | agent_task_delegate | agent_permission_answer` for the
typed intent surface. Semantic refs shift after every re-render —
re-snapshot before EVERY interaction, and never drive doc bindings
through form fills (controller listeners do not fire on semantic
injection — measured); use the intents and file missing intents as R9.a
work instead of hacking around them.
