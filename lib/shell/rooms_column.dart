/// The docked ROOMS COLUMN (owner law 2026-11-10, the chat-first
/// projection): the shell's second projection of the ONE layout
/// document — navigation chrome like VSCode's sidebar. LAW: the column
/// is never a tab and never a surface; a row click rides the shell's
/// tab-select path, and the layout document stays the single
/// authority (shell.views.v4). The macOS traffic lights are NOT this
/// column's business (the lights gutter law v2): the rail is always
/// the window's leftmost chrome and always owns the gutter.
///
/// Anatomy: two sections — DMs (the roster's non-human actors) and
/// channels (the registry's named threads, user-settable icon mark).
/// The watchable rooms left the column (owner law 2026-11-16): they
/// surface INSIDE the channel view's threads browser (the Discord-
/// threads model) and their `room:<threadId>` tabs still open through
/// the shell's ONE router. The selected row mirrors the service's
/// active thread through [conversationSurfaceId]; per-row unread badges
/// ride LaWorld reactively ([EcsWorldSelector] over the cursor fold —
/// no LaWorld, no badges: honest absence, never a poll).
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `shell.roomsColumn`, `rooms.section.dms|channels`,
/// `rooms.row.dm.<actorId>`, `rooms.row.channel.<channelId>`,
/// `rooms.unread.<surfaceId>`,
/// `rooms.create.channel`, `rooms.cta.dm`, the context-menu rows
/// `rooms.menu.rename|close|setIcon|miniwindow.*` and the change-icon
/// dialog's `rooms.icon.<glyph>|clear|custom|confirm`.
library;

import 'package:ecsly_flutter/ecsly_flutter.dart';

import 'package:lastanswer/coding_agent/actor_roster.dart';

import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';

import 'package:lastanswer/coding_agent/realm_chat/conversation_spaces.dart';

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
              leading: LaTooltip(
                message: l10n.roomsKindChannel,
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
  /// every other row offers the window presentation only. The kit menu
  /// grammar (v6): rows carry their own activation, the menu closes on
  /// choice, and the frozen `rooms.menu.*` keys ride the items.
  void _onContext(final BuildContext context, final Offset globalPosition) {
    final l10n = context.l10n;
    final channel = this.channel;
    final onSetIcon = this.onSetIcon;
    LaMenuItem item(
      final String keyValue,
      final String label,
      final VoidCallback onPressed,
    ) => LaMenuItem(
      key: ValueKey(keyValue),
      label: label,
      onPressed: onPressed,
    );
    showLaMenuAt(
      context,
      globalPosition: globalPosition,
      entries: [
        if (channel != null)
          item(
            'rooms.menu.rename.${channel.channelId}',
            l10n.roomsRenameAction,
            () {
              if (context.mounted) {
                unawaited(_renameChannel(context, channel));
              }
            },
          ),
        if (channel != null && onSetIcon != null)
          item(
            'rooms.menu.setIcon.${channel.channelId}',
            l10n.roomsSetIconAction,
            () {
              if (context.mounted) {
                unawaited(_changeChannelIcon(context, channel, onSetIcon));
              }
            },
          ),
        if (channel != null)
          item(
            'rooms.menu.close.${channel.channelId}',
            l10n.roomsCloseChannel,
            () => unawaited(service.closeChannel(channel.channelId)),
          ),
        item(
          'rooms.menu.miniwindow.$surfaceId',
          l10n.railRowMiniwindow,
          () => onMiniWindow(surfaceId),
        ),
      ],
    );
  }

  /// The rename dialog: one field, the service's verb, honest refusal
  /// (a refused rename keeps the dialog open — the name stays intact).
  Future<void> _renameChannel(
    final BuildContext context,
    final ChannelInfo channel,
  ) => showLaDialog<void>(
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
  ) => showLaDialog<void>(
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
/// rebuilds the field after `showLaDialog` returns, so a controller
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
  Widget build(final BuildContext context) => LaDialog(
    titleText: context.l10n.roomsRenameChannelTitle,
    content: SizedBox(
      width: 360,
      child: LaField(
        key: const ValueKey('rooms.rename.name'),
        controller: _name,
        autofocus: true,
        placeholder: context.l10n.worldChatChannelNameLabel,
        prefix: Text(
          '#',
          style: context.laUi.body.copyWith(color: context.laUi.inkMuted),
        ),
      ),
    ),
    actions: [
      LaButton(
        variant: LaButtonVariant.ghost,
        onPressed: () => Navigator.of(context).pop(),
        label: context.l10n.worldChatCancel,
      ),
      LaButton(
        key: const ValueKey('rooms.rename.confirm'),
        variant: LaButtonVariant.primary,
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
        label: context.l10n.roomsRenameAction,
      ),
    ],
  );
}

/// The change-icon dialog (the _RenameDialog law: its own State owns
/// the TextEditingController — the route's exit animation still
/// rebuilds the field after `showLaDialog` returns). A curated glyph tap
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
    return LaDialog(
      titleText: l10n.roomsSetIconTitle,
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
            LaField(
              key: const ValueKey('rooms.icon.custom'),
              controller: _custom,
              maxLength: 8,
              placeholder: l10n.roomsIconCustomLabel,
              counterText: '',
              onChanged: (final value) => setState(
                () => _selected = value.trim().isEmpty ? null : value.trim(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        LaButton(
          key: const ValueKey('rooms.icon.clear'),
          variant: LaButtonVariant.ghost,
          onPressed: () => _select(null),
          label: l10n.roomsIconClear,
        ),
        LaButton(
          variant: LaButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
          label: l10n.worldChatCancel,
        ),
        LaButton(
          key: const ValueKey('rooms.icon.confirm'),
          variant: LaButtonVariant.primary,
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
          label: l10n.save,
        ),
      ],
    );
  }

  /// ONE glyph cell (34px tile on the shell's radius, hover fill +
  /// selected fill — the kit's ONE state layer, no new colors): the
  /// hash mark renders its '#' text, every other name its curated icon.
  Widget _glyphButton(final BuildContext context, final String name) {
    final selected = _selected == name;
    return Semantics(
      button: true,
      selected: selected,
      label: 'rooms.icon.$name',
      child: LaPressable(
        key: ValueKey('rooms.icon.$name'),
        onTap: () => _select(name),
        selected: selected,
        radius: BorderRadius.circular(ShellTokens.radius),
        scaleOnPress: false,
        // The outer Semantics carries the frozen contract.
        semanticsButton: false,
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: name == kChannelHashIcon
                ? Text(
                    '#',
                    style: context.laUi.micro.copyWith(
                      color: selected ? context.laUi.ink : context.shellMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : Icon(
                    kChannelIconGlyphs[name],
                    size: 17,
                    color: selected ? context.laUi.ink : context.shellMuted,
                  ),
          ),
        ),
      ),
    );
  }
}

/// The one row shape: hover + selected fill through the kit's ONE
/// state layer ([LaPressable], v6) on the shell's tile grammar, the
/// §2.3 contract (the Semantics name IS the widget key).
final class _RoomsRow extends StatelessWidget {
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
  Widget build(final BuildContext context) => Semantics(
    button: true,
    selected: selected,
    // The agent contract: the Semantics name IS the widget key; the
    // human title rides the hint.
    label: rowKey,
    hint: title,
    // The context-menu gestures ride OUTSIDE the pressable: they need
    // the event's globalPosition, which LaPressable's position-less
    // callbacks do not carry (kit gap). The pressable never registers
    // them, so the arena has exactly one claimant each.
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onSecondaryTapUp: (final details) =>
          onContext?.call(details.globalPosition),
      onLongPressStart: (final details) =>
          onContext?.call(details.globalPosition),
      child: LaPressable(
        key: ValueKey(rowKey),
        onTap: onTap,
        selected: selected,
        radius: BorderRadius.circular(ShellTokens.radius),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        scaleOnPress: false,
        // The outer Semantics carries the §2.3 contract — frozen.
        semanticsButton: false,
        child: SizedBox(
          height: ShellTokens.rowHeight,
          child: Row(
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.compact.copyWith(
                    // DESIGN type scale: Compact 12 (the off-scale
                    // 12.5 was chrome drift).
                    color: selected ? context.laUi.ink : context.shellMuted,
                    fontWeight: selected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ),
      ),
    ),
  );
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
              style: context.laUi.micro.copyWith(
                color: context.laUi.onAccent,
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
    child: LaTooltip(
      message: tooltip,
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
    child: LaTooltip(
      message: tooltip,
      child: LaPressable(
        key: ValueKey(actionKey),
        onTap: onTap,
        radius: BorderRadius.circular(6),
        scaleOnPress: false,
        // The outer Semantics carries the §2.3 contract — frozen.
        semanticsButton: false,
        child: SizedBox(
          width: 22,
          height: 22,
          child: Icon(icon, size: 15, color: context.shellMuted),
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
            style: context.laUi.micro.copyWith(
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
          style: context.laUi.micro.copyWith(
            fontSize: size - 2,
            color: context.shellMuted,
          ),
        ),
      ),
    );
  }
}
