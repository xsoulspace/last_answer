/// Phase 3a — the Documents view (docs/design/
/// shell-redesign-rail-views-tabs-2026-11-05.md §2.2.1): the missing
/// HUMAN document navigation. The doc grid (owner's call: "the doc grid
/// belongs to Documents") lists every project the registry pages in —
/// agent docs, chat docs, ideas, notes — and a click opens the document
/// as a TAB of this view (`doc:<id>`), hosted through the SAME
/// doc→surface map the route page uses ([ProjectView], embedded).
/// Creation is reachable by human click: "New agent doc" persists through
/// the registry's own update lane and opens its tab — what
/// `agent_doc_create` does for agents, now for people.
library;

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/home/project_view.dart';
import 'package:lastanswer/shell/shell_scope.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// The human title of one registry project, across the sealed variants
/// (idea title, note text, doc title; the changelog names itself).
String projectTitleOf(final ProjectModel project) => project.map(
  idea: (final idea) => idea.title,
  note: (final note) => note.note,
  changelog: (final _) => 'changelog',
  doc: (final doc) => doc.title,
);

/// The Documents view body: the registry's grid + the creation affordance.
final class DocumentsView extends StatefulWidget {
  const DocumentsView({super.key});

  @override
  State<DocumentsView> createState() => _DocumentsViewState();
}

final class _DocumentsViewState extends State<DocumentsView> {
  ProjectsPagedController? _controller;

  @override
  void initState() {
    super.initState();
    // The Documents view is now the registry page's only consumer: it
    // triggers the first fetch itself. `loadFirstPage` is the verb —
    // the pager's `refresh` only resets state, it does not fetch.
    final controller = _controller = context
        .read<ProjectsNotifier?>()
        ?.projectsPagedController;
    controller?.addItemsCountListener(_onItemsCount);
    controller?.loadFirstPage();
  }

  void _onItemsCount(final int count) {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeItemsCountListener(_onItemsCount);
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final projects = context.watch<ProjectsNotifier?>();
    final items =
        projects?.projectsPagedController.items ?? const <ProjectModel>[];
    return Column(
      key: const ValueKey('shell.documentsView'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          child: Row(
            children: [
              Text(l10n.viewDocumentsTitle, style: shellSectionLabel(context)),
              const Spacer(),
              _NewAgentDocButton(projects: projects),
            ],
          ),
        ),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Text(
                    l10n.documentsEmpty,
                    key: const ValueKey('documents.empty'),
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    for (final item in items)
                      _DocumentRow(
                        key: ValueKey('documents.row.${item.id}'),
                        project: item,
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}

/// One grid row: the type's mark, the title, the quiet timestamp. A click
/// opens the document as a tab of the Documents view.
final class _DocumentRow extends StatelessWidget {
  const _DocumentRow({required this.project, super.key});

  final ProjectModel project;

  IconData get _icon => project.map(
    idea: (final _) => Icons.lightbulb_outline,
    note: (final _) => Icons.note_outlined,
    changelog: (final _) => Icons.history,
    doc: (final doc) => switch (doc.formatId) {
      DocFormatIds.chat => Icons.forum_outlined,
      DocFormatIds.agent => Icons.smart_toy_outlined,
      _ => Icons.description_outlined,
    },
  );

  @override
  Widget build(final BuildContext context) {
    final id = '${project.id}';
    return Semantics(
      button: true,
      label: 'documents.row.$id',
      hint: projectTitleOf(project),
      child: ShellRow(
        height: 38,
        onTap: () {
          final scope = ViewScope.of(context);
          if (scope == null) return;
          scope.onChanged(scope.layout.openTab('doc:$id'));
        },
        child: Row(
          children: [
            Icon(_icon, size: 15, color: context.shellMuted),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                projectTitleOf(project).isEmpty ? id : projectTitleOf(project),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The human-click creation affordance: persist a fresh agent doc
/// through the registry's own update lane, refresh the grid, open its
/// tab (what `agent_doc_create` does for agents).
final class _NewAgentDocButton extends StatelessWidget {
  const _NewAgentDocButton({required this.projects});

  final ProjectsNotifier? projects;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return Semantics(
      button: true,
      label: 'documents.new',
      hint: l10n.documentsNewAgentDoc,
      child: TextButton(
        key: const ValueKey('documents.new'),
        onPressed: projects == null
            ? null
            : () async {
                final doc = ProjectModel.emptyAgent();
                await projects!.updateProject(doc);
                projects!.onReset();
                if (!context.mounted) return;
                final scope = ViewScope.of(context);
                if (scope == null) return;
                scope.onChanged(scope.layout.openTab('doc:${doc.id}'));
              },
        child: Text(l10n.documentsNewAgentDoc),
      ),
    );
  }
}

/// A `doc:<id>` tab's host: the registry's projection of the document
/// through the route page's OWN doc→surface map, embedded (no route
/// chrome). An id the loaded page does not carry renders an honest
/// quiet note — never a guessed document.
final class DocumentsTabHost extends StatelessWidget {
  const DocumentsTabHost({required this.docId, super.key});

  final String docId;

  @override
  Widget build(final BuildContext context) {
    final projects = context.watch<ProjectsNotifier?>();
    final item = projects?.projectsPagedController.items.firstWhereOrNull(
      (final project) => '${project.id}' == docId,
    );
    if (item == null) {
      return Center(
        child: Text(
          context.l10n.documentsMissing,
          key: const ValueKey('documents.missing'),
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
        ),
      );
    }
    return ProjectView(
      project: item,
      embedded: true,
      key: ValueKey('documents.host.$docId'),
    );
  }
}
