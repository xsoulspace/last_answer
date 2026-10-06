import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

final class _Handle implements SessionHandle {
  final tasks = <String>[];
  final permissions = <bool>[];

  @override
  SessionSnapshot get state => SessionSnapshot(
    sessionId: 'runtime-session',
    kind: 'test',
    turnCount: tasks.length,
  );

  @override
  SessionIntentResult delegateTask(String task) {
    tasks.add(task);
    return (ok: true, message: 'queued');
  }

  @override
  SessionIntentResult answerPermission({required bool allow}) {
    permissions.add(allow);
    return (ok: true, message: 'answered');
  }
}

AgentCallEntry _entry(String name) =>
    agentMcpEntries().firstWhere((entry) => entry.name == name);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final registry = HarnessSessionRegistry.instance;
  late _Handle handle;

  setUp(() {
    for (final entry in registry.sessions.entries.toList()) {
      registry.unregister(entry.key, entry.value);
    }
    AgentDocSurface.shadowDoc = null;
    handle = _Handle();
    registry.register('agent-doc', handle);
  });

  tearDown(() {
    registry.unregister('agent-doc', handle);
    AgentDocSurface.shadowDoc = null;
  });

  test(
    'shared schema admits sessionId and delegation returns the live turn',
    () async {
      final result = await _entry(
        'agent_task_delegate',
      ).invokeDirect({'sessionId': 'agent-doc', 'task': 'inspect the graph'});
      expect(result.data['ok'], true);
      expect(result.data['turn'], 1);
      expect(handle.tasks, ['inspect the graph']);
      final state = await _entry(
        'agent_doc_state',
      ).invokeDirect({'sessionId': 'agent-doc'});
      expect(state.data['registryKey'], 'agent-doc');
      expect(state.data['session'], isA<Map>());
    },
  );

  test(
    'raw document aliases use the shared resolver without changing attribution',
    () async {
      final result = await _entry(
        'agent_task_delegate',
      ).invokeDirect({'docId': 'doc', 'task': 'read a beat'});
      expect(result.data['ok'], true);
      expect(handle.tasks, ['read a beat']);
    },
  );

  test(
    'permission isolates the owner from an unknown session',
    () async {
      final rejected = await _entry(
        'agent_permission_answer',
      ).invokeDirect({'sessionId': 'agent-doc', 'allow': 'false'});
      expect(rejected.data['ok'], true);
      expect(handle.permissions, [false]);
      final unknown = await _entry(
        'agent_permission_answer',
      ).invokeDirect({'sessionId': 'missing', 'allow': 'true'});
      expect(unknown.data['ok'], false);
      expect(unknown.data['liveSessions'], ['agent-doc']);
      expect(handle.permissions, [false]);
    },
  );
}
