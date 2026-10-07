import 'package:dart_acp_toolkit/dart_acp_toolkit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/doc/chat_permission_policy.dart';

AcpPermissionRequest requestOf(final String kind) => AcpPermissionRequest(
  sessionId: 'session-1',
  toolCallId: 'tool-1',
  title: 'Run tests',
  kind: kind,
  details: 'dart test',
);

void main() {
  test('ask (the default) never auto-allows — deny-by-default', () {
    for (final kind in ['read', 'edit', 'move', 'execute', 'delete', 'other']) {
      expect(
        ChatPermissionPolicy.ask.autoAllows(requestOf(kind)),
        isFalse,
        reason: 'ask must surface buttons for $kind',
      );
    }
    expect(ChatPermissionPolicy.fromName(null), ChatPermissionPolicy.ask);
    expect(ChatPermissionPolicy.fromName('nonsense'), ChatPermissionPolicy.ask);
  });

  test('workspace edits auto-allows the working set, asks for the rest', () {
    const policy = ChatPermissionPolicy.workspaceEdits;
    expect(policy.autoAllows(requestOf('read')), isTrue);
    expect(policy.autoAllows(requestOf('edit')), isTrue);
    expect(policy.autoAllows(requestOf('move')), isTrue);
    expect(
      policy.autoAllows(requestOf('execute')),
      isFalse,
      reason: 'a command execution is not a workspace edit',
    );
    expect(policy.autoAllows(requestOf('delete')), isFalse);
    expect(policy.autoAllows(requestOf('other')), isFalse);
  });

  test('full access answers everything', () {
    const policy = ChatPermissionPolicy.fullAccess;
    for (final kind in ['read', 'edit', 'move', 'execute', 'delete', 'other']) {
      expect(policy.autoAllows(requestOf(kind)), isTrue);
    }
  });

  test('agent-mode preference maps onto advertised ids, else null', () {
    const claude = AcpSessionModes(
      currentModeId: 'default',
      available: [
        AcpSessionModeInfo(id: 'default', name: 'Always ask'),
        AcpSessionModeInfo(id: 'acceptEdits', name: 'Accept edits'),
        AcpSessionModeInfo(id: 'plan', name: 'Plan mode'),
        AcpSessionModeInfo(id: 'bypassPermissions', name: 'Bypass'),
      ],
    );
    expect(ChatPermissionPolicy.ask.preferredAgentModeId(claude), 'default');
    expect(
      ChatPermissionPolicy.workspaceEdits.preferredAgentModeId(claude),
      'acceptEdits',
    );
    expect(
      ChatPermissionPolicy.fullAccess.preferredAgentModeId(claude),
      'bypassPermissions',
    );

    // An agent without modes: the client-side policy is the only layer.
    const none = AcpSessionModes(available: []);
    expect(ChatPermissionPolicy.fullAccess.preferredAgentModeId(none), isNull);
  });
}
