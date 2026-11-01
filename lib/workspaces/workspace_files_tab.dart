/// The context panel's FILES tab (ADR 0024/0026): the workspace
/// registry's folders, workspace by workspace — the editor principle's
/// file surface in its quietest form. Mounted through the panel's
/// `ShellContextColumn.filesTabContentBuilder` seam; this file is the
/// integrator's side of that seam.
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `workspaces.filesTab`, `workspaces.filesTab.workspace.<id>`,
/// `workspaces.filesTab.folder`.
library;

import 'package:flutter/material.dart';

import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/workspaces/workspace.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';

/// The FILES tab: every workspace's registered folders, quiet rows on
/// the shared grid. Empty states are honest: no provider (tests/hermetic
/// shells) or no workspaces yet (add one from the rail).
final class WorkspaceFilesTab extends StatelessWidget {
  const WorkspaceFilesTab({required this.notifier, super.key});

  final WorkspaceNotifier notifier;

  @override
  Widget build(final BuildContext context) {
    final workspaces = notifier.workspaces;
    if (workspaces.isEmpty) {
      return _FilesNote(text: context.l10n.workspacesFilesEmpty);
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 4),
      children: [
        for (final workspace in workspaces)
          _WorkspaceFolderSection(
            key: ValueKey('workspaces.filesTab.workspace.${workspace.id}'),
            workspace: workspace,
          ),
      ],
    );
  }
}

class _WorkspaceFolderSection extends StatelessWidget {
  const _WorkspaceFolderSection({required this.workspace, super.key});

  final Workspace workspace;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: ShellTokens.sectionPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(workspace.name, style: shellSectionLabel(context)),
          const SizedBox(height: 4),
          if (workspace.folderPaths.isEmpty)
            Text(
              context.l10n.workspacesFilesNoFolders,
              style: theme.textTheme.bodySmall?.copyWith(
                color: context.shellMuted,
              ),
            )
          else
            for (final folder in workspace.folderPaths)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.folder_outlined,
                      size: 14,
                      color: context.shellMuted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        folder,
                        key: const ValueKey('workspaces.filesTab.folder'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFeatures: const [],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

class _FilesNote extends StatelessWidget {
  const _FilesNote({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        key: const ValueKey('workspaces.filesTab'),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.shellMuted,
        ),
      ),
    ),
  );
}
