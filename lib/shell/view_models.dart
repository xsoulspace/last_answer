/// Phase 1d — the Models surface (docs/design/
/// ecsai-modelscope-first-priority-2026-11-05.md G5/G7 first step): the
/// chrome that merges the read models that already existed — every
/// declared palette rung with its health verdict, the escalation
/// ladder, the daemon's arm controls, the per-actor dispatch telemetry
/// (cache-hit %, rounds, stalls) — and the palette EDITOR over the real
/// config document, validated with the harness's own parser.
///
/// Dynamic by law (the owner's Zed rule): nothing here names a model.
/// The rungs are whatever the discovered `.xsoulspace/config.json`
/// declares; the editor edits that document (a JSON view with named
/// refusals — Zed's own settings grammar); health comes from the
/// daemon's file. A config change is a Save + Restart world away, with
/// no Dart edit and no shell.
library;

import 'dart:convert';


import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot, healthColor;
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show PaletteConfigError, parsePaletteConfig;

/// The Models surface: rungs + daemon controls + editor + telemetry.
final class ModelsView extends StatelessWidget {
  const ModelsView({required this.world, super.key});

  final WorldStateService world;

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
        _HeaderButton(
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
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'providers': {
        for (final provider in palette.providers.values)
          provider.id: <String, Object?>{
            'transport': provider.transport.wireName,
            if (provider.baseUrl != null) 'base_url': provider.baseUrl,
            if (provider.credentialEnv != null)
              'credential_env': provider.credentialEnv,
            'models': [
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
      'cast': [
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
    });
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
