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

Never hand-edit `*.g.dart` / `*.freezed.dart`. Update EN + IT + RU arb files together for user-facing strings (`packages/core/lib/src/l10n/intl_{en,it,ru}.arb`) AND the four hand-maintained mirrors `packages/core/lib/src/generated/intl/{S,S_en,S_it,S_ru}.dart` — every new key in all seven files, real IT/RU translations. NEVER run intl_utils/intl_utils:generate: it crashes on this repo's arb format at HEAD and rewrites `generated/l10n.dart` (+5k lines); if that file ever shows a diff, `git checkout --` it. Cross-check keys mechanically (script over arbs + mirrors) before committing.

## Shell (realm chat) architecture

- `lib/shell/app_shell.dart` owns ONE layout document: `ShellLayout` v4 (pane groups of tab strips, persisted `shell.views.v4`) + the `shell.rooms.docked` bool (default TRUE). Two projections of that one document: **chat-first** (docked rooms column; conversation ids `dm:`/`channel:`/`room:`/`conversations` route to group 0, view ids split right; closing group 0's last tab lands on the world face) and **workspace** (column hidden; byte-identical v4). The rail is THREE buttons: `rail.search` (⌘K palette), `rail.actors` (docks the column, carries the total unread badge), `rail.settings`.
- `lib/shell/rooms_column.dart` — the docked column: DMs/Channels/Rooms sections over `RealmChatService` projections, per-row LaWorld unread badges, create/rename/close channel management, miniwindow context verb, macOS lights gutter when docked. It is chrome: never a tab, never a surface (DESIGN.md v3).
- `lib/shell/surfaces.dart` — the surface registry (`conversations`, `browser`(+`:n` instances), `filesystem`, `people`, `boards`, `threads`, `terminal`, `inspector`, `documents`, `models`, `settings`); conversation and `doc:` ids resolve through it.
- `lib/coding_agent/realm_chat/realm_chat_service.dart` — the verbs everything rides: `channels`/`createChannel`/`renameChannel`/`closeChannel` (close ARCHIVES, never destroys — the journal is authority), `ensureSeededChannel()` + `firstRunSeedEnabled` (first-entry `#general` seed, shell-called at boot, never inside `ensureReady`), work-thread spawn (ADR 0129 seals), grant verbs thin over host exports.
- Widget keys ARE the agent's UI contract (DESIGN §6): `rail.*`, `rooms.*`, `view.tab.*`, `worldchat.*`, `board.*`; `test/shell/rail_sem_probe_test.dart` snapshots the semantics contract — update it with any chrome change.

### Shell test lane (paid-for laws)

- Hermetic worlds: `RealmWorld.open(rootOverride: tempDir)` + `RealmWorld.debugDeviceHome` pin in setUp, released in tearDown; services are REAL (final class — no fakes), injected into `AppShell(service:)`.
- Real IO (registry/store) never completes under fake async: wrap drains in `tester.runAsync`, but NEVER with a live animation ticker (popup-menu exit, cursor blink) — settle (`pumpAndSettle`) before the runAsync window or the fake clock poisons (`elapsed < 0`).
- Popup menus (`showMenu`) animate in: `pumpAndSettle` after the secondary tap before tapping menu items.
- Dialogs own their controllers: a `TextEditingController` disposed when `showDialog` returns is used-after-dispose by the route's exit animation — the dialog's State must own it.
- A focused composer holds a scheduler performance mode: unfocus + settle at the end of any test that leaves focus in a TextField.
- `flutter_animate`'s mounted-then-disposed `Animate` leaves a zero-delay timer its dispose only ignores: tick the fake clock (`pump(1ms)`) after the mount frame.
- The shell disposes ONLY the service it creates itself (DI-provided services belong to `GlobalStatesProvider`); an owned service's journal debounce timer must not outlive the tree.

## Architecture map

- `lib/main_prod.dart` vs `lib/main.dart` — prod entry vs debug entry (the latter wires `MCPToolkitBinding`, debug-only).
- App wiring: `lib/other/last_answer_app.dart` → `GlobalStatesProvider` (packages/core, all repos/notifiers) → `GlobalStatesInitializer.onLoad()` (DB init, user load).
- Settings UI lives in `lib/settings/features/*_button.dart` + `_state.dart`; tiles registered in `lib/settings/views/general_settings_view.dart`.
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
