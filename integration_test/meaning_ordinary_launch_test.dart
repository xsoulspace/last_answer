import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/main.dart' as app;
import 'package:universal_storage_live_apply/universal_storage_live_apply.dart';

// Independent fixture identities frozen before ordinary-entry wiring.
const _assets = {
  'lib/greeting.dart':
      '8e9ae44506195092f75388e6d16eccb23d6321204daa2f7fb55b1f03cd6fc33f',
  'test/greeting_test.dart':
      'b1d3cc0924f9d313c4084b44e54fb76d1a776d7700f30c2695a0f54024eca402',
  'pubspec.yaml':
      'ad7a4a06fe9a4090477432843f37575c01580a8daaf8e9c39f41805291f172b9',
  'tool/observe.dart':
      'b1f8e8815340b713cd4090533fcdf96620f63a7bdd7e9751f8879642f64296ab',
  'oracle.json':
      'c4b94c1aa2e8e0830e6a80338f3932d1d70ac857589d5f0c7dabd64e07a14f4b',
};
const _names = ['Ada', '', '2', r'a$b', "x'y"];
List<Map<String, String>> _expected({bool candidate = false}) => [
  for (final name in _names)
    {'name': name, 'value': 'Hello, $name!${candidate ? ' — updated' : ''}'},
];
Map<String, Object?> _meaning() => AgentDocSurface.debugState!.meaning!;
Map<String, String> _hashes(Directory workspace) => {
  for (final path in _assets.keys)
    path: sha256
        .convert(File('${workspace.path}/$path').readAsBytesSync())
        .toString(),
};

Future<void> _wait(WidgetTester tester, bool Function() ready) async {
  final deadline = DateTime.now().add(const Duration(minutes: 3));
  while (!ready() && DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  expect(
    ready(),
    true,
    reason:
        'Ordinary app operation did not settle: '
        '${AgentDocSurface.debugState?.meaning}',
  );
  await tester.pump();
}

Future<void> _tap(WidgetTester tester, String key) async {
  final target = find.byKey(Key(key));
  expect(target, findsOneWidget);
  await tester.ensureVisible(target);
  await tester.tap(target);
  await tester.pump();
}

Future<Object?> _observe(Directory workspace, Map runtime) async {
  final result = await Process.run(
    runtime['executable'] as String,
    ['run', 'tool/observe.dart'],
    workingDirectory: workspace.path,
    environment: {
      'PATH': '/usr/bin:/bin:/usr/sbin:/sbin',
      'PUB_CACHE': runtime['pubCache'] as String,
    },
    includeParentEnvironment: false,
  );
  expect(result.exitCode, 0, reason: '${result.stdout}${result.stderr}');
  return jsonDecode((result.stdout as String).trim());
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('ordinary main entry: real Preview, consent and Undo', (
    tester,
  ) async {
    expect(
      Platform.isMacOS,
      true,
      reason: 'This independent runtime lane qualifies macOS only.',
    );
    // No injected app/host/controller/factory, define, manual binding or observer.
    debugPrint('MEANING_ORDINARY_PHASE main ${DateTime.now().toUtc()}');
    app.main();
    await _wait(
      tester,
      () => find
          .byKey(const Key('home.meaning_experiment'))
          .evaluate()
          .isNotEmpty,
    );
    debugPrint('MEANING_ORDINARY_PHASE entry ${DateTime.now().toUtc()}');
    await _tap(tester, 'home.meaning_experiment');
    await _wait(
      tester,
      () =>
          AgentDocSurface.debugState != null ||
          find
              .byKey(const Key('home.meaning_experiment.refusal'))
              .evaluate()
              .isNotEmpty,
    );
    expect(
      find.byKey(const Key('home.meaning_experiment.refusal')),
      findsNothing,
      reason: 'A runtime/preparation refusal is not an ordinary-launch pass.',
    );
    final state = AgentDocSurface.debugState!;
    expect(state.workspaces, hasLength(1));
    final workspace = Directory(state.workspaces.single);
    final preparation = _meaning()['preparation']! as Map;
    expect(preparation['ok'], true);
    expect(preparation['workspace'], workspace.path);
    final runtime = preparation['runtime']! as Map;
    expect(runtime['source'], 'app_bundle');
    expect(File(runtime['executable'] as String).isAbsolute, true);
    expect(
      sha256
          .convert(File(runtime['executable'] as String).readAsBytesSync())
          .toString(),
      runtime['executableSha256'],
    );
    expect(_hashes(workspace), _assets);
    final original = File(
      '${workspace.path}/lib/greeting.dart',
    ).readAsBytesSync();
    final lock = File('${workspace.path}/pubspec.lock').readAsBytesSync();
    debugPrint('MEANING_ORDINARY_PHASE baseline ${DateTime.now().toUtc()}');
    expect(await _observe(workspace, runtime), _expected());
    final projection = agentMcpEntries().singleWhere(
      (entry) => entry.name == 'agent_doc_state',
    );

    Future<String> preview() async {
      final priorId = _meaning()['proposalId'];
      final priorRefusal = _meaning()['refusal'];
      var sawDispatch = false;
      debugPrint('MEANING_ORDINARY_PHASE preview ${DateTime.now().toUtc()}');
      await _tap(tester, 'coding_agent.meaning.preview');
      await _wait(tester, () {
        final state = _meaning();
        if (state['busy'] == true) sawDispatch = true;
        final freshProposal =
            state['preview'] != null && state['proposalId'] != priorId;
        final refused =
            state['refusal'] != null &&
            (sawDispatch || state['refusal'] != priorRefusal);
        return state['busy'] == false && (freshProposal || refused);
      });
      expect(_meaning()['refusal'], isNull, reason: '${_meaning()}');
      final p = _meaning()['preview']! as Map;
      expect(p['baseline_observation'], _expected());
      expect(p['candidate_observation'], _expected(candidate: true));
      expect((p['evidence']! as Map)['stage'], 'previewExecuted');
      expect(_hashes(workspace), _assets);
      expect(File('${workspace.path}/pubspec.lock').readAsBytesSync(), lock);
      final readback = await projection.invokeDirect({'docId': state.docId});
      expect(readback.data['meaning'], _meaning());
      expect(find.byKey(const Key('coding_agent.meaning.diff')), findsNothing);
      for (final row in _expected(candidate: true)) {
        expect(find.textContaining(row['value']!), findsWidgets);
      }
      await _tap(tester, 'coding_agent.meaning.details');
      expect(
        find.byKey(const Key('coding_agent.meaning.diff')),
        findsOneWidget,
      );
      await _tap(tester, 'coding_agent.meaning.details');
      return _meaning()['proposalId']! as String;
    }

    Future<void> consent(String id, {required bool allow}) async {
      debugPrint('MEANING_ORDINARY_PHASE apply ${DateTime.now().toUtc()}');
      await _tap(tester, 'coding_agent.meaning.apply');
      await _wait(
        tester,
        () => find
            .byKey(const Key('coding_agent.permission.allow'))
            .evaluate()
            .isNotEmpty,
      );
      final update = _meaning()['reviewProposal']! as Map;
      expect((update['payload']! as Map)['proposalId'], id);
      final issued = (_meaning()['preview']! as Map)['proposal']! as Map;
      expect(
        (update['payload']! as Map)['effectDigest'],
        issued['effectDigest'],
      );
      await _tap(
        tester,
        allow
            ? 'coding_agent.permission.allow'
            : 'coding_agent.permission.reject',
      );
      await _wait(tester, () => _meaning()['busy'] == false);
    }

    final rejected = await preview();
    await consent(rejected, allow: false);
    expect(
      File('${workspace.path}/lib/greeting.dart').readAsBytesSync(),
      original,
    );
    expect(_meaning()['refusal'], isNotNull);
    expect(
      (_meaning()['receipts']! as List).last,
      containsPair('action', 'status'),
    );
    final accepted = await preview();
    expect(accepted, isNot(rejected));
    await consent(accepted, allow: true);
    expect(_meaning()['refusal'], isNull, reason: '${_meaning()}');
    final applied = _meaning()['applied']! as Map;
    expect((applied['outcome']! as Map)['analyze_exit'], 0);
    expect((applied['outcome']! as Map)['check_exit'], 0);
    expect(_meaning()['currentObservation'], _expected(candidate: true));
    expect(await _observe(workspace, runtime), _expected(candidate: true));
    final revisions =
        (_meaning()['preview']! as Map)['candidate_revisions']! as Map;
    final candidate = revisions['lib/greeting.dart']! as Map;
    expect(candidate['kind'], 'source_sha256');
    expect(
      sha256
          .convert(
            File('${workspace.path}/lib/greeting.dart').readAsBytesSync(),
          )
          .toString(),
      candidate['value'],
    );
    final run = _meaning()['runId']! as String;
    final store = LiveApplyJournalStore(
      storePath: '${workspace.path}.meaning-recovery',
    );
    expect((await store.read(run))!.status, LiveApplyRunStatus.applied);
    expect(find.text('Undo'), findsOneWidget);
    debugPrint('MEANING_ORDINARY_PHASE undo ${DateTime.now().toUtc()}');
    await _tap(tester, 'coding_agent.meaning.rollback');
    await _wait(tester, () => _meaning()['busy'] == false);
    expect(_meaning()['refusal'], isNull, reason: '${_meaning()}');
    expect(_hashes(workspace), _assets);
    expect(
      File('${workspace.path}/lib/greeting.dart').readAsBytesSync(),
      original,
    );
    expect(_meaning()['currentObservation'], _expected());
    expect(await _observe(workspace, runtime), _expected());
    expect((await store.read(run))!.status, LiveApplyRunStatus.rolledBack);
    expect(_meaning()['rollbackAvailable'], false);
    final receipt = {
      'docId': state.docId,
      'workspace': workspace.path,
      'preparation': preparation,
      'rejectedProposalId': rejected,
      'appliedProposalId': accepted,
      'runId': run,
      'sourceHashes': _hashes(workspace),
      'meaning': _meaning(),
      'scope':
          'real main integration; built-app restricted-PATH and '
          'physical journey separate',
    };
    debugPrint('MEANING_ORDINARY_LAUNCH ${jsonEncode(receipt)}');
  }, timeout: const Timeout(Duration(minutes: 12)));
}
