import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:xsoulspace_agentic_harness/xsoulspace_agentic_harness.dart'
    show ModelId;

void main() {
  group('HarnessHostConfig external_acp backend', () {
    test('builds a binding when the command is resolvable', () {
      const config = HarnessHostConfig(
        backend: 'external_acp',
        externalAcpCommand: 'pi-acp',
        externalAcpArguments: ['--flag'],
        externalAcpEnvironment: {'KEY': 'value'},
        externalAcpWorkingDirectory: '/tmp/ws',
      );
      expect(config.openRouterKeyResolvable, isTrue);
      final backend = config.buildBackend();
      expect(backend.backend, 'external_acp');
      expect(backend.bindings['external_acp'], isNotNull);
      // The router is built lazily per model request — resolve it.
      final router = backend.bindings['external_acp']!.buildRouter(
        model: 'harnessd',
      );
      expect(router, isNotNull);
      expect(
        router!.models.containsKey(const ModelId('harnessd')),
        isTrue,
      );
    });

    test('no command → no binding and named unresolvability', () {
      const config = HarnessHostConfig(backend: 'external_acp');
      expect(config.openRouterKeyResolvable, isFalse);
      final backend = config.buildBackend();
      expect(backend.bindings['external_acp'], isNull);
    });

    test('copyWith swaps the external command for a server switch', () {
      const base = HarnessHostConfig(
        backend: 'external_acp',
        externalAcpCommand: 'a',
      );
      final switched = base.copyWith(externalAcpCommand: 'b');
      expect(switched.externalAcpCommand, 'b');
      expect(base.externalAcpCommand, 'a');
    });

    test('other backends stay untouched by the external fields', () {
      const config = HarnessHostConfig(
        externalAcpCommand: 'unused',
      );
      final backend = config.buildBackend();
      expect(backend.bindings['external_acp'], isNull);
      expect(config.openRouterKeyResolvable, isTrue);
    });
  });
}
