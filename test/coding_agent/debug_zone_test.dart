import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'scripted_write_mover.dart';

/// Alternates pump (flushes fake-zone stream microtasks) and runAsync
/// (lets real file/process IO complete) until [condition] holds.
Future<void> pumpUntil(
  final WidgetTester tester,
  final bool Function() condition, {
  final int maxCycles = 300,
}) async {
  for (var i = 0; i < maxCycles && !condition(); i++) {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 10)),
    );
  }
}

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_dbg2');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
  });

  tearDown(() {
    try {
      workspace.deleteSync(recursive: true);
    } on Object {
      // ignore
    }
  });

  testWidgets('debug: alternation strategy', (final tester) async {
    final controller = HarnessSessionController(
      host: HarnessHost(
        config: HarnessHostConfig(
          handlerFactory: (_) => ScriptedWriteMover(
            'main.dart',
            "void main() { print('ok'); }\n",
          ),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: CodingAgentScreen(controller: controller)),
    );

    await tester.enterText(
      find.byKey(const Key('coding_agent.workspace')),
      workspace.path,
    );
    await tester.enterText(
      find.byKey(const Key('coding_agent.task')),
      'Fix main.dart.',
    );
    await tester.tap(find.byKey(const Key('coding_agent.delegate')));
    await tester.pump();

    // ignore: avoid_print
    print('DBG waiting for permission with pump/runAsync alternation');
    await pumpUntil(tester, () => controller.pendingPermission != null);
    // ignore: avoid_print
    print('DBG pending permission: ${controller.pendingPermission != null}');

    if (controller.pendingPermission != null) {
      await tester.tap(
        find.byKey(const Key('coding_agent.permission.allow')),
      );
      await tester.pump();
      // ignore: avoid_print
      print('DBG allowed; waiting for idle');
      await pumpUntil(tester, () => !controller.isRunning);
      // ignore: avoid_print
      print('DBG idle; verdict: ${controller.current?.verdictLine}');
    }
  });
}
