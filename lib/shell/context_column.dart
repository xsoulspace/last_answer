/// ADR 0024 — the shell's contextual right panel: a TABBED context HUD.
/// One frame, one width, one hairline; content switches by tab. The tab
/// strip is a quiet row of text labels on a hairline — no pills, no
/// boxes (Tufte): PEOPLE (the default), BROWSER, FILES, TERMINAL,
/// THREADS, DOCS.
///
/// PEOPLE is today's conversation context: the thread topic, the
/// participants (or the channel's member list), and — when an actor is
/// focused by clicking its identity in the conversation header — that
/// actor's profile with an inline EDIT mode (name, role, persona, brain
/// + sampling; no modals). The same edit verb
/// (`RealmChatService.updateActor`) backs the Settings actors pane.
///
/// BROWSER embeds the existing workspace browser surface
/// (`WorkspaceBrowser`, the `browser` surface's widget — reused, not
/// modified). NOTE (design intent, no implementation): this embedded
/// browser is the surface actors will drive via automation intents on
/// any device.
///
/// FILES is a named empty state behind a one-line seam
/// ([ShellContextColumn.filesTabContentBuilder]): the integrator assigns
/// a builder (the workspaces registry) without touching this file.
/// TERMINAL, THREADS and DOCS are quiet named empty states — the
/// information architecture exists before their content lands.
///
/// The panel auto-hides below [kContextColumnMinWindowWidth] window
/// width (LayoutBuilder gate in the shell — the app's minimum window
/// width, so the header toggle is the only hider; Discord keeps its
/// member list visible on narrow windows). The human's show/hide
/// intent, the chosen tab and the focused actor live in
/// [ContextColumnController] — session state only, no persistence.
///
/// Widget keys are the agent's UI contract (DESIGN §6):
/// `shell.contextColumn`, `shell.contextTab.<id>`, `shell.context.topic`,
/// `shell.context.people`, `shell.context.actor` (with `.back`, `.edit`,
/// `.save`), `shell.context.empty.<id>`.
library;

import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/browser/workspace_browser.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_avatar.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_bot_host.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';

/// Below this window width the context panel auto-hides (LayoutBuilder
/// gate in the shell): this is the app's MINIMUM window width, so the
/// column is effectively always laid out and the human's toggle is the
/// only hider — Discord keeps its member list on narrow windows.
const double kContextColumnMinWindowWidth = 980;

/// Which content the tabbed context panel shows. PEOPLE stays the
/// default; every other tab is a named, honest placeholder today.
enum ContextColumnTab { people, browser, files, terminal, threads, docs }

/// The human's intent state for the context panel: visibility (the
/// width gate is NOT state — the shell recomputes it on every layout),
/// the selected tab, and the focused actor (the PEOPLE tab then shows
/// that actor's profile instead of the conversation's people list).
/// Session state only — no persistence.
final class ContextColumnController extends ChangeNotifier {
  bool _visible = true;
  ContextColumnTab _tab = ContextColumnTab.people;
  String? _focusedActorId;

  /// Whether the panel is wanted; the shell still width-gates it.
  bool get visible => _visible;

  /// The selected tab (default [ContextColumnTab.people]).
  ContextColumnTab get tab => _tab;

  /// The focused actor id, null = the conversation's plain people list.
  String? get focusedActorId => _focusedActorId;

  void setVisible({required final bool value}) {
    if (_visible == value) return;
    _visible = value;
    notifyListeners();
  }

  void toggle() => setVisible(value: !visible);

  void setTab(final ContextColumnTab tab) {
    if (_tab == tab) return;
    _tab = tab;
    notifyListeners();
  }

  /// Focuses [actorId]: the PEOPLE tab shows the actor's profile. An
  /// actor is people — focusing selects the PEOPLE tab.
  void focusActor(final String actorId) {
    if (_focusedActorId == actorId && _tab == ContextColumnTab.people) return;
    _focusedActorId = actorId;
    _tab = ContextColumnTab.people;
    notifyListeners();
  }

  /// Clears the actor focus (back to the conversation's people).
  void clearActorFocus() {
    if (_focusedActorId == null) return;
    _focusedActorId = null;
    notifyListeners();
  }
}

/// The shell's right panel over the active conversation (ADR 0024 §4):
/// one frame, the tab strip, then the tab's content.
final class ShellContextColumn extends StatelessWidget {
  const ShellContextColumn({required this.service, super.key});

  /// The world conversation service — the PEOPLE tab's state source.
  final RealmChatService service;

  /// The FILES tab's content seam (one file, one seam): the integrator
  /// assigns a builder — typically the workspaces registry's file
  /// listing — once at startup, and the tab renders it without this
  /// file changing. Null keeps the named empty state.
  static Widget Function(BuildContext context)? filesTabContentBuilder;

  @override
  Widget build(final BuildContext context) {
    final controller = context.read<ContextColumnController?>();
    final body = controller == null
        ? ListenableBuilder(
            listenable: service,
            builder: (final context, final _) =>
                _PeopleTab(service: service, controller: null),
          )
        : ListenableBuilder(
            listenable: Listenable.merge(<Listenable?>[service, controller]),
            builder: (final context, final _) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TabStrip(controller: controller),
                Divider(height: 1, color: Theme.of(context).dividerColor),
                Expanded(child: _tabContent(context, controller)),
              ],
            ),
          );
    return DecoratedBox(
      key: const ValueKey('shell.contextColumn'),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: context.shellHairline,
            width: ShellTokens.hairline,
          ),
        ),
      ),
      child: body,
    );
  }

  Widget _tabContent(
    final BuildContext context,
    final ContextColumnController controller,
  ) => switch (controller.tab) {
    ContextColumnTab.people => _PeopleTab(
      service: service,
      controller: controller,
    ),
    // The embedded workspace browser — the surface actors will drive via
    // automation intents on any device (design intent; the automation
    // wiring is not built here). Mounted only while the tab is live, so
    // a browser window exists exactly when the human asked for it.
    ContextColumnTab.browser => const WorkspaceBrowser(),
    ContextColumnTab.files =>
      ShellContextColumn.filesTabContentBuilder?.call(context) ??
          const _EmptyTabNote(ContextColumnTab.files),
    ContextColumnTab.terminal => const _EmptyTabNote(ContextColumnTab.terminal),
    ContextColumnTab.threads => const _EmptyTabNote(ContextColumnTab.threads),
    ContextColumnTab.docs => const _EmptyTabNote(ContextColumnTab.docs),
  };
}

/// The tab strip: quiet text labels on a hairline, the selected one in
/// strong ink over a hairline accent — no pills, no boxes.
class _TabStrip extends StatelessWidget {
  const _TabStrip({required this.controller});

  final ContextColumnController controller;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    // Six instruments do not fit 240px at full words: the strip scrolls
    // horizontally when labels overflow (Codex-like), so every tab keeps
    // its honest name instead of truncating to noise.
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final tab in ContextColumnTab.values)
              InkWell(
                key: ValueKey('shell.contextTab.${tab.name}'),
                onTap: () => controller.setTab(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 9,
                    horizontal: 8,
                  ),
                  decoration: controller.tab == tab
                      ? BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: theme.colorScheme.primary,
                              width: ShellTokens.hairline * 2,
                            ),
                          ),
                        )
                      : null,
                  child: Text(
                    switch (tab) {
                      ContextColumnTab.people => context.l10n.contextTabPeople,
                      ContextColumnTab.browser =>
                        context.l10n.contextTabBrowser,
                      ContextColumnTab.files => context.l10n.contextTabFiles,
                      ContextColumnTab.terminal =>
                        context.l10n.contextTabTerminal,
                      ContextColumnTab.threads =>
                        context.l10n.contextTabThreads,
                      ContextColumnTab.docs => context.l10n.contextTabDocs,
                    },
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    // Linear vocabulary: hierarchy by tone, not by case
                    // tricks — sentence case, active = full ink.
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: ShellTokens.sectionLabelSize,
                      color: controller.tab == tab
                          ? theme.colorScheme.onSurface
                          : context.shellMuted,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// The PEOPLE tab: the focused actor's profile (with its inline edit
/// mode), or the conversation's topic + people list.
class _PeopleTab extends StatelessWidget {
  const _PeopleTab({required this.service, required this.controller});

  final RealmChatService service;

  /// Null when no controller owns the column (the actor panel needs one
  /// for focus); the plain people list still renders.
  final ContextColumnController? controller;

  @override
  Widget build(final BuildContext context) {
    final controller = this.controller;
    final focusedId = controller?.focusedActorId;
    if (controller != null && focusedId != null) {
      return _ActorPanel(
        service: service,
        controller: controller,
        actorId: focusedId,
      );
    }
    final thread = service.activeThread;
    if (thread == null) {
      return _ColumnNote(text: context.l10n.worldChatSelectFromRail);
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
                onFocus: controller?.focusActor,
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

  /// Focuses an actor (its profile rides the PEOPLE tab); null when no
  /// controller owns the column and rows stay inert.
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
    required this.controller,
    required this.actorId,
  });

  final RealmChatService service;
  final ContextColumnController controller;
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
                onPressed: widget.controller.clearActorFocus,
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
                Text(brainLabel, style: theme.textTheme.bodySmall),
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

/// A tab's quiet named empty state: honest absence, one line.
class _EmptyTabNote extends StatelessWidget {
  const _EmptyTabNote(this.tab);

  final ContextColumnTab tab;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final message = switch (tab) {
      ContextColumnTab.files => l10n.contextFilesEmpty,
      ContextColumnTab.terminal => l10n.contextTerminalEmpty,
      ContextColumnTab.threads => l10n.contextThreadsEmpty,
      ContextColumnTab.docs => l10n.contextDocsEmpty,
      _ => l10n.contextFilesEmpty,
    };
    return Center(
      key: ValueKey('shell.context.empty.${tab.name}'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: context.shellMuted),
        ),
      ),
    );
  }
}

/// The quiet no-conversation note: the column is contextual, and no
/// conversation is open.
class _ColumnNote extends StatelessWidget {
  const _ColumnNote({required this.text});

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
