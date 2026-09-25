# Hand-off — writable agent document and ACP-client first slice (C0–C6)

You are an autonomous coding agent continuing a multi-agent product
build. Work through this brief top to bottom. Read the listed docs BEFORE
changing anything — the architecture is deliberate; most apparent
shortcuts are forbidden for reasons recorded in ADRs.

## Repos & surfaces

- **Product (you work here):** `~/xs/storage_problem/last_answer` — docs,
  UI, hosts. Flutter app (macOS-first for this work).
- **Infrastructure (you only compose, never modify product-wards):**
  - `~/xs/ecsai_harness` — engine, host, and workspace:
    `pkgs/xsoulspace_agentic_harness` (loop/oracles engine),
    `pkgs/xsoulspace_agentic_host` (daemon + ACP host policy:
    `HarnessAcpBackend`, `HarnessEmbed`, `runCodingAgentOnce`),
    `pkgs/xsoulspace_agentic_workspace`; `appleFoundationBinding` is
    `pkgs/xsoulspace_agentic_afm`.
  - `~/xs/storage_problem/dart_flutter_packages` — the FFI client remains
    `pkgs/xsoulspace_inference_apple_foundation`; OpenRouter stays
    `pkgs/xsoulspace_inference_openrouter` (backup provider; model
    `deepseek/deepseek-v4-flash-0731`).
  - `~/xs/agentic_executables` — canonical rows / repair packs
    (`agentic_executables_wire`).
  - `~/mcp/cline/intentcall` — intent registry (`intentcall_core`) +
    `dart_acp_toolkit` (ACP v1 transport).
  - `~/mcp/cline/mcp_flutter/mcp_toolkit` — the app's MCP projection.

## Read order (non-negotiable)

1. `docs/decisions/0012-writable-agent-doc-and-acp-client-first.md` —
   first product outcome and ACP direction.
2. `docs/decisions/0003-agents-live-in-docs.md` and
   `docs/decisions/0008-local-first-model-federation.md` — runtime/world/
   actor composition and shared meaning graph/materializer law.
3. `docs/NORTH_STAR.mdx` and `docs/DESIGN.md` — document-first product
   direction and binding UI/state projection law.
4. `docs/PLAN.md` (last_answer) — C0–C6 is the local shared-document and
   outbound ACP-client acceptance path; select the first dependency-ready
   item. Historical passes are evidence for only their recorded scope.
5. `docs/history.md` (last_answer) — what is landed; do not redo.
6. `docs/product/agents-in-docs.md` — phases, pillars, non-goals.
7. `~/xs/ecsai_harness/pkgs/xsoulspace_agentic_harness/docs/agent/PLAN.md`
   (G0, F0–F7, H1, M0, R0/R1 and optional J0/J1) + `architecture.mdx`
   and `pipeline_coding.md` beside it
   (the law: Agent = G ∘ F).
8. Evidence: agentic_harness `benchmark/runs/delegation_m1_evidence.md`
   (TASK B + Phase 1 rows and dogfooding findings).

## Invariants you must not break

- **Composition law:** infrastructure never imports last_answer. Engine,
  host, and workspace are in `~/xs/ecsai_harness`; loop/oracle work →
  `xsoulspace_agentic_harness`. `appleFoundationBinding` is
  `xsoulspace_agentic_afm`. The FFI client remains
  `xsoulspace_inference_apple_foundation` in `dart_flutter_packages`;
  OpenRouter stays there too. Canonical rows →
  `agentic_executables_wire`; intent projection → IntentCall. last_answer
  owns docs, UI, hosts.
- **ACP direction is staged:** first Last Answer is the ACP client and
  launches ACP agents. Only after that shared-document path is proven may an
  external ACP client operate Last Answer through an ACP server, CLI, MCP or
  IntentCall surface. These are distinct directions, not competing runtime
  protocols.
- **State split is law:** the shared typed document/meaning graph and its
  attributed edits, threads, diffs and permissions are durable collaborative
  state. ACP conversations and harness activity are projections of that
  state. Host snapshots, derived meaning cuts and runtime state remain
  device-local (`<workspace>/.dart_tool/harnessd_store`); they are rebuilt,
  never restored from a transcript. The workspace owner is the single code
  materializer/oracle.
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
  when the engine is unavailable. C0 revalidates clean-environment launch
  and provisioning for included providers, including bridge bundling when
  AFM is included. A declared hosted-only preview explicitly selects hosted
  inference and disables unavailable AFM; no automatic fallback or local-first
  availability claim. Unrun AFM gates remain open.
- Concurrent work may affect all three repositories. Inspect current
  changes and package ownership before editing: engine/host/workspace/AFM
  composition belong to ecsai_harness; inference transports belong to
  dart_flutter_packages. Do not absorb unrelated work into this release.

## Current handoff

Use [PLAN.md](PLAN.md) as the sole forward task list and
[history.md](history.md) for completed evidence. The current plan is a
documentation rebaseline, not a claim that the release gates passed.

- C0 freezes the source/fixture baseline and reproduces setup after central
  G0/R0 prerequisites. The Xcode-licence blockage recorded earlier is
  RESOLVED (2026-09-23: `fvm flutter doctor` Xcode ✓; only the iOS 27
  simulator runtime is missing, which does not block macOS). Local gates ran:
  analyze 0 errors; root suite 128 passed / 1 failed (the `agent_task_guide`
  escalation round — the ecsai_harness resumed-world first decision omits
  `task.repairHint`, so the guidance never reaches the mover; owner:
  ecsai_harness `xsoulspace_agentic_host`); headless_core 59/59; macOS debug
  build + `xs_fm_bridge.framework` bundling + 12 s launch smoke green.
  See [evidence/current-status.mdx](evidence/current-status.mdx) for exact
  commands and non-claims. Unrun AFM provisioning/launch gates remain open.
- The first slice is local: one device/user/workspace, one writable agent
  document and one foreground task, with a real ACP agent launched by Last
  Answer. It limits the workload, not the actor model. M0 requires one shared
  world with human, mechanical and model-backed actors; distinct actors may
  reuse one model resource. Remote peers use the same world in later mesh
  gates; Internet/VPS relay is later still.
- C1 makes document operations and origin-identified typed outcomes from H1
  one state; C2 persists the living document, threads, diffs and linked
  activity history. Existing queue persistence, session registry, binding
  callbacks and meaning-runtime composition should be preserved, not rebuilt.
- C3 covers provider/model configuration, device-local credentials and cloud
  consent. Optional generic decision providers remain disabled by default;
  Jev is an example actor binding, able to reason/code through semantic
  operations. J1-T/R/C/M keep separate evidence/promotion; R/C experiments
  need generic safety gates, not completed consumer release.
- C4 covers reviewed mutation, policy, deny/cancel/error behavior; C5 covers
  restoration and distinct-task isolation; C6 closes the real macOS journey
  and feeds central R1. Its local M0 gate uses two projections and shared-model
  actors: focus must not redirect authority, approval, cancel or restoration;
  no duplicate daemon/materialization. Full F7 capability remains separate.
- Broader squads, remote mesh completion, Internet/VPS relay, mobile, prose
  adapters and external operator ingress are staged after the local
  shared-document/ACP-client proof with their existing acceptance criteria
  in PLAN.md. External ACP clients do not connect to Last Answer in this
  first direction.

Preserve unrelated edits in this checkout and the sibling repositories.
Engine/host contracts belong in ecsai_harness; inference transport contracts
belong in dart_flutter_packages. Use the current tool schema and repository
skill for external driving instead of copying old CLI syntax from a handoff.

Record each completed item with exact revisions, the command/artifact,
measured result and non-claims. Scripted tests, real-provider runs and a
reproducible packaged launch establish different facts. No current pass
counts or provider readiness are inherited from historical reports.
