import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:lastanswer/settings/features/supervisor_agent_client.dart';
import 'package:lastanswer/settings/features/supervisor_agent_provider.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:resource_composition/resource_composition.dart';

/// One execution owner retained by the app, separate from settings widgets.
final class SupervisorExecution extends ChangeNotifier {
  SupervisorExecution({
    required final Directory storeRoot,
    required final Directory appRoot,
    final MachineRegistry? registry,
    final ProviderFactory? agentFactory,
    SupervisorAgentClient? agentClient,
    SupervisorAgentClientResolver? agentClientResolver,
  }) {
    this.agentClient = agentClient;
    this.agentClientResolver = agentClientResolver;
    _session = AppSupervisorSession(
      supervisor: Supervisor(projectRoot: appRoot.path, registry: registry),
      loadDesired: () async {
        final store = SpecStore(storeRoot);
        return DesiredState(
          specs: [
            for (final name in store.names()) ...?store.load(name)?.specs,
          ],
        );
      },
      factoryFor: (final desired) {
        final agentSpecs = [
          for (final spec in desired.specs)
            if (spec.providerName == 'agent') spec,
        ];
        // An agent automation runs in the authorized world through the
        // app's existing harness client. With no such client the run is
        // REFUSED, visibly — never substituted by another provider.
        if (agentFactory == null &&
            this.agentClient == null &&
            this.agentClientResolver == null &&
            agentSpecs.isNotEmpty) {
          throw StateError('Agent automation execution is not connected');
        }
        final processes = SupervisorProcessProvider(
          desired: DesiredState(
            specs: [
              for (final spec in desired.specs)
                if (spec.providerName == 'process') spec,
            ],
          ),
          projectRoot: appRoot.path,
        );
        final agents = agentSpecs.isEmpty
            ? null
            : SupervisorAgentProvider(
                client: this.agentClient,
                resolver: this.agentClientResolver,
                specs: {for (final spec in agentSpecs) spec.id: spec},
              );        return (final name) {
          if (name == 'process') return processes.factory(name);
          if (name == 'agent') {
            if (agentFactory != null) return agentFactory(name);
            if (agents != null) return agents;
            throw ArgumentError('Agent automation execution is not connected');
          }
          throw ArgumentError('unknown provider "$name"');
        };
      },
      onReport: (final report) {
        lastReport = report.describe();
        notifyListeners();
      },
      onError: (final error, final stack) {
        lastError = '$error';
        notifyListeners();
      },
      onLog: (final id, final log) {
        logs[id] = log;
        unawaited(_logSubscriptions.remove(id)?.cancel());
        _logSubscriptions[id] = log.stream.listen((final line) {
          notifyListeners();
        });
      },
    );
  }

  late final AppSupervisorSession _session;
  final Map<String, LogTap> logs = {};
  final Map<String, StreamSubscription<String>> _logSubscriptions = {};

  /// Where an agent automation gets its client: the app's existing
  /// harness client for the currently authorized world, resolved when
  /// the run starts. Replaced when the app re-binds the world — the
  /// seat it holds belongs to whoever bound it.
  SupervisorAgentClientResolver? agentClientResolver;

  /// The client in hand, when the app installed one. Read when the run
  /// starts, so an install that lands after construction still counts.
  /// A fixed client wins over the resolver: an explicit install is the
  /// app's own choice of client.
  SupervisorAgentClient? agentClient;
  Map<String, List<String>> get logLines => {
    for (final entry in logs.entries) entry.key: entry.value.tail(20),
  };
  String? lastError;
  String? lastReport;
  bool get enabled => _session.enabled;
  bool get running => _session.running;

  void enable() {
    lastError = null;
    _session.enable();
    notifyListeners();
  }

  void pause() {
    _session.pause();
    notifyListeners();
  }

  void cancel() {
    _session.cancel();
    notifyListeners();
  }

  Future<void> run() async {
    lastError = null;
    try {
      final future = _session.converge();
      notifyListeners();
      final report = await future;
      // A failed start is a visible failure: the converge reports it in
      // its count, the registry keeps the terminal record, and the run
      // log names the reason. The pane must not read a failed automation
      // as a quiet pass.
      if (report.failedStarts > 0) {
        lastError =
            '${report.failedStarts} automation(s) failed to start — see the '
            'run log';
      }
    } on Object catch (error) {
      lastError = '$error';
    } finally {
      notifyListeners();
    }
  }

  Future<List<StopReport>> close() async {
    final reports = await _session.close();
    for (final subscription in _logSubscriptions.values) {
      await subscription.cancel();
    }
    _logSubscriptions.clear();
    return reports;
  }

  Future<void> stop() async {
    final reports = await _session.stop();
    final unknown = reports.where((final report) => !report.stopped);
    if (unknown.isNotEmpty) {
      lastError = unknown.map((final report) => report.message).join('\n');
    }
    notifyListeners();
  }
}
