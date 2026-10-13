import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:universal_storage_live_apply/universal_storage_live_apply.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart';
import 'package:xsoulspace_agentic_host/conventional_change.dart';

import 'meaning_native_test_composition.dart';

void main() {
  test(
    'product admission previews real multi-file code and native Undo',
    () async {
      final root = await Directory.systemTemp.createTemp('la_conventional_');
      addTearDown(() => root.delete(recursive: true));
      final workspace = await Directory('${root.path}/project').create();
      File file(String path) => File('${workspace.path}/$path');
      file('main.dart').writeAsStringSync(
        "import 'ranking.dart';\n"
        "void main() => print(rank([3, 1, 9]).join(','));\n",
      );
      const original = 'List<int> rank(List<int> values) => values;\n';
      file('ranking.dart').writeAsStringSync(original);
      file('obsolete.txt').writeAsStringSync('retain in Undo');
      final instances = <World, Map<String, ConventionalChangeToolExtension>>{};
      final observed = <Map<String, Object?>>[];
      final host = HarnessHost(
        config: HarnessHostConfig(
          meaningProfile: true,
          extraToolsWithContext: (context) {
            final tasks = instances[context.world] ??= {};
            final extension = tasks.putIfAbsent(
              context.taskId,
              () => ConventionalChangeToolExtension(
                context: context,
                store: LiveApplyJournalStore(
                  storePath: '${root.path}/recovery',
                ),
                dependencyPaths: const [
                  'main.dart',
                  'ranking.dart',
                  'obsolete.txt',
                ],
                allowWrite: (path) => const {
                  'ranking.dart',
                  'ranking_helper.dart',
                  'obsolete.txt',
                }.contains(path),
                verificationDescription: 'Real Dart output equals 9,3,1',
                onOutcome: (observation) {
                  observed.add(observation);
                  if (observation['action'] == 'apply') {
                    // A broken view cannot turn a acknowledged native effect
                    // into a failure or mutate the actual execution result.
                    (observation['result'] as Map)['ok'] = false;
                    throw StateError('simulated observer failure');
                  }
                },
                verifyCandidate: (candidate) async {
                  final result = await runMeaningComponentDart('dart', [
                    '${candidate.path}/main.dart',
                  ], candidate.path);
                  return ConventionalCheck(
                    ok: result.exitCode == 0 && result.stdout == '9,3,1\n',
                    evidence: {
                      'exitCode': result.exitCode,
                      'stdout': result.stdout,
                      'stderr': result.stderr,
                    },
                  );
                },
              ),
            );
            return extension.tools;
          },
        ),
      );
      addTearDown(host.stop);
      await host.start();
      final session = await host.newSession(workspace.path);
      Future<Map<String, Object?>> act(
        String action, [
        Map<String, Object?> arguments = const {},
      ]) => host.conventionalAction(session, action, arguments);

      final read = await act('read');
      expect(read['ok'], true, reason: '$read');
      final reserved = await act('declareTarget', {
        'sourceId': read['sourceId'],
        'path': 'ranking_helper.dart',
      });
      expect(reserved['ok'], true, reason: '$reserved');
      final preview = await act('preview', {
        'sourceId': reserved['sourceId'],
        'changesJson': jsonEncode({
          'ranking.dart':
              "import 'ranking_helper.dart';\n"
              'List<int> rank(List<int> values) => descending(values);\n',
          'ranking_helper.dart':
              'List<int> descending(List<int> values) => '
              '[...values]..sort((a, b) => b.compareTo(a));\n',
          'obsolete.txt': null,
        }),
      });
      expect(preview['ok'], true, reason: '$preview');
      expect(file('ranking.dart').readAsStringSync(), original);
      expect(file('ranking_helper.dart').existsSync(), false);
      expect(file('obsolete.txt').existsSync(), true);

      var allow = false;
      final consent = <String>[];
      final subscription = host.permissionRequests.listen((pending) {
        final details = jsonDecode(pending.request.details!) as Map;
        consent.add(details['proposalId'] as String);
        allow ? pending.allow() : pending.reject();
      });
      addTearDown(subscription.cancel);
      final proposal = (preview['proposal']! as Map)['proposalId'];
      final denied = await act('apply', {'proposalId': proposal});
      expect(denied['ok'], false, reason: '$denied');
      expect(file('ranking.dart').readAsStringSync(), original);
      expect(file('ranking_helper.dart').existsSync(), false);

      // A rejected proposal is not silently retried as another authoring route.
      allow = true;
      final nextRead = await act('read');
      final nextReserved = await act('declareTarget', {
        'sourceId': nextRead['sourceId'],
        'path': 'ranking_helper.dart',
      });
      final nextPreview = await act('preview', {
        'sourceId': nextReserved['sourceId'],
        'changesJson': jsonEncode({
          'ranking.dart':
              "import 'ranking_helper.dart';\n"
              'List<int> rank(List<int> values) => descending(values);\n',
          'ranking_helper.dart':
              'List<int> descending(List<int> values) => '
              '[...values]..sort((a, b) => b.compareTo(a));\n',
          'obsolete.txt': null,
        }),
      });
      expect(nextPreview['ok'], true, reason: '$nextPreview');
      final nextProposal = (nextPreview['proposal']! as Map)['proposalId'];
      expect(nextProposal, isNot(proposal));
      final applied = await act('apply', {'proposalId': nextProposal});
      expect(applied['ok'], true, reason: '$applied');
      expect(applied['native_status'], 'applied');
      expect(applied['acceptance'], false);
      expect(consent, [proposal, nextProposal]);
      expect(file('obsolete.txt').existsSync(), false);
      final result = await runMeaningComponentDart('dart', [
        file('main.dart').path,
      ], workspace.path);
      expect(result.stdout, '9,3,1\n');
      final undo = await act('rollback', {
        'proposalId': nextProposal,
        'runId': applied['runId'],
      });
      expect(undo['ok'], true, reason: '$undo');
      expect(undo['native_status'], 'rolledBack');
      expect(file('ranking.dart').readAsStringSync(), original);
      expect(file('ranking_helper.dart').existsSync(), false);
      expect(file('obsolete.txt').readAsStringSync(), 'retain in Undo');
      expect((await act('status'))['ok'], true);
      expect(observed.where((o) => o['action'] == 'preview').length, 2);
      expect(observed.where((o) => o['action'] == 'apply').length, 2);
      expect(observed.last['action'], 'status');
      expect(observed.last['taskId'], isNotEmpty);
      expect(observed.last['workspace'], workspace.resolveSymbolicLinksSync());
    },
    timeout: const Timeout(Duration(minutes: 5)),
  );
}
