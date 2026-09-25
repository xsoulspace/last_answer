import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/doc/acp_agent_runtime.dart';

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
      clientFactory: (_) async {
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
    final runtime = AcpAgentRuntime(clientFactory: (_) async => agent.client);
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
      clientFactory: (_) async => throw StateError('spawn failed'),
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
}
