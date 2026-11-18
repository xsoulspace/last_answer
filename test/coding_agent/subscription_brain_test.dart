import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/chatgpt_credentials.dart';
import 'package:lastanswer/coding_agent/chatgpt_gateway_contract.dart';
import 'package:lastanswer/coding_agent/chatgpt_harness_binding.dart';
import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:lastanswer/coding_agent/grok_credentials.dart';
import 'package:lastanswer/coding_agent/grok_harness_binding.dart';
import 'package:lastanswer/coding_agent/grok_subscription_controller.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_world.dart';
import 'package:lastanswer/coding_agent/subscription_provider.dart';
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';

import 'chatgpt_credentials_test.dart' show SecureMemory;

void main() {
  test('subscription brain ref names the provider and the model', () {
    expect(
      subscriptionBrainRef(grokBackend, 'grok-4'),
      'subscription:xai_grok_plan/grok-4',
    );
    expect(
      parseSubscriptionBrainRef(
        'subscription:openai_chatgpt_plan/gpt-5.4?reasoning=high',
      ),
      (providerId: chatGptBackend, model: 'gpt-5.4'),
    );
    expect(
      brainParam(
        'subscription:xai_grok_plan/grok-4?reasoning=low',
        'reasoning',
      ),
      'low',
    );
    expect(parseSubscriptionBrainRef('openrouter:a/b'), isNull);
    expect(parseSubscriptionBrainRef('subscription:xai_grok_plan'), isNull);
    expect(parseSubscriptionBrainRef('subscription:/grok-4'), isNull);
  });

  test('two actors keep two subscription models', () async {
    final clients = <_EchoClient>[];
    ActorBrain? resolve(final String ref) => resolveBrain(
      ref,
      resolveOpenRouterApiKey: () => null,
      resolveSubscription: (final providerId, final model) => () {
        final client = _EchoClient('$providerId/$model');
        clients.add(client);
        return client;
      },
    );

    final chatgpt = resolve(
      'subscription:openai_chatgpt_plan/gpt-a?reasoning=high',
    );
    final grok = resolve('subscription:xai_grok_plan/grok-4?reasoning=low');
    expect(chatgpt, isA<SubscriptionBrain>());
    expect(grok, isA<SubscriptionBrain>());
    expect(
      await chatgpt!.generate(system: 's', turns: const []),
      'openai_chatgpt_plan/gpt-a',
    );
    expect(
      await grok!.generate(system: 's', turns: const []),
      'xai_grok_plan/grok-4',
    );
    expect(clients.map((final client) => client.reasoning), ['high', 'low']);
    expect(
      resolveBrain(
        'subscription:openai_chatgpt_plan/gpt-a',
        resolveOpenRouterApiKey: () => null,
      ),
      isNull,
    );
    expect(
      resolveBrain(
        'subscription:no-such/model',
        resolveOpenRouterApiKey: () => null,
        resolveSubscription: (final providerId, final model) => null,
      ),
      isNull,
    );
  });

  test('the picker lists each signed-in plan and skips a closed one', () {
    final chat =
        ChatGptSubscriptionController(
            credentials: ChatGptCredentials(secureValues: SecureMemory()),
          )
          ..profiles = [
            const ChatGptProfile(
              clientId: 'acct-a',
              subject: 'sub',
              signedIn: true,
              planEnabled: true,
              model: 'gpt-a',
            ),
          ]
          ..activeClientId = 'acct-a'
          ..models = const [
            SubscriptionModel(slug: 'gpt-a', displayName: 'GPT A'),
            SubscriptionModel(slug: 'gpt-b', displayName: 'GPT B'),
          ];
    final grok =
        GrokSubscriptionController(
            credentials: GrokCredentials(secureValues: SecureMemory()),
          )
          ..profiles = [
            const GrokProfile(
              subject: 'user-1',
              signedIn: true,
              planEnabled: true,
            ),
          ]
          ..activeAccountId = 'user-1'
          ..models = const [
            SubscriptionModel(slug: 'grok-4', displayName: 'Grok 4'),
          ];
    final closed =
        GrokSubscriptionController(
            credentials: GrokCredentials(secureValues: SecureMemory()),
          )
          ..profiles = [
            const GrokProfile(
              subject: 'user-2',
              signedIn: true,
              planEnabled: false,
            ),
          ]
          ..activeAccountId = 'user-2'
          ..models = const [
            SubscriptionModel(slug: 'grok-3', displayName: 'Grok 3'),
          ];

    final open = subscriptionBrainChoices(chatgpt: chat, grok: grok);
    expect(open.map((final entry) => entry.model), [
      'gpt-a',
      'gpt-b',
      'grok-4',
    ]);
    expect(open.map((final entry) => entry.providerId).toSet(), {
      chatGptBackend,
      grokBackend,
    });
    final options = availableBrainOptions(
      defaultOpenRouterModel: '',
      discoverQwen3Variants: () => const [],
      subscriptionModels: open,
    );
    expect(
      options.map((final option) => option.ref),
      containsAll([
        'subscription:openai_chatgpt_plan/gpt-a',
        'subscription:openai_chatgpt_plan/gpt-b',
        'subscription:xai_grok_plan/grok-4',
      ]),
    );
    expect(
      subscriptionBrainChoices(
        chatgpt: chat,
        grok: closed,
      ).map((final entry) => entry.providerId),
      everyElement(chatGptBackend),
    );
    expect(
      subscriptionClientFor(
        providerId: grokBackend,
        model: 'grok-4',
        grok: closed,
      ),
      isNull,
    );
    final factory = subscriptionClientFor(
      providerId: chatGptBackend,
      model: 'gpt-b',
      chatgpt: chat,
    );
    expect(factory, isNotNull);
  });

  test('reasoning tiers follow the subscription provider', () {
    expect(
      reasoningTiersForBrainRef(
        'subscription:openai_chatgpt_plan/gpt-a',
        transportOfRung: (_) => null,
      ),
      containsAll(['none', 'xhigh']),
    );
    expect(
      reasoningTiersForBrainRef(
        'subscription:xai_grok_plan/grok-4?reasoning=low',
        transportOfRung: (_) => null,
      ),
      ['low', 'medium', 'high'],
    );
    expect(
      reasoningTiersForBrainRef(
        'subscription:other/model',
        transportOfRung: (_) => null,
      ),
      isEmpty,
    );
  });

  test('a subscription actor stays with the app when a daemon is live', () {
    final service = RealmChatService(debugStartBotDispatcher: false);
    addTearDown(service.dispose);
    expect(
      service.daemonBoundActor(
        const ActorProfile(
          actorId: 'grok-actor',
          displayName: 'Grok',
          brainRef: 'subscription:xai_grok_plan/grok-4',
        ),
      ),
      isFalse,
    );
    expect(
      service.daemonBoundActor(
        const ActorProfile(
          actorId: 'scope',
          displayName: 'Scope',
          brainRef: 'cast:modelscope',
        ),
      ),
      isTrue,
    );
  });

  test('a room runs subscription, OpenRouter, and a cast together', () async {
    final temp = await Directory.systemTemp.createTemp('subscription_room_');
    addTearDown(() => temp.delete(recursive: true));
    final world = (await RealmWorld.open(rootOverride: temp.path))!;
    final host =
        RealmBotHost(
          world: world,
          humanActorId: 'human-1',
          resolveOpenRouterApiKey: () => 'sk-test',
          resolveCast: (final id) => id == 'ms'
              ? const CastBrainDecl(
                  id: 'ms',
                  model: 'Qwen',
                  transport: 'openai_compatible',
                  credentialEnv: 'MS_KEY',
                )
              : null,
          resolveCredential: (final name) => name == 'MS_KEY' ? 'key' : null,
          resolveSubscription: (final providerId, final model) {
            if (providerId != chatGptBackend && providerId != grokBackend) {
              return null;
            }
            return () => _EchoClient('$providerId/$model');
          },
          debugStartDispatcher: false,
        )..syncBots(const [
          ActorProfile(
            actorId: 'chat',
            displayName: 'Chat',
            brainRef: 'subscription:openai_chatgpt_plan/gpt-a',
          ),
          ActorProfile(
            actorId: 'grok',
            displayName: 'Grok',
            brainRef: 'subscription:xai_grok_plan/grok-4',
          ),
          ActorProfile(
            actorId: 'router',
            displayName: 'Router',
            brainRef: 'openrouter:vendor/model',
          ),
          ActorProfile(
            actorId: 'scope',
            displayName: 'Scope',
            brainRef: 'cast:ms',
          ),
          ActorProfile(
            actorId: 'closed',
            displayName: 'Closed',
            brainRef: 'subscription:no-such/model',
          ),
        ]);
    expect(host.isRunning('chat'), isTrue);
    expect(host.isRunning('grok'), isTrue);
    expect(host.isRunning('router'), isTrue);
    expect(host.isRunning('scope'), isTrue);
    expect(host.isRunning('closed'), isFalse);
    host.stopAll();
  });
}

final class _EchoClient implements InferenceClient {
  _EchoClient(this.model);
  final String model;
  String? reasoning;

  @override
  String get id => model;
  @override
  bool get isAvailable => true;
  @override
  Set<InferenceTask> get supportedTasks => const {InferenceTask.text};
  @override
  Future<bool> refreshAvailability() async => true;
  @override
  Future<void> load() async {}
  @override
  void resetAvailabilityCache() {}
  @override
  Future<InferenceResult<InferenceResponse>> infer(
    final InferenceRequest request, {
    final ToolRegistry? toolRegistry,
  }) async {
    reasoning = request.reasoningEffort;
    return InferenceResult.ok(InferenceResponse(rawOutput: model));
  }
}
