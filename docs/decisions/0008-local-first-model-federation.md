# ADR 0008 — Local-first model federation (per-device brains, one shared meaning-world)

- Status: **Accepted** (user-confirmed 2026-09-08; amendments to the
  Proposed draft folded in — see §Resolved questions)
- Date: 2026-09-08
- North Star impact: `clarifies` (of the local-first law — value path 4:
  local brains are the default on every platform; the model surface is
  the EXISTING inference abstraction, not a new one)
- Builds on: [0003](0003-agents-live-in-docs.md) (actors, brains as data),
  [0005](0005-doc-multiplayer-over-convergence-kernel.md) (join model, ops),
  [0006](0006-session-is-not-world.md) (single-writer worlds, sessions as
  projections), [0007](0007-actor-roster-and-multiplayer-identity.md)
  (roster sync)
- Infra dependencies (referenced, never imported): agentic harness North
  Star (tiny-model-first; flat tokens per decision), harness ADRs 0020
  (model ≠ actor), 0023 (filesystem as projection target — edit as
  re-derivation), 0024 (typed materializers), 0028 (one move per
  decision), 0033 (mechanical repair ladder);
  `xsoulspace_inference_core` (InferenceClient /
  ProvisionableInferenceClient / InferenceTask / ModelPurpose /
  ModelRouter / Model.tier / maxInFlight) with its client family —
  on-device: `apple_foundation` (AFM), `gemma_flutter` (LiteRT),
  `vosk_flutter`, `whisper_cpp_flutter`, `sherpa_onnx_flutter`,
  `flutter_tts`, `web_speech_recognition`; network: `openrouter`,
  `elevenlabs_flutter`; mesh ADRs 0010/0031 (transport seam, presence
  topology).

## Context

Phones now run capable on-device models — and not only LLMs: the
inference abstraction already spans text, structured text, speech-to-text
and text-to-speech, with on-device clients (AFM, Gemma via LiteRT, Vosk,
Whisper, Sherpa, TTS) and network clients (OpenRouter, ElevenLabs)
behind one contract. The harness is tiny-model-first by design (the
harness does the heavy lifting; token cost per decision stays flat), so
an actor on a phone can be as real an actor as one on a Mac — and an
actor may bind DIFFERENT models for different purposes (dictate a note
through Vosk, edit a doc through Gemma, speak a verdict through TTS),
while different actors may share one model.

The mesh already syncs actor rosters and routes permission round-trips
as doc ops. What had no decision was **where the world lives when many
devices each bring their own brains**, and what the model surface is.

## Problem

1. Two devices, two local brains, one workspace: what is shared, what is
   single-writer, and where does verification run?
2. Which models exist on which device — without inventing a parallel
   model registry next to the existing inference abstraction?
3. How does a phone reach its desktop peer when not on the same LAN?

## Decision

**D1 — One shared world per workspace: the meaning graph. The
filesystem is a projection target; materialization and toolchain
verification are single-writer.**

- The **meaning/doc graph is the shared CRDT world** (kernel-converged,
  ADR 0005) — for every workspace kind, coding or not. Any device's
  actor may make **edit moves as ops** into it: a phone actor (Gemma)
  and the Mac actor (AFM) co-edit the same code workspace's meaning
  tree.
- The **filesystem is a projection target** (harness ADR 0023 — edit as
  re-derivation). Its **materializer is single-writer**: the device that
  owns the folder applies moves to disk. A move from any actor is
  *proposed* until it is materialized and graded; for code workspaces
  the oracle (workspace toolchain) runs at the materializer — a phone's
  move on a code workspace is verified by the owner's daemon, not by the
  phone.
- Doc-only workspaces (no FS binding) materialize into the replica
  itself; verification is the structural oracle (materializer re-parse +
  schema + mechanical repair ladder, harness ADR 0033) — pure Dart, no
  toolchain, native on every device.
- Sessions (thread graphs) stay device-local — legal by ADR 0006
  (sessions are projections, not the world). The earlier two-lane split
  (code vs docs) is superseded: the difference is only **who
  materializes and where the toolchain oracle lives**, never *who may
  act*.

**D2 — The model surface is the EXISTING inference abstraction:
purpose-bound models, no new registry.**

- Actors bind models **per purpose** through
  `ProvisionableInferenceClient.ensureReady(ModelPurpose, constraints)`
  and `InferenceTask` (text / nativelyStructuredText / speechToText /
  textToSpeech) via `ModelRouter`. Model ≠ actor (harness ADR 0020):
  one actor may use several models; several actors may share one model.
- Two client classes with different defaults, per the offline-first law:
  - **On-device clients** (AFM, Gemma/LiteRT, Vosk, Whisper, Sherpa,
    TTS): default-on, local-first.
  - **Network clients** (OpenRouter, ElevenLabs): **default-off on ALL
    devices** — they cross the privacy boundary, so they are per-doc,
    per-actor consent-gated, visible on the grid, budgets monotonic and
    surfaced. There is no platform where cloud is the default brain.
- On-device capability is platform-dependent and stated honestly
  (AFM: Apple 26+; Gemma `coding`-purpose artifact is desktop-only
  today; Web on-device artifacts not yet in the catalog) — a missing
  model is an honest refusal with named data, never a silent fallback
  to cloud.

**D3 — Provenance is ink.** Task, turn, and edit ops carry the actor id
and the model provenance (extension of the `originActorId` pattern from
perm ops). Squad surfaces render whose brain produced which line and
which verdict — a trust requirement for MMO collaboration, not a nicety.

**D4 — v1 actor placement law.** Actors run on the device that hosts
their model. Distributed inference (a desktop daemon calling a phone's
model for one generation) is explicitly deferred as research; the mesh
task-op board is the coordination surface, not RPC.

**D5 — v1 composes EXISTING inference clients only.** No new runtime is
wired in v1; the `InferenceClient`/`ProvisionableInferenceClient`
contract is the extension point for future providers. Voice purposes
(dictation via Vosk/Whisper/Sherpa, readback via TTS) enter as actors'
purpose-bound models through the same registry.

**D6 — Relay topology v1: desktop hosts the relay; remote access is a
named roadmap, not a gap.** See the appendix for the online paths; v1
ships LAN + the zero-code remote workaround, with the cloud bridge and
push prompts as the next rows.

## Resolved questions (user-confirmed 2026-09-08)

1. **Shared code workspaces?** Yes — code workspaces are shared CRDT
   worlds too (meaning graph); single-writer applies to materialization
   + toolchain oracle, not to acting. (Folded into D1.)
2. **Cloud default?** Default-off on all devices; offline-first. (D2.)
3. **Model surface?** The existing inference abstraction — models are
   bound per purpose; not Gemma-only. (D2/D5.)
4. **Relay v1?** Desktop-hosted relay stands; remote paths documented as
   a roadmap (D6 + appendix).

## Consequences

- `HarnessHostConfig.buildBackend()` stops hardcoding a platform brain;
  it composes the purpose-bound registry from installed/available
  clients (AFM binding on Apple, Gemma binding elsewhere — both default
  local) and refuses network clients without explicit per-doc consent.
  The app's backend/model picker binds models per purpose and surfaces
  provision state (download/consent) per model.
- Mobile harness first slice sandboxes the workspace to the app documents
  directory (absolute path, no SAF) and mounts only tool-free surfaces
  (md/yaml/json/text materializers, structural verifier, git/dart tool
  entries removed) — the SAF seam (`WorkspaceRef` + `SafFilesystem`) is a
  later, L-sized row gated on real demand.
- Code-workspace moves made by non-owner actors arrive as *proposed*
  ops; the owner's daemon materializes + grades them and folds the
  verdict back as data. Deny-by-default permissions are unchanged; the
  consent surface gains one axis: which devices' actors may propose on
  this workspace.
- Mesh: task ops (`task/<turnId>`) + ephemeral delta stream + sync-on-
  event triggers become the substrate for remote actors (gate: the
  two-device real gate, phone delegates → desktop executes → prompt
  permission round-trip).
- Known honest gaps stand until bridged: mobile backgrounding
  (permission deny deadline — push prompts are the roadmap answer,
  appendix C), delegate-rights policy carried in op schema
  (`originActorId` from day one), relay as single point of liveness.

## Appendix — online/remote paths (D6 roadmap)

Ordered by cost/benefit; A+D is the recommended near-term pair.

- **A. Cloud WS bridge relay (opt-in).** A tiny always-on WebSocket
  relay in the cloud (self-hosted VPS / Fly.io / Cloudflare Durable
  Objects). Both peers dial OUT (no NAT traversal needed); the desktop
  registers as workspace host, the phone connects through it. Privacy:
  ops are signed today — add per-doc end-to-end encryption derived from
  the existing Ed25519 pairing identities (X25519), so the bridge only
  ever sees ciphertext. This is the ADR 0010 §2 "bridge node" seam
  realized; mesh code changes are confined to `MeshTransport`
  implementations.
- **D. VPN/Tailscale workaround (zero code, ship in docs).** Document as
  the supported remote workaround today: the desktop's LAN relay is
  reachable over a user-installed VPN; pairing flow unchanged.
- **C. Push notifications for permission prompts (FCM/APNs).** Required
  for backgrounded phones regardless of transport: a prompt notification
  deep-links into the doc, the app syncs and answers before the host's
  deny deadline. Crosses the privacy boundary → opt-in, and the
  notification payload carries no content (only "permission pending on
  doc X").
- **B. Git-backed op-log exchange (zero new infra, asynchronous).** Reuse
  `universal_storage_github_api` / git_offline as an op-log bus over
  cellular: phone pushes ops, desktop pulls and folds. Latency-tolerant
  by construction (ops are event-sourced; permission answers survive
  the delay). Fallback when neither bridge nor LAN is available.
- **E. WebRTC + TURN (later).** ADR 0010's direct-transport seam;
  heaviest option; defer until A proves insufficient.

## Falsifier

If a converging two-device session cannot be produced where both
actors' moves fold into one meaning-world and the projections are
byte-identical after each convergence point — with the non-owner's moves
proposed→materialized→graded by the owner (code workspace) or verified
structurally (doc workspace) — D1 is false and this ADR must be amended.
