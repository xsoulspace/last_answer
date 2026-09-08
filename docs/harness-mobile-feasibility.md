# Feasibility: agentic harness on mobile (Android/iOS) — sandboxed, user-picked folder

Task brief: `~/.pi/agent/squad/briefs/harness-mobile-feasibility.md`.
Investigated 2026-02 (tool-execution mode; all `file:line` refs below are
deterministic tool output from the named packages). Package roots (the brief's
paths were stale; actual locations):

- `xsoulspace_agentic_harness` → `/Users/antonio/xs/storage_problem/dart_flutter_packages/pkgs/xsoulspace_agentic_harness`
- `xsoulspace_agentic_host` → `.../pkgs/xsoulspace_agentic_host`
- `xsoulspace_agentic_workspace` → `.../pkgs/xsoulspace_agentic_workspace`
- `xsoulspace_inference_core` / `xsoulspace_inference_openrouter` / `xsoulspace_inference_apple_foundation` → `.../pkgs/...`
- App side → `last_answer/lib/coding_agent/`

## Verdict (critical read)

**Feasible on Android, conditionally.** The daemon itself is already
subprocess-free and in-process (`harness_embed.dart:1-3` — "no stdio, no
subprocess"), OpenRouter inference is pure `package:http`, and scripted mode is
LLM-free and process-free. **The hard blockers are all in the fs tier and the
verification tier**: the harness assumes a POSIX filesystem addressed by
absolute paths through `dart:io` (which an Android SAF-picked folder does not
provide), and the meaning profile's whole "verify and auto-revert" contract
executes `dart`/`git`/`flutter` binaries that do not exist on any phone. On
**iOS** it is additionally blocked at the OS level: no fork/exec for app
processes, so even the degrade paths that shell out must be compiled out; and
AFM's dylib bridge is macOS-only today.

## Q1 — Does the harness spawn subprocesses?

Yes. Every spawn site in `lib/` (non-benchmark), with the command it runs:

| Site | Command |
|---|---|
| `harness/lib/src/tools/fs_tools.dart:908` (`runTool`) | allowlisted user/workspace commands — default prefixes `dart analyze/test/run`, `flutter analyze/test` (`harness_acp_backend.dart:596-606`); the goal verifier grades THROUGH this tool (`build_gates.dart:280-298` — `runGoalVerifier` re-dispatches the spec command via the jailed `run` tool) |
| `harness/lib/src/tools/fs_tools.dart:496` (`gitStatusTool`) | `git status --porcelain=v1 -b` |
| `harness/lib/src/tools/fs_tools.dart:563` (`gitDiffTool`) | `git diff [--cached] [-- path]` |
| `harness/lib/src/meaning/vcs_meaning.dart:169` (`GitVcsAdapter._runGit`) | read-only `git` subcommands (`ensureReadOnlyGitCommand` jail, `vcs_meaning.dart:167`) |
| `harness/lib/src/tooling/problem_board.dart:163` | pack-declared repair `command` with `{span.file}`/`{span.line}` substitution |
| `harness/lib/src/tooling/problem_board.dart:185` | analyzer oracle re-run (`oracleBinary + oracleArgs + filePath`) |
| `harness/lib/src/tooling/ae_bridge.dart:41` | `ae artifact verify --pack <id> --json` (external AE CLI on PATH) |
| `workspace/lib/src/span_editor.dart:1165` | `dart analyze` (once-per-session baseline) |
| `workspace/lib/src/span_editor.dart:1255` | `dart analyze <touched files>` (per-move scoped verify) |
| `workspace/lib/src/span_editor.dart:1362-1370` (`_runCheck`) | `dart pub get` (if no package config) + workspace convention check |
| `workspace/lib/src/workspace_meaning_runner.dart:262` | `dart pub get` |
| `workspace/lib/src/workspace_meaning_runner.dart:275` | workspace convention check (e.g. `dart test`) |
| `host/lib/src/coding_agent_runner.dart:891` | `dart analyze` (analyzer-before-tests, ADR 0027 §2) |
| `host/lib/src/coding_agent_runner.dart:1135` | `Process.runSync(step.command …)` — final per-package verify gate |
| `host/lib/src/intent_closure_runner.dart:183` | `dart run intent_runner.dart` (intent-surface oracle only) |
| benchmark-only: `harness/lib/src/benchmark/coding_suite/checkers.dart:109,200` | `Process.runSync` checkers (never on the session path) |

**Scripted mode** (`HarnessHostConfig.scripted` → `_ScriptedDaemonActor`,
`harness_acp_backend.dart:1087`, class at `:1556`) is a pure-Dart
`GenerationHandler` (`testing/scripted_handler.dart` imports only `dart:async`,
`ecsly`, `inference_core`) — **no subprocess on the generation path**. But the
session scaffold around it still builds `Directory(session.cwd)` jails
(`harness_acp_backend.dart:566,596,682,720,989,1098`) and opens a snapshot
store under `<cwd>/.dart_tool/harnessd_store` (`:498,512`) — so even scripted
mode needs a real, writable directory.

**Meaning profile**: spawns via `span_editor.dart` (dart analyze ×2, pub get,
check) and the `run` tool — see Q3.

## Q2 — How does the workspace ETL access files?

Direct, synchronous `dart:io` over absolute paths:

- `fs_etl.dart:92-100` — `scanWorkspaceFs(Directory workspace)`: `Directory.list(recursive)` walk; `:258` `File('${workspace.path}/${f.rel}').readAsStringSync()`; `:413,433,440,618,676` `statSync` / `Directory(...).listSync`.
- `fs_tools.dart:31-44` — `FsToolsRoot` **resolves symlinks at construction** (`dir.resolveSymbolicLinksSync()`) and rejects paths outside the root via prefix matching (`:59-88`); reads/writes via `File(path).readAsString()` (`:161`), `File(...).writeAsString` (`:190-191`), sync variants (`:306-350`).
- `span_editor.dart:668,903,968,1047,1073,1149,1246` — sync `File` reads/writes on absolute `_abs(f)` paths.
- materializers (`md_materializer.dart:217,227,466,652`; `yaml_json_materializer.dart:815,1462`) — same pattern.
- `code_etl.dart:234-245,361,392`; `test_etl.dart:196,241,327-378` — same.
- `harness_acp_backend.dart:127-130` — `ConsentPlan.forWorkspace` reads `<cwd>/.harnessd/consent.json` with `File`.
- `harness_acp_backend.dart:498,512` — snapshot store rooted INSIDE the workspace: `<cwd>/.dart_tool/harnessd_store`.
- Notable exception: `snapshot_store.dart:32-35` already accepts an **injected `StorageService`** (universal_storage_interface) — the one existing persistence seam.

**What breaks under an Android SAF-picked folder** (content URIs, no absolute
path, no exec bit, copy-out only):

1. `Directory(cwd)` / `File('$cwd/...')` do not exist for a tree-URI grant —
   SAF is not a POSIX path; there is no absolute path to feed `FsToolsRoot`.
2. `resolveSymbolicLinksSync` and prefix-based jail checks are POSIX concepts.
3. All ETL/materializer IO is **synchronous** (`readAsStringSync`,
   `listSync`, `statSync`); SAF access is inherently async (ContentResolver)
   and cannot back `Sync*` APIs without a pre-copied mirror.
4. Writes into the picked tree (`.dart_tool/harnessd_store`,
   `.harnessd/consent.json`, materialized files) must go through
   DocumentsContract; dart:io cannot do that.
5. The app's current picker compounds this: `agent_doc_surface.dart:446-451`
   uses `file_selector` `getDirectoryPath`, and
   `file_selector_android-0.5.2+4` converts the tree URI to a file path via
   `FileUtils.getPathFromUri` (`FileSelectorApiImpl.java:195-232`), which
   throws `UnsupportedOperationException` for providers that don't map to real
   paths — and even when a path maps, scoped storage does not grant `File`
   write access to it.
6. Git tools would silently degrade (no repo → `not_a_git_repo` bounce,
   `fs_tools.dart:487-491` — acceptable).

## Q3 — What does the meaning profile do for verification? Can it degrade?

**Verification is process-execution all the way down (D8 workspace
convention):**

- Convention resolution: `workspace_conventions.dart:34-70` — `pubspec.yaml` +
  tests → `dart test` / `flutter test`; bare `main.dart` → `dart run main.dart`;
  otherwise **honest `null`**.
- Goal gate: `coding_agent_runner.dart:810-817` — in meaning-profile mode,
  `task.runCommand ?? resolveWorkspaceCheck(jail) ?? (throw StateError(
  'meaning-profile task: no verification criterion resolvable …'))`. So a
  picked folder with no pubspec/main.dart **hard-throws** unless the app
  supplies `checkCommand` (the doc binding does: `agent_doc_surface.dart:136`).
- The wired gate is executed mechanically through the jailed `run` tool
  (`build_gates.dart:280-298`), i.e. `Process.run('dart'|'flutter', …)`.
- Per-move verify + auto-revert: `span_editor.dart:1163-1183` (baseline
  `dart analyze`), `:1246-1270` (scoped `dart analyze` after every move,
  revert on regression), `:1359-1370` (pub get + check).

**Can it degrade gracefully on mobile?** Partially, today:

- `runTool` catches `ProcessException` and returns structured
  `{'ok': false, 'code': 'spawn_error'}` (`fs_tools.dart:932-944`) — no crash.
- Read-only tasks wire **no verifier at all** (`coding_agent_runner.dart:805-807`
  — "reads have no oracle; the gate would be theater").
- BUT: any mutating meaning-profile task on-device would have its goal graded
  by `run dart test` → `spawn_error` → graded `false` → the loop burns
  `maxGoalAttempts` and stamps FAIL even for correct edits. And
  `span_editor.dart:1165/1255` call `Process.run('dart', …)` **without a
  catch** in the apply path → an uncaught `ProcessException` kills
  `edit_symbol` outright (md/yaml/json materializers do not spawn processes —
  `md_materializer.dart`, `yaml_json_materializer.dart` have no `Process` refs).

So: **verification cannot merely be "skipped" at runtime — it must be replaced
by a non-process verifier tier** (host-side structural checks, or a verifier
callback the host injects), plus a guard so the dart-only oracle never runs for
non-Dart file classes or on platforms without a toolchain.

## Q4 — Backends: what works on Android?

- **`open_router`** — pure `package:http` (`openrouter_inference_client.dart:10,43-50,186-188`); the `dart:io` import at `:8` is unused (leftover). **Works on Android and iOS.** Key must be passed explicitly: `HarnessHostConfig.openRouterKeyResolvable` checks `Platform.environment['OPENROUTER_API_KEY']` (`harness_host.dart:191`) which won't exist for a GUI-launched mobile app.
- **`apple_foundation_afm`** — FFI bridge to `SystemLanguageModel`
  (`FoundationModels`). macOS-only today: the Swift package lives under
  `macos/` only (`macos/xsoulspace_inference_apple_foundation/Package.swift`),
  the loader searches for `libxs_fm_bridge.dylib` in `Directory.current`,
  executable dir, `.dart_tool/lib` (`library_loader.dart:28-40`), and the API
  doc says "macOS 26+" (`xsoulspace_inference_apple_foundation.dart:1-2`).
  **Does not work on Android** (no FoundationModels; `dart:ffi` would have
  nothing to load). On **iOS**, FoundationModels exists on iOS 26+, but this
  package ships no iOS Swift package and the dylib path strategy would need an
  iOS variant. No other native FFI exists in the session path (`ecsly` is pure
  Dart; the harness core barrel has no `dart:ffi`).
- **Scripted / `handlerFactory`** — no provider at all; works anywhere
  (`harness_acp_backend.dart:1087-1096`, lazy bindings per
  `harness_host.dart:198-205`).

## (a) Hard blockers

1. **SAF folder ≠ absolute POSIX path** — `FsToolsRoot(fs_tools.dart:31-44)`, all of `fs_etl.dart`/`span_editor.dart`/materializers, `ConsentPlan` read (`harness_acp_backend.dart:127-130`) and the in-workspace snapshot store (`:498,512`) require `dart:io` File/Directory with absolute paths and sync IO. (Android; iOS document picker has the same shape.)
2. **Verification = process execution** — convention check, goal gate, per-move analyze all `Process.run` dart/flutter (`workspace_conventions.dart:34-70`, `span_editor.dart:1163-1270,1359-1370`, `build_gates.dart:280-298`, `coding_agent_runner.dart:810-817`). No toolchains exist on-device; meaning-profile mutating tasks would fail every grade or crash `edit_symbol` (uncaught `ProcessException`, `span_editor.dart:1165,1255`).
3. **iOS fork/exec prohibition** — no subprocess at all, ever; all degrade paths that shell out must be statically excluded on iOS.
4. **AFM binding is macOS-only** — `library_loader.dart:28-40`, `macos/`-only Swift package; default backend in the app is `apple_foundation_afm` (`harness_host.dart:71`) → mobile needs the OpenRouter binding plus an explicit API key.
5. **Directory picker on Android** — `file_selector_android-0.5.2+4` `getDirectoryPath` maps tree URIs to file paths and throws for non-mappable providers (`FileSelectorApiImpl.java:195-232`); a SAF-native picker returning a persisted tree URI is required.

## (b) Soft blockers

- Sync IO throughout the ETL (`readAsStringSync`, `listSync`, `statSync`) — workable on a mirrored/copy-in workspace, painful against a live ContentResolver.
- Snapshot + consent files are written **into the picked workspace** (`.dart_tool/harnessd_store`, `.harnessd/consent.json`) — invisible clutter / permission churn; better rooted in app-support via the injectable `StorageService` (`snapshot_store.dart:32-35`).
- `Platform.environment['OPENROUTER_API_KEY']` key discovery is a no-op on mobile (`harness_host.dart:191,203`) — needs an in-app key store.
- Read-world `run` tool registers dart/flutter allowlist entries that can never succeed on-device (`harness_acp_backend.dart:596-606`) — wasted surface, misleading bounce text for the model.
- `git_status`/`git_diff`/`GitVcsAdapter` will always bounce `not_a_git_repo` on mobile — honest but dead weight unless a git binary is bundled (not worth it).
- Web stub precedent exists (`agentic_workspace_web_stub.dart` — honest refusals), but it is keyed on `dart.library.js_interop`; a mobile-degrade profile needs its own conditional-import axis (or runtime capability flag).

## (c) Minimal viable 'mobile sandboxed harness' mode + the seam list

Minimal mode: **OpenRouter over HTTP (or scripted) + reads via ETL zoom + md/yaml/json/text edits materialized within ONE picked folder + verification degraded to a host-injected non-process verifier (or read-only tasks only) + snapshot store in app-support.**

Seams required (in dependency order):

1. **Filesystem seam (the big one):** abstract the fs tier behind an interface —
   roughly `list/stat/read/write/mkdir` over *workspace-relative* paths, async,
   implemented by (i) a `IoFilesystem` (today's behavior) and (ii) a
   `SafFilesystem` (ContentResolver/DocumentsContract). Call sites to convert:
   `FsToolsRoot` (`fs_tools.dart:31-110`), fs read/write helpers
   (`:150-350`), `fs_etl.dart` (scan/refresh/stat), `span_editor.dart`
   (`_abs` + File IO), `md/yaml_json/dart materializers`, `code_etl.dart`,
   `test_etl.dart`, `ConsentPlan.forWorkspace`. Unix-only machinery
   (`resolveSymbolicLinksSync`, symlink containment) collapses to lexical
   canonicalization under the interface.
2. **Verifier seam:** make the goal gate accept a host-injected verifier
   (`Future<bool> Function(detail)` / structured result) as an alternative to
   `RunGoalSpec.command`; add a "no-toolchain" degrade tier that (a) skips
   dart-only oracles for non-Dart classes in `span_editor.apply`, (b) replaces
   exit-0 grading with structural/structural-diff checks (materializer
   re-parse, schema validation — already pure Dart in the workspace package),
   and (c) reports `verification: degraded (no toolchain)` honestly in the
   verdict beat. Guard the uncaught `Process.run` sites.
3. **Picker seam (Android):** SAF-native directory picker returning a persisted
   tree URI + a `WorkspaceRef` type (either `AbsPath` or `SafTree(uri)`) used
   instead of a bare `cwd: String` through `HarnessEmbed.newSession` →
   `HarnessAcpBackend.createSession` → `_Session.cwd`.
4. **Snapshot/consent relocation:** route the store via injected
   `StorageService` rooted in app-support (`snapshot_store.dart:32-35` already
   accepts it — the backend just never injects, `harness_acp_backend.dart:498-512`);
   move consent policy out of `<cwd>/.harnessd/` or read it through seam #1.
5. **Backend composition (S):** on Android/iOS default to `open_router`, pass
   the key from secure storage; make `apple_foundation_afm` binding registration
   platform-gated (already effectively null-capable: `buildRouter` may return
   null and the daemon refuses with named data, `harness_host.dart:186-205`).
6. **Tool surface trim (S):** on mobile omit `git_status`/`git_diff`, the
   dart/flutter `run` allowlist, and `ae` verify from the registries
   (`harness_acp_backend.dart:596-606,682`; `ae_bridge.dart:41`) — registry
   composition is already per-surface, so this is configuration, not surgery.
7. **iOS gating (S):** compile-time exclusion of every `Process.*` site on iOS
   (or runtime `Platform.isIOS` guards with the same honest
   `spawn_unavailable` bounce `runTool` already returns).

## (d) Effort estimate per seam

| Seam | Size | Why |
|---|---|---|
| 1. Filesystem seam (IoFilesystem + SafFilesystem) | **L** | ~10 files across 3 packages touch dart:io directly (`fs_tools`, `fs_etl`, `span_editor`, 3 materializers, `code_etl`, `test_etl`, backend consent/store); SAF impl + persistable-permission lifecycle is its own chunk |
| 2. Verifier seam (degraded verification tier) | **M** | `wireRunGradedGoal`/`runGoalVerifier` already centralize grading; need an injected-verifier branch, span_editor guards, honest degrade beat |
| 3. SAF picker + WorkspaceRef | **M** | new platform channel (or `file_selector_android` fork) + type threading through embed/backend (currently `cwd: String` end-to-end) |
| 4. Snapshot/consent relocation | **S** | `SnapshotStore` already takes an injected `StorageService`; consent file read moves behind seam 1 |
| 5. Backend/key composition on mobile | **S** | binding is already injectable + lazily null-capable |
| 6. Mobile tool-surface trim | **S** | registry composition is already per-surface/per-session |
| 7. iOS Process.* exclusion | **S** | guards at the 7 runtime spawn sites listed in Q1 |

**Total: L-sized program** (~2–4 weeks of focused work for one person who
knows the codebase, dominated by seam 1 + SAF lifecycle). A pragmatic
**S/M-sized first slice** exists without SAF: sandbox the workspace to the
app's own documents directory (plain absolute path — zero fs-seam work), ship
OpenRouter + md/yaml editing + degraded verification, and defer the
user-picked-SAF-folder requirement. That gets a working mobile harness in days;
SAF-picked folders are the long pole.

## Non-claims

- No mobile target was built or run; this is static code reading plus
  dependency-source inspection (`file_selector_android-0.5.2+4` in pub cache).
- "Works on Android" claims for `package:http`/SAF APIs rest on their public
  contracts, not on an executed device test.
- Status remains `stewardship_protocol`; nothing here establishes a further
  stewardship status.
