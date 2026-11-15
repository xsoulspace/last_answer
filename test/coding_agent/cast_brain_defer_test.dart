import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';

/// G6 — the `cast:` brainRef grammar (the discovered palette as a bot
/// brain) and the defer-to-daemon law (one answerer per actor).
const _decl = CastBrainDecl(
  id: 'modelscope_qwen38max',
  model: 'Qwen3.8-Max-Preview',
  transport: 'openai_compatible',
  baseUrl: 'https://api-inference.modelscope.ai/v1',
  credentialEnv: 'MODELSCOPE_API_KEY',
);

CastBrainDecl? _onlyDecl(final String id) => id == _decl.id ? _decl : null;

void main() {
  group('the cast: grammar', () {
    test('an entry the palette does not declare names nothing', () {
      expect(
        resolveBrain(
          'cast:ghost',
          resolveOpenRouterApiKey: () => null,
          resolveCast: _onlyDecl,
        ),
        isNull,
      );
      expect(
        resolveBrain('cast:', resolveOpenRouterApiKey: () => null),
        isNull,
      );
    });

    test(
      'a declared rung speaks the palette endpoint with its credential',
      () async {
        final seen = <http.Request>[];
        final brain = PaletteCastBrain(
          decl: _decl,
          resolveApiKey: () => 'sk-from-envconfig',
          httpClient: MockClient((final request) async {
            seen.add(request);
            return http.Response(
              jsonEncode({
                'id': 'cmpl-1',
                'model': _decl.model,
                'choices': [
                  {
                    'message': {
                      'role': 'assistant',
                      'content': 'hello from the rung',
                    },
                  },
                ],
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }),
        );
        final reply = await brain.generate(
          system: 'you are scout',
          turns: const [BrainTurn(fromMe: false, content: 'hi')],
        );
        expect(reply, 'hello from the rung');
        expect(seen.single.url.toString(), startsWith(_decl.baseUrl!));
        expect(seen.single.url.path, contains('chat/completions'));
        expect(
          seen.single.headers['authorization'],
          'Bearer sk-from-envconfig',
        );
        final body = jsonDecode(seen.single.body) as Map<String, Object?>;
        expect(body['model'], _decl.model);
        expect(brain.ref, 'cast:modelscope_qwen38max');
      },
    );

    test(
      'a missing credential is the typed unavailability, named by env',
      () async {
        final brain = PaletteCastBrain(
          decl: _decl,
          resolveApiKey: () => null,
          httpClient: MockClient((final _) async => http.Response('', 200)),
        );
        await expectLater(
          brain.generate(system: 's', turns: const []),
          throwsA(
            isA<BrainUnavailable>().having(
              (final e) => e.reason,
              'reason',
              'cast_credential_absent:MODELSCOPE_API_KEY',
            ),
          ),
        );
      },
    );

    test('a builtin cast routes to the local lane', () {
      final brain = resolveBrain(
        'cast:qwen',
        resolveOpenRouterApiKey: () => null,
        resolveCast: (final id) => id == 'qwen'
            ? const CastBrainDecl(
                id: 'qwen',
                model: 'qwen',
                transport: 'builtin',
              )
            : null,
      );
      // macOS tests have MLX; elsewhere the local lane names nothing —
      // either way the ref is the LOCAL grammar, never a hosted wire.
      expect(brain?.ref, mlxSupported ? 'local:qwen' : isNull);
    });

    test(
      'the credential chain: process env, then the flat EnvConfig store',
      () {
        final temp = Directory.systemTemp.createTempSync('cast_cred_');
        addTearDown(() => temp.deleteSync(recursive: true));
        Directory(
          '${temp.path}/.config/xsoulspace/inference',
        ).createSync(recursive: true);
        File(
          '${temp.path}/.config/xsoulspace/inference/config.json',
        ).writeAsStringSync(jsonEncode({'MODELSCOPE_API_KEY': 'sk-flat'}));

        expect(
          readInferenceCredential(
            'MODELSCOPE_API_KEY',
            resolveHome: () => temp.path,
            environment: const {},
          ),
          'sk-flat',
        );
        // The process environment wins (the harness precedence chain).
        expect(
          readInferenceCredential(
            'MODELSCOPE_API_KEY',
            resolveHome: () => temp.path,
            environment: const {'MODELSCOPE_API_KEY': 'sk-process'},
          ),
          'sk-process',
        );
        expect(
          readInferenceCredential(
            'ABSENT_KEY',
            resolveHome: () => temp.path,
            environment: const {},
          ),
          isNull,
        );
      },
    );
  });

  group('the defer-to-daemon law', () {
    test('a live daemon owning the actor keeps the in-app loop out', () async {
      final temp = await Directory.systemTemp.createTemp('cast_defer_');
      addTearDown(() => temp.delete(recursive: true));
      final world = (await RealmWorld.open(rootOverride: temp.path))!;
      const profile = ActorProfile(
        actorId: 'scout',
        displayName: 'Scout',
        brainRef: 'cast:modelscope_qwen38max',
      );
      RealmBotHost host({required bool daemonLive}) => RealmBotHost(
        world: world,
        humanActorId: 'human-1',
        resolveOpenRouterApiKey: () => null,
        resolveCast: _onlyDecl,
        debugStartDispatcher: false,
        daemonOwnsActor: daemonLive ? (_) => true : null,
        debugBrainOverride: (_) => _ScriptedBrain(),
      );

      final deferred = host(daemonLive: true)..syncBots([profile]);
      expect(deferred.isRunning('scout'), isFalse);
      expect(deferred.statuses, isEmpty);
      deferred.stopAll();

      final local = host(daemonLive: false)..syncBots([profile]);
      expect(local.isRunning('scout'), isTrue);
      local.stopAll();
    });
  });
}

/// The narration test's scripted brain, copied small: generate parks a
/// completer; the defer law only needs a resolvable brain.
final class _ScriptedBrain implements ActorBrain {
  @override
  Future<String> generate({
    required final String system,
    required final List<BrainTurn> turns,
  }) async => 'scripted';

  @override
  String get label => 'scripted';

  @override
  String get ref => 'scripted:brain';
}
