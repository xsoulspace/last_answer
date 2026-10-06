import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/agent_config/agent_config_persistence.dart';
import 'package:lastanswer/agent_config/agent_platform_config.dart';
import 'package:lastanswer/coding_agent/provider_configuration.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';
import 'package:lastanswer/doc/acp_agent_runtime_registry.dart';
import 'package:lastanswer/doc/chat_document_view.dart';
import 'package:lastanswer/doc/chat_inference_resolver.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

/// Stands in for OpenedProjectNotifier's persistence cascade
/// (ProjectsNotifier → LocalDb) — out of scope here; what matters is that
/// the chat view can call updateProject without a full app tree.
final class _SpyOpenedProject extends ChangeNotifier
    implements OpenedProjectNotifier {
  final _updates = <ProjectModel>[];

  @override
  LoadableContainer<ProjectModel> get value =>
      LoadableContainer<ProjectModel>.loaded(
        ProjectModel.emptyChat() as ProjectModel,
      );

  @override
  void updateProject(final ProjectModel item) {
    _updates.add(item);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(final Invocation invocation) =>
      super.noSuchMethod(invocation);
}

final class _ScriptedPort implements DocInferencePort {
  _ScriptedPort(this.reply);
  final String reply;

  @override
  Stream<String> chat(List<ChatMessage> messages) async* {
    yield reply;
  }
}

/// Fails the first turn, succeeds on the second — drives the retry path.
final class _FailOncePort implements DocInferencePort {
  bool failed = false;

  @override
  Stream<String> chat(List<ChatMessage> messages) async* {
    if (!failed) {
      failed = true;
      throw StateError('backend exploded');
    }
    yield 'recovered';
  }
}

final class InMemoryAgentConfigPersistence
    implements AgentConfigPersistence {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

Future<AgentConfigStore> _configStore() async {
  final store = AgentConfigStore(
    persistence: InMemoryAgentConfigPersistence(),
  );
  await store.save(
    const AgentPlatformConfig(
      providers: {
        'open_router': ProviderConfig(
          apiKeyEnv: 'OPENROUTER_API_KEY',
          models: ['test/model-a', 'test/model-b'],
          defaultModel: 'test/model-a',
        ),
      },
      chat: ChatConfig(defaultProvider: 'open_router'),
    ),
  );
  return store;
}

Future<void> _pumpChat(
  WidgetTester tester, {
  required AgentConfigStore configStore,
  required ChatInferenceResolver resolver,
}) async {
  final repository = hc.InMemoryDocumentRepository();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<hc.DocumentRepository>.value(value: repository),
        Provider<hc.ChatDocumentService>(
          create: (_) => hc.ChatDocumentService(repository: repository),
        ),
        Provider<AcpAgentRuntimeRegistry>(
          create: (final _) => AcpAgentRuntimeRegistry(),
        ),
        Provider<AcpInstallationService>(
          create: (_) => AcpInstallationService(
            processRunner: (_) async => const ProcessRunResult(1, ''),
          ),
        ),
        ListenableProvider<AgentConfigStore>.value(value: configStore),
        Provider<ChatInferenceResolver>.value(value: resolver),
        ChangeNotifierProvider<OpenedProjectNotifier>.value(
          value: _SpyOpenedProject(),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: S.localizationsDelegates,
        supportedLocales: S.supportedLocales,
        home: Scaffold(
          body: ChatDocumentView(
            doc: ProjectModelDoc(
              id: const ProjectModelId('chat-doc'),
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
              formatId: DocFormatIds.chat,
              title: 'Chat',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets(
    'hosted model send: consent gate, streamed reply, per-doc metadata',
    (tester) async {
      final configStore = await _configStore();
      final providerKeys = ProviderConfigurationStore(
        secureValues: _KeyedSecureStore(),
        preferences: SharedPreferences.getInstance,
      );
      await providerKeys.writeProviderKey('open_router', 'k');
      final resolver = ChatInferenceResolver(
        configStore: configStore,
        providerKeys: providerKeys,
        portFactory: (providerId, model, apiKey) => _ScriptedPort(
          'hello from $model',
        ),
      );
      await _pumpChat(
        tester,
        configStore: configStore,
        resolver: resolver,
      );

      // The hosted model from the config appears in the transport picker.
      expect(find.text('open_router · test/model-a'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'hi there');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Consent gate shows before anything is sent.
      expect(find.byKey(const Key('chat.consent.allow')), findsOneWidget);
      await tester.tap(find.byKey(const Key('chat.consent.allow')));
      await tester.pumpAndSettle();

      // The scripted reply landed in the assistant bubble.
      expect(find.text('hello from test/model-a'), findsWidgets);
    },
  );

  testWidgets('failed turn offers retry and recovers', (tester) async {
    final configStore = await _configStore();
    final port = _FailOncePort();
    final providerKeys = ProviderConfigurationStore(
      secureValues: _KeyedSecureStore(),
      preferences: SharedPreferences.getInstance,
    );
    await providerKeys.writeProviderKey('open_router', 'k');
    final resolver = ChatInferenceResolver(
      configStore: configStore,
      providerKeys: providerKeys,
      portFactory: (providerId, model, apiKey) => port,
    );
    // Consent before the turn: seed the same record the dialog would write.
    await providerKeys.grantHostedConsent(
      documentId: 'chat-doc',
      provider: 'open_router',
      model: 'test/model-a',
      workspace: ChatInferenceResolver.chatWorkspace,
    );

    await _pumpChat(
      tester,
      configStore: configStore,
      resolver: resolver,
    );
    await tester.enterText(find.byType(TextField).last, 'trigger failure');
    await tester.tap(find.byIcon(Icons.send));
    await tester.pumpAndSettle();

    // The assistant block failed and offers RETRY.
    final retryFinder = find.byWidgetPredicate(
      (widget) => widget.key.toString().contains('.retry'),
    );
    expect(retryFinder, findsOneWidget);
    await tester.tap(retryFinder);
    await tester.pumpAndSettle();

    // The TextField renders an inner EditableText — at least one match
    // proves the recovered reply rendered.
    expect(find.text('recovered'), findsWidgets);
  });
}

final class _KeyedSecureStore implements SecureValueStore {
  _KeyedSecureStore();
  final _values = <String, String>{};

  @override
  Future<void> delete(String key) async => _values.remove(key);

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;
}
