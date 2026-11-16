# Wave N — actor equality, four-class lanes, dynamic model config, human self-profile, task honesty

## Context

Owner review of the live shell (2026-11-15) named six product laws the current build violates:
1. **Actor equality** — a model-based actor is still an actor: every actor must be editable. Today daemon-minted actors (`actor_ensure`, `realm_actors` row carries only `brainCast`) are skipped by roster adoption (`realm_chat_service.dart:369-370` skips rows without `brainRef`), so their `actor:<id>` surface renders "no roster profile" read-only (`actor_info_surface.dart:88-98`).
2. **Lane taxonomy** — there is no such product thing as "builtin jev": the world has four lane classes (remote providers; direct subscription providers like ChatGPT; local servers like ollama; on-device built-in services like AFM/laya/MLX-qwen). Today three pickers speak three vocabularies (palette wire names, `local:/openrouter:/cast:` refs, runtime chips) and `jev` reads as a lane instead of an actor bound to the remote openrouter lane.
3. **DM symmetry** — human ↔ model actor DMs must work both ways. The dispatch substrate is already DM-symmetric (addressedTo-only fan-out in both planes: `realm_bot_host.dart:436-443`, `daemon_actor_loops.dart:1230-1236`; no thread-shape filter), but daemon-minted actors are not DM-able (roster skip + DM picker lists roster only, `create_flows.dart:37-40`) and `cast:`-brainRef actors are a black hole while the daemon lives (LA defers at `realm_bot_host.dart:261`, daemon binds only `brainCast` at `daemon_actor_loops.dart:689-695`, LA never writes it).
4. **Full actor management** — reasoning level, model, profile, name, avatar, add/remove, permissions. Missing today: per-actor reasoning (no schema anywhere; LA's in-app brain even DROPS the declared per-model `reasoning_effort` at `actor_brain.dart:580-627`), avatar (pure derivation, no field, `actor_avatar.dart:29-92`), add/remove entry points outside Settings, retire never wired (harness verb ships unused, `realm_actor_admin.dart:172-204`).
5. **Human self-profile** — one human actor on this machine, manageable (name/avatar/profile). Today Settings skips the human row (`actors_panel.dart:99-100`) and there is no discoverable "my profile" entry.
6. **Task honesty** — the inbox's "Running tasks" rows are `queued` durable-task rows that never drain (no scheduler: arm refuses `daemon_artifact_absent`; creation is not a wake, `scout-task-create-wake.md`; no queued TTL, `durable_task_queue.dart:830-866` touches only leased/started), never appear on Boards (ADR 0140 `realm_board_feed.dart` landed unwired), and rows are inert (`landing_inbox.dart:322-372` has no tap, no cancel).

Owner decisions taken via questions: **four class sections** in the Models catalog; **glyph/emoji avatars** (channel-icon law); and for reasoning/config: **the model editor must represent whatever config a model/provider actually has** — a growing, per-model/per-provider heterogeneous list — ZCode/ComfyUI-style dynamic typed config, not a fixed five-field form.

Collision law unchanged: LA edits neither harness nor ecsly; gaps are filed to `surface_gaps.md`.

## Waves (steward verifies + commits each; one fvm command at a time)

### N1 — actor equality + DM symmetry (LA-only)
- `realm_chat_service.dart` roster adoption (:367-386): adopt `realm_actors` rows that carry `brainCast` but no `brainRef` — synthesize the roster profile with `brainRef: 'cast:<cast>'` + the row's displayName/role/systemPrompt, so daemon-minted actors become editable and DM-able. Keep the skip for rows with neither.
- `realm_world.dart registerActor` (:406-455): when the profile's brain is a `cast:` ref, also write the durable `brainCast` through the existing `actor_bind` wrap pattern (`world_work_verbs.dart:265-268`) so the daemon plane binds what LA edited (closes the black hole).
- DM picker (`create_flows.dart:37-40`) lists world actors (roster ∪ adopted), not roster-only.
- `actor_info_surface.dart`: add a **Message** verb (header) → `service.openDm(actorId)` + route `dm:<id>`; add **Remove/retire** with a confirm dialog → `removeActor` + harness `actor_retire` via the participation lane (grantAccess pattern, `realm_chat_service.dart:1242-1264`).
- People view rows (`view_people.dart:250-252`): Message verb beside the existing edit route.
- Add-actor entry point: "New actor" verb on People view + actor surface opening the existing `_CreateActorForm` pattern (`actors_panel.dart:261-399`) with a kind choice (model/agent), reusing `createActor` (:478).
- Tests: adoption of a brainCast-only fixture row (editable + DM-able), brainCast write on cast-brain save, retire refusal naming.

### N2 — actor editor completion: avatars + per-actor reasoning + the dropped-reasoning bug
- **Avatar field** (glyph/emoji, channel-icon law from `ChannelInfo.icon`): `ActorProfile.avatar` (String?, tolerant read like `archived`), `updateActor(avatar:)`, re-register carries it; `ActorAvatar` renders named-glyph hit → Icon, else raw emoji Text, else today's derivation; editor gets the preset glyph grid + one-emoji field dialog (copy the rooms-column change-icon dialog); applies to model actors AND the human.
- **brainRef grammar** (`actor_roster.dart:142-162`, `actor_brain.dart:114-155`): add `reasoning=<tier>` param valid on ANY brain base (local/openrouter/cast); `buildLocalBrainRef` keeps carrying parsed `lora`/`loraScale` (today silently dropped at `actor_profile_editor.dart:114-118`).
- **Per-actor reasoning picker** in `ActorProfileEditor`: tiers from `kReasoningEffortTiers` resolved by the brain's lane class (`palette_lanes.dart` + transport of the cast/openrouter target); honest absence note for on-device brains; writes the grammar param. Daemon-lane note: "daemon dispatch reads reasoning per-model until the harness ask lands".
- **Fix the drop**: `PaletteCastBrain._renderRequest` (`actor_brain.dart:580-627`) carries `reasoningEffort` + `includeReasoning` (from the grammar param, else the palette decl) into `InferenceRequest` (fields exist, `inference_models.dart:98-131`); same for the openrouter brain path.
- Tests: grammar round-trip (reasoning+lora), avatar round-trip + render override, in-app dispatch wire carries declared effort (recording-client test in the actor_brain test file).

### N3 — human self-profile
- Settings gains a **"Your profile"** tile (registry pattern in `general_settings_view.dart`) routing to `actor:<humanId>` (human has a roster profile, so the N2-completed editor + avatar work as-is); tile shows current name + avatar.
- `actors_panel.dart`: list the human row labelled "you" (read-only brain column, editable via the surface) instead of skipping (:99-100).
- Heals untouched (`realm_chat_service.dart:394-428`).

### N4 — Models: four class sections + dynamic schema-driven config editor
- `palette_lanes.dart` grows the class map: `LaneClass { remote, localServer, subscription, onDevice }`; declared providers classify by transport + loopback `base_url` detection (`http://127.…/localhost` = localServer, the harness loopback allowance `palette_config.dart:650-676`); builtins map on-device except hostedOpenRouter → remote; ChatGPT = subscription (state from `ChatGptSubscriptionController`).
- `catalog_lens.dart` rebuilds the table as FOUR sections in the owner's vocabulary (remote providers nested inside; local-server rows chip `loopback`; subscription section shows ChatGPT sign-in state + honest absence of qwen/grok lanes; on-device section lists AFM/laya/MLX with `device_capabilities.dart` probe facts + palette_health); bindings rows chip the CLASS (`remote/loopback/subscription/on-device`) replacing the wave-M family chips (mirror stays internal); brain picker labels (`actor_brain.dart:366-398`) read by class. `jev` renders as an actor-bound remote row — no `builtin`/`open_router` vocabulary in UI.
- **Dynamic config editor (ZCode/ComfyUI law)**: the model form becomes a settings-row list over the model map: one row per declared key with a typed control from a per-transport SCHEMA MIRROR (`max_tokens`/`max_output_tokens` int fields, `reasoning_effort` tier picker titled per class, `include_reasoning` toggle, `capabilities.*` boolean sub-rows); an **add-setting** row offers schema keys not yet declared for that transport PLUS a free mono key field; every row removable. Keys outside the mirror ride the document verbatim with a quiet `unconsumed` marker (the parser tolerates unknown model keys — verified `palette_config.dart:440-486` — but no lane reads them: honesty marker, never a fake control). Row chips summarize declared config (`reasoning High · incl`, `ctx 32768`, caps count).
- Tests: class-section grouping (loopback provider lands in local-server), dynamic editor add/remove/free-key + unconsumed marker, tier picker per class, bindings class chips.

### N5 — task honesty: details, cancel, honest queue state
- `landing_inbox.dart _TaskRow` (:322-372) becomes tappable (`ShellRow` like `_ThreadRow`) → **task detail** panel/dialog: full sentence, state + timeline (admitted/lease/started/settled from the journal row), modelId, addressees, terminal summary/reason, and the event tail via `task {op:'events'}` — invoked through the existing allowlisted seat-call pattern (`supervisor_agent_client.dart:185-277` `HarnessWorldAgentClient._invoke`, reused for a new `WorldStateService.taskDetail/taskEvents/taskCancel` trio).
- Per-row **Cancel** on non-terminal rows (`task {op:'cancel'}`, harness authority `durable_realm_tools.dart:706-710`) with confirm; this is also the owner's route to clear the rehearsal residue.
- Honest state: section title "Queued & running"; a `queued` row while `!world.daemonLive` carries the reason line "waiting for a scheduler — arm the world" (arm row already above); state word stays the queue's own.
- Boards cross-link: a chip on the Boards face naming the durable-queue count → routes to the inbox (the ADR 0140 fold stays a harness ask).
- Tests: row tap opens detail with verbatim journal facts; cancel verb refusal renders verbatim; queued-reason line gated on daemonLive.

### N6 — cross-cutting
- l10n ×7 (arb trio + four mirrors, hand-mirrored; cross-check now `json.load`-parses) for class names, Message/New actor/Remove/confirm, avatar dialog, reasoning picker note, settings-row verbs, task detail/cancel/queue-reason.
- Harness `surface_gaps.md` asks (file, never edit): (4) per-actor `generationOptions` on `realm_actors` + daemon dispatch read (the daemon lane for the N2 picker); (5) wire the ADR 0140 `realm_board_feed` fold into the daemon cadence so queued tasks reach Boards; (6) an actor-grant **revoke** verb (both project grants and thread-join consents today have approve-only surfaces).
- Docs: design doc §9 (wave N record + the four-class law + dynamic-config law), DESIGN.md amendment line, skill bullets (actor equality, class taxonomy, dynamic config honesty, task-detail lane).
- Per wave: named tests green + `fvm flutter analyze` clean on touched files; after N5: full suite; live fmtk proofs (evidence law): akio-steward-style daemon-minted actor editable + DM round-trip, four-class catalog + dynamic config editor screenshots, task detail + one residue cancel.

## Verification
- N1: adoption/DM/retire widget tests over the hermetic machine (brainCast-only fixture row).
- N2: grammar/avatar/wire tests (recording inference client asserts `reasoning_effort` on the wire).
- N3: settings tile routes to the human surface; name+avatar persist through updateActor.
- N4: class grouping + dynamic editor tests; live screenshots of all four sections and the editor on the openrouter deepseek row.
- N5: detail/cancel tests; live: open detail on a stuck `ADR 0118 fixture task` row, cancel it, watch the inbox drop it.
- Full suite + analyze + l10n parse cross-check; commits scoped per wave (never sweep concurrent edits); harness asks committed in the harness repo alone.