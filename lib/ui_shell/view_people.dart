/// The ACTORS MANAGER — the People view, re-scoped (owner decision
/// 2026-11-18): a WORLD-scoped surface for managing every actor, not a
/// conversation's people list. The conversation-scoped sections (the
/// thread's participants, the channel's members, the topic) retired
/// with the pre-tabs design — a conversation's people live in the
/// conversation's own surfaces, and an actor's name anywhere opens the
/// `actor:<id>` info tab (Wave F). The manager owns the whole roster:
///
/// - the SEARCH field (the member-picker's filter grammar) over the
///   roster's names and ids — the 2000-actor answer;
/// - the ACTORS section — one row per roster identity (the human
///   rides it too, labelled "you"), each with the folded status mark
///   (`deriveActorPresence`: working / idle / failed) and the quiet
///   narration line, the Message verb on non-human rows, and the New
///   actor verb on the section head (actor equality: minting lives
///   where the people are);
/// - the RETIRED section — shown-muted by default (an invisible
///   retirement is a lie of absence) with the show/hide toggle on the
///   head.
///
/// The same edit verb (`RealmChatService.updateActor`) backs the
/// `actor:<id>` info surface; the [PeopleFocus] seam stays for
/// hermetic hosts (no `onOpenActor` above the view).
///
/// Widget keys are the agent's UI contract (DESIGN §6) — the surviving
/// family is unchanged: `shell.context.people`,
/// `shell.context.person.<id>`, `shell.people.status.<id>`,
/// `shell.people.newActor`, `shell.people.message.<id>`,
/// `shell.people.retired(.<id>)` and `shell.people.retired.mark.<id>`;
/// the manager adds `shell.people.search(.empty)`,
/// `shell.people.retired.toggle` and the status marks
/// `actor.status.<id>` (2026-11-18).
library;

import 'package:lastanswer/ui_models/agent_config/agent_config.dart';
import 'package:lastanswer/journal/actor_roster.dart';
import 'package:lastanswer/chat/actor_avatar.dart';
import 'package:lastanswer/chat/actor_brain.dart';
import 'package:lastanswer/chat/actor_presence.dart';
import 'package:lastanswer/chat/actor_profile_editor.dart';
import 'package:lastanswer/chat/actor_status.dart';
import 'package:lastanswer/chat/brain_health_dot.dart';
import 'package:lastanswer/journal/palette_lanes.dart';
import 'package:lastanswer/journal/realm_bot_host.dart';
import 'package:lastanswer/journal/realm_chat_service.dart';
import 'package:lastanswer/journal/world_state_service.dart';
import 'package:lastanswer/data_agents/config/subscription_provider.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/world/creatures.dart';
import 'package:lastanswer/world/world.dart';
import 'package:lastanswer/ui_shell/project_scope_picker.dart';
import 'package:lastanswer/ui_shell/shell_theme.dart';
import 'package:lastanswer/world/creature_mark.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show ActorScopeGrant;

/// Which actor the people view focuses (session state, not persisted —
/// the same lifetime the panel's focus had). Null = the plain actor
/// list. The shell routes row taps into `actor:<id>` tabs instead;
/// this seam stays for hermetic hosts.
final class PeopleFocus extends ChangeNotifier {
  String? _actorId;

  /// The focused actor id, null = the plain actor list.
  String? get actorId => _actorId;

  /// Focuses [actorId]: the view shows the actor's profile.
  void focus(final String actorId) {
    if (_actorId == actorId) return;
    _actorId = actorId;
    notifyListeners();
  }

  /// Clears the focus (back to the actor list).
  void clear() {
    if (_actorId == null) return;
    _actorId = null;
    notifyListeners();
  }
}

/// The ACTORS MANAGER body: the focused actor's profile (with its
/// inline edit mode — the hermetic seam), or the searchable roster with
/// the folded status marks and the retired section. Reads the service
/// (state); a null focus keeps the rows inert (hermetic shells without
/// a shell above).
final class PeopleView extends StatefulWidget {
  const PeopleView({
    required this.service,
    this.focus,
    this.onOpenActor,
    this.onOpenConversation,
    super.key,
  });

  /// The world conversation service — the view's state source.
  final RealmChatService service;

  /// The view's focus; null renders the plain actor list with inert
  /// rows.
  final PeopleFocus? focus;

  /// Wave F owner law: a row tap opens the actor's INFO surface (the
  /// shell routes `actor:<id>` into a split). Takes precedence over the
  /// in-view [focus] swap; the focus seam stays for hermetic hosts and
  /// other callers.
  final void Function(String actorId)? onOpenActor;

  /// Routes a row's Message verb into the shell's conversation grammar
  /// (`dm:<id>`); null keeps the verb absent (hermetic hosts).
  final void Function(String surfaceId)? onOpenConversation;

  @override
  State<PeopleView> createState() => _PeopleViewState();
}

final class _PeopleViewState extends State<PeopleView> {
  /// The search field's live query — filters names AND ids (the
  /// member-picker's rule).
  var _query = '';

  /// RETIRED VISIBILITY (the owner's call, 2026-11-18): shown-muted by
  /// DEFAULT — an invisible retirement is a lie of absence; hiding is
  /// the opt-in.
  var _showRetired = true;

  @override
  Widget build(final BuildContext context) {
    final focus = widget.focus;
    return ListenableBuilder(
      listenable: focus ?? widget.service,
      builder: (final context, final _) {
        final focusedId = focus?.actorId;
        if (focus != null && focusedId != null) {
          return _ActorPanel(
            service: widget.service,
            peopleFocus: focus,
            actorId: focusedId,
          );
        }
        return ListenableBuilder(
          listenable: widget.service,
          builder: (final context, final _) => _ActorsManagerBody(
            service: widget.service,
            query: _query,
            onQueryChanged: (final value) => setState(() => _query = value),
            showRetired: _showRetired,
            onToggleRetired: () => setState(() => _showRetired = !_showRetired),
            onFocus: focus?.focus,
            onOpenActor: widget.onOpenActor,
            onOpenConversation: widget.onOpenConversation,
          ),
        );
      },
    );
  }
}

/// The manager's list body: the search field, the roster (filtered,
/// status-marked) and the retired section (the toggle on the head).
class _ActorsManagerBody extends StatelessWidget {
  const _ActorsManagerBody({
    required this.service,
    required this.query,
    required this.onQueryChanged,
    required this.showRetired,
    required this.onToggleRetired,
    this.onFocus,
    this.onOpenActor,
    this.onOpenConversation,
  });

  final RealmChatService service;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final bool showRetired;
  final VoidCallback onToggleRetired;

  /// Focuses an actor (its profile rides the view); null keeps rows
  /// inert.
  final void Function(String actorId)? onFocus;

  /// Wave F: opens the actor's info surface; wins over [onFocus].
  final void Function(String actorId)? onOpenActor;

  /// Routes the Message verb / post-mint routing into the shell's
  /// conversation grammar.
  final void Function(String surfaceId)? onOpenConversation;

  /// The search rule: a row matches when the query is empty or names
  /// the actor — display name OR actor id, case-insensitive (the
  /// member-picker's rule verbatim).
  static bool _matches(final String query, final String id, final String name) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return true;
    return name.toLowerCase().contains(needle) ||
        id.toLowerCase().contains(needle);
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final rosterIds = [
      for (final actor in service.roster?.all ?? const <ActorProfile>[])
        actor.actorId,
    ]..sort((final a, final b) {
      final an = _nameOf(a).toLowerCase();
      final bn = _nameOf(b).toLowerCase();
      return an.compareTo(bn) != 0 ? an.compareTo(bn) : a.compareTo(b);
    });
    final liveIds = [
      for (final id in rosterIds)
        if (_matches(query, id, _nameOf(id))) id,
    ];
    // RETIRED VISIBILITY: the retired ids sort by name (the rooms
    // column's rule); the search filters them too, the toggle on the
    // head decides whether they render at all.
    final retiredIds =
        service.retiredRows.keys
            .where(
              (final id) =>
                  _matches(query, id, _retiredNameOf(id)),
            )
            .toList()
          ..sort((final a, final b) {
            final an = _retiredNameOf(a).toLowerCase();
            final bn = _retiredNameOf(b).toLowerCase();
            return an.compareTo(bn) != 0 ? an.compareTo(bn) : a.compareTo(b);
          });
    final searchEmpty = query.trim().isNotEmpty;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            child: LaField(
              key: const ValueKey('shell.people.search'),
              placeholder: l10n.actorsSearchHint,
              onChanged: onQueryChanged,
            ),
          ),
          _Section(
            sectionKey: const ValueKey('shell.context.people'),
            label: l10n.viewActorsTitle,
            // ACTOR EQUALITY (owner law, 2026-11-16): minting lives
            // where the people are — one verb, the shared create verb,
            // then the new actor's own surface opens.
            trailing: LaButton.icon(
              key: const ValueKey('shell.people.newActor'),
              tooltip: l10n.actorsNewActor,
              size: LaButtonSize.sm,
              icon: Icon(Icons.add, size: 13, color: context.shellMuted),
              onPressed: () => unawaited(_newActor(context)),
            ),
            child: liveIds.isEmpty
                ? Text(
                    searchEmpty
                        ? l10n.actorsSearchEmpty
                        : l10n.actorsNoneYet,
                    key: const ValueKey('shell.people.search.empty'),
                    style: context.laUi.compact.copyWith(
                      color: context.shellMuted,
                    ),
                  )
                : _PeopleList(
                    ids: liveIds,
                    service: service,
                    onFocus: onFocus,
                    onOpenActor: onOpenActor,
                    onOpenConversation: onOpenConversation,
                  ),
          ),
          if (retiredIds.isNotEmpty || service.retiredRows.isNotEmpty)
            _Section(
              sectionKey: const ValueKey('shell.people.retired'),
              label:
                  '${l10n.actorsRetiredSection} '
                  '${service.retiredRows.length}',
              trailing: LaButton.icon(
                key: const ValueKey('shell.people.retired.toggle'),
                tooltip: showRetired
                    ? l10n.actorsHideRetired
                    : l10n.actorsShowRetired,
                size: LaButtonSize.sm,
                icon: Icon(
                  showRetired
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 14,
                  color: context.shellMuted,
                ),
                onPressed: onToggleRetired,
              ),
              child: showRetired && retiredIds.isNotEmpty
                  ? _RetiredList(
                      ids: retiredIds,
                      service: service,
                      onOpenActor: onOpenActor ?? onFocus,
                    )
                  : const SizedBox.shrink(),
            ),
        ],
      ),
    );
  }

  /// A live roster identity's display name (the derived fallback when
  /// the profile says nothing).
  String _nameOf(final String id) =>
      service.roster?.get(id)?.displayName ?? actorDisplayFallback(id);

  /// A retired row's display name: the durable record's own
  /// `displayName` when it says one, the derived fallback otherwise.
  String _retiredNameOf(final String id) {
    final name = '${service.retiredInfo(id)?['displayName'] ?? ''}'.trim();
    return name.isNotEmpty ? name : actorDisplayFallback(id);
  }

  /// Mint one model actor through the SHARED create verb: name + role
  /// + a brain from the discovered options (the picker's vocabulary is
  /// the world's, never a hardcoded model list), then the new actor's
  /// own surface opens (actor equality: minted = editable at once).
  Future<void> _newActor(final BuildContext context) async {
    final l10n = context.l10n;
    final options = availableBrainOptions(
      defaultOpenRouterModel: _defaultOpenRouterModel(context),
      paletteRungs:
          context.read<WorldStateService?>()?.generativeDecls ?? const [],
      subscriptionModels: subscriptionModelsOf(context),
    );
    final name = TextEditingController();
    final role = TextEditingController();
    var brain = options.isEmpty ? '' : options.first.ref;
    final created = await showLaDialog<bool>(
      context: context,
      builder: (final dialogContext) => StatefulBuilder(
        builder: (final dialogContext, final setDialogState) => LaDialog(
          key: const ValueKey('shell.people.newActor.dialog'),
          titleText: l10n.actorsNewActor,
          content: SizedBox(
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LaField(
                  key: const ValueKey('shell.people.newActor.name'),
                  controller: name,
                  placeholder: l10n.actorsNameHint,
                ),
                const SizedBox(height: 8),
                LaField(
                  key: const ValueKey('shell.people.newActor.role'),
                  controller: role,
                  placeholder: l10n.actorsRoleHint,
                ),
                const SizedBox(height: 8),
                LaSelect<String>(
                  key: const ValueKey('shell.people.newActor.brain'),
                  value: brain,
                  expand: true,
                  items: [
                    for (final option in options)
                      LaSelectItem(value: option.ref, label: option.label),
                  ],
                  onChanged: (final value) =>
                      setDialogState(() => brain = value ?? brain),
                ),
              ],
            ),
          ),
          actions: [
            LaButton(
              variant: LaButtonVariant.ghost,
              onPressed: () => Navigator.of(dialogContext).pop(false),
              label: l10n.worldChatCancel,
            ),
            LaButton(
              key: const ValueKey('shell.people.newActor.create'),
              variant: LaButtonVariant.primary,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              label: l10n.actorsCreate,
            ),
          ],
        ),
      ),
    );
    if (created != true || name.text.trim().isEmpty || brain.isEmpty) {
      name.dispose();
      role.dispose();
      return;
    }
    final profile = await service.createActor(
      displayName: name.text.trim(),
      kind: ActorKind.model,
      brainRef: brain,
      role: role.text.trim(),
    );
    name.dispose();
    role.dispose();
    if (profile != null) onOpenActor?.call(profile.actorId);
  }

  /// The hosted-model option the brain picker offers (the picker's
  /// hosted option), read from the agent config the same way the actor
  /// surface does.
  String _defaultOpenRouterModel(final BuildContext context) {
    try {
      final config = context.read<AgentConfigStore>().config;
      return config.chat.defaultModel.isNotEmpty
          ? config.chat.defaultModel
          : (config.providers[AgentPlatformConfig.openRouterId]?.defaultModel ??
                '');
    } on Object {
      return '';
    }
  }
}

/// The roster rows: derived avatar + display name per row, the folded
/// status mark, and — Wave 3A — the bot's one-line activity narration
/// underneath (humans and unknown ids stay quiet; a listening bot is
/// silence). A row taps into the actor's profile.
class _PeopleList extends StatelessWidget {
  const _PeopleList({
    required this.ids,
    required this.service,
    this.onFocus,
    this.onOpenActor,
    this.onOpenConversation,
  });

  final List<String> ids;

  /// The world conversation service — roster and bot presence source.
  final RealmChatService service;

  /// Focuses an actor (its profile rides the view); null keeps rows
  /// inert.
  final void Function(String actorId)? onFocus;

  /// Wave F: opens the actor's info surface; wins over [onFocus] (the
  /// shell's owner law: click an actor name → its info in a split).
  final void Function(String actorId)? onOpenActor;

  /// Routes a row's Message verb into the shell's conversation grammar
  /// (`dm:<id>`); null keeps the verb absent (hermetic hosts).
  final void Function(String surfaceId)? onOpenConversation;

  @override
  Widget build(final BuildContext context) {
    final roster = service.roster;
    final bots = service.bots;
    final world = context.read<WorldStateService?>();
    // 3d — the creature layer's UI fold: the narration and daemon
    // facts live in memory (service/world), not in the journal, so the
    // widget that reads them reports them to the projection on its own
    // rebuild. refreshCreatures notifies NOTHING (LaWorld is not this
    // widget's listenable; the rows rebuild on the service's tick) —
    // the selector discipline stays intact.
    final laWorld = context.read<LaWorld?>();
    if (laWorld != null) {
      laWorld.refreshCreatures(
        narrationStates: <String, String>{
          for (final entry in service.botNarration.entries)
            entry.key: entry.value.state.name,
        },
        daemonAsleep: !(world == null) && !world.daemonLive,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final id in ids)
          _personRow(context, id, roster, bots, laWorld, world),
      ],
    );
  }

  /// One roster row: avatar + name, the folded status mark
  /// (`deriveActorPresence` — the manager's triage), and the bot's
  /// one-line activity narration underneath. The whole row taps into
  /// the profile. 3d: a bot's avatar grows EYES — the creature overlay
  /// carries the mood the derive law folded (the avatar keeps its
  /// identicon, kind badge, presence dot and keys untouched — a
  /// creature never becomes the only carrier of type or presence).
  Widget _personRow(
    final BuildContext context,
    final String id,
    final ActorRoster? roster,
    final RealmBotHost? bots,
    final LaWorld? laWorld,
    final WorldStateService? world,
  ) {
    final line = _statusLineOf(context, id);
    final presence = presenceStatusOf(service, id, world: world);
    final profile =
        roster?.get(id) ??
        ActorProfile(actorId: id, displayName: actorDisplayFallback(id));
    final isHuman = profile.kind == ActorKind.human;
    Widget avatar = ActorAvatar(
      profile: profile,
      size: ShellTokens.rowAvatar,
      showPresence: bots != null,
      presenceOnline: bots?.statuses[id] == 'listening',
    );
    // Eyes grow only on a ROSTERED non-human identity: an unknown or
    // legacy id never gets an invented creature (world truth, never
    // decorative fiction).
    final rostered = roster?.get(id);
    if (rostered != null && !isHuman) {
      avatar = Stack(
        children: [
          avatar,
          Positioned.fill(
            child: CreatureMark(
              actorId: id,
              mood: _moodOf(id, laWorld),
              eyesOnly: true,
            ),
          ),
        ],
      );
    }
    // Wave F: the shell's info-surface routing wins; the in-view focus
    // swap stays for hermetic hosts (no onOpenActor above the view).
    final open = onOpenActor ?? onFocus;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LaPressable(
        key: ValueKey('shell.context.person.$id'),
        onTap: open == null ? null : () => open(id),
        radius: BorderRadius.circular(6),
        scaleOnPress: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatar,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    // The human rides the manager labelled "you" (the
                    // Wave N3 actor-equality law, the settings pane's
                    // vocabulary).
                    isHuman
                        ? '${profile.displayName} · ${context.l10n.actorsYou}'
                        : profile.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.laUi.compact,
                  ),
                ),
                // The folded status mark: working / idle / failed —
                // humans and absent facts render nothing.
                if (!isHuman) ...[
                  ActorStatusMark(
                    key: ValueKey('actor.status.$id'),
                    status: presence,
                  ),
                  const SizedBox(width: 6),
                ],
                // ACTOR EQUALITY (owner law, 2026-11-16): the DM verb
                // rides the row — the human writes any model actor in
                // one tap, and the actor answers in the same thread
                // (the dispatch plane is addressedTo-only, both planes).
                if (!isHuman && onOpenConversation != null)
                  LaButton.icon(
                    key: ValueKey('shell.people.message.$id'),
                    tooltip: context.l10n.actorsMessage,
                    icon: const Icon(Icons.chat_bubble_outline, size: 14),
                    size: LaButtonSize.sm,
                    onPressed: () {
                      unawaited(service.openDm(id));
                      onOpenConversation!('dm:$id');
                    },
                  ),
              ],
            ),
            if (line != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: ShellTokens.rowAvatar + 8,
                  top: 1,
                ),
                child: Text(
                  line,
                  key: ValueKey('shell.people.status.$id'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.micro.copyWith(color: context.shellMuted),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The quiet narration line under one row (Wave 3A): only bots with a
  /// narration speak; humans and unknown ids return null. 1b appends
  /// the parallel-work fact: the actor's RUNNING durable tasks, at a
  /// glance (the info surface's Now section owns the detail — the row
  /// owns the "is my cast busy" answer).
  String? _statusLineOf(final BuildContext context, final String id) {
    final profile = service.roster?.get(id);
    if (profile == null || profile.kind == ActorKind.human) return null;
    final narration = service.botNarration[id]?.statusLine;
    final running = runningTasksOf(context.read<WorldStateService?>(), id);
    if (running == 0) return narration;
    final work = running == 1 ? '1 task running' : '$running tasks running';
    return narration == null ? work : '$narration · $work';
  }

  /// The row creature's mood: the projection's derived state when
  /// LaWorld knows the actor; otherwise (hermetic shells, an actor the
  /// fold has not seen) the same pure derive law runs on the narration
  /// fact alone — honest absence, never an invented mood.
  CreatureMood _moodOf(final String id, final LaWorld? laWorld) {
    if (laWorld != null && laWorld.moodCauseOf(id) != 'unknown') {
      return laWorld.moodOf(id);
    }
    return deriveCreatureMood(
      narrationState: service.botNarration[id]?.state.name,
    ).mood;
  }
}

/// The RETIRED actors: one muted row per retired durable row —
/// half-opacity avatar, the display name and the retirement mark — the
/// whole row tapping into the actor's INFO surface (retirement is named
/// verbatim there, Revive included; a retired actor answers no DM, so
/// the row offers no message verb). Visibility rides the section head's
/// toggle; shown-muted is the default.
class _RetiredList extends StatelessWidget {
  const _RetiredList({
    required this.ids,
    required this.service,
    this.onOpenActor,
  });

  final List<String> ids;

  /// The world conversation service — the retired rows' facts source.
  final RealmChatService service;

  /// Opens the actor's info surface; null keeps rows inert (hermetic
  /// hosts).
  final void Function(String actorId)? onOpenActor;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final id in ids)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: LaPressable(
            key: ValueKey('shell.people.retired.$id'),
            onTap: onOpenActor == null ? null : () => onOpenActor!(id),
            radius: BorderRadius.circular(6),
            scaleOnPress: false,
            child: Row(
              children: [
                Opacity(
                  opacity: 0.5,
                  child: ActorAvatar(
                    profile:
                        service.roster?.get(id) ??
                        ActorProfile(
                          actorId: id,
                          displayName: actorDisplayFallback(id),
                        ),
                    size: ShellTokens.rowAvatar,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    service.retiredInfo(id)?['displayName'] as String? ??
                        actorDisplayFallback(id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.laUi.compact.copyWith(
                      color: context.shellMuted,
                    ),
                  ),
                ),
                Text(
                  context.l10n.actorsRetiredMark,
                  key: ValueKey('shell.people.retired.mark.$id'),
                  style: LaTokens.mono(9.5, context.shellMuted),
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

/// The focused actor's profile: identity, brain, sampling, persona —
/// and an EDIT affordance that switches in place to
/// [ActorProfileEditor] (no modal; Save routes through
/// `RealmChatService.updateActor`, which persists the world record and
/// rebuilds the bot loop when the profile materially changed). The
/// hermetic seam — the shell routes actor taps into `actor:<id>` tabs.
class _ActorPanel extends StatefulWidget {
  const _ActorPanel({
    required this.service,
    required this.peopleFocus,
    required this.actorId,
  });

  final RealmChatService service;
  final PeopleFocus peopleFocus;
  final String actorId;

  @override
  State<_ActorPanel> createState() => _ActorPanelState();
}

class _ActorPanelState extends State<_ActorPanel> {
  var _editing = false;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final laUi = context.laUi;
    final service = widget.service;
    final profile = service.roster?.get(widget.actorId);
    final display =
        profile ??
        ActorProfile(
          actorId: widget.actorId,
          displayName: actorDisplayFallback(widget.actorId),
        );
    if (_editing && profile != null) {
      return SingleChildScrollView(
        child: Padding(
          padding: ShellTokens.sectionPadding,
          child: ActorProfileEditor(
            profile: profile,
            brainOptions: availableBrainOptions(
              paletteRungs:
                  context.read<WorldStateService?>()?.generativeDecls ??
                  const [],
              defaultOpenRouterModel: _defaultOpenRouterModel(context),
              subscriptionModels: subscriptionModelsOf(context),
            ),
            tiersForBrain: (final ref) => reasoningTiersForBrainRef(
              ref,
              transportOfRung: (final id) =>
                  context.read<WorldStateService?>()?.transportOfRung(id),
            ),
            saveKey: const ValueKey('shell.context.actor.save'),
            onCancel: () => setState(() => _editing = false),
            initialBrainSet:
                service.brainSets[widget.actorId] ?? const <String>[],
            initialSelfBind:
                (service.selfBinds[widget.actorId] ?? 'allow') != 'deny',
            onSave:
                ({
                  required displayName,
                  required role,
                  required systemPrompt,
                  required brainRef,
                  required avatar,
                  required brainSet,
                  required selfBind,
                }) {
                  unawaited(
                    service
                        .updateActor(
                          actorId: widget.actorId,
                          displayName: displayName,
                          role: role,
                          systemPrompt: systemPrompt,
                          brainRef: brainRef,
                          avatar: avatar,
                          brainSet: brainSet,
                          selfBind: selfBind ? 'allow' : 'deny',
                        )
                        .then((final ok) {
                          if (mounted && ok) setState(() => _editing = false);
                        }),
                  );
                },
          ),
        ),
      );
    }
    final options = availableBrainOptions(
      defaultOpenRouterModel: _defaultOpenRouterModel(context),
      paletteRungs:
          context.read<WorldStateService?>()?.generativeDecls ?? const [],
      subscriptionModels: subscriptionModelsOf(context),
    );
    final brainBase = brainRefBase(profile?.brainRef ?? '');
    final knownLabels = options
        .where((final option) => option.ref == brainBase)
        .map((final option) => option.label);
    final brainLabel = brainBase.isEmpty
        ? l10n.contextNoBrain
        : knownLabels.isEmpty
        ? brainBase
        : knownLabels.first;
    final local = parseLocalBrainRef(profile?.brainRef ?? '');
    final sampling = local == null
        ? '—'
        : '${local.temperature ?? defaultChatTemperature} · '
              '${local.repetitionPenalty ?? defaultChatRepetitionPenalty}';
    final persona = profile?.systemPrompt ?? '';
    return SingleChildScrollView(
      child: Column(
        key: const ValueKey('shell.context.actor'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LaButton.icon(
                key: const ValueKey('shell.context.actor.back'),
                tooltip: l10n.contextBackToConversation,
                icon: const Icon(Icons.arrow_back, size: 18),
                onPressed: widget.peopleFocus.clear,
              ),
              const Spacer(),
              LaButton.icon(
                key: const ValueKey('shell.context.actor.edit'),
                tooltip: l10n.actorsEditTooltip,
                icon: const Icon(Icons.edit_outlined, size: 18),
                onPressed: profile == null
                    ? null
                    : () => setState(() => _editing = true),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
            child: Row(
              children: [
                ActorAvatar(profile: display, size: 44),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        display.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: laUi.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          display.kind.name.toUpperCase(),
                          if (display.role.isNotEmpty) display.role,
                        ].join(' · '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: laUi.micro.copyWith(color: context.shellMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _Section(
            label: l10n.contextBrain,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        brainLabel,
                        style: laUi.compact,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (brainBase.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      BrainHealthDot(
                        key: const ValueKey('shell.context.brain.health'),
                        brainRef: profile?.brainRef ?? '',
                      ),
                    ],
                  ],
                ),
                if (brainBase.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      brainBase,
                      style: laUi.micro.copyWith(color: context.shellMuted),
                    ),
                  ),
              ],
            ),
          ),
          _Section(
            label: l10n.contextSampling,
            child: Text(sampling, style: laUi.compact),
          ),
          _Section(
            label: l10n.contextPersona,
            child: Text(
              persona,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: laUi.compact.copyWith(
                color: persona.isEmpty ? context.shellMuted : null,
              ),
            ),
          ),
          // ADR 0129 — project access: the actor's durable grants, the
          // request affordance, and — on the human's own card, once for
          // the realm — the pending access requests with the one-tap
          // approve (the owner's everything-from-LA decision).
          ProjectAccessSection(service: service, actorId: widget.actorId),
        ],
      ),
    );
  }

  /// The hosted-model option the brain picker offers (same derivation
  /// as the mint form; absence keeps the local casts).
  String _defaultOpenRouterModel(final BuildContext context) {
    try {
      final config = context.read<AgentConfigStore>().config;
      return config.chat.defaultModel.isNotEmpty
          ? config.chat.defaultModel
          : (config.providers[AgentPlatformConfig.openRouterId]?.defaultModel ??
                '');
    } on Object {
      return '';
    }
  }
}

/// A muted section label above its content — the rail's `_Section`
/// shape, read on the shell tokens. An optional [trailing] rides the
/// label row (the mint verb, the retired toggle).
class _Section extends StatelessWidget {
  const _Section({
    required this.label,
    required this.child,
    this.sectionKey,
    this.trailing,
  });

  final String label;
  final Widget child;

  /// The section's agent-contract key (DESIGN §6), null for anonymous
  /// sections.
  final Key? sectionKey;

  /// A small affordance beside the label; null keeps the row plain.
  final Widget? trailing;

  @override
  Widget build(final BuildContext context) => Padding(
    key: sectionKey,
    padding: ShellTokens.sectionPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: shellSectionLabel(context)),
            if (trailing != null) ...[
              const Spacer(),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

/// ADR 0129 — the actor's PROJECT ACCESS section (the owner's
/// everything-from-LA decision): the durable grant set rendered
/// verbatim (the host's own projection — ink is data, paths are facts),
/// a request affordance over the scope picker's roots, and — on the
/// human's own card only, once for the realm — the pending access
/// requests with the one-tap approve ([RealmChatService.grantAccess],
/// the in-process `ecsai --grant` twin whose VERIFY re-read is the
/// honest outcome). Calm chrome: metadata rows in mono, no ceremony.
/// Wave F: PUBLIC — the `actor:<id>` info surface renders the SAME
/// section (one grants row pattern, one key family: `shell.people.*`).
class ProjectAccessSection extends StatefulWidget {
  const ProjectAccessSection({
    required this.service,
    required this.actorId,
    super.key,
  });

  final RealmChatService service;
  final String actorId;

  @override
  State<ProjectAccessSection> createState() => _ProjectAccessSectionState();
}

class _ProjectAccessSectionState extends State<ProjectAccessSection> {
  List<String> _grants = const <String>[];
  List<ActorScopeGrant> _scopes = const <ActorScopeGrant>[];
  List<Map<String, Object?>> _pending = const <Map<String, Object?>>[];
  var _loading = true;
  var _busy = false;

  /// The last action's honest outcome line (the host's own message,
  /// verbatim — never a paraphrase, never a guess).
  String? _outcome;

  /// The realm-wide pending ledger renders ONCE, on the human's own
  /// card (the operator seat — a design call the brief leaves open).
  bool get _isHumanCard => widget.service.humanActorId == widget.actorId;

  @override
  void initState() {
    super.initState();
    unawaited(_reload());
  }

  @override
  void didUpdateWidget(covariant final ProjectAccessSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actorId != widget.actorId) {
      _outcome = null;
      unawaited(_reload());
    }
  }

  Future<void> _reload() async {
    var grants = const <String>[];
    var scopes = const <ActorScopeGrant>[];
    var pending = const <Map<String, Object?>>[];
    try {
      grants = await widget.service.listGrants(widget.actorId);
      // ADR 0147 — the SCOPE ledger rides the same section: the actor's
      // effective grants with their caps and provenance (legacy ∪
      // ledger ∪ channel-conferred), each row with its Revoke verb.
      scopes = await widget.service.listScopeGrants(widget.actorId);
      if (_isHumanCard) {
        pending = await widget.service.pendingAccessRequests();
      }
    } on Object catch (error) {
      // An unreadable ledger keeps the quiet state; the outcome line
      // names the failure honestly (never a silent guess, never a
      // crash in the panel).
      _outcome = '$error';
    }
    if (!mounted) return;
    setState(() {
      _grants = grants;
      _scopes = scopes;
      _pending = pending;
      _loading = false;
    });
  }

  /// ADR 0147 — revokes one scope row (the operator lane: the harness
  /// verb permits the operator, the granter, a superset holder, or the
  /// grantee giving the access back).
  Future<void> _revoke(final ActorScopeGrant grant) async {
    setState(() => _busy = true);
    final result = await widget.service.revokeScope(
      actorId: widget.actorId,
      path: grant.path,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = result.message;
    });
    await _reload();
  }

  Future<void> _request() async {
    final l10n = context.l10n;
    final picked = await pickProjectScope(
      context,
      service: widget.service,
      title: l10n.contextRequestAccessTitle,
      optionKeyPrefix: 'shell.people.access.option',
      listKey: 'shell.people.access.picker',
    );
    if (!mounted || picked == null) return;
    setState(() => _busy = true);
    final result = await widget.service.requestAccess(widget.actorId, picked);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _outcome = result['ok'] == true
          ? l10n.contextAccessRequested
          : '${result['error'] ?? result}';
    });
    await _reload();
  }

  Future<void> _approve(final Map<String, Object?> row) async {
    final actor = '${row['actorId'] ?? ''}';
    final project = '${row['projectId'] ?? ''}';
    if (actor.isEmpty || project.isEmpty) return;
    setState(() => _busy = true);
    final grant = await widget.service.grantAccess(actor, project);
    if (!mounted) return;
    // The host's own message line, verbatim — the VERIFY re-read behind
    // `granted` is what makes the row's disappearance honest.
    setState(() {
      _busy = false;
      _outcome = grant.message;
    });
    await _reload();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final laUi = context.laUi;
    return _Section(
      sectionKey: const ValueKey('shell.people.access'),
      label: l10n.contextProjectAccess,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            Text(
              l10n.loading,
              style: laUi.micro.copyWith(color: context.shellMuted),
            )
          else if (_grants.isEmpty)
            Text(
              l10n.contextNoProjectGrants,
              key: const ValueKey('shell.people.access.empty'),
              style: laUi.micro.copyWith(color: context.shellMuted),
            )
          else
            for (final path in _grants)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: Text(
                  path,
                  key: ValueKey('shell.people.access.grant.$path'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(10.5, context.la.ink),
                ),
              ),
          for (final grant in _scopes)
            if (grant.caps != null || grant.via != null ||
                !_grants.contains(grant.path))
              Padding(
                key: ValueKey('shell.people.access.scope.${grant.path}'),
                padding: const EdgeInsets.symmetric(vertical: 1.5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        [
                          grant.path,
                          if (grant.caps != null) grant.caps!.join(' '),
                          if (grant.via != null) grant.via!,
                        ].join('  '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: LaTokens.mono(10.5, context.la.ink),
                      ),
                    ),
                    LaPressable(
                      key: ValueKey(
                        'shell.people.access.scope.${grant.path}.revoke',
                      ),
                      radius: BorderRadius.circular(6),
                      scaleOnPress: false,
                      onTap: _busy ? null : () => unawaited(_revoke(grant)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1.5,
                        ),
                        child: Text(
                          context.l10n.worldChatPermsRevoke,
                          style: context.laUi.micro.copyWith(
                            color: _busy
                                ? context.shellMuted
                                : context.la.danger,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          const SizedBox(height: 6),
          LaPressable(
            key: const ValueKey('shell.people.access.request'),
            radius: BorderRadius.circular(6),
            scaleOnPress: false,
            onTap: _busy ? null : () => unawaited(_request()),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 13, color: context.shellMuted),
                  const SizedBox(width: 6),
                  Text(
                    l10n.contextRequestAccess,
                    style: laUi.micro.copyWith(
                      color: _busy ? context.shellMuted : context.la.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isHumanCard && _pending.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(l10n.contextPendingAccess, style: shellSectionLabel(context)),
            const SizedBox(height: 4),
            for (final row in _pending) _pendingRow(context, row),
          ],
          if (_outcome != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                _outcome!,
                key: const ValueKey('shell.people.access.message'),
                style: LaTokens.mono(10, context.la.inkMuted),
              ),
            ),
        ],
      ),
    );
  }

  /// One pending request row: WHO asks for WHICH root (the host's row
  /// fields verbatim) + the one-tap approve.
  Widget _pendingRow(
    final BuildContext context,
    final Map<String, Object?> row,
  ) {
    final actor = '${row['actorId'] ?? ''}';
    final project = '${row['projectId'] ?? ''}';
    final name =
        widget.service.roster?.get(actor)?.displayName ??
        actorDisplayFallback(actor);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        key: ValueKey('shell.people.access.pending.$actor.$project'),
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$name · $actor',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.micro,
                ),
                Text(
                  project,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(10, context.shellMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          LaButton(
            key: ValueKey('shell.people.access.approve.$actor.$project'),
            variant: LaButtonVariant.ghost,
            size: LaButtonSize.sm,
            dense: true,
            onPressed: _busy ? null : () => unawaited(_approve(row)),
            label: context.l10n.contextApprove,
          ),
        ],
      ),
    );
  }
}

/// ADR 0119 — the brain health dot moved to its shared home
/// (`brain_health_dot.dart`, 1b): every brain picker renders the same
/// verdict beside the same name.
