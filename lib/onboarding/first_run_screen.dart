/// The first-run flow — "meet your first actor" (product law, plan v5:
/// everything starts from an actor and a conversation; a brand-new user
/// never lands in an empty shell).
///
/// The flow mints the user's FIRST actor through the ONE actor-creation
/// mechanism ([RealmChatService.createActor] — the durable `realm_actors`
/// row plus the roster projection), opens the DM with it
/// ([RealmChatService.openDm]), and seeds ONE greeting beat under the
/// ACTOR's own identity through the LA-side session facade
/// (`service.world.sessionFor(actorId).say`) so the room is never empty.
/// Completion persists `hasCompletedOnboarding` ([UserNotifier]) — the
/// flag the boot routing branch reads — and routes home with the shell's
/// conversation tab already pointed at the DM (the layout blob the shell
/// restores, written through its public [ShellLayout] grammar).
///
/// A calm skip always exists: a user with no provider configured creates
/// no actor and lands in the shell — a brain is never faked.
///
/// Design law (docs/DESIGN.md): the shell's de-Material vocabulary —
/// `context.la.*` semantic ink, hairlines, flat surfaces, sentence case,
/// micro-labels. Widget keys are the agent's UI contract: every
/// interactive widget carries a Semantics label equal to its key
/// (`firstrun.name`, `firstrun.persona`, `firstrun.brain`,
/// `firstrun.create`, `firstrun.skip`).
library;

import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/app_shell.dart' show kViewLayoutPrefsKey;
import 'package:lastanswer/shell/shell_layout.dart';
import 'package:lastanswer/shell/shell_theme.dart';

import 'package:shared_preferences/shared_preferences.dart';

/// The first-run screen: name + optional persona + a brain pick from the
/// AVAILABLE rungs, then create — or a calm skip.
final class FirstRunScreen extends StatefulWidget {
  const FirstRunScreen({
    @visibleForTesting this.service,
    @visibleForTesting this.brainOptions,
    super.key,
  });

  /// Test seam: the service the flow drives (production resolves the
  /// app-run singleton from DI, mirroring the shell's own seam). The
  /// greeting beat rides the SERVICE's world (`service.world`) — never
  /// a second `RealmWorld.open()` — so hermetic overrides flow.
  @visibleForTesting
  final RealmChatService? service;

  /// Test seam: the brain options verbatim (production composes them
  /// from [availableBrainOptions] over the discovered palette).
  @visibleForTesting
  final List<({String ref, String label})>? brainOptions;

  @override
  State<FirstRunScreen> createState() => _FirstRunScreenState();
}

class _FirstRunScreenState extends State<FirstRunScreen> {
  final _name = TextEditingController();
  final _persona = TextEditingController();
  String? _brainRef;
  bool _busy = false;
  String? _error;

  RealmChatService? _ownedService;
  late final RealmChatService _service;

  /// The owned world read model (palette discovery for the brain pick);
  /// null when the options are injected or a service is provided above.
  WorldStateService? _ownedWorldState;
  WorldStateService? _worldState;

  List<({String ref, String label})> get _brainOptions =>
      widget.brainOptions ??
      availableBrainOptions(
        defaultOpenRouterModel: _defaultOpenRouterModel(context),
        paletteRungs: _worldState?.generativeDecls ?? const [],
      );

  @override
  void initState() {
    super.initState();
    // The actors pane's resolution pattern: DI singleton first, an
    // owned instance only when nothing provides one.
    _service =
        widget.service ??
        context.read<RealmChatService?>() ??
        (_ownedService ??= RealmChatService());
    if (widget.brainOptions == null) {
      _worldState = context.read<WorldStateService?>();
      if (_worldState == null) {
        final owned = WorldStateService();
        _ownedWorldState = owned;
        _worldState = owned;
        owned.addListener(_onWorldStateChanged);
        // One discovery pass, no polling: the flow is short-lived and
        // must never leave a pending timer behind.
        unawaited(owned.refresh());
      }
    }
    // Warm the world (idempotent) so Create does not pay the open cost.
    unawaited(_service.ensureReady());
  }

  void _onWorldStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ownedWorldState?.removeListener(_onWorldStateChanged);
    _ownedWorldState?.dispose();
    _name.dispose();
    _persona.dispose();
    _ownedService?.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final options = _brainOptions;
    final effectiveBrain =
        _brainRef ?? (options.isEmpty ? null : options.first.ref);
    final canCreate = !_busy && _name.text.trim().isNotEmpty &&
        effectiveBrain != null;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.firstRunTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: context.la.ink,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),
              Text(
                l10n.firstRunSubtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: context.la.inkMuted,
                  height: 1.45,
                ),
              ),
              const Gap(32),
              Text(
                l10n.firstRunNameLabel,
                style: shellSectionLabel(context),
              ),
              const Gap(6),
              Semantics(
                label: 'firstrun.name',
                textField: true,
                child: TextField(
                  key: const ValueKey('firstrun.name'),
                  controller: _name,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    hintText: l10n.firstRunNameHint,
                    isDense: true,
                  ),
                  textInputAction: TextInputAction.next,
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const Gap(18),
              Text(
                l10n.firstRunPersonaLabel,
                style: shellSectionLabel(context),
              ),
              const Gap(6),
              Semantics(
                label: 'firstrun.persona',
                textField: true,
                child: TextField(
                  key: const ValueKey('firstrun.persona'),
                  controller: _persona,
                  enabled: !_busy,
                  decoration: InputDecoration(
                    hintText: l10n.firstRunPersonaHint,
                    isDense: true,
                  ),
                  minLines: 2,
                  maxLines: 4,
                ),
              ),
              const Gap(18),
              Text(
                l10n.firstRunBrainLabel,
                style: shellSectionLabel(context),
              ),
              const Gap(6),
              if (options.isEmpty)
                Text(
                  l10n.firstRunNoBrains,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.la.inkMuted,
                    height: 1.4,
                  ),
                )
              else
                Semantics(
                  label: 'firstrun.brain',
                  child: DropdownButtonFormField<String>(
                    key: const ValueKey('firstrun.brain'),
                    initialValue: effectiveBrain,
                    isExpanded: true,
                    decoration: const InputDecoration(isDense: true),
                    items: [
                      for (final option in options)
                        DropdownMenuItem(
                          value: option.ref,
                          child: Text(
                            option.label,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: _busy
                        ? null
                        : (final value) => setState(() => _brainRef = value),
                  ),
                ),
              const Gap(28),
              Semantics(
                label: 'firstrun.create',
                button: true,
                enabled: canCreate,
                child: FilledButton(
                  key: const ValueKey('firstrun.create'),
                  onPressed: canCreate ? _create : null,
                  child: Text(
                    _busy ? l10n.firstRunCreating : l10n.firstRunCreate,
                  ),
                ),
              ),
              const Gap(4),
              Semantics(
                label: 'firstrun.skip',
                button: true,
                enabled: !_busy,
                child: TextButton(
                  key: const ValueKey('firstrun.skip'),
                  onPressed: _busy ? null : _skip,
                  child: Text(l10n.firstRunSkip),
                ),
              ),
              if (_error != null) ...[
                const Gap(12),
                Container(
                  height: ShellTokens.hairline,
                  color: context.la.rule,
                ),
                const Gap(12),
                Text(
                  _error!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.la.danger,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// The hosted-model option the brain picker offers — the actors
  /// pane's derivation, verbatim (absence keeps the other lanes only).
  String _defaultOpenRouterModel(final BuildContext context) {
    try {
      final config = context.read<AgentConfigStore>().config;
      return config.chat.defaultModel.isNotEmpty
          ? config.chat.defaultModel
          : (config.providers[AgentPlatformConfig.openRouterId]
                    ?.defaultModel ??
                '');
    } on Object {
      return '';
    }
  }

  /// Create: the ONE actor-creation mechanism, then the DM, then ONE
  /// greeting beat under the actor's own identity, then home.
  Future<void> _create() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    // Captured before any await: no BuildContext use across async gaps.
    final navigator = GoRouter.of(context);
    final userNotifier = context.read<UserNotifier>();
    final l10n = context.l10n;
    final options = _brainOptions;
    final brainRef =
        _brainRef ?? (options.isEmpty ? null : options.first.ref);
    try {
      final service = _service;
      await service.ensureReady();
      // The G6 seam, wired like the shell wires it — a `cast:` brain the
      // flow mints must resolve for the bot loop that picks it up. The
      // shell re-points this at its own read model later; this only
      // fills the absence.
      final worldState = _worldState;
      if (worldState != null && service.resolveCastRung == null) {
        service.resolveCastRung = worldState.castDeclFor;
      }
      if (brainRef == null) {
        // Never fake a brain: no available rung, no actor.
        throw const _NoBrainAvailable();
      }
      final profile = await service.createActor(
        displayName: _name.text.trim(),
        kind: ActorKind.model,
        brainRef: brainRef,
        systemPrompt: _persona.text.trim(),
      );
      if (profile == null) {
        throw _CreateRefused(service.error ?? 'realm_not_ready');
      }
      await service.openDm(profile.actorId);
      final threadId = service.activeThreadId;
      if (threadId != null) {
        await _seedGreeting(
          service,
          profile,
          threadId,
          l10n.firstRunGreeting(profile.displayName),
        );
        // Land the DM deterministically: the beats load through the
        // selection, and the shell's persisted layout opens the DM's
        // conversation tab when home boots.
        service
          ..clearActiveThread()
          ..selectThread(threadId);
        await _persistDmTab(profile.actorId);
      }
      userNotifier.completeOnboarding();
      navigator.go(ScreenPaths.home);
    } on Object catch (error) {
      if (!mounted) return;
      final reason = switch (error) {
        _NoBrainAvailable() => 'no_brain_available',
        _CreateRefused(:final reason) => reason,
        _ => '$error',
      };
      setState(() {
        _busy = false;
        _error = l10n.firstRunCreateFailed(reason);
      });
    }
  }

  /// ONE greeting beat under the ACTOR's identity (the LA-side session
  /// facade exists exactly for this), addressed to the human so the DM
  /// reads as a real arrival. Rides the service's world — the same
  /// store the shell's projections read.
  Future<void> _seedGreeting(
    final RealmChatService service,
    final ActorProfile profile,
    final String threadId,
    final String greeting,
  ) async {
    final world = service.world;
    if (world == null) return; // unresolved world: no seed, no lie
    final human = service.humanActorId;
    await world
        .sessionFor(profile.actorId)
        .say(
          threadId,
          greeting,
          addressedTo: human == null ? const [] : [human],
        );
  }

  /// Points the shell's persisted layout at the new DM (read-modify-write
  /// through the layout's own tolerant grammar) so home boots with the
  /// conversation showing. Best-effort: a failure leaves the DM at the
  /// top of the landing inbox, which is still an honest arrival.
  Future<void> _persistDmTab(final String actorId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(kViewLayoutPrefsKey);
      final layout =
          (raw == null || raw.isEmpty)
              ? ShellLayout.defaultLayout()
              : ShellLayout.fromJson(jsonDecode(raw));
      await prefs.setString(
        kViewLayoutPrefsKey,
        jsonEncode(layout.openConversation('dm:$actorId').toJson()),
      );
    } on Object {
      // Best-effort by design; the world record is the authority.
    }
  }

  /// The calm defer: no provider configured (or the user simply wants
  /// the shell) — create nothing, mark onboarding done, land home.
  void _skip() {
    if (_busy) return;
    context.read<UserNotifier>().completeOnboarding();
    context.go(ScreenPaths.home);
  }
}

/// The named refusal behind "never fake a brain".
final class _NoBrainAvailable implements Exception {
  const _NoBrainAvailable();
}

/// The named refusal when the service could not mint the identity.
final class _CreateRefused implements Exception {
  const _CreateRefused(this.reason);
  final String reason;
}
