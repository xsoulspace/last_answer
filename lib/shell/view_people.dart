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
import 'package:lastanswer/coding_agent/realm_chat/palette_health.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final id in ids) _personRow(context, id, roster, bots)],
    );
  }

  /// One people row: avatar + name, and — Wave 3A — the bot's one-line
  /// activity narration underneath (humans and unknown ids stay quiet;
  /// a listening bot is silence). The whole row taps into the profile.
  Widget _personRow(
    final BuildContext context,
    final String id,
    final ActorRoster? roster,
    final RealmBotHost? bots,
  ) {
    final line = _statusLineOf(id);
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
                ActorAvatar(
                  profile:
                      roster?.get(id) ??
                      ActorProfile(
                        actorId: id,
                        displayName: actorDisplayFallback(id),
                      ),
                  size: ShellTokens.rowAvatar,
                  showPresence: bots != null,
                  presenceOnline: bots?.statuses[id] == 'listening',
                ),
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
  /// narration speak; humans and unknown ids return null.
  String? _statusLineOf(final String id) {
    final profile = service.roster?.get(id);
    if (profile == null || profile.kind == ActorKind.human) return null;
    return service.botNarration[id]?.statusLine;
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
                      _BrainHealthDot(
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

/// ADR 0119 — the brain's daemon-side health verdict as one small dot:
/// green `ok`, grey `unknown`, amber `not_downloaded`/`downloading`/
/// `loading`, red `failed`. The tooltip names the code and the daemon's
/// fix hint; a brain the palette doesn't name (a local brain, a stale
/// file) renders nothing at all — no verdict, no chrome.
class _BrainHealthDot extends StatelessWidget {
  const _BrainHealthDot({required this.brainRef, super.key});

  final String brainRef;

  static final PaletteHealthStore _store = PaletteHealthStore();

  @override
  Widget build(final BuildContext context) {
    final health = _store.statusFor(brainRef);
    if (health == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final color = switch (health.status) {
      'ok' => const Color(0xFF30A46C),
      'failed' => theme.colorScheme.error,
      'unknown' => context.shellMuted,
      _ => const Color(0xFFB58A00),
    };
    return Tooltip(
      message:
          '${health.status}'
          '${health.code == null ? '' : ' (${health.code})'}'
          '${health.detail == null ? '' : ' — ${health.detail}'}',
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}
