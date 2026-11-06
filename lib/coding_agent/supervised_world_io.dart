/// The `io` variant of the supervised world adapter (mobile + desktop):
/// oka_supervisor's `DesiredState`/`Supervisor.converge` drive the
/// machine's world as DECLARED components — the daemon (`ecsai-daemon`)
/// and, since leg B gap G1, the realm scheduler (`ecsai-scheduler`, the
/// durable delegation lane's claimant pump: without it a `task
/// op:create` sits `queued` forever). The host doctor's pointer + pid
/// probe is the daemon's readiness truth; the supervisor record's
/// identity drives the stop ladder.
///
/// Platform note: this file needs `dart:io` (the `Process` machinery
/// oka_core wraps), so it is compiled only where `dart.library.io`
/// holds — the facade gates the web build to the stub variant.
library;

import 'dart:convert';
import 'dart:io';

import 'package:lastanswer/coding_agent/supervised_world_commands.dart';
import 'package:meta/meta.dart' show visibleForTesting;
import 'package:oka_core/oka_core.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:resource_composition/resource_composition.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show WorldManifestIO, collectEcsaiDoctorReport;

export 'package:lastanswer/coding_agent/supervised_world_commands.dart';

/// The daemon's declared component id (the machine's ONE daemon).
const String _componentId = ecsaiDaemonComponentId;

/// The scheduler's declared component id.
const String _schedulerComponentId = ecsaiSchedulerComponentId;

/// ONE WORLD PER MACHINE: the hint only steers realm resolution; the
/// supervised component is always the machine's realm world home (the
/// same truth `ecsai status` serves).
String _resolveMachineWorkspace(String? workspaceHint) {
  final report = collectEcsaiDoctorReport(
    workspace: workspaceHint ?? Directory.current.path,
  ).toJson();
  final daemon = report['daemon']! as Map<String, Object?>;
  return (daemon['worldHome'] as String?) ??
      workspaceHint ??
      Directory.current.path;
}

/// The provider name the daemon adapter's factory resolves (guide
/// vocabulary: the mechanics come from a leased process provider).
const String _providerName = 'leased';

/// The scheduler's own provider name: the converge factory resolves
/// providers BY NAME, so the two components of one desired state carry
/// distinct names and distinct per-component commands.
const String _schedulerProviderName = 'leased-scheduler';

/// Poll cadence for the pointer-liveness gate (the host's own
/// `_awaitDaemonLive` cadence) and for the scheduler's settle probes.
const Duration _probeInterval = Duration(milliseconds: 300);

/// The typed fact for a scheduler child that died inside the settle
/// window: the start FAILS (the child is torn down through the verified
/// ladder, never abandoned), converge records a `componentFailed` and
/// consumes restart budget, and the merged report carries the code the
/// operator can grep.
final class SchedulerEarlyExit implements Exception {
  const SchedulerEarlyExit({this.pid});

  /// The named, greppable refusal code.
  static const String code = 'ecsai_scheduler_early_exit';

  /// The spawned pid that died, null when the provider recorded none.
  final int? pid;

  @override
  String toString() =>
      '$code${pid == null ? '' : ': pid $pid'} died inside the settle '
      'window (check the scheduler log: argv refusal, missing sibling '
      'realm_actor.dart, or an unreadable store)';
}

/// Boots the machine's ONE daemon for [workspace] as a DECLARED
/// supervisor component through the oka_supervisor library (no oka exe,
/// no plan file): `Supervisor.converge` spawns [daemonExecutablePath]
/// with `--mcp --local-mcp-seats --idle-exit-minutes 0` under the
/// budgeted restart policy (3 restarts / 300 s window), and readiness is
/// the daemon's OWN liveness truth — the owner pointer file exists AND
/// its recorded pid is alive — enforced by the provider's start gate,
/// not a stdout handshake (the daemon logs readiness to stderr).
///
/// Idempotent: a live daemon converges nothing (`alreadyRunning`).
/// [logPath] appends the daemon's stdout/stderr to a file through a
/// POSIX `exec`-redirection shell wrap (the shell replaces itself, so
/// the recorded pid stays the daemon's); on Windows the log is a named
/// gap (the provider keeps a bounded in-memory tail).
///
/// One converge pass per call (ADR-0040 law): a daemon that dies later
/// is restarted by the NEXT call within the budget, then `giveUp` until
/// a revision bump.
Future<Map<String, Object?>> startSupervisedEcsaiDaemon({
  required String daemonExecutablePath,
  String? workspaceHint,
  String? logPath,
  Duration readinessBudget = const Duration(seconds: 30),
}) async {
  // ONE WORLD PER MACHINE: the hint only steers realm resolution; the
  // supervised component is always the machine's realm world home.
  final workspace = _resolveMachineWorkspace(workspaceHint);
  final before = _daemonView(workspace);
  if (before['live'] == true) {
    return {
      'ok': true,
      'alreadyRunning': true,
      'supervisor': 'oka-sdk',
      'pid': ?before['pid'],
      'workspace': workspace,
    };
  }

  final command = _daemonCommand(
    workspace: workspace,
    daemonExecutablePath: daemonExecutablePath,
    logPath: logPath,
  );
  final provider = _SupervisedDaemonProvider(
    LeasedProcessProvider(
      leaseId: _componentId,
      command: ProcessCommand(command.first, command.sublist(1)),
      registry: ProcessLeaseRegistry.forProject(workspace),
    ),
    () => _daemonView(workspace)['live'] == true,
  );
  final desired = DesiredState(
    readinessBudget: readinessBudget,
    specs: [
      _serviceSpec(
        id: _componentId,
        providerName: _providerName,
        command: command,
      ),
    ],
  );

  final supervisor = Supervisor(projectRoot: workspace);
  final report = await supervisor.converge(
    desired: desired,
    factory: (name) => name == _providerName
        ? provider
        : throw StateError('unknown provider "$name"'),
    // The pass EXPLICITLY applies (ADR-0040: converge is explicit —
    // a dry run is a declared alternative, never an ambient default).
    // ignore: avoid_redundant_argument_values
    apply: true,
  );

  final after = _daemonView(workspace);
  final live = after['live'] == true;
  final record = supervisor.registry.read(supervisor.scope, _componentId);
  return {
    'ok': report.ok && live,
    'supervisor': 'oka-sdk',
    'live': live,
    'started': report.started,
    'restarted': report.restarted,
    'failedStarts': report.failedStarts,
    'pid': ?(record?.pid ?? after['pid']),
    if (report.plan.findings.isNotEmpty)
      'findings': [
        for (final finding in report.plan.findings)
          '${finding.code}: ${finding.message}',
      ],
    'workspace': workspace,
  };
}

/// Boots the realm SCHEDULER — the durable delegation lane's claimant
/// pump (harness ADR 0114 lane C, `realm_scheduler`) — as a SECOND
/// declared supervisor component (`ecsai-scheduler`).
///
/// The scheduler is SCRIPT-ONLY (the harness builds AOT artifacts for
/// the daemon and the seat, not for it), so the component command is
/// `dart run HARNESS/pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart`
/// with `--store WORLD/coordination --scheduler-id ID --max-actors N`
/// — exactly the argv `parseRealmSchedulerOptions` admits. Both halves
/// are resolved, never guessed: [schedulerPath] or [harnessRoot] must
/// name an entrypoint that EXISTS (else the named refusal
/// `scheduler_entrypoint_absent`), and [dartExecutable] or a bounded
/// discovery must find a Dart runtime (else
/// `scheduler_dart_runtime_absent`).
///
/// Readiness has no pointer file to gate on, so the gate is the LEASED
/// RECORD'S pid staying alive across a bounded settle window
/// ([settleWindow], probed every 300 ms); a child that dies inside the
/// window fails the start with the typed [SchedulerEarlyExit] fact and
/// is torn down through the provider's verified ladder.
///
/// Idempotent: a scheduler whose registry record names a live pid
/// converges nothing (`alreadyRunning`). [logPath] appends both streams
/// through the same POSIX `exec` wrap the daemon uses (Windows: a named
/// gap). One converge pass per call, budgeted restarts like the daemon.
Future<Map<String, Object?>> startSupervisedEcsaiScheduler({
  String? harnessRoot,
  String? schedulerPath,
  String? dartExecutable,
  String? workspaceHint,
  String? logPath,
  int maxActors = kDefaultSchedulerMaxActors,
  String schedulerId = kDefaultSchedulerId,
  Duration readinessBudget = const Duration(seconds: 30),
  Duration settleWindow = kSchedulerSettleWindow,
  @visibleForTesting String? debugWorkspace,
  @visibleForTesting Object? debugRegistry,
}) async {
  final resolved = await _resolveSchedulerLaunch(
    harnessRoot: harnessRoot,
    schedulerPath: schedulerPath,
    dartExecutable: dartExecutable,
  );
  if (resolved.refusal case final refusal?) {
    return {...refusal, 'component': _schedulerComponentId};
  }
  final workspace = debugWorkspace ?? _resolveMachineWorkspace(workspaceHint);
  final storePath = realmStorePath(workspace);

  final before = readSupervisedScheduler(
    workspace: workspace,
    debugRegistry: debugRegistry,
  );
  if (before['live'] == true) {
    return {
      'ok': true,
      'alreadyRunning': true,
      'supervisor': 'oka-sdk',
      'component': _schedulerComponentId,
      'pid': ?before['pid'],
      'workspace': workspace,
    };
  }

  var command = schedulerCommand(
    dartExecutable: resolved.dartExecutable!,
    schedulerScript: resolved.schedulerScript!,
    storePath: storePath,
    schedulerId: schedulerId,
    maxActors: maxActors,
  );
  if (logPath != null && !Platform.isWindows) {
    command = execWithLogWrap(command, logPath);
  }
  final provider = _SupervisedSchedulerProvider(
    LeasedProcessProvider(
      leaseId: _schedulerComponentId,
      command: ProcessCommand(command.first, command.sublist(1)),
      registry: ProcessLeaseRegistry.forProject(workspace),
      // The harness checkout is the scheduler's working directory when
      // it is known (its actor-spawn fallback resolves `bin/` under the
      // cwd); never a guess when it is not.
      workingDirectory: harnessRoot,
    ),
    settleWindow,
  );
  final desired = DesiredState(
    readinessBudget: readinessBudget,
    specs: [
      _serviceSpec(
        id: _schedulerComponentId,
        providerName: _schedulerProviderName,
        command: command,
      ),
    ],
  );

  final supervisor = Supervisor(
    projectRoot: workspace,
    registry: debugRegistry as MachineRegistry?,
  );
  final evidence = _ConvergeFindings();
  final report = await supervisor.converge(
    desired: desired,
    factory: (name) => name == _schedulerProviderName
        ? provider
        : throw StateError('unknown provider "$name"'),
    evidence: evidence,
    // ignore: avoid_redundant_argument_values
    apply: true,
  );
  return _schedulerResult(
    report: report,
    evidence: evidence,
    supervisor: supervisor,
    workspace: workspace,
    debugRegistry: debugRegistry,
  );
}

/// Converges the WHOLE world — daemon AND scheduler — in ONE
/// `Supervisor.converge` pass (one desired state, two declared
/// components, spec order = daemon first so the world's owner is up
/// before the scheduler's queue pump). Atomic at the resolution layer:
/// a missing scheduler entrypoint or Dart runtime refuses the WHOLE arm
/// by name BEFORE anything spawns — never a half-armed world.
///
/// Keep [startSupervisedEcsaiDaemon] for daemon-only compatibility;
/// this is the entrypoint the app's one-click arm uses (leg B G1: from
/// a cold machine one click must give a `task op:create` a claimant).
Future<Map<String, Object?>> startSupervisedWorld({
  required String daemonExecutablePath,
  String? harnessRoot,
  String? schedulerPath,
  String? dartExecutable,
  String? workspaceHint,
  String? daemonLogPath,
  String? schedulerLogPath,
  int maxActors = kDefaultSchedulerMaxActors,
  String schedulerId = kDefaultSchedulerId,
  Duration readinessBudget = const Duration(seconds: 30),
  Duration schedulerSettleWindow = kSchedulerSettleWindow,
  @visibleForTesting String? debugWorkspace,
  @visibleForTesting Object? debugRegistry,
}) async {
  final resolved = await _resolveSchedulerLaunch(
    harnessRoot: harnessRoot,
    schedulerPath: schedulerPath,
    dartExecutable: dartExecutable,
  );
  if (resolved.refusal case final refusal?) {
    // Both-or-neither: the refusal names the missing component AND
    // lists the world's components, so the surface shows what the arm
    // was asking for.
    return {
      ...refusal,
      'components': supervisedWorldComponentIds,
    };
  }
  final workspace = debugWorkspace ?? _resolveMachineWorkspace(workspaceHint);

  final daemonBefore = _daemonView(workspace);
  final schedulerBefore = readSupervisedScheduler(
    workspace: workspace,
    debugRegistry: debugRegistry,
  );
  if (daemonBefore['live'] == true && schedulerBefore['live'] == true) {
    return {
      'ok': true,
      'alreadyRunning': true,
      'supervisor': 'oka-sdk',
      'components': supervisedWorldComponentIds,
      'daemon': {'live': true, 'pid': ?daemonBefore['pid']},
      'scheduler': {'live': true, 'pid': ?schedulerBefore['pid']},
      'workspace': workspace,
    };
  }

  final daemonArgv = _daemonCommand(
    workspace: workspace,
    daemonExecutablePath: daemonExecutablePath,
    logPath: daemonLogPath,
  );
  var schedulerArgv = schedulerCommand(
    dartExecutable: resolved.dartExecutable!,
    schedulerScript: resolved.schedulerScript!,
    storePath: realmStorePath(workspace),
    schedulerId: schedulerId,
    maxActors: maxActors,
  );
  if (schedulerLogPath != null && !Platform.isWindows) {
    schedulerArgv = execWithLogWrap(schedulerArgv, schedulerLogPath);
  }
  final daemonProvider = _SupervisedDaemonProvider(
    LeasedProcessProvider(
      leaseId: _componentId,
      command: ProcessCommand(daemonArgv.first, daemonArgv.sublist(1)),
      registry: ProcessLeaseRegistry.forProject(workspace),
    ),
    () => _daemonView(workspace)['live'] == true,
  );
  final schedulerProvider = _SupervisedSchedulerProvider(
    LeasedProcessProvider(
      leaseId: _schedulerComponentId,
      command: ProcessCommand(
        schedulerArgv.first,
        schedulerArgv.sublist(1),
      ),
      registry: ProcessLeaseRegistry.forProject(workspace),
      workingDirectory: harnessRoot,
    ),
    schedulerSettleWindow,
  );
  final desired = DesiredState(
    readinessBudget: readinessBudget,
    specs: [
      // The daemon first: it owns (and on a cold machine creates) the
      // realm store whose durable queue the scheduler pumps.
      _serviceSpec(
        id: _componentId,
        providerName: _providerName,
        command: daemonArgv,
      ),
      _serviceSpec(
        id: _schedulerComponentId,
        providerName: _schedulerProviderName,
        command: schedulerArgv,
      ),
    ],
  );

  final supervisor = Supervisor(
    projectRoot: workspace,
    registry: debugRegistry as MachineRegistry?,
  );
  final evidence = _ConvergeFindings();
  final report = await supervisor.converge(
    desired: desired,
    factory: (name) => switch (name) {
      _providerName => daemonProvider,
      _schedulerProviderName => schedulerProvider,
      _ => throw StateError('unknown provider "$name"'),
    },
    evidence: evidence,
    // ignore: avoid_redundant_argument_values
    apply: true,
  );

  final daemonAfter = _daemonView(workspace);
  final daemonLive = daemonAfter['live'] == true;
  final schedulerAfter = readSupervisedScheduler(
    workspace: workspace,
    debugRegistry: debugRegistry,
  );
  final schedulerLive = schedulerAfter['live'] == true;
  final daemonRecord = supervisor.registry.read(supervisor.scope, _componentId);
  final schedulerRecord = supervisor.registry.read(
    supervisor.scope,
    _schedulerComponentId,
  );
  final ok = report.ok && daemonLive && schedulerLive;
  final findings = _mergedFindings(report, evidence);
  return {
    'ok': ok,
    'supervisor': 'oka-sdk',
    'components': supervisedWorldComponentIds,
    'daemon': {
      'live': daemonLive,
      'pid': ?(daemonRecord?.pid ?? daemonAfter['pid']),
    },
    'scheduler': {
      'live': schedulerLive,
      'pid': ?(schedulerRecord?.pid ?? schedulerAfter['pid']),
    },
    'started': report.started,
    'restarted': report.restarted,
    'failedStarts': report.failedStarts,
    if (!ok) 'bounce': 'world_converge_failed',
    if (findings.isNotEmpty) 'findings': findings,
    'workspace': workspace,
  };
}

/// Stops the machine's daemon for [workspace], declaratively where the
/// supervisor knows it: the registry record's identity (handle, pid,
/// identity token) drives the leased provider's verified stop ladder —
/// owned-only teardown, never a guessed signal. The converge API has no
/// absent/stop verb (planner actions are start/restart only), so the
/// provider stop IS the declarative shape; the SIGTERM fallback below
/// exists for daemons started OUTSIDE the supervisor (no record): the
/// pointer's owner pid gets a bounded SIGTERM, then one SIGKILL — the
/// same ladder `ecsai stop` runs.
Future<Map<String, Object?>> stopSupervisedEcsaiDaemon({
  required String workspace,
  Duration grace = const Duration(seconds: 10),
}) async {
  final supervisor = Supervisor(projectRoot: workspace);
  final record = supervisor.registry.read(supervisor.scope, _componentId);
  if (record != null && record.pid != null) {
    // Stop-only construction: the inner provider never spawns here —
    // stop uses the recorded ref identity (lease registry + pid +
    // identity token), never the command.
    final inner = LeasedProcessProvider(
      leaseId: _componentId,
      command: const ProcessCommand('(stop-only; never spawned)'),
      registry: ProcessLeaseRegistry.forProject(workspace),
    );
    final stopReport = await inner.stop(
      ResourceRef(
        componentId: _componentId,
        handle: record.handle ?? _componentId,
        pid: record.pid,
        identityToken: record.identityToken,
      ),
      grace: grace,
    );
    // A stop that did not VERIFY (refused: borrowed lease; unknown:
    // survivors after the ladder) is reported, never double-signaled.
    return {
      'ok': stopReport.stopped,
      'stopped': stopReport.stopped,
      'via': 'supervisor-record',
      'disposition': stopReport.disposition.name,
      'pid': ?record.pid,
      if (stopReport.message != null) 'message': stopReport.message,
      'workspace': workspace,
    };
  }

  final daemon = _daemonView(workspace);
  final pid = daemon['pid'] as int?;
  if (daemon['live'] != true || pid == null) {
    return {
      'ok': true,
      'wasRunning': false,
      'supervisor': 'oka-sdk',
      'workspace': workspace,
    };
  }
  if (!Process.killPid(pid)) {
    return {
      'ok': false,
      'bounce': 'ecsai_daemon_stop_refused',
      'supervisor': 'oka-sdk',
      'pid': pid,
      'workspace': workspace,
    };
  }
  final end = DateTime.now().add(grace);
  var escalated = false;
  while (DateTime.now().isBefore(end)) {
    if (!WorldManifestIO.pidAlive(pid)) {
      return {
        'ok': true,
        'stopped': true,
        'via': 'sigterm-fallback',
        'pid': pid,
        'escalated': escalated,
        'workspace': workspace,
      };
    }
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  escalated = true;
  Process.killPid(pid, ProcessSignal.sigkill);
  await Future<void>.delayed(const Duration(milliseconds: 500));
  return {
    'ok': true,
    'stopped': !WorldManifestIO.pidAlive(pid),
    'via': 'sigterm-fallback',
    'pid': pid,
    'escalated': true,
    'workspace': workspace,
  };
}

/// Stops the supervised scheduler for [workspace], record-driven like
/// the daemon's declarative stop. The scheduler has NO pointer file, so
/// a missing (or pid-less) record is an honest `wasRunning: false` —
/// there is nothing to find and nothing to guess. Stopping the
/// scheduler stops SPAWNING only: live actors keep their leases and
/// settle their tasks on their own (the scheduler's survival
/// semantics — it is replaceable, the work is not owned by it).
Future<Map<String, Object?>> stopSupervisedEcsaiScheduler({
  required String workspace,
  Duration grace = const Duration(seconds: 10),
  @visibleForTesting Object? debugRegistry,
}) async {
  final supervisor = Supervisor(
    projectRoot: workspace,
    registry: debugRegistry as MachineRegistry?,
  );
  final record = supervisor.registry.read(
    supervisor.scope,
    _schedulerComponentId,
  );
  if (record == null || record.pid == null) {
    return {
      'ok': true,
      'wasRunning': false,
      'component': _schedulerComponentId,
      'via': 'no-record',
      'supervisor': 'oka-sdk',
      'workspace': workspace,
    };
  }
  final inner = LeasedProcessProvider(
    leaseId: _schedulerComponentId,
    command: const ProcessCommand('(stop-only; never spawned)'),
    registry: ProcessLeaseRegistry.forProject(workspace),
  );
  final stopReport = await inner.stop(
    ResourceRef(
      componentId: _schedulerComponentId,
      handle: record.handle ?? _schedulerComponentId,
      pid: record.pid,
      identityToken: record.identityToken,
    ),
    grace: grace,
  );
  return {
    'ok': stopReport.stopped,
    'stopped': stopReport.stopped,
    'component': _schedulerComponentId,
    'via': 'supervisor-record',
    'disposition': stopReport.disposition.name,
    'pid': ?record.pid,
    if (stopReport.message != null) 'message': stopReport.message,
    'workspace': workspace,
  };
}

/// Stops the WHOLE world in the DECLARED order
/// ([supervisedWorldStopOrder]): the scheduler FIRST (stop stops
/// spawning — no further actor is claimed against a world going away),
/// the daemon SECOND through its own ladder (record-driven, with the
/// pointer-pid SIGTERM fallback for daemons started outside the
/// supervisor). Both reports ride the merged result; `ok` is the AND.
Future<Map<String, Object?>> stopSupervisedWorld({
  required String workspace,
  Duration grace = const Duration(seconds: 10),
  @visibleForTesting Object? debugRegistry,
}) async {
  final scheduler = await stopSupervisedEcsaiScheduler(
    workspace: workspace,
    grace: grace,
    debugRegistry: debugRegistry,
  );
  final daemon = await stopSupervisedEcsaiDaemon(
    workspace: workspace,
    grace: grace,
  );
  return {
    'ok': scheduler['ok'] == true && daemon['ok'] == true,
    'supervisor': 'oka-sdk',
    'stopOrder': supervisedWorldStopOrder,
    'scheduler': scheduler,
    'daemon': daemon,
    'workspace': workspace,
  };
}

/// The scheduler's supervisor-registry view — the SAME record shape the
/// daemon stop ladder reads (`MachineRegistry.read(scope, id)`), with
/// liveness as the recorded pid's real liveness: the scheduler has no
/// pointer file, so the record + pid probe IS the truth. Synchronous
/// (one small JSON read + one pid probe) so the world read model can
/// refresh it beside the doctor facts. Never throws: an unreadable
/// registry degrades to `present: false` with the error named.
Map<String, Object?> readSupervisedScheduler({
  required String workspace,
  Object? debugRegistry,
}) {
  try {
    final supervisor = Supervisor(
      projectRoot: workspace,
      registry: debugRegistry as MachineRegistry?,
    );
    final record = supervisor.registry.read(
      supervisor.scope,
      _schedulerComponentId,
    );
    if (record == null) {
      return {
        'component': _schedulerComponentId,
        'present': false,
        'live': false,
        'workspace': workspace,
      };
    }
    final pid = record.pid;
    final live = pid != null && WorldManifestIO.pidAlive(pid);
    return {
      'component': _schedulerComponentId,
      'present': true,
      'live': live,
      'pid': ?pid,
      'handle': ?record.handle,
      'startedAt': record.startedAt.toIso8601String(),
      'killPolicy': record.killPolicy.name,
      'workspace': workspace,
    };
  } on Object catch (error) {
    return {
      'component': _schedulerComponentId,
      'present': false,
      'live': false,
      'error': '$error',
      'workspace': workspace,
    };
  }
}

/// Discovers a Dart executable for the SCRIPT-ONLY scheduler (there is
/// no AOT artifact to probe). Candidates, in order: the harness
/// justfile's own DEFAULT_DART convention (`/opt/homebrew/bin/dart`),
/// the Intel-homebrew path, then a bounded `which dart` PATH probe (the
/// discovery shape the ACP installer already uses). Null when none
/// exists — callers refuse BY NAME (`scheduler_dart_runtime_absent`);
/// they never spawn a guess.
Future<String?> resolveSchedulerDartExecutable() async {
  for (final candidate in const <String>[
    '/opt/homebrew/bin/dart',
    '/usr/local/bin/dart',
  ]) {
    try {
      if (File(candidate).existsSync()) return candidate;
    } on Object {
      continue;
    }
  }
  try {
    final result = await Process.run('which', <String>['dart']);
    final path = '${result.stdout}'.trim();
    if (result.exitCode == 0 &&
        path.isNotEmpty &&
        !path.contains('\n') &&
        File(path).existsSync()) {
      return path;
    }
  } on Object {
    // A failed probe is an absent runtime, never a crash.
  }
  return null;
}

/// The daemon's liveness view through the host doctor: the SAME
/// pointer + owner-record probe `ecsai --status` serves (`live` = the
/// pointer exists AND its recorded pid is alive, realm-aware). Imported
/// from `package:xsoulspace_agentic_host` — LA already depends on the
/// host package, so the path law stays single-sourced, not duplicated.
Map<String, Object?> _daemonView(String workspace) =>
    collectEcsaiDoctorReport(
      workspace: workspace,
      pidAlive: WorldManifestIO.pidAlive,
    ).toJson()['daemon']! as Map<String, Object?>;

/// The daemon argv: executable + the RESIDENT flags. With [logPath] on
/// POSIX, an `exec` shell wrap appends both streams to the file while
/// keeping ONE process (the shell replaces itself, so the recorded pid
/// stays the daemon's).
List<String> _daemonCommand({
  required String workspace,
  required String daemonExecutablePath,
  required String? logPath,
}) {
  final argv = [
    daemonExecutablePath,
    '--workspace',
    workspace,
    '--mcp',
    '--local-mcp-seats',
    '--idle-exit-minutes',
    '0',
  ];
  if (logPath == null || Platform.isWindows) return argv;
  return execWithLogWrap(argv, logPath);
}

/// One declared service spec: the budget is DECLARED, never defaulted —
/// the approved design's explicit service shape (3 restarts in a 300 s
/// window) repeats the shape/maxRestarts defaults on purpose so the
/// spec reads as the whole policy. `env` mirrors the authored plan
/// vocabulary (`SpecCodec`) so records and revision hashes reflect the
/// command even though the wrapper reads the command from its
/// constructor, never from env.
ComponentSpec _serviceSpec({
  required String id,
  required String providerName,
  required List<String> command,
}) => ComponentSpec(
  id: id,
  providerName: providerName,
  policy: const SupervisionPolicy(
    // ignore: avoid_redundant_argument_values
    shape: SupervisionShape.service,
    // ignore: avoid_redundant_argument_values
    maxRestarts: 3,
    restartWindow: Duration(seconds: 300),
  ),
  env: {
    'command': command.first,
    'args-json': jsonEncode(command.sublist(1)),
  },
);

/// The scheduler launch resolution: the entrypoint (from
/// [schedulerPath] or [harnessRoot] + the known relative path) and the
/// Dart runtime ([dartExecutable] or discovery). A named refusal
/// instead of a spawn guess; the record carries either the resolved
/// pair or the refusal map.
typedef _SchedulerLaunch = ({
  String? schedulerScript,
  String? dartExecutable,
  Map<String, Object?>? refusal,
});

Future<_SchedulerLaunch> _resolveSchedulerLaunch({
  required String? harnessRoot,
  required String? schedulerPath,
  required String? dartExecutable,
}) async {
  final script =
      schedulerPath ??
      (harnessRoot == null || harnessRoot.isEmpty
          ? null
          : schedulerEntrypointPath(harnessRoot));
  if (script == null) {
    const finding =
        'scheduler_entrypoint_absent: neither harnessRoot nor '
        'schedulerPath named the realm scheduler entrypoint '
        '($realmSchedulerEntrypointRelative under the harness '
        'checkout) — refusing by name, never spawning a guess.';
    return (
      schedulerScript: null,
      dartExecutable: null,
      refusal: {
        'ok': false,
        'bounce': 'scheduler_entrypoint_absent',
        'findings': [finding],
      },
    );
  }
  if (!File(script).existsSync()) {
    final finding =
        'scheduler_entrypoint_absent: $script does not exist — the '
        'harness checkout is incomplete or the doctor resolved a '
        'stale root (artifacts.root / ECSAID_ROOT).';
    return (
      schedulerScript: script,
      dartExecutable: null,
      refusal: {
        'ok': false,
        'bounce': 'scheduler_entrypoint_absent',
        'findings': [finding],
      },
    );
  }
  final dart = dartExecutable ?? await resolveSchedulerDartExecutable();
  if (dart == null) {
    const finding =
        'scheduler_dart_runtime_absent: the realm scheduler is '
        'script-only (no AOT artifact exists) and no Dart '
        'executable was found (probed /opt/homebrew/bin/dart, '
        '/usr/local/bin/dart, `which dart`) — install a Dart SDK '
        'or pass dartExecutable explicitly.';
    return (
      schedulerScript: script,
      dartExecutable: null,
      refusal: {
        'ok': false,
        'bounce': 'scheduler_dart_runtime_absent',
        'findings': [finding],
      },
    );
  }
  return (schedulerScript: script, dartExecutable: dart, refusal: null);
}

/// The scheduler's merged converge result: the plan's findings plus the
/// evidence stream's start-failure messages (the typed
/// [SchedulerEarlyExit] fact and spawn failures live there, never in
/// the plan).
Map<String, Object?> _schedulerResult({
  required ConvergenceReport report,
  required _ConvergeFindings evidence,
  required Supervisor supervisor,
  required String workspace,
  Object? debugRegistry,
}) {
  final after = readSupervisedScheduler(
    workspace: workspace,
    debugRegistry: debugRegistry,
  );
  final live = after['live'] == true;
  final record = supervisor.registry.read(
    supervisor.scope,
    _schedulerComponentId,
  );
  final ok = report.ok && live;
  final findings = _mergedFindings(report, evidence);
  return {
    'ok': ok,
    'supervisor': 'oka-sdk',
    'component': _schedulerComponentId,
    'live': live,
    'started': report.started,
    'restarted': report.restarted,
    'failedStarts': report.failedStarts,
    'pid': ?(record?.pid ?? after['pid']),
    if (!ok) 'bounce': 'scheduler_start_failed',
    if (findings.isNotEmpty) 'findings': findings,
    'workspace': workspace,
  };
}

List<String> _mergedFindings(
  ConvergenceReport report,
  _ConvergeFindings evidence,
) => [
  for (final finding in report.plan.findings)
    '${finding.code}: ${finding.message}',
  ...evidence.failures,
];

/// Collects the converge pass's provider-failure evidence into finding
/// strings: plan findings carry planner codes, while a failed START's
/// reason (spawn failure, [SchedulerEarlyExit], readiness timeout)
/// rides the evidence stream — the merged report must name BOTH.
final class _ConvergeFindings implements EvidenceSink {
  final List<String> failures = <String>[];

  @override
  void add(LifecycleEvent event) {
    switch (event) {
      case ComponentFailed(:final componentId, :final cause, :final message):
        failures.add('$componentId: ${message ?? cause.name}');
      case ReadinessTimeout(:final componentId, :final budget):
        failures.add(
          '$componentId: readiness timeout within '
          '${budget.inMilliseconds}ms',
        );
      default:
        break;
    }
  }
}

/// The daemon provider: spawn/stop/inspect mechanics come from the
/// leased process provider; THIS layer adds the readiness gate the
/// substrate cannot declare — the sealed `Readiness` dialects have no
/// "pointer file AND recorded pid alive" kind (a bare `FilePresent`
/// cannot tell pointer debris from a live daemon), so the gate is
/// provider-internal probe mechanics: converge's budget Timer + the
/// request cancellation bound the wait, and a failed gate stops the
/// spawned child (never abandons it) and fails the start — a typed
/// `ReadinessTimeout` fact and a consumed restart budget on the next
/// converge pass.
final class _SupervisedDaemonProvider implements ResourceProvider {
  _SupervisedDaemonProvider(this._inner, this._isLive);

  final LeasedProcessProvider _inner;
  final bool Function() _isLive;

  @override
  ProviderCapabilities get capabilities =>
      const ProviderCapabilities(readinessProbe: true, durableIdentity: true);

  @override
  Future<StartReport> start(StartRequest request) async {
    final report = await _inner.start(request);
    while (true) {
      var live = false;
      try {
        live = _isLive();
      } on Object {
        live = false; // a failed probe is not a live daemon; keep waiting
      }
      if (live) return report;
      if (request.cancellation.isCancelled) {
        await _inner.stop(report.ref, grace: const Duration(seconds: 2));
        throw StartCancelled(request.component.id);
      }
      await Future<void>.delayed(_probeInterval);
    }
  }

  @override
  Future<Observation> inspect(ResourceRef ref) => _inner.inspect(ref);

  @override
  Future<StopReport> stop(ResourceRef ref, {required Duration grace}) =>
      _inner.stop(ref, grace: grace);

  @override
  Future<Observation> reconcile(ResourceRef ref) => _inner.reconcile(ref);
}

/// The scheduler provider: the leased provider spawns and records; THIS
/// layer adds the settle-window gate the scheduler's readiness needs —
/// there is no pointer file, so the LEASED RECORD's pid must stay alive
/// across a bounded window (probed every [_probeInterval]). A child
/// that dies inside the window is stopped through the verified ladder
/// (never abandoned) and fails the start with the typed
/// [SchedulerEarlyExit] fact; a cancellation (converge's budget Timer)
/// tears down and rethrows [StartCancelled] exactly like the daemon
/// gate.
final class _SupervisedSchedulerProvider implements ResourceProvider {
  _SupervisedSchedulerProvider(this._inner, this._settleWindow);

  final LeasedProcessProvider _inner;
  final Duration _settleWindow;

  @override
  ProviderCapabilities get capabilities =>
      const ProviderCapabilities(readinessProbe: true, durableIdentity: true);

  @override
  Future<StartReport> start(StartRequest request) async {
    final report = await _inner.start(request);
    final pid = report.ref.pid;
    if (pid == null) {
      // The leased provider records the spawned pid before returning;
      // an absent pid is a provider fault, never a ready start.
      await _inner.stop(report.ref, grace: const Duration(seconds: 2));
      throw const SchedulerEarlyExit();
    }
    final deadline = DateTime.now().add(_settleWindow);
    while (true) {
      if (request.cancellation.isCancelled) {
        await _inner.stop(report.ref, grace: const Duration(seconds: 2));
        throw StartCancelled(request.component.id);
      }
      if (!WorldManifestIO.pidAlive(pid)) {
        await _inner.stop(report.ref, grace: const Duration(seconds: 2));
        throw SchedulerEarlyExit(pid: pid);
      }
      if (!DateTime.now().isBefore(deadline)) return report;
      await Future<void>.delayed(_probeInterval);
    }
  }

  @override
  Future<Observation> inspect(ResourceRef ref) => _inner.inspect(ref);

  @override
  Future<StopReport> stop(ResourceRef ref, {required Duration grace}) =>
      _inner.stop(ref, grace: grace);

  @override
  Future<Observation> reconcile(ResourceRef ref) => _inner.reconcile(ref);
}
