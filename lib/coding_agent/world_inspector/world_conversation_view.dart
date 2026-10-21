import 'dart:async';
import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:lastanswer/coding_agent/world_inspector/external_worlds_stub.dart'
    if (dart.library.io) 'package:lastanswer/coding_agent/world_inspector/external_worlds_io.dart'
    as worlds;
import 'package:lastanswer/coding_agent/world_inspector/world_binding.dart';
import 'package:lastanswer/coding_agent/world_inspector/world_seats.dart';

/// A human seat on the selected existing world. Displayed messages are owner
/// receipts, never a second locally authored transcript or an embedded task.
class WorldConversationView extends StatefulWidget {
  const WorldConversationView({
    required this.binding,
    this.worldResolver,
    this.seatRequester,
    super.key,
  });
  final WorldBindingModel binding;
  final Future<DiscoveredWorld?> Function(WorldBindingModel)? worldResolver;
  final Future<WorldSeatLease?> Function(DiscoveredWorld)? seatRequester;
  static final _mountedViews = <WorldConversationViewState>{};
  static List<WorldConversationViewState> get _currentViews => [
    for (final view in _mountedViews)
      if (view.mounted && (ModalRoute.of(view.context)?.isCurrent ?? true))
        view,
  ];
  static int get mountedViewCount => _mountedViews.length;
  static int get currentViewCount => _currentViews.length;
  static WorldConversationViewState? get active {
    final views = _currentViews;
    return views.length == 1 ? views.single : null;
  }

  @override
  State<WorldConversationView> createState() => WorldConversationViewState();
}

class WorldConversationViewState extends State<WorldConversationView> {
  final _input = TextEditingController();
  WorldSeatLease? _lease;
  late DiscoveredWorld _world;
  Timer? _timer;
  late bool _busy = false;
  late bool _refreshing = false;
  String? _error;
  String? _selected;
  late int _cursor = 0;
  late List<Map<String, Object?>> _subjects = [];
  final _events = <Map<String, Object?>>[];
  String? _pendingRequest;
  String? _pendingText;
  String? _pendingConversation;
  String? _pendingRecipient;
  Map<String, Object?>? _pendingConsent;
  String? _pendingConsentSpec;
  int _connectionEpoch = 0;

  /// WHO is on this world (the roster) and WHAT is open (the frontier).
  ///
  /// Both come from the participant delta (`agent_context {op:'delta'}`) — the
  /// seat-scoped surface. The operator projection (`agent_doc_state`) is not
  /// available to a seat, and the world is the only roster: a pane that
  /// keeps its own list of actors is a second truth.
  List<Map<String, Object?>> _presence = [];
  List<Map<String, Object?>> _frontier = [];
  List<Map<String, Object?>> _claims = [];

  /// The actor the next message is ADDRESSED to (a whisper). Null → the
  /// message is broadcast on the selected conversation.
  String? _recipient;

  /// The selected task's WORK — the world's BEATS (tool results, effects,
  /// reports, verification), not the participation receipts. The world is
  /// the only source: this list is exactly what the world's cut served.
  List<Map<String, Object?>> _work = [];

  /// Why the world did NOT serve a beat list. Non-null means "I could not
  /// look" — never an empty-but-confident list that reads as "no work
  /// happened" (the honest absence law).
  String? _workAbsence;

  /// The beats the world's own view omitted (budget/rank). Non-zero means
  /// the list is a window, not the whole task.
  int _workOmitted = 0;

  /// Guards a stale work read from overwriting a newer one.
  int _workEpoch = 0;

  Map<String, Object?> get projection => {
    'worldId': widget.binding.worldId,
    'connected': _lease != null,
    'actor': _lease?.actor,
    'conversation': _selected,
    'subjects': _subjects,
    'events': _events
        .where((event) => (event['anchor'] as Map?)?['id'] == _selected)
        .toList(),
    'cursor': _cursor,
    'error': _error,
    'presence': _presence,
    'frontier': _frontier,
    'claims': _claims,
    'recipient': _recipient,
    'work': _work,
    'workAbsence': _workAbsence,
    'workOmitted': _workOmitted,
  };

  @override
  void initState() {
    super.initState();
    WorldConversationView._mountedViews.add(this);
    unawaited(connect());
  }

  @override
  void reassemble() {
    // Existing mounted states must enter the registry when this repair is
    // hot-reloaded; initState is deliberately not repeated by Flutter.
    WorldConversationView._mountedViews.add(this);
    super.reassemble();
  }

  Future<Map<String, Object?>> _call(Map<String, Object?> arguments) async {
    final world = _world;
    final result = await WorldSeatChannel.call(
      _lease!,
      seatWs: world.seatWs,
      token: world.token,
      name: 'agent_participation',
      args: arguments,
    );
    if (result['ok'] != true) throw StateError('${result['bounce'] ?? result}');
    return result;
  }

  /// The participant context surface (the seat-scoped world read). Separate
  /// from [ _call ] because the remote lane serves the participation verbs
  /// only — a missing surface is an honest absence, not a crash.
  /// The seat's context surface, RAW: a refusal is DATA (a named bounce), not
  /// an exception, so the work list can say honestly WHY the world did not
  /// serve beats instead of pretending there were none.
  Future<Map<String, Object?>> _contextRaw(Map<String, Object?> arguments) {
    final world = _world;
    return WorldSeatChannel.call(
      _lease!,
      seatWs: world.seatWs,
      token: world.token,
      name: 'agent_context',
      args: arguments,
    );
  }

  Future<Map<String, Object?>> _callContext(
    Map<String, Object?> arguments,
  ) async {
    final result = await _contextRaw(arguments);
    if (result['ok'] != true) throw StateError('${result['bounce'] ?? result}');
    return result;
  }

  Future<void> connect() async {
    if (_busy) return;
    _connectionEpoch++;
    _timer?.cancel();
    _busy = true;
    try {
      await _lease?.disconnect?.call();
      _lease = null;
      final world = await (widget.worldResolver ?? worlds.rediscover)(
        widget.binding,
      );
      if (world == null || world.localSeatSocket.isEmpty) {
        throw StateError('No local MCP seat advertised for this world');
      }
      _world = world;
      final lease =
          await (widget.seatRequester?.call(world) ??
              WorldSeatChannel.request(
                seatWs: world.seatWs,
                token: world.token,
                localSocket: world.localSeatSocket,
                docId: world.workspace,
                actor: 'lastanswer-human',
              ));
      if (!mounted) {
        await lease?.disconnect?.call();
        return;
      }
      _lease = lease;
      if (_lease == null) throw StateError('World refused the human seat');
      final subjects = await _call({'op': 'subjects', 'limit': 100});
      if (!mounted) return;
      final ownConversation = 'assignment:${lease!.actor}';
      _subjects = [
        for (final row in (subjects['subjects']! as List).cast<Map>())
          if ((row['anchor'] as Map?)?['kind'] == 'task')
            Map<String, Object?>.from(row),
      ];
      if (!_subjects.any(
        (row) => (row['anchor'] as Map?)?['id'] == _selected,
      )) {
        _selected =
            _subjects.any(
              (row) => (row['anchor'] as Map?)?['id'] == ownConversation,
            )
            ? ownConversation
            : null;
      }
      _error = null;
      _timer?.cancel();
      _timer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => unawaited(refresh()),
      );
    } on Object catch (error) {
      _error = '$error';
      final failed = _lease;
      _lease = null;
      try {
        await failed?.disconnect?.call();
      } on Object {
        // Preserve the original admission/discovery failure.
      }
    } finally {
      _busy = false;
      if (mounted) setState(() {});
    }
    if (mounted && _lease != null) await refresh();
  }

  Future<void> refresh() async {
    if (!mounted || _busy || _refreshing || _lease == null) return;
    final epoch = _connectionEpoch;
    _refreshing = true;
    try {
      final result = await _call({
        'op': 'events',
        'afterSequence': _cursor,
        'limit': 24,
      });
      if (!mounted || epoch != _connectionEpoch) return;
      for (final event in result['events']! as List) {
        final row = Map<String, Object?>.from(event as Map);
        if (!_events.any((prior) => prior['beat'] == row['beat'])) {
          _events.add(row);
        }
      }
      _cursor = result['cursor']! as int;
      await _refreshWorldState();
      await _refreshWork();
      _error = null;
    } on Object catch (error) {
      if (mounted && epoch == _connectionEpoch) _error = '$error';
    } finally {
      _refreshing = false;
      if (mounted) setState(() {});
    }
  }

  /// The selected task's WORK — the world's BEATS (tool results, effects,
  /// reports, verification), not the participation receipts.
  ///
  /// The world is the only source: this is the world's own cut for the
  /// task's thread, read through the seat-scoped `agent_context {op:'cut'}`
  /// surface the harness already owns. A lane that does not serve it (the
  /// remote WebSocket cockpit may) is an HONEST ABSENCE — the list says
  /// "I could not look", never an empty list that reads as "no work
  /// happened".
  Future<void> _refreshWork() async {
    final thread = _selected;
    if (thread == null) {
      if (_work.isNotEmpty || _workAbsence != null) {
        _work = const [];
        _workAbsence = null;
        _workOmitted = 0;
      }
      return;
    }
    final epoch = _workEpoch + 1;
    _workEpoch = epoch;
    final result = await _contextRaw({
      'op': 'cut',
      'threads': [thread],
      'budgetTokens': 2048,
    });
    if (!mounted || epoch != _workEpoch) return;
    if (result['ok'] != true) {
      // A refusal is DATA: name it, do not pretend the task was idle.
      _work = const [];
      _workOmitted = 0;
      _workAbsence =
          '${result['bounce'] ?? result['message'] ?? 'context_unavailable'}';
      return;
    }
    final beats = result['beats'];
    final rows = <Map<String, Object?>>[];
    if (beats is List) {
      for (final beat in beats) {
        if (beat is! Map) continue;
        final text = '${beat['text'] ?? beat['preview'] ?? ''}'.trim();
        if (text.isEmpty) continue;
        rows.add({
          'beatId': beat['beatId'],
          'kind': '${beat['kind'] ?? 'observation'}',
          'speakerId': beat['speakerId'],
          'text': text,
        });
      }
    }
    _work = rows;
    // The world's own view may have omitted rows (budget/rank): the list
    // is then a WINDOW, and the pane says so rather than implying
    // completeness.
    final omitted = result['omitted'];
    _workOmitted = omitted is List ? omitted.length : 0;
    _workAbsence = null;
  }

  /// The participant delta: WHO is here, WHAT is open, WHO holds it.
  ///
  /// The remote (WebSocket) lane serves only the cockpit verbs, so the
  /// roster is empty there — an honest absence, never a second list. The
  /// world is the only roster: a pane that keeps its own copy of the actors
  /// is a second truth.
  Future<void> _refreshWorldState() async {
    try {
      final delta = await _callContext({'op': 'delta'});
      _presence = _rows(delta['presence']);
      _frontier = _rows(delta['frontier']);
      _claims = _rows(delta['claims']);
    } on Object {
      // The lane does not serve the participant delta; the roster stays
      // empty rather than being invented.
    }
  }

  static List<Map<String, Object?>> _rows(Object? value) {
    final rows = <Map<String, Object?>>[];
    if (value is! List) return rows;
    for (final row in value) {
      if (row is! Map) continue;
      final copy = <String, Object?>{};
      for (final entry in row.entries) {
        copy['${entry.key}'] = entry.value;
      }
      rows.add(copy);
    }
    return rows;
  }

  Future<Map<String, Object?>> send(
    String text, {
    String? conversation,
    String? recipient,
  }) async {
    if (_busy || _lease == null) throw StateError('Seat is not ready');
    if (text.trim().isEmpty) throw StateError('Message is empty');
    final selected = conversation ?? _selected;
    if (selected == null ||
        !_subjects.any((row) => (row['anchor']! as Map)['id'] == selected)) {
      throw StateError('Choose a visible conversation');
    }
    final target = recipient ?? _recipient;
    if (_pendingRequest == null ||
        _pendingText != text ||
        _pendingConversation != selected ||
        _pendingRecipient != target) {
      _pendingRequest = 'human-${DateTime.now().microsecondsSinceEpoch}';
      _pendingText = text;
      _pendingConversation = selected;
      _pendingRecipient = target;
    }
    _busy = true;
    late Map<String, Object?> result;
    try {
      final message = <String, Object?>{
        'op': 'message',
        'requestId': _pendingRequest,
        'anchor': {'kind': 'task', 'id': selected},
        'text': text,
      };
      // ADR 0077: a whisper NAMES its audience; a broadcast reaches every
      // actor. An addressed message is what wakes one seat (the addressed
      // idle-wake path) — a broadcast only reaches whoever polls.
      if (target == null) {
        message['broadcast'] = true;
      } else {
        message['recipients'] = [target];
      }
      result = await _call(message);
      final receipt = result['interaction'];
      if (receipt is Map &&
          !_events.any((event) => event['beat'] == receipt['beat'])) {
        _events.add(Map<String, Object?>.from(receipt));
      }
      _pendingRequest = null;
    } finally {
      _busy = false;
    }
    _selected = selected;
    if (mounted) _input.clear();
    await refresh();
    return result;
  }

  /// This is a bounded human statement on the world conversation. Only the
  /// owner can decide whether its speaker, target and scope confer authority.
  Future<Map<String, Object?>> taskConsent({
    required String taskId,
    required String recipientActor,
    required List<String> paths,
    required int durationSeconds,
    bool revoke = false,
  }) async {
    if (_busy || _lease == null) throw StateError('Seat is not ready');
    final selected = _selected;
    if (selected == null ||
        !_subjects.any((row) => (row['anchor']! as Map)['id'] == selected) ||
        !_subjects.any((row) => (row['anchor']! as Map)['id'] == taskId)) {
      throw StateError('Choose a visible conversation and task');
    }
    if (recipientActor.trim().isEmpty ||
        recipientActor.trim() != recipientActor ||
        durationSeconds < 1 ||
        durationSeconds > 3600 ||
        paths.isEmpty ||
        paths.any(
          (path) =>
              path.isEmpty ||
              path.startsWith('/') ||
              path.contains(r'\') ||
              RegExp(r'[*?\[\]{}]').hasMatch(path) ||
              path
                  .split('/')
                  .any((part) => part.isEmpty || part == '.' || part == '..'),
        ) ||
        paths.toSet().length != paths.length) {
      throw StateError('Use an actor, exact relative paths and 1–3600 seconds');
    }
    final spec = jsonEncode([
      selected,
      taskId,
      recipientActor,
      paths,
      durationSeconds,
      revoke,
    ]);
    if (_pendingConsentSpec != spec || _pendingConsent == null) {
      final expiresAt = DateTime.now()
          .toUtc()
          .add(Duration(seconds: durationSeconds))
          .toIso8601String();
      _pendingConsentSpec = spec;
      _pendingConsent = {
        'op': 'message',
        'requestId': 'human-consent-${DateTime.now().microsecondsSinceEpoch}',
        'broadcast': true,
        'preset': revoke ? 'task_consent_revoke' : 'task_consent',
        'anchor': {'kind': 'task', 'id': selected},
        'text':
            '${revoke ? 'Revoke' : 'Authorize'} $recipientActor for task '
            '$taskId on exactly ${paths.join(', ')} until $expiresAt. '
            'The host must verify changes and preserve targeted Undo.',
        'attachments': [
          {
            'kind': 'conventional_task_consent',
            'taskId': taskId,
            'recipientActor': recipientActor,
            'writablePaths': paths,
            'expiresAt': expiresAt,
          },
        ],
      };
    }
    _busy = true;
    if (mounted) setState(() {});
    try {
      final result = await _call(_pendingConsent!);
      final receipt = result['interaction'];
      if (receipt is Map &&
          !_events.any((event) => event['beat'] == receipt['beat'])) {
        _events.add(Map<String, Object?>.from(receipt));
      }
      _pendingConsent = null;
      _pendingConsentSpec = null;
      _error = null;
      return result;
    } finally {
      _busy = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _showTaskConsent() async {
    var actor = '';
    var paths = '';
    final form = GlobalKey<FormState>();
    var task = _selected;
    var minutes = 15;
    try {
      final revoke = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) => AlertDialog(
            title: Text(context.l10n.worldTaskPermission),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Form(
                  key: form,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.l10n.worldTaskPermissionHint),
                      DropdownButtonFormField<String>(
                        key: const Key('world_conversation.consent.task'),
                        initialValue: task,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: context.l10n.worldTaskTarget,
                        ),
                        items: [
                          for (final row in _subjects)
                            DropdownMenuItem(
                              value: (row['anchor']! as Map)['id'] as String,
                              child: Text(
                                row['label']! as String,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (value) => update(() => task = value),
                      ),
                      TextFormField(
                        key: const Key('world_conversation.consent.actor'),
                        onChanged: (value) => actor = value,
                        decoration: InputDecoration(
                          labelText: context.l10n.worldTaskActor,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.worldTaskRequired
                            : null,
                      ),
                      TextFormField(
                        key: const Key('world_conversation.consent.paths'),
                        onChanged: (value) => paths = value,
                        minLines: 2,
                        maxLines: 5,
                        decoration: InputDecoration(
                          labelText: context.l10n.worldTaskPaths,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.worldTaskRequired
                            : null,
                      ),
                      DropdownButtonFormField<int>(
                        key: const Key('world_conversation.consent.duration'),
                        initialValue: minutes,
                        decoration: InputDecoration(
                          labelText: context.l10n.worldTaskMinutes,
                        ),
                        items: [
                          for (final value in [5, 15, 30, 60])
                            DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            ),
                        ],
                        onChanged: (value) => update(() => minutes = value!),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                key: const Key('world_conversation.consent.cancel'),
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.l10n.cancel),
              ),
              TextButton(
                key: const Key('world_conversation.consent.revoke'),
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(dialogContext, true);
                  }
                },
                child: Text(context.l10n.worldTaskRevoke),
              ),
              TextButton(
                key: const Key('world_conversation.consent.authorize'),
                onPressed: () {
                  if (form.currentState!.validate()) {
                    Navigator.pop(dialogContext, false);
                  }
                },
                child: Text(context.l10n.worldTaskAuthorize),
              ),
            ],
          ),
        ),
      );
      if (revoke == null || task == null || !mounted) return;
      await taskConsent(
        taskId: task!,
        recipientActor: actor.trim(),
        paths: paths
            .split('\n')
            .map((path) => path.trim())
            .where((path) => path.isNotEmpty)
            .toList(),
        durationSeconds: minutes * 60,
        revoke: revoke,
      );
    } on Object catch (error) {
      if (mounted) setState(() => _error = '$error');
    }
  }

  @override
  void dispose() {
    _connectionEpoch++;
    WorldConversationView._mountedViews.remove(this);
    _timer?.cancel();
    unawaited(_lease?.disconnect?.call());
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'WORLD · ${widget.binding.displayName}',
        style: Theme.of(context).textTheme.labelSmall,
      ),
      Row(
        children: [
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selected,
              hint: Text(context.l10n.worldConversationChoose),
              items: [
                for (final row in _subjects)
                  DropdownMenuItem(
                    value: (row['anchor']! as Map)['id'] as String,
                    child: Text(
                      row['label']! as String,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() => _selected = value),
            ),
          ),
          TextButton(
            onPressed: _busy ? null : connect,
            child: Text(
              _lease == null
                  ? context.l10n.connectWithToken
                  : context.l10n.worldConversationReconnect,
            ),
          ),
          TextButton(
            key: const Key('world_conversation.consent'),
            onPressed: _lease == null || _busy || _selected == null
                ? null
                : _showTaskConsent,
            child: Text(context.l10n.worldTaskPermission),
          ),
        ],
      ),
      Expanded(
        child: ListView(
          children: [
            if (_error != null) SelectableText(_error!),
            if (_presence.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final row in _presence)
                      if (row['actor'] is String)
                        ChoiceChip(
                          key: Key('world_conversation.actor.${row['actor']}'),
                          label: Text('${row['actor']}'),
                          selected: _recipient == row['actor'],
                          onSelected: (selected) {
                            final actor = row['actor'] as String?;
                            setState(
                              () => _recipient = selected ? actor : null,
                            );
                          },
                        ),
                  ],
                ),
              ),
            for (final step in _frontier)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SelectableText(
                  'OPEN  ${step['title']}'
                  '${step['ready'] == true ? '  (claimable)' : ''}',
                ),
              ),
            for (final claim in _claims)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: SelectableText(
                  'HELD  ${claim['claim']}  ·  ${claim['claimedBy']}',
                ),
              ),
            for (final event in _events)
              if ((event['anchor'] as Map?)?['id'] == _selected)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: SelectableText(
                    '${event['speaker']}  ${event['text']}',
                  ),
                ),
            // The task's WORK: the world's beats, not the receipts above.
            // An honest absence when the world did not serve them.
            if (_selected != null && _workAbsence != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SelectableText(
                  'WORK  not available  ·  $_workAbsence',
                  key: const Key('world_conversation.work.absence'),
                ),
              ),
            for (final work in _work)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SelectableText(
                  'WORK  ${work['kind']}'
                  '${work['speakerId'] == null ? '' : '  ${work['speakerId']}'}'
                  '  ${work['text']}',
                  key: Key('world_conversation.work.${work['beatId']}'),
                ),
              ),
            if (_workOmitted > 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: SelectableText(
                  'WORK  +$_workOmitted more row(s) the world did not serve.',
                  key: const Key('world_conversation.work.omitted'),
                ),
              ),
          ],
        ),
      ),
      Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('world_conversation.input'),
              controller: _input,
              decoration: InputDecoration(
                hintText: context.l10n.worldConversationHint,
              ),
              onSubmitted: (text) async {
                try {
                  await send(text);
                } on Object catch (error) {
                  if (mounted) setState(() => _error = '$error');
                }
              },
            ),
          ),
          TextButton(
            key: const Key('world_conversation.send'),
            onPressed: _lease == null || _busy
                ? null
                : () async {
                    try {
                      await send(_input.text);
                    } on Object catch (error) {
                      if (mounted) setState(() => _error = '$error');
                    }
                  },
            child: Text(context.l10n.worldConversationSend),
          ),
        ],
      ),
      Text(
        context.l10n.worldConversationPublic,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    ],
  );
}
