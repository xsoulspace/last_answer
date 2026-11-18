/// Models refactor (2026-11-14) + wave N4 (2026-11-16) — the CATALOG
/// lens as the owner's FOUR LANE CLASSES, each a section of ONE nested
/// table (the spreadsheet law): declared REMOTE providers (modelscope,
/// openrouter…), declared LOOPBACK providers (the ollama-class lanes:
/// an openai_compatible wire over a loopback endpoint), the DIRECT
/// SUBSCRIPTION providers (the ChatGPT plan, and the Grok plan closed
/// until xAI issues a client id — actors name them as
/// `subscription:<provider>/<model>`, ADR 0031), and the LOCAL MODELS
/// section (2026-11-18 merge: the downloadable checkpoints AND the
/// on-device built-in services — AFM, laya, LFM — in ONE section; the
/// standalone `qwen` lane row is absorbed into the checkpoints it is
/// the same thing as). Verbs live on the row that
/// owns them; the same tree reads on a phone (compact rows) and on
/// desktop (full chip run).
///
/// The edit lane is the table itself — no modal, no parallel card
/// list: a verb row opens ONE inline form panel under the table, and
/// the model form is a DYNAMIC settings list (the ZCode/ComfyUI law):
/// one typed row per declared key (int field, titled tier picker,
/// boolean toggle), an add-setting row offering the lane's schema keys
/// plus a free key, and a per-row remove. Keys outside the mirror ride
/// the document verbatim with an `unconsumed` marker — the parser
/// tolerates them, no lane reads them, and the UI says so instead of
/// hiding or faking a control. The JSON toggle swaps the tree for the
/// raw document view (the Zed rule: named parser refusals, never a
/// silent half-parse). Every mutation lands on the shared
/// [PaletteCandidateModel]; the dirty bar (propose → receipt → apply)
/// rides at the view's bottom edge.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:lastanswer/coding_agent/chatgpt_subscription_controller.dart';
import 'package:lastanswer/coding_agent/grok_subscription_controller.dart';
import 'package:lastanswer/coding_agent/realm_chat/palette_lanes.dart';
import 'package:lastanswer/coding_agent/realm_chat/world_state_service.dart';
import 'package:lastanswer/common_imports.dart';
import 'package:lastanswer/settings/features/storage_backends_state.dart';
import 'package:lastanswer/shell/models/local_models_state.dart';
import 'package:lastanswer/shell/models/local_runtime_ledger.dart';
import 'package:lastanswer/shell/models/memory_budget.dart';
import 'package:lastanswer/shell/models/memory_budget_bar.dart';
import 'package:lastanswer/shell/models/models_widgets.dart';
import 'package:lastanswer/shell/models/palette_candidate.dart';
import 'package:lastanswer/shell/shell_theme.dart';
import 'package:lastanswer/shell/status_edge.dart' show HealthDot;
import 'package:xsoulspace_inference_core/xsoulspace_inference_core.dart';
import 'package:xsoulspace_inference_mlx_native/xsoulspace_inference_mlx_native.dart';

/// The transport vocabulary is CLOSED (the host parser's law): the
/// form cycles these wire names, never a free string. A subscription
/// is a provider type an actor names (`subscription:<provider>/<model>`,
/// ADR 0031). It is not one of these wires: the harness parser refuses
/// an unknown transport, and the daemon does not hold the OAuth account.
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

/// The typed control a settings key rides (wave N4): ints get number
/// fields, booleans toggles, the effort its titled picker, anything
/// else a raw mono field with the unconsumed marker.
enum _SettingKind { intField, boolToggle, tierPicker, rawField }

_SettingKind _kindOf(final String key) => switch (key) {
  'max_tokens' || 'max_output_tokens' => _SettingKind.intField,
  'include_reasoning' => _SettingKind.boolToggle,
  'reasoning_effort' => _SettingKind.tierPicker,
  _ =>
    key.startsWith('capabilities.')
        ? _SettingKind.boolToggle
        : _SettingKind.rawField,
};

/// Whether a key is in the lane schema mirror (a key outside it rides
/// the document verbatim — declared, unconsumed, marked).
bool _isMirroredKey(final String key) =>
    _kindOf(key) != _SettingKind.rawField ||
    (key.startsWith('capabilities.') &&
        kCommonCapabilities.contains(key.substring('capabilities.'.length)));

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
    required this.localModels,
    super.key,
  });

  final PaletteCandidateModel model;
  final WorldStateService world;
  final bool compact;

  /// The local model manager's state (the curated catalog, install
  /// states, the in-flight install). Owned and refreshed by the
  /// ModelsView; tests inject a fake-installer state.
  final LocalModelsState localModels;

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
  final TextEditingController _jsonCtrl = TextEditingController();
  final TextEditingController _newKeyCtrl = TextEditingController();

  /// The dynamic settings list (wave N4): the model row minus `id`,
  /// capabilities flattened as `capabilities.<key>`; typed values.
  final Map<String, Object?> _settings = <String, Object?>{};

  /// Text controllers for the int/raw settings rows (the toggles and
  /// the tier picker are stateless over [_settings]).
  final Map<String, TextEditingController> _settingCtrls =
      <String, TextEditingController>{};
  Timer? _jsonDebounce;

  PaletteCandidateModel get _model => widget.model;

  @override
  void dispose() {
    _jsonDebounce?.cancel();
    _idCtrl.dispose();
    _baseUrlCtrl.dispose();
    _credCtrl.dispose();
    _jsonCtrl.dispose();
    _newKeyCtrl.dispose();
    for (final ctrl in _settingCtrls.values) {
      ctrl.dispose();
    }
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
        transport: '${provider['transport'] ?? kTransportWireNames.first}',
      );
      _idCtrl.text = editId ?? '';
      _baseUrlCtrl.text = '${provider['base_url'] ?? ''}';
      _credCtrl.text = '${provider['credential_env'] ?? ''}';
    });
  }

  void _clearSettingCtrls() {
    for (final ctrl in _settingCtrls.values) {
      ctrl.dispose();
    }
    _settingCtrls.clear();
  }

  void _openModelForm({
    required final String providerId,
    final String? editId,
  }) {
    final declared = editId == null
        ? const <String, Object?>{}
        : _model
              .modelsOf(providerId)
              .firstWhere(
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
    final settings = <String, Object?>{
      for (final entry in declared.entries)
        if (entry.key != 'id' && entry.key != 'capabilities')
          entry.key: entry.value,
      for (final cap in declaredCaps.entries)
        'capabilities.${cap.key}': cap.value,
    };
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
      _clearSettingCtrls();
      _settings
        ..clear()
        ..addAll(settings);
      for (final entry in _settings.entries) {
        final kind = _kindOf(entry.key);
        if (kind == _SettingKind.intField || kind == _SettingKind.rawField) {
          _settingCtrls[entry.key] = TextEditingController(
            text: entry.value?.toString() ?? '',
          );
        }
      }
    });
  }

  void _closeForm() => setState(() {
    _form = null;
    _clearSettingCtrls();
    _settings.clear();
  });

  int? _intOrReject(final String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return int.tryParse(trimmed);
  }

  /// A raw field's value with JSON fidelity: booleans and numbers keep
  /// their type, everything else rides as the typed string.
  Object? _coerceRaw(final String text) {
    final trimmed = text.trim();
    if (trimmed == 'true') return true;
    if (trimmed == 'false') return false;
    return int.tryParse(trimmed) ?? double.tryParse(trimmed) ?? trimmed;
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
        final settings = <String, Object?>{};
        for (final key in _settings.keys) {
          switch (_kindOf(key)) {
            case _SettingKind.intField:
              final text = _settingCtrls[key]?.text ?? '';
              if (text.trim().isEmpty) continue; // dropped key
              final value = _intOrReject(text);
              if (value == null) {
                _model.refuseBadNumber();
                return;
              }
              settings[key] = value;
            case _SettingKind.boolToggle:
              settings[key] = _settings[key] == true;
            case _SettingKind.tierPicker:
              final tier = _settings[key];
              if (tier is String && tier.isNotEmpty) settings[key] = tier;
            case _SettingKind.rawField:
              final text = _settingCtrls[key]?.text ?? '';
              if (text.trim().isEmpty) continue;
              settings[key] = _coerceRaw(text);
          }
        }
        ok = _model.editModelSettings(
          providerId: form.providerId!,
          oldId: form.modelId,
          id: id,
          settings: settings,
        );
    }
    if (ok) _closeForm();
  }

  // ---- the JSON lane ----

  void _toggleJson() {
    setState(() {
      _jsonMode = !_jsonMode;
      _form = null;
      _clearSettingCtrls();
      if (_jsonMode) {
        _jsonCtrl.text = const JsonEncoder.withIndent(
          '  ',
        ).convert(_model.candidate);
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
        Expanded(child: _jsonMode ? _jsonPane(context) : _table(context)),
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
      // The raw-JSON lane on the kit field (borderless law): at rest it
      // is the pane itself; hover earns the quiet fill, focus the
      // accent hairline.
      child: LaField(
        key: const ValueKey('models.json.field'),
        controller: _jsonCtrl,
        maxLines: null,
        expands: true,
        style: LaTokens.mono(11, la.ink),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        radius: BorderRadius.circular(4),
        onChanged: _onJsonChanged,
      ),
    );
  }

  // ---- the four class sections ----

  Map<String, Map<Object?, Object?>> _declaredProviders() =>
      <String, Map<Object?, Object?>>{
        for (final entry in _model.providers.entries)
          if (entry.value is Map)
            entry.key: Map<Object?, Object?>.from(entry.value! as Map),
      };

  LaneClass _classOfDeclared(final Map<Object?, Object?> provider) =>
      classOfProvider(
        '${provider['transport'] ?? ''}',
        '${provider['base_url'] ?? ''}',
      );

  /// The nested table: ONE section per owner lane class, providers
  /// nested inside their class, builtins as on-device service rows.
  Widget _table(final BuildContext context) {
    final providers = _declaredProviders();
    final remote = <String>[
      for (final entry in providers.entries)
        if (_classOfDeclared(entry.value) == LaneClass.remote) entry.key,
    ];
    final loopback = <String>[
      for (final entry in providers.entries)
        if (_classOfDeclared(entry.value) == LaneClass.localServer) entry.key,
    ];
    final builtins = <WorldRung>[
      for (final rung in widget.world.rungs)
        if (rung.builtin) rung,
    ];
    final onDevice = <WorldRung>[
      for (final rung in builtins)
        if (rung.id != 'qwen' &&
            classOfBuiltin(builtinLaneFamily(rung.id)) == LaneClass.onDevice)
          rung,
    ];
    final unclassified = <WorldRung>[
      for (final rung in builtins)
        if (classOfBuiltin(builtinLaneFamily(rung.id)) ==
            LaneClass.unclassified)
          rung,
    ];
    if (providers.isEmpty && builtins.isEmpty) {
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
        _classSection(
          context,
          'models.class.remote',
          context.l10n.modelsClassRemote,
          children: [
            if (remote.isEmpty)
              _emptyNote(context, context.l10n.modelsClassRemoteEmpty)
            else
              for (final id in remote) ..._providerBlock(context, id),
          ],
        ),
        _classSection(
          context,
          'models.class.localServer',
          context.l10n.modelsClassLocalServer,
          children: [
            if (loopback.isEmpty)
              _emptyNote(context, context.l10n.modelsClassLocalServerEmpty)
            else
              for (final id in loopback) ..._providerBlock(context, id),
          ],
        ),
        _classSection(
          context,
          'models.class.subscription',
          context.l10n.modelsClassSubscription,
          children: [
            _subscriptionRow(context),
            _grokSubscriptionRow(context),
            _emptyNote(context, context.l10n.modelsClassSubscriptionAbsent),
          ],
        ),
        _classSection(
          context,
          'models.class.localModels',
          context.l10n.modelsLocalCatalog,
          children: [
            ListenableBuilder(
              listenable: widget.localModels,
              builder: (final context, final _) {
                final local = widget.localModels;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // The budget bar LEADS the section (2026-11-18) and
                    // v3 makes it the MAP: each loaded model owns a
                    // labeled segment (tap-through selects the row) and
                    // a generating model's segment pulses.
                    MemoryBudgetBar(
                      facts: local.memoryFacts,
                      loaded: <LoadedModelSegment>[
                        for (final entry in local.catalog)
                          if (local.stateOf(entry).installed &&
                              local.isLoaded(entry))
                            LoadedModelSegment(
                              cast: localCastsForEntry(entry).first,
                              label: entry.label,
                              approxBytes: entry.approxDownloadBytes,
                              generating:
                                  localRunForEntry(entry)?.running ?? false,
                            ),
                      ],
                      onModelTap: (final cast) {
                        for (final entry in local.catalog) {
                          if (localCastsForEntry(entry).contains(cast)) {
                            local.selectedRef = localModelRefName(entry);
                            break;
                          }
                        }
                      },
                    ),
                    // The machine verdict, said ONCE and made
                    // ACTIONABLE (2026-11-18 v3.1, the owner's "why is
                    // there no place to start any model"): the floor is
                    // the gate's headroom, and the line names the
                    // next runnable step — how much to free for the
                    // downloaded model closest to fitting.
                    if (_closestUnfitEntry(local) case (
                      final entry,
                      final fit,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: ModelsNote(
                          keyName: 'models.local.budget.noFit',
                          text: context.l10n.modelsBudgetNothingFits(
                            formatModelBytes(
                              (fit.missingMegabytes ?? 0) * 1024 * 1024,
                            ),
                            entry.label,
                          ),
                          color: context.la.caution,
                        ),
                      ),
                    const SizedBox(height: 4),
                    for (final entry in _sortedLocalEntries(local))
                      _localModelRow(context, entry),
                    if (local.error case final code?)
                      ModelsNote(
                        keyName: 'models.local.error',
                        text: code == 'delete_refused'
                            ? context.l10n.modelsLocalDeleteRefused
                            : '${context.l10n.modelsLocalPhaseFailed}: '
                                  '$code',
                        color: context.la.caution,
                      ),
                  ],
                );
              },
            ),
            // The built-in lanes close the merged section as a FOOTER
            // (the owner's 2026-11-18 merge law, v3 shape): they are
            // not lifecycle rows — one quiet chip per lane, the
            // sentence on the tooltip, AFM visibly exempt from the
            // load/download story. The `qwen` lane chip is ABSENT on
            // purpose: it IS the checkpoints above.
            if (onDevice.isNotEmpty)
              Padding(
                key: const ValueKey('models.local.builtins'),
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final rung in onDevice)
                      _builtinLaneChip(context, rung),
                  ],
                ),
              ),
          ],
        ),
        if (unclassified.isNotEmpty)
          _classSection(
            context,
            'models.class.unclassified',
            context.l10n.modelsClassUnclassified,
            children: [
              for (final rung in unclassified) _onDeviceRow(context, rung),
            ],
          ),
      ],
    );
  }

  Widget _classSection(
    final BuildContext context,
    final String keyName,
    final String title, {
    required final List<Widget> children,
  }) => Padding(
    key: ValueKey(keyName),
    padding: const EdgeInsets.only(bottom: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(title, style: shellSectionLabel(context)),
        ),
        ...children,
      ],
    ),
  );

  Widget _emptyNote(final BuildContext context, final String text) => Padding(
    padding: const EdgeInsets.fromLTRB(0, 2, 0, 6),
    child: Text(text, style: LaTokens.mono(10, context.la.inkQuiet)),
  );

  /// The ChatGPT plan row. The runtime pane owns sign-in.
  Widget _subscriptionRow(final BuildContext context) {
    final la = context.la;
    final controller = context.read<ChatGptSubscriptionController?>();
    final profile = controller?.activeProfile;
    final signedIn = profile?.signedIn == true;
    return Container(
      key: const ValueKey('models.subscription.chatgpt'),
      padding: const EdgeInsets.fromLTRB(0, 3, 12, 3),
      child: Row(
        children: [
          HealthDot(status: signedIn ? 'ok' : 'unknown', size: 8),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'openai_chatgpt_plan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(11, la.inkMuted),
                ),
                Text(
                  signedIn
                      ? '${context.l10n.modelsChatGptPlan} · '
                            '${profile?.model ?? ''}'
                      : context.l10n.modelsChatGptSignedOut,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.micro.copyWith(
                    fontSize: 10,
                    color: la.inkQuiet,
                  ),
                ),
              ],
            ),
          ),
          ModelsChip(
            label: laneClassChipLabel(LaneClass.subscription),
            color: la.inkQuiet,
            mono: true,
          ),
        ],
      ),
    );
  }

  Widget _grokSubscriptionRow(final BuildContext context) {
    final la = context.la;
    final controller = context.read<GrokSubscriptionController?>();
    final profile = controller?.activeProfile;
    final signedIn = profile?.signedIn == true;
    final awaiting = controller?.registered == false;
    return Container(
      key: const ValueKey('models.subscription.grok'),
      padding: const EdgeInsets.fromLTRB(0, 3, 12, 3),
      child: Row(
        children: [
          HealthDot(status: signedIn ? 'ok' : 'unknown', size: 8),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'xai_grok_plan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(11, la.inkMuted),
                ),
                Text(
                  signedIn
                      ? '${context.l10n.modelsGrokPlan} · '
                            '${profile?.model ?? ''}'
                      : awaiting
                      ? context.l10n.modelsGrokAwaitingRegistration
                      : context.l10n.modelsGrokSignedOut,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.micro.copyWith(
                    fontSize: 10,
                    color: la.inkQuiet,
                  ),
                ),
              ],
            ),
          ),
          ModelsChip(
            label: laneClassChipLabel(LaneClass.subscription),
            color: la.inkQuiet,
            mono: true,
          ),
        ],
      ),
    );
  }

  /// One on-device service row: the harness-owned lane as a read-only
  /// fact (health + lane sentence + class chip) — no verbs, because the
  /// composition root owns these bindings (the collision law).
  Widget _onDeviceRow(final BuildContext context, final WorldRung rung) {
    final la = context.la;
    final family = builtinLaneFamily(rung.id);
    return Container(
      key: ValueKey('models.onDevice.${rung.id}'),
      padding: const EdgeInsets.fromLTRB(0, 3, 12, 3),
      child: Row(
        children: [
          HealthDot(status: rung.healthStatus, size: 8),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ADR — the DISPLAY name leads (2026-11-18: `laya` /
                // `lfm` / `qwen` are wire vocabulary, not user
                // surfaces); the raw id stays the Semantics hint.
                Text(
                  builtinLaneDisplayName(rung.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.body,
                ),
                Text(
                  builtinLaneSentence(context, rung.id),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.laUi.micro.copyWith(
                    fontSize: 10,
                    color: la.inkQuiet,
                  ),
                ),
              ],
            ),
          ),
          if (family == BuiltinLaneFamily.appleFoundation)
            ModelsChip(label: 'afm', color: la.inkQuiet, mono: true),
          ModelsChip(
            label: laneClassChipLabel(classOfBuiltin(family)),
            color: la.inkQuiet,
            mono: true,
          ),
        ],
      ),
    );
  }

  // ---- the local model catalog (docs/design/models-local-manager.md)

  /// One curated local model row — v3 (2026-11-18): ONE line, the
  /// shadcn-quiet grammar. Identity (name), quiet metadata
  /// (`params · quant · ≈size`), a STATUS WORD (dot + text: generating
  /// / ≈tok/s / Downloaded / Not downloaded — the two-stage chips
  /// collapse into it), ONE primary verb (Download / Load / Unload)
  /// and the `⋯` overflow (Details, Delete). The fit verdict lives at
  /// the Load verb: when the machine's own arithmetic says the load
  /// would miss, Load renders disabled and a QUIET reason line names
  /// the gap at the moment of intent — no standing orange wall (the
  /// aggregate already said once above the rows). During its download
  /// the row IS the progress (phase word + the keyed [LaProgress]
  /// bar); during a load/unload the verbs step aside for the spinner.
  /// Below the 640px law the line stacks to two.
  Widget _localModelRow(
    final BuildContext context,
    final MlxModelCatalogEntry entry,
  ) {
    final la = context.la;
    final l10n = context.l10n;
    final local = widget.localModels;
    final ref = localModelRefName(entry);
    final state = local.stateOf(entry);
    final installed = state.installed;
    final loaded = installed && local.isLoaded(entry);
    final installing = local.installingRef == ref;
    final busy = installing || local.isBusy(entry);
    final progress = installing ? local.progress : null;
    final fit = local.fitOf(entry);
    final run = localRunForEntry(entry);
    final generating = loaded && (run?.running ?? false);
    // Fit at the verb (2026-11-18 v3): the gate's own arithmetic
    // (single-sourced floor) says a load would miss — Load renders
    // disabled and the quiet reason line names the gap. The verb stays
    // honest to the same math the runtime enforces; nothing here
    // invents a second gate.
    final loadBlocked =
        installed &&
        !loaded &&
        local.hasRuntime &&
        !fit.unknown &&
        !fit.fitsNow;
    final statusText = generating
        ? l10n.modelsLocalGenerating
        : loaded
        ? switch (run?.lastTokensPerSecond) {
            final speed? => l10n.modelsLocalTokPerSec(_speedLabel(speed)),
            _ => l10n.modelsLocalMemLoaded,
          }
        : installed
        ? l10n.modelsLocalDiskDownloaded
        : l10n.modelsLocalDiskNot;
    final statusColor = loaded ? la.accent : la.inkMuted;
    final metaText = installing && progress != null
        ? _progressLine(context, progress)
        : '${entry.paramLabel} · ${entry.quant} · '
              '${formatModelBytes(entry.approxDownloadBytes)}';
    return Container(
      key: ValueKey('models.local.$ref.row'),
      padding: const EdgeInsets.fromLTRB(0, 3, 12, 3),
      // The bar's tap-through highlight (the segment → row law): a
      // quiet accent wash, nothing structural.
      decoration: local.selectedRef == ref
          ? BoxDecoration(
              color: la.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(6),
            )
          : null,
      child: LayoutBuilder(
        builder: (final context, final constraints) {
          // The compact law's local-row tier: below the 640px law the
          // line stacks to two (name+status / metadata+verbs) instead
          // of overflowing the Row by its unbreakable minimum.
          final stacked = widget.compact || constraints.maxWidth < 640;
          final dot = HealthDot(status: loaded ? 'ok' : 'unknown', size: 8);
          final name = Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.laUi.body,
          );
          final statusLine = AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              // The key IS the transition: a status-word change fades,
              // a repaint of the same word does not.
              key: ValueKey('status.$statusText'),
              statusText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LaTokens.mono(10, statusColor),
            ),
          );
          final metaTextWidget = Text(
            metaText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LaTokens.mono(10, la.inkQuiet),
          );
          final verbRun = busy
              ? LaSpinner(size: 11, strokeWidth: 1.5, color: la.inkMuted)
              : Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (!installed)
                      ModelsButton(
                        keyName: 'models.local.$ref.download',
                        label: l10n.modelsLocalDownload,
                        onTap: () => unawaited(_askInstall(context, entry)),
                      )
                    else ...[
                      if (local.hasRuntime)
                        ModelsButton(
                          keyName: loaded
                              ? 'models.local.$ref.unload'
                              : 'models.local.$ref.load',
                          label: loaded
                              ? l10n.modelsLocalUnload
                              : l10n.modelsLocalLoad,
                          disabled: loadBlocked,
                          onTap: () => unawaited(
                            loaded
                                ? local.unloadEntry(entry)
                                : local.loadEntry(entry),
                          ),
                        ),
                      ModelsButton(
                        keyName: 'models.local.$ref.menu',
                        label: '⋯',
                        onTap: () => _openRowMenu(context, entry),
                      ),
                    ],
                  ],
                );
          final verbLine = AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              // The lifecycle stage is the key: Download → spinner →
              // Load/Unload crossfade instead of popping.
              key: ValueKey(
                'verbs.${busy
                    ? 'busy'
                    : installed
                    ? (loaded ? 'loaded' : 'disk')
                    : 'missing'}',
              ),
              child: verbRun,
            ),
          );
          final rowLine = stacked
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        dot,
                        const SizedBox(width: 9),
                        Expanded(child: name),
                        const SizedBox(width: 8),
                        statusLine,
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(child: metaTextWidget),
                        const SizedBox(width: 8),
                        verbLine,
                      ],
                    ),
                  ],
                )
              : Row(
                  children: [
                    dot,
                    const SizedBox(width: 9),
                    Expanded(child: name),
                    const SizedBox(width: 10),
                    Flexible(child: metaTextWidget),
                    const SizedBox(width: 10),
                    statusLine,
                    const SizedBox(width: 8),
                    verbLine,
                  ],
                );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              rowLine,
              // The fit reason lives HERE, at the moment of intent, and
              // only for the row that misses (never a standing wall);
              // its appearance fades in with the disabled verb.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: loadBlocked
                    ? Padding(
                        key: ValueKey('models.local.$ref.fitReason'),
                        padding: const EdgeInsets.fromLTRB(17, 2, 24, 0),
                        child: Text(
                          l10n.modelsLocalFitReason(
                            formatModelBytes(
                              (fit.missingMegabytes ?? 0) * 1024 * 1024,
                            ),
                          ),
                          maxLines: 2,
                          style: LaTokens.mono(10, la.caution),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
              if (installing && progress != null)
                Padding(
                  key: ValueKey('models.local.$ref.progress'),
                  padding: const EdgeInsets.fromLTRB(17, 2, 24, 3),
                  child: LaProgress(
                    value: progress.percent == null
                        ? null
                        : progress.percent!.clamp(0, 100) / 100,
                    color: la.accent,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// The v3 row order: loaded first, then downloaded, then not
  /// installed — the lifecycle's natural reading order. List.sort is
  /// not stable, so the repo id is the tiebreak (the catalog order is
  /// its own deterministic sequence).
  List<MlxModelCatalogEntry> _sortedLocalEntries(final LocalModelsState local) {
    int rank(final MlxModelCatalogEntry entry) {
      final installed = local.stateOf(entry).installed;
      return installed && local.isLoaded(entry)
          ? 0
          : installed
          ? 1
          : 2;
    }

    final entries =
        <(int, MlxModelCatalogEntry)>[
          for (final entry in local.catalog) (rank(entry), entry),
        ]..sort((final a, final b) {
          final byRank = a.$1.compareTo(b.$1);
          return byRank != 0 ? byRank : a.$2.repoId.compareTo(b.$2.repoId);
        });
    return <MlxModelCatalogEntry>[for (final (_, entry) in entries) entry];
  }

  /// The machine's next runnable step (2026-11-18 v3.1): when EVERY
  /// downloaded-but-unloaded entry misses its fit on today's memory,
  /// return the one closest to fitting (fewest missing MB) — the
  /// verdict line names it, so "no place to start any model" always
  /// comes with the lever that changes it. Null when something fits or
  /// nothing is downloaded.
  (MlxModelCatalogEntry, LocalModelFit)? _closestUnfitEntry(
    final LocalModelsState local,
  ) {
    final candidates = <(MlxModelCatalogEntry, LocalModelFit)>[
      for (final entry in local.catalog)
        if (local.stateOf(entry).installed &&
            local.hasRuntime &&
            !local.isLoaded(entry) &&
            !local.fitOf(entry).unknown)
          (entry, local.fitOf(entry)),
    ];
    if (candidates.isEmpty) return null;
    if (candidates.any((final cand) => cand.$2.fitsNow)) return null;
    return candidates.reduce(
      (final a, final b) =>
          (a.$2.missingMegabytes ?? 0) <= (b.$2.missingMegabytes ?? 0) ? a : b,
    );
  }

  /// The built-in lane chip (v3 footer): dot + display name, the
  /// sentence on the tooltip, AFM visibly exempt from the lifecycle.
  /// NOT a lifecycle row — these lanes have no Download/Load story
  /// (AFM is always-on; Laya is the loopback composition lane; LFM 2.5
  /// lazy-loads inside its own lane and joins the checkpoint story
  /// when it enters the catalog).
  Widget _builtinLaneChip(final BuildContext context, final WorldRung rung) {
    final la = context.la;
    final family = builtinLaneFamily(rung.id);
    final afm = family == BuiltinLaneFamily.appleFoundation;
    return LaTooltip(
      message: builtinLaneSentence(context, rung.id),
      child: Container(
        key: ValueKey('models.onDevice.${rung.id}'),
        // A cap, not a wish: on a crushed pane the chip shrinks and
        // the suffix ellipsizes instead of overflowing the footer.
        constraints: const BoxConstraints(maxWidth: 220),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: la.inkQuiet.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HealthDot(status: rung.healthStatus),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                builtinLaneDisplayName(rung.id),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LaTokens.mono(10, la.inkMuted),
              ),
            ),
            if (afm) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  context.l10n.modelsBuiltinsNoLifecycle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LaTokens.mono(9, la.inkQuiet),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The `⋯` overflow: Details (the sheet) + Delete (the confirm).
  void _openRowMenu(
    final BuildContext context,
    final MlxModelCatalogEntry entry,
  ) {
    final l10n = context.l10n;
    final ref = localModelRefName(entry);
    final box = context.findRenderObject()! as RenderBox;
    final anchor = box.localToGlobal(
      Offset(math.max(0, box.size.width - 180), box.size.height),
    );
    showLaMenuAt(
      context,
      globalPosition: anchor,
      entries: [
        LaMenuItem(
          key: ValueKey('models.local.$ref.details'),
          label: l10n.modelsLocalDetails,
          onPressed: () => unawaited(_showDetails(context, entry)),
        ),
        LaMenuItem(
          key: ValueKey('models.local.$ref.delete'),
          label: l10n.modelsLocalDelete,
          destructive: true,
          onPressed: () => unawaited(_askDelete(context, entry)),
        ),
      ],
    );
  }

  /// The detail sheet (v3): the sensed facts behind the one-line row —
  /// disk + memory states, the SENSED size on disk (a real walk of the
  /// snapshot dir, never the approximation), the snapshot path, the
  /// ledger's last generation (≈speed), and the last failure
  /// verbatim. `used-by` (which actors bind the cast) is the noted
  /// phase-3 follow-up — the bindings live in the world read model
  /// this lens does not read.
  Future<void> _showDetails(
    final BuildContext context,
    final MlxModelCatalogEntry entry,
  ) async {
    final local = widget.localModels;
    final ref = localModelRefName(entry);
    await showLaDialog<void>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: entry.label,
        content: _LocalModelDetails(
          key: ValueKey('models.local.$ref.details.sheet'),
          local: local,
          entry: entry,
        ),
        actions: [
          LaButton(
            key: ValueKey('models.local.$ref.details.close'),
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(),
            label: dialogContext.l10n.modelsCancel,
          ),
        ],
      ),
    );
  }

  /// The speed label: whole tok/s at double digits, one decimal below.
  String _speedLabel(final double tokensPerSecond) => tokensPerSecond >= 10
      ? tokensPerSecond.round().toString()
      : tokensPerSecond.toStringAsFixed(1);

  /// The install row's progress line: the phase word titled in l10n,
  /// then percent, or the downloaded/total bytes when no percent
  /// rides (the honest middle of a resumable download).
  String _progressLine(
    final BuildContext context,
    final ProvisionProgress progress,
  ) {
    final phase = switch (progress.phase) {
      ProvisionPhase.checking => context.l10n.modelsLocalPhaseChecking,
      ProvisionPhase.downloading => context.l10n.modelsLocalPhaseDownloading,
      ProvisionPhase.loading => context.l10n.modelsLocalPhaseLoading,
      ProvisionPhase.ready => context.l10n.modelsLocalPhaseReady,
      ProvisionPhase.failed => context.l10n.modelsLocalPhaseFailed,
      ProvisionPhase.idle => context.l10n.modelsLocalPhaseChecking,
    };
    final percent = progress.percent;
    final downloaded = progress.downloadedBytes;
    final total = progress.totalBytes;
    final detail = percent != null
        ? '$percent%'
        : downloaded != null && total != null
        ? '${formatModelBytes(downloaded)} / ${formatModelBytes(total)}'
        : progress.message;
    return '$phase $detail'.trim();
  }

  /// The consent dialog behind the Download verb (the provisioning
  /// law's consent point): names the model, the approximate download
  /// size, and the network fact. Confirm installs with consent; Cancel
  /// installs nothing. While an install is in flight the dialog never
  /// re-opens — the row IS the progress.
  Future<void> _askInstall(
    final BuildContext context,
    final MlxModelCatalogEntry entry,
  ) async {
    final local = widget.localModels;
    if (local.installingRef != null) return;
    final l10n = context.l10n;
    final ref = localModelRefName(entry);
    final ok = await showLaDialog<bool>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: l10n.modelsLocalConsentTitle,
        content: Text(
          l10n.modelsLocalConsentBody(
            entry.label,
            formatModelBytes(entry.approxDownloadBytes),
          ),
          style: dialogContext.laUi.body.copyWith(fontSize: 13),
        ),
        actions: [
          LaButton(
            key: ValueKey('models.local.$ref.consent.cancel'),
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: l10n.modelsCancel,
          ),
          LaButton(
            key: ValueKey('models.local.$ref.consent.confirm'),
            variant: LaButtonVariant.primary,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: l10n.modelsLocalConsentConfirm,
          ),
        ],
      ),
    );
    if (ok == true) await local.install(entry);
  }

  /// The delete confirm (the marker-file law: only a manager-installed
  /// dir is deletable; an honest false no-ops with the quiet refusal
  /// line under the section).
  Future<void> _askDelete(
    final BuildContext context,
    final MlxModelCatalogEntry entry,
  ) async {
    final local = widget.localModels;
    if (local.installingRef != null) return;
    final l10n = context.l10n;
    final ref = localModelRefName(entry);
    final ok = await showLaDialog<bool>(
      context: context,
      builder: (final dialogContext) => LaDialog(
        titleText: l10n.modelsLocalDeleteTitle,
        content: Text(
          l10n.modelsLocalDeleteBody(entry.label),
          style: dialogContext.laUi.body.copyWith(fontSize: 13),
        ),
        actions: [
          LaButton(
            key: ValueKey('models.local.$ref.delete.cancel'),
            variant: LaButtonVariant.ghost,
            onPressed: () => Navigator.of(dialogContext).pop(false),
            label: l10n.modelsCancel,
          ),
          LaButton(
            key: ValueKey('models.local.$ref.delete.confirm'),
            variant: LaButtonVariant.destructive,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            label: l10n.modelsLocalDelete,
          ),
        ],
      ),
    );
    if (ok == true) await local.delete(entry);
  }

  /// One provider's block: the row, then (expanded) its verb row and
  /// its indented model rows.
  List<Widget> _providerBlock(final BuildContext context, final String id) {
    final provider = _declaredProviders()[id] ?? const <Object?, Object?>{};
    final count = _model.modelsOf(id).length;
    final expanded = _expanded.contains(id);
    return <Widget>[
      Semantics(
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
              // compresses like a phone — the chip run is a WIDTH
              // fact, not a window fact. Below 420 the metadata chips
              // drop; below 260 the class/count chips follow (a crushed
              // third pane kept only the fixed chip run and overflowed
              // — live-caught reverify, 2026-11-17).
              final width = constraints.maxWidth;
              final tight = widget.compact || width < 420;
              final crushed = width < 260;
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
                          style: context.laUi.compact,
                        ),
                        if (!tight)
                          if (provider['base_url'] case final url?)
                            Text(
                              '$url',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.laUi.micro.copyWith(
                                fontSize: 10,
                                color: context.la.inkQuiet,
                              ),
                            ),
                      ],
                    ),
                  ),
                  if (!tight) ...[
                    ModelsChip(
                      label: '${provider['transport'] ?? ''}',
                      color: context.la.inkQuiet,
                      mono: true,
                    ),
                    if (provider['credential_env'] case final env?)
                      ModelsChip(
                        label: '$env',
                        color: context.la.accent,
                        mono: true,
                      ),
                  ],
                  if (!crushed) ...[
                    ModelsChip(
                      label: laneClassChipLabel(_classOfDeclared(provider)),
                      color: context.la.inkQuiet,
                      mono: true,
                    ),
                    ModelsChip(
                      label: '$count ${context.l10n.modelsCountSuffix}',
                      color: context.la.inkQuiet,
                    ),
                  ],
                  const SizedBox(width: 6),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    size: 14,
                    color: context.la.inkQuiet,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      if (expanded) ..._providerExpanded(context, id),
    ];
  }

  /// The expanded block: the provider's verb row, then one indented
  /// row per model with its own verbs.
  List<Widget> _providerExpanded(final BuildContext context, final String id) {
    final la = context.la;
    final models = _model.modelsOf(id);
    return <Widget>[
      Padding(
        padding: const EdgeInsets.fromLTRB(33, 2, 12, 2),
        // The verb run wraps like the model rows' chip run: a crushed
        // pane wraps verbs to a second line instead of overflowing.
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ModelsButton(
              keyName: 'models.provider.$id.edit',
              label: context.l10n.modelsEditAction,
              onTap: () => _openProviderForm(editId: id),
            ),
            ModelsButton(
              keyName: 'models.provider.$id.remove',
              label: context.l10n.modelsRemoveAction,
              onTap: () => _model.removeProvider(id),
            ),
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
                Text(modelId, style: LaTokens.mono(11, la.inkMuted)),
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
                    label:
                        'reasoning ${reasoningEffortTitle('$effort')}'
                        '${model['include_reasoning'] == true ? ' · incl' : ''}',
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
            onTap: () =>
                _openModelForm(providerId: providerId, editId: modelId),
          ),
          _ModelIconVerb(
            keyName: 'models.model.$providerId.$modelId.remove',
            icon: Icons.delete_outlined,
            tooltip: context.l10n.modelsRemoveAction,
            onTap: () =>
                _model.removeModel(providerId: providerId, modelId: modelId),
          ),
        ],
      ),
    );
  }

  /// The one form panel under the table: provider fields, or the
  /// DYNAMIC settings list (wave N4). A referenced provider id renders
  /// READ-ONLY with the immutability refusal naming the cast rows.
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
              text:
                  '${context.l10n.modelsRefusalIdImmutable} '
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
                    final next =
                        kTransportWireNames[(index + 1) %
                            kTransportWireNames.length];
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
            // The Zed law at the form level: a lane with no effort
            // tiers names the absence once, and its schema offers no
            // reasoning row at all (never a disabled picker).
            if ((kReasoningEffortTiers[form.transport] ?? const <String>[])
                .isEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  key: const ValueKey('models.reasoning.noLane'),
                  '${context.l10n.modelsReasoningNoLane} ${form.transport}',
                  style: LaTokens.mono(10, la.inkQuiet),
                ),
              ),
            for (final key in (_settings.keys.toList()..sort()))
              _settingRow(context, form, key),
            const SizedBox(height: 8),
            _addSettingRow(context, form),
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

  /// One dynamic settings row (the ZCode/ComfyUI law): the key in mono,
  /// its typed control, and a remove verb. A key outside the lane
  /// schema mirror rides as a raw field with the `unconsumed` marker —
  /// declared, verbatim, honest.
  Widget _settingRow(
    final BuildContext context,
    final _FormState form,
    final String key,
  ) {
    final la = context.la;
    final kind = _kindOf(key);
    final tiers = kReasoningEffortTiers[form.transport] ?? const <String>[];
    return Padding(
      key: ValueKey('models.setting.$key'),
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(
              key,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: LaTokens.mono(10, la.inkMuted),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: switch (kind) {
              _SettingKind.intField || _SettingKind.rawField => Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    child: _formField(
                      keyName: 'models.setting.$key.field',
                      hint: key,
                      controller: _settingCtrls[key]!,
                    ),
                  ),
                  if (kind == _SettingKind.rawField && !_isMirroredKey(key))
                    ModelsChip(
                      label: context.l10n.modelsSettingsUnconsumed,
                      color: la.caution,
                      mono: true,
                    ),
                ],
              ),
              _SettingKind.boolToggle => ModelsButton(
                keyName: 'models.setting.$key.toggle',
                label: _settings[key] == true ? '✓ true' : 'false',
                onTap: () =>
                    setState(() => _settings[key] = _settings[key] != true),
              ),
              _SettingKind.tierPicker =>
                tiers.isEmpty
                    ? Text(
                        key: const ValueKey('models.reasoning.noLane'),
                        '${context.l10n.modelsReasoningNoLane} '
                        '${form.transport}',
                        style: LaTokens.mono(10, la.inkQuiet),
                      )
                    : Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          for (final tier in <String>{
                            ...tiers,
                            if (_settings[key] is String)
                              _settings[key]! as String,
                          })
                            ModelsButton(
                              keyName: 'models.setting.$key.$tier',
                              label: _settings[key] == tier
                                  ? '✓ ${reasoningEffortTitle(tier)}'
                                  : reasoningEffortTitle(tier),
                              onTap: () => setState(
                                () => _settings[key] = _settings[key] == tier
                                    ? null
                                    : tier,
                              ),
                            ),
                        ],
                      ),
            },
          ),
          _ModelIconVerb(
            keyName: 'models.setting.$key.remove',
            icon: Icons.close,
            tooltip: context.l10n.modelsSettingsRemove,
            onTap: () => setState(() {
              _settings.remove(key);
              _settingCtrls.remove(key)?.dispose();
            }),
          ),
        ],
      ),
    );
  }

  /// The add-setting row: the lane schema's undeclared keys as one-tap
  /// adds, plus a free mono key for the growing list (the owner law:
  /// the config list grows and differs per model and per provider).
  Widget _addSettingRow(final BuildContext context, final _FormState form) {
    final tiers = kReasoningEffortTiers[form.transport] ?? const <String>[];
    final schema = <String>[
      'max_tokens',
      'max_output_tokens',
      if (tiers.isNotEmpty) 'reasoning_effort',
      'include_reasoning',
      for (final cap in kCommonCapabilities) 'capabilities.$cap',
    ];
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final key in schema)
          if (!_settings.containsKey(key))
            ModelsButton(
              keyName: 'models.setting.add.$key',
              label: '+ $key',
              onTap: () => setState(() {
                _settings[key] = _kindOf(key) == _SettingKind.boolToggle
                    ? false
                    : null;
                final kind = _kindOf(key);
                if (kind == _SettingKind.intField ||
                    kind == _SettingKind.rawField) {
                  _settingCtrls[key] = TextEditingController();
                }
              }),
            ),
        SizedBox(
          width: 140,
          child: _formField(
            keyName: 'models.setting.add.free',
            hint: context.l10n.modelsSettingsFreeKey,
            controller: _newKeyCtrl,
          ),
        ),
        ModelsButton(
          keyName: 'models.setting.add.confirm',
          label: context.l10n.modelsSettingsAdd,
          onTap: () {
            final key = _newKeyCtrl.text.trim();
            if (key.isEmpty || _settings.containsKey(key)) return;
            setState(() {
              _settings[key] = null;
              final kind = _kindOf(key);
              if (kind == _SettingKind.intField ||
                  kind == _SettingKind.rawField) {
                _settingCtrls[key] = TextEditingController();
              }
              _newKeyCtrl.clear();
            });
          },
        ),
      ],
    );
  }

  String _formTitle(final _FormState form) => switch (form.kind) {
    _FormKind.provider =>
      form.providerId == null
          ? context.l10n.modelsAddProvider
          : '${context.l10n.modelsEditProvider} ${form.providerId}',
    _FormKind.model =>
      form.modelId == null
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
    // The kit field law (borderless → hover fill → focus hairline):
    // the resting canvas fill stays as the form panel's field tone.
    return LaField(
      key: ValueKey(keyName),
      controller: controller,
      readOnly: readOnly,
      style: LaTokens.mono(12, readOnly ? la.inkQuiet : la.ink),
      placeholder: hint,
      placeholderStyle: LaTokens.mono(11, la.inkQuiet),
      fill: la.canvas,
      radius: BorderRadius.circular(ShellTokens.radius),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
  Widget build(final BuildContext context) => LaTooltip(
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

/// The detail sheet's body (2026-11-18 v3): the sensed facts behind the
/// one-line row. The generation line rides the [LocalRuntimeLedger]
/// live (a sheet left open flips from "generating…" to the ≈speed when
/// the run lands); the disk size is a real walk of the snapshot dir —
/// a sensed number, never the download approximation.
final class _LocalModelDetails extends StatelessWidget {
  const _LocalModelDetails({
    required this.local,
    required this.entry,
    super.key,
  });

  final LocalModelsState local;
  final MlxModelCatalogEntry entry;

  @override
  Widget build(final BuildContext context) => ListenableBuilder(
    listenable: LocalRuntimeLedger.instance,
    builder: (final context, final _) {
      final l10n = context.l10n;
      final state = local.stateOf(entry);
      final loaded = state.installed && local.isLoaded(entry);
      final run = localRunForEntry(entry);
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _localDetailRow(
            context,
            l10n.modelsLocalDetailsDisk,
            state.installed
                ? l10n.modelsLocalDiskDownloaded
                : l10n.modelsLocalDiskNot,
          ),
          _localDetailRow(
            context,
            l10n.modelsLocalDetailsMemory,
            !local.hasRuntime
                ? '—'
                : loaded
                ? l10n.modelsLocalMemLoaded
                : l10n.modelsLocalMemUnloaded,
          ),
          FutureBuilder<int?>(
            future: local.diskBytesOf(entry),
            builder: (final context, final snapshot) => _localDetailRow(
              context,
              l10n.modelsLocalDetailsSizeOnDisk,
              snapshot.data == null ? '—' : formatModelBytes(snapshot.data!),
            ),
          ),
          _localDetailRow(
            context,
            l10n.modelsLocalDetailsPath,
            state.snapshotDir ?? '—',
          ),
          _localDetailRow(
            context,
            l10n.modelsLocalDetailsLastGeneration,
            switch ((run?.running, run?.lastTokensPerSecond)) {
              (true, _) => l10n.modelsLocalGenerating,
              (false, final speed?) => l10n.modelsLocalTokPerSec(
                _detailSpeedLabel(speed),
              ),
              _ => '—',
            },
          ),
          if (run?.lastError case final error?)
            _localDetailRow(context, l10n.modelsLocalDetailsLastError, error),
          _localDetailRow(
            context,
            l10n.modelsLocalDetailsUsedBy,
            _actorsBoundTo(entry),
          ),
        ],
      );
    },
  );
}

/// The actors whose brain binding names this entry's cast (phase 3's
/// `used-by` fact): the roster is the mesh doc the shell keeps; a
/// binding whose `local:<cast>` matches any of the entry's casts
/// counts. Empty = nobody binds it right now — an honest absence, not
/// a guess.
String _actorsBoundTo(final MlxModelCatalogEntry entry) {
  final casts = localCastsForEntry(entry).toSet();
  final names = <String>[
    for (final profile
        in StorageBackendsNotifier.instance.ensureActorRoster().all)
      if (profile.brainRef.startsWith('local:') &&
          casts.contains(
            profile.brainRef.substring('local:'.length).split('?').first,
          ))
        profile.displayName,
  ];
  return names.isEmpty ? '—' : names.join(', ');
}

/// One sheet row: the quiet label column, the mono value beside it.
Widget _localDetailRow(
  final BuildContext context,
  final String label,
  final String value,
) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 3),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 120,
        child: Text(label, style: LaTokens.mono(10, context.la.inkQuiet)),
      ),
      Expanded(
        child: Text(
          value,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: LaTokens.mono(11, context.la.inkMuted),
        ),
      ),
    ],
  ),
);

/// The sheet's speed label (the lens's twin: whole tok/s at double
/// digits, one decimal below).
String _detailSpeedLabel(final double tokensPerSecond) => tokensPerSecond >= 10
    ? tokensPerSecond.round().toString()
    : tokensPerSecond.toStringAsFixed(1);
