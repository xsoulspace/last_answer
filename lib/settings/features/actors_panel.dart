import 'package:lastanswer/agent_config/agent_config.dart';
import 'package:lastanswer/coding_agent/actor_roster.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_brain.dart';
import 'package:lastanswer/coding_agent/realm_chat/actor_profile_editor.dart';
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/common_imports.dart';

/// ADR 0023 §1a — the Settings actors pane: where a human mints actor
/// identities (the Grok-bot shape) and watches the bot runtime.
///
/// This is the SAME creation mechanism actors use when they spawn
/// actors — the pane only wraps [RealmChatService.createActor], which
/// lands a roster profile plus a durable world record. Observability
/// (world inspector, mesh tasks) also lives here, moved out from under
/// every doc surface.
class ActorsPanel extends StatefulWidget {
  const ActorsPanel({this.padding, super.key});

  final EdgeInsets? padding;

  @override
  State<ActorsPanel> createState() => _ActorsPanelState();
}

class _ActorsPanelState extends State<ActorsPanel> {
  RealmChatService? _owned;

  /// Resolved once in [initState]: `dispose` must not look up ancestors
  /// on the deactivated element (it is unsafe there).
  RealmChatService? _resolved;

  RealmChatService get _service =>
      _resolved ??=
          context.read<RealmChatService?>() ?? (_owned ??= RealmChatService());

  @override
  void initState() {
    super.initState();
    final service = _service..addListener(_onChanged);
    unawaited(service.ensureReady());
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_onChanged);
    _owned?.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final service = _service;
    final roster = service.roster;
    final actors = roster?.all ?? const <ActorProfile>[];
    return Padding(
      padding: widget.padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.actorsSectionTitle,
            style: theme.textTheme.labelSmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.actorsSectionHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          if (!service.isSupported)
            Text(
              context.l10n.actorsUnsupported,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            )
          else if (service.error != null && !service.isReady)
            Text(
              'World failed to open: ${service.error}',
              style: TextStyle(color: theme.colorScheme.error),
            )
          else ...[
            if (actors.isEmpty)
              Text(
                context.l10n.actorsNoneYet,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              )
            else
              for (final actor in actors)
                if (actor.kind != ActorKind.human)
                  _ActorRow(
                    key: ValueKey('actors.row.${actor.actorId}'),
                    actor: actor,
                    service: service,
                    defaultOpenRouterModel: _defaultOpenRouterModel(context),
                  ),
            const _CreateActorForm(),
          ],
        ],
      ),
    );
  }
}

/// The hosted-model option the brain pickers offer (same derivation for
/// the mint form and the edit expansions; absence keeps the local casts
/// only).
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

class _ActorRow extends StatefulWidget {
  const _ActorRow({
    required this.actor,
    required this.service,
    required this.defaultOpenRouterModel,
    super.key,
  });

  final ActorProfile actor;
  final RealmChatService service;
  final String defaultOpenRouterModel;

  @override
  State<_ActorRow> createState() => _ActorRowState();
}

class _ActorRowState extends State<_ActorRow> {
  /// The row's inline edit expansion — the SAME editor the context
  /// column's actor panel embeds, routed through the SAME verb
  /// (`RealmChatService.updateActor`). One editing mechanism, two
  /// surfaces; no modals on either.
  var _editing = false;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final actor = widget.actor;
    final status = widget.service.bots?.statuses[actor.actorId];
    final muted = theme.colorScheme.onSurfaceVariant;
    final failed = status != null && status.startsWith('failed');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                switch (status) {
                  null => Icons.person_outline,
                  'listening' => Icons.circle,
                  _ => failed ? Icons.error_outline : Icons.circle_outlined,
                },
                size: 14,
                color: switch (status) {
                  'listening' => context.la.accent,
                  _ => failed ? theme.colorScheme.error : muted,
                },
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${actor.displayName} · ${actor.brainRef.isEmpty ? 'no brain' : actor.brainRef}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (status != null && status != 'listening')
                      Text(
                        status,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: failed ? theme.colorScheme.error : muted,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                key: ValueKey('actors.edit.${actor.actorId}'),
                tooltip: context.l10n.actorsEditTooltip,
                icon: Icon(
                  _editing ? Icons.keyboard_arrow_up : Icons.edit_outlined,
                  size: 20,
                ),
                visualDensity: VisualDensity.compact,
                onPressed: () => setState(() => _editing = !_editing),
              ),
              IconButton(
                key: ValueKey('actors.remove.${actor.actorId}'),
                tooltip: context.l10n.actorsRemoveTooltip,
                icon: const Icon(Icons.delete_outline, size: 20),
                visualDensity: VisualDensity.compact,
                onPressed: () => widget.service.removeActor(actor.actorId),
              ),
            ],
          ),
          if (_editing)
            Padding(
              padding: const EdgeInsets.only(left: 22, top: 6, bottom: 4),
              child: ActorProfileEditor(
                profile: actor,
                brainOptions: availableBrainOptions(
                  defaultOpenRouterModel: widget.defaultOpenRouterModel,
                ),
                onCancel: () => setState(() => _editing = false),
                onSave:
                    ({
                      required displayName,
                      required role,
                      required systemPrompt,
                      required brainRef,
                    }) {
                      unawaited(
                        widget.service
                            .updateActor(
                              actorId: actor.actorId,
                              displayName: displayName,
                              role: role,
                              systemPrompt: systemPrompt,
                              brainRef: brainRef,
                            )
                            .then((final ok) {
                              if (mounted && ok) {
                                setState(() => _editing = false);
                              }
                            }),
                      );
                    },
              ),
            ),
        ],
      ),
    );
  }
}

/// The inline mint form: name + brain (+ role), then Create.
class _CreateActorForm extends StatefulWidget {
  const _CreateActorForm();

  @override
  State<_CreateActorForm> createState() => _CreateActorFormState();
}

class _CreateActorFormState extends State<_CreateActorForm> {
  final _name = TextEditingController();
  final _role = TextEditingController();
  String? _brainRef;

  @override
  void dispose() {
    _name.dispose();
    _role.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final options = availableBrainOptions(
      defaultOpenRouterModel: _defaultOpenRouterModel(context),
    );
    final effective = _brainRef ?? (options.isEmpty ? null : options.first.ref);
    final canCreate = _name.text.trim().isNotEmpty && effective != null;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  key: const ValueKey('actors.name'),
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: context.l10n.actorsNameLabel,
                    hintText: context.l10n.actorsNameHint,
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  key: const ValueKey('actors.brain'),
                  initialValue: effective,
                  decoration: InputDecoration(
                    labelText: context.l10n.actorsBrainLabel,
                    isDense: true,
                  ),
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
                  onChanged: (final value) => setState(() => _brainRef = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const ValueKey('actors.role'),
                  controller: _role,
                  decoration: InputDecoration(
                    labelText: context.l10n.actorsRoleLabel,
                    hintText: context.l10n.actorsRoleHint,
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                key: const ValueKey('actors.create'),
                onPressed: canCreate ? _create : null,
                child: Text(context.l10n.actorsCreateActor),
              ),
            ],
          ),
          if (Theme.of(context).platform != TargetPlatform.macOS)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.actorsLocalNeedsMacos,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _create() async {
    final service = context.read<RealmChatService?>();
    if (service == null) return;
    await service.ensureReady();
    await service.createActor(
      displayName: _name.text.trim(),
      kind: ActorKind.model,
      brainRef: _brainRef ?? '',
      role: _role.text.trim(),
    );
    if (mounted) {
      setState(() {
        _name.clear();
        _role.clear();
      });
    }
  }
}
