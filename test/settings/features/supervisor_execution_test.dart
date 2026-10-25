import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/supervisor_execution.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:resource_composition/resource_composition.dart';

void main() {
  late Directory root;
  late Directory plans;
  late MachineRegistry registry;
  setUp(() async {
    root = await Directory.systemTemp.createTemp('la_automation_execution_');
    plans = Directory('${root.path}/plans')..createSync();
    registry = MachineRegistry(root: '${root.path}/registry');
  });
  tearDown(() async => root.delete(recursive: true));

  test('constructing execution does not run saved commands', () async {
    final marker = File('${root.path}/ran');
    SpecStore(plans).save('command', DesiredState(specs: [
      ComponentSpec(
        id: 'command',
        providerName: 'process',
        policy: const SupervisionPolicy(shape: SupervisionShape.job),
        env: {'command': '/usr/bin/touch', 'args-json': '["${marker.path}"]'},
      ),
    ]));
    final execution = SupervisorExecution(
      storeRoot: plans,
      appRoot: root,
      registry: registry,
    );
    expect(marker.existsSync(), isFalse);
    expect(execution.enabled, isFalse);
    await execution.run();
    expect(marker.existsSync(), isTrue);
    expect(execution.lastError, isNull);
    await execution.close();
  }, skip: Platform.isWindows);

  test('agent provider is injected and terminal result is durable', () async {
    SpecStore(plans).save('agent', const DesiredState(specs: [
      ComponentSpec(
        id: 'agent',
        providerName: 'agent',
        policy: SupervisionPolicy(shape: SupervisionShape.job),
        env: {'instructions': 'Perform the declared task'},
      ),
    ]));
    final provider = FakeProvider();
    final execution = SupervisorExecution(
      storeRoot: plans,
      appRoot: root,
      registry: registry,
      agentFactory: (_) => provider,
    );
    await execution.run();
    expect(execution.lastError, isNull);
    expect(registry.snapshot(registry.scopeFor(root.path))['agent']!.lastRun,
        'succeeded');
    await execution.close();
  });

  test('unconnected agent provider refuses visibly without substitution',
      () async {
    SpecStore(plans).save('agent', const DesiredState(specs: [
      ComponentSpec(id: 'agent', providerName: 'agent'),
    ]));
    final execution = SupervisorExecution(
      storeRoot: plans,
      appRoot: root,
      registry: registry,
    );
    await execution.run();
    expect(execution.lastError, contains('not connected'));
    expect(registry.snapshot(registry.scopeFor(root.path)).records, isEmpty);
    await execution.close();
  });
}
