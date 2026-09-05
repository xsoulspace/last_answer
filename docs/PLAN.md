# Last Answer — Plan (Agents in Docs: the race to the product console)

> Forward/frontier record only. All landed work lives in
> [history.md](history.md); durable decisions in
> [decisions/](decisions/) (ADR 0001 document model, ADR 0002 core
> extraction, **ADR 0003 agents live in docs**); evidence ledger in
> [evidence/current-status.mdx](evidence/current-status.mdx); agent
> handoffs in [HANDOFF.md](HANDOFF.md) (v1, ADR 0001) and
> [HANDOFF-agents-in-docs.md](HANDOFF-agents-in-docs.md) (current).
>
> Engine-side frontier (product-agnostic): agentic_harness
> `docs/agent/PLAN.md` (R8 track). The two plans reference each other but
> never import each other — the composition law (ADR 0003) forbids
> infrastructure from depending on this product.

## NOW — the production path (ordered; each item names its gate)

The R8 machinery is landed and gated (embedded daemon, doc surface, MCP
intents, self-profile gate — see history). What is NOT yet true: **a human
has never used the agent doc in the real app** (the gates so far are
test-driven), the runtime seam unifies only the harness, and the board is
not canonical data yet. Everything below is ordered; do not skip #1.

1. **Phase 1.5 — THE HUMAN GATE — GREEN (2026-09-05).** The AFM pipeline
   works from the HUMAN perspective in this app: launch last_answer (debug),
   create an agent doc, bind a real workspace, delegate a real task, watch
   progress stream, answer a permission round-trip, read the verdict — with
   NO terminal and NO env vars. All three known blockers cleared and gated:
   - **Bridge dylib bundling — DONE.** Runner build phase
     (`macos/Runner/bundle_afm_bridge.sh`) copies the hook-built dylib into
     the `.app`; the loader resolves executable-relative. `XS_FM_BRIDGE_PATH`
     stays as an override. Clean-env real-app AFM e2e: PASS.
   - **Workspace picker — DONE.** Folder button fills the same field;
     text field kept for power users. Widget-gated.
   - **Honest empty state — DONE.** Four-step guide on unbound docs.
     Widget-gated.
   - **OpenRouter key UX — VERIFIED from the GUI** (missing-key = honest
     pre-session config error, widget-gated).
   - **Check override field — DONE (found by the loop).** The doc's
     `checkCommand` is UI-editable; a repo whose convention oracle is
     `flutter test` needs the targeted override for a usable loop.
   Gate evidence: harness `benchmark/runs/delegation_phase1_5.md` — the
   GUI human loop on this repo completed (turn 1 honest FAIL + escalation,
   turn 2 **PASS**, verdict banner, fixture oracle exit 0, fixture
   restored; backend `apple_foundation_afm`, spend + decision path + n in
   the row). Harness-side findings (unanswered-permission stall,
   cancel-not-interrupting, intermittent first-write-without-permission,
   bridge crash on cancel mid-tool-call) are filed there and pulled by the
   harness's own track. **Phase 2 may start.**

2. **Phase 2 — runtime seam + squad UX.** `AgentRuntimeHandle` union:
   embedded harness | ACP CLI agents (pi, opencode, claude-code, gemini,
   codex via `AcpAgentCatalog`) — one registry, one permission surface,
   per-binding settings on the doc roster. Task board as canonical rows
   (AE `ProblemRowWire`-compatible; add a `TaskRowWire` to
   `agentic_executables_wire` if needed — NOT to this product). Batched
   transcript segments (never chunk-per-block — sync would die). Squad
   view: single-writer file locks, per-actor verdicts, whose turn.
   Gate: scripted e2e — two agents (one embedded, one spawned CLI) on one
   doc, one workspace, disjoint tasks, board drains, idle; plus the human
   gate re-run with a CLI binding.

3. **Phase 3 — agent-friendly surface hardening.** The four intents
   (`agent.doc.create`, `agent.task.delegate`, `agent.permission.answer`,
   `agent.task.guide`) registered via IntentCall → MCP/deep-links (the
   mcp_toolkit entries exist; productionize + document for external
   drivers). Remote mover exposed: the daemon runs model-less; pi's model
   (or AFM) is the brain; last_answer owns loop, budgets, oracles. Gate:
   pi drives last_answer headlessly through intents (one full loop,
   transcript recorded); escalation guidance answered from the app.

4. **Phase 4 — one general (non-code) agent domain.** One prose domain
   (research or PRD) on the **evidence tier** — never the code-law `pass`
   tier. Different tool surface, different verification. Gate: one task
   delegated, graded honestly (evidence, not pass), failure classified.

5. **Phase 5 — mesh multiplayer.** Board + transcripts sync across
   devices; task assignment and permission answers ride the existing
   permission round-trip; each device is a player; agents run on the
   device that owns the workspace. World snapshots stay device-local.
   Gate: two devices, one doc, one task, one permission answered from the
   second device.

6. **Harness-side open problems** (tracked in agentic_harness PLAN.md R8;
   this product pulls, never implements them itself): actor topology
   (1 world/N actors vs N worlds/1 brain — task- and CLI-dependent data),
   multi-workspace daemon (one process, several worlds), new-task goal
   isolation on a resumed world (the Phase-1 dogfood finding).

## Race tracks

- **R8 — agents in docs:** Phase 1 LANDED (see history); **Phase 1.5
  (human gate) GREEN 2026-09-05** — production path #1 closed. Phase 2
  (runtime seam + squad UX) is the open track.
- **R9 — console migration:** pi stops being the operator console when
  Phase 3's escalation UX answers guidance in-app. Measure with
  delegation rows (backend, decisions, tokens source, verdict, wall, n),
  never vibes. NOTE from the human-gate run: the escalation guidance
  round-trip already works in-app (turn 1 → guided turn 2 → PASS).

## Standing rules

- **Composition law (ADR 0003):** last_answer composes infrastructure
  (agentic_harness, xsoulspace_inference_*, IntentCall, agentic_executables,
  dart_acp_toolkit, universal_storage/mesh); none of them ever depends on
  this product. Integration ONLY over stable seams: ACP transport,
  IntentCall projection, AE wire types, the harness's public host surface.
- **No second protocol, ever**: ACP vocabulary (prompt, permission,
  propose_move) is the universe; worlds nest fractally and compose because
  every level speaks it.
- **State split is law**: transcripts, board, roster, permission log =
  doc data (synced); world snapshots + meaning tree = device-local
  (`<workspace>/.dart_tool/harnessd_store`), re-derived never restored.
- **Deny-by-default permissions; monotonic budgets; failures are data**
  (classified, never dropped); every published number states backend,
  decision path, tokens source, and n.
- **Honest oracles**: a gate that passes without the agent acting is not a
  gate (R5 rule — the self-profile fixture exists for exactly this).
- **Library separation**: AFM bridge/loader/dylib work →
  `xsoulspace_inference_apple_foundation`; harness loop/oracles →
  `xsoulspace_agentic_harness`; canonical rows → `agentic_executables_wire`;
  intent projection → IntentCall. This product owns docs, UI, hosts.
- Concurrent sessions edit the monorepo (e.g. R7e) — before building,
  wait for `flutter analyze` to settle; never absorb another session's
  fixes; escalate instead.
- Every test ends green or classified; widget tests drive the REAL surface
  keys; integration gates are env-gated and skip honestly when the engine
  is unavailable.

## Cleanup ledger

- [x] Standalone coding-agent screen + route — absorbed into the doc
      surface (Phase 1); `ScreenPaths.codingAgent` removed.
- [x] `XS_FM_BRIDGE_PATH` as the only dylib path — DONE 2026-09-05
      (Runner build phase bundles the dylib; env var stays as override).
- [x] Raw text-field workspace entry — DONE 2026-09-05 (directory picker
      via `file_selector`; text field kept for power users).
- [ ] Transcript in memory only — move to batched doc blocks (Phase 2).
