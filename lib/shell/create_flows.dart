/// The shell's creation flows — lifted verbatim from the retired actor
/// rail's `+` menu when the rail became a Discord-style action bar
/// (DESIGN.md v2): the new-tab picker owns discovery AND creation, so
/// these dialogs live beside the picker, keys unchanged
/// (`rail.channel.*`, `rail.workspace.*`, `rail.pick.actor.<id>`).
library;

import 'package:file_selector/file_selector.dart' show getDirectoryPath;

import 'package:lastanswer/coding_agent/acp_bridge/acp_actor_bridge.dart';

import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_registry.dart';

import 'package:lastanswer/coding_agent/acp_bridge/acp_bridge_transport.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_picker.dart';

import 'package:lastanswer/coding_agent/realm_chat/channel_members_ui.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/doc/acp_agent_runtime.dart';

import 'package:lastanswer/workspaces/workspace.dart';

import 'package:lastanswer/workspaces/workspace_notifier.dart';

/// The searchable actor picker → openDm (reuse-or-create the DM).
/// Minting identities lives in Settings → Agents & Models.
Future<void> openMessageActorFlow(
  final BuildContext context, {
  required final RealmChatService service,
  required final VoidCallback onOpenSettings,
}) async {
  final actors = <ActorProfile>[
    for (final actor in service.roster?.all ?? const <ActorProfile>[])
      if (actor.kind != ActorKind.human) actor,
  ];
  await showLaDialog<void>(
    context: context,
    builder: (final dialogContext) => LaDialog(
      titleText: dialogContext.l10n.worldChatPickActorTitle,
      content: SizedBox(
        width: 360,
        height: 420,
        child: ActorPicker(
          actors: actors,
          onPick: (final actor) {
            Navigator.of(dialogContext).pop();
            unawaited(service.openDm(actor.actorId));
          },
          onCreateActor: () {
            Navigator.of(dialogContext).pop();
            onOpenSettings();
          },
        ),
      ),
      actions: [
        LaButton(
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(dialogContext).pop(),
          label: dialogContext.l10n.worldChatCancel,
        ),
      ],
    ),
  );
}

/// The channel dialog: a name (empty and duplicates refused inline)
/// plus member checkboxes → createChannel.
Future<void> openNewChannelFlow(
  final BuildContext context, {
  required final RealmChatService service,
}) async {
  final actors = <ActorProfile>[
    for (final actor in service.roster?.all ?? const <ActorProfile>[])
      if (actor.kind != ActorKind.human) actor,
  ];
  final name = TextEditingController();
  final picked = <String>{};
  var nameTaken = false;
  await showLaDialog<void>(
    context: context,
    builder: (final dialogContext) => StatefulBuilder(
      builder: (final dialogContext, final setDialogState) => LaDialog(
        titleText: dialogContext.l10n.worldChatNewChannelTitle,
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The field law is borderless (no floating label): the
              // label rides a quiet Text above, the hint IS the
              // placeholder — both frozen l10n strings preserved.
              Text(
                dialogContext.l10n.worldChatChannelNameLabel,
                style: dialogContext.laUi.compact,
              ),
              const SizedBox(height: 4),
              LaField(
                key: const ValueKey('rail.channel.name'),
                controller: name,
                autofocus: true,
                onChanged: (final _) {
                  if (nameTaken) setDialogState(() => nameTaken = false);
                },
                prefix: Text(
                  '#',
                  style: dialogContext.laUi.body.copyWith(
                    color: dialogContext.laUi.inkMuted,
                  ),
                ),
                placeholder: dialogContext.l10n.worldChatChannelNameHint,
                errorText: nameTaken
                    ? dialogContext.l10n.worldChatChannelNameTaken
                    : null,
              ),
              const SizedBox(height: 12),
              Flexible(
                // The shared member picker (the members lane): the same
                // searchable checkbox list the members popover and the
                // rooms-column menu use; the frozen `rail.pick.actor.<id>`
                // row keys ride the default prefix.
                child: ChannelMemberPicker(
                  searchKey: const ValueKey('rail.channel.search'),
                  candidates: actors,
                  selected: picked,
                  onToggle: (final actorId) => setDialogState(() {
                    if (picked.contains(actorId)) {
                      picked.remove(actorId);
                    } else {
                      picked.add(actorId);
                    }
                  }),
                ),
              ),
            ],
          ),
        ),
        actions: [
          LaButton(
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
            label: dialogContext.l10n.worldChatCancel,
          ),
          LaButton(
            key: const ValueKey('rail.channel.create'),
            variant: LaButtonVariant.primary,
            onPressed: name.text.trim().isEmpty
                ? null
                : () async {
                    final channel = await service.createChannel(
                      name.text,
                      memberIds: picked.toList(),
                    );
                    if (!dialogContext.mounted) return;
                    if (channel != null) {
                      Navigator.of(dialogContext).pop();
                    } else {
                      setDialogState(() => nameTaken = true);
                    }
                  },
            label: dialogContext.l10n.worldChatChannelCreate,
          ),
        ],
      ),
    ),
  );
}

/// The workspace dialog (ADR 0026): a name plus optional folder picks —
/// name-only is valid, folders attach later too. Creation is refused
/// inline when the store refuses the record. A shell without a
/// workspace notifier (hermetic tests) opens nothing — honest absence.
Future<void> openNewWorkspaceFlow(final BuildContext context) async {
  final notifier = context.read<WorkspaceNotifier?>();
  if (notifier == null) return;
  final name = TextEditingController();
  final folders = <String>[];
  await showLaDialog<void>(
    context: context,
    builder: (final dialogContext) => StatefulBuilder(
      builder: (final dialogContext, final setDialogState) => LaDialog(
        titleText: dialogContext.l10n.worldChatNewWorkspaceTitle,
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The borderless field law: the label rides a quiet Text
              // above, the hint IS the placeholder (both l10n frozen).
              Text(
                dialogContext.l10n.worldChatWorkspaceNameLabel,
                style: dialogContext.laUi.compact,
              ),
              const SizedBox(height: 4),
              LaField(
                key: const ValueKey('rail.workspace.name'),
                controller: name,
                autofocus: true,
                onChanged: (_) => setDialogState(() {}),
                placeholder: dialogContext.l10n.worldChatWorkspaceNameHint,
              ),
              const SizedBox(height: 8),
              for (final folder in folders)
                LaRow(
                  key: ValueKey('rail.workspace.folder.$folder'),
                  margin: EdgeInsets.zero,
                  padding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_outlined, size: 18),
                  title: Text(
                    folder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: dialogContext.laUi.control,
                  ),
                  trailing: LaButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    size: LaButtonSize.sm,
                    onPressed: () =>
                        setDialogState(() => folders.remove(folder)),
                  ),
                ),
              LaRow(
                key: const ValueKey('rail.workspace.pick-folder'),
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                leading: const Icon(Icons.create_new_folder_outlined, size: 20),
                titleText: dialogContext.l10n.worldChatWorkspaceAddFolder,
                onTap: () async {
                  final path = await _pickDirectory();
                  if (path != null && !folders.contains(path)) {
                    setDialogState(() => folders.add(path));
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          LaButton(
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
            label: dialogContext.l10n.worldChatCancel,
          ),
          LaButton(
            key: const ValueKey('rail.workspace.create'),
            variant: LaButtonVariant.primary,
            onPressed: name.text.trim().isEmpty
                ? null
                : () async {
                    try {
                      await notifier.create(
                        name: name.text,
                        folderPaths: List.of(folders),
                      );
                    } on Object {
                      // A real store failure keeps the dialog open —
                      // the user's name and folders stay intact.
                      return;
                    }
                    if (dialogContext.mounted) {
                      Navigator.of(dialogContext).pop();
                    }
                  },
            label: dialogContext.l10n.worldChatWorkspaceCreate,
          ),
        ],
      ),
    ),
  );
}

/// One user-selected folder; null when the picker is unavailable (no
/// plugin in this platform/binding) or the user cancelled — name-only
/// creation still works either way.
Future<String?> _pickDirectory() async {
  try {
    return await getDirectoryPath();
  } on Object {
    return null;
  }
}

/// Item 2e — the ACP external-actor bridge flow (desktop only): detect
/// the installed ACP agents (discovery WITHOUT execution), list the
/// DETECTED ones (never fake an agent), and on pick mint the bridged
/// actor + open its DM + bind the bridge loop.
///
/// Honest absence by law: a non-desktop platform opens nothing (the
/// picker row already names the gate), and a detection that found no
/// agent renders the named empty state — never a crash, never a fake.
Future<void> openAcpBridgeFlow(
  final BuildContext context, {
  required final RealmChatService service,
  final AcpInstallationService? installationService,
}) async {
  if (!PlatformInfo.isNativeDesktop) return; // the gate names itself upstream
  // The ACP session's cwd: the first workspace folder this device knows,
  // else the process cwd (a fact, named in the row subtitle below).
  var workingDirectory = Directory.current.path;
  final workspaces =
      context.read<WorkspaceNotifier?>()?.workspaces ?? const <Workspace>[];
  for (final workspace in workspaces) {
    if (workspace.folderPaths.isNotEmpty) {
      workingDirectory = workspace.folderPaths.first;
      break;
    }
  }
  final installations = await AcpBridgeRegistry.detectAgents(
    installationService: installationService,
  );
  if (!context.mounted) return;
  await showLaDialog<void>(
    context: context,
    builder: (final dialogContext) => LaDialog(
      // Unlocalized mono house vocabulary (v1 — l10n keys listed in the
      // change report; the dialog never fakes a translation).
      titleText: 'acp · bridge an agent',
      content: SizedBox(
        width: 360,
        height: 420,
        child: installations.isEmpty
            ? const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('no ACP agent detected on PATH'),
                ),
              )
            : ListView(
                children: [
                  for (final installation in installations)
                    LaRow(
                      key: ValueKey('acp.pick.${installation.entry.id}'),
                      margin: EdgeInsets.zero,
                      titleText: installation.entry.displayName,
                      metaText: installation.path,
                      onTap: () {
                        Navigator.of(dialogContext).pop();
                        unawaited(
                          startAcpBridge(
                            service: service,
                            installation: installation,
                            workingDirectory: workingDirectory,
                          ),
                        );
                      },
                    ),
                ],
              ),
      ),
      actions: [
        LaButton(
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(dialogContext).pop(),
          label: dialogContext.l10n.worldChatCancel,
        ),
      ],
    ),
  );
}

/// Mints the bridged actor (kind agent, brainRef `acp:<id>` — neither a
/// daemon cast nor an in-app brain, so the bridge is the actor's ONLY
/// voice), opens the DM, binds + starts the bridge and registers it.
/// Null = a named absence (the service never came ready, or no room
/// could be opened) — never a crash, never a half-bound bridge.
Future<AcpActorBridge?> startAcpBridge({
  required final RealmChatService service,
  required final AcpAgentInstallation installation,
  required final String workingDirectory,
}) async {
  await service.ensureReady();
  final profile = await service.createActor(
    displayName: '${installation.entry.displayName} (bridged)',
    kind: ActorKind.agent,
    brainRef: 'acp:${installation.entry.id}',
    role: 'acp bridge',
  );
  if (profile == null) return null; // service not ready: nothing minted
  await service.openDm(profile.actorId);
  final threadId = service.dmThreadOf(profile.actorId);
  if (threadId == null) return null; // no room, no bridge
  final bridge = AcpActorBridge(
    actorId: profile.actorId,
    agentId: installation.entry.id,
    threadId: threadId,
    workingDirectory: workingDirectory,
    transport: AcpRuntimeBridgeTransport(
      config: AcpRuntimeConfig.fromInstallation(installation),
    ),
  );
  AcpBridgeRegistry.register(bridge);
  bridge.start(service);
  return bridge;
}
