import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:lastanswer/coding_agent/harness_session_controller.dart';

void main() {
  test(
    'stable bindings preserve owner; changed participant and grants restart',
    () async {
      final services = AcpClientServices(canAccessSession: (_) => false);
      final config = HarnessHostConfig(
        backend: 'external_acp',
        externalAcpCommand: '/installed/agent',
        externalAcpWorkingDirectory: '/owner/candidate',
        externalAcpConversationKey: 'doc:actor:conversation',
        externalAcpClientServices: services,
        externalAcpArguments: const ['--acp'],
      );
      final controller = HarnessSessionController(config: config);
      addTearDown(controller.dispose);
      final initialHost = controller.host;
      await controller.switchBackend(config.copyWith());
      expect(identical(controller.host, initialHost), true);
      expect(
        identical(controller.config.externalAcpClientServices, services),
        true,
      );
      await controller.switchBackend(
        config.copyWith(
          externalAcpConversationKey: 'doc:another-actor:conversation',
        ),
      );
      expect(identical(controller.host, initialHost), false);
      final secondHost = controller.host;
      await controller.switchBackend(
        controller.config.copyWith(
          externalAcpClientServices: AcpClientServices(
            canAccessSession: (_) => false,
          ),
        ),
      );
      expect(identical(controller.host, secondHost), false);
      expect(
        controller.config.externalAcpConversationKey,
        'doc:another-actor:conversation',
      );
    },
  );
}
