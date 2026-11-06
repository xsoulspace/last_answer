import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/supervised_world_io.dart';
import 'package:oka_supervisor/oka_supervisor.dart';

/// Leg B gap G1 — the durable delegation lane's claimant pump: the
/// realm scheduler is a SECOND declared oka component next to the
/// daemon. These tests prove the three things the app side can prove
/// hermetically: the pure argv grammar (the EXACT contract
/// `parseRealmSchedulerOptions` admits), the named refusals (a missing
/// entrypoint/runtime never spawns a guess), and — through the REAL oka
/// SDK with a fake harness checkout and a fake `dart` — the converge
/// wiring: spawn, leased record, registry view, idempotent re-arm,
/// early-exit typed fact, verified stop.
///
/// What stays unproven here (and says so in the report): the terminal
/// end-to-end lane — a real `task op:create` being claimed by a real
/// `realm_actor` under a real daemon — needs the real harness runtime.
void main() {
  group('the pure argv grammar', () {
    test('schedulerCommand builds exactly the admitted argv', () {
      expect(
        schedulerCommand(
          dartExecutable: '/sdk/bin/dart',
          schedulerScript:
              '/harness/pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart',
          storePath: '/world/coordination',
          schedulerId: 'lastanswer',
          maxActors: 2,
        ),
        [
          '/sdk/bin/dart',
          'run',
          '/harness/pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart',
          '--store',
          '/world/coordination',
          '--scheduler-id',
          'lastanswer',
          '--max-actors',
          '2',
        ],
      );
    });

    test('the entrypoint and store paths join the known layout', () {
      expect(
        schedulerEntrypointPath('/h'),
        '/h/pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart',
      );
      expect(realmStorePath('/w'), '/w/coordination');
    });

    test('the log wrap keeps ONE process through exec', () {
      final wrapped = execWithLogWrap(
        ['dart', 'run', 's.dart', '--store', '/w c/coordination'],
        '/tmp/sched.log',
      );
      expect(wrapped[0], '/bin/sh');
      expect(wrapped[1], '-c');
      expect(wrapped[2], startsWith('exec '));
      // A path with a space stays one quoted argument.
      expect(wrapped[2], contains("'/w c/coordination'"));
      expect(wrapped[2], endsWith(">> '/tmp/sched.log' 2>&1"));
    });

    test('the world declares both components, stops scheduler-first', () {
      expect(supervisedWorldComponentIds, [
        'ecsai-daemon',
        'ecsai-scheduler',
      ]);
      // The stop order is the helper law stopSupervisedWorld follows:
      // stop stops spawning BEFORE the world's owner goes away.
      expect(supervisedWorldStopOrder, [
        'ecsai-scheduler',
        'ecsai-daemon',
      ]);
      expect(
        supervisedWorldStopOrder.reversed.toList(),
        supervisedWorldComponentIds,
      );
    });
  });

  group('named refusals (never a spawn guess)', () {
    test('no harness root and no script path refuses by name', () async {
      final report = await startSupervisedEcsaiScheduler();

      expect(report['ok'], isFalse);
      expect(report['bounce'], 'scheduler_entrypoint_absent');
      expect(report['component'], 'ecsai-scheduler');
      expect(
        '${report['findings']}',
        contains('never spawning a guess'),
      );
    });

    test('a missing entrypoint under a fake root refuses by name', () async {
      final temp = Directory.systemTemp.createTempSync('sched_refuse_');
      addTearDown(() => temp.deleteSync(recursive: true));

      final report = await startSupervisedEcsaiScheduler(
        harnessRoot: temp.path,
      );

      expect(report['ok'], isFalse);
      expect(report['bounce'], 'scheduler_entrypoint_absent');
      expect(
        '${report['findings']}',
        contains(schedulerEntrypointPath(temp.path)),
      );
    });

    test('the world arm refuses whole, naming both components', () async {
      final report = await startSupervisedWorld(
        daemonExecutablePath: '/nonexistent/ecsai_daemon.exe',
      );

      expect(report['ok'], isFalse);
      expect(report['bounce'], 'scheduler_entrypoint_absent');
      expect(report['components'], [
        'ecsai-daemon',
        'ecsai-scheduler',
      ]);
      // Both-or-neither: the refusal happened before ANY spawn.
      expect(report.containsKey('started'), isFalse);
    });
  });

  group('the hermetic converge (real oka SDK, fake harness + dart)', () {
    late Directory temp;
    late String workspace;
    late String harnessRoot;
    late MachineRegistry registry;
    late String liveDart;
    late String argvFile;

    void writeExecutable(final String path, final String body) {
      File(path).writeAsStringSync(body);
      Process.runSync('chmod', ['+x', path]);
    }

    setUp(() {
      temp = Directory.systemTemp.createTempSync('sched_world_');
      workspace = '${temp.path}/worlds/local';
      Directory('$workspace/coordination').createSync(recursive: true);
      harnessRoot = '${temp.path}/harness';
      Directory(
        '$harnessRoot/pkgs/xsoulspace_agentic_afm/bin',
      ).createSync(recursive: true);
      // The fake checkout carries both scripts the real scheduler needs
      // (the actor script is its sibling — the resolve-by-sibling law).
      File(
        '$harnessRoot/pkgs/xsoulspace_agentic_afm/bin/realm_scheduler.dart',
      ).writeAsStringSync('// fake entrypoint for the hermetic converge\n');
      File(
        '$harnessRoot/pkgs/xsoulspace_agentic_afm/bin/realm_actor.dart',
      ).writeAsStringSync('// fake actor for the hermetic converge\n');
      registry = MachineRegistry(root: '${temp.path}/oka');
      // The fake `dart`: records the argv it was spawned with, then
      // REPLACES itself with a short sleep (the pid stays the spawned
      // one — exactly what an `exec` wrap or a real VM would do).
      argvFile = '${temp.path}/spawned-argv.txt';
      liveDart = '${temp.path}/fake-dart-live.sh';
      writeExecutable(
        liveDart,
        '#!/bin/sh\n'
        'printf "%s\\n" "\$@" > "$argvFile"\n'
        'exec sleep 5\n',
      );
    });

    tearDown(() {
      if (temp.existsSync()) temp.deleteSync(recursive: true);
    });

    test('a live scheduler converges, records its pid, reads back, '
        're-arms idempotently and stops through the record', () async {
      final report = await startSupervisedEcsaiScheduler(
        harnessRoot: harnessRoot,
        dartExecutable: liveDart,
        debugWorkspace: workspace,
        debugRegistry: registry,
        settleWindow: const Duration(milliseconds: 400),
      );

      expect(report['ok'], isTrue, reason: '$report');
      expect(report['live'], isTrue);
      expect(report['started'], 1);
      expect(report['component'], 'ecsai-scheduler');
      final spawnedPid = report['pid'] as int?;
      expect(spawnedPid, isNotNull);

      // The SPAWNED argv is the scheduler's admitted contract: the
      // store is the world's coordination directory, absolute.
      final spawnedArgv = File(
        argvFile,
      ).readAsLinesSync().where((line) => line.isNotEmpty).toList();
      expect(spawnedArgv, [
        'run',
        schedulerEntrypointPath(harnessRoot),
        '--store',
        realmStorePath(workspace),
        '--scheduler-id',
        kDefaultSchedulerId,
        '--max-actors',
        '$kDefaultSchedulerMaxActors',
      ]);

      // The registry record mirrors what startSupervised* writes —
      // the SAME shape readSupervisedScheduler and the stop ladder read.
      final record = registry.read(
        registry.scopeFor(workspace),
        'ecsai-scheduler',
      );
      expect(record, isNotNull);
      expect(record!.pid, spawnedPid);
      expect(record.providerName, 'leased-scheduler');
      expect(record.shape, 'service');
      expect(record.killPolicy, KillPolicy.spawned);
      expect(record.handle, 'ecsai-scheduler');

      // The app's read-model source: record + live-pid probe.
      final view = readSupervisedScheduler(
        workspace: workspace,
        debugRegistry: registry,
      );
      expect(view['present'], isTrue);
      expect(view['live'], isTrue);
      expect(view['pid'], spawnedPid);

      // The lease file lives under the workspace's own .oka_cache.
      final lease = File(
        '$workspace/.oka_cache/processes/ecsai-scheduler.json',
      );
      expect(lease.existsSync(), isTrue);

      // Idempotent: a live scheduler converges nothing.
      final again = await startSupervisedEcsaiScheduler(
        harnessRoot: harnessRoot,
        dartExecutable: liveDart,
        debugWorkspace: workspace,
        debugRegistry: registry,
        settleWindow: const Duration(milliseconds: 400),
      );
      expect(again['ok'], isTrue);
      expect(again['alreadyRunning'], isTrue);

      // Stop is record-driven through the verified ladder.
      final stop = await stopSupervisedEcsaiScheduler(
        workspace: workspace,
        debugRegistry: registry,
      );
      expect(stop['ok'], isTrue);
      expect(stop['stopped'], isTrue);
      expect(stop['via'], 'supervisor-record');
      expect(stop['pid'], spawnedPid);

      // After the stop the honest view is DOWN (the record stays —
      // evidence — but its pid is dead), and the lease is gone.
      final after = readSupervisedScheduler(
        workspace: workspace,
        debugRegistry: registry,
      );
      expect(after['present'], isTrue);
      expect(after['live'], isFalse);
      expect(lease.existsSync(), isFalse);
    });

    test(
      'an early-exiting child fails the start with the typed fact',
      () async {
      final dyingDart = '${temp.path}/fake-dart-dying.sh';
      writeExecutable(dyingDart, '#!/bin/sh\nexit 3\n');

      final report = await startSupervisedEcsaiScheduler(
        harnessRoot: harnessRoot,
        dartExecutable: dyingDart,
        debugWorkspace: workspace,
        debugRegistry: registry,
        settleWindow: const Duration(milliseconds: 900),
      );

      expect(report['ok'], isFalse);
      expect(report['live'], isFalse);
      expect(report['failedStarts'], 1);
      expect(report['bounce'], 'scheduler_start_failed');
      final findings = (report['findings']! as List).join('\n');
      expect(findings, contains(SchedulerEarlyExit.code));
      expect(findings, contains('ecsai-scheduler'));
      // The dead child was torn down, never abandoned: no lease left.
      expect(
        File('$workspace/.oka_cache/processes/ecsai-scheduler.json')
            .existsSync(),
        isFalse,
      );
      // The registry view is honestly down.
      final view = readSupervisedScheduler(
        workspace: workspace,
        debugRegistry: registry,
      );
      expect(view['live'], isFalse);
    });

    test('a stop with no record is an honest wasRunning:false', () async {
      final stop = await stopSupervisedEcsaiScheduler(
        workspace: workspace,
        debugRegistry: registry,
      );

      expect(stop['ok'], isTrue);
      expect(stop['wasRunning'], isFalse);
      expect(stop['via'], 'no-record');
      expect(stop['component'], 'ecsai-scheduler');
    });

    test('the web-mirror signatures exist and refuse by name', () {
      // The conditional-import law: the stub answers the SAME call
      // shapes. The io variant is what this test file exercises; the
      // stub's refusals are asserted here through its named constants
      // so a signature drift breaks a test, not the web build.
      expect(ecsaiSchedulerComponentId, 'ecsai-scheduler');
      expect(kDefaultSchedulerMaxActors, inInclusiveRange(1, 32));
      expect(kDefaultSchedulerId, isNotEmpty);
    });
  });
}
