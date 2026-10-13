import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

import 'pump_until.dart';
import 'scripted_write_mover.dart';

void main() {
  testWidgets('native deadline retires an unanswered permission row', (
    tester,
  ) async {
    final root = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('permission_deadline'),
    ))!;
    final source = File('${root.path}/main.dart');
    const original = "void main() { throw StateError('original'); }\n";
    source.writeAsStringSync(original);
    final controller = HarnessSessionController(
      config: HarnessHostConfig(
        handlerFactory: (_) => ScriptedWriteMover(
          'main.dart',
          "void main() { print('changed'); }\n",
        ),
      ),
    );
    try {
      var ready = false;
      unawaited(controller.createSession(root.path).then((_) => ready = true));
      await pumpUntil(tester, () => ready);
      expect(ready, isTrue);
      var done = false;
      unawaited(
        controller.host
            .delegateTask(controller.current!.id, 'Change main.dart')
            .then((_) => done = true),
      );
      await pumpUntil(tester, () => controller.pendingPermission != null);
      final pending = controller.pendingPermission!;
      expect(pending.isAnswered, isFalse);
      // Advance the test clock over the real backend deadline. No second
      // timer, timeout setting, approval or cancellation is introduced.
      await tester.pump(const Duration(minutes: 6));
      await pumpUntil(tester, () => done);
      expect(done, isTrue);
      expect(controller.pendingPermission, isNull);
      expect(pending.isAnswered, isTrue);
      pending.allow();
      await tester.pump();
      expect(source.readAsStringSync(), original);
    } finally {
      controller.dispose();
      await tester.runAsync(() => root.delete(recursive: true));
    }
  });

  test(
    'native cancellation retires permission and late allow cannot write',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'permission_retirement',
      );
      final source = File('${root.path}/main.dart');
      const original = "void main() { throw StateError('original'); }\n";
      source.writeAsStringSync(original);
      final controller = HarnessSessionController(
        config: HarnessHostConfig(
          handlerFactory: (_) => ScriptedWriteMover(
            'main.dart',
            "void main() { print('changed'); }\n",
          ),
        ),
      );
      try {
        await controller.createSession(root.path);
        final session = controller.current!;
        final turn = controller.host.delegateTask(
          session.id,
          'Change main.dart',
        );
        final pending = await controller.nextPermission();
        expect(controller.pendingPermission, same(pending));
        expect(pending.isAnswered, isFalse);
        controller.host.cancel(session.id);
        await turn;
        await Future<void>.delayed(Duration.zero);
        expect(controller.pendingPermission, isNull);
        expect(pending.isAnswered, isTrue);
        pending.allow();
        await Future<void>.delayed(Duration.zero);
        expect(source.readAsStringSync(), original);
      } finally {
        controller.dispose();
        await controller.host.stop();
        await root.delete(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
