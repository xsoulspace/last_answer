/// ADR 0129 — the project scope picker: ONE list of the workspace roots
/// a work order or a project-access request can name.
///
/// The option set is the DEDUPED union of the human's durable project
/// grants ([RealmChatService.listGrants] — the host's ADR 0121 grant
/// set) and the registered workspace folders ([WorkspaceNotifier],
/// ADR 0026), grants first. A folder WITHOUT a grant stays selectable
/// by law (the owner's auto-spawn decision): the spawn then carries the
/// honest `project_not_granted` refusal with the current grants as
/// evidence, and the room offers the one-tap grant — the picker never
/// pretends to be the policy.
///
/// Keys are the agent's UI contract (DESIGN §6): the caller passes its
/// own family — the composer uses `worldchat.scope.*`, the People view
/// uses `shell.people.access.*`.
library;

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/workspaces/workspace.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';

/// One selectable project scope: the root path plus whether the human
/// already holds the durable grant for it (a fact tag, never a gate).
final class ProjectScopeOption {
  const ProjectScopeOption({required this.path, required this.granted});

  final String path;
  final bool granted;

  /// The display name: the root's last path segment (the work thread's
  /// default-name derivation — picker and card agree on one name).
  String get name => projectScopeDisplayName(path);
}

/// The last path segment of a project root (both slash families) — the
/// same mechanical derivation the service's default work-thread name
/// uses; the UI owns presentation, never a second vocabulary.
String projectScopeDisplayName(final String projectRoot) {
  final segments = projectRoot
      .replaceAll(r'\', '/')
      .split('/')
      .where((final segment) => segment.isNotEmpty)
      .toList();
  return segments.isEmpty ? projectRoot : segments.last;
}

/// Loads the deduped option list: the human's durable grants first
/// (sorted — [RealmChatService.listGrants] sorts), then the registered
/// workspace folders in registry order. Never throws: a closed world or
/// a missing notifier (hermetic shells) yields the honest shorter list.
Future<List<ProjectScopeOption>> loadProjectScopeOptions(
  final BuildContext context,
  final RealmChatService service,
) async {
  final workspaces = context.read<WorkspaceNotifier?>();
  final human = service.humanActorId;
  var grants = const <String>[];
  if (human != null) {
    try {
      grants = await service.listGrants(human);
    } on Object {
      grants = const <String>[]; // an unreadable grant set lists folders only
    }
  }
  final folders = <String>[
    for (final workspace in workspaces?.workspaces ?? const <Workspace>[])
      ...workspace.folderPaths,
  ];
  final seen = <String>{};
  return <ProjectScopeOption>[
    for (final path in grants)
      if (seen.add(path)) ProjectScopeOption(path: path, granted: true),
    for (final path in folders)
      if (seen.add(path)) ProjectScopeOption(path: path, granted: false),
  ];
}

/// Opens the scope dialog and answers the picked project root, null on
/// cancel. The list loads INSIDE the dialog (one quiet spinner — the
/// grant read is real IO); option rows carry `<optionKeyPrefix>.<path>`
/// keys and a mono `granted` fact tag (journal vocabulary, never
/// localized — every value is a durable fact).
Future<String?> pickProjectScope(
  final BuildContext context, {
  required final RealmChatService service,
  required final String title,
  required final String optionKeyPrefix,
  required final String listKey,
}) {
  final options = loadProjectScopeOptions(context, service);
  return showDialog<String>(
    context: context,
    builder: (final dialogContext) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 360,
        height: 420,
        child: FutureBuilder<List<ProjectScopeOption>>(
          future: options,
          builder: (final dialogContext, final snapshot) {
            final loaded = snapshot.data;
            if (loaded == null) {
              return const Center(child: UiCircularProgress());
            }
            if (loaded.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    dialogContext.l10n.worldChatScopeEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(dialogContext).textTheme.bodySmall,
                  ),
                ),
              );
            }
            return ListView(
              key: ValueKey(listKey),
              children: <Widget>[
                for (final option in loaded)
                  ListTile(
                    key: ValueKey('$optionKeyPrefix.${option.path}'),
                    dense: true,
                    leading: const Icon(Icons.folder_outlined, size: 18),
                    title: Text(
                      option.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      option.path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaTokens.mono(10, dialogContext.shellMuted),
                    ),
                    trailing: option.granted
                        ? Text(
                            'granted',
                            style: LaTokens.mono(10, dialogContext.shellMuted),
                          )
                        : null,
                    onTap: () => Navigator.of(dialogContext).pop(option.path),
                  ),
              ],
            );
          },
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text(dialogContext.l10n.worldChatCancel),
        ),
      ],
    ),
  );
}
