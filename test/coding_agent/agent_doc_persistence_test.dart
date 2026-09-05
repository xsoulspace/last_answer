// R9.b acceptance test (operator-written — the AGENT's fix must make it
// pass through last_answer): an agent doc's payload changes (workspace
// bind, check override, backend) must PERSIST through the app's
// composition point. ProjectView wires AgentDocSurface.onDocChanged →
// OpenedProjectNotifier.updateProject, whose ProjectsNotifier puts the
// doc into the repository. Without the wiring the binding lives only in
// memory and is lost on app restart (found BY the R9.a headless gate).
//
// The spy stands in for OpenedProjectNotifier's provider slot — the REAL
// notifier's persistence cascade (ProjectsNotifier → LocalDb) is out of
// scope here; what this pins is THE WIRING in lib/home/project_view.dart.
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lastanswer/coding_agent/agent_mcp_tools.dart';
import 'package:lastanswer/coding_agent/coding_agent.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:mcp_toolkit/mcp_toolkit.dart';
import 'package:provider/provider.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

AgentCallEntry _entry(final String name) =>
    agentMcpEntries().firstWhere((final e) => e.name == name);

/// Records every updateProject call; everything else unimplemented.
final class _SpyOpenedProject extends ChangeNotifier
    implements OpenedProjectNotifier {
  _SpyOpenedProject(this.initial);

  final ProjectModel initial;
  final List<ProjectModel> updates = [];

  @override
  LoadableContainer<ProjectModel> get value =>
      LoadableContainer<ProjectModel>.loaded(initial);

  @override
  void updateProject(final ProjectModel item) {
    updates.add(item);
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(final Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  testWidgets(
    'agent doc payload changes persist through the ProjectView wiring '
    '(bind intent → onDocChanged → updateProject)',
    (final tester) async {
      final doc = ProjectModel.emptyAgent() as ProjectModelDoc;
      final spy = _SpyOpenedProject(doc);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<OpenedProjectNotifier>.value(value: spy),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ProjectView()),
          ),
        ),
      );
      await tester.pump();

      expect(
        spy.updates,
        isEmpty,
        reason: 'nothing persists before any payload change',
      );

      // Bind through the intent (never a form fill) — the change must
      // reach the composition point and persist.
      final bind = await _entry('agent_doc_bind')
          .invokeDirect({'workspace': '/tmp/r9b_persistence_ws'});
      expect(bind.data['ok'], isTrue, reason: bind.message);

      await tester.pumpAndSettle();
      expect(
        spy.updates,
        isNotEmpty,
        reason:
            'the surface payload change must reach '
            'OpenedProjectNotifier.updateProject — without the ProjectView '
            'wiring the binding is lost on app restart',
      );
      final persisted = spy.updates.last as ProjectModelDoc;
      expect(persisted.agent, isNotNull);
      expect(persisted.agent!.workspaces, contains('/tmp/r9b_persistence_ws'));
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
