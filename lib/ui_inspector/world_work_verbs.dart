/// The seat's WORK verbs — the CURRENT law (ADR 0118 D3/D5): delegation
/// is `task {op:'create'}` (creation IS the delegation, the addressing
/// is the delegation), a cast binding is `agent_participation
/// {op:'actor_bind'}`, and `tool_action` stays the allowlisted tool
/// call. The pre-0118 verbs (`resource_bind`, `task_delegate`) answer
/// with a named migration error — this file no longer sends them
/// (leg B G4). The seat-visible palette read (`agent_participation
/// {op:'actions'}`) is unchanged.
///
/// The world is the ONLY source of models and tools: this file parses what
/// the world declares and never invents a default. A refusal is DATA — the
/// harness bounce code, verbatim — not an exception to be rewritten into a
/// generic failure (DESIGN §6, honest surfaces).
///
/// Pure Dart on purpose: the surface owns rendering, this owns the contract.
library;

import 'dart:convert';

/// One palette entry exactly as the world declares it.
final class WorldPaletteEntry {
  const WorldPaletteEntry({
    required this.id,
    required this.kind,
    required this.model,
    required this.provider,
    required this.primary,
    required this.capabilities,
    required this.bound,
  });

  /// The PALETTE ENTRY id (`openrouter_minimax`) — the only id
  /// `resource_bind` accepts. Never a raw provider model string.
  final String id;

  /// `generative` | `decision` | `mechanical` | `humanSeam` |
  /// `externalAgent`.
  final String kind;

  /// The provider model id this entry resolves to. Displayed as data; it is
  /// never sent back to the world (the entry [id] is).
  final String model;
  final String provider;
  final bool primary;
  final List<String> capabilities;

  /// `bound: false` ⇒ `resource_bind` will refuse this id. Shown, not
  /// hidden: an unbound entry is a fact about the world.
  final bool bound;

  /// Parses one entry; null when the row carries no usable id (an entry
  /// without an id cannot be addressed, so it is not invented).
  static WorldPaletteEntry? fromJson(final Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    if (id is! String || id.isEmpty) return null;
    final capabilities = value['capabilities'];
    return WorldPaletteEntry(
      id: id,
      kind: '${value['kind'] ?? ''}',
      model: '${value['model'] ?? ''}',
      provider: '${value['provider'] ?? ''}',
      primary: value['primary'] == true,
      capabilities: capabilities is List
          ? [for (final item in capabilities) '$item']
          : const [],
      bound: value['bound'] == true,
    );
  }
}

/// The seat-visible palette: what the world declares, and which entry each
/// role resolves to.
final class WorldModelPalette {
  const WorldModelPalette({required this.entries, required this.roles});

  factory WorldModelPalette.fromJson(final Object? value) {
    if (value is! Map) return empty;
    final entries = <WorldPaletteEntry>[];
    final rawEntries = value['entries'];
    if (rawEntries is List) {
      for (final item in rawEntries) {
        final entry = WorldPaletteEntry.fromJson(item);
        if (entry != null) entries.add(entry);
      }
    }
    final roles = <String, String>{};
    final rawRoles = value['roles'];
    if (rawRoles is Map) {
      for (final role in rawRoles.entries) {
        final id = role.value;
        if (id is String && id.isNotEmpty) roles['${role.key}'] = id;
      }
    }
    return WorldModelPalette(entries: entries, roles: roles);
  }

  /// The honest empty palette — "no model palette declared for this world".
  static const empty = WorldModelPalette(entries: [], roles: {});

  final List<WorldPaletteEntry> entries;

  /// `generative` / `decision` → palette entry id.
  final Map<String, String> roles;

  bool get isEmpty => entries.isEmpty;

  /// The entry the world declares for [role], when it is present.
  WorldPaletteEntry? entryForRole(final String role) => entryById(roles[role]);

  WorldPaletteEntry? entryById(final String? id) {
    if (id == null) return null;
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }
}

/// One tool the seat may invoke through `tool_action`.
final class WorldToolEntry {
  const WorldToolEntry({required this.name, required this.summary});

  final String name;
  final String summary;

  static WorldToolEntry? fromJson(final Object? value) {
    if (value is! Map) return null;
    final name = value['name'];
    if (name is! String || name.isEmpty) return null;
    return WorldToolEntry(name: name, summary: '${value['summary'] ?? ''}');
  }
}

/// The outcome of one work verb. [bounce] is the harness's own vocabulary,
/// verbatim — the surface renders it as-is.
final class WorldWorkReceipt {
  const WorldWorkReceipt({
    required this.verb,
    required this.ok,
    required this.bounce,
    required this.result,
  });

  final String verb;
  final bool ok;

  /// `model_not_in_palette`, `binding_actor_not_authorized`,
  /// `thread_not_visible`, `decision_purpose_required`,
  /// `decision_resource_unavailable`, … or a transport error string. Null
  /// only when the world accepted the call.
  final String? bounce;

  /// The world's raw response, preserved for callers that need more than
  /// the bounce.
  final Map<String, Object?> result;

  /// One grid line: the verb and what the world said.
  String get label =>
      ok ? '$verb · accepted' : '$verb · ${bounce ?? 'refused'}';
}

/// The seat's work surface: the palette cache plus the three verbs.
///
/// The seat binds ITS OWN actor only — [actor] is the seat's identity, and
/// `resource_bind` for any other actor bounces
/// `binding_actor_not_authorized`. The thread is the seat's own assignment
/// claim (`assignment:<actor>`); a wrong thread bounces `thread_not_visible`.
final class WorldWorkSeat {
  WorldWorkSeat({required this.actor, required this.invoke});

  /// The seat's own actor id, as the world admitted it.
  final String actor;

  /// One allowlisted tool call over the seat (raw: a refusal is data).
  final Future<Map<String, Object?>> Function(
    String name,
    Map<String, Object?> args,
  )
  invoke;

  /// The palette the world declared. Empty until [load] succeeds.
  WorldModelPalette palette = WorldModelPalette.empty;

  /// Why the palette could not be read. Non-null means "I could not look" —
  /// never a fabricated default model.
  String? paletteAbsence;

  /// The tools the seat may invoke, and the menu revision `tool_action`
  /// must echo.
  List<WorldToolEntry> tools = const [];
  String? toolMenuRevision;
  String? toolMenuAbsence;

  bool _loaded = false;
  int _request = 0;
  String? _delegateKey;
  String? _delegateRequest;

  /// The seat's own assignment thread — the claim it holds.
  String get thread => 'assignment:$actor';

  bool get loaded => _loaded;

  /// Reads `actions` once per seat session and caches the palette + tool
  /// menu. A later read whose `toolMenu.revision` differs REPLACES the
  /// cached rows: the revision is the menu's identity, so a changed
  /// revision invalidates everything read before it.
  ///
  /// Never throws: a lane that does not serve `actions` is an honest
  /// absence, not a broken conversation.
  Future<void> load({final bool force = false}) async {
    if (_loaded && !force) return;
    Map<String, Object?> result;
    try {
      result = await invoke('agent_participation', {
        'op': 'actions',
        'toolLimit': 128,
      });
    } on Object catch (error) {
      _absent('$error');
      return;
    }
    if (result['ok'] != true) {
      _absent(_bounceOf(result) ?? 'actions_unavailable');
      return;
    }
    palette = WorldModelPalette.fromJson(result['modelPalette']);
    paletteAbsence = null;
    final menu = result['toolMenu'];
    if (menu is! Map) {
      tools = const [];
      toolMenuRevision = null;
      toolMenuAbsence = 'tool_menu_unavailable';
    } else {
      final revision = menu['revision'];
      toolMenuRevision = revision == null ? null : '$revision';
      final rawTools = menu['tools'];
      tools = [
        if (rawTools is List)
          for (final item in rawTools) ?WorldToolEntry.fromJson(item),
      ];
      toolMenuAbsence = toolMenuRevision == null
          ? 'tool_menu_revision_missing'
          : null;
    }
    _loaded = true;
  }

  void _absent(final String reason) {
    palette = WorldModelPalette.empty;
    paletteAbsence = reason;
    tools = const [];
    toolMenuRevision = null;
    toolMenuAbsence = reason;
    _loaded = true;
  }

  /// `actor_bind` for THIS seat's actor (ADR 0120): the durable row's
  /// brain binding, validated by the world against the declared
  /// palette — an unknown cast bounces with the harness's own code.
  ///
  /// [brainCast] is a PALETTE ENTRY id (`modelscope_qwen38max`) — never
  /// a provider model string.
  Future<WorldWorkReceipt> bindCast({required final String brainCast}) => _verb(
    'agent_participation',
    'actor_bind',
    {'op': 'actor_bind', 'actorId': actor, 'brainCast': brainCast},
  );

  /// `task {op:'create'}` — the human's sentence becomes world work
  /// (ADR 0118: creation IS the delegation). The receipt is an
  /// ADMISSION (`state: queued`), never a completion: the terminal
  /// truth is the durable task record, read back through
  /// `task {op:'show'}`.
  ///
  /// [modelId] is a PALETTE ENTRY id; omitted, the world defaults to
  /// its primary generative rung (leg B G3: the surface should show the
  /// rung it will use and let the human pick). [addressees] are the
  /// actor ids the task is addressed to — the addressing is the
  /// delegation. An identical retry reuses its request id (the host
  /// dedupes exact retries); a new sentence is a new request.
  Future<WorldWorkReceipt> delegate({
    required final String task,
    final String purpose = 'coding',
    final String? modelId,
    final List<String>? addressees,
  }) async {
    final key = jsonEncode([task, purpose, modelId, addressees]);
    if (_delegateKey != key || _delegateRequest == null) {
      _delegateKey = key;
      _delegateRequest = _nextRequest('delegate');
    }
    final receipt = await _verb('task', 'create', {
      'op': 'create',
      'task': task,
      'requestId': _delegateRequest,
      'purpose': purpose,
      if (modelId != null && modelId.isNotEmpty) 'modelId': modelId,
      if (addressees != null && addressees.isNotEmpty) 'addressees': addressees,
    });
    if (receipt.ok) {
      _delegateKey = null;
      _delegateRequest = null;
    }
    return receipt;
  }

  /// Reads the durable state of a delegated task (`task {op:'show'}`) —
  /// the terminal truth behind the admission receipt.
  Future<WorldWorkReceipt> taskState({required final String taskId}) =>
      _verb('task', 'show', {'op': 'show', 'taskId': taskId});

  /// Posts one guidance line to a delegated task's conversation
  /// (`task {op:'say'}`) — the re-delegate-with-guidance loop.
  Future<WorldWorkReceipt> taskSay({
    required final String taskId,
    required final String text,
  }) => _verb('task', 'say', {
    'op': 'say',
    'taskId': taskId,
    'text': text,
    'requestId': _nextRequest('say'),
  });

  /// `tool_action` with the menu revision the world currently serves.
  ///
  /// The menu is re-read first: a stale revision is a wrong revision, and
  /// the read is the only evidence that the revision is current.
  Future<WorldWorkReceipt> toolAction({required final String toolName}) async {
    await load(force: true);
    final revision = toolMenuRevision;
    if (revision == null) {
      return WorldWorkReceipt(
        verb: 'tool_action',
        ok: false,
        bounce: toolMenuAbsence ?? 'tool_menu_unavailable',
        result: const {},
      );
    }
    return _verb('agent_participation', 'tool_action', {
      'op': 'tool_action',
      'requestId': _nextRequest('tool'),
      'thread': thread,
      'toolName': toolName,
      'toolRevision': revision,
    });
  }

  /// One raw call: [tool] is the harness tool name, [verb] the receipt's
  /// label (the op word). A refusal is data — the bounce rides the
  /// receipt, never an exception.
  Future<WorldWorkReceipt> _verb(
    final String tool,
    final String verb,
    final Map<String, Object?> args,
  ) async {
    Map<String, Object?> result;
    try {
      result = await invoke(tool, args);
    } on Object catch (error) {
      return WorldWorkReceipt(
        verb: verb,
        ok: false,
        bounce: '$error',
        result: const {},
      );
    }
    final ok = result['ok'] == true;
    return WorldWorkReceipt(
      verb: verb,
      ok: ok,
      bounce: ok ? null : (_bounceOf(result) ?? 'refused'),
      result: result,
    );
  }

  String _nextRequest(final String verb) =>
      '$verb-${DateTime.now().microsecondsSinceEpoch}-${++_request}';
}

/// The world's refusal code, verbatim. A bounce may be a string or a map
/// carrying `code`; anything else falls back to `error`.
String? _bounceOf(final Map<String, Object?> result) {
  final bounce = result['bounce'];
  if (bounce is String && bounce.isNotEmpty) return bounce;
  if (bounce is Map) {
    final code = bounce['code'];
    if (code is String && code.isNotEmpty) return code;
    return jsonEncode(bounce);
  }
  final error = result['error'];
  if (error is String && error.isNotEmpty) return error;
  return null;
}
