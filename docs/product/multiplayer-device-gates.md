# Multiplayer device gates — testing docs under real heavy usage

> Runbook + oracle design for proving the multiplayer phase on REAL apps
> (macOS + web) under heavy usage. Companion to [PLAN.md](../PLAN.md)
> Phase 5 (tracks 5.G1–5.G4) and [ADR 0005](../decisions/0005-doc-multiplayer-over-convergence-kernel.md).
> Evidence discipline: every run appends a row to
> [evidence/current-status](../evidence/current-status.mdx); failures are
> classified data; no fixture is ever trivially green.

## The oracle: debugSurface projection diff

Both apps already expose the agent-friendly projection of their typed
state — `AgentDocSurface.debugSurface`, reachable through mcp_toolkit
(the same seam `tool/r9a_gate.sh` drives with
`flutter-mcp-toolkit exec --name fmt_client_tool --toolName agent_*`).
The device gates reuse it as the **convergence oracle**:

> after every convergence point, dump each app's debugSurface JSON and
> diff. Byte-identical = converged. Any difference is either a bug or a
> NAMED expected divergence (see Divergence ledger below).

Widget keys (DESIGN §8) are the second oracle: the driver asserts through
the same `coding_agent.*` keys a human taps — UI and agent read one state.

## Evidence tiers

| Tier | What | Status |
| --- | --- | --- |
| T0 | Kernel property tests (convergence, commutativity-by-inheritance, expiry) | ✅ landed (33 kernel tests) |
| T1 | Two-replica conformance over fakes (shuffled delivery, batch splits, reconnect) | ✅ landed (DocReplica/Store/Roster/perm suites) |
| T2 | Single-app scripted e2e via mcp_toolkit intents (`agent_doc_*`) | ✅ pattern exists (`tool/r9a_gate.sh`); extend with doc-edit verbs |
| T3 | **Two REAL apps, one doc, scripted concurrency** (5.G1) | ⬜ this runbook |
| T4 | **Chaos soak on the two apps** (5.G2) | ⬜ this runbook |

(Touch-driven flows on iOS simulator stay on maestro:
`e2e/maestro/*.yaml` — complementary, for gesture-level regressions.)

## T3 — the two-device gate (5.G1)

Topology: **macOS app hosts the relay** (dart:io — the "main device");
**web app (PWA)** is the second peer, connecting over WebSocket to the
advertised relay endpoint. Both build from the same commit,
`--dart-define-from-file=configs/envs/prod.json`.

Script shape (`tool/gates/multiplayer_gate.sh`, extending the r9a_gate
pattern — two `flutter run` processes, two mcp_toolkit channels):

1. **Boot**: launch macOS app → `agent_doc_create` → `agent_doc_bind`
   (a scratch workspace); start relay hosting; produce pairing code.
2. **Join**: serve the web app; pair via the pairing payload (paste
   path — the QR scan itself stays human); web joins the doc session.
3. **Concurrent scripted edits** (mcp_toolkit edit verbs, interleaved
   with fixed timing): macOS appends text to block A while web prepends
   to block B; both reorder children (fractional keys); both add blocks.
4. **Sync point** → dump both debugSurfaces → **diff** (must be empty).
5. **The permission**: macOS (workspace owner) runs a delegated task
   whose write gate fires; web answers REJECT first (reject-first is the
   law, DESIGN §4) — macOS verdict surfaces FAIL, turn records
   `PERM → reject · web`; re-run with ALLOW → PASS. Both surfaces
   identical again.
6. **Presence + roster**: web's actor appears in macOS `presence(docId)`
   and the PROFILE pane; macOS actor appears on web. Leave web (close
   tab) → macOS fold expires within ttl.
7. **Verdict**: PASS only if every diff is empty, every answer is
   recorded as data on both sides, and the transcript fold is identical.

## T4 — chaos matrix (5.G2)

Each row = scripted on the two apps, one invariant to hold:

| # | Chaos | Injection | Invariant |
| --- | --- | --- | --- |
| C1 | Partition | web offline (devtools network) during edits; reconnect | catch-up → identical projections; no lost ops |
| C2 | Relay death | kill macOS relay mid-session; restart; re-pair-free reconnect | replicas converge; presence expires then re-announces |
| C3 | Process death | kill web app mid-stream (streaming agent text); relaunch | durable op log replays; fold identical; no half-turn ghosts |
| C4 | Streaming burst | agent streams 100+ text deltas/s into one block on macOS while web edits another block | identical text folds; no interleaved corruption (kernel RGA semantics) |
| C5 | Scale | 1000-block doc, 200 child reorder ops in a loop | convergence + interactive fold latency budget recorded (not asserted) |
| C6 | Clock skew | web wall clock −30 min | HLC absorbance: ops still order causally; converge |
| C7 | Rapid permission churn | 10 permission round-trips in a minute, half rejected from web | every decision recorded on both sides; no double-answer wins |
| C8 | Concurrent rebalance | both devices reorder the same 20 children repeatedly | identical order after convergence (LWW policy; scrambled-intermediate allowed, named) |

## Divergence ledger (expected, named — never silent)

- **Same-anchor mid-text inserts**: deterministic but positionally after
  the sibling chain (kernel RGA; PLAN 5.G4 / YATA v2 is the fix). Oracle
  asserts **convergence**, not positional intent.
- **Concurrent fractional rebalances**: intermediate order may scramble;
  converged order is identical (LWW + tie-break).
- Anything else that differs at a convergence point is a **bug**: file a
  row, classify, fix — never widen the oracle to make it pass.

## Hygiene rules

- Scratch workspaces/fixtures are restored after every run (r9a_gate
  pattern); scratch docs carry a `gate/` prefix and are deleted.
- Every run: commit hash, both app platforms, relay topology, seed
  values, diff output (or "empty"), and the verdict row — into
  `docs/evidence/current-status.mdx`.
- The BLOCKER before G1: fix `agent_doc_persistence_test` (pre-existing
  failure; it guards the persistence path this whole gate stands on).
