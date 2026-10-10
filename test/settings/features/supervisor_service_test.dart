import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/supervisor_service_io.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:path/path.dart' as p;

/// The on-device supervisor read surface (oka ADR-0041 §6): plans in a
/// [SpecStore] plus this device's records project into one status view.
/// Every test writes only into its temp dirs.
void main() {
  late Directory temp;
  late Directory plans;
  late Directory appSupport;
  late String registryRoot;
  late SupervisorService service;

  setUp(() async {
    temp = await Directory.systemTemp.createTemp('la_supervisor_test_');
    plans = Directory(p.join(temp.path, 'supervisor', 'plans'))
      ..createSync(recursive: true);
    appSupport = Directory(p.join(temp.path, 'support'))
      ..createSync(recursive: true);
    registryRoot = p.join(temp.path, 'registry');
    service = SupervisorService(storeRoot: plans, appRoot: appSupport);
  });

  tearDown(() => temp.deleteSync(recursive: true));

  DesiredState planWith(final String id) => DesiredState(
        specs: [
          ComponentSpec(
            id: id,
            providerName: 'process',
            env: const {'command': '/bin/sleep', 'args': '1'},
          ),
        ],
      );

  test('empty device: supported view with nothing declared', () async {
    final view = await service.load(registryRoot: registryRoot);
    expect(view.supported, isTrue);
    expect(view.plans, isEmpty);
    expect(view.automations, isEmpty);
    expect(view.corruptRecords, isEmpty);
  });

  test('a declared plan renders as not-present until it runs', () async {
    SpecStore(plans).save('hello', planWith('hello-job'));
    final view = await service.load(registryRoot: registryRoot);
    expect(view.plans, ['hello']);
    expect(view.automations, hasLength(1));
    final automation = view.automations.single;
    expect(automation.id, 'hello-job');
    expect(automation.present, isFalse);
    expect(automation.drifted, isFalse);
    expect(automation.shape, 'service');
  });

  test('a matching record renders present with epoch and restarts',
      () async {
    SpecStore(plans).save('hello', planWith('hello-job'));
    final spec = planWith('hello-job').specs.single;
    final registry = MachineRegistry(root: registryRoot);
    final startedAt = DateTime.now().toUtc();
    registry.upsert(
      SupervisorRecord(
        componentId: spec.id,
        providerName: spec.providerName,
        shape: spec.policy.shape.name,
        revisionHash: spec.revisionHash,
        epoch: 2,
        killPolicy: KillPolicy.spawned,
        startedAt: startedAt,
        restartCount: 1,
        windowStartedAt: startedAt,
        trigger: spec.trigger.describe(),
        pid: 4242,
      ),
      scope: registry.scopeFor(appSupport.path),
    );

    final view = await service.load(registryRoot: registryRoot);
    final automation = view.automations.single;
    expect(automation.present, isTrue);
    expect(automation.drifted, isFalse);
    expect(automation.epoch, 2);
    expect(automation.restartCount, 1);
  });

  test('a drifted record is flagged, never hidden', () async {
    SpecStore(plans).save('hello', planWith('hello-job'));
    final spec = planWith('hello-job').specs.single;
    final registry = MachineRegistry(root: registryRoot);
    final startedAt = DateTime.now().toUtc();
    registry.upsert(
      SupervisorRecord(
        componentId: spec.id,
        providerName: spec.providerName,
        shape: spec.policy.shape.name,
        revisionHash: 'drifted000000',
        epoch: 1,
        killPolicy: KillPolicy.spawned,
        startedAt: startedAt,
        restartCount: 0,
        windowStartedAt: startedAt,
        trigger: spec.trigger.describe(),
        pid: 4242,
      ),
      scope: registry.scopeFor(appSupport.path),
    );

    final view = await service.load(registryRoot: registryRoot);
    expect(view.automations.single.drifted, isTrue);
  });

  test('a corrupt record is surfaced in the view', () async {
    SpecStore(plans).save('hello', planWith('hello-job'));
    final registry = MachineRegistry(root: registryRoot);
    final scope = registry.scopeFor(appSupport.path);
    final scopeDir = Directory(p.join(registryRoot, 'records', scope))
      ..createSync(recursive: true);
    File(p.join(scopeDir.path, 'broken.json')).writeAsStringSync('{nope');

    final view = await service.load(registryRoot: registryRoot);
    expect(view.corruptRecords, hasLength(1));
    expect(view.corruptRecords.single, endsWith('broken.json'));
  });
}
