import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/supervisor_agent_client.dart';
import 'package:lastanswer/settings/features/supervisor_agent_provider.dart';
import 'package:lastanswer/settings/features/supervisor_execution.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:resource_composition/resource_composition.dart';

/// The client boundary: a fake world. It records what the provider asked
/// the world to do and answers with the world's own words.
final class FakeWorld implements SupervisorAgentClient {
  FakeWorld({
    this.outcomes = const [],
    this.refusal,
    this.admission = const SupervisorAgentAdmission(
      taskId: 'delegation:actor:req-1',
      admissionBeatId: 'beat-1',
      state: 'queued',
    ),
  });

  /// The states the world reports, in order. The last one repeats.
  final List<SupervisorAgentOutcome> outcomes;

  /// When set, the admission is refused with this code.
  final SupervisorAgentRefusal? refusal;

  final SupervisorAgentAdmission admission;

  int outcomeCalls = 0;
  int cancelCalls = 0;
  int admitCalls = 0;
  final List<String> admittedTasks = [];

  @override
  Future<SupervisorAgentAdmission> admit({
    required final String task,
    required final String requestId,
  }) async {
    admitCalls++;
    admittedTasks.add(task);
    final denied = refusal;
    if (denied != null) throw denied;
    return admission;
  }

  @override
  Future<SupervisorAgentOutcome> outcome({
    required final SupervisorAgentAdmission admission,
  }) async {
    if (outcomes.isEmpty) {
      return const SupervisorAgentOutcome(
        state: 'queued',
        terminal: false,
        succeeded: false,
      );
    }
    final index = outcomeCalls < outcomes.length
        ? outcomeCalls
        : outcomes.length - 1;
    outcomeCalls++;
    return outcomes[index];
  }

  @override
  Future<SupervisorAgentOutcome> cancel({
    required final SupervisorAgentAdmission admission,
    required final String requestId,
  }) async {
    cancelCalls++;
    return const SupervisorAgentOutcome(
      state: 'cancelled',
      terminal: true,
      succeeded: false,
      cancelled: true,
    );
  }
}

const _verified = SupervisorAgentOutcome(
  state: 'loop_settled',
  terminal: true,
  succeeded: true,
);

const _open = SupervisorAgentOutcome(
  state: 'started',
  terminal: false,
  succeeded: false,
);

const _failed = SupervisorAgentOutcome(
  state: 'loop_settled',
  terminal: true,
  succeeded: false,
  failure: 'check_failed: the check did not pass',
);

ComponentSpec _spec({
  final String id = 'agent',
  final Map<String, String> env = const {'instructions': 'Do the thing'},
}) => ComponentSpec(
  id: id,
  providerName: 'agent',
  policy: const SupervisionPolicy(shape: SupervisionShape.job),
  env: env,
);

StartRequest _request(
  final SupervisorAgentProvider provider, {
  final Duration budget = const Duration(seconds: 5),
  final Cancellation? cancellation,
}) => StartRequest(
  component: Component(id: 'agent', provider: provider),
  mode: StartMode.start,
  dependencies: ResolvedOutputs.empty,
  readinessBudget: budget,
  cancellation: cancellation ?? Cancellation(),
);

void main() {
  group('SupervisorAgentProvider', () {
    test('a queued receipt never completes the run', () async {
      final world = FakeWorld(outcomes: const [_open, _open, _verified]);
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec()},
        pollInterval: const Duration(milliseconds: 1),
      );

      final report = await provider.start(_request(provider));

      // The run ended only when the WORLD settled the delegation.
      expect(world.outcomeCalls, 3);
      expect(world.admitCalls, 1);
      expect(world.admittedTasks, ['Do the thing']);
      expect(report.ref.handle, 'delegation:actor:req-1');
      expect(report.ref.identityToken, 'beat-1');
    });

    test('an unverified settlement is a failure, never a success', () async {
      final world = FakeWorld(outcomes: const [_failed]);
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec()},
        pollInterval: const Duration(milliseconds: 1),
      );

      await expectLater(
        provider.start(_request(provider)),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('did not verify'),
          ),
        ),
      );
    });

    test('a cancelled delegation is a failure, not a success', () async {
      final world = FakeWorld(
        outcomes: const [
          SupervisorAgentOutcome(
            state: 'cancelled',
            terminal: true,
            succeeded: false,
            cancelled: true,
          ),
        ],
      );
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec()},
        pollInterval: const Duration(milliseconds: 1),
      );

      await expectLater(
        provider.start(_request(provider)),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('cancelled'),
          ),
        ),
      );
    });

    test('a refusal is visible and never substituted', () async {
      final world = FakeWorld(
        refusal: const SupervisorAgentRefusal(
          'task_delegation_not_authorized',
        ),
      );
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec()},
      );

      await expectLater(
        provider.start(_request(provider)),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('task_delegation_not_authorized'),
          ),
        ),
      );
      expect(world.outcomeCalls, 0);
    });

    test('cancellation joins the world before the start is abandoned',
        () async {
      final world = FakeWorld(outcomes: const [_open]);
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec()},
        pollInterval: const Duration(milliseconds: 5),
      );
      final cancellation = Cancellation();
      final start = provider.start(
        _request(
          provider,
          budget: const Duration(seconds: 30),
          cancellation: cancellation,
        ),
      );
      final expectation = expectLater(start, throwsA(isA<StartCancelled>()));
      // The run is open: cancel it and the world must be told.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      cancellation.cancel();

      await expectation;
      expect(world.cancelCalls, 1);
    });

    test('a resolver that refuses stops the run with the exact words',
        () async {
      final world = FakeWorld();
      final provider = SupervisorAgentProvider(
        specs: {'agent': _spec()},
        resolver: () async => const SupervisorAgentClientResolution.refused(
          'the seat does not serve agent_participation — delegation is not '
          'available on this seat',
        ),
      );

      await expectLater(
        provider.start(_request(provider)),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('cannot run'),
          ),
        ),
      );
      // The world was never asked: the capability was absent.
      expect(world.admitCalls, 0);
    });

    test('a resolver that serves a client runs the automation', () async {
      final world = FakeWorld(outcomes: const [_verified]);
      final provider = SupervisorAgentProvider(
        specs: {'agent': _spec()},
        resolver: () async =>
            SupervisorAgentClientResolution.available(world),
      );

      final report = await provider.start(_request(provider));

      expect(world.admitCalls, 1);
      expect(report.ref.handle, 'delegation:actor:req-1');
    });

    test('a client in hand wins over a resolver', () async {
      final world = FakeWorld(outcomes: const [_verified]);
      var resolverCalls = 0;
      final provider = SupervisorAgentProvider(
        specs: {'agent': _spec()},
        client: world,
        resolver: () async {
          resolverCalls++;
          return const SupervisorAgentClientResolution.refused(
            'the resolver was not consulted',
          );
        },
      );

      final report = await provider.start(_request(provider));

      expect(resolverCalls, 0);
      expect(world.admitCalls, 1);
      expect(report.ref.handle, 'delegation:actor:req-1');
    });

    test('without any client the run refuses visibly', () async {
      final provider = SupervisorAgentProvider(specs: {'agent': _spec()});

      await expectLater(
        provider.start(_request(provider)),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('not connected'),
          ),
        ),
      );
    });

    test('an automation without instructions is a declaration bug', () async {
      final world = FakeWorld();
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec(env: const {})},
      );

      await expectLater(
        provider.start(_request(provider)),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('declares no instructions'),
          ),
        ),
      );
      expect(world.admitCalls, 0);
    });

    test('an unfinished delegation is stopped in the world, not abandoned',
        () async {
      final world = FakeWorld(outcomes: const [_open]);
      final provider = SupervisorAgentProvider(
        client: world,
        specs: {'agent': _spec()},
        pollInterval: const Duration(milliseconds: 1),
      );

      await expectLater(
        provider.start(
          _request(provider, budget: const Duration(milliseconds: 20)),
        ),
        throwsA(
          isA<StateError>().having(
            (e) => '$e',
            'message',
            contains('did not settle'),
          ),
        ),
      );
      expect(world.cancelCalls, 1);
    });
  });

  group('SupervisorExecution with the world client', () {
    late Directory root;
    late Directory plans;
    late MachineRegistry registry;
    setUp(() async {
      root = await Directory.systemTemp.createTemp('la_agent_execution_');
      plans = Directory('${root.path}/plans')..createSync();
      registry = MachineRegistry(root: '${root.path}/registry');
    });
    tearDown(() => root.delete(recursive: true));

    test('an agent automation runs in the world and records the evidence',
        () async {
      SpecStore(plans).save('agent', DesiredState(specs: [_spec()]));
      final world = FakeWorld(outcomes: const [_verified]);
      final execution = SupervisorExecution(
        storeRoot: plans,
        appRoot: root,
        registry: registry,
        agentClient: world,
      );

      await execution.run();

      expect(execution.lastError, isNull);
      final record = registry.snapshot(registry.scopeFor(root.path))['agent'];
      expect(record, isNotNull);
      expect(record!.lastRun, 'succeeded');
      // The world's own task is named in the run log: the durable
      // evidence of WHICH delegated task ran.
      expect(
        execution.logLines['agent']?.join('\n'),
        contains('delegation:actor:req-1'),
      );
      expect(world.admittedTasks, ['Do the thing']);
      await execution.close();
    });

    test('an unverified delegation is recorded as a failed run', () async {
      SpecStore(plans).save('agent', DesiredState(specs: [_spec()]));
      final world = FakeWorld(outcomes: const [_failed]);
      final execution = SupervisorExecution(
        storeRoot: plans,
        appRoot: root,
        registry: registry,
        agentClient: world,
      );

      await execution.run();

      expect(execution.lastError, contains('failed to start'));
      final record = registry.snapshot(registry.scopeFor(root.path))['agent'];
      expect(record!.lastRun, 'failed');
      expect(
        execution.logLines['agent']?.join('\n'),
        contains('did not verify'),
      );
      await execution.close();
    });

    test('a refused delegation is a failed run, never a success', () async {
      SpecStore(plans).save('agent', DesiredState(specs: [_spec()]));
      final world = FakeWorld(
        refusal: const SupervisorAgentRefusal(
          'task_delegation_not_authorized',
        ),
      );
      final execution = SupervisorExecution(
        storeRoot: plans,
        appRoot: root,
        registry: registry,
        agentClient: world,
      );

      await execution.run();

      expect(execution.lastError, contains('failed to start'));
      final record = registry.snapshot(registry.scopeFor(root.path))['agent'];
      expect(record!.lastRun, 'failed');
      expect(
        execution.logLines['agent']?.join('\n'),
        contains('task_delegation_not_authorized'),
      );
      await execution.close();
    });

    test('a resolver refusal reaches the surface in words', () async {
      SpecStore(plans).save('agent', DesiredState(specs: [_spec()]));
      final execution = SupervisorExecution(
        storeRoot: plans,
        appRoot: root,
        registry: registry,
        agentClientResolver: () async =>
            const SupervisorAgentClientResolution.refused(
              'the world "w1" is not reachable from this device',
            ),
      );

      await execution.run();

      expect(execution.lastError, contains('failed to start'));
      expect(
        execution.logLines['agent']?.join('\n'),
        contains('not reachable from this device'),
      );
      final record = registry.snapshot(registry.scopeFor(root.path))['agent'];
      expect(record!.lastRun, 'failed');
      await execution.close();
    });

    test('a resolver that serves a client runs the automation', () async {
      SpecStore(plans).save('agent', DesiredState(specs: [_spec()]));
      final world = FakeWorld(outcomes: const [_verified]);
      final execution = SupervisorExecution(
        storeRoot: plans,
        appRoot: root,
        registry: registry,
        agentClientResolver: () async =>
            SupervisorAgentClientResolution.available(world),
      );

      await execution.run();

      expect(execution.lastError, isNull);
      final record = registry.snapshot(registry.scopeFor(root.path))['agent'];
      expect(record!.lastRun, 'succeeded');
      expect(world.admittedTasks, ['Do the thing']);
      await execution.close();
    });
    test('a client installed after construction still runs', () async {
      SpecStore(plans).save('agent', DesiredState(specs: [_spec()]));
      final world = FakeWorld(outcomes: const [_verified]);
      final execution = SupervisorExecution(
        storeRoot: plans,
        appRoot: root,
        registry: registry,
      );

      // The app installs its client after the execution exists.
      execution.agentClient = world;
      await execution.run();

      expect(execution.lastError, isNull);
      final record = registry.snapshot(registry.scopeFor(root.path))['agent'];
      expect(record!.lastRun, 'succeeded');
      expect(world.admittedTasks, ['Do the thing']);
      await execution.close();
    });
  });
}
