/// Wave N2 — the reasoning wire: the model's declaration rides the
/// in-app request (the old render dropped it), the per-actor grammar
/// param overrides it for ONE actor (the Zed per-selection law), and
/// the daemon-served builtin lanes resolve to in-app silence instead
/// of a fake client.
library;
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lastanswer/chat/actor_brain.dart';

const _decl = CastBrainDecl(
  id: 'modelscope_qwen38max',
  model: 'Qwen3.8-Max-Preview',
  transport: 'openai_compatible',
  baseUrl: 'https://api-inference.modelscope.ai/v1',
  credentialEnv: 'MODELSCOPE_API_KEY',
);

http.Response _ok(final http.Request request, final List<Map<String, Object?>> bodies) {
  bodies.add(
    Map<String, Object?>.from(jsonDecode(request.body) as Map<String, Object?>),
  );
  return http.Response(
    jsonEncode({
      'id': 'cmpl-r',
      'model': _decl.model,
      'choices': [
        {
          'message': {'role': 'assistant', 'content': 'ok'},
        },
      ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  group('the reasoning wire (wave N2)', () {
    test('declared effort + include ride the request; the grammar '
        'param overrides per actor', () async {
      final bodies = <Map<String, Object?>>[];
      final declared = CastBrainDecl(
        id: _decl.id,
        model: _decl.model,
        transport: _decl.transport,
        baseUrl: _decl.baseUrl,
        credentialEnv: _decl.credentialEnv,
        reasoningEffort: 'high',
        includeReasoning: true,
      );
      final brain = PaletteCastBrain(
        decl: declared,
        resolveApiKey: () => 'k',
        httpClient: MockClient((final r) async => _ok(r, bodies)),
      );
      await brain.generate(
        system: 's',
        turns: const [BrainTurn(fromMe: false, content: 'hi')],
      );
      expect(bodies.single['reasoning_effort'], 'high');
      expect(bodies.single['include_reasoning'], true);

      final overridden = PaletteCastBrain(
        decl: declared,
        reasoningOverride: 'low',
        resolveApiKey: () => 'k',
        httpClient: MockClient((final r) async => _ok(r, bodies)),
      );
      await overridden.generate(
        system: 's',
        turns: const [BrainTurn(fromMe: false, content: 'hi')],
      );
      expect(bodies.last['reasoning_effort'], 'low');
      expect(bodies.last['include_reasoning'], true);
    });

    test('a hosted builtin cast resolves to in-app silence — the '
        'daemon serves that lane; the MLX builtins stay in-process',
        () {
      const jev = CastBrainDecl(
        id: 'jev',
        model: 'jev',
        transport: 'builtin',
      );
      expect(
        resolveBrain(
          'cast:jev',
          resolveOpenRouterApiKey: () => 'k',
          resolveCast: (final id) => id == 'jev' ? jev : null,
        ),
        isNull,
      );
      const qwen = CastBrainDecl(
        id: 'qwen',
        model: 'qwen',
        transport: 'builtin',
      );
      final brain = resolveBrain(
        'cast:qwen',
        resolveOpenRouterApiKey: () => 'k',
        resolveCast: (final id) => id == 'qwen' ? qwen : null,
      );
      expect(brain != null, mlxSupported, reason: 'the MLX lane fact');
    });
  });
}
