import 'package:lastanswer/coding_agent/harness_host.dart';
import 'package:test/test.dart';
import 'package:xsoulspace_agentic_afm/xsoulspace_agentic_afm.dart';

/// ADR 0059 — the local text casts (`lfm` / `qwen`) as Last Answer
/// backend options: same binding law as `laya` (no key, no consent gate,
/// local-only), lazy engines (composition never loads weights), and
/// stop() disposes what the config holds. Pure composition — no engine
/// loads here.
void main() {
  group('HarnessHostConfig native text casts', () {
    test('buildBackend registers the lfm binding', () {
      final binding = lfmTextBinding();
      final config = HarnessHostConfig(
        backend: 'lfm',
        model: 'lfm25',
        lfmBinding: binding,
      );

      final backend = config.buildBackend();

      expect(backend.backend, 'lfm');
      expect(binding.isAvailable, isFalse, reason: 'lazy = composed unloaded');
      binding.dispose();
    });

    test('buildBackend registers the qwen binding', () {
      final binding = qwenTextBinding();
      final config = HarnessHostConfig(
        backend: 'qwen',
        model: 'qwen3',
        qwenBinding: binding,
      );

      final backend = config.buildBackend();

      expect(backend.backend, 'qwen');
      binding.dispose();
    });

    test('no binding and no key → resolvable (local capability)', () {
      const config = HarnessHostConfig(backend: 'lfm');

      expect(config.buildBackend(), isNotNull);
      expect(config.openRouterKeyResolvable, isTrue);

      const qwenConfig = HarnessHostConfig(backend: 'qwen');
      expect(qwenConfig.openRouterKeyResolvable, isTrue);
    });

    test('copyWith swaps and clears the cast bindings', () {
      final first = lfmTextBinding();
      final second = qwenTextBinding();
      final base = HarnessHostConfig(
        backend: 'lfm',
        lfmBinding: first,
        qwenBinding: second,
      );

      final clearedLfm = base.copyWith(clearLfmBinding: true);
      expect(clearedLfm.lfmBinding, isNull);
      expect(identical(clearedLfm.qwenBinding, second), isTrue);

      final swap = base.copyWith(
        lfmBinding: lfmTextBinding(),
        clearQwenBinding: true,
      );
      expect(identical(swap.lfmBinding, first), isFalse);
      expect(swap.qwenBinding, isNull);

      first.dispose();
      second.dispose();
      swap.lfmBinding?.dispose();
    });

    test('stop() disposes the config-held cast bindings', () async {
      final lfm = lfmTextBinding();
      final qwen = qwenTextBinding();
      final host = HarnessHost(
        config: HarnessHostConfig(
          backend: 'lfm',
          lfmBinding: lfm,
          qwenBinding: qwen,
        ),
      );

      await host.stop();

      // The bindings mark their clients disposed; a disposed client's
      // availability stays false even after this stop.
      expect(lfm.isAvailable, isFalse);
      expect(qwen.isAvailable, isFalse);
    });
  });
}
