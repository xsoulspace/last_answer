import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/product_agent_mcp_tools.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

class _Document implements AgentDocProductHandle {
  _Document(this.id);
  final String id;
  final calls = <Map<String, Object?>>[];
  @override
  SessionSnapshot get state => SessionSnapshot(sessionId: id, kind: 'test');
  @override
  Future<Map<String, Object?>> configureNative({
    required String workspace,
    required String model,
    required bool grantConsent,
    String? check,
  }) async {
    calls.add({
      'workspace': workspace,
      'model': model,
      'grantConsent': grantConsent,
      'check': check,
    });
    return {'ok': true};
  }

  @override
  Future<Map<String, Object?>> codingAction(
    String action,
    Map<String, Object?> arguments,
  ) async {
    calls.add({'action': action, ...arguments});
    return {'ok': true};
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  final registry = HarnessSessionRegistry.instance;
  late _Document first;
  late _Document second;
  setUp(() {
    first = _Document('agent-product-first');
    second = _Document('agent-product-second');
    registry
      ..register(first.id, first)
      ..register(second.id, second)
      ..focused = second.id;
  });
  tearDown(() {
    registry
      ..unregister(first.id, first)
      ..unregister(second.id, second);
  });

  test(
    'configuration targets exact document and retains explicit consent',
    () async {
      final tool = productAgentMcpEntries().firstWhere(
        (entry) => entry.name == 'agent_doc_configure_native',
      );
      final result = await tool.invokeDirect({
        'docId': 'product-first',
        'workspace': '/workspace',
        'model': 'gpt-6-luna',
        'grantConsent': false,
      });
      expect(result.data['ok'], true);
      expect(first.calls.single['grantConsent'], false);
      expect(second.calls, isEmpty);
    },
  );

  test(
    'unknown explicit document never falls back to focused document',
    () async {
      final tool = productAgentMcpEntries().firstWhere(
        (entry) => entry.name == 'agent_coding_change',
      );
      final result = await tool.invokeDirect({
        'docId': 'missing',
        'action': 'status',
      });
      expect(result.data['ok'], false);
      expect(first.calls, isEmpty);
      expect(second.calls, isEmpty);
    },
  );

  test(
    'reapply requests fresh review and undo uses admitted recovery',
    () async {
      final tool = productAgentMcpEntries().firstWhere(
        (entry) => entry.name == 'agent_coding_change',
      );
      await tool.invokeDirect({
        'docId': 'product-first',
        'action': 'reapply',
        'candidateId': 'candidate',
      });
      await tool.invokeDirect({
        'docId': 'product-first',
        'action': 'undo',
        'runId': 'run',
      });
      expect(first.calls, [
        {'action': 'reviewSaved', 'candidateId': 'candidate'},
        {'action': 'recoverRollback', 'runId': 'run'},
      ]);
      expect(second.calls, isEmpty);
    },
  );
}
