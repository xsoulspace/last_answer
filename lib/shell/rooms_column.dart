/// The docked ROOMS COLUMN (owner law 2026-11-10, the chat-first
/// projection): the shell's second projection of the ONE layout
/// document — navigation chrome like VSCode's sidebar. LAW: the column
/// is never a tab and never a surface; a row click rides the shell's
/// tab-select path, and the layout document stays the single
/// authority (shell.views.v4). The macOS traffic lights are NOT this
/// column's business (the lights gutter law v2): the rail is always
/// the window's leftmost chrome and always owns the gutter.
///
/// Anatomy: three sections — DMs (the roster's non-human actors),
/// channels (the registry's named threads, user-settable icon mark)
/// and rooms (the watchable threads, forum mark). The selected row
/// mirrors the service's active thread through [conversationSurfaceId];
/// per-row unread badges ride LaWorld reactively ([EcsWorldSelector]
/// over the cursor fold — no LaWorld, no badges: honest absence, never
/// a poll).
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `shell.roomsColumn`, `rooms.section.dms|channels|rooms`,
/// `rooms.row.dm.<actorId>`, `rooms.row.channel.<channelId>`,
/// `rooms.row.room.<threadId>`, `rooms.unread.<surfaceId>`,
/// `rooms.create.channel`, `rooms.cta.dm`, the context-menu rows
/// `rooms.menu.rename|close|setIcon|miniwindow.*` and the change-icon
/// dialog's `rooms.icon.<glyph>|clear|custom|confirm`.
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

/// The curated channel glyph vocabulary (the change-icon dialog's
/// grid): a registry icon string naming one of these renders the
/// matching Material outlined icon; [kChannelHashIcon] keeps the text
/// '#' mark; any other non-empty string renders AS TEXT (the emoji
/// path). The map lives here, beside the marks it feeds — the strip
/// pill's leading (app_shell) renders through the same [ChannelIconMark].
/// Stroke-family exception note: `favorite_outline`/`star_outline` are
/// the legacy-named OUTLINED twins (no `*_outlined` constant exists for
/// them) — same stroke family, older name.
const Map<String, IconData> kChannelIconGlyphs = <String, IconData>{
  'beaker': Icons.science_outlined,
  'book': Icons.menu_book_outlined,
  'bug': Icons.bug_report_outlined,
  'bulb': Icons.lightbulb_outlined,
  'chip': Icons.memory_outlined,
  'flask': Icons.biotech_outlined,
  'globe': Icons.public_outlined,
  'heart': Icons.favorite_outline,
  'star': Icons.star_outline,
  'terminal': Icons.terminal_outlined,
  'wrench': Icons.build_outlined,
};

/// The curated name of the default mark: the '#' text (the retired
/// _ChannelMark's grammar), never an icon font glyph.
const String kChannelHashIcon = 'hash';

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
    this.onSetIcon,
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

  /// The change-icon dialog's apply lane: writes the channel's icon
  /// (null clears it back to the '#' mark) through the shell's registry
  /// route and answers the honest success/refusal fact. Null keeps the
  /// menu row honestly absent — the column never writes on its own.
  final Future<bool> Function(String channelId, String? icon)? onSetIcon;

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
      // A ListView, not a SingleChildScrollView: the SCV's semantics
      // subtree never assembles in a live desktop app (the measured
      // rail-drop framework gap); ListView-backed lists keep their
      // nodes, and the column is the agent's room index.
      child: ListView(
        padding: const EdgeInsets.only(bottom: 8),
        children: [
          _SectionHead(
            sectionKey: 'rooms.section.dms',
            label: l10n.roomsSectionDms,
            tooltip: l10n.roomsExplainDms,
          ),
          if (actors.isEmpty)
            _RoomsRow(
              rowKey: 'rooms.cta.dm',
              title: l10n.worldChatMenuMessageActor,
              // The 18px leading box: every row mark (avatar, '#',
              // glyph, forum) rides ONE vertical axis (Wave K optical
              // alignment).
              leading: SizedBox(
                width: 18,
                height: 18,
                child: Center(
                  child: Icon(
                    Icons.person_search_outlined,
                    size: 15,
                    color: context.shellMuted,
                  ),
                ),
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
            tooltip: l10n.roomsExplainChannels,
            trailing: _HeaderAction(
              actionKey: 'rooms.create.channel',
              tooltip: l10n.worldChatMenuNewChannel,
              icon: Icons.add_outlined,
              onTap: onCreateChannel,
            ),
          ),
          for (final channel in service.channels)
            _ConversationRow(
              rowKey: 'rooms.row.channel.${channel.channelId}',
              surfaceId: 'channel:${channel.channelId}',
              title: '#${channel.name}',
              // The kind word rides the mark's tooltip; the mark
              // itself is the channel's user-settable icon.
              leading: Tooltip(
                message: l10n.roomsKindChannel,
                waitDuration: const Duration(milliseconds: 600),
                child: ChannelIconMark(icon: channel.icon),
              ),
              threadId: channel.threadId,
              selected:
                  activeSurfaceId == 'channel:${channel.channelId}',
              laWorld: laWorld,
              service: service,
              channel: channel,
              onSelect: onSelect,
              onMiniWindow: onMiniWindow,
              onSetIcon: onSetIcon,
            ),
          _SectionHead(
            sectionKey: 'rooms.section.rooms',
            label: l10n.roomsSectionRooms,
            tooltip: l10n.roomsExplainRooms,
          ),
          for (final thread in service.roomThreads)
            _ConversationRow(
              rowKey: 'rooms.row.room.${thread['threadId']}',
              surfaceId: 'room:${thread['threadId']}',
              title: '${thread['topic'] ?? thread['threadId']}',
              leading: Tooltip(
                message: l10n.roomsKindRoom,
                waitDuration: const Duration(milliseconds: 600),
                child: const _RoomMark(),
              ),
              threadId: '${thread['threadId']}',
              selected: activeSurfaceId == 'room:${thread['threadId']}',
              laWorld: laWorld,
              service: service,
              onSelect: onSelect,
              onMiniWindow: onMiniWindow,
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
    this.onSetIcon,
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

  /// The change-icon apply lane (channels only); null keeps the menu
  /// row honestly absent.
  final Future<bool> Function(String channelId, String? icon)? onSetIcon;

  final LaWorld? laWorld;

  /// Non-null for channel rows: they carry the rename/close/setIcon
  /// verbs.
  final ChannelInfo? channel;

  /// The row's right-click / long-press (the strip tab's menu pattern):
  /// channels offer Rename, Change icon, Close and the miniwindow;
  /// every other row offers the window presentation only.
  void _onContext(final BuildContext context, final Offset globalPosition) {
    final l10n = context.l10n;
    final channel = this.channel;
    final onSetIcon = this.onSetIcon;
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
          if (channel != null && onSetIcon != null)
            PopupMenuItem<String>(
              value: 'setIcon',
              key: ValueKey('rooms.menu.setIcon.${channel.channelId}'),
              child: Text(l10n.roomsSetIconAction),
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
        case 'setIcon':
          if (channel != null && onSetIcon != null && context.mounted) {
            await _changeChannelIcon(context, channel, onSetIcon);
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

  /// The change-icon dialog: the curated glyph grid, the clear button
  /// and the single-character/emoji field, applying through the
  /// shell-provided [onSetIcon] lane (honest refusal keeps it open —
  /// the rename dialog's law).
  Future<void> _changeChannelIcon(
    final BuildContext context,
    final ChannelInfo channel,
    final Future<bool> Function(String channelId, String? icon) onSetIcon,
  ) => showDialog<void>(
    context: context,
    builder: (final dialogContext) => _SetIconDialog(
      channel: channel,
      onSetIcon: onSetIcon,
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
          final navigator = Navigator.of(context);
          final renamed = await widget.service.renameChannel(
            widget.channel.channelId,
            trimmed,
          );
          if (!mounted || !renamed) return;
          navigator.pop();
        },
        child: Text(context.l10n.roomsRenameAction),
      ),
    ],
  );
}

/// The change-icon dialog (the _RenameDialog law: its own State owns
/// the TextEditingController — the route's exit animation still
/// rebuilds the field after `showDialog` returns). A curated glyph tap
/// selects it; the clear button selects the default '#' mark; the
/// field takes ONE character/emoji verbatim (the emoji path). Confirm
/// applies through the shell's [RoomsColumn.onSetIcon] lane and a
/// refusal keeps the dialog open — the icon stays intact.
final class _SetIconDialog extends StatefulWidget {
  const _SetIconDialog({required this.channel, required this.onSetIcon});

  final ChannelInfo channel;
  final Future<bool> Function(String channelId, String? icon) onSetIcon;

  @override
  State<_SetIconDialog> createState() => _SetIconDialogState();
}

final class _SetIconDialogState extends State<_SetIconDialog> {
  /// The pending choice: a curated name, a raw character/emoji, or
  /// null (the default '#' mark).
  String? _selected;

  /// The hovered glyph (the shadcn hover fill, tracked here so the
  /// grid stays a plain Wrap of Stateless buttons).
  String? _hovered;

  late final TextEditingController _custom = TextEditingController(
    text: _isCustom(widget.channel.icon) ? widget.channel.icon : '',
  );

  @override
  void initState() {
    super.initState();
    _selected = widget.channel.icon;
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  /// A non-empty icon that is neither the hash mark nor a curated
  /// glyph name is a raw character/emoji (the field's value).
  static bool _isCustom(final String? icon) {
    final value = icon?.trim() ?? '';
    return value.isNotEmpty &&
        value != kChannelHashIcon &&
        !kChannelIconGlyphs.containsKey(value);
  }

  void _select(final String? next) => setState(() {
    _selected = next;
    if (next != _custom.text.trim()) _custom.clear();
  });

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.roomsSetIconTitle),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final name in <String>[
                  kChannelHashIcon,
                  ...kChannelIconGlyphs.keys,
                ])
                  _glyphButton(context, name),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              key: const ValueKey('rooms.icon.custom'),
              controller: _custom,
              maxLength: 8,
              decoration: InputDecoration(
                labelText: l10n.roomsIconCustomLabel,
                counterText: '',
              ),
              onChanged: (final value) => setState(
                () => _selected = value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const ValueKey('rooms.icon.clear'),
          onPressed: () => _select(null),
          child: Text(l10n.roomsIconClear),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.worldChatCancel),
        ),
        FilledButton(
          key: const ValueKey('rooms.icon.confirm'),
          onPressed: () async {
            final trimmed = _selected?.trim();
            final navigator = Navigator.of(context);
            final applied = await widget.onSetIcon(
              widget.channel.channelId,
              trimmed == null || trimmed.isEmpty ? null : trimmed,
            );
            if (!mounted || !applied) return;
            navigator.pop();
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  /// ONE glyph cell (34px tile on the shell's radius, hover fill +
  /// selected fill — shadcn discipline, no new colors): the hash mark
  /// renders its '#' text, every other name its curated icon.
  Widget _glyphButton(final BuildContext context, final String name) {
    final selected = _selected == name;
    final hovered = _hovered == name;
    final fill = selected
        ? context.shellSelected
        : hovered
        ? context.shellHover
        : null;
    return Semantics(
      button: true,
      selected: selected,
      label: 'rooms.icon.$name',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (final _) => setState(() => _hovered = name),
        onExit: (final _) => setState(() => _hovered = null),
        child: GestureDetector(
          key: ValueKey('rooms.icon.$name'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _select(name),
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(ShellTokens.radius),
            ),
            child: Center(
              child: name == kChannelHashIcon
                  ? Text(
                      '#',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: selected ? context.la.ink : context.shellMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  : Icon(
                      kChannelIconGlyphs[name],
                      size: 17,
                      color: selected ? context.la.ink : context.shellMuted,
                    ),
            ),
          ),
        ),
      ),
    );
  }
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
                      // DESIGN type scale: Compact 12 (the off-scale
                      // 12.5 was chrome drift).
                      fontSize: 12,
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
                  const SizedBox(width: 4),
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
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
/// its kind explanation on the hover tooltip, with an optional
/// trailing action (the channels' `+`).
final class _SectionHead extends StatelessWidget {
  const _SectionHead({
    required this.sectionKey,
    required this.label,
    required this.tooltip,
    this.trailing,
  });

  final String sectionKey;
  final String label;

  /// The kind explanation (roomsExplain*): what this section's rooms
  /// ARE, one hover away.
  final String tooltip;
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) => Semantics(
    key: ValueKey(sectionKey),
    label: sectionKey,
    child: Tooltip(
      message: tooltip,
      waitDuration: const Duration(milliseconds: 600),
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

/// The channel's identity mark (the strip pill's twin — app_shell's
/// tab leading renders through THIS widget): a curated glyph name
/// renders its Material outlined icon, [kChannelHashIcon]/null/empty
/// keeps today's '#' text mark, and any other non-empty string renders
/// AS TEXT (the emoji path). [size] is the glyph edge: 15 in the rooms
/// rows (the retired _ChannelMark's 18px box, 11px '#'), 14 in the
/// strip pills.
final class ChannelIconMark extends StatelessWidget {
  const ChannelIconMark({required this.icon, this.size = 15, super.key});

  /// The registry's icon string (null = the default '#' mark).
  final String? icon;

  /// The mark's glyph edge (px).
  final double size;

  @override
  Widget build(final BuildContext context) {
    final value = icon?.trim() ?? '';
    if (value.isEmpty || value == kChannelHashIcon) {
      // Today's '#' mark, verbatim (the retired _ChannelMark's box).
      return SizedBox(
        width: size + 3,
        height: size + 3,
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
    final glyph = kChannelIconGlyphs[value];
    if (glyph != null) {
      // The same 18px leading box as the '#' mark: curated glyphs and
      // the hash ride ONE vertical axis in the rows and the strip pills.
      return SizedBox(
        width: size + 3,
        height: size + 3,
        child: Center(
          child: Icon(glyph, size: size, color: context.shellMuted),
        ),
      );
    }
    // The emoji path: the raw string IS the mark.
    return SizedBox(
      width: size + 3,
      height: size + 3,
      child: Center(
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: size - 2,
            color: context.shellMuted,
          ),
        ),
      ),
    );
  }
}

/// The watchable room's forum mark (the strip pill's twin) — riding the
/// same 18px leading box as every other row mark (one vertical axis).
final class _RoomMark extends StatelessWidget {
  const _RoomMark();

  @override
  Widget build(final BuildContext context) => SizedBox(
    width: 18,
    height: 18,
    child: Center(
      child: Icon(
        Icons.forum_outlined,
        size: 15,
        color: context.shellMuted,
      ),
    ),
  );
}
