/// The docked ROOMS COLUMN (owner law 2026-11-10, the chat-first
/// projection): the shell's second projection of the ONE layout
/// document — navigation chrome like VSCode's sidebar. LAW: the column
/// is never a tab and never a surface; a row click rides the shell's
/// ordinary tab-select path, and the layout document stays the single
/// authority (shell.views.v4).
///
/// Anatomy: three sections — DMs (the roster's non-human actors),
/// channels (the registry's named threads, `#` mark) and rooms (the
/// watchable threads, forum mark). The selected row mirrors the
/// service's active thread through [conversationSurfaceId]; per-row
/// unread badges ride LaWorld reactively ([EcsWorldSelector] over the
/// cursor fold — no LaWorld, no badges: honest absence, never a poll).
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `shell.roomsColumn`, `rooms.section.dms|channels|rooms`,
/// `rooms.row.dm.<actorId>`, `rooms.row.channel.<channelId>`,
/// `rooms.row.room.<threadId>`, `rooms.unread.<surfaceId>`,
/// `rooms.create.channel`, `rooms.cta.dm`, and the context-menu rows
/// `rooms.menu.rename|close|miniwindow.*`.
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';

import 'package:lastanswer/coding_agent/realm_chat/channel_registry.dart';

import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';

import 'package:lastanswer/common_imports.dart';

import 'package:lastanswer/la_world/la_world.dart';

import 'package:lastanswer/shell/shell_theme.dart';

import 'package:lastanswer/shell/surfaces.dart';

import 'package:lastanswer/shell/window_drag.dart';

/// The docked rooms column: sections of conversation rows over the
/// service's live projections. The SHELL owns the dock state and the
/// tab routing; this column only renders facts and forwards intents.
final class RoomsColumn extends StatelessWidget {
  const RoomsColumn({
    required this.service,
    required this.onSelect,
    required this.onCreateChannel,
    required this.onMessageActor,
    required this.onMiniWindow,
    this.lightsGutter = false,
    super.key,
  });

  /// The realm chat service (roster, channels, room threads, active
  /// thread). The shell rebuilds this column on every service notify.
  final RealmChatService service;

  /// A row tap: the shell's ordinary tab-select path.
  final ValueChanged<String> onSelect;

  /// The channels section's `+`: the shell's existing create flow.
  final VoidCallback onCreateChannel;

  /// The empty-DMs CTA: the shell's existing message-actor flow.
  final VoidCallback onMessageActor;

  /// The context menu's miniwindow row: the shell's window presentation
  /// (ADR 0027) — the column never owns windows.
  final ValueChanged<String> onMiniWindow;

  /// The title-bar-is-gone law (DESIGN.md v2): when the column is the
  /// window's leftmost chrome on macOS, its head carries the traffic
  /// lights — an inert, draggable gutter, never interactive chrome.
  final bool lightsGutter;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    // The selection fact: the service's active thread folded into its
    // surface id (the same vocabulary the strips and the tabs speak);
    // null (no thread open) selects no row — honest absence.
    final activeSurfaceId = conversationSurfaceId(
      activeThreadId: service.activeThreadId,
      channels: service.channels,
      actors: service.roster?.all ?? const <ActorProfile>[],
      dmThreadOf: service.dmThreadOf,
    );
    // No LaWorld yet = no badges anywhere (honest absence, the action
    // bar's null-guard pattern).
    LaWorld? laWorld;
    try {
      laWorld = context.read<LaWorld?>();
    } on ProviderNotFoundException {
      laWorld = null;
    }
    final actors = <ActorProfile>[
      for (final actor in service.roster?.all ?? const <ActorProfile>[])
        if (actor.kind != ActorKind.human) actor,
    ];
    return Container(
      key: const ValueKey('shell.roomsColumn'),
      width: ShellTokens.contextColumnWidth,
      decoration: BoxDecoration(
        color: context.la.surface,
        border: Border(right: BorderSide(color: context.shellHairline)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (lightsGutter)
            // The traffic lights' zone (Safari anatomy): inert,
            // draggable, never interactive chrome.
            const WindowDragRegion(
              child: SizedBox(
                height: ShellTokens.stripHeight,
                width: double.infinity,
              ),
            ),
          Expanded(
            // A ListView, not a SingleChildScrollView: the SCV's
            // semantics subtree never assembles in a live desktop app
            // (the measured rail-drop framework gap); ListView-backed
            // lists keep their nodes, and the column is the agent's
            // room index.
            child: ListView(
              padding: const EdgeInsets.only(bottom: 8),
              children: [
                _SectionHead(
                  sectionKey: 'rooms.section.dms',
                  label: l10n.roomsSectionDms,
                ),
                if (actors.isEmpty)
                  _RoomsRow(
                    rowKey: 'rooms.cta.dm',
                    title: l10n.worldChatMenuMessageActor,
                    leading: const Icon(
                      Icons.person_search_outlined,
                      size: 15,
                    ),
                    onTap: onMessageActor,
                  )
                else
                  for (final actor in actors)
                    _ConversationRow(
                      rowKey: 'rooms.row.dm.${actor.actorId}',
                      surfaceId: 'dm:${actor.actorId}',
                      title: actor.displayName,
                      leading: ActorAvatar(profile: actor, size: 18),
                      threadId: service.dmThreadOf(actor.actorId),
                      selected: activeSurfaceId == 'dm:${actor.actorId}',
                      laWorld: laWorld,
                      service: service,
                      onSelect: onSelect,
                      onMiniWindow: onMiniWindow,
                    ),
                _SectionHead(
                  sectionKey: 'rooms.section.channels',
                  label: l10n.railChannels,
                  trailing: _HeaderAction(
                    actionKey: 'rooms.create.channel',
                    tooltip: l10n.worldChatMenuNewChannel,
                    icon: Icons.add,
                    onTap: onCreateChannel,
                  ),
                ),
                for (final channel in service.channels)
                  _ConversationRow(
                    rowKey: 'rooms.row.channel.${channel.channelId}',
                    surfaceId: 'channel:${channel.channelId}',
                    title: '#${channel.name}',
                    leading: const _ChannelMark(),
                    threadId: channel.threadId,
                    selected:
                        activeSurfaceId == 'channel:${channel.channelId}',
                    laWorld: laWorld,
                    service: service,
                    channel: channel,
                    onSelect: onSelect,
                    onMiniWindow: onMiniWindow,
                  ),
                _SectionHead(
                  sectionKey: 'rooms.section.rooms',
                  label: l10n.roomsSectionRooms,
                ),
                for (final thread in service.roomThreads)
                  _ConversationRow(
                    rowKey: 'rooms.row.room.${thread['threadId']}',
                    surfaceId: 'room:${thread['threadId']}',
                    title: '${thread['topic'] ?? thread['threadId']}',
                    leading: const _RoomMark(),
                    threadId: '${thread['threadId']}',
                    selected: activeSurfaceId == 'room:${thread['threadId']}',
                    laWorld: laWorld,
                    service: service,
                    onSelect: onSelect,
                    onMiniWindow: onMiniWindow,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One conversation row: identity mark, title, the reactive unread
/// badge, the selected fill from the service's active thread. A tap is
/// the shell's tab-select path; a right-click (or long-press) asks for
/// the row's context menu.
final class _ConversationRow extends StatelessWidget {
  const _ConversationRow({
    required this.rowKey,
    required this.surfaceId,
    required this.title,
    required this.leading,
    required this.threadId,
    required this.selected,
    required this.service,
    required this.onSelect,
    required this.onMiniWindow,
    this.laWorld,
    this.channel,
  });

  final String rowKey;
  final String surfaceId;
  final String title;
  final Widget leading;

  /// The row's thread (a DM without one yet stays badge-less — the
  /// badge is a thread's fact, never an invention).
  final String? threadId;

  final bool selected;
  final RealmChatService service;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onMiniWindow;
  final LaWorld? laWorld;

  /// Non-null for channel rows: they carry the rename/close verbs.
  final ChannelInfo? channel;

  /// The row's right-click / long-press (the strip tab's menu pattern):
  /// channels offer Rename, Close and the miniwindow; every other row
  /// offers the window presentation only.
  void _onContext(final BuildContext context, final Offset globalPosition) {
    final l10n = context.l10n;
    final channel = this.channel;
    unawaited(() async {
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
          if (channel != null)
            PopupMenuItem<String>(
              value: 'rename',
              key: ValueKey('rooms.menu.rename.${channel.channelId}'),
              child: Text(l10n.roomsRenameAction),
            ),
          if (channel != null)
            PopupMenuItem<String>(
              value: 'close',
              key: ValueKey('rooms.menu.close.${channel.channelId}'),
              child: Text(l10n.roomsCloseChannel),
            ),
          PopupMenuItem<String>(
            value: 'miniwindow',
            key: ValueKey('rooms.menu.miniwindow.$surfaceId'),
            child: Text(l10n.railRowMiniwindow),
          ),
        ],
      );
      if (choice == null) return;
      switch (choice) {
        case 'rename':
          if (channel != null && context.mounted) {
            await _renameChannel(context, channel);
          }
        case 'close':
          if (channel != null) {
            unawaited(service.closeChannel(channel.channelId));
          }
        case 'miniwindow':
          onMiniWindow(surfaceId);
      }
    }());
  }

  /// The rename dialog: one field, the service's verb, honest refusal
  /// (a refused rename keeps the dialog open — the name stays intact).
  Future<void> _renameChannel(
    final BuildContext context,
    final ChannelInfo channel,
  ) => showDialog<void>(
    context: context,
    builder: (final dialogContext) => _RenameDialog(
      service: service,
      channel: channel,
    ),
  );

  @override
  Widget build(final BuildContext context) => _RoomsRow(
    rowKey: rowKey,
    title: title,
    leading: leading,
    selected: selected,
    onTap: () => onSelect(surfaceId),
    onContext: (final position) => _onContext(context, position),
    trailing: _RowUnreadBadge(
      badgeKey: 'rooms.unread.$surfaceId',
      laWorld: laWorld,
      threadId: threadId,
    ),
  );
}

/// The rename dialog's own State owns its TextEditingController (init
/// and dispose with the State): the route's EXIT animation still
/// rebuilds the field after `showDialog` returns, so a controller
/// disposed at that point would be used after dispose.
final class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.service, required this.channel});

  final RealmChatService service;
  final ChannelInfo channel;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

final class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _name = TextEditingController(
    text: widget.channel.name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) => AlertDialog(
    title: Text(context.l10n.roomsRenameChannelTitle),
    content: SizedBox(
      width: 360,
      child: TextField(
        key: const ValueKey('rooms.rename.name'),
        controller: _name,
        autofocus: true,
        decoration: InputDecoration(
          prefixText: '#',
          labelText: context.l10n.worldChatChannelNameLabel,
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.worldChatCancel),
      ),
      FilledButton(
        key: const ValueKey('rooms.rename.confirm'),
        onPressed: () async {
          final trimmed = _name.text.trim();
          if (trimmed.isEmpty) return;
          final renamed = await widget.service.renameChannel(
            widget.channel.channelId,
            trimmed,
          );
          if (!mounted || !renamed) return;
          Navigator.of(context).pop();
        },
        child: Text(context.l10n.roomsRenameAction),
      ),
    ],
  );
}

/// The one row shape: hover + selected fill on the shell's tile
/// grammar, the §2.3 contract (the Semantics name IS the widget key).
final class _RoomsRow extends StatefulWidget {
  const _RoomsRow({
    required this.rowKey,
    required this.title,
    this.leading,
    this.trailing,
    this.selected = false,
    this.onTap,
    this.onContext,
  });

  final String rowKey;
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;
  final ValueChanged<Offset>? onContext;

  @override
  State<_RoomsRow> createState() => _RoomsRowState();
}

final class _RoomsRowState extends State<_RoomsRow> {
  var _hovering = false;

  @override
  Widget build(final BuildContext context) {
    final fill = widget.selected
        ? context.shellSelected
        : _hovering
        ? context.shellHover
        : null;
    return Semantics(
      button: true,
      selected: widget.selected,
      // The agent contract: the Semantics name IS the widget key; the
      // human title rides the hint.
      label: widget.rowKey,
      hint: widget.title,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (final _) => setState(() => _hovering = true),
        onExit: (final _) => setState(() => _hovering = false),
        child: GestureDetector(
          key: ValueKey(widget.rowKey),
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          onSecondaryTapUp: (final details) =>
              widget.onContext?.call(details.globalPosition),
          onLongPressStart: (final details) =>
              widget.onContext?.call(details.globalPosition),
          child: Container(
            height: ShellTokens.rowHeight,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(ShellTokens.radius),
            ),
            child: Row(
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontSize: 12.5,
                      color: widget.selected
                          ? context.la.ink
                          : context.shellMuted,
                      fontWeight: widget.selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
                if (widget.trailing != null) ...[
                  const SizedBox(width: 6),
                  widget.trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One row's unread badge: an [EcsWorldSelector] over the journal
/// projection keyed by the row's thread (the member gate lives in
/// [LaWorld.unreadByThread]). No LaWorld, no thread or a read room
/// renders nothing — honest absence, never a zero pill.
final class _RowUnreadBadge extends StatelessWidget {
  const _RowUnreadBadge({
    required this.badgeKey,
    required this.laWorld,
    required this.threadId,
  });

  final String badgeKey;
  final LaWorld? laWorld;
  final String? threadId;

  @override
  Widget build(final BuildContext context) {
    final laWorld = this.laWorld;
    final threadId = this.threadId;
    if (laWorld == null || threadId == null) return const SizedBox.shrink();
    return EcsWorldSelector<int>(
      world: laWorld.world,
      controller: laWorld.controller,
      select: (final world) => laWorld.unreadByThread()[threadId] ?? 0,
      builder: (final context, final unread) {
        if (unread <= 0) return const SizedBox.shrink();
        final label = unread > 99 ? '99+' : '$unread';
        return Semantics(
          key: ValueKey(badgeKey),
          label: badgeKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: context.la.accent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: context.la.onAccent,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A section head: the micro-label (DESIGN §3) on the section's key,
/// with an optional trailing action (the channels' `+`).
final class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.sectionKey,
    required this.label,
    this.trailing,
  });

  final String sectionKey;
  final String label;
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) => Semantics(
    key: ValueKey(sectionKey),
    label: sectionKey,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: shellSectionLabel(context)),
          ),
          ?trailing,
        ],
      ),
    ),
  );
}

/// A section head's quiet glyph button (the channels' `+`): the
/// creation flow lives in the shell — the column only hands it over.
final class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.actionKey,
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String actionKey;
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: actionKey,
    hint: tooltip,
    child: Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          key: ValueKey(actionKey),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: 22,
            height: 22,
            child: Icon(icon, size: 15, color: context.shellMuted),
          ),
        ),
      ),
    ),
  );
}

/// The channel row's `#` mark (the strip pill's twin).
final class _ChannelMark extends StatelessWidget {
  const _ChannelMark();

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 18,
    height: 18,
    child: Center(
      child: Text(
        '#',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: context.shellMuted,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

/// The watchable room's forum mark (the strip pill's twin).
final class _RoomMark extends StatelessWidget {
  const _RoomMark();

  @override
  Widget build(final BuildContext context) => Icon(
    Icons.forum_outlined,
    size: 15,
    color: context.shellMuted,
  );
}
