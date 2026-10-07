import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/mesh_task_console_view.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_inspector_pane.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/doc/chat_document_view.dart';
import 'package:lastanswer/doc/doc_view.dart';
import 'package:lastanswer/idea/idea_view.dart';
import 'package:lastanswer/note/note_view.dart';
import 'package:lastanswer/settings/views/changelog_view.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({super.key});

  @override
  Widget build(final BuildContext context) {
    final projectContainer = context
        .select<OpenedProjectNotifier, LoadableContainer<ProjectModel>>(
          (final c) => c.value,
        );
    if (projectContainer.isLoading) {
      return const UiCircularProgress();
    }

    final id = projectContainer.value.id;
    return projectContainer.value.map(
      idea: (final idea) => IdeaView(idea: idea, key: ValueKey(id)),
      note: (final note) => _AdaptiveView(
        appBar: const _ProjectViewAppBar(),
        child: NoteView(note: note, key: ValueKey(id)),
      ),
      changelog: (final changelog) => const _AdaptiveView(
        appBar: _ChangelogViewAppBar(),
        child: ChangelogView(),
      ),
          doc: (final doc) => _AdaptiveView(
        appBar: const _ProjectViewAppBar(),
        child: switch (doc.formatId) {
          DocFormatIds.chat => ChatDocumentView(doc: doc, key: ValueKey(id)),
          DocFormatIds.agent => Column(
            children: [
              Expanded(
                child: AgentDocSurface(
                  doc: doc,
                  key: ValueKey(id),
                  // Persist the doc payload (workspace bind, check override,
                  // backend) through the composition point — the same cascade
                  // DocView uses for its listing stub. Without this wiring the
                  // binding lives only in the surface state and is lost on app
                  // restart.
                  onDocChanged: (final updated) => context
                      .read<OpenedProjectNotifier>()
                      .updateProject(updated),
                ),
              ),
              // PLAN 6.C — the mesh task console under the doc surface
              // (hidden whenever no mesh replica is live on this device).
              MeshTaskConsoleView(
                docId: doc.id.value,
                key: ValueKey('mesh-console-$id'),
              ),
              // The world inspector (inspector DESIGN.md rev. 3): the
              // harness's 3D inspector embedded over the ONE session
              // registry — observation here; verbs stay in the doc
              // surface above. The doc's worldBinding (user-chosen,
              // never hardcoded) points the pane at an external world;
              // null = the embedded default. Full-screenable: the
              // mission-control surface for the whole fleet (multiplayer
              // recommendation 5).
              _WorldInspectorRegion(
                key: ValueKey('world-inspector-region-$id'),
                binding: doc.agent?.worldBinding,
                onBindingChanged: (final binding) {
                  final agent = doc.agent ?? const AgentDocModel();
                  context.read<OpenedProjectNotifier>().updateProject(
                    doc.copyWith(
                      agent: agent.copyWith(worldBinding: binding),
                    ),
                  );
                },
              ),
            ],
          ),
          _ => DocView(doc: doc, key: ValueKey(id)),
        },
      ),
    );
  }
}

class _AdaptiveView extends StatelessWidget {
  const _AdaptiveView({required this.child, required this.appBar});
  final Widget appBar;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final screenLayout = ScreenLayout.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (screenLayout.small) appBar else const Gap(42),
        Expanded(child: child),
      ],
    );
  }
}

/// The embedded inspector pane plus its full-screen affordance. The
/// full-screen route hosts a FRESH pane (it self-polls and converges
/// within one tick); the binding pick in either surface persists into
/// the doc payload through the same callback.
class _WorldInspectorRegion extends StatelessWidget {
  const _WorldInspectorRegion({
    required this.binding,
    required this.onBindingChanged,
    super.key,
  });

  final WorldBindingModel? binding;
  final ValueChanged<WorldBindingModel?> onBindingChanged;

  Future<void> _openFullScreen(final BuildContext context) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (final routeContext) => _WorldInspectorFullScreenPage(
            binding: binding,
            onBindingChanged: onBindingChanged,
          ),
        ),
      );

  @override
  Widget build(final BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(
            key: const Key('world_inspector.fullscreen.open'),
            tooltip: 'World inspector full screen',
            icon: const Icon(Icons.fullscreen, size: 20),
            visualDensity: VisualDensity.compact,
            onPressed: () => unawaited(_openFullScreen(context)),
          ),
        ],
      ),
      WorldInspectorPane(binding: binding, onBindingChanged: onBindingChanged),
    ],
  );
}

/// The inspector as the MAIN surface (multiplayer recommendation: the
/// mission-control view for the whole fleet — every session the registry
/// knows, every routed permission, the task board).
class _WorldInspectorFullScreenPage extends StatelessWidget {
  const _WorldInspectorFullScreenPage({
    required this.binding,
    required this.onBindingChanged,
  });

  final WorldBindingModel? binding;
  final ValueChanged<WorldBindingModel?> onBindingChanged;

  @override
  Widget build(final BuildContext context) => Scaffold(
    body: SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 12),
                child: Text(
                  'WORLD INSPECTOR',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                key: const Key('world_inspector.fullscreen.close'),
                tooltip: 'Back to the doc',
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Gap(8),
            ],
          ),
          Expanded(
            child: WorldInspectorPane(
              expandedHeight: double.infinity,
              binding: binding,
              onBindingChanged: onBindingChanged,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProjectViewAppBar extends StatelessWidget {
  const _ProjectViewAppBar();

  @override
  Widget build(final BuildContext context) => BackTextUniversalAppBar(
    onBack: () => context.go(ScreenPaths.home),
    titleStr: '',
    useBackButton: true,
  );
}

class _ChangelogViewAppBar extends StatelessWidget {
  const _ChangelogViewAppBar();

  @override
  Widget build(final BuildContext context) => BackTextUniversalAppBar(
    onBack: () => context.go(ScreenPaths.home),
    titleStr: context.l10n.changeLog,
    useBackButton: true,
  );
}
