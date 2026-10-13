import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

void main() {
  test(
    'parallel startup and session creation await one completed host',
    () async {
      final root = await Directory.systemTemp.createTemp('la_startup_');
      final controller = HarnessSessionController(
        config: const HarnessHostConfig(scripted: true),
      );
      addTearDown(controller.dispose);
      addTearDown(() => root.delete(recursive: true));
      await Future.wait([
        controller.ensureStarted(),
        controller.ensureStarted(),
        controller.createSession(root.path),
      ]);
      expect(controller.error, isNull);
      expect(controller.host.isRunning, true);
      expect(controller.current?.cwd, root.path);
    },
  );

  test(
    'session creation follows a concurrently queued backend configuration',
    () async {
      final root = await Directory.systemTemp.createTemp('la_config_startup_');
      const config = HarnessHostConfig(scripted: true);
      final controller = HarnessSessionController(config: config);
      addTearDown(controller.dispose);
      addTearDown(() => root.delete(recursive: true));
      await Future.wait([
        controller.ensureStarted(),
        controller.switchBackend(config.copyWith(model: 'configured-fixture')),
        controller.createSession(root.path),
      ]);
      expect(controller.error, isNull);
      expect(controller.config.model, 'configured-fixture');
      expect(controller.host.isRunning, true);
      expect(controller.current?.cwd, root.path);
    },
  );
}
