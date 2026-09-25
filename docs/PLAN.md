# Last Answer — forward plan

This is the product frontier. Completed work and historical measurements live
in [history.md](history.md) and [the evidence ledger](evidence/current-status.mdx).
The [central harness plan](../../../ecsai_harness/pkgs/xsoulspace_agentic_harness/docs/agent/PLAN.md)
owns G0, F0–F7, H1, M0, R0–R1 and J0–J1. This product composes those contracts;
it does not implement engine, transport, or oracle policy. Release scope is
recorded in [ADR 0037](../../../ecsai_harness/docs/decisions/0037_consumer_first_release.md);
optional decision-provider isolation follows
[ADR 0038](../../../ecsai_harness/docs/decisions/0038_optional_decision_providers.md).

## Product outcome — a writable shared agentic document

The product is a living, writable document/workspace on which a human and
agents work together. The typed document/meaning graph is the shared
collaborative state; conversations, ACP streams, harness beats, task boards,
permissions, diffs and threads are durable projections/observability of that
work, not substitutes for the document. Workspace content must be addressable
to authorized sessions through stable projections. Do not copy the entire
filesystem indiscriminately into a transcript or a second document store.

For a code workspace, shared edit/meaning operations are materialized to the
owner's filesystem projection and verified there (ADR 0008). One workspace
has one materializer/oracle authority; local or remote participants can read,
edit, and propose in the shared world without gaining execution authority.
Rejected or conflicting changes remain visible and cannot silently overwrite
the materialized workspace.

**ACP direction is staged:** first Last Answer is an ACP client that launches
ACP agents (Codex, Pi, and compatible agents) against the same document and
workspace state. This is not the generic chat-document ACP path. Only after
this outbound path is proven may an external ACP client connect to Last Answer
as an agent/server, or operate it through CLI/MCP/IntentCall.

## First release boundary

Prove the local **macOS, one-device/user/workspace shared-work journey**:
open an agent document → bind one workspace → edit the document as a human
while an ACP agent works → inspect attributed document edits, threads, and
revision-bound proposals → approve/reject materialization → run the workspace
oracle → restart and recover the document/history → run a distinct second
task. The embedded meaning runtime and one real ACP agent launched by Last
Answer must act on the same typed document/world state; conversation is only
one projection. Codex and Pi are the first interoperability fixtures; the
product must negotiate ACP capabilities and name unsupported features rather
than imply universal support from one passing adapter.

A failure, denial, conflict, cancellation, or unavailable agent must end
visibly and preserve the document, operation history and workspace correctly.
This first workload is one workspace and one foreground task, not one actor:
human, mechanical, embedded and ACP-backed actors share the world; models are
reusable resources, distinct from actors. Central **M0** requires local
shared-world conformance before release. Remote device participation remains
the next collaboration gate; VPN/Internet/VPS relay remains later transport
work. Neither changes the one-world/one-materializer law.

`north_star_impact: applies`: this orders an initial acceptance slice within
the existing North Star; it does not replace local-first policy or retire
its deferred obligations. AFM remains the intended default and local-first
standing work. A declared hosted-only preview may explicitly select a hosted
provider and disable unavailable AFM; it makes no local-first availability
claim. No silent or unauthorized hosted fallback is permitted, and unrun AFM acceptance gates
remain open. An optional Jev/OpenRouter
pilot is disabled by default, follows central J0/J1 and transport D0–D3,
and is not a prerequisite for the first release. No provider promotion or
new external transmission policy follows from this plan.

## Ordered consumer work

### C0 — establish a reproducible consumer baseline

Fixture selection and source baseline can begin alongside **G0**; reproducible
launch depends on **R0**. Preserve existing work and record the exact
revisions of Last Answer, ecsai_harness and dart_flutter_packages, plus
remaining local dependency locations. Resolve the local Xcode-license
prerequisite through the user's normal toolchain setup; never accept legal
terms automatically. Verify FVM, dependency resolution and GUI launch from a clean environment.
Validate runtime provisioning and bundling for each included provider and
ACP-agent adapter; record the exact agent/adapter version and negotiated
capabilities. For coding adapters, record how workspace reads, file edits and
terminal operations cross the owner-controlled proposal boundary; do not
include an adapter whose effective write authority cannot be enforced and
tested. AFM bridge bundling is required when AFM is included. A hosted-only preview must
explicitly select its hosted provider and disable unavailable AFM. Replace stale failure claims only
with current evidence; the binding callback already exists in
`lib/home/project_view.dart` and must be regression-checked, not reimplemented.

Gate: documented checkout/bootstrap/build/launch commands work without
undocumented absolute-path dependencies or, for included AFM, shell-only
bridge configuration;
record baseline diagnostics, included/disabled providers and classified
failures. Unrun AFM provisioning/launch gates remain open. Existing targets:
`test/coding_agent/agent_doc_persistence_test.dart` and
`test/coding_agent/harness_host_test.dart`. A launch smoke proves launch,
not model or ACP-agent capability.

### C1 — make document operations and execution outcomes one typed state

Depends on **H1** (which depends on central F3/F4). Adapt
`HarnessSessionController`, the grid and agent-facing projection to the
host's typed task/beat/completion contract, and normalize outbound ACP-agent
activity into the same typed document/world state. Human edits and agent
proposals update that shared state; transcript text is a projection, not the
canonical work record. Remove PASS/FAIL and spend inference from text chunks.
Preserve IDs, world/task/actor/proposal IDs, model-resource binding provenance
independent of UI focus, verification tier, failure class, cancellation state,
backend/model identity, usage source, unavailable usage and observed timing.
Human, embedded-harness, ACP-agent and peer readers consume the same result;
unknown usage must never become zero.

Gate: streamed chunk boundaries cannot change outcome; successful, failed,
denied, interrupted and provider-error turns terminate once; human edits and
agent proposals are visible through the same document state; UI, ACP and
intent projections agree. A negative control emitting model-authored
`verdict: PASS` must never mint host-verified success. Extend
`test/coding_agent/harness_host_test.dart`, `coding_agent_screen_test.dart`
and `agent_intents_test.dart` as appropriate.

### C2 — persist the living document and its work history

Depends on **C1**. Persist canonical document edits/ops, recursive threads,
revision/diff history and stable workspace/file projections, with task/result
IDs, permission decisions, outcome/spend provenance and cooled-turn content
linked as observability. Preserve originating world/task/actor/proposal and
model-resource IDs through materialization and replay. Projection visibility
must obey existing access/privacy scope: sharing a model must not expose
another actor's private context or confer authority. Queue-only or
transcript-only persistence is insufficient. Restore the shared document and
history after navigation, reconnect and process restart; retain unknown
partial state as interrupted/reconciliation-needed rather than inventing
completion. Keep host snapshots, derived runtime trees/cuts and ephemeral
execution state device-local; the shared meaning/document graph and its
durable operations are not device-local. Use stable IDs and idempotent
materialization so replay cannot duplicate edits or turns.

Gate: human edit + ACP-agent proposal → materialize/deny → navigate away,
reconnect or kill/relaunch preserves document content, thread anchors, diff,
approval audit and verdict; replay introduces no duplicates. Editing a
completed activity projection never rewrites historical execution facts.
Extend `test/coding_agent/agent_doc_persistence_test.dart` and
`agent_doc_queue_test.dart` for document/history and queue recovery.

### C3 — make runtime and provider configuration usable and explicit

Depends on **C0** and existing inference contracts. Expose persisted model
and ACP-agent selection, executable/adapter readiness, negotiated capability
and named failure state. Keep application-managed credentials device-local in
an appropriate secure store, never document blocks, exports, logs or mesh.
External agents keep authentication in their own native credential store;
Last Answer must not copy their secrets into document configuration. Require
explicit per-document consent for network execution, disclose the selected
agent/provider before transmission, and never silently fall back from AFM or
an unavailable ACP agent to another network runtime. Surface bounded
provider/agent failures and real usage availability through C1.

Gate: GUI-only configuration survives restart; missing or invalid
application-managed credentials, agent installations or native agent
authentication fail before work starts; saved documents and logs contain no
key; cloud requests are refused without consent. If AFM is included, it remains usable without credentials. A hosted-only
preview disables unavailable AFM and requires explicit hosted selection and
consent; it must not imply offline/local-first availability or close AFM gates.
Optional decision-provider composition settings stay hidden/disabled by
default. **D0–D2 → J0** enables an explicit opt-in shadow evaluation;
**D3** records provider evidence/disposition within **J1**. Production pilot
use requires the relevant J1 promotion; no primary Jev feature or default
switch is implied. A generic decision-provider actor may reason and code
through authorized semantic choices; Jev is one example. J1-T/R/C/M evaluate
target/evidence selection, reasoning, unseen coding and mixed-world behavior
separately. R/C experiments can start after their generic safety gates without
waiting for consumer release; each track keeps its own evidence and promotion.

### C4 — materialize shared edits through the workspace owner

Depends on **H1/F3/F4**, **C1** and **C3** for network execution. Convert
shared document/workspace edit operations into the host-produced immutable
review proposal: diff, target paths, verification scope and source revision,
tied to the approval request before filesystem materialization. Consume that
contract; never reconstruct approval identity from transcript text or
independently invent a proposal. Bind permissions to the originating
world/task/actor/proposal revision, never the currently selected tab or the
first roster entry. Roster presence, remote connection and model sharing
grant no permission; preserve existing authorization policy. Display and
edit scoped workspace consent and audit its use through the host contract;
product code must not create a separate authorization engine. The workspace
owner remains the single materializer/oracle for code files. Preserve
fresh-revision checks and verification/rollback guarantees. Expose deny,
stop, guidance, conflict and actionable errors in both UI and agent
projections; navigating away must not create hidden work. The ACP adapter/
harness must mediate workspace writes into those proposals. If an ACP runtime
requires direct filesystem mutation, isolate it from the authoritative
workspace and import a revision-bound diff; refuse coding support when neither
boundary is enforceable.

Gate: approve affects only the reviewed scope; stale proposals are refused;
deny writes nothing; verification failure restores the prior state; stopping
while awaiting permission or model output terminates within the declared
bound. No future mutation inherits permission accidentally. Extend
`harness_host_test.dart`, `coding_agent_screen_test.dart` and
`agent_intents_test.dart`; execute real workspace checks in C6.

### C5 — make shared-world sessions, restore and the next task unambiguous

Depends on **C1/C2/C4** and central task-lifecycle gates. All sessions on one
workspace attach to the same world/document, not competing materializers.
Distinguish resume from a new task on a restored workspace; preserve audit
and monotonic budgets within their declared scope without carrying an old
goal into a new task. Reconcile queued/in-flight tasks, consent waits and
provider switches with host state. Cancellation addresses the originating
task/request and actor, not whichever projection is focused or whichever
actor shares a backend.
Expose a world-level stop distinctly if supported; never silently convert a
task stop into one. Resume preserves actor provenance and accounting, without
reviving an old actor goal or resetting shared-model budget state. A persisted
queue must not execute silently on startup. Denied or cancelled
tasks must never replay automatically; restored pending permissions expire
and require a fresh decision, never a restored grant. Guidance,
steer and send-now must preserve interrupted outcomes and actual partial
usage. Treat an unavailable old session as named state, not a fresh success.

Gate: task A completes, restart, task B targets a different fixture and does
not repeat A; a second local session observes the same document/world;
interrupted/queued tasks recover without duplicate writes or lost prompts.
Extend `agent_doc_queue_test.dart`, `session_registry_test.dart` and
`session_registry_gate_test.dart`. Remote peers use the same shared-world
identity when their mesh gate is run; they never start another workspace
materializer.

### C6 — close the real consumer acceptance gate

Depends on **C0–C5**, central **F1–F4**, the relevant **F5** safety and
claimed-provider lifecycle gates, **F6a** capability routing, **H1** and
**R0** and **M0**; feeds **R1**. The broader ten-class **F7** AFM coding gate and
**F6b** novel composition are separate readiness claims, not prerequisites.
Run the first product slice in the actual macOS app using the meaning
runtime and a real supported ACP agent launched by Last Answer as client, no
test handler. Use a disposable workspace whose oracle fails until the
requested change exists. While the ACP agent is active, edit the shared
document as a human; prove both projections observe the same state. Verify an
agent's attempted unmediated write cannot alter the authoritative workspace.
Include successful materialization, rejected mutation,
stale/conflicting proposal, verification failure/rollback, provider/agent
failure, stop, restart, and a distinct second task. Run protocol conformance
against Codex and Pi adapters
before claiming both; do not claim every ACP capability from one adapter.
Retain a scripted seam for deterministic regression coverage.
The required local M0-backed consumer gate opens two projections on one
world with human/mechanical actors and two model-backed actor identities
sharing one model resource. Serialize materialization; switching focus must
not reroute permissions, outcomes, cancellation or resume. Verify no second
daemon, double apply, actor-context leakage or authority from roster presence.
Reuse `session_registry_test.dart` and `session_registry_gate_test.dart`,
extending their currently narrower cases. Check how mechanical actors are
represented through existing contracts; do not assume the current actor-kind
enum already carries them or introduce a speculative enum migration. These
scripted routing/safety checks complement the live primary-provider journey.

Existing starting points are
`integration_test/coding_agent_afm_meaning_e2e_test.dart`,
`integration_test/coding_agent_afm_e2e_test.dart` and
`integration_test/coding_agent_self_profile_test.dart`; inspect their actual
flags before use. Extend them or add a dedicated consumer gate where their
coverage stops. Record exact revisions, fixture diff, independent oracle,
provider/model, backend, decisions, usage source, wall time, run count,
failures and limitations in the evidence ledger and central run artifacts.
A conventional-profile historical PASS cannot close this meaning-runtime
gate. A consumer preview is not a claim that every future domain works.

## Staged work after the local shared-document proof

These retain their existing ADRs and acceptance criteria. The local
shared-document/ACP-client slice is part of C0–C6; the work below extends
that proven substrate to more actors, peers, transports and entry directions.
Legacy labels such as R9.1–R9.6, 5.G1–5.G5 and 6.A–6.E are retained as
trace identifiers for existing decisions and evidence, not as an alternate
execution order; follow C0–C6 and the staged sequence below.

- **Phase 3 / R9.5 — broader runtimes, squads and shared-world collaboration:**
  embedded harness + multiple ACP CLI bindings, per-binding settings,
  canonical task board (AE wire types), single-writer locks and per-actor
  results, then mesh peers on the same world. Gate: multiple agents perform
  disjoint tasks, human edits remain visible in the same document, and a
  second device converges edits and permission results without becoming a
  second materializer. This is broader squad/remote work, not the first ACP
  binding.
- **Phase 4 — external operator surface:** only after the Last Answer ACP
  client path passes C6, expose a separate production ingress for an external
  ACP client/CLI/MCP/IntentCall to operate Last Answer. Gate: an external
  operator drives the complete loop against the same writable document,
  permissions, materializer and oracle. Existing debug intents do not prove
  production exposure.
- **Phase 5 — non-code document domain:** evidence-tier research/PRD workflow;
  explicit proposal preview, revision-safe apply and persistent child-thread
  conclusion. Plain DocView/ACP inference currently bypasses the harness.
  Gate: a real delegated prose task has honest evidence grading and named
  failure, never coding PASS by analogy.
- **5.G1 — real two-device shared-work completion:** after the local
  shared-document proof, re-run macOS/web pairing, concurrent document edits,
  workspace projections, convergence and the previously blocked peer
  permission answer. Both peers observe one meaning world; only the owner
  materializes code and runs its oracle.
- **5.G2 — heavy-usage soak:** partitions, restart, streaming bursts, large
  docs and clock skew converge or produce a named expected divergence.
- **5.G3 — snapshot-aware sync:** compacted replica and lagging peer recover
  through `needsSnapshotFor`/`adoptSnapshot` across the actual store/mesh seam.
- **5.G4 — positional co-editing:** kernel YATA v2 behind `MergeStrategy` when
  same-block co-authoring becomes the frontier; convergence alone does not
  prove positional intent.
- **5.G5 — ecsly bridge/publication:** live World→delta bridge and published
  kernel dependency; two-device convergence without the path override.
- **Phase 6.A — purpose-bound local models:** provision/consent UI for AFM,
  Gemma and voice capabilities; scripted parity plus real structured move.
- **6.B — mobile harness:** documents-directory workspace, text materializers,
  injected storage, trimmed tools and structural verification; real Android
  edit with visible result/spend. See [feasibility](harness-mobile-feasibility.md).
- **6.C — mesh console:** phone task op→macOS execution→streamed phone verdict
  and prompt permission response, over existing convergence/ACP contracts.
- **6.D — shared-world device actors:** macOS+Android offline/online editing,
  one owner materializing code, provenance and converged results, zero cloud
  calls (ADR 0008 falsifier).
- **6.E — remote access:** document VPN first; later opt-in encrypted relay
  (including a user-operated VPS path), background permission notification
  and asynchronous git op-log fallback. Gate: cellular permission response
  before the host's deny deadline.
- **Item 8 / ADR 0010 — surface consolidation:** remove unused creation
  species without migrations, merge chat/tree mechanics into the grid only
  when the runtime union supports them. Gate: plain doc→delegated turn→cooled
  span→child thread→explicit conclusion apply; analyze/tests and rail review.
- **Item 9 — queue/cooled-turn completion:** C2/C5 own durability and lifecycle;
  remaining recursive span discussion and the full queue-as-graph view stay
  deferred under ADR 0011, with scripted steer/send-now and child-thread gates.
- **Item 10 — profiler adoption:** registry-backed addressing, optional docId
  verbs, shared profiler protocol instead of private debug truth, doc-domain
  glue extraction and capability-gated inspector. Preserve ADR 0009's
  two-surface/headless/adapter-removal gates; do not redo existing registry.
- **Item 11 — casting trace/replay:** after items 9/10, span→decision context
  provenance and headless `cutTrace`; deterministic replay without inference
  until explicitly rerun; honest absence on devices without the local graph.
- **Harness topology/multi-workspace:** follow the central plan; several actors
  or workspaces are not implied by the one-foreground-task release gate.
  Local shared-world actor/resource correctness is required now by M0/C6;
  advanced scheduling and distribution remain deferred.
- **R9 console migration:** R9.1 maps to the declared central capability gates+C6; R9.2→H1/C1;
  R9.3→C4; R9.4→C1/C2/C5; R9.5 remains squads; R9.6→C6/R1 with a current
  genuinely failing fixture. Retire external operator workflows only after
  measured acceptance, never by declaration or an already-fixed fixture.

## Execution and evidence rules

Follow AGENTS.md, the repository maintenance skill and DESIGN.md. Keep
infrastructure changes in their owning repositories. Use real surface keys
and intents; preserve unrelated working-tree changes. Standing constraints
remain deny-by-default permissions, honest verification tiers, bounded
budgets, no second protocol, shared durable document/meaning operations, and
the split between replicated work state and device-local runtime snapshots.
Code workspace materialization stays with its owner. Do not infer model or ACP
capability from availability.

Run focused tests first, then relevant full app analysis/tests and the actual
integration gate. `fvm flutter analyze` and `fvm flutter test` are existing
commands; inspect current SDK/dependency readiness before executing them.
For documentation changes run `git diff --check` and validate changed links.
Move each completed C item to history with date, evidence and non-claims;
keep only its remaining work here. Historical pass counts are not current
validation. Optional Jev evidence remains separate from AFM and release rows.
