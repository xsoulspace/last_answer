import 'dart:io';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

void main() {
  testWidgets('DEBUG: permission surfaces', (final tester) async {
    final workspace = await Directory.systemTemp.createTemp('la_debug');
    File('${workspace.path}/main.dart').writeAsStringSync(
      "void main() { throw StateError('not implemented'); }\n",
    );
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) =>
            ScriptedWriteMover('main.dart', "void main() { print('ok'); }\n"),
      ),
    );
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AgentDocSurface(doc: ProjectModel.emptyAgent() as ProjectModelDoc, controller: controller),
        ),
      ),
    );
    await tester.pump();

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

    await tester.tap(find.byKey(const Key('coding_agent.delegate')));
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
    }
    // ignore: avoid_print
    print(
      'DEBUG after tap: error=${controller.error} '
      'current=${controller.current?.id} running=${controller.isRunning} '
      'turns=${controller.current?.turns.length} '
      'transcript="${controller.current?.transcript.toString().substring(0, (controller.current?.transcript.length ?? 0).clamp(0, 200))}"',
    );

    await pumpUntil(tester, () => controller.pendingPermission != null);
    await tester.pump();
    // ignore: avoid_print
    print('DEBUG pendingPermission=${controller.pendingPermission?.request.title}');
    // ignore: avoid_print
    print(
      'DEBUG keys: ${tester.allWidgets
          .whereType<Widget>()
          .map((w) => w.key)
          .whereType<Key>()
          .map((k) => (k as ValueKey).value)
          .toSet()}',
    );
  }, timeout: const Timeout(Duration(minutes: 3)));
}
