// R9.b mechanical in-loop check (the doc's check override). Exit 1 until
// lib/home/project_view.dart wires the agent-doc payload persistence
// (AgentDocSurface.onDocChanged → OpenedProjectNotifier.updateProject) —
// the agent MUST act to flip it. The BEHAVIORAL proof of the same claim is
// test/coding_agent/agent_doc_persistence_test.dart, run by the operator
// as the verdict validation (the in-loop run tool's 30 s default timeout
// cannot fit a `flutter test` compile — recorded finding).
import 'dart:io';

void main() {
  final src = File('lib/home/project_view.dart').readAsStringSync();
  final agentBranch = RegExp(
    r'DocFormatIds\.agent[\s\S]{0,400}',
  ).firstMatch(src)?.group(0) ?? '';
  final wired = agentBranch.contains('onDocChanged') &&
      agentBranch.contains('updateProject');
  if (!wired) {
    // ignore: avoid_print
    print(
      'FAIL: lib/home/project_view.dart does not wire AgentDocSurface'
      '.onDocChanged to OpenedProjectNotifier.updateProject — agent doc '
      'payload changes are lost on app restart.',
    );
    exit(1);
  }
  // ignore: avoid_print
  print('ok: agent-doc payload persistence wired in ProjectView');
}
