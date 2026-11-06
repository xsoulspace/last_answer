/// ADR 0024 — the actor rail: the shell's left pane is THE conversation
/// list (Discord model). Sections: ACTORS (every roster identity is one
/// row and its DM — opening/selecting it, Telegram-like), CHANNELS
/// (named group spaces), WORKSPACES (ADR 0026 — multi-root workspaces
/// with nesting-as-graph; the projects list retired: notes/ideas/docs
/// are file types inside workspaces now). The bottom row carries the
/// human's identity and the settings gear. The conversations surface
/// never duplicates this list.
///
/// Identity markers are derived, never authored (ADR 0024 §2): avatars
/// are the deterministic identicons of [ActorAvatar], channel discs are
/// [actorColor] over the channel id, presence folds
/// `RealmBotHost.statuses` — the rail owns no second identity system.
/// Row previews are the service's last-beat projections; a row's
/// selected fill follows the service's open thread (`activeThreadId`).
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `rail.search`, `rail.add`, `rail.actor.<id>`, `rail.channel.<id>`,
/// `rail.workspace.<id>` (+ `.toggle.<id>`, `.empty-tree`),
/// `rail.settings`. (The pre-fold DM rows keyed `rail.dm.<threadId>`
/// retired when DIRECT folded into ACTORS; the `rail.project.<id>`
/// rows retired when PROJECTS folded into WORKSPACES — ADR 0026.)
library;

import 'package:file_selector/file_selector.dart' show getDirectoryPath;

import 'package:flutter/cupertino.dart' show CupertinoIcons;

import 'package:flutter/gestures.dart' show kMiddleMouseButton;

import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_picker.dart';
import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/surfaces.dart';
import 'package:lastanswer/workspaces/workspace.dart';
import 'package:lastanswer/workspaces/workspace_notifier.dart';

/// The rail's width inside the shell.
const double kActorRailWidth = 272;

/// Whether the rail row standing for [rowThreadId] is the shell's open
/// conversation. The one selection rule for ACTORS and CHANNELS rows:
/// a row maps to its thread, the fill follows `activeThreadId`. Exposed
/// for the shell test lane (the service's world is not hermetic in
/// widget tests).
bool railRowIsSelected({
  required final String? rowThreadId,
  required final String? activeThreadId,
}) => rowThreadId != null && rowThreadId == activeThreadId;

/// The left pane of the app shell (ADR 0024 §4): identities first.
/// PHASE 1b — the rail is the activity bar AND the roster: a VIEWS
/// section on top switches the hosted view (Zed/VSCode anatomy), the
/// roster below opens conversations inside the Conversations view.
/// [expanded] false renders the compact icon column (the half-screen
/// desktop case); the width gate lives in the shell.
final class ActorRail extends StatefulWidget {
  const ActorRail({
    required this.service,
    required this.onOpenSettings,
    this.onConversationNewTab,
    this.onMiniWindow,
    this.onOpenView,
    this.views = const <SurfaceSpec>[],
    this.activeView = kConversationsSurfaceId,
    this.expanded = true,
    super.key,
  });

  /// The world conversation service — the rail's only state source.
  final RealmChatService service;

  /// Opens Settings (the create-actor affordance lives there, ADR 0023).
  final VoidCallback onOpenSettings;

  /// ⌘-click / middle-click on a conversation row: the row reports its
  /// surface id (`dm:<actorId>` / `channel:<channelId>`) and the SHELL
  /// gives it its own center tab. The rail never learns about tabs —
  /// it names the conversation, the shell decides what that means
  /// (null: the gesture falls through to plain selection).
  final ValueChanged<String>? onConversationNewTab;

  /// Right-click on a conversation row: the row offers "open in
  /// miniwindow" and reports the same surface id to the shell, which
  /// floats a read-only peek window (ADR 0027). Null: no menu.
  final ValueChanged<String>? onMiniWindow;

  /// A VIEWS row tap: the shell hosts that view. Null: the section is
  /// not interactive (hermetic shells).
  final ValueChanged<String>? onOpenView;

  /// The view registry slice the VIEWS section lists (ordered).
  final List<SurfaceSpec> views;

  /// The hosted view — its VIEWS row carries the selected fill.
  final String activeView;

  /// Expanded (272 px, labels) vs compact (56 px, icons only).
  final bool expanded;

  @override
  State<ActorRail> createState() => _ActorRailState();
}

class _ActorRailState extends State<ActorRail> {
  String _query = '';

  /// The selected workspace — local for this slice (ADR 0026 non-goal:
  /// the file-tree surface, where selection becomes durable state, is a
  /// later wave).
  String? _selectedWorkspaceId;

  @override
  void initState() {
    super.initState();
    widget.service.addListener(_onChanged);
    unawaited(widget.service.ensureReady());
    unawaited(context.read<WorkspaceNotifier>().ensureLoaded());
  }

  @override
  void didUpdateWidget(final ActorRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.service, oldWidget.service)) {
      oldWidget.service.removeListener(_onChanged);
      widget.service.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.service.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  // ---- projections ------------------------------------------------------

  /// The roster's non-human actors — who the human can address. Each
  /// row IS its DM: opening it selects the existing two-member thread
  /// or creates one ([RealmChatService.openDm]).
  List<ActorProfile> get _addressableActors => [
    for (final actor in widget.service.roster?.all ?? const <ActorProfile>[])
      if (actor.kind != ActorKind.human) actor,
  ];

  bool _matches(final String text) =>
      _query.isEmpty || text.toLowerCase().contains(_query.toLowerCase());

  List<ActorProfile> get _filteredActors => [
    for (final actor in _addressableActors)
      if (_matches(actor.displayName) || _matches(actor.role)) actor,
  ];

  List<ChannelInfo> get _filteredChannels => [
    for (final channel in widget.service.channels)
      if (_matches(channel.name)) channel,
  ];

  /// A row's quiet second line: the thread's last beat when the DM has
  /// one, else the actor's authored role (who they are until they
  /// speak).
  String? _actorPreview(final ActorProfile actor) =>
      widget.service.beatPreviews()[widget.service.dmThreadOf(actor.actorId)] ??
      (actor.role.isEmpty ? null : actor.role);

  // ---- workspace projections (ADR 0026) ---------------------------------

  /// parent id → child workspaces, from the notifier's loaded list.
  Map<String, List<Workspace>> _workspaceChildren(
    final List<Workspace> workspaces,
  ) {
    final childrenByParent = <String, List<Workspace>>{};
    for (final workspace in workspaces) {
      for (final parentId in workspace.parentIds) {
        (childrenByParent[parentId] ??= []).add(workspace);
      }
    }
    return childrenByParent;
  }

  /// The ids that pass the search: a workspace matches by name, and a
  /// parent stays visible when any descendant matches (the graph's
  /// reachability is the search's).
  Set<String> _passingWorkspaceIds(
    final List<Workspace> workspaces,
    final Map<String, List<Workspace>> childrenByParent,
  ) {
    final passing = <String>{};
    void visit(final Workspace workspace) {
      var anyChild = false;
      final children = childrenByParent[workspace.id] ?? const <Workspace>[];
      for (final child in children) {
        if (!passing.contains(child.id)) visit(child);
        if (passing.contains(child.id)) anyChild = true;
      }
      if (_matches(workspace.name) || anyChild) passing.add(workspace.id);
    }

    for (final workspace in workspaces) {
      if (workspace.parentIds.isEmpty) visit(workspace);
    }
    // Members of no root (impossible by the registry's cycle law, but
    // stay total): judge them by name alone.
    for (final workspace in workspaces) {
      if (_matches(workspace.name)) passing.add(workspace.id);
    }
    return passing;
  }

  // ---- actions ----------------------------------------------------------

  Future<void> _openNewMenu() async {
    final l10n = context.l10n;
    final box = context.findRenderObject()! as RenderBox;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset(0, box.size.height), ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final action = await showMenu<String>(
      context: context,
      position: position,
      items: [
        PopupMenuItem(
          key: const ValueKey('rail.menu.pick-actor'),
          value: 'actor',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_search_outlined, size: 20),
            title: Text(l10n.worldChatMenuMessageActor),
          ),
        ),
        PopupMenuItem(
          key: const ValueKey('rail.menu.new-channel'),
          value: 'channel',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.tag, size: 20),
            title: Text(l10n.worldChatMenuNewChannel),
          ),
        ),
        PopupMenuItem(
          key: const ValueKey('rail.menu.new-workspace'),
          value: 'workspace',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.create_new_folder_outlined, size: 20),
            title: Text(l10n.worldChatMenuNewWorkspace),
          ),
        ),
        PopupMenuItem(
          key: const ValueKey('rail.menu.create-actor'),
          value: 'create',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_add_alt, size: 20),
            title: Text(l10n.actorsCreateActor),
          ),
        ),
      ],
    );
    if (!mounted || action == null) return;
    switch (action) {
      case 'actor':
        await _pickActor();
      case 'channel':
        await _newChannel();
      case 'workspace':
        await _newWorkspace();
      case 'create':
        widget.onOpenSettings();
    }
  }

  /// The searchable actor picker → openDm (reuse-or-create the DM).
  Future<void> _pickActor() async {
    final actors = _addressableActors;
    await showDialog<void>(
      context: context,
      builder: (final dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.worldChatPickActorTitle),
        content: SizedBox(
          width: 360,
          height: 420,
          child: ActorPicker(
            actors: actors,
            onPick: (final actor) {
              Navigator.of(dialogContext).pop();
              unawaited(widget.service.openDm(actor.actorId));
            },
            // Minting identities lives in Settings → Agents & Models.
            onCreateActor: () {
              Navigator.of(dialogContext).pop();
              widget.onOpenSettings();
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(dialogContext.l10n.worldChatCancel),
          ),
        ],
      ),
    );
  }

  /// The channel dialog: a name (empty and duplicates refused inline)
  /// plus member checkboxes → createChannel.
  Future<void> _newChannel() async {
    final service = widget.service;
    final actors = _addressableActors;
    final name = TextEditingController();
    final picked = <String>{};
    var nameTaken = false;
    await showDialog<void>(
      context: context,
      builder: (final dialogContext) => StatefulBuilder(
        builder: (final dialogContext, final setDialogState) => AlertDialog(
          title: Text(dialogContext.l10n.worldChatNewChannelTitle),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const ValueKey('rail.channel.name'),
                  controller: name,
                  autofocus: true,
                  onChanged: (final _) {
                    if (nameTaken) setDialogState(() => nameTaken = false);
                  },
                  decoration: InputDecoration(
                    prefixText: '#',
                    labelText: dialogContext.l10n.worldChatChannelNameLabel,
                    hintText: dialogContext.l10n.worldChatChannelNameHint,
                    errorText: nameTaken
                        ? dialogContext.l10n.worldChatChannelNameTaken
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final actor in actors)
                        CheckboxListTile(
                          key: ValueKey('rail.pick.actor.${actor.actorId}'),
                          dense: true,
                          title: Text(actor.displayName),
                          subtitle: actor.role.isEmpty
                              ? null
                              : Text(actor.role),
                          value: picked.contains(actor.actorId),
                          onChanged: (final value) => setDialogState(() {
                            if (value ?? false) {
                              picked.add(actor.actorId);
                            } else {
                              picked.remove(actor.actorId);
                            }
                          }),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.l10n.worldChatCancel),
            ),
            FilledButton(
              key: const ValueKey('rail.channel.create'),
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
              child: Text(dialogContext.l10n.worldChatChannelCreate),
            ),
          ],
        ),
      ),
    );
  }

  /// The workspace dialog (ADR 0026): a name plus optional folder
  /// picks — name-only is valid, folders attach later too. Creation is
  /// refused inline when the store refuses the record.
  Future<void> _newWorkspace() async {
    final notifier = context.read<WorkspaceNotifier>();
    final name = TextEditingController();
    final folders = <String>[];
    await showDialog<void>(
      context: context,
      builder: (final dialogContext) => StatefulBuilder(
        builder: (final dialogContext, final setDialogState) => AlertDialog(
          title: Text(dialogContext.l10n.worldChatNewWorkspaceTitle),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const ValueKey('rail.workspace.name'),
                  controller: name,
                  autofocus: true,
                  onChanged: (_) => setDialogState(() {}),
                  decoration: InputDecoration(
                    labelText: dialogContext.l10n.worldChatWorkspaceNameLabel,
                    hintText: dialogContext.l10n.worldChatWorkspaceNameHint,
                  ),
                ),
                const SizedBox(height: 8),
                for (final folder in folders)
                  ListTile(
                    key: ValueKey('rail.workspace.folder.$folder'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.folder_outlined, size: 18),
                    title: Text(
                      folder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 16),
                      onPressed: () =>
                          setDialogState(() => folders.remove(folder)),
                    ),
                  ),
                ListTile(
                  key: const ValueKey('rail.workspace.pick-folder'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.create_new_folder_outlined,
                    size: 20,
                  ),
                  title: Text(dialogContext.l10n.worldChatWorkspaceAddFolder),
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
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.l10n.worldChatCancel),
            ),
            FilledButton(
              key: const ValueKey('rail.workspace.create'),
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
              child: Text(dialogContext.l10n.worldChatWorkspaceCreate),
            ),
          ],
        ),
      ),
    );
  }

  /// One user-selected folder; null when the picker is unavailable
  /// (no plugin in this platform/binding) or the user cancelled —
  /// name-only creation still works either way.
  Future<String?> _pickDirectory() async {
    try {
      return await getDirectoryPath();
    } on Object {
      return null;
    }
  }

  // ---- build ------------------------------------------------------------

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final workspacesNotifier = context.read<WorkspaceNotifier>();
    return ListenableBuilder(
      listenable: Listenable.merge([widget.service, workspacesNotifier]),
      builder: (final context, final _) {
        final actors = _filteredActors;
        final channels = _filteredChannels;
        final workspaces = workspacesNotifier.workspaces;
        final childrenByParent = _workspaceChildren(workspaces);
        final passing = _passingWorkspaceIds(workspaces, childrenByParent);
        final rootWorkspaces = [
          for (final workspace in workspaces)
            if (workspace.parentIds.isEmpty && passing.contains(workspace.id))
              workspace,
        ];
        final filteredChildrenByParent = <String, List<Workspace>>{
          for (final entry in childrenByParent.entries)
            entry.key: [
              for (final child in entry.value)
                if (passing.contains(child.id)) child,
            ],
        };
        final bots = widget.service.bots;
        final activeThreadId = widget.service.activeThreadId;
        final sections = <Widget>[
          if (widget.views.isNotEmpty)
            if (!widget.expanded)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    for (final spec in widget.views)
                      _ViewRow(
                        key: ValueKey('rail.view.${spec.id}'),
                        spec: spec,
                        selected: spec.id == widget.activeView,
                        compact: true,
                        onTap: widget.onOpenView == null
                            ? null
                            : () => widget.onOpenView!(spec.id),
                      ),
                  ],
                ),
              )
            else
              _Section(
                label: l10n.railViews,
                child: Column(
                  children: [
                    for (final spec in widget.views)
                      _ViewRow(
                        key: ValueKey('rail.view.${spec.id}'),
                        spec: spec,
                        selected: spec.id == widget.activeView,
                        onTap: widget.onOpenView == null
                            ? null
                            : () => widget.onOpenView!(spec.id),
                      ),
                  ],
                ),
              ),
          if (actors.isNotEmpty)
            _Section(
              label: widget.expanded ? l10n.railActors : null,
              child: Column(
                children: [
                  for (final actor in actors)
                    _ConversationRow(
                      key: ValueKey('rail.actor.${actor.actorId}'),
                      lead: ActorAvatar(
                        profile: actor,
                        size: ShellTokens.rowAvatar,
                        showPresence: bots != null,
                        presenceOnline:
                            bots?.statuses[actor.actorId] == 'listening',
                      ),
                      title: actor.displayName,
                      preview: widget.expanded ? _actorPreview(actor) : null,
                      compact: !widget.expanded,
                      selected: railRowIsSelected(
                        rowThreadId: widget.service.dmThreadOf(actor.actorId),
                        activeThreadId: activeThreadId,
                      ),
                      onTap: () =>
                          unawaited(widget.service.openDm(actor.actorId)),
                      onNewTab: widget.onConversationNewTab == null
                          ? null
                          : () => widget.onConversationNewTab!(
                              'dm:${actor.actorId}',
                            ),
                      onMiniWindow: widget.onMiniWindow == null
                          ? null
                          : () => widget.onMiniWindow!('dm:${actor.actorId}'),
                    ),
                ],
              ),
            ),
          if (channels.isNotEmpty)
            _Section(
              label: widget.expanded ? l10n.railChannels : null,
              child: Column(
                children: [
                  for (final channel in channels)
                    _ConversationRow(
                      key: ValueKey('rail.channel.${channel.channelId}'),
                      lead: _ChannelDisc(channelId: channel.channelId),
                      title: '#${channel.name}',
                      preview: widget.expanded
                          ? widget.service.beatPreviews()[channel.threadId]
                          : null,
                      compact: !widget.expanded,
                      selected: railRowIsSelected(
                        rowThreadId: channel.threadId,
                        activeThreadId: activeThreadId,
                      ),
                      onTap: () =>
                          widget.service.selectChannel(channel.channelId),
                      onNewTab: widget.onConversationNewTab == null
                          ? null
                          : () => widget.onConversationNewTab!(
                              'channel:${channel.channelId}',
                            ),
                      onMiniWindow: widget.onMiniWindow == null
                          ? null
                          : () => widget.onMiniWindow!(
                              'channel:${channel.channelId}',
                            ),
                    ),
                ],
              ),
            ),
          if (widget.expanded && rootWorkspaces.isNotEmpty)
            _Section(
              label: l10n.railWorkspaces,
              child: Column(
                children: [
                  for (final workspace in rootWorkspaces)
                    _WorkspaceRow(
                      key: ValueKey('rail.workspace.${workspace.id}'),
                      workspace: workspace,
                      depth: 0,
                      ancestors: const <String>{},
                      childrenByParent: filteredChildrenByParent,
                      selectedId: _selectedWorkspaceId,
                      onSelect: (final id) =>
                          setState(() => _selectedWorkspaceId = id),
                    ),
                ],
              ),
            ),
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.expanded)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const ValueKey('rail.search'),
                        onChanged: (final value) =>
                            setState(() => _query = value),
                        style: theme.textTheme.bodySmall,
                        decoration: InputDecoration(
                          hintText: l10n.railSearchHint,
                          hintStyle: theme.textTheme.bodySmall?.copyWith(
                            color: context.shellMuted,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: 16,
                            color: context.shellMuted,
                          ),
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 30,
                          ),
                          isDense: true,
                          // Linear's input: invisible until needed — the
                          // surface IS the field; focus earns the caret,
                          // never an always-on outline box.
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      key: const ValueKey('rail.add'),
                      tooltip: l10n.railAddTooltip,
                      icon: const Icon(Icons.add_comment_outlined, size: 20),
                      onPressed: () => unawaited(_openNewMenu()),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: sections.isEmpty
                  ? Center(
                      child: Text(
                        l10n.railNoMatches,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sections,
                      ),
                    ),
            ),
            Divider(height: 1, color: theme.dividerColor),
            _HumanRow(
              service: widget.service,
              onOpenSettings: widget.onOpenSettings,
              compact: !widget.expanded,
            ),
          ],
        );
      },
    );
  }
}

/// A muted section label above its content (DESIGN: small-caps labels).
class _Section extends StatelessWidget {
  const _Section({this.label, required this.child});

  /// Null in the compact rail: an icon column carries no section word
  /// (a 56px column would wrap the label into noise).
  final String? label;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.labelSmall?.copyWith(
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
          ],
          child,
        ],
      ),
    );
  }
}

/// The one conversation row: a derived identity mark, the object's name
/// and the last-beat preview; the selected fill follows the service's
/// open thread. Two lines when a preview exists, the shell's quiet
/// hover/select otherwise ([ShellRow]).
class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.lead,
    required this.title,
    required this.selected,
    required this.onTap,
    this.preview,
    this.onNewTab,
    this.onMiniWindow,
    this.compact = false,
    super.key,
  });

  /// The 22px identity mark: an [ActorAvatar] or a channel disc.
  final Widget lead;
  final String title;
  final String? preview;
  final bool selected;
  final VoidCallback onTap;

  /// ⌘-click / middle-click opens this conversation in its own center
  /// tab instead of selecting it (browser convention). Null falls
  /// through to plain selection.
  final VoidCallback? onNewTab;

  /// Right-click offers "open in miniwindow" (ADR 0027) and reports
  /// here. Null: no context menu.
  final VoidCallback? onMiniWindow;

  /// The compact rail: the identity mark alone, centered (phase 1b).
  final bool compact;

  Future<void> _showContextMenu(
    final BuildContext context,
    final Offset globalPosition,
  ) async {
    if (onMiniWindow == null) return;
    final overlay =
        Overlay.of(context).context.findRenderObject()! as RenderBox;
    final choice = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        globalPosition.dx,
        globalPosition.dy,
        overlay.size.width - globalPosition.dx,
        overlay.size.height - globalPosition.dy,
      ),
      items: [
        PopupMenuItem<String>(
          value: 'miniwindow',
          child: Text(context.l10n.railRowMiniwindow),
        ),
      ],
    );
    if (choice == 'miniwindow') onMiniWindow!();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Listener(
      // Middle-click never reaches GestureDetector's tap recognizers;
      // the DOWN event carries the button bits (the UP event does not).
      onPointerDown: (final event) {
        if (onNewTab == null) return;
        if (event.buttons == kMiddleMouseButton) onNewTab!();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onSecondaryTapUp: (final details) =>
            _showContextMenu(context, details.globalPosition),
        child: ShellRow(
          selected: selected,
          padding: compact
              ? const EdgeInsets.symmetric(horizontal: 6)
              : ShellTokens.rowPadding,
          // ⌘+click (⌃+click off-mac) rides the normal tap; the modifier
          // decides what the tap MEANS (new tab vs selection) the moment
          // it lands.
          onTap: onNewTab == null
              ? onTap
              : () {
                  final modifiers = HardwareKeyboard.instance;
                  if (modifiers.isMetaPressed || modifiers.isControlPressed) {
                    onNewTab!();
                  } else {
                    onTap();
                  }
                },
          height: compact
              ? 40
              : preview == null
              ? ShellTokens.rowHeight
              : 46,
          child: compact
              ? Center(child: lead)
              : Row(
                  children: [
                    lead,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          if (preview != null)
                            Text(
                              preview!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: context.shellMuted,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// The channel row's `#` disc: the channel id's hue, tinted quiet.
class _ChannelDisc extends StatelessWidget {
  const _ChannelDisc({required this.channelId});

  final String channelId;

  @override
  Widget build(final BuildContext context) {
    final color = actorColor(channelId);
    return Container(
      width: ShellTokens.rowAvatar,
      height: ShellTokens.rowAvatar,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(ShellTokens.radius - 3),
      ),
      child: Text(
        '#',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// A workspace row (ADR 0026): a folder-stack mark, the name and a
/// muted count of its folders; expandable into child workspaces
/// (nesting-as-graph — a child may appear under several parents, so it
/// renders under each). Tap selects; a selected leaf carries the quiet
/// empty-state note where its file tree will land in a later wave.
class _WorkspaceRow extends StatefulWidget {
  const _WorkspaceRow({
    required this.workspace,
    required this.depth,
    required this.ancestors,
    required this.childrenByParent,
    required this.selectedId,
    required this.onSelect,
    super.key,
  });

  final Workspace workspace;

  /// Nesting depth — one indent step (14px) per parent hop.
  final int depth;

  /// The ancestor chain rendering this row, as a cycle guard: a
  /// workspace already shown above renders as a quiet leaf (the
  /// registry refuses cycles; the render stays total regardless).
  final Set<String> ancestors;

  /// parent id → children, pre-filtered by the search.
  final Map<String, List<Workspace>> childrenByParent;

  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  State<_WorkspaceRow> createState() => _WorkspaceRowState();
}

class _WorkspaceRowState extends State<_WorkspaceRow> {
  bool _expanded = false;

  bool get _selected => widget.selectedId == widget.workspace.id;

  List<Workspace> get _children => [
    for (final child
        in widget.childrenByParent[widget.workspace.id] ?? const <Workspace>[])
      if (!widget.ancestors.contains(child.id)) child,
  ];

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final children = _children;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: widget.depth * 14),
          child: ShellRow(
            selected: _selected,
            onTap: () => widget.onSelect(widget.workspace.id),
            child: Row(
              children: [
                if (children.isNotEmpty)
                  GestureDetector(
                    key: ValueKey(
                      'rail.workspace.toggle.${widget.workspace.id}',
                    ),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _expanded = !_expanded),
                    child: Icon(
                      _expanded ? Icons.expand_more : Icons.chevron_right,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  const SizedBox(width: 18),
                Icon(
                  Icons.folder_copy_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.workspace.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                if (widget.workspace.folderPaths.isNotEmpty)
                  Text(
                    '${widget.workspace.folderPaths.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: context.shellMuted,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (_selected)
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 12, bottom: 2),
            child: Text(
              context.l10n.railWorkspaceEmptyTree,
              key: const ValueKey('rail.workspace.empty-tree'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.shellMuted,
              ),
            ),
          ),
        if (_expanded)
          for (final child in children)
            _WorkspaceRow(
              key: ValueKey('rail.workspace.${child.id}'),
              workspace: child,
              depth: widget.depth + 1,
              ancestors: {...widget.ancestors, widget.workspace.id},
              childrenByParent: widget.childrenByParent,
              selectedId: widget.selectedId,
              onSelect: widget.onSelect,
            ),
      ],
    );
  }
}

/// The rail's bottom row: the human's identity and the settings gear.
class _HumanRow extends StatelessWidget {
  const _HumanRow({
    required this.service,
    required this.onOpenSettings,
    this.compact = false,
  });

  final RealmChatService service;
  final VoidCallback onOpenSettings;

  /// The compact rail: avatar + gear, no name (phase 1b).
  final bool compact;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final humanId = service.humanActorId;
    final human = humanId == null ? null : service.roster?.get(humanId);
    return Padding(
      padding: compact
          ? const EdgeInsets.fromLTRB(6, 6, 2, 6)
          : const EdgeInsets.fromLTRB(12, 6, 4, 6),
      child: Row(
        children: [
          if (human != null) ...[
            ActorAvatar(profile: human, size: 28),
            if (!compact) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  human.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ] else
            const Spacer(),
          IconButton(
            key: const ValueKey('rail.settings'),
            tooltip: context.l10n.settings,
            icon: const Icon(CupertinoIcons.gear, size: 20),
            visualDensity: VisualDensity.compact,
            style: compact
                ? IconButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(24, 24),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                : null,
            onPressed: onOpenSettings,
          ),
        ],
      ),
    );
  }
}

/// A VIEWS row (phase 1b): the registry's icon + title, the hosted view
/// on the selected fill. Compact: the icon alone, centered — the rail's
/// activity-bar presentation. Semantics: a named button (phase 2's
/// contract starts here).
class _ViewRow extends StatelessWidget {
  const _ViewRow({
    required this.spec,
    required this.selected,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final SurfaceSpec spec;
  final bool selected;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: spec.title,
    child: ShellRow(
      selected: selected,
      onTap: onTap,
      height: compact ? 40 : ShellTokens.rowHeight,
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 6)
          : ShellTokens.rowPadding,
      child: compact
          ? Center(
              child: Icon(
                spec.icon ?? Icons.crop_square,
                size: 18,
                color: selected
                    ? Theme.of(context).colorScheme.onSurface
                    : context.shellMuted,
              ),
            )
          : Row(
              children: [
                Icon(
                  spec.icon ?? Icons.crop_square,
                  size: 16,
                  color: selected
                      ? Theme.of(context).colorScheme.onSurface
                      : context.shellMuted,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    spec.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
    ),
  );
}
