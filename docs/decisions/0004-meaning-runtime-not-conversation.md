# ADR 0004 — The meaning runtime: agent docs speak the harness's meaning
# surface, never a conversation log

- Status: Accepted (2026-09-06)
- Builds on: [0003](0003-agents-live-in-docs.md) (agents live in docs; the
  runtime union; no second protocol), harness ADRs 0023 (the filesystem is
  a projection target), 0024 (one map-graph, typed materializers),
  0025/0026 (host layer extraction), 0027 (reads are not builds; consent
  plans), and the agentic-harness North Star (beats are the source of
  truth; the model is a sparingly-called reasoning primitive).
- North-Star impact: `clarifies` — applies the composition law to the R9
  hot path. Measured trigger: the R9.b dogfood FAIL row
  (harness `benchmark/runs/delegation_r9.md` finding 6 + the recorded
  corruption) where the conventional command profile let a small model
  blind-write a target file into garbage; the outer oracle held, but the
  shape is impossible-by-construction on the meaning surface.

## Context

The R9.a headless gate proved the intent-driven operator cycle, and in
doing so exposed a category error: **last_answer embedded the harness but
ran it on the conventional command profile** (`read`/`write`/`run` tools,
prose task sentences, transcript text). The harness's own evolution — zoom
instead of read (34–54 ms mechanical cuts vs a measured 68 s graded-task
read), edit-as-rederivation instead of write, beats as the source of truth,
consent plans instead of per-write prompts — never crossed the product
boundary. last_answer consumed a lossy text projection and regex-parsed
verdicts out of it. The user-actor answered ~15 permission round-trips by
hand in one gate run. The grid rendered a conversation because that is all
the host let through — the harness works in beats.

## Decision

1. **Meaning-first runtime.** The agent doc's embedded runtime derives
   `meaningProfile: true` always. Reads are budgeted zoom cuts (mechanical,
   ungraded per ADR 0027); code mutations are host-materialized edit moves
   (analyzer-verified, auto-revert); blind whole-file writes do not exist
   on this path. AFM's context window is too small for anything else — the
   model is a sparingly-called reasoning primitive, the harness is the
   amplifier. The conventional command profile is NOT a product surface:
   it remains only for (a) scripted LLM-free test seams and (b) external
   CLI squad members (codex et al., R9.c's `AgentRuntimeHandle` union) —
   and even for those it is a transitional projection: when mechanics are
   missing (a new format, an unmaterialized media type), the answer is to
   build the format's ETL + materializers, never to hand the model files.
2. **Beats cross the boundary; the transcript is derived.** The host
   projects typed beats (decision + reasoning class, tool call
   start/result, observation, verification, verdict, escalation) through
   the existing ACP session/update stream as additive kinds — no second
   protocol (ADR 0003 §2). The conversation grid becomes a beat
   projection (batched — never chunk-per-block); the text transcript is a
   derivation of beats, never the source.
3. **Consent policy is workspace-level data.** The bounded grant lives at
   `<workspace>/.harnessd/consent.json` (pathGlob, verbs, maxUses —
   monotonic, hard-capped) and is applied by the HOST automatically at
   session creation (`ConsentPlan.forWorkspace`, ADR 0027 amendment).
   Deny-by-default outside the plan is untouched; every plan answer is
   audited (the audit log is session/doc data). last_answer is the
   consumer: R9.3 adds UI to edit the file and render the log — the
   policy mechanics themselves never live in the product.
4. **Multiplayer, not turn-taking (direction).** The world is an MMO:
   agents, humans, and models are players; human messages and guidance
   queue while actors work; disjoint tasks drain in parallel under the
   existing per-model concurrency gates; the board (`TaskRowWire`) and
   per-actor beat projections are the surfaces. Beats also open the
   projection space beyond chat: branches, generational adjacencies,
   pattern discovery across the graph — projections of the same truth,
   not new stores.

## Consequences

- The R9 plan reorders: meaning profile (R9.1) → beats over ACP (R9.2) →
  consent UI (R9.3) → beat grid + queue (R9.4) → board + squad (R9.5) →
  the dogfood row re-run on the meaning surface (R9.6). The recorded
  conversation-profile FAIL stays as the classified failure that
  motivated this ADR.
- The conventional profile's remaining use is transitional and shrinks as
  ETL/materializer coverage grows (md/yaml/json families, then media).
- Widget tests keep the scripted conventional seam for surface mechanics;
  profile-derivation is itself gated.
- Honest oracles unchanged: the workspace convention or the doc's check
  override remains the terminal gate; the meaning profile invokes the
  oracle less (ADR 0027), never dilutes it.
