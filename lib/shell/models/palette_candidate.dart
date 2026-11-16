/// Models refactor (2026-11-14, owner-approved design doc
/// docs/design/models-management-refactor-2026-11-14.md) — the CANDIDATE
/// STATE MACHINE, extracted widget-free out of the retired
/// `ProviderEditorDialog` so every lens (catalog table, bindings ladder,
/// JSON lane) edits ONE candidate through ONE verb set, and so the verbs
/// are unit-testable without pumping a single widget.
///
/// The laws it carries, unchanged from the dialog it replaces:
/// * the candidate is a DEEP COPY of the live palette wire document,
///   kept in memory in the host's own wire shape
///   ([paletteWireDocument]); nothing touches the config file until
///   Apply lands through the participation plane's revision verbs;
/// * a referenced provider id is IMMUTABLE and a referenced provider or
///   model cannot be removed — the refusal NAMES the referencing cast
///   rows (structured here, rendered by the UI);
/// * a model rename carries its cast rows with it, so the candidate
///   stays internally consistent;
/// * one receipt validates one previous byte-set, so any mutation
///   drops the receipt (stale by law);
/// * the secret law: `credential_env` is an env NAME only — this model
///   never reads, resolves or renders a value.
///
/// New verbs the refactor adds (the schema always parsed them, the old
/// form simply never offered them): full per-model field edits
/// (`max_tokens`, `max_output_tokens`, `reasoning_effort`,
/// `include_reasoning`, `capabilities`), a persisted `primary` mark and
/// cast-ladder reordering.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show PaletteConfig, paletteFingerprint;

/// The parsed palette re-rendered into the host's OWN wire shape — the
/// key vocabulary the harness parser reads (`parsePaletteConfig`) and
/// serves (`paletteWire`): providers keyed by id with `transport`,
/// `base_url`, `credential_env` and `models[{id, max_tokens,
/// max_output_tokens, reasoning_effort, include_reasoning,
/// capabilities}]`, plus `cast[{id, builtin, provider, model, role,
/// lane, primary}]`. The candidate round-trips through EXACTLY these
/// keys; nothing is invented.
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

/// The lane the candidate lands through — the realm chat service's
/// participation-plane verbs in production
/// (`proposePalette` every seat / `applyPalette` owner-only), a fake in
/// tests. The model never talks to a seat directly.
abstract interface class PaletteVerbLane {
  Future<Map<String, Object?>> propose(final Map<String, Object?> candidate);
  Future<Map<String, Object?>> apply(
    final Map<String, Object?> candidate, {
    final String? expectedBeforeSha256,
  });
}

/// One structured local refusal: a stable [code] the UI maps to its
/// l10n sentence, the [refs] it names (the cast rows blocking a remove
/// or a rename), and a free-text [detail] for decoder messages.
final class CandidateRefusal {
  const CandidateRefusal(this.code, {this.refs = const [], this.detail});

  /// `emptyId` · `duplicateProvider` · `duplicateModel` · `idImmutable`
  /// · `providerInUse` · `modelInUse` · `jsonInvalid` · `noSeat`.
  final String code;
  final List<String> refs;
  final String? detail;
}

/// The in-memory candidate palette and its verb set. Widget-free by
/// law: the lenses render it, the tests drive it, and the dirty bar
/// reads [dirty] / [receipt] / [applyOutcome].
final class PaletteCandidateModel extends ChangeNotifier {
  PaletteCandidateModel({
    required final Map<String, Object?> live,
    this._lane,
  }) : _live = live,
       _candidate = _deepCopy(live) {
    debugLastCandidate = _deepCopy(_candidate);
  }

  Map<String, Object?> _live;
  Map<String, Object?> _candidate;
  final PaletteVerbLane? _lane;

  CandidateRefusal? _refusal;
  Map<String, Object?>? _receipt;
  Map<String, Object?>? _applyOutcome;
  bool _busy = false;

  /// The test seam the dialog owned: the candidate's last published
  /// bytes, so assertions read the MAP diff, never UI pixels.
  static Map<String, Object?>? debugLastCandidate;

  Map<String, Object?> get live => _live;
  Map<String, Object?> get candidate => _candidate;
  CandidateRefusal? get refusal => _refusal;
  Map<String, Object?>? get receipt => _receipt;
  Map<String, Object?>? get applyOutcome => _applyOutcome;
  bool get busy => _busy;
  bool get receiptOk => _receipt?['ok'] == true;

  bool get dirty =>
      paletteFingerprint(_candidate) != paletteFingerprint(_live);

  // ---- read helpers over the wire shape ----

  Map<String, Object?> get providers {
    var raw = _candidate['providers'];
    if (raw is! Map) {
      raw = <String, Object?>{};
      _candidate['providers'] = raw;
    }
    return raw.cast<String, Object?>();
  }

  List<Object?> get cast {
    var raw = _candidate['cast'];
    if (raw is! List) {
      raw = <Object?>[];
      _candidate['cast'] = raw;
    }
    return raw;
  }

  /// The cast rows referencing a provider (the immutability/removal
  /// law's evidence — a refusal NAMES them).
  List<String> castRefs(final String providerId) => <String>[
    for (final entry in cast)
      if (entry is Map && entry['provider'] == providerId) '${entry['id']}',
  ];

  List<String> castModelRefs(
    final String providerId,
    final String modelId,
  ) => <String>[
    for (final entry in cast)
      if (entry is Map &&
          entry['provider'] == providerId &&
          entry['model'] == modelId)
        '${entry['id']}',
  ];

  List<Map<String, Object?>> modelsOf(final String providerId) {
    final raw = providers[providerId];
    final provider = raw is Map ? raw : const <String, Object?>{};
    return <Map<String, Object?>>[
      for (final model in (provider['models'] as List? ?? const <Object?>[]))
        if (model is Map) Map<String, Object?>.from(model),
    ];
  }

  // ---- the edit verbs (in-memory candidate surgery) ----

  bool addProvider({
    required final String id,
    required final String transport,
    final String? baseUrl,
    final String? credentialEnv,
  }) {
    if (id.isEmpty) return _refuse(const CandidateRefusal('emptyId'));
    if (providers.containsKey(id)) {
      return _refuse(CandidateRefusal('duplicateProvider', refs: [id]));
    }
    providers[id] = <String, Object?>{
      'transport': transport,
      'base_url': ?_nonEmpty(baseUrl),
      'credential_env': ?_nonEmpty(credentialEnv),
      'models': <Object?>[],
    };
    return _land();
  }

  bool editProvider({
    required final String oldId,
    required final String id,
    required final String transport,
    final String? baseUrl,
    final String? credentialEnv,
  }) {
    final refs = castRefs(oldId);
    if (id != oldId && refs.isNotEmpty) {
      // The honest refusal: a referenced provider id is IMMUTABLE,
      // naming the referencing cast rows.
      return _refuse(CandidateRefusal('idImmutable', refs: refs));
    }
    if (id.isEmpty) return _refuse(const CandidateRefusal('emptyId'));
    if (id != oldId && providers.containsKey(id)) {
      return _refuse(CandidateRefusal('duplicateProvider', refs: [id]));
    }
    final raw = providers[oldId];
    final map = Map<String, Object?>.from(raw is Map ? raw : const {});
    map['transport'] = transport;
    final url = _nonEmpty(baseUrl);
    if (url == null) {
      map.remove('base_url');
    } else {
      map['base_url'] = url;
    }
    final env = _nonEmpty(credentialEnv);
    if (env == null) {
      map.remove('credential_env');
    } else {
      map['credential_env'] = env;
    }
    if (id != oldId) providers.remove(oldId);
    providers[id] = map;
    return _land();
  }

  bool removeProvider(final String id) {
    final refs = castRefs(id);
    if (refs.isNotEmpty) {
      // Refuse while cast rows reference it, NAMING them.
      return _refuse(CandidateRefusal('providerInUse', refs: refs));
    }
    providers.remove(id);
    return _land();
  }

  /// The full per-model edit the old form never offered: rename plus
  /// every schema field the harness parser reads. Null fields DROP the
  /// key (the wire shape's own omission law); [capabilities] replaces
  /// the declared map whole (the UI carries the undeclared keys through
  /// so an edit never silently drops one). A null [oldId] is the ADD
  /// mode: one upsert verb, one field set, no parallel form lane.
  bool editModel({
    required final String providerId,
    required final String id, final String? oldId,
    final int? maxTokens,
    final int? maxOutputTokens,
    final String? reasoningEffort,
    final bool? includeReasoning,
    final Map<String, bool>? capabilities,
  }) {
    if (id.isEmpty) return _refuse(const CandidateRefusal('emptyId'));
    final models = modelsOf(providerId);
    if (models.any(
      (final model) => model['id'] == id && model['id'] != oldId,
    )) {
      return _refuse(CandidateRefusal('duplicateModel', refs: [id]));
    }
    final fields = <String, Object?>{
      'id': id,
      'max_tokens': ?maxTokens,
      'max_output_tokens': ?maxOutputTokens,
      'reasoning_effort': ?_nonEmpty(reasoningEffort),
      'include_reasoning': ?includeReasoning,
      if (capabilities != null && capabilities.isNotEmpty)
        'capabilities': <String, Object?>{...capabilities},
    };
    return _upsertModel(providerId, id, oldId, fields);
  }

  /// The dynamic config editor's verb (wave N4, the ZCode/ComfyUI
  /// law): [settings] is the model row minus `id`, with capabilities
  /// flattened as `capabilities.<key>`; ANY other key rides VERBATIM
  /// (the harness parser tolerates unknown model keys; the editor
  /// marks them unconsumed instead of hiding them). Null-valued keys
  /// are dropped (the wire shape's omission law).
  bool editModelSettings({
    required final String providerId,
    required final String id,
    required final Map<String, Object?> settings,
    final String? oldId,
  }) {
    if (id.isEmpty) return _refuse(const CandidateRefusal('emptyId'));
    final caps = <String, Object?>{
      for (final entry in settings.entries)
        if (entry.key.startsWith('capabilities.'))
          entry.key.substring('capabilities.'.length): entry.value,
    };
    final fields = <String, Object?>{
      'id': id,
      for (final entry in settings.entries)
        if (!entry.key.startsWith('capabilities.'))
          entry.key:
              entry.value,
      if (caps.isNotEmpty) 'capabilities': caps,
    };
    return _upsertModel(providerId, id, oldId, fields);
  }

  /// The ONE upsert: add mode (null [oldId]) appends, edit mode
  /// replaces in place, and the cast rows that rode a renamed model id
  /// FOLLOW the rename — the candidate stays internally consistent.
  bool _upsertModel(
    final String providerId,
    final String id,
    final String? oldId,
    final Map<String, Object?> fields,
  ) {
    final models = modelsOf(providerId);
    if (models.any(
      (final model) => model['id'] == id && model['id'] != oldId,
    )) {
      return _refuse(CandidateRefusal('duplicateModel', refs: [id]));
    }
    if (oldId == null) {
      models.add(fields);
      _writeModels(providerId, models);
      return _land();
    }
    var touched = false;
    for (var i = 0; i < models.length; i++) {
      if (models[i]['id'] != oldId) continue;
      models[i] = fields;
      touched = true;
    }
    if (!touched) {
      return _refuse(CandidateRefusal('duplicateModel', refs: [oldId]));
    }
    _writeModels(providerId, models);
    if (oldId != id) {
      for (final entry in cast) {
        if (entry is Map &&
            entry['provider'] == providerId &&
            entry['model'] == oldId) {
          entry['model'] = id;
        }
      }
    }
    return _land();
  }

  bool removeModel({
    required final String providerId,
    required final String modelId,
  }) {
    final refs = castModelRefs(providerId, modelId);
    if (refs.isNotEmpty) {
      return _refuse(CandidateRefusal('modelInUse', refs: refs));
    }
    _writeModels(providerId, [
      for (final model in modelsOf(providerId))
        if (model['id'] != modelId) model,
    ]);
    return _land();
  }

  /// The persisted primary mark: ONE cast entry carries `primary`
  /// (the realm's default mover) — setting it clears every other.
  bool setPrimary(final String castId) {
    var found = false;
    for (final entry in cast) {
      if (entry is! Map) continue;
      if (entry['id'] == castId) {
        entry['primary'] = true;
        found = true;
      } else {
        entry.remove('primary');
      }
    }
    if (!found) return _refuse(CandidateRefusal('emptyId', refs: [castId]));
    return _land();
  }

  /// The escalation ladder's order IS the cast list's order: move one
  /// entry to [toIndex] (clamped), the wave-C insert-at-index law.
  bool moveCast(final String castId, final int toIndex) {
    final list = cast;
    final from = list.indexWhere(
      (final entry) => entry is Map && entry['id'] == castId,
    );
    if (from < 0) return _refuse(CandidateRefusal('emptyId', refs: [castId]));
    final entry = list.removeAt(from);
    final at = toIndex.clamp(0, list.length);
    list.insert(at, entry);
    return _land();
  }

  /// The JSON lane: the raw document view (the Zed rule). A decode
  /// failure or a non-object root is a named refusal — the candidate
  /// keeps its last valid shape, never a half-parse.
  void replaceFromJson(final String text) {
    Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException catch (error) {
      _refuse(CandidateRefusal('jsonInvalid', detail: error.message));
      return;
    }
    if (decoded is! Map) {
      _refuse(
        const CandidateRefusal(
          'jsonInvalid',
          detail: 'the root must be an object',
        ),
      );
      return;
    }
    _candidate = decoded.cast<String, Object?>();
    _land();
  }

  /// The one local refusal no verb owns: a numeric field that is not a
  /// number. The UI names it; the candidate keeps its shape.
  void refuseBadNumber() => _refuse(const CandidateRefusal('badNumber'));

  /// Cancel reverts to live — the candidate, the receipt and every
  /// note drop; the lenses stay on the truth.
  void revert() {
    _candidate = _deepCopy(_live);
    _receipt = null;
    _applyOutcome = null;
    _refusal = null;
    _touch();
  }

  /// The external truth moved (a refresh re-read the config, an apply
  /// landed elsewhere): an clean candidate adopts it wholesale; a
  /// DIRTY one keeps its edits and only re-anchors the dirty compare.
  /// Receipts drop either way — they validated older bytes.
  void rebase(final Map<String, Object?> newLive) {
    // The dirty verdict is against the OLD live: after the swap every
    // candidate would read dirty and a clean one would never adopt.
    final wasDirty = dirty;
    _live = newLive;
    if (!wasDirty) _candidate = _deepCopy(newLive);
    _receipt = null;
    _applyOutcome = null;
    _publish();
  }

  // ---- the propose → receipt → apply lane (the host's verbs) ----

  Future<void> propose() async {
    final lane = _lane;
    if (lane == null) {
      _refuse(const CandidateRefusal('noSeat'));
      return;
    }
    if (_busy) return;
    _busy = true;
    _refusal = null;
    _applyOutcome = null;
    notifyListeners();
    final receipt = await lane.propose(_deepCopy(_candidate));
    _busy = false;
    _receipt = receipt;
    notifyListeners();
  }

  Future<void> apply() async {
    final lane = _lane;
    if (lane == null) {
      _refuse(const CandidateRefusal('noSeat'));
      return;
    }
    if (_busy || !receiptOk) return;
    _busy = true;
    _refusal = null;
    notifyListeners();
    final before = _receipt?['beforeSha256'];
    final outcome = await lane.apply(
      _deepCopy(_candidate),
      expectedBeforeSha256: before is String ? before : null,
    );
    _busy = false;
    _applyOutcome = outcome;
    if (outcome['ok'] == true) {
      // The apply consumed the receipt; the candidate is now the live
      // declaration (the read model re-reads the landed file). The
      // outcome note SURVIVES (the dirty bar renders 'applied · rev'),
      // so this path publishes without the touch's note-clearing.
      _receipt = null;
      _live = _deepCopy(_candidate);
      _publish();
    } else {
      notifyListeners();
    }
  }

  // ---- internals ----

  void _writeModels(
    final String providerId,
    final List<Map<String, Object?>> models,
  ) {
    final raw = providers[providerId];
    final provider = Map<String, Object?>.from(raw is Map ? raw : const {});
    provider['models'] = <Object?>[...models];
    providers[providerId] = provider;
  }

  bool _refuse(final CandidateRefusal refusal) {
    _refusal = refusal;
    notifyListeners();
    return false;
  }

  /// One candidate mutation landed: a receipt validated the PREVIOUS
  /// bytes, so it is stale by law; the test seam re-publishes.
  bool _land() {
    _refusal = null;
    _touch();
    return true;
  }

  void _touch() {
    _receipt = null;
    _applyOutcome = null;
    _publish();
  }

  void _publish() {
    debugLastCandidate = _deepCopy(_candidate);
    notifyListeners();
  }

  static String? _nonEmpty(final String? value) {
    final trimmed = value?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }
}

/// The deep copy of a wire document (JSON-safe values by construction —
/// the round-trip IS the copy law; no shared mutable state between the
/// live palette and the candidate).
Map<String, Object?> _deepCopy(final Map<String, Object?> doc) =>
    jsonDecode(jsonEncode(doc))! as Map<String, Object?>;
