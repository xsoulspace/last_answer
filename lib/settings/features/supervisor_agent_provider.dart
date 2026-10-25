/// The AGENT provider for app-open automations: it runs one automation
/// by DELEGATING it to the authorized harness world through the app's
/// existing harness client ([SupervisorAgentClient]) — the same owner
/// (the app-scoped supervisor session) and the same client model as
/// every other automation. There is no second executor here.
///
/// The contract it honours (oka ADR-0040 / ADR-0042, LA ADR 0020):
///
/// - a JOB's start IS the completed run: [start] returns only after the
///   world has SETTLED the delegation. The admission receipt
///   (`state: queued`) is never a completion;
/// - cancellation joins the active pass: the delegation is cancelled in
///   the world before the start is abandoned — never left running
///   behind the app's back;
/// - every terminal state is honest: a failed, cancelled, unknown or
///   unproven delegation is a VISIBLE FAILURE (the supervisor records
///   `lastRun: failed`), never a fabricated success;
/// - the evidence is durable: the world's own admission beat keeps the
///   delegation's state, and the supervisor's registry keeps the run's
///   terminal record.
library;

import 'dart:async';

import 'package:lastanswer/settings/features/supervisor_agent_client.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:resource_composition/resource_composition.dart';

/// Runs agent automations by delegating to the authorized world.
final class SupervisorAgentProvider implements ResourceProvider {
  SupervisorAgentProvider({
    required this.specs,
    this.client,
    this.resolver,
    this.pollInterval = const Duration(seconds: 2),
  });

  /// The existing harness client (the world's seat or the embedded
  /// tools), when it is already in hand. Never a second client, never a
  /// substituted provider.
  final SupervisorAgentClient? client;

  /// Where the client comes from when it is not in hand: the app's
  /// existing seat over the currently authorized world, earned when the
  /// automation actually runs.
  final SupervisorAgentClientResolver? resolver;

  /// The declared agent specs, keyed by component id — the provider is
  /// composed per converge, so it sees exactly the current declaration.
  final Map<String, ComponentSpec> specs;

  /// How often the durable delegation state is re-read while the
  /// delegation is open.
  final Duration pollInterval;

  @override
  ProviderCapabilities get capabilities =>
      const ProviderCapabilities(durableIdentity: true, readinessProbe: true);

  @override
  Future<StartReport> start(final StartRequest request) async {
    final spec = specs[request.component.id];
    if (spec == null) {
      throw StateError(
        'no agent automation composed for "${request.component.id}"',
      );
    }
    final task = _taskOf(spec);
    final requestId = 'supervisor-${spec.id}-'
        '${DateTime.now().microsecondsSinceEpoch}';
    final log = request.log;
    final (client, refusal) = await _resolve(spec.id);
    if (client == null) {
      log?.add('refused: $refusal');
      throw StateError(
        'agent automation "${spec.id}" cannot run: $refusal',
      );
    }
    log?.add('agent automation "${spec.id}" → delegated to the world');
    final SupervisorAgentAdmission admission;
    try {
      admission = await client.admit(task: task, requestId: requestId);
    } on SupervisorAgentRefusal catch (refusal) {
      log?.add('refused: $refusal');
      throw StateError(
        'agent automation "${spec.id}" was refused: $refusal',
      );
    }
    // The receipt is an ADMISSION. The run is over only when the world
    // says so.
    log?.add('admitted ${admission.taskId} (${admission.state})');

    final deadline = DateTime.now().add(request.readinessBudget);
    var outcome = await _outcome(client, admission, log);
    while (!outcome.terminal) {
      if (request.cancellation.isCancelled) {
        await _cancel(client, admission, requestId, log);
        throw StartCancelled(request.component.id);
      }
      if (!DateTime.now().isBefore(deadline)) {
        log?.add(
          '${admission.taskId} did not settle within '
          '${request.readinessBudget.inSeconds}s',
        );
        await _cancel(client, admission, requestId, log);
        throw StateError(
          'agent automation "${spec.id}" did not settle within '
          '${request.readinessBudget.inSeconds}s',
        );
      }
      await _wait(request.cancellation, pollInterval);
      if (request.cancellation.isCancelled) {
        await _cancel(client, admission, requestId, log);
        throw StartCancelled(request.component.id);
      }
      outcome = await _outcome(client, admission, log);
    }

    log?.add('${admission.taskId} settled: ${outcome.describe}');
    if (outcome.succeeded) {
      return StartReport(
        ref: ResourceRef(
          componentId: spec.id,
          handle: admission.taskId,
          identityToken: admission.admissionBeatId,
        ),
        outputs: _outputsOf(spec, admission, outcome),
      );
    }
    if (outcome.cancelled) {
      log?.add('${admission.taskId} was cancelled');
      throw StateError('agent automation "${spec.id}" was cancelled');
    }
    log?.add(
      '${admission.taskId} did not verify: '
      '${outcome.failure ?? outcome.state}',
    );
    throw StateError(
      'agent automation "${spec.id}" did not verify: '
      '${outcome.failure ?? outcome.state}',
    );
  }

  /// Reads the world's durable state, and says so when it cannot.
  Future<SupervisorAgentOutcome> _outcome(
    final SupervisorAgentClient client,
    final SupervisorAgentAdmission admission,
    final LogTap? log,
  ) async {
    try {
      return await client.outcome(admission: admission);
    } on SupervisorAgentRefusal catch (refusal) {
      log?.add('the delegation state could not be read: $refusal');
      rethrow;
    }
  }

  /// The client for this run: the one in hand, else the one the app
  /// resolves for the authorized world. An absent client is a VISIBLE
  /// refusal with the world's own words — never a substituted provider.
  Future<(SupervisorAgentClient?, String?)> _resolve(
    final String componentId,
  ) async {
    // A client already in hand is the app's own explicit choice: it
    // wins over a resolver, because the app installed it on purpose.
    final held = this.client;
    if (held != null) return (held, null);
    final resolver = this.resolver;
    if (resolver == null) {
      final client = this.client;
      if (client == null) {
        return (null, 'agent automation execution is not connected');
      }
      return (client, null);
    }
    final resolution = await resolver();
    final client = resolution.client;
    if (client == null) {
      return (null, resolution.refusal ?? 'the world served no client');
    }
    return (client, null);
  }

  /// The durable evidence a declaration may ask for: the world's own
  /// task id, its admission beat and the state it settled in.
  ResolvedOutputs _outputsOf(
    final ComponentSpec spec,
    final SupervisorAgentAdmission admission,
    final SupervisorAgentOutcome outcome,
  ) => ResolvedOutputs({
    for (final id in spec.provides)
      id: {
        'taskId': admission.taskId,
        'admissionBeatId': admission.admissionBeatId,
        'state': outcome.state,
        'verified': outcome.succeeded,
      },
  });

  @override
  Future<Observation> inspect(final ResourceRef ref) async {
    final admission = _admissionOf(ref);
    if (admission == null) {
      return const Observation(
        state: ResourceState.unknown,
        cause: TerminalCause.unknown,
        message: 'no delegation identity on this record',
      );
    }
    final (client, refusal) = await _resolve(ref.componentId);
    if (client == null) {
      return Observation(
        state: ResourceState.unknown,
        cause: TerminalCause.unknown,
        message: refusal,
      );
    }
    try {
      return _observationOf(await client.outcome(admission: admission));
    } on SupervisorAgentRefusal catch (refusal) {
      return Observation(
        state: ResourceState.unknown,
        cause: TerminalCause.unknown,
        message: '$refusal',
      );
    }
  }

  @override
  Future<StopReport> stop(
    final ResourceRef ref, {
    required final Duration grace,
  }) async {
    final admission = _admissionOf(ref);
    if (admission == null) {
      return const StopReport(
        disposition: StopDisposition.unknown,
        message: 'no delegation identity on this record',
      );
    }
    final (client, refusal) = await _resolve(ref.componentId);
    if (client == null) {
      return StopReport(
        disposition: StopDisposition.unknown,
        message: refusal,
      );
    }
    try {
      final outcome = await client.cancel(
        admission: admission,
        requestId:
            'supervisor-stop-${ref.componentId}-'
            '${DateTime.now().microsecondsSinceEpoch}',
      );
      if (!outcome.terminal) {
        return const StopReport(
          disposition: StopDisposition.unknown,
          message: 'the world did not confirm the cancellation',
        );
      }
      return StopReport(
        disposition: outcome.succeeded
            ? StopDisposition.alreadyStopped
            : StopDisposition.stopped,
        cause: TerminalCause.exited,
        message: outcome.describe,
      );
    } on SupervisorAgentRefusal catch (refusal) {
      return StopReport(
        disposition: StopDisposition.unknown,
        message: '$refusal',
      );
    }
  }

  @override
  Future<Observation> reconcile(final ResourceRef ref) async {
    final admission = _admissionOf(ref);
    if (admission == null) {
      return const Observation(
        state: ResourceState.unknown,
        cause: TerminalCause.unknown,
        message: 'no delegation identity on this record',
      );
    }
    final (client, refusal) = await _resolve(ref.componentId);
    if (client == null) {
      return Observation(
        state: ResourceState.unknown,
        cause: TerminalCause.unknown,
        message: refusal,
      );
    }
    try {
      return _observationOf(await client.outcome(admission: admission));
    } on SupervisorAgentRefusal catch (refusal) {
      return Observation(
        state: ResourceState.unknown,
        cause: TerminalCause.unknown,
        message: '$refusal',
      );
    }
  }

  /// The task the automation delegates: the declared instructions. A
  /// declaration without instructions is a declaration bug, not an empty
  /// run.
  String _taskOf(final ComponentSpec spec) {
    final instructions = spec.env['instructions'] ?? spec.env['task'];
    if (instructions == null || instructions.trim().isEmpty) {
      throw StateError(
        'agent automation "${spec.id}" declares no instructions',
      );
    }
    return instructions;
  }

  SupervisorAgentAdmission? _admissionOf(final ResourceRef ref) {
    final handle = ref.handle;
    final beat = ref.identityToken ?? '';
    if (handle.isEmpty || beat.isEmpty) return null;
    return SupervisorAgentAdmission(
      taskId: handle,
      admissionBeatId: beat,
      state: '',
    );
  }

  Observation _observationOf(final SupervisorAgentOutcome outcome) {
    if (!outcome.terminal) {
      return Observation(state: ResourceState.ready, message: outcome.describe);
    }
    if (outcome.succeeded) {
      return Observation(
        state: ResourceState.stopped,
        cause: TerminalCause.exited,
        message: outcome.describe,
      );
    }
    if (outcome.cancelled) {
      return Observation(
        state: ResourceState.stopped,
        cause: TerminalCause.exited,
        message: outcome.describe,
      );
    }
    return Observation(
      state: ResourceState.crashed,
      cause: TerminalCause.providerFault,
      message: outcome.describe,
    );
  }

  Future<void> _cancel(
    final SupervisorAgentClient client,
    final SupervisorAgentAdmission admission,
    final String requestId,
    final LogTap? log,
  ) async {
    try {
      final outcome = await client.cancel(
        admission: admission,
        requestId: 'supervisor-cancel-$requestId',
      );
      log?.add('cancelled ${admission.taskId}: ${outcome.describe}');
    } on SupervisorAgentRefusal catch (refusal) {
      // The cancellation could not be confirmed — say so; never pretend.
      log?.add('cancellation of ${admission.taskId} was refused: $refusal');
    }
  }

  /// Waits for the next poll, but wakes at once when the start is
  /// cancelled.
  Future<void> _wait(
    final Cancellation cancellation,
    final Duration interval,
  ) async {
    final completer = Completer<void>();
    final timer = Timer(interval, completer.complete);
    unawaited(
      cancellation.future.then<void>((_) {
        if (!completer.isCompleted) completer.complete();
      }),
    );
    await completer.future;
    timer.cancel();
  }
}
