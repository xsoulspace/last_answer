/// Phase 1d — the Models surface (docs/design/
/// ecsai-modelscope-first-priority-2026-11-05.md G5/G7 first step): the
/// chrome that merges the read models that already existed — every
/// declared palette rung with its health verdict, the escalation
/// ladder, the daemon's arm controls, the per-actor dispatch telemetry
/// (cache-hit %, rounds, stalls) — and the palette EDITOR over the real
/// config document, validated with the harness's own parser.
///
/// Wave J — the surface is also the PROVIDER EDITOR: the read lane
/// lists every declared provider (transport family, endpoint, the
/// credential env NAME — never a value, model count, merged health) and
/// expands into its models + the read-only cast chips that ride it; the
/// Pro-gated edit lane builds a candidate palette IN MEMORY in the
/// host's own wire shape and lands it through the participation plane's
/// revision verbs (`RealmChatService.proposePalette` /
/// `applyPalette` — propose validates with the harness parser, apply is
/// OWNER-ONLY and a non-owner refusal renders its recovery verbatim).
///
/// Dynamic by law (the owner's Zed rule): nothing here names a model.
/// The rungs are whatever the discovered `.xsoulspace/config.json`
/// declares; the editor edits that document (a JSON view with named
/// refusals — Zed's own settings grammar); health comes from the
/// daemon's file. A config change is a Save + Restart world away, with
/// no Dart edit and no shell.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:lastanswer/coding_agent/realm_chat/realm_chat_service.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/entitlement/tier_gate.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot, healthColor;
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show
        PaletteCastEntryConfig,
        PaletteConfig,
        PaletteConfigError,
        PaletteProviderConfig,
        paletteFingerprint,
        parsePaletteConfig;

/// The Models surface: rungs + daemon controls + editor + telemetry +
/// the Wave J provider lanes.
final class ModelsView extends StatelessWidget {
  const ModelsView({required this.world, this.service, super.key});

  final WorldStateService world;

  /// Wave J — the realm chat service the palette verbs ride. Injected
  /// by tests; in the shell it resolves from the provider scope. Null
  /// degrades honestly: the edit lane names the missing seat.
  final RealmChatService? service;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    return ListenableBuilder(
      listenable: world,
      builder: (final context, final _) => ListView(
        key: const ValueKey('shell.modelsView'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
        children: [
          _DaemonHeader(world: world),
          const SizedBox(height: 18),
          if (world.paletteAbsence case final refusal?)
            _RefusalNote(keyName: 'models.palette.refusal', text: refusal)
          else if (world.rungs.isEmpty)
            _RefusalNote(
              keyName: 'models.palette.empty',
              text: world.paletteConfigPath == null
                  ? l10n.modelsNoPalette
                  : '${l10n.modelsNoPalette} · ${world.paletteConfigPath}',
            ),
          if (world.rungs.isNotEmpty) ...[
            _RungSection(
              title: l10n.modelsGenerative,
              world: world,
              rungs: [
                for (final rung in world.rungs)
                  if (rung.role == 'generative') rung,
              ],
            ),
            const SizedBox(height: 14),
            _RungSection(
              title: l10n.modelsDecision,
              world: world,
              rungs: [
                for (final rung in world.rungs)
                  if (rung.role != 'generative') rung,
              ],
            ),
          ],
          // Wave J — the provider READ lane (free: reading the truth is
          // never a paid feature); its Pro-gated edit affordance opens
          // the structured provider editor.
          if (world.palette != null) ...[
            const SizedBox(height: 14),
            _ProviderSection(
              world: world,
              service: service ?? context.read<RealmChatService?>(),
            ),
          ],
          if (world.telemetryByActor.isNotEmpty) ...[
            const SizedBox(height: 18),
            _TelemetrySection(world: world),
          ],
        ],
      ),
    );
  }
}

/// The header: daemon facts + the arm controls + the editor affordance.
final class _DaemonHeader extends StatelessWidget {
  const _DaemonHeader({required this.world});

  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final theme = Theme.of(context);
    final facts = <String>[
      if (world.daemonLive) world.daemonPid == null
                ? l10n.modelsDaemonLive
                : '${l10n.modelsDaemonLive} · pid ${world.daemonPid}' else l10n.modelsDaemonDown,
      if (world.daemonBinaryStale == true) l10n.modelsDaemonStale,
      ?world.paletteConfigPath,
    ];
    return Row(
      key: const ValueKey('models.header'),
      children: [
        HealthDot(status: world.daemonLive ? 'ok' : 'failed', size: 8),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.viewModelsTitle, style: theme.textTheme.titleMedium),
              Text(
                facts.join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: la.inkQuiet,
                  fontSize: 10,
                ),
              ),
              // G1 — the scheduler's honest row: the durable delegation
              // lane has a claimant pump (live · pid) or it does not
              // (down — a delegated task would sit `queued`). One fact,
              // never an invented health.
              Text(
                world.schedulerLive
                    ? world.schedulerPid == null
                          ? l10n.modelsSchedulerLive
                          : '${l10n.modelsSchedulerLive} · '
                                'pid ${world.schedulerPid}'
                    : l10n.modelsSchedulerDown,
                key: const ValueKey('models.scheduler'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: world.schedulerLive ? la.inkQuiet : la.caution,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
        Flexible(
          // A split group can be arbitrarily narrow: the daemon's verb
          // cluster scales down as a whole instead of overflowing (a
          // RenderFlex overflow is an error, never a layout).
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!world.daemonLive)
                  _HeaderButton(
                    keyName: 'models.arm',
                    label: world.armState == WorldArmState.arming
                        ? l10n.edgeArming
                        : l10n.edgeArmWorld,
                    busy: world.armState == WorldArmState.arming,
                    onTap: () => unawaited(world.armWorld()),
                  )
                else ...[
                  _HeaderButton(
                    keyName: 'models.restart',
                    label: l10n.edgeRestartWorld,
                    onTap: () => unawaited(world.restartWorld()),
                  ),
                  const SizedBox(width: 6),
                  _HeaderButton(
                    keyName: 'models.stop',
                    label: l10n.edgeStopWorld,
                    onTap: () => unawaited(world.stopWorld()),
                  ),
                ],
                const SizedBox(width: 6),
                // Plan v5 4b — the tier gate sits on the EDIT affordance
                // only: the rungs/telemetry read model above stays FREE
                // (reading the truth is never a paid feature). FREE
                // renders the quiet named absence with the upgrade
                // route; an unmounted entitlement layer fails open
                // (hermetic surfaces are never locked out).
                ProGate(
                  feature: TierFeature.paletteEditor,
                  child: _HeaderButton(
                    keyName: 'models.edit',
                    label: l10n.modelsEditPalette,
                    onTap: () => unawaited(
                      showDialog<void>(
                        context: context,
                        builder: (final dialogContext) =>
                            PaletteEditorDialog(world: world),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// One header button: quiet fill, sentence case.
final class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.keyName,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  final String keyName;
  final String label;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    return Semantics(
      button: true,
      label: keyName,
      hint: label,
      child: MouseRegion(
        cursor: busy ? MouseCursor.defer : SystemMouseCursors.click,
        child: GestureDetector(
          key: ValueKey(keyName),
          behavior: HitTestBehavior.opaque,
          onTap: busy ? null : onTap,
          child: Container(
            height: 24,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: la.ink.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: busy
                  ? SizedBox(
                      width: 11,
                      height: 11,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: la.inkMuted,
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: la.inkMuted,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A named refusal / quiet absence note (the house law: honest surfaces
/// render the code verbatim).
final class _RefusalNote extends StatelessWidget {
  const _RefusalNote({required this.keyName, required this.text});

  final String keyName;
  final String text;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      key: ValueKey(keyName),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.la.caution.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(ShellTokens.radius),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          fontFamily: LaTokens.monoFamily,
          color: context.la.inkMuted,
        ),
      ),
    ),
  );
}

/// One role's rung list.
final class _RungSection extends StatelessWidget {
  const _RungSection({
    required this.title,
    required this.world,
    required this.rungs,
  });

  final String title;
  final WorldStateService world;
  final List<WorldRung> rungs;

  @override
  Widget build(final BuildContext context) {
    if (rungs.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(title, style: shellSectionLabel(context)),
        ),
        Container(
          decoration: BoxDecoration(
            color: context.shellRaised,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final rung in rungs)
                _RungRow(
                  key: ValueKey('models.rung.${rung.id}'),
                  rung: rung,
                  selected: world.selectedRungId == rung.id,
                  generative: rung.role == 'generative',
                  onSelect: rung.role == 'generative'
                      ? () => world.selectRung(
                          world.selectedRungId == rung.id ? null : rung.id,
                        )
                      : null,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One rung row: health dot · id · provider/model · chips (primary,
/// local, ladder next) · delegate-via mark. The local-lane honesty law:
/// `not_downloaded` renders with the weights fact (the runtime never
/// downloads), never as a dead toggle.
final class _RungRow extends StatelessWidget {
  const _RungRow({
    required this.rung,
    required this.selected,
    required this.generative,
    required this.onSelect,
    super.key,
  });

  final WorldRung rung;
  final bool selected;
  final bool generative;
  final VoidCallback? onSelect;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final theme = Theme.of(context);
    final health = rung.health;
    final detail = switch (health?.status) {
      'failed' =>
        '${health?.code ?? 'failed'}'
            '${health?.detail == null ? '' : ' · ${health!.detail}'}',
      'not_downloaded' =>
        '${health?.code ?? 'not_downloaded'}'
            '${health?.detail == null ? '' : ' · ${health!.detail}'}',
      _ => health?.detail,
    };
    return Semantics(
      button: onSelect != null,
      selected: selected,
      label: 'models.rung.${rung.id}',
      hint: rung.id,
      child: ShellRow(
        height: detail == null ? 38 : 50,
        selected: selected,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: onSelect,
        child: Row(
          children: [
            HealthDot(status: rung.healthStatus, size: 8),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          rung.id,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: selected ? FontWeight.w600 : null,
                          ),
                        ),
                      ),
                      if (rung.model != null) ...[
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${rung.provider ?? ''}/${rung.model}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontSize: 10,
                              color: la.inkQuiet,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (detail != null)
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: healthColor(la, health?.status ?? 'unknown'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (rung.primary)
              _Chip(label: context.l10n.modelsChipPrimary, color: la.accent),
            if (rung.builtin)
              _Chip(label: context.l10n.modelsChipLocal, color: la.inkQuiet),
            if (rung.ladderNext case final next?)
              _Chip(label: '→ $next', color: la.inkQuiet, mono: true),
            if (generative) ...[
              const SizedBox(width: 6),
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                size: 14,
                color: selected ? la.accent : la.inkQuiet,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The row's small fact chip.
final class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color, this.mono = false});

  final String label;
  final Color color;
  final bool mono;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Container(
      height: 16,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          label,
          style: mono
              ? LaTokens.mono(9, color)
              : Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
        ),
      ),
    ),
  );
}

/// The dispatch telemetry section (leg B §2.3d): the newest tool-loop
/// row per actor — rounds, cache-hit %, stalled.
final class _TelemetrySection extends StatelessWidget {
  const _TelemetrySection({required this.world});

  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    final rows = world.telemetryByActor.values.toList()
      ..sort((a, b) => (b.at ?? '').compareTo(a.at ?? ''));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(l10n.modelsTelemetry, style: shellSectionLabel(context)),
        ),
        Container(
          key: const ValueKey('models.telemetry'),
          decoration: BoxDecoration(
            color: context.shellRaised,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (final telemetry in rows.take(8))
                Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: la.rule, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          telemetry.actorId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      Text(
                        '${telemetry.rounds}r',
                        style: LaTokens.mono(10, la.inkQuiet),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        telemetry.cacheHitRate == null
                            ? 'cache —'
                            : 'cache ${(telemetry.cacheHitRate! * 100).round()}%',
                        style: LaTokens.mono(
                          10,
                          telemetry.stalled ? la.caution : la.inkQuiet,
                        ),
                      ),
                      if (telemetry.stalled) ...[
                        const SizedBox(width: 10),
                        Text('stalled', style: LaTokens.mono(10, la.caution)),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The parsed palette re-rendered into the host's OWN wire shape — the
/// key vocabulary the harness parser reads (`parsePaletteConfig`) and
/// serves (`paletteWire`): providers keyed by id with `transport`,
/// `base_url`, `credential_env` and `models[{id, max_tokens,
/// max_output_tokens, reasoning_effort, include_reasoning,
/// capabilities}]`, plus `cast[{id, builtin, provider, model, role,
/// lane, primary}]`. The Wave J candidate builder round-trips through
/// EXACTLY these keys; nothing is invented.
Map<String, Object?> paletteWireDocument(final PaletteConfig palette) =>
    <String, Object?>{
      'providers': <String, Object?>{
        for (final provider in palette.providers.values)
          provider.id: <String, Object?>{
            'transport': provider.transport.wireName,
            if (provider.baseUrl != null) 'base_url': provider.baseUrl,
            if (provider.credentialEnv != null)
              'credential_env': provider.credentialEnv,
            'models': <Object?>[
              for (final model in provider.models)
                <String, Object?>{
                  'id': model.id,
                  if (model.maxTokens != null) 'max_tokens': model.maxTokens,
                  if (model.maxOutputTokens != null)
                    'max_output_tokens': model.maxOutputTokens,
                  if (model.reasoningEffort != null)
                    'reasoning_effort': model.reasoningEffort,
                  if (model.includeReasoning != null)
                    'include_reasoning': model.includeReasoning,
                  if (model.capabilities.isNotEmpty)
                    'capabilities': model.capabilities,
                },
            ],
          },
      },
      'cast': <Object?>[
        for (final entry in palette.cast)
          <String, Object?>{
            'id': entry.id,
            if (entry.builtin) 'builtin': true,
            if (entry.provider != null) 'provider': entry.provider,
            if (entry.model != null) 'model': entry.model,
            'role': entry.role,
            if (entry.lane != null) 'lane': entry.lane,
            if (entry.primary) 'primary': true,
          },
      ],
    };

/// The palette editor (G7 first step): a JSON view over the REAL
/// `model_palette` document — Zed's settings grammar: edit the source of
/// truth, validate with the owner parser, save with a `.bak`, then
/// offer the supervised restart. Refusals render verbatim; nothing is
/// written until validation passes.
final class PaletteEditorDialog extends StatefulWidget {
  const PaletteEditorDialog({required this.world, super.key});

  final WorldStateService world;

  @override
  State<PaletteEditorDialog> createState() => _PaletteEditorDialogState();
}

final class _PaletteEditorDialogState extends State<PaletteEditorDialog> {
  late final TextEditingController _controller = TextEditingController(
    text: _initialDocument(),
  );
  String? _verdict;
  bool _verdictOk = false;
  bool _saved = false;

  String _initialDocument() {
    final path = widget.world.paletteConfigPath;
    if (path == null) return _prettyPlaceholder();
    try {
      final decoded = jsonDecode(File(path).readAsStringSync());
      if (decoded is Map && decoded['model_palette'] != null) {
        return const JsonEncoder.withIndent(
          '  ',
        ).convert(decoded['model_palette']);
      }
    } on Object {
      // An unreadable file starts from the placeholder — the editor
      // never fabricates the current declaration.
    }
    return _prettyPlaceholder();
  }

  String _prettyPlaceholder() {
    final palette = widget.world.palette;
    if (palette == null) {
      return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
        'providers': <String, Object?>{},
        'cast': <Object?>[],
      });
    }
    // Re-render the parsed declaration so the editor opens on the
    // live shape even when the raw file read failed.
    return const JsonEncoder.withIndent('  ').convert(
      paletteWireDocument(palette),
    );
  }

  void _validate() {
    final refusal = _validateOnly();
    setState(() {
      _verdict = refusal ?? 'palette ok';
      _verdictOk = refusal == null;
    });
  }

  String? _validateOnly() {
    Object? decoded;
    try {
      decoded = jsonDecode(_controller.text);
    } on FormatException catch (error) {
      return 'json_malformed: ${error.message}';
    }
    // Harness-grade validation: the owner parser's named refusals,
    // verbatim — the same codes the daemon boot would answer with.
    try {
      parsePaletteConfig(decoded);
    } on PaletteConfigError catch (error) {
      return '$error';
    }
    return null;
  }

  void _save() {
    final refusal = widget.world.savePaletteJson(_controller.text);
    setState(() {
      _verdict = refusal ?? 'saved';
      _verdictOk = refusal == null;
      _saved = refusal == null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final la = context.la;
    return Dialog(
      key: const ValueKey('models.editor'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaTokens.radiusFloating),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.modelsEditPalette,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (widget.world.paletteConfigPath case final path?)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(path, style: LaTokens.mono(10, la.inkQuiet)),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: la.canvas,
                    borderRadius: BorderRadius.circular(ShellTokens.radius),
                    border: Border.all(color: la.rule),
                  ),
                  child: TextField(
                    key: const ValueKey('models.editor.field'),
                    controller: _controller,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: LaTokens.mono(12, la.ink),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ),
              if (_verdict != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _verdict!,
                    key: const ValueKey('models.editor.verdict'),
                    style: LaTokens.mono(
                      11,
                      _verdictOk ? la.accent : la.danger,
                    ),
                  ),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _DialogButton(
                    keyName: 'models.editor.validate',
                    label: l10n.modelsValidate,
                    onTap: _validate,
                  ),
                  const SizedBox(width: 8),
                  _DialogButton(
                    keyName: 'models.editor.save',
                    label: l10n.modelsSave,
                    onTap: _save,
                  ),
                  const Spacer(),
                  if (_saved)
                    _DialogButton(
                      keyName: 'models.editor.restart',
                      label: l10n.edgeRestartWorld,
                      onTap: () async {
                        await widget.world.restartWorld();
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                  const SizedBox(width: 8),
                  _DialogButton(
                    keyName: 'models.editor.close',
                    label: l10n.modelsClose,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The editor dialog's small button.
final class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.keyName,
    required this.label,
    required this.onTap,
  });

  final String keyName;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Semantics(
    button: true,
    label: keyName,
    hint: label,
    child: TextButton(
      key: ValueKey(keyName),
      onPressed: onTap,
      child: Text(label),
    ),
  );
}

// ---- Wave J — the provider lanes ----

/// Wave J strings — EN literals pending their l10n keys (the arb and
/// the four mirrors are a separate lane; the widget keys are the

/// The provider's merged health: the WORST status among the cast rows
/// that ride it (the palette_health.json verdicts WorldStateService
/// already merged onto the rungs); `unknown` when no cast row
/// references the provider — an honest absence, never an invented
/// health.
String _providerHealth(final WorldStateService world, final String id) {
  const severity = <String>['ok', 'unknown', 'not_downloaded', 'failed'];
  var worst = -1;
  for (final rung in world.rungs) {
    if (rung.provider != id) continue;
    final rank = severity.indexOf(rung.healthStatus);
    if (rank > worst) worst = rank;
  }
  return worst < 0 ? 'unknown' : severity[worst];
}

/// Wave J — the provider READ lane (FREE, like every read model): one
/// row per declared provider of the live parsed palette — id,
/// transport/api family, endpoint, the credential env NAME (never a
/// value — the config names the variable, the surface resolves
/// nothing), the models count and the merged health. Expanding a
/// provider shows its models (id + context tier when declared) and the
/// read-only cast chips that reference it. The Pro-gated edit
/// affordance opens [ProviderEditorDialog].
final class _ProviderSection extends StatefulWidget {
  const _ProviderSection({required this.world, required this.service});

  final WorldStateService world;
  final RealmChatService? service;

  @override
  State<_ProviderSection> createState() => _ProviderSectionState();
}

final class _ProviderSectionState extends State<_ProviderSection> {
  final Set<String> _expanded = <String>{};

  void _toggle(final String id) => setState(() {
    if (!_expanded.remove(id)) _expanded.add(id);
  });

  @override
  Widget build(final BuildContext context) {
    final palette = widget.world.palette;
    if (palette == null) return const SizedBox.shrink();
    final providers = palette.providers.values.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.modelsProviders,
                  style: shellSectionLabel(context),
                ),
              ),
              // Plan v5 4b — the tier gate sits on the EDIT affordance
              // only; the provider read model above stays FREE. An
              // unmounted entitlement layer fails open (hermetic
              // surfaces are never locked out).
              ProGate(
                feature: TierFeature.paletteEditor,
                child: _HeaderButton(
                  keyName: 'models.editProviders',
                  label: context.l10n.modelsEditProviders,
                  onTap: () => unawaited(
                    showDialog<void>(
                      context: context,
                      builder: (final dialogContext) => ProviderEditorDialog(
                        world: widget.world,
                        chat: widget.service,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          key: const ValueKey('models.providers'),
          decoration: BoxDecoration(
            color: context.shellRaised,
            borderRadius: BorderRadius.circular(ShellTokens.radius),
          ),
          clipBehavior: Clip.antiAlias,
          child: providers.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    context.l10n.modelsNoProviders,
                    key: const ValueKey('models.providers.empty'),
                  ),
                )
              : Column(
                  children: [
                    for (final provider in providers) ...[
                      _ProviderRow(
                        provider: provider,
                        world: widget.world,
                        expanded: _expanded.contains(provider.id),
                        onToggle: () => _toggle(provider.id),
                      ),
                      if (_expanded.contains(provider.id))
                        _ProviderDetail(
                          provider: provider,
                          world: widget.world,
                        ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

/// One provider row: health dot · id · endpoint · transport chip ·
/// models count · env NAME chip. The secret law: the credential rides
/// as the environment VARIABLE NAME only — a value is never read,
/// never rendered, never resolved here.
final class _ProviderRow extends StatelessWidget {
  const _ProviderRow({
    required this.provider,
    required this.world,
    required this.expanded,
    required this.onToggle,
  });

  final PaletteProviderConfig provider;
  final WorldStateService world;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final theme = Theme.of(context);
    return Semantics(
      key: ValueKey('models.provider.${provider.id}'),
      button: true,
      expanded: expanded,
      label: 'models.provider.${provider.id}',
      hint: provider.id,
      child: ShellRow(
        height: 44,
        selected: expanded,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: onToggle,
        child: Row(
          children: [
            HealthDot(
              status: _providerHealth(world, provider.id),
              size: 8,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    provider.id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium,
                  ),
                  if (provider.baseUrl case final url?)
                    Text(
                      url,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        color: la.inkQuiet,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Chip(
              label: provider.transport.wireName,
              color: la.inkQuiet,
              mono: true,
            ),
            _Chip(
              label: '${provider.models.length} ${context.l10n.modelsCountSuffix}',
              color: la.inkQuiet,
            ),
            if (provider.credentialEnv case final env?)
              _Chip(label: env, color: la.accent, mono: true),
            const SizedBox(width: 6),
            Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              size: 14,
              color: la.inkQuiet,
            ),
          ],
        ),
      ),
    );
  }
}

/// The expanded provider: its declared models (id + context tier when
/// declared) and the READ-ONLY cast chips that reference it.
final class _ProviderDetail extends StatelessWidget {
  const _ProviderDetail({required this.provider, required this.world});

  final PaletteProviderConfig provider;
  final WorldStateService world;

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final castRefs = <String>[
      for (final entry
          in world.palette?.cast ?? const <PaletteCastEntryConfig>[])
        if (entry.provider == provider.id) entry.id,
    ];
    return Container(
      key: ValueKey('models.provider.${provider.id}.detail'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(29, 2, 12, 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: context.shellHairline, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final model in provider.models)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                key: ValueKey(
                  'models.model.${provider.id}.${model.id}',
                ),
                children: [
                  Flexible(
                    child: Text(
                      model.id,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaTokens.mono(11, la.inkMuted),
                    ),
                  ),
                  if (model.maxTokens case final tier?) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${context.l10n.modelsContextTier} $tier',
                      style: LaTokens.mono(10, la.inkQuiet),
                    ),
                  ],
                ],
              ),
            ),
          if (provider.models.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                context.l10n.modelsNoModels,
                style: LaTokens.mono(10, la.inkQuiet),
              ),
            ),
          if (castRefs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(
                runSpacing: 4,
                children: [
                  for (final castId in castRefs)
                    KeyedSubtree(
                      key: ValueKey(
                        'models.provider.${provider.id}.cast.$castId',
                      ),
                      child: _Chip(
                        label: castId,
                        color: la.inkQuiet,
                        mono: true,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// The transport vocabulary is CLOSED (the host parser's law): the
/// editor form cycles these wire names, never a free string.
const List<String> _transportWireNames = <String>[
  'openrouter',
  'openai_compatible',
  'system_one',
];

/// A deep copy of a wire document (JSON-safe values by construction —
/// the round-trip IS the copy law; no shared mutable state between the
/// live palette and the candidate).
Map<String, Object?> _deepCopyPalette(final Map<String, Object?> doc) =>
    jsonDecode(jsonEncode(doc))! as Map<String, Object?>;

/// The form's four modes (one panel, one controller set — the dialog's
/// State owns them all; the test-lane law).
enum _FormKind { addProvider, editProvider, addModel, renameModel }

/// The open form's immutable facts (which mode, which provider/model).
final class _ProviderFormState {
  const _ProviderFormState({
    required this.kind,
    this.providerId,
    this.modelId,
    this.transport = 'openrouter',
  });

  final _FormKind kind;
  final String? providerId;
  final String? modelId;
  final String transport;

  _ProviderFormState withTransport(final String transport) =>
      _ProviderFormState(
        kind: kind,
        providerId: providerId,
        modelId: modelId,
        transport: transport,
      );
}

/// Wave J — the structured provider EDITOR (the Pro-gated affordance
/// opens it). The candidate is a DEEP COPY of the parsed live palette
/// kept IN MEMORY in the host's own wire shape
/// ([paletteWireDocument]); nothing touches the file until Apply lands.
/// The dirty bar's Propose validates through the participation plane's
/// revision lane ([RealmChatService.proposePalette] — the harness's own
/// parser is the only gate), the receipt panel renders the host receipt
/// (ok + beforeSha256, or the PaletteConfigError VERBATIM), and Apply
/// rides the OWNER-only verb — a non-owner seat renders the refusal's
/// recovery text VERBATIM, never a bare error. Cancel reverts to live.
final class ProviderEditorDialog extends StatefulWidget {
  const ProviderEditorDialog({required this.world, this.chat, super.key});

  final WorldStateService world;

  /// The palette verbs' seat; null degrades honestly (the Propose/Apply
  /// lane names the missing seat instead of guessing).
  final RealmChatService? chat;

  /// Debug seam (the house debugInstances pattern): the newest
  /// candidate document, published on init and on every mutation, so
  /// tests assert the CANDIDATE MAP DIFF — never UI pixels.
  @visibleForTesting
  static Map<String, Object?>? debugLastCandidate;

  @override
  State<ProviderEditorDialog> createState() => _ProviderEditorDialogState();
}

final class _ProviderEditorDialogState extends State<ProviderEditorDialog> {
  late Map<String, Object?> _live = _liveWire();
  late Map<String, Object?> _candidate = _deepCopyPalette(_live);

  _ProviderFormState? _form;
  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _baseUrlCtrl = TextEditingController();
  final TextEditingController _credCtrl = TextEditingController();

  Map<String, Object?>? _receipt;
  Map<String, Object?>? _applyOutcome;
  String? _localRefusal;
  bool _busy = false;

  Map<String, Object?> _liveWire() {
    final palette = widget.world.palette;
    if (palette != null) return paletteWireDocument(palette);
    return <String, Object?>{
      'providers': <String, Object?>{},
      'cast': <Object?>[],
    };
  }

  @override
  void initState() {
    super.initState();
    ProviderEditorDialog.debugLastCandidate = _deepCopyPalette(_candidate);
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _baseUrlCtrl.dispose();
    _credCtrl.dispose();
    super.dispose();
  }

  /// The candidate's providers section, bound into the document on
  /// first touch (the wire shape's own key — never an invented one).
  Map<String, Object?> get _providers {
    var raw = _candidate['providers'];
    if (raw is! Map) {
      raw = <String, Object?>{};
      _candidate['providers'] = raw;
    }
    return raw.cast<String, Object?>();
  }

  List<Object?> get _cast {
    var raw = _candidate['cast'];
    if (raw is! List) {
      raw = <Object?>[];
      _candidate['cast'] = raw;
    }
    return raw;
  }

  /// The cast rows referencing a provider (the immutability/removal
  /// law's evidence — a refusal NAMES them).
  List<String> _castRefs(final String providerId) => <String>[
    for (final entry in _cast)
      if (entry is Map && entry['provider'] == providerId) '${entry['id']}',
  ];

  List<String> _castModelRefs(
    final String providerId,
    final String modelId,
  ) => <String>[
    for (final entry in _cast)
      if (entry is Map &&
          entry['provider'] == providerId &&
          entry['model'] == modelId)
        '${entry['id']}',
  ];

  List<Map<String, Object?>> _modelsOf(final String providerId) {
    final raw = _providers[providerId];
    final provider = raw is Map ? raw : const <String, Object?>{};
    return <Map<String, Object?>>[
      for (final model in (provider['models'] as List? ?? const <Object?>[]))
        if (model is Map) Map<String, Object?>.from(model),
    ];
  }

  /// One candidate mutation landed: a receipt validated the PREVIOUS
  /// bytes, so it is stale by law; the test seam re-publishes.
  void _touch() {
    _receipt = null;
    _applyOutcome = null;
    ProviderEditorDialog.debugLastCandidate = _deepCopyPalette(_candidate);
  }

  bool get _dirty =>
      paletteFingerprint(_candidate) != paletteFingerprint(_live);

  bool get _receiptOk => _receipt?['ok'] == true;

  // ---- the edit verbs (in-memory candidate surgery) ----

  void _openAddProvider() {
    setState(() {
      _form = const _ProviderFormState(kind: _FormKind.addProvider);
      _localRefusal = null;
      _idCtrl.text = '';
      _baseUrlCtrl.text = '';
      _credCtrl.text = '';
    });
  }

  void _openEditProvider(final String id) {
    final raw = _providers[id];
    final provider = raw is Map ? raw : const <String, Object?>{};
    setState(() {
      _form = _ProviderFormState(
        kind: _FormKind.editProvider,
        providerId: id,
        transport: '${provider['transport'] ?? _transportWireNames.first}',
      );
      _localRefusal = null;
      _idCtrl.text = id;
      _baseUrlCtrl.text = '${provider['base_url'] ?? ''}';
      _credCtrl.text = '${provider['credential_env'] ?? ''}';
    });
  }

  void _openAddModel(final String providerId) {
    setState(() {
      _form = _ProviderFormState(
        kind: _FormKind.addModel,
        providerId: providerId,
      );
      _localRefusal = null;
      _idCtrl.text = '';
    });
  }

  void _openRenameModel(final String providerId, final String modelId) {
    setState(() {
      _form = _ProviderFormState(
        kind: _FormKind.renameModel,
        providerId: providerId,
        modelId: modelId,
      );
      _localRefusal = null;
      _idCtrl.text = modelId;
    });
  }

  void _closeForm() => setState(() => _form = null);

  void _refuse(final String text) =>
      setState(() => _localRefusal = text);

  void _confirmForm() {
    final form = _form;
    if (form == null) return;
    final id = _idCtrl.text.trim();
    switch (form.kind) {
      case _FormKind.addProvider:
        if (id.isEmpty) return _refuse(context.l10n.modelsRefusalEmptyId);
        if (_providers.containsKey(id)) {
          return _refuse('${context.l10n.modelsRefusalDuplicateProvider} "$id"');
        }
        _providers[id] = <String, Object?>{
          'transport': form.transport,
          if (_baseUrlCtrl.text.trim().isNotEmpty)
            'base_url': _baseUrlCtrl.text.trim(),
          if (_credCtrl.text.trim().isNotEmpty)
            'credential_env': _credCtrl.text.trim(),
          'models': <Object?>[],
        };
      case _FormKind.editProvider:
        final oldId = form.providerId!;
        final refs = _castRefs(oldId);
        if (id != oldId && refs.isNotEmpty) {
          // The honest refusal: a referenced provider id is IMMUTABLE,
          // naming the referencing cast rows.
          return _refuse(
            '${context.l10n.modelsRefusalIdImmutable} ${refs.join(', ')}',
          );
        }
        final raw = _providers[oldId];
        final map = Map<String, Object?>.from(raw is Map ? raw : const {});
        map['transport'] = form.transport;
        final baseUrl = _baseUrlCtrl.text.trim();
        if (baseUrl.isEmpty) {
          map.remove('base_url');
        } else {
          map['base_url'] = baseUrl;
        }
        final cred = _credCtrl.text.trim();
        if (cred.isEmpty) {
          map.remove('credential_env');
        } else {
          map['credential_env'] = cred;
        }
        if (id != oldId) _providers.remove(oldId);
        _providers[id] = map;
      case _FormKind.addModel:
        final providerId = form.providerId!;
        if (id.isEmpty) return _refuse(context.l10n.modelsRefusalEmptyId);
        final models = _modelsOf(providerId);
        if (models.any((final model) => model['id'] == id)) {
          return _refuse('${context.l10n.modelsRefusalDuplicateModel} "$id"');
        }
        models.add(<String, Object?>{'id': id});
        _writeModels(providerId, models);
      case _FormKind.renameModel:
        final providerId = form.providerId!;
        final oldModel = form.modelId!;
        if (id.isEmpty) return _refuse(context.l10n.modelsRefusalEmptyId);
        final models = _modelsOf(providerId);
        if (oldModel != id &&
            models.any((final model) => model['id'] == id)) {
          return _refuse('${context.l10n.modelsRefusalDuplicateModel} "$id"');
        }
        for (var i = 0; i < models.length; i++) {
          if (models[i]['id'] == oldModel) models[i]['id'] = id;
        }
        _writeModels(providerId, models);
        // The cast rows that rode the old model id FOLLOW the rename —
        // the candidate stays internally consistent, and the propose
        // receipt's diff makes the move visible.
        if (oldModel != id) {
          for (final entry in _cast) {
            if (entry is Map &&
                entry['provider'] == providerId &&
                entry['model'] == oldModel) {
              entry['model'] = id;
            }
          }
        }
    }
    setState(() {
      _form = null;
      _localRefusal = null;
      _touch();
    });
  }

  void _writeModels(
    final String providerId,
    final List<Map<String, Object?>> models,
  ) {
    final raw = _providers[providerId];
    final provider = Map<String, Object?>.from(raw is Map ? raw : const {});
    provider['models'] = <Object?>[...models];
    _providers[providerId] = provider;
  }

  void _removeProvider(final String id) {
    final refs = _castRefs(id);
    if (refs.isNotEmpty) {
      // Refuse while cast rows reference it, NAMING them.
      return _refuse('${context.l10n.modelsRefusalProviderInUse} ${refs.join(', ')}');
    }
    setState(() {
      _providers.remove(id);
      _localRefusal = null;
      _touch();
    });
  }

  void _removeModel(final String providerId, final String modelId) {
    final refs = _castModelRefs(providerId, modelId);
    if (refs.isNotEmpty) {
      return _refuse('${context.l10n.modelsRefusalModelInUse} ${refs.join(', ')}');
    }
    setState(() {
      _writeModels(providerId, [
        for (final model in _modelsOf(providerId))
          if (model['id'] != modelId) model,
      ]);
      _localRefusal = null;
      _touch();
    });
  }

  // ---- the propose → receipt → apply lane (the host's verbs) ----

  Future<void> _propose() async {
    final chat = widget.chat;
    if (chat == null) return _refuse(context.l10n.modelsRefusalNoSeat);
    if (_busy) return;
    setState(() {
      _busy = true;
      _localRefusal = null;
      _applyOutcome = null;
    });
    final receipt = await chat.proposePalette(_deepCopyPalette(_candidate));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _receipt = receipt;
    });
  }

  Future<void> _apply() async {
    final chat = widget.chat;
    if (chat == null) return _refuse(context.l10n.modelsRefusalNoSeat);
    if (_busy || !_receiptOk) return;
    setState(() {
      _busy = true;
      _localRefusal = null;
    });
    final before = _receipt?['beforeSha256'];
    final outcome = await chat.applyPalette(
      _deepCopyPalette(_candidate),
      expectedBeforeSha256: before is String ? before : null,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _applyOutcome = outcome;
      if (outcome['ok'] == true) {
        // The apply consumed the receipt; the candidate is now the live
        // declaration (the read model re-reads the landed file).
        _receipt = null;
        _live = _deepCopyPalette(_candidate);
        _touch();
        unawaited(widget.world.refresh());
      }
    });
  }

  /// Cancel reverts to live — the candidate, the receipt and every
  /// note drop; the dialog stays open on the truth.
  void _revert() {
    setState(() {
      _candidate = _deepCopyPalette(_live);
      _receipt = null;
      _applyOutcome = null;
      _localRefusal = null;
      _form = null;
      _touch();
    });
  }

  /// One honest line out of a host envelope: the bounce code plus the
  /// refusal — a string message VERBATIM, or a detail map's `recovery`
  /// text VERBATIM (the owner refusal's recovery is the helpful half;
  /// a bare error is never rendered).
  static String envelopeLine(final Map<String, Object?> envelope) {
    final bounce = '${envelope['bounce'] ?? 'refused'}';
    final refusal = envelope['refusal'];
    if (refusal is String && refusal.isNotEmpty) return '$bounce: $refusal';
    if (refusal is Map) {
      final recovery = refusal['recovery'];
      if (recovery is String && recovery.isNotEmpty) {
        return '$bounce: $recovery';
      }
      return '$bounce: $refusal';
    }
    return bounce;
  }

  String _receiptText(final Map<String, Object?> receipt) {
    final diff = receipt['diff'];
    final added = diff is Map
        ? (diff['added'] as List? ?? const <Object?>[])
        : const <Object?>[];
    final removed = diff is Map
        ? (diff['removed'] as List? ?? const <Object?>[])
        : const <Object?>[];
    final buffer = StringBuffer(
      'ok · beforeSha256 ${receipt['beforeSha256'] ?? 'none'}',
    );
    if (added.isNotEmpty) buffer.write('\n+ ${added.join(', ')}');
    if (removed.isNotEmpty) buffer.write('\n- ${removed.join(', ')}');
    for (final warning in (receipt['warnings'] as List? ?? const <Object?>[])) {
      if (warning is Map) {
        buffer.write('\n${warning['code']}: ${warning['detail'] ?? ''}');
      }
    }
    if (receipt['restartRequired'] == true) {
      buffer.write('\n${context.l10n.modelsRestartRequired}');
    }
    return buffer.toString();
  }

  String _applyText(final Map<String, Object?> outcome) =>
      'applied · ${outcome['revisionId']} · ${context.l10n.modelsRestartRequired}';

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
    final theme = Theme.of(context);
    return Dialog(
      key: const ValueKey('models.providerEditor'),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(LaTokens.radiusFloating),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.modelsEditProviders,
                style: theme.textTheme.titleMedium,
              ),
              if (widget.world.paletteConfigPath case final path?)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(path, style: LaTokens.mono(10, la.inkQuiet)),
                ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    for (final id in _providers.keys.toList())
                      _editCard(context, id),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _DialogButton(
                        keyName: 'models.provider.add',
                        label: context.l10n.modelsAddProvider,
                        onTap: _openAddProvider,
                      ),
                    ),
                    if (_form != null) _formPanel(context, _form!),
                    if (_localRefusal case final refusal?)
                      _EditorNote(
                        keyName: 'models.refusal.local',
                        text: refusal,
                        color: la.caution,
                      ),
                    if (_receipt case final receipt?)
                      _EditorNote(
                        keyName: receipt['ok'] == true
                            ? 'models.receipt.ok'
                            : 'models.receipt.refusal',
                        text: receipt['ok'] == true
                            ? _receiptText(receipt)
                            : envelopeLine(receipt),
                        color: receipt['ok'] == true ? la.accent : la.danger,
                      ),
                    if (_applyOutcome case final outcome?)
                      _EditorNote(
                        keyName: outcome['ok'] == true
                            ? 'models.apply.outcome'
                            : outcome['bounce'] == 'palette_apply_not_owner'
                            ? 'models.refusal.recovery'
                            : 'models.apply.outcome',
                        text: outcome['ok'] == true
                            ? _applyText(outcome)
                            : envelopeLine(outcome),
                        color: outcome['ok'] == true ? la.accent : la.danger,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Row(
                key: const ValueKey('models.dirtyBar'),
                children: [
                  Expanded(
                    child: Text(
                      _dirty ? context.l10n.modelsUnsavedChanges : context.l10n.modelsInSync,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaTokens.mono(
                        10,
                        _dirty ? la.caution : la.inkQuiet,
                      ),
                    ),
                  ),
                  if (_dirty) ...[
                    _DialogButton(
                      keyName: 'models.propose',
                      label: context.l10n.modelsPropose,
                      onTap: _busy ? () {} : () => unawaited(_propose()),
                    ),
                    const SizedBox(width: 8),
                    _DialogButton(
                      keyName: 'models.cancel',
                      label: context.l10n.modelsCancel,
                      onTap: _revert,
                    ),
                  ],
                  if (_receiptOk) ...[
                    const SizedBox(width: 8),
                    _DialogButton(
                      keyName: 'models.apply',
                      label: context.l10n.modelsApply,
                      onTap: _busy ? () {} : () => unawaited(_apply()),
                    ),
                  ],
                  const SizedBox(width: 8),
                  _DialogButton(
                    keyName: 'models.providerEditor.close',
                    label: context.l10n.modelsClose,
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// One provider's edit card: facts, field verbs, its model rows with
  /// rename/remove, the add-model verb, and the read-only cast chips.
  Widget _editCard(final BuildContext context, final String id) {
    final la = context.la;
    final raw = _providers[id];
    final provider = raw is Map ? raw : const <String, Object?>{};
    final models = _modelsOf(id);
    final refs = _castRefs(id);
    return Container(
      key: ValueKey('models.provider.$id.card'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: BoxDecoration(
        color: la.canvas,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
        border: Border.all(color: la.rule),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(id, style: LaTokens.mono(12, la.ink)),
              ),
              _Chip(
                label: '${provider['transport'] ?? ''}',
                color: la.inkQuiet,
                mono: true,
              ),
              const SizedBox(width: 6),
              _DialogButton(
                keyName: 'models.provider.$id.edit',
                label: context.l10n.modelsEditAction,
                onTap: () => _openEditProvider(id),
              ),
              _DialogButton(
                keyName: 'models.provider.$id.remove',
                label: context.l10n.modelsRemoveAction,
                onTap: () => _removeProvider(id),
              ),
            ],
          ),
          if (provider['base_url'] case final url?)
            Text('$url', style: LaTokens.mono(10, la.inkQuiet)),
          if (provider['credential_env'] case final env?)
            Text(
              '${context.l10n.modelsEnvPrefix}$env',
              style: LaTokens.mono(10, la.inkQuiet),
            ),
          for (final model in models)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Row(
                key: ValueKey('models.model.$id.${model['id']}'),
                children: [
                  Expanded(
                    child: Text(
                      '${model['id']}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LaTokens.mono(11, la.inkMuted),
                    ),
                  ),
                  if (model['max_tokens'] case final tier?)
                    Text(
                      '${context.l10n.modelsContextTier} $tier',
                      style: LaTokens.mono(10, la.inkQuiet),
                    ),
                  _DialogButton(
                    keyName: 'models.model.$id.${model['id']}.rename',
                    label: context.l10n.modelsRenameAction,
                    onTap: () => _openRenameModel(id, '${model['id']}'),
                  ),
                  _DialogButton(
                    keyName: 'models.model.$id.${model['id']}.remove',
                    label: context.l10n.modelsRemoveAction,
                    onTap: () => _removeModel(id, '${model['id']}'),
                  ),
                ],
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: _DialogButton(
              keyName: 'models.model.$id.add',
              label: context.l10n.modelsAddModel,
              onTap: () => _openAddModel(id),
            ),
          ),
          if (refs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Wrap(
                runSpacing: 4,
                children: [
                  for (final castId in refs)
                    KeyedSubtree(
                      key: ValueKey('models.provider.$id.cast.$castId'),
                      child: _Chip(
                        label: castId,
                        color: la.inkQuiet,
                        mono: true,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// The one form panel (add/edit provider, add/rename model). The
  /// State owns every controller; a referenced provider's id renders
  /// READ-ONLY with the immutability refusal naming the cast rows.
  Widget _formPanel(final BuildContext context, final _ProviderFormState form) {
    final la = context.la;
    final providerFields =
        form.kind == _FormKind.addProvider ||
        form.kind == _FormKind.editProvider;
    final idLocked =
        form.kind == _FormKind.editProvider &&
        _castRefs(form.providerId!).isNotEmpty;
    return Container(
      key: const ValueKey('models.form'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: la.canvas,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
        border: Border.all(color: la.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_formTitle(form), style: LaTokens.mono(11, la.inkMuted)),
          const SizedBox(height: 8),
          _formField(
            keyName: 'models.form.id',
            hint: providerFields ? context.l10n.modelsProviderIdHint : context.l10n.modelsModelIdHint,
            controller: _idCtrl,
            readOnly: idLocked,
          ),
          if (idLocked)
            _EditorNote(
              keyName: 'models.refusal.providerIdImmutable',
              text: '${context.l10n.modelsRefusalIdImmutable} '
                  '${_castRefs(form.providerId!).join(', ')}',
              color: la.caution,
            ),
          if (providerFields) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  context.l10n.modelsTransportLabel,
                  style: LaTokens.mono(10, la.inkQuiet),
                ),
                const SizedBox(width: 8),
                _DialogButton(
                  keyName: 'models.form.transport',
                  label: form.transport,
                  onTap: () {
                    final index = _transportWireNames.indexOf(form.transport);
                    final next = _transportWireNames[
                        (index + 1) % _transportWireNames.length];
                    setState(() => _form = form.withTransport(next));
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            _formField(
              keyName: 'models.form.baseUrl',
              hint: context.l10n.modelsBaseUrlHint,
              controller: _baseUrlCtrl,
            ),
            const SizedBox(height: 8),
            _formField(
              keyName: 'models.form.credentialEnv',
              hint: context.l10n.modelsCredentialEnvHint,
              controller: _credCtrl,
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              _DialogButton(
                keyName: 'models.form.confirm',
                label: context.l10n.modelsConfirm,
                onTap: _confirmForm,
              ),
              const SizedBox(width: 8),
              _DialogButton(
                keyName: 'models.form.cancel',
                label: context.l10n.modelsCancel,
                onTap: _closeForm,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formTitle(final _ProviderFormState form) => switch (form.kind) {
    _FormKind.addProvider => context.l10n.modelsAddProvider,
    _FormKind.editProvider => '${context.l10n.modelsEditProvider} ${form.providerId}',
    _FormKind.addModel => '${context.l10n.modelsAddModel} · ${form.providerId}',
    _FormKind.renameModel => '${context.l10n.modelsRenameModel} ${form.modelId}',
  };

  Widget _formField({
    required final String keyName,
    required final String hint,
    required final TextEditingController controller,
    final bool readOnly = false,
  }) {
    final la = context.la;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: la.canvas,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
        border: Border.all(color: la.rule),
      ),
      child: TextField(
        key: ValueKey(keyName),
        controller: controller,
        readOnly: readOnly,
        style: LaTokens.mono(12, readOnly ? la.inkQuiet : la.ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: LaTokens.mono(11, la.inkQuiet),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ),
        ),
      ),
    );
  }
}

/// The dialog's honest note line (refusal, receipt, outcome): mono,
/// colored by kind, the host's text rendered VERBATIM.
final class _EditorNote extends StatelessWidget {
  const _EditorNote({
    required this.keyName,
    required this.text,
    required this.color,
  });

  final String keyName;
  final String text;
  final Color color;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Text(
      text,
      key: ValueKey(keyName),
      style: LaTokens.mono(11, color),
    ),
  );
}
