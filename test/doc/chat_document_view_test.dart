import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';
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

import '../coding_agent/pump_until.dart';

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

final class InMemoryAgentConfigPersistence implements AgentConfigPersistence {
  String? contents;

  @override
  Future<String?> read() async => contents;

  @override
  Future<void> write(String contents) async => this.contents = contents;
}

Future<AgentConfigStore> _configStore() async {
  final store = AgentConfigStore(persistence: InMemoryAgentConfigPersistence());
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

/// Same as [_configStore] plus one registered ACP agent server, so the
/// transport picker carries an ACP entry whose process the test fakes.
Future<AgentConfigStore> _configStoreWithAcpAgent() async {
  final store = AgentConfigStore(persistence: InMemoryAgentConfigPersistence());
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
      agentServers: {
        'fake': AgentServerConfig(
          command: 'fake-agent',
          displayName: 'Fake ACP',
        ),
      },
    ),
  );
  return store;
}

Future<void> _pumpChat(
  WidgetTester tester, {
  required AgentConfigStore configStore,
  required ChatInferenceResolver resolver,
  AcpAgentRuntimeRegistry? runtimeRegistry,
  hc.InMemoryDocumentRepository? repository,
}) async {
  final docRepository = repository ?? hc.InMemoryDocumentRepository();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<hc.DocumentRepository>.value(value: docRepository),
        Provider<hc.ChatDocumentService>(
          create: (_) => hc.ChatDocumentService(repository: docRepository),
        ),
        Provider<AcpAgentRuntimeRegistry>(
          create: (_) => runtimeRegistry ?? AcpAgentRuntimeRegistry(),
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
        portFactory: (providerId, model, apiKey) =>
            _ScriptedPort('hello from $model'),
      );
      await _pumpChat(tester, configStore: configStore, resolver: resolver);

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

    await _pumpChat(tester, configStore: configStore, resolver: resolver);
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

  testWidgets(
    'ACP permission round-trip answers WHILE the turn is streaming '
    '(the agent holds the turn until it is answered)',
    // ACP is desktop-gated; widget tests default to android.
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      final agent = _FakeAcpAgent(replyPrefix: 'saw the answer');
      addTearDown(agent.dispose);
      final registry = AcpAgentRuntimeRegistry(
        clientFactory: (config, delegate, {onStderr}) async =>
            agent.buildClient(delegate),
      );
      await _pumpChat(
        tester,
        configStore: await _configStoreWithAcpAgent(),
        resolver: _acpOnlyResolver(),
        runtimeRegistry: registry,
      );

      // Pick the fake ACP transport.
      await tester.tap(find.byKey(const Key('chat.transport.picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fake ACP').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'run the tests');
      await tester.tap(find.byIcon(Icons.send));

      // The permission row must surface AND be answerable mid-turn —
      // the pre-fix UI disabled these buttons while _isSending, so the
      // agent waited forever for an answer the UI refused to give.
      final allowFinder = find.byKey(const Key('chat.perm.tool-1.allow'));
      await pumpUntil(tester, () => allowFinder.evaluate().isNotEmpty);
      await tester.pump();
      expect(
        tester.widget<TextButton>(allowFinder).onPressed,
        isNotNull,
        reason: 'allow must be tappable while the turn is streaming',
      );
      await tester.tap(allowFinder);

      await pumpUntil(tester, () => agent.permissionAnswered);
      await pumpUntil(
        tester,
        () => find.textContaining('saw the answer').evaluate().isNotEmpty,
      );
      expect(find.textContaining('PERM → allowed'), findsWidgets);
      // The JSON-RPC result wraps the outcome object.
      expect(
        agent.permissionOutcome?['outcome'],
        containsPair('outcome', 'selected'),
      );
    },
  );

  testWidgets(
    'consecutive ACP turns continue ONE agent session (no session/new '
    'per message)',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      final agent = _FakeAcpAgent(withPermission: false);
      addTearDown(agent.dispose);
      final registry = AcpAgentRuntimeRegistry(
        clientFactory: (config, delegate, {onStderr}) async =>
            agent.buildClient(delegate),
      );
      await _pumpChat(
        tester,
        configStore: await _configStoreWithAcpAgent(),
        resolver: _acpOnlyResolver(),
        runtimeRegistry: registry,
      );

      await tester.tap(find.byKey(const Key('chat.transport.picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fake ACP').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'first message');
      await tester.tap(find.byIcon(Icons.send));
      await pumpUntil(
        tester,
        () => find.textContaining('reply 1').evaluate().isNotEmpty,
      );

      await tester.enterText(find.byType(TextField).last, 'second message');
      await tester.tap(find.byIcon(Icons.send));
      await pumpUntil(
        tester,
        () => find.textContaining('reply 2').evaluate().isNotEmpty,
      );

      expect(
        agent.sessionNewCount,
        1,
        reason:
            'the second turn must RESUME the persisted session, not '
            'start a fresh one with no memory of the first',
      );
      expect(agent.promptCount, 2);
    },
  );

  testWidgets(
    'peer turn hop: a chat-turn task posted to the board is auto-run by '
    'the OWNER device without duplicating the user message',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      // withPermission: false — the permission switcher has its own test;
      // this one isolates the board hop.
      final agent = _FakeAcpAgent(
        withPermission: false,
        replyPrefix: 'peer reply',
      );
      addTearDown(agent.dispose);
      final registry = AcpAgentRuntimeRegistry(
        clientFactory: (config, delegate, {onStderr}) async =>
            agent.buildClient(delegate),
      );
      // The shared task board, mounted with the OWNER's peer id — the
      // same WorldSync-backed board the mesh cycle ships.
      final board = MeshTaskBoard(replicaId: 'owner-1');
      final savedWiring = AgentDocSurface.meshWiring;
      AgentDocSurface.meshWiring = AgentDocMeshWiring(
        routerFor: (_) => throw UnimplementedError(),
        joinDoc: (_) async {},
        leaveDoc: (_) async {},
        statusFor: (_) => const AgentDocMeshStatus(
          hosting: false,
          connected: true,
          peerCount: 2,
          presenceCount: 2,
        ),
        taskBoard: () => board,
        selfPeerId: () => 'owner-1',
      );
      addTearDown(() => AgentDocSurface.meshWiring = savedWiring);

      final repository = hc.InMemoryDocumentRepository();
      final chatService = hc.ChatDocumentService(repository: repository);
      await _pumpChat(
        tester,
        configStore: await _configStoreWithAcpAgent(),
        resolver: _acpOnlyResolver(),
        runtimeRegistry: registry,
        repository: repository,
      );

      await tester.tap(find.byKey(const Key('chat.transport.picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fake ACP').last);
      await tester.pumpAndSettle();

      // The PEER composed a user block into the shared doc (it converged
      // over the mesh) and requested the turn.
      const docId = hc.NodeId('chat-doc');
      const userBlockId = hc.NodeId('peer-msg-1');
      await chatService.appendMessage(
        docId,
        role: hc.ChatRole.user,
        content: 'hello from the peer',
        blockId: userBlockId,
      );
      board.requestTask(
        docId: 'chat-doc',
        task: 'chat-turn peer-msg-1',
        originPeerId: 'peer-2',
      );

      // The owner's sync-cycle hook claims and runs it.
      ChatDocumentView.debugSurface?.refresh();
      await pumpUntil(
        tester,
        () => find.textContaining('peer reply').evaluate().isNotEmpty,
      );
      await pumpUntil(
        tester,
        () =>
            board.tasksFor('chat-doc').firstOrNull?.status ==
            MeshTaskBoard.statusCompleted,
      );

      expect(
        board.tasksFor('chat-doc').single.status,
        MeshTaskBoard.statusCompleted,
      );
      // Exactly ONE user block — the peer's, not a re-appended copy.
      final doc = (await repository.get(docId) as hc.DocFound).node;
      expect(doc.blocks.where((b) => b.role == hc.ChatRole.user), hasLength(1));
      expect(
        doc.blocks.any((b) => b.content.contains('hello from the peer')),
        isTrue,
      );

      // The OWNER sending locally claims the session on the shared doc.
      await pumpUntil(
        tester,
        () => find.byIcon(Icons.send).evaluate().isNotEmpty,
      );
      await tester.enterText(find.byType(TextField).last, 'my own turn');
      await tester.tap(find.byIcon(Icons.send));
      await pumpUntil(
        tester,
        () => find.textContaining('peer reply 2').evaluate().isNotEmpty,
      );
      final claimed =
          (await repository.get(docId) as hc.DocFound).node.blocks.first;
      expect(
        claimed.ownerPeerId,
        'owner-1',
        reason:
            'a local turn must persist the ownership claim so future '
            'PEER turns route to this device',
      );
    },
  );

  testWidgets(
    'permission switcher: FULL auto-answers the mid-turn request without '
    'the user tapping allow',
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    (tester) async {
      final agent = _FakeAcpAgent(replyPrefix: 'unblocked');
      addTearDown(agent.dispose);
      final registry = AcpAgentRuntimeRegistry(
        clientFactory: (config, delegate, {onStderr}) async =>
            agent.buildClient(delegate),
      );
      await _pumpChat(
        tester,
        configStore: await _configStoreWithAcpAgent(),
        resolver: _acpOnlyResolver(),
        runtimeRegistry: registry,
      );

      await tester.tap(find.byKey(const Key('chat.transport.picker')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fake ACP').last);
      await tester.pumpAndSettle();

      // The user flips the stance to FULL before sending (the codex/
      // zed/cursor-style switcher in the header).
      await tester.tap(find.byKey(const Key('chat.perm.mode.fullAccess')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'run the tests');
      await tester.tap(find.byIcon(Icons.send));

      // The fake agent still opens with session/request_permission — but
      // no allow tap happens. The policy answers; the turn completes.
      await pumpUntil(
        tester,
        () => find.textContaining('unblocked').evaluate().isNotEmpty,
      );
      expect(agent.permissionAnswered, isTrue);
      expect(
        find.textContaining('PERM → auto-allowed (full)'),
        findsWidgets,
        reason: 'the durable row must record WHICH layer answered',
      );
      // No per-request buttons surfaced for an auto-answered request.
      expect(find.byKey(const Key('chat.perm.tool-1.allow')), findsNothing);
    },
  );
}

/// A stand-in resolver for ACP-only tests — hosted paths are never taken.
ChatInferenceResolver _acpOnlyResolver() => ChatInferenceResolver(
  configStore: AgentConfigStore(persistence: _NullPersistence()),
  providerKeys: ProviderConfigurationStore(
    secureValues: _KeyedSecureStore(),
    preferences: () async => throw UnimplementedError(),
  ),
  portFactory: (providerId, model, apiKey) => throw UnimplementedError(),
);

final class _NullPersistence implements AgentConfigPersistence {
  @override
  Future<String?> read() async => null;
  @override
  Future<void> write(String contents) async {}
}

/// A fake ACP agent speaking real JSON-RPC over in-memory pipes: the
/// production [AcpClient] drives this side, so the protocol surface
/// (initialize → session/new → session/prompt → session/request_permission)
/// is exercised for real.
final class _FakeAcpAgent {
  _FakeAcpAgent({this.withPermission = true, this.replyPrefix = 'reply'}) {
    sink._onLine = _handleClientMessage;
  }

  /// When true, every turn opens with a `session/request_permission` and
  /// holds until the client answers it.
  final bool withPermission;

  /// First words of every turn's reply (the count follows: 'reply 1').
  final String replyPrefix;

  final _output = StreamController<List<int>>();
  final sink = _RecordingSink();
  int sessionNewCount = 0;
  int promptCount = 0;
  bool permissionAnswered = false;
  Map<String, Object?>? permissionOutcome;
  Completer<Map<String, Object?>>? _permissionAnswer;
  var _nextPermissionId = 900;

  AcpClient buildClient(final AcpPermissionDelegate? delegate) => AcpClient(
    agentOutput: _output.stream,
    agentInput: sink,
    permissionHandler: delegate,
  );

  Future<void> dispose() async {
    await _output.close();
  }

  void respond(final int id, final Map<String, Object?> result) =>
      _send({'jsonrpc': '2.0', 'id': id, 'result': result});

  void _handleClientMessage(final String line) {
    final message = jsonDecode(line) as Map<String, dynamic>;
    final id = message['id'];
    final method = message['method'] as String?;
    if (method != null) {
      switch (method) {
        case 'initialize':
          respond(id! as int, {'protocolVersion': 1});
        case 'session/new':
          sessionNewCount++;
          respond(id! as int, {'sessionId': 'session-1'});
        case 'session/prompt':
          promptCount++;
          unawaited(_runPrompt(id! as int));
        case 'session/cancel':
          break;
      }
      return;
    }
    // A response from the client: the permission answer we were waiting on.
    if (id is int && message.containsKey('result')) {
      final result = (message['result'] as Map).cast<String, Object?>();
      permissionOutcome = result;
      permissionAnswered = true;
      _permissionAnswer?.complete(result);
    }
  }

  Future<void> _runPrompt(final int requestId) async {
    if (withPermission) {
      final permissionId = _nextPermissionId++;
      final answer = Completer<Map<String, Object?>>();
      _permissionAnswer = answer;
      _send({
        'jsonrpc': '2.0',
        'id': permissionId,
        'method': 'session/request_permission',
        'params': {
          'sessionId': 'session-1',
          'toolCallId': 'tool-1',
          'options': [
            {'kind': 'allow_once', 'optionId': 'allow-once'},
            {'kind': 'reject_once', 'optionId': 'reject-once'},
          ],
          '_meta': {
            'title': 'Run tests',
            'kind': 'execute',
            'details': 'dart test',
          },
        },
      });
      // Hold the turn exactly like a real agent: no reply until answered.
      await answer.future;
    }
    await _update(_chunk('$replyPrefix $promptCount '));
    await _update(_chunk('continues'));
    respond(requestId, {'stopReason': 'end_turn'});
  }

  Future<void> _update(final Map<String, Object?> value) async {
    _send({'jsonrpc': '2.0', 'method': 'session/update', 'params': value});
    await Future<void>.delayed(Duration.zero);
  }

  Map<String, Object?> _chunk(final String text) => {
    'sessionId': 'session-1',
    'update': {
      'sessionUpdate': 'agent_message_chunk',
      'content': {'type': 'text', 'text': text},
    },
  };

  void _send(final Map<String, Object?> message) =>
      _output.add(utf8.encode('${jsonEncode(message)}\n'));
}

final class _RecordingSink implements StringSink {
  final lines = <String>[];

  void Function(String line)? _onLine;

  @override
  void write(final Object? object) {
    final value = '$object';
    if (value.trim().isEmpty) return;
    lines.add(value);
    _onLine?.call(value);
  }

  @override
  void writeln([final Object? object = '']) => write('$object\n');

  @override
  void writeAll(
    final Iterable<Object?> objects, [
    final String separator = '',
  ]) => write(objects.join(separator));

  @override
  void writeCharCode(final int charCode) =>
      write(String.fromCharCode(charCode));
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
