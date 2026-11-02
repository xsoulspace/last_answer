/// The `io` variant of the supervised daemon adapter (mobile + desktop):
/// oka_supervisor's `DesiredState`/`Supervisor.converge` drive the
/// daemon as ONE declared service; the host doctor's pointer + pid probe
/// is the readiness truth; the supervisor record's identity drives the
/// stop ladder.
///
/// Platform note: this file needs `dart:io` (the `Process` machinery
/// oka_core wraps), so it is compiled only where `dart.library.io`
/// holds — the facade gates the web build to the stub variant.
library;

import 'dart:convert';
import 'dart:io';

import 'package:oka_core/oka_core.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:resource_composition/resource_composition.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show WorldManifestIO, collectEcsaiDoctorReport;

/// The one declared component of the machine's desired state.
const String _componentId = 'ecsai-daemon';

/// The provider name this adapter's factory resolves (guide vocabulary:
/// the mechanics come from a leased process provider).
const String _providerName = 'leased';

/// Poll cadence for the pointer-liveness gate (the host's own
/// `_awaitDaemonLive` cadence).
const Duration _probeInterval = Duration(milliseconds: 300);

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
  required String workspace,
  required String daemonExecutablePath,
  String? logPath,
  Duration readinessBudget = const Duration(seconds: 30),
}) async {
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
      // `env` mirrors the authored plan vocabulary (`SpecCodec`) so
      // records and revision hashes reflect the command even though the
      // wrapper reads the command from its constructor, never from env.
      ComponentSpec(
        id: _componentId,
        providerName: _providerName,
        // The budget is DECLARED, never defaulted: the approved design's
        // explicit service shape (3 restarts in a 300 s window) repeats
        // the shape/maxRestarts defaults on purpose so the spec reads as
        // the whole policy.
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
  final q = String.fromCharCode(92) + String.fromCharCode(39);
  String quote(String part) => "'${part.replaceAll("'", q)}'";
  final wrapped = argv.map(quote).join(' ');
  return ['/bin/sh', '-c', 'exec $wrapped >> ${quote(logPath)} 2>&1'];
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
