import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

Future<List<Map<String, Object?>>> _snapshot(
  WidgetTester tester, {
  required String receipt,
}) async {
  final pending = SemanticSnapshotService.buildSemanticSnapshot();
  await tester.pump();
  await tester.pump();
  final result = await pending;
  File(
    '/tmp/meaning-semantic-regions-$receipt.snapshot.json',
  ).writeAsStringSync(jsonEncode(result));
  return (result['nodes']! as List).cast<Map<String, Object?>>();
}

Set<String> _descendants(
  List<Map<String, Object?>> nodes,
  Map<String, Object?> region,
) {
  final byRef = {for (final node in nodes) node['ref']: node};
  final result = <String>{};
  void walk(Map<String, Object?> node) {
    for (final ref in (node['children'] as List? ?? const [])) {
      if (ref is String && result.add(ref) && byRef[ref] != null) {
        walk(byRef[ref]!);
      }
    }
  }

  walk(region);
  return result;
}

void _bounds(Map<String, Object?> node, Rect actual) {
  final bounds = node['bounds']! as Map;
  expect(bounds['left'], closeTo(actual.left, .01));
  expect(bounds['top'], closeTo(actual.top, .01));
  expect(bounds['right'], closeTo(actual.right, .01));
  expect(bounds['bottom'], closeTo(actual.bottom, .01));
}

void main() {
  testWidgets(
    'real surface publishes fitting and overflowing transcript region',
    (tester) async {
      final root = await tester.runAsync(
        () => Directory.systemTemp.createTemp('la_semantic_regions_'),
      );
      addTearDown(() => root!.delete(recursive: true));
      File('${root!.path}/main.dart').writeAsStringSync('void main() {}\n');
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          handlerFactory: (_) =>
              ScriptedWriteMover('main.dart', 'void main() {}\n'),
          extraToolsWithContext: (_) => [],
        ),
      );
      addTearDown(controller.dispose);
      await tester.runAsync(() => controller.createSession(root.path));
      expect(controller.error, isNull);
      final doc = (ProjectModel.emptyAgent() as ProjectModelDoc).copyWith(
        agent: AgentDocModel(workspaces: [root.path]),
      );
      Widget surface() => MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: doc, controller: controller),
        ),
      );
      await tester.pumpWidget(surface());
      await tester.pumpAndSettle();
      final semantics = tester.ensureSemantics();
      try {
        final list = find.descendant(
          of: find.byKey(const Key('coding_agent.transcript')),
          matching: find.byType(ListView),
        );
        final scroll = tester.state<ScrollableState>(
          find.descendant(of: list, matching: find.byType(Scrollable)).first,
        );
        for (final overflow in [false, true]) {
          if (overflow) {
            for (var i = 0; i < 40; i++) {
              controller.queue.enqueue('Queued visible message $i');
            }
            await tester.pumpWidget(surface());
            await tester.pumpAndSettle();
            scroll.position.jumpTo(scroll.position.maxScrollExtent);
            await tester.pumpAndSettle();
          }
          expect(scroll.position.maxScrollExtent > 0, overflow);
          final nodes = await _snapshot(
            tester,
            receipt: overflow ? 'overflow' : 'fitting',
          );
          final region = nodes.singleWhere(
            (node) => node['identifier'] == 'coding_agent.transcript',
          );
          _bounds(region, tester.getRect(list));
          final refs = _descendants(nodes, region);
          final preview = nodes.singleWhere(
            (node) => node['label'] == 'Preview',
          );
          final details = nodes.singleWhere(
            (node) => node['label'] == '+ Details',
          );
          expect(refs, contains(preview['ref']));
          expect(refs, contains(details['ref']));
          expect(
            nodes.where(
              (node) => node['identifier'] == 'coding_agent.permission',
            ),
            isEmpty,
          );
        }
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('real pending permission has a separate named native region', (
    tester,
  ) async {
    final root = await tester.runAsync(
      () => Directory.systemTemp.createTemp('la_semantic_permission_'),
    );
    addTearDown(() => root!.delete(recursive: true));
    final source = File('${root!.path}/main.dart')
      ..writeAsStringSync('void main() {}\n');
    final original = source.readAsStringSync();
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) => ScriptedWriteMover(
          'main.dart',
          "void main() { print('changed'); }\n",
        ),
      ),
    );
    addTearDown(controller.dispose);
    await tester.runAsync(() => controller.createSession(root.path));
    final doc = (ProjectModel.emptyAgent() as ProjectModelDoc).copyWith(
      agent: AgentDocModel(workspaces: [root.path]),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: doc, controller: controller),
        ),
      ),
    );
    unawaited(controller.delegate('Propose the owned fixture write.'));
    await pumpUntil(tester, () => controller.pendingPermission != null);
    expect(controller.pendingPermission, isNotNull);
    await tester.pump();
    final semantics = tester.ensureSemantics();
    try {
      final nodes = await _snapshot(tester, receipt: 'permission');
      final permission = nodes.singleWhere(
        (node) => node['identifier'] == 'coding_agent.permission',
      );
      final transcript = nodes.singleWhere(
        (node) => node['identifier'] == 'coding_agent.transcript',
      );
      _bounds(
        permission,
        tester.getRect(find.byKey(const Key('coding_agent.permission'))),
      );
      final permitted = _descendants(nodes, permission);
      final transcriptRefs = _descendants(nodes, transcript);
      for (final label in ['[reject]', '[allow]']) {
        final control = nodes.singleWhere((node) => node['label'] == label);
        expect(permitted, contains(control['ref']));
        expect(transcriptRefs, isNot(contains(control['ref'])));
      }
      expect(transcriptRefs, isNot(contains(permission['ref'])));
      final exact = controller.pendingPermission!.request.details;
      expect(exact, isNotNull);
      final disclosure = nodes.singleWhere(
        (node) =>
            node['label'] ==
            '+ ${controller.pendingPermission!.request.toolCallId}',
      );
      expect(permitted, contains(disclosure['ref']));
      await tester.tap(
        find.byKey(const Key('coding_agent.permission.exact_summary')),
      );
      await tester.pumpAndSettle();
      final expanded = await _snapshot(tester, receipt: 'permission-expanded');
      expect(
        expanded.any(
          (node) => node['label'] == exact || node['value'] == exact,
        ),
        isTrue,
      );
      expect(source.readAsStringSync(), original);
      controller.answerPermission(allow: false);
      await pumpUntil(tester, () => !controller.isRunning);
    } finally {
      semantics.dispose();
    }
  });
}
