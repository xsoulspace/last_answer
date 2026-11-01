import 'dart:io' show Directory, File;

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart'
    show CachedQwen3Snapshot;

void main() {
  // ADR 0023 §1a — the brainRef binding grammar: local casts with
  // per-binding sampling params, tolerant parsing, and the option list
  // every cached Qwen3 variant feeds.
  group('parseLocalBrainRef', () {
    test('plain casts parse with no params', () {
      expect(parseLocalBrainRef('local:qwen')?.cast, 'qwen');
      expect(parseLocalBrainRef('local:qwen')?.temperature, isNull);
      expect(parseLocalBrainRef('local:qwen')?.repetitionPenalty, isNull);
      expect(parseLocalBrainRef('local:lfm')?.cast, 'lfm');
    });

    test('named variants parse', () {
      expect(parseLocalBrainRef('local:qwen3-1.7b')?.cast, 'qwen3-1.7b');
    });

    test('sampling params parse', () {
      final params = parseLocalBrainRef(
        'local:qwen?temperature=0.4&repetitionPenalty=1.15',
      );
      expect(params?.cast, 'qwen');
      expect(params?.temperature, 0.4);
      expect(params?.repetitionPenalty, 1.15);
    });

    test('lora params parse (registry id, path, scale)', () {
      final registry = parseLocalBrainRef(
        'local:qwen?lora=mean-lora&loraScale=0.5',
      );
      expect(registry?.cast, 'qwen');
      expect(registry?.lora, 'mean-lora');
      expect(registry?.loraScale, 0.5);

      final path = parseLocalBrainRef(
        'local:lfm?lora=/loras/mean/adapter.safetensors',
      );
      expect(path?.lora, '/loras/mean/adapter.safetensors');
      expect(path?.loraScale, isNull, reason: 'the scale defaults, unparse');
    });

    test('an empty lora value reads as unset; malformed scale reads as unset',
        () {
      final params = parseLocalBrainRef('local:qwen?lora=&loraScale=strong');
      expect(params?.lora, isNull);
      expect(params?.loraScale, isNull);
    });

    test('unknown keys are ignored, never fatal', () {
      final params = parseLocalBrainRef(
        'local:qwen?temperature=0.4&mood=sunny',
      );
      expect(params?.cast, 'qwen');
      expect(params?.temperature, 0.4);
    });

    test('malformed values read as unset (defaults apply)', () {
      final params = parseLocalBrainRef(
        'local:qwen?temperature=highest&repetitionPenalty=',
      );
      expect(params?.cast, 'qwen');
      expect(params?.temperature, isNull);
      expect(params?.repetitionPenalty, isNull);
    });

    test('junk query parts are ignored', () {
      final params = parseLocalBrainRef('local:qwen?&&temperature=0.4');
      expect(params?.cast, 'qwen');
      expect(params?.temperature, 0.4);
    });

    test('whitespace around the ref is tolerated', () {
      expect(parseLocalBrainRef(' local:qwen ')?.cast, 'qwen');
    });

    test('non-local refs and empty casts name nothing', () {
      expect(parseLocalBrainRef('openrouter:meta-llama/Llama-3'), isNull);
      expect(parseLocalBrainRef('local:'), isNull);
      expect(parseLocalBrainRef('local:?temperature=0.4'), isNull);
      expect(parseLocalBrainRef(''), isNull);
    });
  });

  group('chat sampling defaults', () {
    test('chat is not greedy: 0.7 + mild penalty unless overridden', () {
      final chatDefaults = resolveBrain(
        'local:qwen',
        resolveOpenRouterApiKey: () => null,
      );
      // macOS test host: the local cast resolves; its sampling fields
      // carry the chat defaults.
      if (mlxSupported) {
        final brain = chatDefaults;
        expect(brain, isNotNull);
        expect(brain!.ref, 'local:qwen');
        expect(
          parseLocalBrainRef(brain.ref),
          isNotNull,
          reason: 'the ref round-trips through the grammar',
        );
      }
      // The defaults are constants with the documented values.
      expect(defaultChatTemperature, 0.7);
      expect(defaultChatRepetitionPenalty, 1.1);
    });

    test('per-binding override parses into explicit params', () {
      final params = parseLocalBrainRef(
        'local:qwen?temperature=0.0&repetitionPenalty=1.0',
      );
      // A future coding lane pins 0.0/1.0 explicitly.
      expect(params?.temperature, 0.0);
      expect(params?.repetitionPenalty, 1.0);
    });
  });

  group('resolveBrain', () {
    test('local casts resolve on a macOS host, unknown variants do not',
        () {
      if (!mlxSupported) return;
      expect(
        resolveBrain('local:qwen', resolveOpenRouterApiKey: () => null),
        isNotNull,
      );
      expect(
        resolveBrain('local:lfm', resolveOpenRouterApiKey: () => null),
        isNotNull,
      );
      // A variant this machine never cached names nothing.
      expect(
        resolveBrain(
          'local:qwen3-not-a-model',
          resolveOpenRouterApiKey: () => null,
        ),
        isNull,
      );
    });

    test('a lora REGISTRY id resolves inside the injected loras root', () {
      if (!mlxSupported) return;
      final root = Directory.systemTemp.createTempSync('la_loras_root');
      addTearDown(() => root.deleteSync(recursive: true));
      // Shape 1: the default adapter file name.
      final mean = Directory('${root.path}/mean-lora')
        ..createSync(recursive: true);
      File('${mean.path}/adapter.safetensors').writeAsStringSync('x');
      final brain = resolveBrain(
        'local:qwen?lora=mean-lora&loraScale=0.5',
        resolveOpenRouterApiKey: () => null,
        loraRoot: root.path,
      );
      expect(brain, isNotNull);
      final params = parseLocalBrainRef(brain!.ref);
      expect(params?.lora, 'mean-lora', reason: 'the ref round-trips');
      expect(
        resolveLoraAdapterPath('mean-lora', root: root.path),
        '${mean.path}/adapter.safetensors',
      );
    });

    test('a registry id without the default name scans its own directory '
        '(lexicographically first, never recursive)', () {
      final root = Directory.systemTemp.createTempSync('la_loras_root');
      addTearDown(() => root.deleteSync(recursive: true));
      final dir = Directory('${root.path}/scanned')..createSync(recursive: true);
      File('${dir.path}/beta.safetensors').writeAsStringSync('x');
      File('${dir.path}/alpha.safetensors').writeAsStringSync('x');
      // A NESTED safetensors is invisible to the flat scan.
      Directory('${dir.path}/nested').createSync();
      File('${dir.path}/nested/aaa.safetensors').writeAsStringSync('x');
      expect(
        resolveLoraAdapterPath('scanned', root: root.path),
        '${dir.path}/alpha.safetensors',
      );
    });

    test('a lora id that names nothing makes the whole ref resolve null', () {
      if (!mlxSupported) return;
      final root = Directory.systemTemp.createTempSync('la_loras_root');
      addTearDown(() => root.deleteSync(recursive: true));
      expect(
        resolveBrain(
          'local:qwen?lora=absent-adapter',
          resolveOpenRouterApiKey: () => null,
          loraRoot: root.path,
        ),
        isNull,
        reason: 'a binding to an adapter this machine lacks names nothing',
      );
    });

    test('registry ids cannot traverse: dot-names are refused, paths are '
        'not ids', () {
      final root = Directory.systemTemp.createTempSync('la_loras_root');
      addTearDown(() => root.deleteSync(recursive: true));
      // `..` carries no `/`, so it parses as an id — and the id shape
      // guard refuses it: the resolution can never leave the root.
      expect(resolveLoraAdapterPath('..', root: root.path), isNull);
      expect(resolveLoraAdapterPath('.', root: root.path), isNull);
      // A `/` value is a PATH by the documented rule — used verbatim and
      // validated at attach time, never silently turned into an id.
      expect(
        resolveLoraAdapterPath('../escape', root: root.path),
        '../escape',
      );
    });

    test('openrouter refs keep their model and need no local engine', () {
      final brain = resolveBrain(
        'openrouter:openai/gpt-4o-mini',
        resolveOpenRouterApiKey: () => 'sk-test',
      );
      expect(brain?.ref, 'openrouter:openai/gpt-4o-mini');
      expect(brain?.label, contains('openai/gpt-4o-mini'));
      expect(
        resolveBrain('openrouter:', resolveOpenRouterApiKey: () => 'sk-test'),
        isNull,
      );
    });
  });

  group('availableBrainOptions', () {
    test('shape holds: ref + label pairs, openrouter entry present', () {
      final options = availableBrainOptions(
        defaultOpenRouterModel: 'meta-llama/llama-3',
        discoverQwen3Variants: () => const <CachedQwen3Snapshot>[],
      );
      expect(options, everyElement(
        isA<({String ref, String label})>()
            .having((final o) => o.ref, 'ref', isNotEmpty)
            .having((final o) => o.label, 'label', isNotEmpty),
      ));
      expect(
        options.map((final o) => o.ref),
        contains('openrouter:meta-llama/llama-3'),
      );
    });

    test('every discovered cached variant is listed with its param count',
        () {
      final options = availableBrainOptions(
        defaultOpenRouterModel: '',
        discoverQwen3Variants: () => const <CachedQwen3Snapshot>[
          CachedQwen3Snapshot(
            refName: 'qwen3-0.6b',
            paramLabel: '0.6B',
            snapshotDir: '/hub/qwen3-0.6b/snapshots/x',
          ),
          CachedQwen3Snapshot(
            refName: 'qwen3-1.7b',
            paramLabel: '1.7B',
            snapshotDir: '/hub/qwen3-1.7b/snapshots/x',
          ),
        ],
      );
      if (!mlxSupported) {
        expect(options, isEmpty);
        return;
      }
      final refs = options.map((final o) => o.ref).toList();
      // The default 0.6B 4-bit cast IS local:qwen — not listed twice.
      expect(refs.contains('local:qwen3-0.6b'), isFalse);
      expect(refs, contains('local:qwen3-1.7b'));
      final label1_7 = options
          .firstWhere((final o) => o.ref == 'local:qwen3-1.7b')
          .label;
      expect(label1_7, contains('1.7B'));
      expect(label1_7, contains('local'));
    });

    test('quant-tagged variants keep their tag in ref and label', () {
      final options = availableBrainOptions(
        defaultOpenRouterModel: '',
        discoverQwen3Variants: () => const <CachedQwen3Snapshot>[
          CachedQwen3Snapshot(
            refName: 'qwen3-0.6b-bf16',
            paramLabel: '0.6B',
            snapshotDir: '/hub/qwen3-0.6b-bf16/snapshots/x',
          ),
        ],
      );
      if (!mlxSupported) return;
      final bf16 = options
          .firstWhere((final o) => o.ref == 'local:qwen3-0.6b-bf16');
      expect(bf16.label, contains('bf16'));
    });
  });
}
