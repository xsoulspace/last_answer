# ecsai + ModelScope first priority — the in-app code path (2026-11-05)

Status: **analysis** (owner-directed; read-only research, no code changed).
Companion to [shell-redesign-rail-views-tabs-2026-11-05.md](shell-redesign-rail-views-tabs-2026-11-05.md)
— this document makes the owner's FIRST priority concrete: *"start working
with the code via ecsai and modelscope config + local models"* from inside
Last Answer. Evidence: code reading of `lib/coding_agent/*`,
`lib/agent_config/*`, `lib/settings/features/*`, `lib/shell/*` (this repo),
`~/xs/ecsai_harness` (`pkgs/xsoulspace_agentic_host`, `pkgs/xsoulspace_agentic_afm`),
live machine state (daemon pid 37857, owner pointer, palette health file,
realm journal) on 2026-11-05.

Live-machine facts used throughout:

- The ONE daemon runs: `~/xs/ecsai_harness/build/ecsai_daemon.exe --composed
  --workspace ~/.xsoulspace/worlds/local --mcp --local-mcp-seats
  --idle-exit-minutes 0` (owner pointer `~/.xsoulspace/worlds/local/owner/owner.json`,
  pid 37857 at time of writing).
- Realm authority row declares `configurationRoot: /Users/antonio/xs/ecsai_harness`
  (journal record) — that repo's `.xsoulspace/config.json` is therefore where
  the realm's `model_palette` lives.
- `~/.xsoulspace/palette_health.json` (2026-11-05T17:44Z): **all four
  `modelscope_*` entries `ok`; the PRIMARY `openrouter_deepseek` is
  `failed` with `transport_http_403`**. The realm's declared primary generative
  rung is down and the ModelScope rungs are healthy — the owner's priority is
  also the live outage workaround.
- `MODELSCOPE_API_KEY` is exported in `~/.zshenv:10` (shell-env credential).
- No `realm_scheduler` / `realm_actor` process runs at time of writing.

---

## 1. The exact end-to-end path today

There is not ONE path; the app ships **three delegation runtimes** and the
owner's priority needs the third. Each hop is marked **IN-APP** (works from
shipped chrome or the app's own MCP tools) or **REQUIRES-CLI/EXTERNAL**.

### Lane A — AgentDoc in-process embed (the shipped operator cycle)

Runtime: `HarnessEmbed` inside the app process; NO ecsai daemon involved;
backends `apple_foundation_afm | open_router | jev | laya | lfm | qwen |
external_acp | chatgpt` (`harness_host.dart:548-554`). **ModelScope is not a
lane here.**

| # | Hop | Where | Mark |
|---|-----|-------|------|
| A1 | Human opens an agent doc. Routes exist (`/home/d/:docId`, `router.dart:44-52`; hosted by `ProjectView` → `AgentDocSurface`, `home/project_view.dart:59`, class at `agent_doc_surface.dart:61`) but **no chrome reaches them** (redesign D4); the projects list was retired | `lib/router.dart`, `lib/home/project_view.dart:59` | **BROKEN for humans**; IN-APP only via MCP `agent_doc_create` (debug/profile builds only — hook absent in release, `agent_mcp_tools.dart:242-249`) |
| A2 | Bind workspace: SETUP pane field (`_workspaceField`, `agent_doc_surface.dart:196`) or MCP `agent_doc_bind` → `bindFromIntent` (`agent_mcp_tools.dart:269-300`) | agent doc surface | IN-APP (MCP), settings-pane field for humans |
| A3 | Pick backend/model: doc payload's `agent.backend` → `_configFor` (`agent_doc_surface.dart:601-646`) → `HarnessHostConfig` (`harness_host.dart:517-546`); model choice table `desired_coding_model.dart:5-17`; key read from `ProviderConfigurationStore` (`provider_configuration.dart:65-92`, secure storage) / env fallback (`harness_host.dart:639,651`) | doc settings + secure store | IN-APP; keys entered in Settings → Agents & Models pane (`agent_config_settings_pane.dart:323-336`) |
| A4 | Delegate: composer submit `_submitFromComposer` (`agent_doc_surface.dart:1673`) → `_delegateText` (`:1645`) → `runTurn` (`:1004-1027`) → `HarnessSessionController.delegate` (`harness_session_controller.dart:596`) → `HarnessHost.delegateTask` → `HarnessEmbed.delegateTask` (`harness_host.dart:90-108`). MCP mirror: `agent_task_delegate` (`agent_mcp_tools.dart:157-166`), intent mirror `delegateFromIntent` (`agent_doc_surface.dart:650-667`) | in-process daemon embed | IN-APP |
| A5 | Permission answer: embed raises `session/request_permission` → `HarnessHost._handlePermission` (`harness_host.dart:326-336`) → `PendingPermission` (`:463-510`) → controller (`harness_session_controller.dart:394,808,1001`) → UI row above the composer (`agent_doc_surface.dart:~2605`); intent/MCP: `answerPermissionFromIntent` (`:681-691`), `agent_permission_answer` (`agent_mcp_tools.dart:207`); remote routing via doc-mesh ops (`permission_doc_router.dart`, `agent_doc_surface.dart:909-951`) | same | IN-APP |
| A6 | Verdict + spend: streamed `verdict:` line → `HarnessTurn.verdictLine/spend` (parsed, never fabricated, `harness_session_controller.dart:97-141`); rendered as one colored rule with spend (`agent_doc_surface.dart:54-55`, projection `:856-890`); MCP read `agent_doc_state` (`agent_mcp_tools.dart`) | same | IN-APP |
| A7 | Apply change: meaning runtime materializes edits (verify + auto-revert); `ProductCodingChangeView` shows native candidate diff/preview, **Live Apply completes the exact pending permission** (`product_coding_change_view.dart:10-45`, hosted `agent_doc_surface.dart:2618`); conventional candidates via `conventional_change` (`harness_host.dart:138-153`) | same | IN-APP |

Lane A verdict: fully in-app, human-operable **except A1** (no human doc
navigation — Phase 3 Documents view fixes it). But it never touches the ecsai
palette, so it cannot satisfy "via ecsai and modelscope".

### Lane B — realm chat (durable world, in-app bots)

Runtime: the app opens the realm's ONE journal **directly on the filesystem**
(`RealmWorld.open` → `~/.xsoulspace/worlds/local/coordination`,
`realm_world.dart:105-131,157-170`); roster bots run **in the app process**
(`realm_bot_host.dart:1-21`), one dispatcher + fan-out, brains from
`brainRef` (`realm_world.dart:219-268`).

| # | Hop | Where | Mark |
|---|-----|-------|------|
| B1 | Create actor with a brain: `brainRef` grammar is `local:<cast>[?k=v]` (MLX qwen/lfm + cached Qwen3 variants) or `openrouter:<model>` — **no ModelScope form exists** (`actor_brain.dart:8-23`, resolver `:214-257`, picker options `:266-293`, MLX gate `:305`) | actor creation sheet (`actor_creation.dart`) | IN-APP, but ModelScope unreachable |
| B2 | Chat/delegate by addressed beat; bot replies run on the app's own engine isolate | `realm_bot_host.dart`, `kernel_conversation.dart` | IN-APP |
| B3 | Brain health badge reads the daemon's `palette_health.json` (`realm_chat/palette_health.dart:46-108`; dot `shell/view_people.dart:535-570`) — keyed by cast id, so `local:*`/`openrouter:*` brainRefs mostly render **no verdict** (`palette_health.dart:63-68`: null when the palette names no such entry) | People view | IN-APP (read-only) |

### Lane C — ecsai seat lane (the owner's priority: daemon, palette, ModelScope, durable tasks)

Runtime: the resident daemon (pid above) hosts MCP seats; the app earns a
seat over the daemon's local socket (`WorldSeatChannel.request` →
`HarnessMcpClient.joinLocal`, `world_seat_io.dart:45-99`, human participant
identity `:24-40`). The daemon NEVER gets spawned by the app: `allowSpawn:
false` is law (`external_worlds_io.dart:5-9`; honest refusal "arm `ecsaid
--serve`" at `world_inspector_pane.dart:555`, `world_inspector_tools.dart:192`).
A complete supervised-launch adapter exists — `startSupervisedEcsaiDaemon`
(`supervised_world_io.dart:63-154`, argv `:264-283`) — and has **zero
callers in `lib/`** (built, unwired).

| # | Hop | Where | Mark |
|---|-----|-------|------|
| C1 | Daemon live: owner pointer + pid (`supervised_world_io.dart:249-258` reads the same doctor truth) | `~/.xsoulspace/worlds/local/owner/` | **REQUIRES-CLI today** (arm `ecsaid`/lifecycle from a shell); one-click arming is the unwired `startSupervisedEcsaiDaemon` seam |
| C2 | Discover + bind world: manifest scan `~/.xsoulspace/worlds/*.json` (`external_worlds_io.dart:56-60,71`), bind sheet from the inspector pane (`world_inspector_pane.dart:235`, `world_binding_sheet.dart:30-118`); doc-level binding `agent.worldBinding` (`supervisor_service_io.dart:79-84`) | world inspector (opt-in view) | IN-APP (inspector reachable; not in main chrome grammar) |
| C3 | Earn seat: local socket join + orient (`world_seat_io.dart:52-85`); human subject persisted (`:24-40`) | same | IN-APP |
| C4 | Read rungs: `agent_participation {op:'actions'}` returns `modelPalette` entries `{id,kind,model,provider,primary,capabilities,bound}` (harness `harness_participation_tools.dart:399,1175-1196`); parsed by `WorldModelPalette` (`world_work_verbs.dart:15-112,206-242`); picker UI exists (`world_model_picker.dart`) | seat verb | IN-APP read; **no health column** (health lives in the file/orient, hop C8) |
| C5 | Delegate a code task (current law, ADR 0118): `task {op:'create', task, requestId, purpose, modelId?, addressees?}` → `_taskCreate` (harness `durable_realm_tools.dart:868-955`): palette required (`model_palette_unbound` `:874`), `modelId` defaults to the **primary generative entry** (`:895-903`; today = the FAILED `openrouter_deepseek`), frozen check from the project's `.xsoulspace/config.json` verification (`last_answer/.xsoulspace/config.json:3-13`; unbound → `delegation_verification_unbound` `:918`), admitted to `DurableTaskQueue` (`pkgs/ecsly_tasks/lib/src/durable_task_queue.dart:361`). App client: `HarnessWorldAgentClient.admit` (`supervisor_agent_client.dart:196-222`) — **sends no `modelId` and no `addressees`**, so every app delegation lands on the primary rung | seat verb | IN-APP verb exists; **app UI surfaces none of it** (only supervisor automations use it); the shipped world-inspector delegate buttons call RETIRED verbs (hop C6) |
| C6 | Drift block: the inspector's work verbs are the pre-0118 surface — `resource_bind` / `task_delegate` (`world_work_verbs.dart:257-302`; UI `world_conversation_view.dart:466-507,956-961`) and `_delegateViaSeat` calls `agent_task_delegate` **over the seat channel** (`world_inspector_pane.dart:343-388`) — the harness answers with the named migration map (`harness_participation_tools.dart:1220-1238`: "delegation is not a verb: create a task and address it") and the seat catalog has no `agent_task_delegate` | world inspector | IN-APP but **dead on arrival** — must be rewritten onto `task op:create/say/show/cancel` |
| C7 | Execution: the queue is claimed ONLY by `realm_actor.dart` edge processes (`realm_actor.dart:467-511` claim; `runRealmActorTask` `:568-670`: palette from `modelConfigurationRoot` `:597-604`, credential chain process→project→global EnvConfig `:606-620`, ModelScope rides `openRouterBuildRouter(baseUrl:)` for `openai_compatible` `:643-660`, local casts `lfm`/`qwen` via native MLX bindings `:679-737`), spawned by `realm_scheduler.dart` (`:394-470`; laws `:3-40`) under the executor `DurableCodingExecutor` (`durable_coding_executor.dart:40-56`, review write gate `:263`). **Nothing in the daemon or the app arms the scheduler** (no callers of `runRealmScheduler` outside its own `main`, `realm_scheduler.dart:530-544`; daemon composes bindings but no task runner) | edge processes | **REQUIRES-CLI** (`dart run realm_scheduler.dart …` or `realm_actor.dart --once`) — the single biggest hop gap |
| C7' | Conversational alternative (runs today, in the daemon): an addressed beat to an actor with `brainCast` = a palette entry drives `daemon_actor_loops` (`daemon_actor_loops.dart:3-47,648-653,664`) on the daemon's own palette bindings (`ecsai_cli.dart:1758-1815`; declared ModelScope bindings built at `pkgs/xsoulspace_agentic_afm/bin/ecsai.dart:420-515`), with fs/run tools gated by this repo's posture (`last_answer/.xsoulspace/config.json:15-29`: write/run/world true, `run_exact` = `fvm flutter analyze`, `run_allow` = test/git reads; write gate `realm_actor_tool_loop.dart:317-330`). Cast binding via seat verb `agent_participation {op:'actor_bind', brainCast}` validated against the declared palette (`realm_actor_admin.dart:107-163`). **No durable queue terminal, no frozen check** — it is the chat floor, not the acceptance lane | daemon | IN-APP once a seat exists; **no app surface calls `actor_bind`** |
| C8 | Permission (ecsai lane): there is no human permission round-trip — the conversational lane auto-approves own-claim writes and refuses others' claims (`realm_actor_tool_loop.dart:14-19,317-330`); the durable lane gates via frozen verification + review-mode write gate inside the executor. The human's consent surfaces are the project posture config (external file) and, in Lane A only, `session/request_permission` | harness | REQUIRES-CLI (posture edits); permission inbox (Phase 3) shows Lane A only today |
| C9 | Verdict + spend: durable lane terminal (`state/model/result.summary`, `durable_realm_tools.dart:999-1010`, read via `task {op:'show'}`; app reader `supervisor_agent_client.dart:224-238` — "creation receipt is not a completion" law `:8-13`); token/cached-token telemetry rows in the journal collection `tool_loop_telemetry` (`realm_actor_tool_loop.dart:1023-1060`: promptTokens/cachedTokens/completionTokens/stalled per dispatch); doctor renders cached-% (`ecsai_doctor.dart:944-974`) | journal + doctor | IN-APP readable (the app holds a `RealmControlStore` on the same journal, `realm_world.dart:117-119`, and imports the doctor in-process, `supervised_world_io.dart:17-19`) — **but no chrome renders any of it**; mesh-task ListTiles in Settings → Agents & Models (`settings_screen.dart:38`, `mesh_tasks_settings_page.dart:24-25,70-83`, 1 s poll) show the APP's mesh board, not harness tasks |
| C10 | Apply change: durable lane writes land in the workspace under the executor's review gate + frozen check (no app diff view); conversational lane writes land via the claim-aware gateway. The app's diff/apply surface (`ProductCodingChangeView`) is bound to Lane A only | workspace fs | REQUIRES-CLI for review (git diff); no in-app change view for Lane C |

**Summary of the true state:** the owner can, from inside the app, earn a
seat and READ the palette (C3-C4); every other Lane-C hop is either dead
verbs (C6), CLI-armed (C1, C7, posture), or unrendered (C5, C9, C10). Lane A
is complete in-app but cannot speak ModelScope.

---

## 2. ModelScope + local models: config shape today, and the minimal app-side surface

### 2.1 How the harness palette is shaped (files + schema)

- **Schema** (Zed-style, closed vocabulary, named refusals):
  `pkgs/xsoulspace_agentic_host/lib/src/palette_config.dart` —
  `model_palette.providers.<id>` = `{transport: openrouter |
  openai_compatible | system_one (:72-101), base_url (https; http only for
  loopback, :651-674), credential_env (an env var NAME, never a value;
  `sk-…`-looking values refuse `palette_literal_credential`, :678-704),
  models[] {id, max_tokens, max_output_tokens, reasoning_effort,
  include_reasoning, capabilities{}} (:136-166,429-512)}`;
  `model_palette.cast[]` = `{id, provider, model | builtin:true, role:
  generative|decision, lane?, primary?}` (:212-250,514-646). One entry per
  model; builtin names reserved (`laya, apple_foundation_afm, lfm, qwen,
  jev, open_router`, :58-65). Structural errors refuse the boot
  (`PaletteConfigError` codes); entry-level problems compose as HEALTH and
  boot (ADR 0119, :26-30).
- **Load chain**: global `~/.xsoulspace/config.json`, then nearest
  `<workspace>/.xsoulspace/config.json` walking UP; the workspace file
  REPLACES the global `model_palette` (`palette_config.dart:332-340,763-778`).
  The daemon's workspace is the world home (`~/.xsoulspace/worlds/local`),
  whose upward walk finds only the global file — which declares NO palette —
  so the effective source is the authority row's **`configurationRoot`
  fallback = `/Users/antonio/xs/ecsai_harness`** (`durable_seat_host.dart:63-77`;
  mirrored per-project in `daemon_actor_loops.dart:897-923` after a live
  `model_palette_unbound` bounce, 2026-11-05). Per-task, the actor re-reads
  the palette from the task's `modelConfigurationRoot` (`realm_actor.dart:597-604`).
- **The live declaration** (`/Users/antonio/xs/ecsai_harness/.xsoulspace/config.json:62-220`):
  provider `modelscope` = `openai_compatible`,
  `https://api-inference.modelscope.ai/v1`, `credential_env:
  MODELSCOPE_API_KEY`, 4 Qwen3.7/3.8 models with capability maps (:64-114);
  cast = 4 `modelscope_*` generative entries (none primary, :161-184),
  `openrouter_deepseek` **primary** (:186-192), `openrouter_minimax`, plus
  builtins `laya/jev/apple_foundation_afm/lfm/qwen` (:200-219).
- **Local lanes**: `lfm` (LFM2.5) and `qwen` (Qwen3 MLX) are builtin casts,
  lazy in-process native engines, weights NOT auto-downloaded
  (`not_downloaded` health + fix hint; the runtime-never-downloads law is
  explicit — journal wave-2 note, 2026-11-05). Per-project window override:
  `realm_actor_context_windows.qwen: 16000` (`last_answer/.xsoulspace/config.json:30-32`).
  `apple_foundation_afm` is the on-device Apple Foundation lane (Lane A backend
  too, `harness_host.dart:669-685`).
- **Economy**: escalation ladder `realm_actor_escalation` in the GLOBAL config
  (`~/.xsoulspace/config.json:41-48`): `qwen/lfm/modelscope_qwen37*→
  modelscope_qwen38max → openrouter_deepseek`; consumed at daemon arm
  (`ecsai_cli.dart:1786-1801`, `daemon_actor_loops.dart:344,405-407,455-465`
  — one promotion per dispatch, 10-min target cooldown, ADR 0122).
- **Health**: `~/.xsoulspace/palette_health.json` (path
  `palette_config.dart:47-48`); boot snapshot + runtime wire transitions
  (`afm/bin/ecsai.dart:~500 runtimeHealth.observe`); readers: doctor
  (`ecsai_doctor.dart:578-600`), orient cut ONLY when degraded
  (`harness_context_tools.dart:31-59`), and the app's `PaletteHealthStore`
  (`realm_chat/palette_health.dart`).
- **Credential**: value in `~/.zshenv:10` (shell env) or the flat EnvConfig
  stores (`~/.config/xsoulspace/inference/config.json` global /
  `<repo>/.xsoulspace/config.json` local; precedence process→local→global,
  `xsoulspace_inference_core/lib/src/config/env_config.dart:9-27,52-77`).
  A GUI-launched daemon/actor inherits NO shell env — the EnvConfig files are
  the durable seam; a missing credential degrades the entry by name
  ("declare credential_env … then restart the daemon",
  `afm/bin/ecsai.dart:475-484`) and the actor refuses
  `actor_credential_absent` (`realm_actor.dart:639-642`).

### 2.2 What the app can already read/write

- `agent_config.json` (app-support dir, `agent_config_persistence_io.dart:18-31`):
  Zed-shaped doc `{agentServers{command,args,env}, providers{apiKeyEnv,
  baseUrl, models[], defaultModel}, chat{defaultProvider,defaultModel,
  systemPrompt}}` (`agent_platform_config.dart:19-151`). The Settings pane
  edits servers/keys/env/baseUrl/models/defaults and SAVES the same file
  (`agent_config_settings_pane.dart:90-115,281-385`); provider API keys go to
  the platform secure store, never the file (`provider_configuration.dart:65-92`).
  **But**: defaults declare only `open_router` (`agent_platform_config.dart:214-219`),
  the pane has **no "+ add provider" button** (`:281-295` iterates existing
  entries only), and this document feeds the APP's chat/ACP surfaces — it is
  **not** the harness `model_palette`. Two config worlds, no bridge.
- Read-only harness state the app already touches: palette health file
  (`palette_health.dart:70-107`, 5 s cache), seat palette via
  `agent_participation {op:'actions'}` (`world_work_verbs.dart:206-242`),
  doctor report in-process (`supervised_world_io.dart:17-19,249-258`), realm
  journal via `RealmControlStore` (`realm_world.dart:117-119` — the app could
  scan `tool_loop_telemetry` and `durable_tasks` directly today).

### 2.3 Minimal app-side surfaces/tools for the four owner needs

| Need | Covered today | Missing (minimal build) |
|---|---|---|
| **(a) See rungs + health** | Seat verb `actions.modelPalette` (ids, model, provider, primary, capabilities, **bound**) parsed at `world_work_verbs.dart:68-112`; health file store `PaletteHealthStore`; People-panel dot `view_people.dart:535-570`; doctor `palette`+`paletteRuntime` sections in-process | ONE merged read model (palette entry × bound × health status/code/detail × primary × ladder next-rung) and a chrome surface for it ("Models" section of the status edge / settings-as-view). No new harness verb needed. Suggested app MCP tool: `world_palette_state` (none of the ~57 registered tools in `app_mcp_tools.dart` exposes palette+health) |
| **(b) Add/edit a ModelScope-compatible entry** | Nothing. Palette edits = hand-edit `~/xs/ecsai_harness/.xsoulspace/config.json` + credential into EnvConfig/shell + **daemon restart** — all REQUIRES-CLI. The app pane can already edit the *shape* (baseUrl/env-name/models) but for the wrong document | App-side: a palette editor over the `model_palette` JSON with the harness's own validation reused in-process (`parsePaletteConfig` is importable — the app already depends on `xsoulspace_agentic_host`), credential written to the EnvConfig GLOBAL flat file (`~/.config/xsoulspace/inference/config.json`), then a supervised daemon restart via the **already-built, unwired** `startSupervisedEcsaiDaemon`/`stopSupervisedEcsaiDaemon` (`supervised_world_io.dart:63,165`). Harness-side (later, cleaner): a write-protected owner verb (`palette op:propose/apply`) so the config edit + health-preserving restart is a world action, not a file race |
| **(c) Pick local MLX/AFM lanes** | Lane A backend picker covers afm/lfm/qwen in-process (`agent_doc_surface.dart:601-646`, `harness_host.dart:669-697`). Lane C: `actor_bind` (brainCast, palette-validated, `realm_actor_admin.dart:107-163`) and `task op:create modelId` (`durable_realm_tools.dart:895-903`) exist as verbs; `world_model_picker.dart` renders seat palette entries | Wire the picker to the CURRENT verbs: `actor_bind` for conversational actors, `modelId` on `task op:create` (extend `SupervisorAgentClient.admit` — it drops modelId today, `supervisor_agent_client.dart:196-208`), and delete the retired `resource_bind`/`task_delegate` path (`world_work_verbs.dart:257-302`). Local-lane honesty: surface `not_downloaded` health + the weights-cache fact (the runtime never downloads) instead of a dead toggle |
| **(d) Cached-token / health signals** | Journal rows `tool_loop_telemetry` (prompt/cached/completion tokens, rounds, stalled — `realm_actor_tool_loop.dart:1023-1060`); doctor cached-% render (`ecsai_doctor.dart:944-974`); orient degraded line (`harness_context_tools.dart:31-59`); health file | An app read of `tool_loop_telemetry` (the store handle exists) rendered per actor/rung on the task rows and the Models surface (cache-hit %, last dispatch, stalled count). No harness change needed; a `task op:show` receipt already carries terminal state for verdict rows |

Verification loop (all phases): the `fmtk` toolkit (`~/mcp/cline/mcp_flutter`)
verbs `get_screenshots{flutter_layer}`, `hot_reload_and_capture`,
`semantic_snapshot`+`tap_widget` (blocked by redesign D2 until Phase 2),
per redesign §0 — no OS automation.

---

## 3. Gap list, ranked by owner value

**G1 — Task execution is CLI-armed (harness owner).** The durable lane's only
claimant is `realm_actor` under `realm_scheduler`, and nothing arms either:
a `task op:create` from the app sits `queued` forever (no scheduler process
runs now; the daemon composes palette bindings but no runner — §1 C7).
Highest-value fix: arm a bounded scheduler lane inside the composed daemon
(it already holds the bindings, the per-project palette cache and the
escalation ladder — `daemon_actor_loops.dart:897-923`), or have the app's
supervised-world adapter declare `ecsai-scheduler` as a SECOND oka component
next to `ecsai-daemon` (`supervised_world_io.dart:96-134` is the template).
*Acceptance:* from a cold machine, the app arms the world (G2), a `task
op:create` reaches `succeeded/failed` terminal with the frozen check run,
with zero shell commands; `ecsai --status` and the app agree.

**G2 — Daemon arming has no click (app owner).** `startSupervisedEcsaiDaemon`
exists, complete with readiness gate and restart budget, and has zero
callers; the shipped surfaces only print "arm `ecsaid --serve`"
(`world_inspector_pane.dart:555`). The redesign already routes this into the
status edge as a one-click action (§2.2 item 3, Phase 3). *Acceptance:*
status edge shows daemon reachability from the doctor truth
(`supervised_world_io.dart:249-258`); one click converges a dead daemon to
live (and says `alreadyRunning` honestly); a failed converge renders the
findings, never a spinner.

**G3 — The app delegates onto the FAILED primary (app owner).**
`HarnessWorldAgentClient.admit` sends no `modelId`, so `_taskCreate` defaults
to the primary generative entry (`durable_realm_tools.dart:895-903`) —
today `openrouter_deepseek`, which `palette_health.json` marks
`failed(transport_http_403)`. Every app-initiated task is pre-destined to
burn its escalation ladder. *Acceptance:* the delegate surface shows the
rung it will use (health-dot included) and lets the human pick any bound
generative entry; `modelId` rides `task op:create`; a degraded primary is
visible BEFORE the send, not after the terminal.

**G4 — The world-inspector work verbs are retired (app owner).**
`resource_bind`/`task_delegate` (`world_work_verbs.dart:257-302`) answer
with the ADR 0118 migration map (`harness_participation_tools.dart:1220-1238`),
and `_delegateViaSeat` calls an app-MCP name (`agent_task_delegate`) over a
seat catalog that never carried it (`world_inspector_pane.dart:360-366`).
The one human "delegate to ecsai" button in the shipped app is dead.
*Acceptance:* the inspector's delegate/bind rungs call `task op:create`
(with modelId) and `actor_bind`; a bounce renders the harness code verbatim
(the receipt shape `WorldWorkReceipt` already keeps it); a scripted seat
scenario exercises create→show→say.

**G5 — No Models surface: rungs, health, ladder, cache (app owner).** The
read models all exist (§2.3a/d) but no chrome merges them; health is a
per-actor dot in People, spend/verdict rows are Settings ListTiles for the
WRONG board (app mesh, not harness tasks — `mesh_tasks_settings_page.dart`).
*Acceptance:* one surface (Phase 3 landing inbox + Models section) lists
every cast entry with bound/primary/health/code/detail, the escalation
next-rung, last-dispatch cache-hit % from `tool_loop_telemetry`, and open
tasks with state/verdict/spend; an app MCP tool `world_palette_state`
mirrors it (tool = acceptance mirror law, redesign §2.3).

**G6 — ModelScope is unreachable from the app's own brains (app owner,
medium value).** `actor_brain.dart` resolves only `local:*` and
`openrouter:*` (:214-257); the in-app bot host therefore cannot speak the
healthy rungs. Two options: extend the brainRef grammar with a
palette-entry form (`cast:modelscope_qwen38max`) resolved against the seat
palette, or (cheaper, law-cleaner) stop running bot brains in-app when the
daemon's actor loops are armed — the daemon already drives `brainCast`
actors on ModelScope bindings (`daemon_actor_loops.dart:648-653`,
`afm/bin/ecsai.dart:420-515`) and `actor_bind` is a seat verb. *Acceptance:*
a roster actor bound to `modelscope_qwen38max` answers an addressed beat,
and the app's dispatcher does not double-answer it.

**G7 — Palette/credential edits are external-file surgery (harness owner,
then app owner).** Adding a rung = edit the configurationRoot's
`config.json`, put the credential where a GUI-spawned process can read it
(EnvConfig global, not `~/.zshenv`), restart the daemon. The parse/validate
logic is importable (`parsePaletteConfig`), the restart is G2's converge,
and the app pane already knows the field shapes (`ProviderConfig` ≈
`PaletteProviderConfig` minus transport/role). *Acceptance (app-side first
step):* the pane edits a ModelScope-shaped entry against the REAL palette
document with harness-grade named refusals, writes the key to the EnvConfig
global file, and offers "restart world" (G2) — no hand-editing, no shell.
*Acceptance (harness follow-up):* an owner-only `palette` propose/apply verb
makes the edit a journal-recorded world action with health-preserving
restart, so two editors cannot race the file.

**G8 — No permission inbox / change view for Lane C (app owner, Phase 3
scope).** The durable lane's human gates are the frozen check and the
review write gate inside the executor; the app renders neither, and
`ProductCodingChangeView` is Lane-A-only. Phase 3's permission inbox +
Boards↔mesh-task merge is the designated home (redesign §2.2). *Acceptance:*
a Lane-C task's diff/verdict/spend renders as a board card with the frozen
check's command and result, and the landing inbox counts it in the attention
line.

---

## 4. Proposed "first session" script (Phase 3, day one)

The exact sequence the owner should be able to perform **in the redesigned
shell**, with the prerequisite phase in brackets. Shell loop discipline per
redesign §0 (`fmtk` captures, no OS automation).

1. **Open the app → land on the Conversations inbox.** Status edge reads:
   `world: live · primary: modelscope_qwen38max · attention: 0` — or, when
   the daemon is down, one honest line + **[Arm world]** button
   [Phase 1: status edge + shell skeleton; Phase 3: arm action; G2 wires
   `startSupervisedEcsaiDaemon`].
2. **Click [Arm world]** (first run only). Converge runs; the edge flips to
   live without a terminal [G2; harness lifecycle already supports it —
   `ecsai_lifecycle.dart:56-122`].
3. **Open the Models section** (status-edge click or ⌘K). See the 11 rungs:
   4× `modelscope_*` (health ok), `openrouter_deepseek` (failed:
   transport_http_403 — with the daemon's fix hint), local `qwen`/`lfm`
   (ok, or `not_downloaded` + weights fact), `apple_foundation_afm`,
   decision rungs; ladder arrows from `realm_actor_escalation`
   [G5; reads `actions.modelPalette` + `palette_health.json` + global config].
4. **Promote the healthy rung:** set `modelscope_qwen38max` primary (or, on
   day one minimal, pick it per-task in step 6). Save → validate with the
   harness parser → **[Restart world]** → health file re-reads ok
   [G7 first step + G2; the full in-app palette editor is G7].
5. **Open the Documents view → New agent doc → bind workspace
   `/Users/antonio/xs/storage_problem/last_answer`.** Human click path for
   what `agent_doc_create`/`agent_doc_bind` do for agents
   [Phase 3: Documents view; tools exist at `agent_mcp_tools.dart:261,299`].
6. **Delegate a code task:** type the sentence, pick rung
   `modelscope_qwen38max` (picker shows health dots), send. The task is
   `task op:create` with `modelId`, addressee = the bound actor; the row
   appears in the Boards/landing inbox with `queued → running` and the
   frozen check named (`fvm flutter analyze`) [G3 + G4; Phase 3 Boards merge;
   G1 makes it actually execute without a shell].
7. **Watch spend + cache:** the task row accrues rounds/tokens/cached %
   from `tool_loop_telemetry`; a stall shows the ladder promotion
   (`→ modelscope_qwen38max → …`) as data [G5d; Phase 3].
8. **Answer attention:** if the run raises a permission (Lane-A-style docs
   lane, or a claim conflict), the landing inbox shows it reject-first; one
   decision per screen [Phase 3 permission inbox; today only inside the open
   doc, `agent_doc_surface.dart:~2605`].
9. **Read the verdict:** `succeeded` + check output + spend on the card;
   open the change view for the diff; **Apply** lands the edit (Lane A) or
   shows the already-applied workspace diff with the check result (Lane C)
   [Phase 3; G8 for the Lane-C change view].
10. **Close the loop honestly:** the card keeps the terminal record
    (`task op:show` truth — "creation receipt is not a completion",
    `supervisor_agent_client.dart:8-13`); a failed check re-delegates with
    one guidance post (`task op:say`) [verbs exist; surface is Phase 3].

Prerequisite map: steps 1-2 → Phase 1 (edge) + G2; step 3 → G5 (can ship
as a Phase 1.5 settings pane before the shell grammar exists); step 4 → G7;
step 5 → Phase 3 Documents; steps 6-10 → Phase 3 Boards/inbox + G1/G3/G4.
Phase 2 (semantics/keyboard) is what makes the whole script **agent-verifiable**
(`semantic_snapshot` + `tap_widget` acceptance, redesign §2.3) — every surface
above ships with a widget-key/Semantics name from day one.

### Non-goals kept

No palette write verb is required for day one (file + validation + restart
suffices; the verb is the clean follow-up). No remote/mesh transport, no
external ACP operator, no weights downloader (the runtime-never-downloads
law stays an explicit owner call, not a silent gap).
