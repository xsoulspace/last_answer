/// Models refactor (2026-11-14) — the CATALOG lens: the hierarchy the
/// owner asked for, as ONE nested table (the spreadsheet law): a row
/// per provider, its models indented one level under it, verbs on the
/// row that owns them. The same tree reads on a phone (compact rows:
/// identity + count + chevron; the chips move into the expanded block)
/// and on desktop (full chip run inline).
///
/// The edit lane is the table itself — no modal, no parallel card list:
/// a verb row opens ONE inline form panel under the table (provider
/// fields, or the FULL per-model field set the harness parser reads),
/// and the JSON toggle swaps the tree for the raw document view (the
/// Zed rule: named parser refusals, never a silent half-parse). Every
/// mutation lands on the shared [PaletteCandidateModel]; the dirty bar
/// (propose → receipt → apply) rides at the view's bottom edge.
library;

import 'dart:convert';

import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot;

/// The transport vocabulary is CLOSED (the host parser's law): the
/// form cycles these wire names, never a free string.
const List<String> kTransportWireNames = <String>[
  'openrouter',
  'openai_compatible',
  'system_one',
];

/// The capability keys the form offers as toggles. A declared key
/// outside this set rides the edit as an extra active toggle, so an
/// edit never silently drops a declaration.
const List<String> kCommonCapabilities = <String>[
  'tools',
  'images',
  'parallel_tool_calls',
  'prompt_cache_key',
  'chat_completions',
];

/// The merged health of a provider: the worst verdict among the cast
/// rows that ride it (the read model's own severity order); `unknown`
/// when no cast row references the provider — an honest absence, never
/// an invented health.
String providerHealth(final WorldStateService world, final String id) {
  const severity = <String>['ok', 'unknown', 'not_downloaded', 'failed'];
  var worst = -1;
  for (final rung in world.rungs) {
    if (rung.provider != id) continue;
    final rank = severity.indexOf(rung.healthStatus);
    if (rank > worst) worst = rank;
  }
  return worst < 0 ? 'unknown' : severity[worst];
}

enum _FormKind { provider, model }

/// The open form's immutable facts (which kind, which provider/model).
final class _FormState {
  const _FormState({
    required this.kind,
    this.providerId,
    this.modelId,
    this.transport = 'openrouter',
  });

  final _FormKind kind;
  final String? providerId;
  final String? modelId;
  final String transport;

  _FormState withTransport(final String transport) => _FormState(
    kind: kind,
    providerId: providerId,
    modelId: modelId,
    transport: transport,
  );
}

final class CatalogLens extends StatefulWidget {
  const CatalogLens({
    required this.model,
    required this.world,
    required this.compact,
    super.key,
  });

  final PaletteCandidateModel model;
  final WorldStateService world;
  final bool compact;

  @override
  State<CatalogLens> createState() => _CatalogLensState();
}

final class _CatalogLensState extends State<CatalogLens> {
  final Set<String> _expanded = <String>{};
  _FormState? _form;
  bool _jsonMode = false;

  final TextEditingController _idCtrl = TextEditingController();
  final TextEditingController _baseUrlCtrl = TextEditingController();
  final TextEditingController _credCtrl = TextEditingController();
  final TextEditingController _maxTokensCtrl = TextEditingController();
  final TextEditingController _maxOutCtrl = TextEditingController();
  final TextEditingController _jsonCtrl = TextEditingController();
  bool _includeReasoning = false;

  /// The picked reasoning-effort wire value, null = undeclared (the
  /// model's provider default). A picker, never a free string: the
  /// tiers are the lane's declared vocabulary (the Zed law), and a
  /// value outside the mirror rides the edit as its own button.
  String? _reasoningEffort;
  Set<String> _caps = <String>{};
  Timer? _jsonDebounce;

  PaletteCandidateModel get _model => widget.model;

  @override
  void dispose() {
    _jsonDebounce?.cancel();
    _idCtrl.dispose();
    _baseUrlCtrl.dispose();
    _credCtrl.dispose();
    _maxTokensCtrl.dispose();
    _maxOutCtrl.dispose();
    _jsonCtrl.dispose();
    super.dispose();
  }

  void _toggle(final String id) => setState(() {
    if (!_expanded.remove(id)) _expanded.add(id);
  });

  // ---- form verbs ----

  void _openProviderForm({final String? editId}) {
    final raw = editId == null ? null : _model.providers[editId];
    final provider = raw is Map ? raw : const <String, Object?>{};
    setState(() {
      _form = _FormState(
        kind: _FormKind.provider,
        providerId: editId,
        transport:
            '${provider['transport'] ?? kTransportWireNames.first}',
      );
      _idCtrl.text = editId ?? '';
      _baseUrlCtrl.text = '${provider['base_url'] ?? ''}';
      _credCtrl.text = '${provider['credential_env'] ?? ''}';
    });
  }

  void _openModelForm({
    required final String providerId,
    final String? editId,
  }) {
    final declared = editId == null
        ? const <String, Object?>{}
        : _model.modelsOf(providerId).firstWhere(
            (final model) => model['id'] == editId,
            orElse: () => const <String, Object?>{},
          );
    final declaredCaps = declared['capabilities'] is Map
        ? (declared['capabilities']! as Map)
        : const <Object?, Object?>{};
    final providerRaw = _model.providers[providerId];
    final provider = providerRaw is Map
        ? providerRaw
        : const <String, Object?>{};
    setState(() {
      _form = _FormState(
        kind: _FormKind.model,
        providerId: providerId,
        modelId: editId,
        // The model form rides the provider's transport: the reasoning
        // tiers are a LANE fact (the mirror's per-transport map).
        transport: '${provider['transport'] ?? ''}',
      );
      _idCtrl.text = editId ?? '';
      _maxTokensCtrl.text = declared['max_tokens']?.toString() ?? '';
      _maxOutCtrl.text = declared['max_output_tokens']?.toString() ?? '';
      final declaredEffort = declared['reasoning_effort'];
      _reasoningEffort = declaredEffort is String ? declaredEffort : null;
      _includeReasoning = declared['include_reasoning'] == true;
      // Every declared-true capability rides the edit, offered or not,
      // so a save never silently drops a declaration.
      _caps = <String>{
        for (final entry in declaredCaps.entries)
          if (entry.value == true) '${entry.key}',
      };
    });
  }

  void _closeForm() => setState(() => _form = null);

  int? _intOrReject(final String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  void _confirmForm() {
    final form = _form;
    if (form == null) return;
    final id = _idCtrl.text.trim();
    bool ok;
    switch (form.kind) {
      case _FormKind.provider:
        ok = form.providerId == null
            ? _model.addProvider(
                id: id,
                transport: form.transport,
                baseUrl: _baseUrlCtrl.text,
                credentialEnv: _credCtrl.text,
              )
            : _model.editProvider(
                oldId: form.providerId!,
                id: id,
                transport: form.transport,
                baseUrl: _baseUrlCtrl.text,
                credentialEnv: _credCtrl.text,
              );
      case _FormKind.model:
        final providerId = form.providerId!;
        final maxTokens = _intOrReject(_maxTokensCtrl.text);
        final maxOut = _intOrReject(_maxOutCtrl.text);
        if ((_maxTokensCtrl.text.trim().isNotEmpty && maxTokens == null) ||
            (_maxOutCtrl.text.trim().isNotEmpty && maxOut == null)) {
          // The one local refusal no verb owns: not a number.
          _model.refuseBadNumber();
          return;
        }
        ok = _model.editModel(
          providerId: providerId,
          oldId: form.modelId,
          id: id,
          maxTokens: maxTokens,
          maxOutputTokens: maxOut,
          reasoningEffort: _reasoningEffort,
          includeReasoning: _includeReasoning,
          capabilities: <String, bool>{for (final key in _caps) key: true},
        );
    }
    if (ok) setState(() => _form = null);
  }

  // ---- the JSON lane ----

  void _toggleJson() {
    setState(() {
      _jsonMode = !_jsonMode;
      _form = null;
      if (_jsonMode) {
        _jsonCtrl.text = const JsonEncoder.withIndent('  ').convert(
          _model.candidate,
        );
      }
    });
  }

  void _onJsonChanged(final String text) {
    _jsonDebounce?.cancel();
    _jsonDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _model.replaceFromJson(text);
    });
  }

  @override
  Widget build(final BuildContext context) {
    final la = context.la;
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
              // A narrow split pane scales the verb pair as a whole
              // instead of overflowing (the daemon-cluster law).
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ModelsButton(
                        keyName: 'models.json.toggle',
                        label: context.l10n.modelsJsonToggle,
                        onTap: _toggleJson,
                      ),
                      const SizedBox(width: 8),
                      ModelsButton(
                        keyName: 'models.provider.add',
                        label: context.l10n.modelsAddProvider,
                        onTap: _openProviderForm,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _jsonMode ? _jsonPane(context) : _table(context),
        ),
        if (_form != null) _formPanel(context, _form!),
        if (_form == null && !_jsonMode)
          if (_model.refusal case final refusal?)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ModelsNote(
              keyName: 'models.refusal.local',
              text: refusalText(context, refusal),
              color: la.caution,
            ),
          ),
      ],
    );
  }

  Widget _jsonPane(final BuildContext context) {
    final la = context.la;
    return Container(
      key: const ValueKey('models.json.pane'),
      decoration: BoxDecoration(
        color: context.shellRaised,
        borderRadius: BorderRadius.circular(ShellTokens.radius),
      ),
      padding: const EdgeInsets.all(10),
      child: TextField(
        key: const ValueKey('models.json.field'),
        controller: _jsonCtrl,
        maxLines: null,
        expands: true,
        textAlignVertical: TextAlignVertical.top,
        style: LaTokens.mono(11, la.ink),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _onJsonChanged,
      ),
    );
  }

  /// The nested table: one block per provider (row + expanded models).
  Widget _table(final BuildContext context) {
    final providers = _model.providers.keys.toList();
    if (providers.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(12),
        child: Text(
          context.l10n.modelsNoProviders,
          key: const ValueKey('models.providers.empty'),
        ),
      );
    }
    return ListView(
      key: const ValueKey('models.providers'),
      padding: EdgeInsets.zero,
      children: [
        for (final id in providers) ...[
          _providerRow(context, id),
          if (_expanded.contains(id)) ..._providerBlock(context, id),
        ],
      ],
    );
  }

  Widget _providerRow(final BuildContext context, final String id) {
    final la = context.la;
    final theme = Theme.of(context);
    final raw = _model.providers[id];
    final provider = raw is Map ? raw : const <String, Object?>{};
    final count = _model.modelsOf(id).length;
    final expanded = _expanded.contains(id);
    return Semantics(
      key: ValueKey('models.provider.$id'),
      button: true,
      expanded: expanded,
      label: 'models.provider.$id',
      hint: id,
      child: ShellRow(
        height: 44,
        selected: expanded,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        onTap: () => _toggle(id),
        child: LayoutBuilder(
          builder: (final context, final constraints) {
            // The pane law: a narrow split pane on a wide window
            // compresses like a phone — the chip run is a WIDTH fact,
            // not a window fact.
            final tight = widget.compact || constraints.maxWidth < 420;
            return Row(
              children: [
                HealthDot(status: providerHealth(widget.world, id), size: 8),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelMedium,
                      ),
                      if (!tight)
                        if (provider['base_url'] case final url?)
                          Text(
                            '$url',
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
                if (!tight) ...[
                  ModelsChip(
                    label: '${provider['transport'] ?? ''}',
                    color: la.inkQuiet,
                    mono: true,
                  ),
                  if (provider['credential_env'] case final env?)
                    ModelsChip(label: '$env', color: la.accent, mono: true),
                ],
                ModelsChip(
                  label: '$count ${context.l10n.modelsCountSuffix}',
                  color: la.inkQuiet,
                ),
                const SizedBox(width: 6),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  size: 14,
                  color: la.inkQuiet,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// The expanded block: the provider's verb row, then one indented
  /// row per model with its own verbs.
  List<Widget> _providerBlock(final BuildContext context, final String id) {
    final la = context.la;
    final models = _model.modelsOf(id);
    return <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(33, 2, 12, 2),
        child: Row(
          children: [
            ModelsButton(
              keyName: 'models.provider.$id.edit',
              label: context.l10n.modelsEditAction,
              onTap: () => _openProviderForm(editId: id),
            ),
            const SizedBox(width: 6),
            ModelsButton(
              keyName: 'models.provider.$id.remove',
              label: context.l10n.modelsRemoveAction,
              onTap: () => _model.removeProvider(id),
            ),
            const SizedBox(width: 6),
            ModelsButton(
              keyName: 'models.model.$id.add',
              label: context.l10n.modelsAddModel,
              onTap: () => _openModelForm(providerId: id),
            ),
          ],
        ),
      ),
      if (models.isEmpty)
        Padding(
          padding: const EdgeInsets.fromLTRB(33, 4, 12, 8),
          child: Text(
            context.l10n.modelsNoModels,
            style: LaTokens.mono(10, la.inkQuiet),
          ),
        ),
      for (final model in models) _modelRow(context, id, model),
      Container(height: 6, color: la.rule.withValues(alpha: 0.4)),
    ];
  }

  Widget _modelRow(
    final BuildContext context,
    final String providerId,
    final Map<String, Object?> model,
  ) {
    final la = context.la;
    final modelId = '${model['id']}';
    final castRefs = _model.castModelRefs(providerId, modelId);
    final caps = <String>[
      for (final entry in (model['capabilities'] as Map? ?? const {}).entries)
        if (entry.value == true) '${entry.key}',
    ];
    return Container(
      key: ValueKey('models.model.$providerId.$modelId'),
      padding: const EdgeInsets.fromLTRB(33, 3, 12, 3),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  modelId,
                  style: LaTokens.mono(11, la.inkMuted),
                ),
                if (model['max_tokens'] case final tier?)
                  ModelsChip(
                    label: '${context.l10n.modelsContextTier} $tier',
                    color: la.inkQuiet,
                    mono: true,
                  ),
                for (final cap in caps)
                  ModelsChip(label: cap, color: la.inkQuiet, mono: true),
                // The reasoning fact rides the row: the declared tier
                // by its display title (never the bare wire value),
                // `· incl` when the reasoning content joins context.
                if (model['reasoning_effort'] case final effort?)
                  ModelsChip(
                    label: 'reasoning ${reasoningEffortTitle('$effort')}'
                        '${model['include_reasoning'] == true
                            ? ' · incl'
                            : ''}',
                    color: la.inkQuiet,
                    mono: true,
                  ),
                for (final ref in castRefs)
                  ModelsChip(label: ref, color: la.accent, mono: true),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _ModelIconVerb(
            keyName: 'models.model.$providerId.$modelId.edit',
            icon: Icons.edit_outlined,
            tooltip: context.l10n.modelsEditModel,
            onTap: () => _openModelForm(
              providerId: providerId,
              editId: modelId,
            ),
          ),
          _ModelIconVerb(
            keyName: 'models.model.$providerId.$modelId.remove',
            icon: Icons.delete_outlined,
            tooltip: context.l10n.modelsRemoveAction,
            onTap: () => _model.removeModel(
              providerId: providerId,
              modelId: modelId,
            ),
          ),
        ],
      ),
    );
  }

  /// The one form panel under the table: provider fields, or the full
  /// per-model field set. A referenced provider id renders READ-ONLY
  /// with the immutability refusal naming the cast rows.
  Widget _formPanel(final BuildContext context, final _FormState form) {
    final la = context.la;
    final isProvider = form.kind == _FormKind.provider;
    final idLocked =
        isProvider &&
        form.providerId != null &&
        _model.castRefs(form.providerId!).isNotEmpty;
    return Container(
      key: const ValueKey('models.form'),
      margin: const EdgeInsets.only(top: 8),
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
            hint: isProvider
                ? context.l10n.modelsProviderIdHint
                : context.l10n.modelsModelIdHint,
            controller: _idCtrl,
            readOnly: idLocked,
          ),
          if (idLocked)
            ModelsNote(
              keyName: 'models.refusal.providerIdImmutable',
              text: '${context.l10n.modelsRefusalIdImmutable} '
                  '${_model.castRefs(form.providerId!).join(', ')}',
              color: la.caution,
            ),
          if (isProvider) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  context.l10n.modelsTransportLabel,
                  style: LaTokens.mono(10, la.inkQuiet),
                ),
                const SizedBox(width: 8),
                ModelsButton(
                  keyName: 'models.form.transport',
                  label: form.transport,
                  onTap: () {
                    final index = kTransportWireNames.indexOf(form.transport);
                    final next = kTransportWireNames[
                      (index + 1) % kTransportWireNames.length
                    ];
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
          ] else ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                SizedBox(
                  width: 120,
                  child: _formField(
                    keyName: 'models.form.maxTokens',
                    hint: context.l10n.modelsFieldMaxTokens,
                    controller: _maxTokensCtrl,
                  ),
                ),
                SizedBox(
                  width: 120,
                  child: _formField(
                    keyName: 'models.form.maxOutputTokens',
                    hint: context.l10n.modelsFieldMaxOutputTokens,
                    controller: _maxOutCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // The Zed law: reasoning controls are a CAPABILITY fact of
            // the lane. A transport whose client declares no effort
            // tiers gets an honest absence note — not a disabled
            // picker — because a declaration on such a lane refuses at
            // dispatch as `reasoning_effort_unsupported` anyway.
            if ((kReasoningEffortTiers[form.transport] ??
                    const <String>[])
                .isEmpty)
              ModelsNote(
                keyName: 'models.reasoning.noLane',
                text: '${context.l10n.modelsReasoningNoLane} '
                    '${form.transport}',
                color: la.inkQuiet,
              )
            else ...[
              Text(
                context.l10n.modelsReasoningTitle,
                style: LaTokens.mono(10, la.inkQuiet),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  // A declared value outside the mirror rides the edit
                  // as its own button (the capabilities law); a second
                  // tap on the selected tier clears the declaration.
                  for (final tier in <String>{
                    ...kReasoningEffortTiers[form.transport]!,
                    ?_reasoningEffort,
                  })
                    ModelsButton(
                      keyName: 'models.form.reasoning.$tier',
                      label: _reasoningEffort == tier
                          ? '✓ ${reasoningEffortTitle(tier)}'
                          : reasoningEffortTitle(tier),
                      onTap: () => setState(
                        () => _reasoningEffort =
                            _reasoningEffort == tier ? null : tier,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              ModelsButton(
                keyName: 'models.form.includeReasoning',
                label: '${context.l10n.modelsFieldIncludeReasoning}: '
                    '${_includeReasoning ? 'true' : 'false'}',
                onTap: () => setState(
                  () => _includeReasoning = !_includeReasoning,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              context.l10n.modelsFieldCapabilities,
              style: LaTokens.mono(10, la.inkQuiet),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final cap in <String>{...kCommonCapabilities, ..._caps})
                  ModelsButton(
                    keyName: 'models.form.cap.$cap',
                    label: _caps.contains(cap) ? '✓ $cap' : cap,
                    onTap: () => setState(() {
                      if (!_caps.remove(cap)) _caps.add(cap);
                    }),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              ModelsButton(
                keyName: 'models.form.confirm',
                label: context.l10n.modelsConfirm,
                onTap: _confirmForm,
              ),
              const SizedBox(width: 8),
              ModelsButton(
                keyName: 'models.form.cancel',
                label: context.l10n.modelsCancel,
                onTap: _closeForm,
              ),
            ],
          ),
          if (_model.refusal case final refusal?)
            ModelsNote(
              keyName: 'models.refusal.local',
              text: refusalText(context, refusal),
              color: la.caution,
            ),
        ],
      ),
    );
  }

  String _formTitle(final _FormState form) => switch (form.kind) {
    _FormKind.provider => form.providerId == null
        ? context.l10n.modelsAddProvider
        : '${context.l10n.modelsEditProvider} ${form.providerId}',
    _FormKind.model => form.modelId == null
        ? '${context.l10n.modelsAddModel} · ${form.providerId}'
        : '${context.l10n.modelsEditModel} ${form.modelId}',
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

/// A row-trailing icon verb (edit / remove a model): 24px tap target,
/// outlined stroke family, tooltip names the verb.
final class _ModelIconVerb extends StatelessWidget {
  const _ModelIconVerb({
    required this.keyName,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(final BuildContext context) => Tooltip(
    message: tooltip,
    child: Semantics(
      button: true,
      label: keyName,
      child: GestureDetector(
        key: ValueKey(keyName),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Icon(icon, size: 14, color: context.la.inkQuiet),
        ),
      ),
    ),
  );
}
