// TASK B — widget gate: the minimal coding-agent UI drives the embedded
// harness end to end (LLM-free, scripted mover):
//
// task input (sentence + workspace) → delegate → the write-gate permission
// prompt surfaces → the user answers ALLOW → the verdict surfaces in the
// UI. The same flow through the REAL screen widgets, no protocol bypass.
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'scripted_write_mover.dart';

void main() {
  late Directory workspace;

  setUp(() async {
    workspace = await Directory.systemTemp.createTemp('lastanswer_widget');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
  });

  tearDown(() {
    try {
      workspace.deleteSync(recursive: true);
    } on Object {
      // best effort
    }
  });

  testWidgets('delegate → permission prompt → allow → verdict surfaces', (
    final tester,
  ) async {
    final controller = HarnessSessionController(
      host: HarnessHost(
        config: HarnessHostConfig(
          handlerFactory: (_) =>
              ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
        ),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(home: CodingAgentScreen(controller: controller)),
    );

    // Enter the workspace and the task sentence; delegate.
    await tester.enterText(
      find.byKey(const Key('coding_agent.workspace')),
      workspace.path,
    );
    await tester.enterText(
      find.byKey(const Key('coding_agent.task')),
      'Fix main.dart so `dart run main.dart` exits 0.',
    );
    await tester.tap(find.byKey(const Key('coding_agent.delegate')));
    await tester.pump();

    // The write-gate round-trip crosses real IO — run it to completion
    // outside the fake-async zone, then resume the frame.
    await tester.runAsync(() => controller.nextPermission());
    await tester.pump();

    expect(
      find.byKey(const Key('coding_agent.permission')),
      findsOneWidget,
      reason: 'the permission prompt must surface per write',
    );

    // The user-actor approves the write.
    await tester.tap(find.byKey(const Key('coding_agent.permission.allow')));
    await tester.pump();

    // The turn (verification oracle: dart run main.dart) crosses real IO.
    await tester.runAsync(() => controller.whenIdle());
    await tester.pump();

    expect(
      find.textContaining('verdict: PASS'),
      findsOneWidget,
      reason: 'the verdict must surface in the transcript',
    );
    expect(
      find.byKey(const Key('coding_agent.verdict.card')),
      findsOneWidget,
      reason: 'the verdict banner must surface',
    );
    expect(
      File('${workspace.path}/main.dart').readAsStringSync(),
      contains("print('ok')"),
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}
