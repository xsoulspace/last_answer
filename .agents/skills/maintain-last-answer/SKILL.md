---
name: maintain-last-answer
description: Maintain and verify the Last Answer app — build/test/analyze commands, storage backends (localDb, filesystem, git offline, GitHub), MCP agent-driven testing without UI, and Maestro e2e. Use when a repo agent needs to run checks, add features safely, debug the app, or test storage replication/sync.
license: PolyForm Noncommercial 1.0.0
type: maintenance
metadata:
  author: last-answer
  version: "1.0.0"
  category: app-maintenance
paths:
  - "lib/**"
  - "test/**"
  - "tool/**"
  - "e2e/**"
  - "packages/core/**"
---

# Maintain Last Answer

Operational guide for AI agents maintaining this Flutter app.

## Core commands

```bash
just gen                  # build_runner codegen (run after model changes)
just fix                  # fvm dart fix --apply
fvm flutter analyze
fvm flutter test          # NOTE: test/parsers/hive_parser_test.dart may fail on clean HEAD (pre-existing)
```

Never hand-edit `*.g.dart` / `*.freezed.dart`. **Localization lives in the `packages/la_locale` workspace package** (extracted 2026-11-19; intl_utils + the `flutter_intl:` config in core are RETIRED — never resurrect them). The only hand-edited l10n sources are the three arbs `packages/la_locale/lib/src/l10n/intl_{en,it,ru}.arb`: add every new user-facing key to all three with real IT/RU translations, then run `just gen-l10n` (→ `fvm flutter gen-l10n` in packages/la_locale, regenerating `lib/src/generated/{S,S_en,S_it,S_ru}.dart`). The generated files are NEVER hand-edited — key drift between arbs and code is now structurally impossible, and gen-l10n reports missing translations into `packages/la_locale/lib/src/l10n/untranslated.txt` when a locale lacks a key. Still validate arb JSON parses (`json.load`) before committing — the 11-14 wave left invalid JSON and substring checks passed it.

## Architecture law (docs/ARCHITECTURE.md — the winning contract)

The folder map + naming grammar live in [docs/ARCHITECTURE.md](../../../docs/ARCHITECTURE.md); where another doc disagrees about code organization, that file wins. AS-BUILT 2026-11-19 (the folder-grammar restructure landed):

- **lib/ root = the grammar**: realm backend at ROOT (owner law, no wrapper): `data_journal/` (journal services + mesh durability), `ecs_world/` (the ONE ecsly World; anatomy-named files: world.dart, world_components.dart, world_feed.dart, creatures.dart, creature_mark.dart), `ui_chat/` (the chat experience domain), `ecs_plugins/{boards,conversation,scene,world_sync}` (per-plugin ecsly integrations), `data_agents/{harness,acp,subscriptions,supervised,meaning,product,config,project_operations}` (the agent APIs = data_remote_api analog). UI domains: `ui_root, ui_shell, ui_models(+agent_config), ui_settings, ui_automations, ui_documents, ui_browser, ui_workbench, ui_inspector, ui_boards, ui_paywall, ui_onboarding, ui_workspaces`. Facilities: `mcp/`, `crash/`, `entitlement/`. Frozen: `ui_legacy/{home,idea,note,legacy_kit}`. `lib/coding_agent.dart` is a re-export barrel only — new code NEVER imports it.
- **State placement — no `data_states/` folder, ever** (owner law): with ecsly + ecsly_flutter, resources/commands ARE the state layer. World state = ecsly resources/components in `world/`; app-global runtime state = providers owned by their domain folder, exposed via that domain's barrel; cross-domain state moves to the backend folders, never into another UI domain.
- **Birth law**: new surface = new `ui_<name>/` folder + `{DOMAIN}_KNOWLEDGE.md` + one row in the surface registry (`lib/ui_shell/surfaces.dart`); new backend capability = a file in its root subject + knowledge entry; cross-domain orchestration lives at the layer root, never inside a domain folder.
- **Direction laws**: features never import `ui_shell/` internals (registry is the manifest); UI domains share data only via the backend folders; `headless_core` stays Flutter-free; kernel `package:ecsly` imports ONLY in `ecs_world/` + `ecs_plugins/`; `ecsly_flutter` selector reads are legal in any widget code.
- **Known inversion named in ARCHITECTURE.md §1**: `world/world_feed.dart` + `world_components.dart` import `journal/world_state_service.dart` — fix via an interface, don't add more of the same shape.

## Shell (realm chat) architecture

- `lib/shell/app_shell.dart` owns ONE layout document: `ShellLayout` v4 (pane groups of tab strips, persisted `shell.views.v4`) + the `shell.rooms.docked` bool (default TRUE). Two projections of that one document: **chat-first** (docked rooms column; conversation ids `dm:`/`channel:`/`room:`/`conversations` route to group 0, view ids split right; closing group 0's last tab lands on the world face) and **workspace** (column hidden; byte-identical v4). The rail is THREE buttons: `rail.search` (⌘K palette), `rail.actors` (docks the column, carries the total unread badge), `rail.settings`.
- `lib/shell/rooms_column.dart` — the docked column: DMs/Channels/Rooms sections over `RealmChatService` projections, per-row LaWorld unread badges, create/rename/close/setIcon channel management, miniwindow context verb, kind tooltips. It is chrome: never a tab, never a surface (DESIGN.md v4). The macOS lights gutter rides the RAIL (`rail.lightsGutter` in action_bar), never the column or strip heads.
- `lib/shell/surfaces.dart` — the surface registry (`conversations`, `browser`(+`:n` instances), `filesystem`, `people`, `boards`, `threads`, `terminal`, `inspector`, `documents`, `models`, `settings`) + dynamic families `doc:<id>` and `actor:<id>` (the editable actor-info surface: profile editor + grants + channel memberships); conversation ids resolve through it.
- `lib/coding_agent/realm_chat/realm_chat_service.dart` — the verbs everything rides: `channels`/`createChannel`/`renameChannel`/`closeChannel`/`setChannelIcon` (close ARCHIVES, never destroys — the journal is authority), `say(text, {replyTo, addressedTo})` (mentions narrow the addressees; null = all participants), `refreshWorkThreads()`, `ensureSeededChannel()` + `firstRunSeedEnabled` (first-entry `#general` seed, shell-called at boot, never inside `ensureReady`), work-thread spawn (ADR 0129 seals), grant verbs thin over host exports.
- Composer anatomy (v4): `worldchat.attach` opens ONE filtered mention/attach list (actors/channels/rooms/docs + honest-absent plugins/MCP); the ADR 0129 scope-arm lives INSIDE it as the Work order row; channel rooms get a meta row `worldchat.meta.{perms,members,info}`; `@partial` opens `worldchat.mentionOverlay`; beats carry a hover cluster `worldchat.beat.{reply,edit,thread,menu}.<threadId>#<n>` with edit/delete honest-disabled (journal append-only — harness verbs gap-filed in surface_gaps); child threads are ONE level (`WorkThreadLink.parentThreadId` → ROOT).
- Models surface v2 (2026-11-14, DESIGN v5): `lib/shell/models/` — THREE lenses over ONE palette document: `catalog_lens` (nested provider → model spreadsheet table; verbs on the owning row; inline forms over the FULL schema `max_tokens/max_output_tokens/reasoning_effort/include_reasoning/capabilities`; `models.json.*` raw-document lane), `bindings_lens` (editable cast ladder: `models.cast.<id>.{up,down,primary}` over the candidate; row tap stays the SESSION `selectRung` override; actor chips join `service.brainCasts`), `observe_lens` (daemon card + process verbs, verbatim per-rung health ledger, dispatch ledger keyed by MODEL with `unbound` grouping, restart-pending banner). ONE widget-free `PaletteCandidateModel` ChangeNotifier owns the in-memory candidate + verbs + structured refusals (`emptyId/duplicateProvider/duplicateModel/idImmutable/providerInUse/modelInUse/jsonInvalid/badNumber/noSeat`, refs name the blocking cast rows); lenses render it, `PaletteDirtyBar` lands propose → receipt → apply (owner-only verb, recovery verbatim). NO tier gate on the surface (single-gate law). Keys: `models.lens.{catalog,bindings,observe}`, `models.provider.<id>`, `models.model.<p>.<m>`, `models.rung.<id>`, `models.health.<id>`, `models.ledger.<cast|unbound>.<actor>`, `models.restartPending`. BOUNDED-LOOSE LAW: content-sized chrome (pills/chips/buttons) sizes through PADDING — Center/Align expand to the incoming max width inside a Wrap or Row and stretch every pill to the pane (live-caught via `fmt_inspect_widget_at_point`, 2026-11-15). PANE-WIDTH LAW: rows compress by their own width (LayoutBuilder <420px), window <640px only sets the default. LANE-TRUTH LAW (2026-11-15): `builtin` on a cast entry means "composition-root-owned binding", NOT local — the family mirror lives in `lib/coding_agent/realm_chat/palette_lanes.dart` (lfm/qwen local MLX, laya local decision, apple_foundation_afm = `afm`, jev/open_router = HOSTED open_router; unknown builtin renders `builtin`, never a guessed lane); `WorldRung.isLocal` = on-device family. ZED REASONING LAW: reasoning controls are a lane CAPABILITY — `kReasoningEffortTiers` per transport (mirrored from the clients' `supportedReasoningEfforts`); a lane with no tiers gets an honest absence note, not a disabled picker (a declaration there refuses at dispatch as `reasoning_effort_unsupported`); tiers render titled (Low/…/Extra High), row chips title the declared tier. L10N CROSS-CHECK LAW: key validation PARSES the arbs (`json.load`), never greps — the 11-14 wave left the arb trio invalid JSON (missing commas after `@key` lines) and substring checks passed it; since the l10n extraction the generated classes come from the arbs, so key drift is structural-impossible and the check is about arb JSON validity.

- Wave N laws (2026-11-16): ACTOR EQUALITY — roster adoption takes brainCast-only rows (synthesized `cast:` ref), registerActor writes brainCast back for cast: brains, Message/Remove ride the actor surface (host retire verb first, bounce verbatim). FOUR LANE CLASSES — the Models surface speaks remote / loopback / subscription / on-device (palette_lanes.dart mirror + classOf*), never harness wire names or "builtin" in UI. DYNAMIC CONFIG EDITOR — the model form is a settings-row list over the model map (schema mirror per transport + free keys + unconsumed markers; candidate verb editModelSettings). TASK HONESTY — queued ≠ running; inbox rows tap open the durable detail (journal verbatim + control_task_events raw) and cancel through DurableTaskQueue.requestCancel; Boards cross-links the durable queue count (ADR 0140 feed unwired = harness ask).
- Live iteration: debug-only `shell_*` fmtk tools (`shell_state|toggle_dock|open_tab|close_tab|split_active|select_room`) over `ShellDebugBridge` (mounted shell assigns, dispose nulls; tools refuse `shell_bridge_absent`). The live semantics walker dropping rail/rooms nodes is a KNOWN framework gap — the test-lane contract (`rail_sem_probe_test`) is the authority. Evidence law: flutter-native fmtk `view_screenshots` ONLY; OS-AX/computer-use driving crashed the app (2026-11-10), never again.
- Widget keys ARE the agent's UI contract (DESIGN §6): `rail.*`, `rooms.*`, `view.tab.*`, `worldchat.*`, `board.*`; `test/shell/rail_sem_probe_test.dart` snapshots the semantics contract — update it with any chrome change.

### Shell test lane (paid-for laws)

- Hermetic worlds: `RealmWorld.open(rootOverride: tempDir)` + `RealmWorld.debugDeviceHome` pin in setUp, released in tearDown; services are REAL (final class — no fakes), injected into `AppShell(service:)`.
- Real IO (registry/store) never completes under fake async: wrap drains in `tester.runAsync`, but NEVER with a live animation ticker (popup-menu exit, cursor blink) — settle (`pumpAndSettle`) before the runAsync window or the fake clock poisons (`elapsed < 0`).
- Popup menus (`showMenu`) animate in: `pumpAndSettle` after the secondary tap before tapping menu items.
- Dialogs own their controllers: a `TextEditingController` disposed when `showDialog` returns is used-after-dispose by the route's exit animation — the dialog's State must own it.
- A focused composer holds a scheduler performance mode: unfocus + settle at the end of any test that leaves focus in a TextField.
- `flutter_animate`'s mounted-then-disposed `Animate` leaves a zero-delay timer its dispose only ignores: tick the fake clock (`pump(1ms)`) after the mount frame.
- The shell disposes ONLY the service it creates itself (DI-provided services belong to `GlobalStatesProvider`); an owned service's journal debounce timer must not outlive the tree.
- Teardown ownership is ONCE: the creation-time `addTearDown` owns the service dispose and the temp dir; a fixture holder object must NOT dispose/delete again (double-dispose and PathNotFoundException tears, paid 2026-11-10).
- `debugDefaultTargetPlatformOverride` must be reset in a `finally` INSIDE the test body — the binding's foundation-vars invariant runs BEFORE tearDowns (addTearDown reset is too late).
- A multi-line arrow body SWALLOWS the cascade sections written under it (`..field = () => x\n..next = y` parses `..next` into the arrow): use block bodies in any cascade chain of closures.
- Hermetic external beats: the journal watch keys on FLUSHES a test append may never reach; poll `service.beatsFor` (pure journal read) in runAsync, then refresh the pane's cached projection via a `selectThread` toggle through a DIFFERENT thread (same-id select is a no-op) before the fake clock takes over.
- `openDm(actor)` on a CHANNEL MEMBER resolves to the channel thread (a two-participant thread IS its DM): fixtures needing a true DM must use a second actor outside the channel.
- Post-mount resizes need `tester.view.physicalSize` + `devicePixelRatio` (+ `addTearDown(tester.view.reset)`): `binding.setSurfaceSize` only seeds the FIRST frame, so a resize after mount never reaches MediaQuery (paid 2026-11-15 in the models compact-law test).
- Nested tables hide child verbs one level down: a test that taps a child-row verb must expand the parent row first (tap the parent key, pump) — `scrollUntilVisible` cannot find what the tree does not contain.

## Architecture map

- `lib/main_prod.dart` vs `lib/main.dart` — prod entry vs debug entry (the latter wires `MCPToolkitBinding`, debug-only).
- App wiring: `lib/other/last_answer_app.dart` → `GlobalStatesProvider` (packages/core, all repos/notifiers) → `GlobalStatesInitializer.onLoad()` (DB init, user load).
- Settings is a ONE-SCROLL section registry: `lib/settings/settings_screen.dart` renders `SettingsSection`s declared in `lib/settings/settings_sections.dart` (You / Appearance / Notes / Data & sync / Agents …) with a scroll-spy TOC + jump filter — no endless tabs; add a section there, not a new tab. App services that are domains, not settings, live in their own surface folder (`lib/automations/` since 2026-11-19: supervisor agent client/provider/execution/service + panel/view + the rail.automations surface; deleted files: `general_settings_view.dart`, `agent_settings_view.dart`, `mesh_tasks_settings_page.dart`, `features/supervisor_*`).
- Storage backends: `lib/settings/features/storage_backends_state.dart` (`StorageBackendsNotifier`, singleton with static `payloadBuilder` / `restoreApplier` hooks) and `storage_backends_button.dart` (UI). Backends in fixed UX order: **localDb → filesystem → gitOffline → github**.
- Platform availability (`storage_backends_platform_{io,stub}.dart`, conditional on `dart.library.io`):

  | backend    | macOS/Win/Linux | web                |
  |------------|-----------------|--------------------|
  | localDb    | ✅              | ✅                 |
  | filesystem | ✅              | ❌ (no dart:io)    |
  | gitOffline | ✅ (needs real git, not xcrun shim) | ❌ (no Process) |
  | github     | ✅              | ✅ (PAT path)      |

  Unsupported tiles render disabled with "(not available on this platform)"; MCP `storage_state` reports `supportedBackends`; the smoke script auto-skips them. On web, dart:io throws `UnsupportedError` (an Error, not Exception) — always catch broadly around backend calls.
  - localDb = shared-prefs-backed live store (default, always on; not a replication target).
  - filesystem / gitOffline = optional copies via `universal_storage_filesystem` / `universal_storage_git_offline` (path deps in `../dart_flutter_packages/pkgs/…`; also listed under both `dependencies:` AND `dependency_overrides:` in pubspec).
  - github = driven separately by `GithubSyncNotifier` (OAuth device flow / PAT); never built through `StorageBackendsNotifier.buildService`.
- Replication payload = canonical `DbSaveModel.toJson()`, one file per backend: `last-answer-data.json`.

## Testing without the UI (MCP agent tooling)

Debug builds register MCP service extensions:

- Flutter toolkit (`snapshot create`, taps, screenshots): via `mcp_toolkit` in `lib/main.dart`.
- Custom storage tools: `lib/mcp/storage_mcp_tools.dart` → `storage_state|storage_select_backend|storage_set_path|storage_backup|storage_restore`.

Custom tools are NOT `fmtk exec --name <tool>` (that only takes built-ins).
Call them through the dynamic registry:

```bash
URI='ws://127.0.0.1:PORT/AUTH/ws'
fmtk exec --name fmt_client_tool --args "{\"toolName\":\"storage_state\",\"arguments\":{},\"connection\":{\"uri\":\"$URI\"}}"
fmtk exec --name fmt_list_client_tools_and_resources --args "{\"connection\":{\"uri\":\"$URI\"}}"  # list all
bash tool/mcp_storage_smoke.sh --uri "$URI"   # full backup/restore round-trip for fs+git, no UI
```

UI driving via semantic snapshots:
- Each `semantic_snapshot` assigns refs (`s_0`, `s_1`, …) in node order — the node `id` is NOT the ref.
- Refs go stale after every snapshot/tap; re-snapshot immediately before each tap and pass the matching integer `snapshotId`.

Notes learned the hard way:
- `MCPToolkitBinding.initialize()` must run AFTER `WidgetsFlutterBinding.ensureInitialized()` or startup crashes.
- Semantic navigation by route fails for Settings (it's inside HomeScreen's nested navigator, not a GoRouter route) — use snapshots + tap_widget.
- All of the above is tree-shaken from release builds (asserts + kDebugMode guards).

## Deterministic tests (no device needed)

- `test/storage/storage_backends_replication_test.dart` — replicate→restore round-trips, re-replication sync (v2 wins), selection persistence, payload hooks. Uses temp dirs; git offline tests can take ~seconds (real commits).
- GitHub e2e is gated behind `GITHUB_E2E=1` (needs human browser step). Maestro flow at `e2e/maestro/github_sync_settings.yaml` (iOS simulator only; macOS desktop unsupported by maestro).

## Pitfalls

- `dependency_overrides:` in pubspec contains many path overrides; direct imports ALSO need entries under `dependencies:` or `depend_on_referenced_packages` fires.
- iOS simulator builds: Crashlytics upload-symbols script phase must be guarded with a `PLATFORM_NAME == iphonesimulator` exit-0 check.
- macOS: App Sandbox was DISABLED (`com.apple.security.app-sandbox=false` in both `macos/Runner/*.entitlements`) because git-offline spawns `git` and filesystem-by-path writes outside the container — both are blocked by the sandbox (and `/usr/bin/git` is an xcrun shim that refuses to run sandboxed; Homebrew's real `/opt/homebrew/bin/git` works). If MAS distribution ever matters, this needs file pickers + security-scoped bookmarks + bundled libgit2 instead.
- Don't touch other agents' files when committing; an auto-commit "wip" process may sweep the working tree.
