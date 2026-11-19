import 'package:headless_core/headless_core.dart' as hc;
import 'package:lastanswer/ui_documents/agent_doc_surface.dart';
import 'package:lastanswer/ui_chat/ui_chat.dart';
import 'package:lastanswer/ui_inspector/ui_inspector.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/ui_documents/changelog_view.dart';
import 'package:lastanswer/ui_documents/code_view.dart';
import 'package:lastanswer/ui_documents/doc_view.dart';
import 'package:lastanswer/ui_documents/legacy_project_migration.dart';
import 'package:xsoulspace_foundation/xsoulspace_foundation.dart';

/// The single doc→surface map (ADR 0010): every document variant renders
/// through this host, served from `ui_documents` since the 2026-11-19
/// folder-grammar restructure. Legacy note/idea rows no longer render their
/// retired editors — opening one converts it ON DEMAND into a doc
/// ([LegacyProjectMigration], idempotent, non-destructive per ADR 0002).
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
      return const Center(child: LaSpinner(size: 24));
    }

    final selected = project == null || projectContainer.value.id == project!.id
        ? projectContainer.value
        : project!;
    final id = selected.id;
    return selected.map(
      idea: (final idea) => _LegacyMigrationHost(
        legacy: idea,
        embedded: embedded,
        key: ValueKey(id),
      ),
      note: (final note) => _LegacyMigrationHost(
        legacy: note,
        embedded: embedded,
        key: ValueKey(id),
      ),
      changelog: (final changelog) => _frame(
        context,
        const _ChangelogViewAppBar(),
        const ChangelogView(),
      ),
      doc: (final doc) =>
          _frame(context, const _ProjectViewAppBar(), _docSurface(context, doc)),
    );
  }

  /// ADR 0023 — two surfaces: `chat` docs are the world conversation
  /// (durable realm threads + bots); `agent` docs stay the harness
  /// coding lane. ADR 0010 D2 metadata no longer mints a distinct
  /// surface, and the observability panes moved to Settings
  /// (world inspector, mesh tasks).
  Widget _docSurface(final BuildContext context, final ProjectModelDoc doc) =>
      switch (doc.formatId) {
        DocFormatIds.chat => WorldChatSurface(key: ValueKey(doc.id)),
        // 2a — the code format: one monospace artifact surface on
        // the open registry (zero migration, the doc spine carries
        // the content block).
        DocFormatIds.code => CodeDocumentView(doc: doc, key: ValueKey(doc.id)),
        DocFormatIds.agent => doc.agent?.worldBinding != null
            ? WorldConversationView(
                binding: doc.agent!.worldBinding!,
                key: ValueKey(
                  '${doc.id}_${doc.agent!.worldBinding!.worldId}',
                ),
              )
            : AgentDocSurface(
                doc: doc,
                key: ValueKey(doc.id),
                // Persist workspace, check and backend through the
                // same composition point as the document listing.
                // Without this wiring the binding is lost on app
                // restart.
                onDocChanged: (final updated) =>
                    context.read<OpenedProjectNotifier>().updateProject(updated),
              ),
        _ => _WorkbenchDocumentHost(doc: doc, key: ValueKey(doc.id)),
      };

  Widget _frame(
    final BuildContext context,
    final Widget appBar,
    final Widget child,
  ) => embedded
      ? child
      : _AdaptiveView(appBar: appBar, child: child);
}

/// The ADR 0002 explicit migration made visible: converting a legacy
/// note/idea shows an honest spinner, then the resulting doc surface. The
/// original row is never mutated (see [LegacyProjectMigration]).
class _LegacyMigrationHost extends StatelessWidget {
  const _LegacyMigrationHost({
    required this.legacy,
    required this.embedded,
    super.key,
  });
  final ProjectModel legacy;
  final bool embedded;

  @override
  Widget build(final BuildContext context) {
    final future = LegacyProjectMigration.migrateToDoc(
      legacy,
      repository: context.read<ProjectsRepository>(),
      localizeQuestion: (final title) => title.localize(context),
    );
    return FutureBuilder<ProjectModelDoc>(
      future: future,
      builder: (final context, final snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: LaSpinner(size: 24));
        }
        final doc = snapshot.data;
        if (doc == null) {
          return Center(
            child: Text(
              switch (Localizations.localeOf(context).languageCode) {
                'it' => 'Impossibile convertire questo elemento.',
                'ru' => 'Не удалось преобразовать этот элемент.',
                _ => 'This item could not be converted.',
              },
              key: const Key('project_view.migration_failed'),
            ),
          );
        }
        return ProjectView(project: doc, embedded: embedded);
      },
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

class _ProjectViewAppBar extends StatelessWidget {
  const _ProjectViewAppBar();

  @override
  Widget build(final BuildContext context) => LaTopBar(
    leading: LaButton.icon(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () => context.go(ScreenPaths.home),
    ),
  );
}

class _ChangelogViewAppBar extends StatelessWidget {
  const _ChangelogViewAppBar();

  @override
  Widget build(final BuildContext context) => LaTopBar(
    leading: LaButton.icon(
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
      onPressed: () => context.go(ScreenPaths.home),
    ),
    titleText: context.l10n.changeLog,
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
        child: LaButton(
          key: const ValueKey('open-workbench'),
          variant: LaButtonVariant.ghost,
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
