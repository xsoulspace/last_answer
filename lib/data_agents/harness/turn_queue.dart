import 'dart:convert';

/// PLAN 9 — "Queue + cooled turns" (ADR 0011 §"Implementation mapping —
/// the queue rides the frontier"). A queued user message is a STEP on the
/// frontier, not a chat-app FIFO row: it records *intent* (`claim` =
/// the message text) with step-shaped status `open | superseded |
/// delivered` — cancellation is `superseded` (queryable, never silently
/// dropped — DESIGN §4/§6), delivery is `delivered` (the flush turned it
/// into the next turn's prompt).
///
/// Lanes (ADR 0011 D5): every entry is keyed by its directed actor→actor
/// pair ([QueueStep.from]/[QueueStep.to]) — the first implementation runs
/// the DEFAULT lane only (human→session agent), but the data shape makes
/// further lanes additive, not a rewrite.
enum QueueStepStatus { open, superseded, delivered }

/// One queued user message: a step on the frontier (ADR 0011).
final class QueueStep {
  QueueStep({
    required this.id,
    required this.text,
    required this.createdAt,
    this.from = 'human',
    this.to = 'agent',
    this.status = QueueStepStatus.open,
    this.immediate = false,
    this.deliveredAt,
  });

  factory QueueStep.fromJson(final Map<String, Object?> json) => QueueStep(
    id: json['id']! as String,
    text: json['text']! as String,
    createdAt: DateTime.parse(json['createdAt']! as String),
    from: (json['from'] as String?) ?? 'human',
    to: (json['to'] as String?) ?? 'agent',
    status: QueueStepStatus.values.firstWhere(
      (final s) => s.name == json['status'],
      orElse: () => QueueStepStatus.open,
    ),
    immediate: (json['immediate'] as bool?) ?? false,
    deliveredAt: json['deliveredAt'] == null
        ? null
        : DateTime.parse(json['deliveredAt']! as String),
  );

  static String newId() =>
      'q-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';

  final String id;

  /// The step's claim — the message text. Editable while `open` (edit
  /// queued = edit the claim before it is worked).
  String text;
  final DateTime createdAt;

  /// The directed lane (ADR 0011 D5): queued *for* [to] *by* [from].
  final String from;
  final String to;
  QueueStepStatus status;

  /// Send-now: deliver FIRST when the running turn lands (before other
  /// open steps). A no-op when the session is idle — an immediate submit
  /// while idle is just today's direct send.
  bool immediate;
  DateTime? deliveredAt;

  Map<String, Object?> toJson() => {
    'id': id,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
    'from': from,
    'to': to,
    'status': status.name,
    'immediate': immediate,
    'deliveredAt': ?deliveredAt?.toIso8601String(),
  };
}

/// The queue-as-graph, first implementation: a linear frontier (one
/// branch, the drawn one — ADR 0011 D3's honest degradation). Carries ALL
/// steps (open, superseded, delivered) so cancellation stays queryable,
/// and serializes into the doc payload (durable + syncable; the
/// migration gate to frontier entities in `xsoulspace_agentic_doc` is
/// ADR 0011's graph gate, not this first gate).
final class TurnQueue {
  final List<QueueStep> steps = [];

  /// The next open step to deliver in [from]'s lane: send-now steps
  /// first (they rejected/stop the running turn), then submission order.
  QueueStep? nextOpen({final String from = 'human'}) {
    final open = openInLane(from: from).toList();
    if (open.isEmpty) return null;
    open.sort((final a, final b) {
      if (a.immediate != b.immediate) return a.immediate ? -1 : 1;
      return a.createdAt.compareTo(b.createdAt);
    });
    return open.first;
  }

  /// Open steps in a lane, in submission order (the rendered queue).
  Iterable<QueueStep> openInLane({final String from = 'human'}) => steps
      .where((final s) => s.from == from && s.status == QueueStepStatus.open);

  QueueStep? byId(final String id) =>
      steps.where((final s) => s.id == id).firstOrNull;

  QueueStep enqueue(
    final String text, {
    final String from = 'human',
    final String to = 'agent',
    final bool immediate = false,
  }) {
    final step = QueueStep(
      id: QueueStep.newId(),
      text: text,
      createdAt: DateTime.now(),
      from: from,
      to: to,
      immediate: immediate,
    );
    steps.add(step);
    return step;
  }

  /// Position (1-based) of [step] among the open steps of its lane —
  /// what the row renders (`STEER 2 · 3m`, DESIGN §10 time-made-visible).
  int positionOf(final QueueStep step) =>
      openInLane(from: step.from).toList().indexOf(step) + 1;

  Map<String, Object?> toJson() => {
    'steps': [for (final s in steps) s.toJson()],
  };

  /// Restores steps from the doc payload (return-after-interruption
  /// reconstructs the queue — DESIGN §10). Steps already present (by id)
  /// are skipped: the payload is the durable copy, memory the live one.
  void restoreJson(final String json) {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) return;
    restore(decoded);
  }

  void restore(final Map<String, Object?> json) {
    final raw = json['steps'];
    if (raw is! List<Object?>) return;
    final known = steps.map((final s) => s.id).toSet();
    for (final entry in raw) {
      if (entry is! Map<String, Object?>) continue;
      final step = QueueStep.fromJson(entry);
      if (known.contains(step.id)) continue;
      steps.add(step);
    }
  }

  /// Signature for cheap change detection (persistence sync).
  String get signature => steps
      .map((final s) => '${s.id}:${s.status.name}:${s.text}:${s.immediate}')
      .join('|');
}
