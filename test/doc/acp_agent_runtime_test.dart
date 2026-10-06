import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';
import 'package:lastanswer/doc/acp_agent_runtime_registry.dart';

class _RecordingSink implements StringSink {
  final lines = <String>[];

  @override
  void write(Object? object) {
    final value = '$object';
    if (value.trim().isEmpty) return;
    lines.add(value);
    _onLine?.call(value);
  }

  @override
  void writeln([Object? object = '']) => write('$object\n');

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      write(objects.join(separator));

  @override
  void writeCharCode(int charCode) => write(String.fromCharCode(charCode));

  void Function(String line)? _onLine;
}

final class _FakeAgent {
  _FakeAgent() {
    sink._onLine = _handleClientMessage;
  }

  final _output = StreamController<List<int>>();
  final sink = _RecordingSink();
  late final AcpClient client = AcpClient(
    agentOutput: _output.stream,
    agentInput: sink,
    permissionHandler: (_) async => AcpPermissionOutcome.reject,
  );
  bool cancelRequested = false;
  Completer<void>? waitingForCancel;

  void respond(int id, Map<String, Object?> result) =>
      _send({'jsonrpc': '2.0', 'id': id, 'result': result});

  Future<void> dispose() async {
    await client.dispose();
    await _output.close();
  }

  void _handleClientMessage(String line) {
    final message = jsonDecode(line) as Map<String, dynamic>;
    final id = message['id'] as int?;
    final method = message['method'] as String?;
    if (method == null) return;
    switch (method) {
      case 'initialize':
        respond(id!, {'protocolVersion': 1});
      case 'session/new':
        respond(id!, {'sessionId': 'session-1'});
      case 'session/prompt':
        unawaited(_runPrompt(id!));
      case 'session/cancel':
        cancelRequested = true;
        waitingForCancel?.complete();
    }
  }

  Future<void> _runPrompt(int requestId) async {
    Future<void> update(Map<String, Object?> value) async {
      const method = 'session/update';
      final message = {'jsonrpc': '2.0', 'method': method, 'params': value};
      _output.add(utf8.encode('${jsonEncode(message)}\n'));
      await Future<void>.delayed(Duration.zero);
    }

    await update(_chunk('Hello '));
    if (!cancelRequested) {
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
    await update(_chunk('world'));
    respond(requestId, {
      'stopReason': cancelRequested ? 'cancelled' : 'end_turn',
    });
  }

  Map<String, Object?> _chunk(String text) => {
    'sessionId': 'session-1',
    'update': {
      'sessionUpdate': 'agent_message_chunk',
      'content': {'type': 'text', 'text': text},
    },
  };

  void _send(Map<String, Object?> message) =>
      _output.add(utf8.encode('${jsonEncode(message)}\n'));
}

AcpRuntimeConfig get config => const AcpRuntimeConfig(command: 'fake-agent');

void main() {
  test(
    'detects the first available command without shell interpolation',
    () async {
      final service = AcpInstallationService(
        catalog: const AcpAgentCatalog(
          entries: [
            AcpAgentCatalogEntry(
              id: 'codex',
              displayName: 'Codex',
              commandCandidates: ['missing', 'codex'],
            ),
          ],
        ),
        processRunner: (candidate) async => candidate == 'missing'
            ? const ProcessRunResult(1, '')
            : const ProcessRunResult(0, '/usr/local/bin/codex'),
      );

      final installations = await service.detectAll();
      expect(installations, hasLength(1));
      expect(installations.single.path, '/usr/local/bin/codex');
    },
  );

  test('initializes once, creates sessions, and streams updates', () async {
    final agent = _FakeAgent();
    var factories = 0;
    final runtime = AcpAgentRuntime(
      clientFactory: (_, __, {onStderr}) async {
        factories += 1;
        return agent.client;
      },
    );

    expect(runtime.status, AcpRuntimeStatus.idle);
    await runtime.start(config);
    await runtime.start(config);
    expect(runtime.status, AcpRuntimeStatus.ready);
    expect(factories, 1);

    await runtime.newSession('/tmp/project');
    expect(runtime.currentSessionId, 'session-1');
    runtime.switchTo('session-1');

    final stream = runtime.send('write');
    final text = StringBuffer();
    await for (final update in stream) {
      final delta = update.textDelta;
      if (delta != null) text.write(delta);
    }
    expect(text.toString(), 'Hello world');
    await runtime.stop();
    expect(runtime.status, AcpRuntimeStatus.stopped);
    expect(agent.client.isClosed, isTrue);
  });

  test('cancel notifies the active ACP session', () async {
    final agent = _FakeAgent();
    final runtime = AcpAgentRuntime(
      clientFactory: (_, __, {onStderr}) async => agent.client,
    );
    await runtime.start(config);
    await runtime.newSession('/tmp/project');

    final done = Completer<String>();
    unawaited(() async {
      try {
        await runtime.send('long task').drain<void>();
        done.complete('completed');
      } catch (error) {
        done.completeError(error);
      }
    }());
    await Future<void>.delayed(const Duration(milliseconds: 10));
    runtime.cancel();
    await done.future;

    expect(agent.cancelRequested, isTrue);
    await runtime.stop();
  });

  test('reports error state when initialization fails', () async {
    final runtime = AcpAgentRuntime(
      clientFactory: (_, __, {onStderr}) async => throw StateError('spawn failed'),
    );

    await expectLater(runtime.start(config), throwsStateError);
    expect(runtime.status, AcpRuntimeStatus.error);
    expect(runtime.error, isA<StateError>());
  });

  test('does not execute declarative install commands', () {
    const entry = AcpAgentCatalogEntry(
      id: 'gemini',
      displayName: 'Gemini',
      commandCandidates: ['gemini'],
      installCommand: ['npm', 'install', '-g', '@google/gemini-cli'],
    );

    expect(entry.installCommand, isNotNull);
  });

  test('accepts executable local paths as installable clients', () async {
    final tempDir = Directory.systemTemp.createTempSync('acp-local-');
    final path = '${tempDir.path}/fake-acp';
    File(path).writeAsStringSync('#!/bin/sh\nexit 0\n');
    Process.runSync('chmod', ['+x', path]);
    addTearDown(() => tempDir.deleteSync(recursive: true));

    final service = AcpInstallationService();
    final installation = await service.detectLocalPath(path);

    expect(installation, isNotNull);
    expect(installation!.path, path);
    expect(await service.detectLocalPath(tempDir.path), isNull);
    expect(await service.detectLocalPath('$tempDir/missing'), isNull);
  });

  test(
    'accepts symlinks and rejects relative or non-executable paths',
    () async {
      final tempDir = Directory.systemTemp.createTempSync('acp-local-');
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final executable = File('${tempDir.path}/agent')
        ..writeAsStringSync('#!/bin/sh\nexit 0\n');
      Process.runSync('chmod', ['+x', executable.path]);
      final link = Link('${tempDir.path}/linked-agent');
      Link('${tempDir.path}/linked-agent').createSync(executable.path);
      File('${tempDir.path}/plain').writeAsStringSync('data');

      final service = AcpInstallationService();
      expect((await service.detectLocalPath(link.path))?.path, link.path);
      expect(await service.detectLocalPath('relative-agent'), isNull);
      expect(await service.detectLocalPath('${tempDir.path}/plain'), isNull);
    },
  );

  test('pi ships in the built-in catalog', () {
    const catalog = AcpAgentCatalog();
    final pi = catalog.entries.firstWhere((entry) => entry.id == 'pi');
    expect(pi.commandCandidates, contains('pi-acp'));
    expect(pi.installCommand, isNotNull);
  });

  test(
    'permission requests surface as awaitable pendings and gate the turn',
    () async {
      final fromClient = StreamController<List<int>>();
      final fromServer = StreamController<List<int>>();
      final backend = _GatedBackend();
      final server = AcpStdioServer(
        backend: backend,
        inputStream: fromClient.stream,
        outputSink: _ForwardSink(fromServer),
      );
      server.run().ignore();

      final runtime = AcpAgentRuntime(
        clientFactory: (config, permissionDelegate, {onStderr}) async =>
            AcpClient(
              agentOutput: fromServer.stream,
              agentInput: _ForwardSink(fromClient),
              permissionHandler: permissionDelegate,
              initializeSettleDelay: Duration.zero,
            ),
      );
      final pendings = <AcpPendingPermission>[];
      runtime.permissionRequests.listen(pendings.add);

      await runtime.start(config);
      final sessionId = await runtime.newSession('/tmp/project');

      final updates = <AcpPromptUpdate>[];
      final done = Completer<void>();
      runtime
          .send('go', sessionId: sessionId)
          .listen(updates.add, onDone: done.complete);

      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(pendings, hasLength(1));
      expect(runtime.pendingPermissions, hasLength(1));
      expect(pendings.single.request.title, 'write main.dart');

      await pendings.single.allow();
      await done.future;

      expect(pendings.single.isAnswered, isTrue);
      expect(runtime.pendingPermissions, isEmpty);
      final text = updates
          .map((update) => update.textDelta ?? '')
          .join();
      expect(text, contains('outcome: allow'));
      // Tool titles ride as message updates — the chat renders them as
      // durable beat rows.
      expect(
        updates.any((update) => update.message == 'bash · ls'),
        isTrue,
      );

      await runtime.stop();
      await fromClient.close();
      await fromServer.close();
    },
  );

  test('registry keeps one runtime per doc and restarts on agent switch',
      () async {
    final startedCommands = <String>[];
    final registry = AcpAgentRuntimeRegistry(
      clientFactory: (config, permissionDelegate, {onStderr}) async {
        startedCommands.add(config.command);
        // Each start gets its own auto-responding in-process agent —
        // initialize must complete for the runtime to become ready.
        return _FakeAgent().client;
      },
    );
    final first = registry.forDoc('doc-1');
    expect(identical(registry.forDoc('doc-1'), first), isTrue);
    expect(registry.forDoc('doc-2'), isNot(same(first)));

    await registry.ensureStarted(
      'doc-1',
      'gemini',
      const AcpRuntimeConfig(command: 'gemini'),
    );
    await registry.ensureStarted(
      'doc-1',
      'gemini',
      const AcpRuntimeConfig(command: 'gemini'),
    );
    // Idempotent while the selected agent is unchanged.
    expect(startedCommands, ['gemini']);
    // A switch restarts the process with the new agent.
    await registry.ensureStarted(
      'doc-1',
      'codex',
      const AcpRuntimeConfig(command: 'codex'),
    );
    expect(startedCommands, ['gemini', 'codex']);
    await registry.disposeAll();
    expect(registry.maybe('doc-1'), isNull);
  });
}

/// Writes every line through as raw bytes (client stdin ↔ server input).
final class _ForwardSink implements StringSink {
  _ForwardSink(this._target);
  final StreamController<List<int>> _target;

  @override
  void writeln([Object? object = '']) {
    final text = '$object';
    if (text.trim().isEmpty) return;
    _target.add(utf8.encode('$text\n'));
  }

  @override
  void write(Object? object) => writeln(object);

  @override
  void writeAll(Iterable<Object?> objects, [String separator = '']) =>
      write(objects.join(separator));

  @override
  void writeCharCode(int charCode) => write(String.fromCharCode(charCode));
}

/// A backend that asks the client for permission mid-turn, then reports the
/// outcome in its text — the write-gate pattern.
class _GatedBackend implements AcpAgentBackend, AcpPermissionRequesting {
  Future<AcpPermissionOutcome> Function(AcpPermissionRequest)? _requester;

  @override
  void attachPermissionRequester(
    Future<AcpPermissionOutcome> Function(AcpPermissionRequest) requester,
  ) {
    _requester = requester;
  }

  @override
  String get name => 'gated';
  @override
  String get version => '0.0.1';
  @override
  Map<String, Object?> get agentCapabilities => const {};

  @override
  Future<String> createSession(AcpSessionNewRequest request) async =>
      'session-1';

  @override
  Future<AcpStopReason> prompt(
    AcpPromptRequest request, {
    required void Function(AcpSessionUpdate update) emit,
    required bool Function() isCancelled,
  }) async {
    emit(const AgentMessageChunk(content: AcpTextBlock('before ')));
    emit(
      const ToolCallUpdate(
        toolCallId: 't1',
        title: 'bash · ls',
        status: 'pending',
      ),
    );
    final outcome = await _requester!(
      const AcpPermissionRequest(
        sessionId: 'session-1',
        toolCallId: 'write-1',
        title: 'write main.dart',
        kind: 'edit',
      ),
    );
    emit(
      AgentMessageChunk(
        content: AcpTextBlock('outcome: ${outcome.name}'),
      ),
    );
    return AcpStopReason.endTurn;
  }

  @override
  Future<AcpPermissionOutcome> requestPermission(
    AcpPermissionRequest request,
  ) async => AcpPermissionOutcome.allow;

  @override
  void cancelSession(String sessionId) {}

  @override
  Future<void> disposeSession(String sessionId) async {}
}
