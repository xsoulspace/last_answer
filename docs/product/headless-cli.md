# Last Answer native CLI

## Scoped autonomous product journey (ADR 0100)

The ordinary Last Answer agent document now exposes **Start autonomous task
board**, **Open live board**, and **Pause changes**. Start creates a separate
local application, grants its native owner two hours to update only `main.dart`,
and retains the existing controller when the document view closes. The model
authors conventional Dart; meaning materialization is paused for this lane.
The product compiles to JavaScript in the existing native candidate containment
and refreshes its browser view after a successful build. A compiler failure keeps
the working artifact. Native Undo uses the existing journal and refreshes again.

For the same product composition in the CLI, add `"autonomousProduct":true` to
`open`, with a dedicated application workspace. It authorizes updates only to
that workspace's `main.dart`, never arbitrary writes or execution. `status`
includes authority, preview URL, revision, activation count and compiler result.
`{"id":"pause","op":"autonomy","action":"revoke"}` revokes further changes.
`{"id":"chat","op":"conversation","text":"Explain the current work"}`
uses the existing sibling conversation actor while a coding task continues.
The human composer takes the same conversation path during autonomous work;
explicit send-now retains its existing interruption behavior.

### Shared generation resources

The addressed `agent_product_local_pair` action configures a cached Qwen snapshot
and optional Laya finite-choice routing. Set `resource` to `qwen`, `deepseek`
(exact DeepSeek1017), or `luna`; `routeWithLaya:false` selects the resource
directly. A settled controller may reconfigure resources without changing actor
identity. It requires an autonomous product document,
`allowEscalation:true`, and the ordinary exact document/workspace Luna-low
subscription consent. `status` reports actual routing/generation receipts,
provider-reported usage, selector latency and native readiness; the subscription
backend label alone does not identify which generator served.

The local ceiling is six calls or two rejected outputs per operation/actor.
Laya then chooses escalation or abstention. A valid abstention explicitly defers
to Luna under this opt-in product policy, with its own `fallback` receipt;
unavailable, malformed or cancelled routing does not silently dispatch cloud.
Escalation stays selected for that operation. All code still passes the same
native source authority, compiler, activation and Undo owners. No training runs.
Results and limitations are retained in the harness's
`docs/evidence/local-product-2026-10-19/README.md`; failures remain failures.
The 2026-10-19 comparison produced no Qwen edit: Luna delivered the first
hybrid change, while local follow-up was stopped without effect. Fresh Luna
completed both visible tasks. Action-envelope compliance, settled local deadlines
and document-revisit/VM responsiveness remain prerequisites for another trial.

These controls are implemented; live product acceptance is tracked in the
harness's `docs/autonomous_product_journey.md`. Source availability and a
compiler pass do not establish a visible model-authored result.

The CLI is a native Flutter product entrypoint over the same `HarnessHost`,
protected account store, subscription binding, workspace tooling, and task pump
as the desktop document surface. It does not install a model runner, fixture,
mock account, or automatic permission approver.

Build a native bundle with `flutter build macos --debug --target lib/headless_main.dart`
using the repository's resolved dependency/toolchain lane. Keep the resulting
bundle separate from an ordinary GUI build: changing Dart targets changes the
bundle's entrypoint. Launch its executable directly, retaining stdin and stdout;
`open -a` does not provide the JSON-lines pipe. Native plugins and the protected
store require the signed app bundle; plain `dart run` is unsupported.

Each stdin line is a JSON object with a unique string/integer `id` and `op`.
Output contains response objects and asynchronous events; native Flutter logging
may also occur, so consume only valid JSON lines with the documented fields.
The initial `ready` event advertises protocol `last-answer-cli/1`.

Open the real coding workspace with explicit consent to send its actor context
to the selected subscription model:

```json
{"id":"open","op":"open","workspace":"/absolute/product/workspace","model":"gpt-6-luna","reasoningEffort":"low","cloudConsent":true,"checkCommand":["dart","analyze"]}
{"id":"investigate","op":"task","text":"Investigate the reported bug and propose the smallest correction. Read the workspace instructions first."}
{"id":"status","op":"status"}
```

`open` uses the active, already authorized Last Answer subscription account; it
never prints credential contents or borrows credentials from another app.
The model must match the active account catalog exactly and reasoning must be
explicitly `low`. Our measured delivery runs use Luna only. `open` retrieves the
account model catalog without an inference call. `checkCommand` is required argv
for the existing host verification owner; it is never evaluated by a shell.
There is no model substitution, access-check inference, API billing fallback,
or automatic persisted cloud-consent update. Workspace/model consent applies to
this CLI session. Sign in through ordinary Last Answer before opening the CLI.

A task returns `started` immediately. Its existing host updates, text and tool
observations arrive as `hostUpdate`, `text`, and `tool` events, ending with
`completed` or `failed`. Existing host update payloads retain verification,
usage and outcome distinctions. Transport diagnostics expose the existing
bounded structural/usage receipts; task completion adds measured elapsed time.
These receipts do not establish independent acceptance or a cache hit target.

When an exact native change asks for consent, the CLI emits `permission` with
an opaque `permissionId` and the host's title/detail. Inspect that request before
answering; an allow applies only to that pending request:

```json
{"id":"answer","op":"permission","permissionId":"permission-1","allow":false}
```

There is no approve-all mode. EOF, cancellation and shutdown reject unanswered
permissions, cancel generation and await settlement before releasing the host.
`permission`, `status`, `cancel`, and `shutdown` remain usable during a task.
A second task or candidate operation is refused while a session is busy.

The `candidate` command projects the product's existing conventional-change
owner. Use its returned exact identifiers and arguments for subsequent actions;
display JSON supplies no authority. For example, inspect existing recovery state:

```json
{"id":"changes","op":"candidate","action":"status","arguments":{}}
{"id":"stop","op":"cancel"}
{"id":"exit","op":"shutdown"}
```

Only installed conventional actions are available. Their existing revision,
source, verification and exact permission controls still apply. This CLI does
not add a shell executor or broaden supported candidate verification. In
particular the current product verifier admits dependency-free Dart; ordinary
Flutter app changes may be refused by that owner.

Restart the native CLI and `open` the same canonical workspace to use the
existing host snapshot restoration path. The CLI does not delete snapshots,
reset exhausted work, replay uncertain effects, or serialize authority into its
own state file. Restart/reconstruction and rendered desktop continuation must
still be qualified with an actual product task.

A task may specify `"maxCompletedInferences":20`. This requests synchronous
cancellation through the existing session owner when the causal trace reports
that many deduplicated successful `inference_settled` records. It is a
**completion-triggered cancellation**, scoped to provider activity in this CLI
session while that operation is active; the trace does not identify domain
tasks. Failed/cancelled or uncorrelated records do not increment the count.
The CLI refuses to combine this option with an active conversation and blocks
starting a conversation until the operation settles. Other CLI sessions have
their own host and counter. A `completionCutoff` event reports the trigger.

This option is not a strict inference-start budget, token budget or
`TaskAggregateBudget`. Parallel calls already started at the trigger may be
cancelled and their usage can remain unknown. The ordinary host still owns
physical settlement and durable cancellation; the client does not restart,
reset or replay a task. Omit the option for ordinary unrestricted operation.

`open.verificationProfile` is a closed selection: omit it or use `"existing"`
for the current default, or explicitly use `"package_snapshot"` for the retained
package-aware compiler implementation. The selected profile is echoed by open
and status. `package_snapshot` requires an already resolved package workspace
with `lib/main.dart`; it cannot be combined with `autonomousProduct:true` and
its separate web compiler. It preserves all native input, consent and
compiler-only checks. This opt-in does not adopt the profile as a GUI/default
feature or establish native qualification. There is no unchecked fallback.

Qwen inference/load/settlement deadlines are30s/120s/5s, cooperatively enforced.
Unknown native settlement quarantines local admission and forbids escalation;
active GPU work is not hard-preemptible. Resource bindings retained by a backend
reconfiguration stay loaded. Cloud requests send max_tokens and reserve costs
against one durable comparison ledger capped at USD1 and the existing provider
limit. Unknown billing blocks new paid dispatch across actors and restarts.
See harness `docs/evidence/resource-product-2026-10-19/README.md` for actual
results and adapter prerequisites; no training is implied by these controls.
