import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/settings/features/supervisor_service_io.dart';
import 'package:lastanswer/settings/features/supervisor_view.dart';
import 'package:oka_supervisor/oka_supervisor.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

/// The on-device supervisor read surface (oka ADR-0041 §6): plans in a
/// [SpecStore] plus this device's records project into one status view.
/// Every test writes only into its temp dirs.
void main() {
  // The world's paired registry reads device-local preferences.
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

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

  test('saveAutomation creates a one-spec plan that loads back', () async {
    await service.saveAutomation(
      const SupervisorAutomationDraft(
        id: 'nightly-backup',
        isService: false,
        command: '/usr/bin/backup',
        intervalSeconds: 86400,
      ),
    );
    final view = await service.load(registryRoot: registryRoot);
    expect(view.plans, ['nightly-backup']);
    final automation = view.automations.single;
    expect(automation.id, 'nightly-backup');
    expect(automation.shape, 'job');
    expect(automation.trigger, 'interval:86400s');
    expect(automation.plan, 'nightly-backup');
    expect(automation.command, '/usr/bin/backup');
    expect(automation.intervalSeconds, 86400);
    expect(automation.revision, 1);
  });

  test('saveAutomation edits in place and bumps the revision', () async {
    await service.saveAutomation(
      const SupervisorAutomationDraft(
        id: 'nightly-backup',
        isService: false,
        command: '/usr/bin/backup',
        intervalSeconds: 86400,
      ),
    );
    await service.saveAutomation(
      const SupervisorAutomationDraft(
        id: 'nightly-backup',
        isService: false,
        command: '/usr/local/bin/backup',
        intervalSeconds: 3600,
        plan: 'nightly-backup',
        revision: 1,
      ),
    );
    final view = await service.load(registryRoot: registryRoot);
    expect(view.plans, ['nightly-backup']);
    final automation = view.automations.single;
    expect(automation.trigger, 'interval:3600s');
    expect(automation.command, '/usr/local/bin/backup');
    expect(automation.revision, 2, reason: 'the reset is the revision bump');
  });

  test('deleteAutomation drops the spec and keeps plan siblings', () async {
    SpecStore(plans).save(
      'demo',
      const DesiredState(
        specs: [
          ComponentSpec(id: 'a', providerName: 'process'),
          ComponentSpec(id: 'b', providerName: 'process'),
        ],
      ),
    );
    await service.deleteAutomation(plan: 'demo', id: 'a');
    final view = await service.load(registryRoot: registryRoot);
    expect(view.plans, ['demo']);
    expect(
      view.automations.map((final automation) => automation.id),
      ['b'],
    );
  });

  test('deleteAutomation removes an emptied plan file', () async {
    await service.saveAutomation(
      const SupervisorAutomationDraft(id: 'solo', isService: true),
    );
    await service.deleteAutomation(plan: 'solo', id: 'solo');
    final view = await service.load(registryRoot: registryRoot);
    expect(view.plans, isEmpty);
    expect(view.automations, isEmpty);
  });

  test('agent task: instructions land on the agent provider', () async {
    await service.saveAutomation(
      const SupervisorAutomationDraft(
        id: 'nightly-agent',
        isService: false,
        isAgent: true,
        instructions: 'Check the backups and report.',
        intervalSeconds: 86400,
        atMinutes: 180,
      ),
    );
    final view = await service.load(registryRoot: registryRoot);
    final automation = view.automations.single;
    expect(automation.isAgent, isTrue);
    expect(automation.instructions, 'Check the backups and report.');
    expect(automation.trigger, 'interval:86400s@03:00');
    expect(automation.atMinutes, 180);
    expect(automation.shape, 'job');
    // The document really carries the agent provider + anchor.
    final doc = SpecStore(
      plans,
    ).load('nightly-agent')!.specs.single;
    expect(doc.providerName, 'agent');
    expect(doc.env['instructions'], 'Check the backups and report.');
    final trigger = doc.trigger as IntervalTrigger;
    expect(trigger.at, '03:00');
  });

  test('anchored command job round-trips the wall clock', () async {
    await service.saveAutomation(
      const SupervisorAutomationDraft(
        id: 'nightly-backup',
        isService: false,
        command: '/usr/bin/backup',
        intervalSeconds: 86400,
        atMinutes: 180,
      ),
    );
    await service.saveAutomation(
      const SupervisorAutomationDraft(
        id: 'nightly-backup',
        isService: false,
        command: '/usr/bin/backup',
        intervalSeconds: 86400,
        atMinutes: 240,
        plan: 'nightly-backup',
        revision: 1,
      ),
    );
    final view = await service.load(registryRoot: registryRoot);
    final automation = view.automations.single;
    expect(automation.trigger, 'interval:86400s@04:00');
    expect(automation.atMinutes, 240);
    expect(automation.revision, 2);
  });

  test('saveAutomation rejects names that cannot be plan files', () {
    expect(
      () => service.saveAutomation(
        const SupervisorAutomationDraft(id: '../escape', isService: true),
      ),
      throwsFormatException,
    );
  });

  test('the authorized world is the one the open project binds', () {
    final bound = ProjectModel.emptyAgent(
      worldBinding: const WorldBindingModel(
        worldId: 'w1',
        endpoint: 'http://127.0.0.1:1234/',
      ),
    );
    expect(SupervisorService.authorizedWorldId(bound), 'w1');
    // A project that binds no world authorizes none — the refusal stays
    // visible instead of guessing a world.
    expect(SupervisorService.authorizedWorldId(ProjectModel.emptyAgent()), isNull);
    expect(
      SupervisorService.authorizedWorldId(ProjectModel.emptyNote),
      isNull,
    );
    expect(SupervisorService.authorizedWorldId(null), isNull);
  });

  test('a world this device cannot reach refuses in words', () async {
    final resolution = await SupervisorService.resolveAgentClient(
      worldId: 'la-no-such-world',
    );
    expect(resolution.client, isNull);
    expect(resolution.refusal, contains('not reachable from this device'));
  });
}
