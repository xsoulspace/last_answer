import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/_library/widgets/widgets.dart';
import 'package:lastanswer/coding_agent/agent_doc_surface.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_chat_surface.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_conversation_view.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/doc/code_view.dart';
import 'package:lastanswer/doc/doc_view.dart';
import 'package:lastanswer/idea/idea_view.dart';
import 'package:lastanswer/note/note_view.dart';
import 'package:lastanswer/settings/views/changelog_view.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

class ProjectView extends StatelessWidget {
  const ProjectView({this.project, this.embedded = false, super.key});

  /// An addressed route retains its projection when another page is opened.
  final ProjectModel? project;

  /// Phase 3a — hosted inside a shell view tab (the Documents view):
  /// the route chrome (app bar, back button, top gutter) belongs to the
  /// ROUTE presentation; a tab already carries the strip, so the doc's
  /// surface renders bare. The doc→surface mapping stays single-sourced
  /// here.
  final bool embedded;

  @override
  Widget build(final BuildContext context) {
    final projectContainer = context
        .select<OpenedProjectNotifier, LoadableContainer<ProjectModel>>(
          (final c) => c.value,
        );
    if (project == null && projectContainer.isLoading) {
      return const UiCircularProgress();
    }

    final selected = project == null || projectContainer.value.id == project!.id
        ? projectContainer.value
        : project!;
    final id = selected.id;
    return selected.map(
      idea: (final idea) => IdeaView(idea: idea, key: ValueKey(id)),
      note: (final note) => _frame(
        context,
        const _ProjectViewAppBar(),
        NoteView(note: note, key: ValueKey(id)),
      ),
      changelog: (final changelog) => _frame(
        context,
        const _ChangelogViewAppBar(),
        const ChangelogView(),
      ),
      doc: (final doc) => _frame(
        context,
        const _ProjectViewAppBar(),
        // ADR 0023 — two surfaces: `chat` docs are the world conversation
        // (durable realm threads + bots); `agent` docs stay the harness
        // coding lane. ADR 0010 D2 metadata no longer mints a distinct
        // surface, and the observability panes moved to Settings
        // (world inspector, mesh tasks).
        switch (doc.formatId) {
          DocFormatIds.chat => WorldChatSurface(key: ValueKey(id)),
          // 2a — the code format: one monospace artifact surface on
          // the open registry (zero migration, the doc spine carries
          // the content block).
          DocFormatIds.code => CodeDocumentView(doc: doc, key: ValueKey(id)),
          DocFormatIds.agent => doc.agent?.worldBinding != null
              ? WorldConversationView(
                  binding: doc.agent!.worldBinding!,
                  key: ValueKey(
                    '${id}_${doc.agent!.worldBinding!.worldId}',
                  ),
                )
              : AgentDocSurface(
                  doc: doc,
                  key: ValueKey(id),
                  // Persist workspace, check and backend through the
                  // same composition point as the document listing.
                  // Without this wiring the binding is lost on app
                  // restart.
                  onDocChanged: (final updated) => context
                      .read<OpenedProjectNotifier>()
                      .updateProject(updated),
                ),
          _ => _WorkbenchDocumentHost(doc: doc, key: ValueKey(id)),
        },
      ),
    );
  }

  Widget _frame(
    final BuildContext context,
    final Widget appBar,
    final Widget child,
  ) => embedded
      ? child
      : _AdaptiveView(appBar: appBar, child: child);
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

class _WorkbenchDocumentHost extends StatefulWidget {
  const _WorkbenchDocumentHost({required this.doc, super.key});
  final ProjectModelDoc doc;
  @override
  State<_WorkbenchDocumentHost> createState() => _WorkbenchDocumentHostState();
}

class _WorkbenchDocumentHostState extends State<_WorkbenchDocumentHost> {
  int epoch = 0;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          key: const ValueKey('open-workbench'),
          onPressed: () async {
            final doc = widget.doc;
            final repo = context.read<hc.DocumentRepository>();
            final existing = await repo.get(hc.NodeId(doc.id.value));
            if (existing is hc.DocNotFound) {
              await repo.save(
                hc.DocumentNode(
                  id: hc.NodeId(doc.id.value),
                  createdAt: doc.createdAt,
                  updatedAt: doc.updatedAt,
                  blocks: [
                    for (final block in doc.blocks)
                      hc.Block(
                        id: hc.NodeId(block.id.value),
                        type: hc.BlockType.values.byName(block.type.name),
                        content: block.content,
                        level: block.level,
                      ),
                  ],
                ),
              );
            }
            if (!context.mounted) return;
            await context.push(
              '/home/workbench?project=${Uri.encodeComponent(doc.id.value)}',
            );
            if (mounted) setState(() => epoch++);
          },
          child: const Text('Workbench'),
        ),
      ),
      Expanded(
        child: DocView(doc: widget.doc, refreshEpoch: epoch),
      ),
    ],
  );
}
