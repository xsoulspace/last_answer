/// Phase 1d — the world's read model for the shell chrome (docs/design/
/// ecsai-modelscope-first-priority-2026-11-05.md G2–G5): ONE dynamic
/// assembly of the facts the status edge, the landing inbox and the
/// Models surface render.
///
/// Dynamic by law (the owner's Zed rule): the model palette is NEVER a
/// hardcoded cast. It is DISCOVERED from the config chain the harness
/// itself reads — the realm authority row's `configurationRoot`, then
/// the nearest `.xsoulspace/config.json` walking up from the world home,
/// then the device-global file — and parsed with the harness's OWN
/// parser (`parsePaletteConfig`), so a refusal is the harness's named
/// code, verbatim. Health merges from the daemon's `palette_health.json`
/// (ADR 0119); the escalation ladder from `realm_actor_escalation`;
/// tasks and telemetry from the realm journal the app already holds a
/// store on; permissions and verdicts from the live session registry.
///
/// Process telemetry + read-only journal projections, never world
/// authority: every absence degrades to a named quiet state, and the
/// one WRITE this service performs is the supervised WORLD converge —
/// daemon AND realm scheduler in one oka pass (leg B G1: the scheduler
/// is the durable delegation lane's claimant pump; without it a `task
/// op:create` sits `queued` forever) — plus the validated palette-config
/// save.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/supervised_world.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// One palette rung, merged: the config declaration × the daemon's
/// health verdict × the escalation ladder × the delegation choice.
@immutable
final class WorldRung {
  const WorldRung({
    required this.id,
    required this.role,
    required this.primary,
    required this.builtin,
    this.provider,
    this.model,
    this.health,
    this.ladderNext,
  });

  /// The palette entry id (`modelscope_qwen38max`) — the only id the
  /// world's verbs accept.
  final String id;

  /// `generative` | `decision`.
  final String role;
  final bool primary;

  /// A composition-root built-in lane (`qwen`, `lfm`,
  /// `apple_foundation_afm`, …) — the local lanes.
  final bool builtin;

  final String? provider;
  final String? model;

  /// The daemon's health verdict, null when the health file names no
  /// entry (an unknown rung has no verdict — honest absence).
  final PaletteBrainHealth? health;

  /// The escalation ladder's next rung, when the global config declares
  /// one for this entry.
  final String? ladderNext;

  String get healthStatus => health?.status ?? 'unknown';

  /// A local (native-engine) lane: builtin AND not the AFM-only names
  /// the composition root downloads nothing for either — the weights
  /// fact rides the health detail (`not_downloaded`).
  bool get isLocal => builtin;
}

/// One durable-task row, projected from the realm journal's
/// `durable_tasks` collection (ADR 0118 D3: the queue record is the
/// delegation's authority).
@immutable
final class WorldTaskRow {
  const WorldTaskRow({
    required this.taskId,
    required this.state,
    required this.task,
    required this.terminal,
    this.modelId,
    this.summary,
    this.at,
    this.addressees = const [],
  });

  final String taskId;

  /// The world's own state word (`queued`, `leased`, `started`,
  /// `verifying`, `succeeded`, `failed`, `cancelled`, `unknown`).
  final String state;

  /// The delegated sentence.
  final String task;

  /// True when the world reached a terminal state.
  final bool terminal;

  final String? modelId;

  /// The terminal record's result summary or failure reason, when set.
  final String? summary;

  /// Best-known timestamp (terminal `at`, else the row's own).
  final String? at;

  final List<String> addressees;

  bool get running => !terminal;
}

/// One pending permission from the live session registry (Lane A — the
/// in-app agent-doc sessions; the reject-first inbox rows).
@immutable
final class InboxPermission {
  const InboxPermission({
    required this.sessionId,
    required this.title,
    required this.answer,
    this.kind,
    this.since,
    this.actorId,
    this.diff,
  });

  final String sessionId;
  final String title;
  final String? kind;
  final String? since;

  /// 2c — the ASKING ACTOR (the session's origin actor id, unresolved):
  /// the change card is attributed, never an anonymous "SYS". Null when
  /// the session carries no actor identity (honest absence).
  final String? actorId;

  /// 2c — the proposed change's unified diff, when the pending
  /// round-trip carries one (the meaning review proposal, exact-matched
  /// to the pending permission by proposalId+effectDigest upstream).
  /// Null = no diff to show; the card stays a title-only interrupt.
  final String? diff;

  /// Answers the round-trip through the session's own handle (allow =
  /// the write proceeds; reject = it never lands).
  final Future<void> Function(bool allow) answer;
}

/// 2c — the tolerant diff finder: the review proposal nests its unified
/// diff under the host's own payload shape (`result.proposal.diff`
/// today); the walk names the FACT (the first `diff` string), never the
/// path, and is bounded (a display read, never an unbounded descent).
String? _firstDiffString(final Object? node, [final int depth = 0]) {
  if (node == null || depth > 6) return null;
  if (node is Map) {
    final direct = node['diff'];
    if (direct is String && direct.isNotEmpty) return direct;
    for (final value in node.values) {
      final found = _firstDiffString(value, depth + 1);
      if (found != null) return found;
    }
    return null;
  }
  if (node is List) {
    for (final value in node) {
      final found = _firstDiffString(value, depth + 1);
      if (found != null) return found;
    }
  }
  return null;
}

/// One last-verdict row: a session's verdict/spend projection or a
/// durable task's terminal record.
@immutable
final class WorldVerdictRow {
  const WorldVerdictRow({
    required this.id,
    required this.state,
    required this.line,
    this.spend,
    this.at,
  });

  final String id;

  /// `succeeded` / `failed` / `cancelled` / a session verdict word.
  final String state;

  /// One honest line (the summary, the verdict text).
  final String line;

  final String? spend;
  final String? at;
}

/// One actor's newest tool-loop telemetry (the cache/spend read model,
/// leg B §2.3d — the journal already carries it).
@immutable
final class ActorTelemetry {
  const ActorTelemetry({
    required this.actorId,
    required this.rounds,
    required this.promptTokens,
    required this.cachedTokens,
    required this.stalled,
    this.toolCalls = 0,
    this.completionTokens = 0,
    this.promptChars = 0,
    this.appliedWrites = 0,
    this.at,
  });

  final String actorId;
  final int rounds;
  final int promptTokens;
  final int cachedTokens;
  final bool stalled;

  /// The rest of the journal row (0b — the inline work texture): the
  /// loop's per-dispatch counts. The journal carries them; the old
  /// projection discarded them and the work cards starved.
  final int toolCalls;
  final int completionTokens;
  final int promptChars;
  final int appliedWrites;
  final String? at;

  /// Cached-token share of the prompt (ADR 0122's hit-rate), null when
  /// the dispatch measured no prompt tokens.
  double? get cacheHitRate =>
      promptTokens <= 0 ? null : cachedTokens / promptTokens;
}

/// The daemon's arm state (G2's one-click converge).
enum WorldArmState { idle, arming, error }

/// The world's read model + the ONE write seam (arm/stop/restart the
/// supervised daemon, save a validated palette config).
final class WorldStateService extends ChangeNotifier {
  WorldStateService({
    this._store,
    PaletteHealthStore? health,
    this.debugDoctor,
    this.debugWorldHome,
  }) : _health = health ?? PaletteHealthStore();

  /// Test seam: replaces the host doctor probe (file IO) with a fixed
  /// report map (`daemon` + `daemonExe` sections).
  @visibleForTesting
  final Map<String, Object?> Function(String workspace)? debugDoctor;

  /// Test seam: pins the realm world home (production derives it from
  /// [RealmWorld.realmControlStorePath]).
  @visibleForTesting
  final String? debugWorldHome;

  RealmControlStore? _store;
  final PaletteHealthStore _health;
  Timer? _poll;
  bool _refreshing = false;

  // ---- daemon (the doctor truth, the same `ecsai --status` serves) ----

  bool _daemonLive = false;
  int? _daemonPid;
  String? _daemonStartedAt;
  bool? _daemonBinaryStale;
  String? _daemonExePath;
  bool _daemonExePresent = false;
  String? _worldHome;
  String? _harnessRoot;

  bool get daemonLive => _daemonLive;
  int? get daemonPid => _daemonPid;
  String? get daemonStartedAt => _daemonStartedAt;
  bool? get daemonBinaryStale => _daemonBinaryStale;

  /// The AOT daemon artifact the arm converges (`build/ecsai_daemon.exe`
  /// under the harness root), null when the doctor found none — the arm
  /// then refuses by name instead of guessing a binary.
  String? get daemonExePath => _daemonExePath;

  /// The realm world home the daemon serves (`~/.xsoulspace/worlds/local`
  /// shape); null until the first refresh resolved it.
  String? get worldHome => _worldHome ?? debugWorldHome;

  /// The harness checkout root the doctor resolved (`artifacts.root`,
  /// the `ECSAID_ROOT` / walk-up law) — the scheduler entrypoint's
  /// discovery base; null when unresolved (the arm then refuses by
  /// name).
  String? get harnessRoot => _harnessRoot;

  // ---- scheduler (the delegation lane's claimant pump, G1) ----

  bool _schedulerLive = false;
  int? _schedulerPid;

  /// Whether the supervised scheduler's oka registry record names a LIVE
  /// pid — the honest claimant fact for the durable delegation lane
  /// (false: a `task op:create` will sit `queued` until the world is
  /// armed). The scheduler has no pointer file; the record + pid probe
  /// IS the truth.
  bool get schedulerLive => _schedulerLive;

  /// The scheduler's recorded pid, null when down or unknown.
  int? get schedulerPid => _schedulerPid;

  /// Test seam: replaces the machine's oka supervisor registry for the
  /// scheduler record read (tests never touch the real `~/.oka`); the
  /// value is the io adapter's `MachineRegistry` (typed `Object?` here
  /// so this file stays free of the `dart:io`-only oka import — the
  /// conditional-import law).
  @visibleForTesting
  Object? debugSupervisorRegistry;

  // ---- arm state (G2) ----

  WorldArmState _armState = WorldArmState.idle;
  String? _armError;
  List<String> _armFindings = const [];
  Map<String, Object?>? _lastArmReport;

  WorldArmState get armState => _armState;
  String? get armError => _armError;
  List<String> get armFindings => _armFindings;
  Map<String, Object?>? get lastArmReport => _lastArmReport;

  // ---- palette (dynamic — the config chain, never a hardcoded cast) ----

  PaletteConfig? _palette;
  String? _paletteConfigPath;
  String? _paletteAbsence;
  Map<String, String> _ladder = const {};
  List<WorldRung> _rungs = const [];
  String? _selectedRungId;

  /// The parsed palette declaration, null when no config declares one.
  PaletteConfig? get palette => _palette;

  /// The config file the palette was discovered in (the editor's
  /// target), null when none declares `model_palette`.
  String? get paletteConfigPath => _paletteConfigPath;

  /// Why no palette is shown — the harness's own refusal code when the
  /// document failed to parse (`palette_malformed_config: …`), null when
  /// the palette is present or simply undeclared.
  String? get paletteAbsence => _paletteAbsence;

  /// The escalation ladder (`rung → next rung`) from the device-global
  /// config's `realm_actor_escalation`.
  Map<String, String> get ladder => _ladder;

  /// Every declared rung, merged with health + ladder, in cast order.
  List<WorldRung> get rungs => _rungs;

  /// The rung the human picked for delegation this session (G3: the
  /// delegate surface shows the rung it will use); null = the world's
  /// primary default.
  String? get selectedRungId => _selectedRungId;

  void selectRung(final String? rungId) {
    if (_selectedRungId == rungId) return;
    _selectedRungId = rungId;
    notifyListeners();
  }

  /// The declared primary generative rung (what a delegation without an
  /// explicit `modelId` lands on — G3's "degraded primary visible
  /// BEFORE the send").
  WorldRung? get primaryRung {
    final id = _palette?.primaryGenerative?.id;
    if (id == null) return null;
    for (final rung in _rungs) {
      if (rung.id == id) return rung;
    }
    return null;
  }

  /// G6 — the wire facts of one palette rung, for the `cast:` brainRef
  /// grammar (actor_brain): the declaration's provider transport,
  /// endpoint and credential env NAME, exactly as the config document
  /// declares them. Null when the palette names no such entry.
  CastBrainDecl? castDeclFor(final String entryId) {
    final config = _palette;
    if (config == null) return null;
    final entry = config.entry(entryId);
    if (entry == null) return null;
    if (entry.builtin) {
      return CastBrainDecl(id: entryId, model: entryId, transport: 'builtin');
    }
    final provider = entry.provider == null
        ? null
        : config.provider(entry.provider!);
    final model = entry.model == null ? null : provider?.model(entry.model!);
    return CastBrainDecl(
      id: entryId,
      model: entry.model ?? '',
      transport: provider?.transport.wireName ?? 'openrouter',
      baseUrl: provider?.baseUrl,
      credentialEnv: provider?.credentialEnv,
      maxOutputTokens: model?.maxOutputTokens,
      reasoningEffort: model?.reasoningEffort,
    );
  }

  /// The generative rungs as brain declarations (the actor picker's
  /// palette section, G6).
  List<CastBrainDecl> get generativeDecls => [
    for (final rung in _rungs)
      if (rung.role == 'generative') ?castDeclFor(rung.id),
  ];

  // ---- journal projections (tasks, telemetry) ----

  List<WorldTaskRow> _tasks = const [];
  Map<String, ActorTelemetry> _telemetryByActor = const {};

  /// Test seam: overrides the journal task projection (widget tests bind
  /// no journal rows). Never set from product.
  @visibleForTesting
  List<WorldTaskRow>? debugTasksOverride;

  /// Durable-task rows, running first, then most recent terminal.
  List<WorldTaskRow> get tasks => debugTasksOverride ?? _tasks;

  List<WorldTaskRow> get runningTasks => [
    for (final task in tasks)
      if (task.running) task,
  ];

  /// The newest telemetry row per actor (cache-hit %, rounds, stalled).
  /// Test seam: overrides the journal telemetry projection (widget
  /// tests bind no journal rows). Never set from product.
  @visibleForTesting
  Map<String, ActorTelemetry>? debugTelemetryOverride;

  Map<String, ActorTelemetry> get telemetryByActor =>
      debugTelemetryOverride ?? _telemetryByActor;

  // ---- session registry projections (permissions, verdicts) ----

  List<InboxPermission> _permissions = const [];
  List<WorldVerdictRow> _verdicts = const [];

  /// Test seams: override the registry projections (a permission needs a
  /// live session handle; tests bind the row shape directly). Never set
  /// from product.
  @visibleForTesting
  List<InboxPermission>? debugPermissionsOverride;
  @visibleForTesting
  List<WorldVerdictRow>? debugVerdictsOverride;

  /// Open Lane-A permissions across the live sessions (reject-first
  /// rows of the landing inbox).
  List<InboxPermission> get permissions =>
      debugPermissionsOverride ?? _permissions;

  /// Last verdicts: session verdict/spend lines plus the newest terminal
  /// durable tasks, most recent first.
  List<WorldVerdictRow> get verdicts => debugVerdictsOverride ?? _verdicts;

  /// The attention count the status edge renders: open permissions plus
  /// running/queued tasks (the operator's ambient awareness, redesign
  /// §2.1).
  int get attentionCount => permissions.length + runningTasks.length;

  // ---- polling ----

  /// Starts the ambient poll (the shell calls this once; the edge and
  /// the inbox render whatever the last pass assembled).
  void startPolling({final Duration period = const Duration(seconds: 5)}) {
    _poll?.cancel();
    unawaited(refresh());
    _poll = Timer.periodic(period, (_) => unawaited(refresh()));
  }

  void stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  /// One read pass. Never throws: every lane degrades to its named
  /// quiet state (telemetry is not authority).
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      _refreshDaemon();
      await _refreshJournal();
      await _refreshAuthority();
      _refreshPalette();
      _refreshSessions();
    } on Object catch (error) {
      // A failed pass keeps the previous projection; the edge renders
      // the last known truth rather than flapping.
      debugPrint('world_state refresh failed: $error');
    } finally {
      _refreshing = false;
    }
    notifyListeners();
  }

  // ---- daemon ----

  String _resolveWorldHome() =>
      debugWorldHome ??
      Directory(RealmWorld.realmControlStorePath()).parent.path;

  void _refreshDaemon() {
    final workspace = _resolveWorldHome();
    Map<String, Object?> report;
    try {
      if (debugDoctor case final doctor?) {
        report = doctor(workspace);
      } else {
        final typed = collectEcsaiDoctorReport(workspace: workspace);
        report = typed.toJson();
      }
    } on Object {
      return; // an unreadable doctor keeps the last known daemon state
    }
    final daemon = report['daemon'];
    if (daemon is Map) {
      _daemonLive = daemon['live'] == true;
      _daemonPid = daemon['pid'] as int?;
      _daemonStartedAt = daemon['residentStartedAt'] as String?;
      _daemonBinaryStale = daemon['binaryStaleVsArtifact'] as bool?;
      final home = daemon['worldHome'];
      if (home is String && home.isNotEmpty) _worldHome = home;
    }
    final artifacts = report['artifacts'];
    if (artifacts is Map && artifacts['daemon'] is Map) {
      final exe = artifacts['daemon']! as Map;
      _daemonExePresent = exe['present'] == true;
      _daemonExePath = exe['path'] as String?;
    }
    if (artifacts is Map) {
      final root = artifacts['root'];
      _harnessRoot = root is String && root.isNotEmpty ? root : null;
    }
    // The scheduler's truth is its oka supervisor registry record + the
    // recorded pid's liveness (no pointer file exists for it) — read
    // through the conditional-import facade, so this stays web-safe.
    final scheduler = readSupervisedScheduler(
      workspace: workspace,
      debugRegistry: debugSupervisorRegistry,
    );
    _schedulerLive = scheduler['live'] == true;
    _schedulerPid = scheduler['pid'] as int?;
  }

  /// G2 + G1 — the one-click arm: converges the machine's WHOLE world
  /// through the supervised adapter (oka_supervisor SDK) in ONE pass —
  /// the daemon (readiness gate = the owner pointer's live pid) AND the
  /// realm scheduler (readiness gate = the leased record's pid alive
  /// across a bounded settle window), so a delegated `task op:create`
  /// has a claimant pump from a cold machine. Honest receipts:
  /// `alreadyRunning` is success, findings render, and a missing
  /// artifact refuses BY NAME naming the component — the daemon's AOT
  /// exe (`daemon_artifact_absent`), the harness root
  /// (`harness_root_unresolved`) or the script-only scheduler
  /// entrypoint (`scheduler_entrypoint_absent`) — never a spinner
  /// without an end and never a half-armed world.
  Future<Map<String, Object?>> armWorld() async {
    if (_armState == WorldArmState.arming) return _lastArmReport ?? const {};
    final exe = _daemonExePath;
    if (!_daemonExePresent || exe == null || exe.isEmpty) {
      const finding =
          'build/ecsai_daemon.exe was not found under the harness root — '
          'build the AOT daemon first (the app never downloads one).';
      _armState = WorldArmState.error;
      _armError = 'daemon_artifact_absent';
      _armFindings = const [finding];
      notifyListeners();
      return {
        'ok': false,
        'bounce': 'daemon_artifact_absent',
        'component': ecsaiDaemonComponentId,
        'components': supervisedWorldComponentIds,
      };
    }
    final root = _harnessRoot;
    if (root == null || root.isEmpty) {
      const finding =
          'harness_root_unresolved: the doctor resolved no harness '
          'checkout root (artifacts.root) — the realm scheduler '
          'entrypoint cannot be located. Set ECSAID_ROOT for the '
          'app environment.';
      _armState = WorldArmState.error;
      _armError = 'harness_root_unresolved';
      _armFindings = const [finding];
      notifyListeners();
      return {
        'ok': false,
        'bounce': 'harness_root_unresolved',
        'component': ecsaiSchedulerComponentId,
        'components': supervisedWorldComponentIds,
      };
    }
    final schedulerScript = schedulerEntrypointPath(root);
    if (!File(schedulerScript).existsSync()) {
      final finding =
          'scheduler_entrypoint_absent: $schedulerScript does not exist '
          '— the harness checkout is incomplete or artifacts.root is '
          'stale (the scheduler is script-only; there is no AOT '
          'artifact to fall back to).';
      _armState = WorldArmState.error;
      _armError = 'scheduler_entrypoint_absent';
      _armFindings = [finding];
      notifyListeners();
      return {
        'ok': false,
        'bounce': 'scheduler_entrypoint_absent',
        'component': ecsaiSchedulerComponentId,
        'components': supervisedWorldComponentIds,
      };
    }
    _armState = WorldArmState.arming;
    _armError = null;
    _armFindings = const [];
    notifyListeners();
    try {
      final home = worldHome ?? _resolveWorldHome();
      final report = await startSupervisedWorld(
        daemonExecutablePath: exe,
        harnessRoot: root,
        workspaceHint: home,
        daemonLogPath: '$home/daemon-app.log',
        schedulerLogPath: '$home/scheduler-app.log',
      );
      _lastArmReport = report;
      _armState = report['ok'] == true
          ? WorldArmState.idle
          : WorldArmState.error;
      if (_armState == WorldArmState.error) {
        _armError = '${report['bounce'] ?? 'world_arm_failed'}';
        _armFindings = [
          for (final finding in (report['findings'] as List? ?? const []))
            '$finding',
        ];
      }
      await refresh();
      return report;
    } on Object catch (error) {
      _armState = WorldArmState.error;
      _armError = '$error';
      _armFindings = const [];
      notifyListeners();
      return {'ok': false, 'bounce': '$error'};
    }
  }

  /// Stops the machine's WHOLE world through the same supervised
  /// ladder, in the declared order: the scheduler first (stop stops
  /// spawning), the daemon second.
  Future<Map<String, Object?>> stopWorld() async {
    try {
      final report = await stopSupervisedWorld(
        workspace: worldHome ?? _resolveWorldHome(),
      );
      await refresh();
      return report;
    } on Object catch (error) {
      return {'ok': false, 'bounce': '$error'};
    }
  }

  /// Restart = the verified stop ladder, then one converge pass (the
  /// palette editor's "restart world" affordance, G7 first step).
  Future<Map<String, Object?>> restartWorld() async {
    await stopWorld();
    return armWorld();
  }

  // ---- journal ----

  Future<void> _refreshJournal() async {
    final store = _store ??= (debugWorldHome == null
        ? (await RealmWorld.open())?.store
        : null);
    if (store == null) return;
    try {
      final tasks = await store.scan('durable_tasks');
      _tasks = _projectTasks(tasks);
    } on Object {
      // An unreadable journal keeps the previous task projection.
    }
    try {
      final telemetry = await store.scan(toolLoopTelemetryCollection);
      _telemetryByActor = _projectTelemetry(telemetry);
    } on Object {
      // Same quiet degradation.
    }
  }

  static List<WorldTaskRow> _projectTasks(
    final Map<String, Map<String, Object?>> rows,
  ) {
    final projected = <WorldTaskRow>[
      for (final entry in rows.entries) ...[?_taskRow(entry.key, entry.value)],
    ];
    // Running first (the inbox's top section), then most recent.
    projected.sort((a, b) {
      if (a.running != b.running) return a.running ? -1 : 1;
      return (b.at ?? '').compareTo(a.at ?? '');
    });
    return List.unmodifiable(projected);
  }

  static WorldTaskRow? _taskRow(
    final String key,
    final Map<String, Object?> row,
  ) {
    final state = '${row['state'] ?? ''}';
    if (state.isEmpty) return null;
    final id = row['taskId'] as String? ?? key;
    // The journal row carries the delegated sentence in its payload
    // (`prompt`), the rung it ran on in `model`, and its timestamps as
    // admitted/started/settled — the terminal RESULT text lives in the
    // actor's doc (the `task op:show` tool composes it), so the inbox
    // renders the sentence + the state word, never an invented summary.
    final payload = row['payload'] is Map
        ? Map<String, Object?>.from(row['payload']! as Map)
        : const <String, Object?>{};
    final terminal = row['terminal'];
    final terminalMap = terminal is Map
        ? Map<String, Object?>.from(terminal)
        : const <String, Object?>{};
    final isTerminal =
        terminalMap.isNotEmpty ||
        row['settledAt'] != null ||
        const {'succeeded', 'failed', 'cancelled', 'unknown'}.contains(state);
    String? summary;
    final result = terminalMap['result'];
    if (result is Map && result['summary'] is String) {
      summary = result['summary'] as String;
    }
    summary ??= terminalMap['reason'] as String?;
    final at =
        row['settledAt'] as String? ??
        terminalMap['at'] as String? ??
        row['startedAt'] as String? ??
        row['leaseAcquiredAt'] as String? ??
        row['admittedAt'] as String?;
    return WorldTaskRow(
      taskId: id,
      state: isTerminal ? '${terminalMap['state'] ?? state}' : state,
      task: '${payload['prompt'] ?? ''}',
      terminal: isTerminal,
      modelId: row['model'] as String? ?? payload['declaredModelId'] as String?,
      summary: summary,
      at: at,
      addressees: [
        for (final addressee
            in (payload['addressees'] as List? ??
                row['addressees'] as List? ??
                const []))
          '$addressee',
      ],
    );
  }

  static Map<String, ActorTelemetry> _projectTelemetry(
    final Map<String, Map<String, Object?>> rows,
  ) {
    final newest = <String, ActorTelemetry>{};
    for (final row in rows.values) {
      final actorId = '${row['actorId'] ?? ''}';
      if (actorId.isEmpty) continue;
      final at = row['at'] as String? ?? '';
      final existing = newest[actorId];
      if (existing != null && (existing.at ?? '').compareTo(at) >= 0) {
        continue;
      }
      newest[actorId] = ActorTelemetry(
        actorId: actorId,
        rounds: (row['rounds'] as num?)?.toInt() ?? 0,
        promptTokens: (row['promptTokens'] as num?)?.toInt() ?? 0,
        cachedTokens: (row['cachedTokens'] as num?)?.toInt() ?? 0,
        stalled: row['stalled'] == true,
        toolCalls: (row['toolCalls'] as num?)?.toInt() ?? 0,
        completionTokens: (row['completionTokens'] as num?)?.toInt() ?? 0,
        promptChars: (row['promptChars'] as num?)?.toInt() ?? 0,
        appliedWrites: (row['appliedWrites'] as num?)?.toInt() ?? 0,
        at: row['at'] as String?,
      );
    }
    return Map.unmodifiable(newest);
  }

  // ---- palette discovery (the dynamic chain) ----

  void _refreshPalette() {
    final discovered = _discoverPaletteConfig();
    final path = discovered?.$1;
    final raw = discovered?.$2;
    _paletteConfigPath = path;
    if (raw == null) {
      _palette = null;
      _paletteAbsence = null;
      _rungs = const [];
      _ladder = const {};
      return;
    }
    try {
      _palette = parsePaletteConfig(raw);
      _paletteAbsence = null;
    } on PaletteConfigError catch (error) {
      // The harness's own named refusal, verbatim — never a silent
      // fallback cast (ADR 0043 house law).
      _palette = null;
      _paletteAbsence = '$error';
      _rungs = const [];
      return;
    }
    _ladder = _readLadder();
    _rungs = _mergeRungs(_palette!, _health.entries, _ladder);
  }

  /// Walks the harness's own config chain and returns the winning file
  /// path plus its raw `model_palette` object: the authority row's
  /// `configurationRoot` first (the daemon's fallback source), then the
  /// nearest workspace file walking up from the world home, then the
  /// device-global config.
  (String, Map<String, Object?>)? _discoverPaletteConfig() {
    for (final candidate in _configCandidates()) {
      final json = _readJsonMap(candidate);
      final palette = json?['model_palette'];
      if (palette is Map) {
        return (candidate, Map<String, Object?>.from(palette));
      }
    }
    return null;
  }

  List<String> _configCandidates() {
    final candidates = <String>[];
    final authorityRoot = _configurationRoot;
    if (authorityRoot != null && authorityRoot.isNotEmpty) {
      candidates.add('$authorityRoot/.xsoulspace/config.json');
    }
    final home = worldHome;
    if (home != null && home.isNotEmpty) {
      var dir = Directory(home).absolute.path;
      while (true) {
        candidates.add('$dir/.xsoulspace/config.json');
        final parent = Directory(dir).parent.path;
        if (parent == dir) break;
        dir = parent;
      }
    }
    candidates.add('${RealmWorld.deviceHome()}/.xsoulspace/config.json');
    return candidates;
  }

  String? _configurationRoot;

  /// The realm authority row's `configurationRoot` (the journal record
  /// the daemon itself falls back to, `durable_seat_host.dart`): read
  /// once per journal refresh so the palette discovery follows the
  /// realm, not a guess.
  Future<void> _refreshAuthority() async {
    final store = _store;
    if (store == null) return;
    try {
      final row = await store.read('coordination', 'authority');
      final root = row?['configurationRoot'];
      _configurationRoot = root is String && root.isNotEmpty ? root : null;
    } on Object {
      _configurationRoot = null;
    }
  }

  Map<String, String> _readLadder() {
    final json = _readJsonMap(
      '${RealmWorld.deviceHome()}/.xsoulspace/config.json',
    );
    final raw = json?['realm_actor_escalation'];
    if (raw is! Map) return const {};
    return Map.unmodifiable(<String, String>{
      for (final entry in raw.entries)
        if (entry.value is String) '${entry.key}': entry.value! as String,
    });
  }

  static List<WorldRung> _mergeRungs(
    final PaletteConfig config,
    final Map<String, PaletteBrainHealth> health,
    final Map<String, String> ladder,
  ) => List.unmodifiable([
    for (final entry in config.cast)
      WorldRung(
        id: entry.id,
        role: entry.role,
        primary: entry.primary,
        builtin: entry.builtin,
        provider: entry.provider,
        model: entry.model,
        health: health[entry.id],
        ladderNext: ladder[entry.id],
      ),
  ]);

  /// Validates + saves a `model_palette` JSON document into the
  /// discovered config file (G7 first step: the editor writes the REAL
  /// palette document with harness-grade named refusals; a `.bak`
  /// sibling keeps the previous bytes). Returns null on success, else
  /// the named refusal — the harness parser's code verbatim, or the
  /// write failure.
  String? savePaletteJson(final String rawJson) {
    final path = _paletteConfigPath ?? _configCandidates().last;
    Object? decoded;
    try {
      decoded = jsonDecode(rawJson);
    } on FormatException catch (error) {
      return 'json_malformed: ${error.message}';
    }
    if (decoded is! Map) return 'palette_malformed_config: expected an object';
    try {
      parsePaletteConfig(decoded);
    } on PaletteConfigError catch (error) {
      return '$error';
    }
    try {
      final file = File(path);
      final document = _readJsonMap(path) ?? <String, Object?>{};
      if (file.existsSync()) {
        File('$path.bak').writeAsStringSync(file.readAsStringSync());
      }
      document['model_palette'] = decoded;
      file.writeAsStringSync(
        '${const JsonEncoder.withIndent('  ').convert(document)}\n',
      );
    } on Object catch (error) {
      return 'palette_write_failed: $error';
    }
    _refreshPalette();
    notifyListeners();
    return null;
  }

  static Map<String, Object?>? _readJsonMap(final String path) {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final decoded = jsonDecode(file.readAsStringSync());
      if (decoded is! Map) return null;
      return Map<String, Object?>.from(decoded);
    } on Object {
      return null;
    }
  }

  // ---- session registry ----

  void _refreshSessions() {
    final permissions = <InboxPermission>[];
    final verdicts = <WorldVerdictRow>[];
    try {
      for (final entry in HarnessSessionRegistry.instance.sessions.entries) {
        final snapshot = entry.value.state;
        final id = entry.key;
        final title = snapshot.pendingPermissionTitle;
        if (title != null && title.isNotEmpty) {
          final handle = entry.value;
          permissions.add(
            InboxPermission(
              sessionId: id,
              title: title,
              kind: snapshot.pendingPermissionKind,
              since: snapshot.pendingPermissionSince?.toIso8601String(),
              // 2c — the proposed diff rides the interrupt: the
              // snapshot's own review proposal (the host keeps the
              // issued proposal; display JSON supplies no authority).
              // The asking actor's ID is NOT in the registry snapshot
              // (harness gap — attribution resolves through the room
              // join at render time, and the gap is filed).
              diff: _firstDiffString(snapshot.reviewProposal),
              answer: (final allow) async {
                handle.answerPermission(allow: allow);
                await refresh();
              },
            ),
          );
        }
        final verdict = snapshot.verdict;
        if (verdict != null && verdict.isNotEmpty) {
          final outcomeState = snapshot.outcome?['state'];
          verdicts.add(
            WorldVerdictRow(
              id: id,
              state: outcomeState is String && outcomeState.isNotEmpty
                  ? outcomeState
                  : verdict,
              line: verdict,
              spend: snapshot.spend == null ? null : '${snapshot.spend}',
            ),
          );
        }
      }
    } on Object {
      // The registry is in-process; a handle mid-dispose never takes
      // the projection down.
    }
    // Terminal durable tasks join the verdict list (newest first).
    for (final task in _tasks) {
      if (!task.terminal) continue;
      verdicts.add(
        WorldVerdictRow(
          id: task.taskId,
          state: task.state,
          line: task.summary ?? task.task,
          at: task.at,
        ),
      );
      if (verdicts.length >= 12) break;
    }
    _permissions = List.unmodifiable(permissions);
    _verdicts = List.unmodifiable(verdicts);
  }

  /// Answers one inbox permission through its session handle.
  Future<void> answerPermission(
    final InboxPermission permission, {
    required final bool allow,
  }) => permission.answer(allow);

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
