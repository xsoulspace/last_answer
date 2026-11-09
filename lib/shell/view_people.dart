/// WAVE 5 — the PEOPLE view, promoted from the context panel into the
/// surface registry (docs/design/unified-views.md): the actor-profile
/// panel is a view now, tab-able and pin-able like any other. Two
/// pieces live here:
///
/// - [PeopleFocus] — the session state of WHICH actor the view
///   focuses (null = the conversation's plain people list). Plain
///   ChangeNotifier, provided by the shell; the view reads it
///   nullable (hermetic shells render the inert list).
/// - [PeopleView] — the view body: the conversation's topic + people
///   (with the bots' quiet narration lines), or the focused actor's
///   profile with its inline EDIT mode. The same edit verb
///   (`RealmChatService.updateActor`) backs the Settings actors pane.
///
/// Widget keys are the agent's UI contract (DESIGN §6) — carried over
/// from the panel unchanged: `shell.context.topic`, `shell.context.people`,
/// `shell.context.person.<id>`, `shell.people.status.<id>`,
/// `shell.context.actor` (with `.back`, `.edit`, `.save`).
library;

import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/brain_health_dot.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/la_world/creatures.dart';
import 'package:lastanswer/la_world/la_world.dart';
import 'package:lastanswer/shell/project_scope_picker.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/ui/creature_mark.dart';

/// Which actor the people view focuses (session state, not persisted —
/// the same lifetime the panel's focus had). Null = the conversation's
/// plain people list.
final class PeopleFocus extends ChangeNotifier {
  String? _actorId;

  /// The focused actor id, null = the plain people list.
  String? get actorId => _actorId;

  /// Focuses [actorId]: the view shows the actor's profile.
  void focus(final String actorId) {
    if (_actorId == actorId) return;
    _actorId = actorId;
    notifyListeners();
  }

  /// Clears the focus (back to the conversation's people).
  void clear() {
    if (_actorId == null) return;
    _actorId = null;
    notifyListeners();
  }
}

/// The PEOPLE view body: the focused actor's profile (with its inline
/// edit mode), or the conversation's topic + people list. Reads the
/// service (state) and the [PeopleFocus] (focus); a null focus keeps
/// the rows inert (hermetic shells without a shell above).
final class PeopleView extends StatelessWidget {
  const PeopleView({required this.service, this.focus, super.key});

  /// The world conversation service — the view's state source.
  final RealmChatService service;

  /// The view's focus; null renders the plain people list with inert
  /// rows.
  final PeopleFocus? focus;

  @override
  Widget build(final BuildContext context) {
    final focus = this.focus;
    return ListenableBuilder(
      listenable: focus ?? service,
      builder: (final context, final _) {
        final focusedId = focus?.actorId;
        if (focus != null && focusedId != null) {
          return _ActorPanel(
            service: service,
            peopleFocus: focus,
            actorId: focusedId,
          );
        }
        return ListenableBuilder(
          listenable: service,
          builder: (final context, final _) =>
              _PeopleListBody(service: service, onFocus: focus?.focus),
        );
      },
    );
  }
}

/// The conversation's people: the thread topic (when it says something
/// the people section does not) + one row per person.
class _PeopleListBody extends StatelessWidget {
  const _PeopleListBody({required this.service, this.onFocus});

  final RealmChatService service;

  /// Focuses an actor (its profile rides the view); null keeps rows
  /// inert.
  final void Function(String actorId)? onFocus;

  @override
  Widget build(final BuildContext context) {
    final thread = service.activeThread;
    if (thread == null) {
      return _ViewNote(text: context.l10n.worldChatSelectFromRail);
    }
    final l10n = context.l10n;
    final threadId = thread['threadId']! as String;
    final participants = (thread['participants']! as List).cast<String>();
    final channel = service.channelByThreadId(threadId);
    final human = service.humanActorId;
    final isDm =
        human != null &&
        participants.length == 2 &&
        participants.contains(human);
    // A channel names its members; a conversation lists its
    // participants. A DM's topic is the other actor's name — the
    // people section already says it, so no topic rule there.
    final people = channel?.memberIds ?? participants;
    final showTopic = channel == null && !isDm;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTopic)
            _Section(
              sectionKey: const ValueKey('shell.context.topic'),
              label: l10n.contextTopic,
              child: Text(
                thread['topic']! as String,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (people.isNotEmpty)
            _Section(
              sectionKey: const ValueKey('shell.context.people'),
              label: channel != null
                  ? l10n.contextMembers
                  : l10n.contextParticipants,
              child: _PeopleList(
                ids: people,
                service: service,
                onFocus: onFocus,
              ),
            ),
        ],
      ),
    );
  }
}

/// The people of the conversation: derived avatar + display name per
/// row, presence folded from the bot host (the rail's derivation). A
/// row taps into the actor's profile (the header identity does too).
class _PeopleList extends StatelessWidget {
  const _PeopleList({required this.ids, required this.service, this.onFocus});

  final List<String> ids;

  /// The world conversation service — roster and bot presence source.
  final RealmChatService service;

  /// Focuses an actor (its profile rides the view); null keeps rows
  /// inert.
  final void Function(String actorId)? onFocus;

  @override
  Widget build(final BuildContext context) {
    final roster = service.roster;
    final bots = service.bots;
    // 3d — the creature layer's UI fold: the narration and daemon
    // facts live in memory (service/world), not in the journal, so the
    // widget that reads them reports them to the projection on its own
    // rebuild. refreshCreatures notifies NOTHING (LaWorld is not this
    // widget's listenable; the rows rebuild on the service's tick) —
    // the selector discipline stays intact.
    final laWorld = context.read<LaWorld?>();
    if (laWorld != null) {
      final world = context.read<WorldStateService?>();
      laWorld.refreshCreatures(
        narrationStates: <String, String>{
          for (final entry in service.botNarration.entries)
            entry.key: entry.value.state.name,
        },
        daemonAsleep: world == null ? false : !world.daemonLive,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final id in ids) _personRow(context, id, roster, bots, laWorld),
      ],
    );
  }

  /// One people row: avatar + name, and — Wave 3A — the bot's one-line
  /// activity narration underneath (humans and unknown ids stay quiet;
  /// a listening bot is silence). The whole row taps into the profile.
  /// 3d: a bot's avatar grows EYES — the creature overlay carries the
  /// mood the derive law folded (the avatar keeps its identicon, kind
  /// badge, presence dot and keys untouched — a creature never becomes
  /// the only carrier of type or presence).
  Widget _personRow(
    final BuildContext context,
    final String id,
    final ActorRoster? roster,
    final RealmBotHost? bots,
    final LaWorld? laWorld,
  ) {
    final line = _statusLineOf(context, id);
    final profile =
        roster?.get(id) ??
        ActorProfile(actorId: id, displayName: actorDisplayFallback(id));
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
    if (rostered != null && rostered.kind != ActorKind.human) {
      avatar = Stack(
        children: [
          avatar,
          Positioned.fill(
            child: CreatureMark(
              actorId: id,
              mood: _moodOf(id, laWorld),
              size: ShellTokens.rowAvatar,
              eyesOnly: true,
            ),
          ),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        key: ValueKey('shell.context.person.$id'),
        onTap: onFocus == null ? null : () => onFocus!(id),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                avatar,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    roster?.get(id)?.displayName ?? actorDisplayFallback(id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
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
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
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
  /// glance (the room's work card owns the detail — the row owns the
  /// "is my cast busy" answer).
  String? _statusLineOf(final BuildContext context, final String id) {
    final profile = service.roster?.get(id);
    if (profile == null || profile.kind == ActorKind.human) return null;
    final narration = service.botNarration[id]?.statusLine;
    final world = context.read<WorldStateService?>();
    var running = 0;
    if (world != null) {
      for (final task in world.tasks) {
        if (!task.terminal && task.addressees.contains(id)) running++;
      }
    }
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

/// The focused actor's profile: identity, brain, sampling, persona —
/// and an EDIT affordance that switches in place to
/// [ActorProfileEditor] (no modal; Save routes through
/// `RealmChatService.updateActor`, which persists the world record and
/// rebuilds the bot loop when the profile materially changed).
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
    final theme = Theme.of(context);
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
            ),
            saveKey: const ValueKey('shell.context.actor.save'),
            onCancel: () => setState(() => _editing = false),
            onSave:
                ({
                  required displayName,
                  required role,
                  required systemPrompt,
                  required brainRef,
                }) {
                  unawaited(
                    service
                        .updateActor(
                          actorId: widget.actorId,
                          displayName: displayName,
                          role: role,
                          systemPrompt: systemPrompt,
                          brainRef: brainRef,
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
              IconButton(
                key: const ValueKey('shell.context.actor.back'),
                tooltip: l10n.contextBackToConversation,
                icon: const Icon(Icons.arrow_back, size: 18),
                visualDensity: VisualDensity.compact,
                onPressed: widget.peopleFocus.clear,
              ),
              const Spacer(),
              IconButton(
                key: const ValueKey('shell.context.actor.edit'),
                tooltip: l10n.actorsEditTooltip,
                icon: const Icon(Icons.edit_outlined, size: 18),
                visualDensity: VisualDensity.compact,
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
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        [
                          display.kind.name.toUpperCase(),
                          if (display.role.isNotEmpty) display.role,
                        ].join(' · '),
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
                        style: theme.textTheme.bodySmall,
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
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: context.shellMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _Section(
            label: l10n.contextSampling,
            child: Text(sampling, style: theme.textTheme.bodySmall),
          ),
          _Section(
            label: l10n.contextPersona,
            child: Text(
              persona,
              maxLines: 8,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: persona.isEmpty ? context.shellMuted : null,
              ),
            ),
          ),
          // ADR 0129 — project access: the actor's durable grants, the
          // request affordance, and — on the human's own card, once for
          // the realm — the pending access requests with the one-tap
          // approve (the owner's everything-from-LA decision).
          _ProjectAccessSection(service: service, actorId: widget.actorId),
        ],
      ),
    );
  }

  /// The hosted-model option the brain picker offers (same derivation
  /// as the Settings pane's mint form; absence keeps the local casts).
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
/// shape, read on the shell tokens.
class _Section extends StatelessWidget {
  const _Section({required this.label, required this.child, this.sectionKey});

  final String label;
  final Widget child;

  /// The section's agent-contract key (DESIGN §6), null for anonymous
  /// sections.
  final Key? sectionKey;

  @override
  Widget build(final BuildContext context) => Padding(
    key: sectionKey,
    padding: ShellTokens.sectionPadding,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: shellSectionLabel(context)),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

/// The view's quiet no-conversation note.
class _ViewNote extends StatelessWidget {
  const _ViewNote({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
      ),
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
class _ProjectAccessSection extends StatefulWidget {
  const _ProjectAccessSection({required this.service, required this.actorId});

  final RealmChatService service;
  final String actorId;

  @override
  State<_ProjectAccessSection> createState() => _ProjectAccessSectionState();
}

class _ProjectAccessSectionState extends State<_ProjectAccessSection> {
  List<String> _grants = const <String>[];
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
  void didUpdateWidget(covariant final _ProjectAccessSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.actorId != widget.actorId) {
      _outcome = null;
      unawaited(_reload());
    }
  }

  Future<void> _reload() async {
    var grants = const <String>[];
    var pending = const <Map<String, Object?>>[];
    try {
      grants = await widget.service.listGrants(widget.actorId);
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
      _pending = pending;
      _loading = false;
    });
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
    final theme = Theme.of(context);
    return _Section(
      sectionKey: const ValueKey('shell.people.access'),
      label: l10n.contextProjectAccess,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            Text(
              l10n.loading,
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.shellMuted,
              ),
            )
          else if (_grants.isEmpty)
            Text(
              l10n.contextNoProjectGrants,
              key: const ValueKey('shell.people.access.empty'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: context.shellMuted,
              ),
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
          const SizedBox(height: 6),
          InkWell(
            key: const ValueKey('shell.people.access.request'),
            borderRadius: BorderRadius.circular(6),
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
                    style: theme.textTheme.labelSmall?.copyWith(
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
    final theme = Theme.of(context);
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
                  style: theme.textTheme.labelSmall,
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
          TextButton(
            key: ValueKey('shell.people.access.approve.$actor.$project'),
            onPressed: _busy ? null : () => unawaited(_approve(row)),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: Text(context.l10n.contextApprove),
          ),
        ],
      ),
    );
  }
}

/// ADR 0119 — the brain health dot moved to its shared home
/// (`brain_health_dot.dart`, 1b): every brain picker renders the same
/// verdict beside the same name.
