import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart';

/// A deterministic [SessionHandle] for tests and the debug seed verb
/// (`world_inspector_seed`): the same three-member seam the doc surfaces
/// and daemon runners implement, backed by mutable fixture data so the
/// world inspector pane can be exercised — and visually verified — with
/// no provider, no daemon and no inference.
///
/// Honesty law: a seeded session is DATA, never a claim about a real run.
/// Its snapshot declares `kind: 'test'`, and every verb output that reads
/// one says so ([seededMessageSuffix]).
final class ScriptedSessionHandle implements SessionHandle {
  ScriptedSessionHandle({
    required this.sessionId,
    this.kind = 'test',
    this.running = false,
    this.verdict,
    this.spend,
    List<SessionBeat> beats = const [],
    this.pendingPermissionTitle,
    this.pendingPermissionSince,
    this.contextSummary = '',
  }) : _beats = [...beats];

  final String sessionId;
  final String kind;
  final String? verdict;
  final SessionSpend? spend;
  final String contextSummary;

  bool running;
  String? pendingPermissionTitle;
  DateTime? pendingPermissionSince;
  final List<SessionBeat> _beats;
  int _turnCount = 0;

  /// The beats so far (unmodifiable view — mutation goes through the
  /// intent actions, like any handle).
  List<SessionBeat> get beats => List.unmodifiable(_beats);

  @override
  SessionSnapshot get state => SessionSnapshot(
    sessionId: sessionId,
    kind: kind,
    running: running,
    pendingPermissionTitle: pendingPermissionTitle,
    pendingPermissionSince: pendingPermissionSince,
    verdict: verdict,
    spend: spend,
    turnCount: _turnCount,
    beats: List.unmodifiable(_beats),
    contextSummary: contextSummary,
  );

  @override
  SessionIntentResult delegateTask(final String task) {
    final sentence = task.trim();
    if (sentence.isEmpty) {
      return (ok: false, message: 'task sentence is empty');
    }
    _beats
      ..add(SessionBeat(name: 'you', detail: sentence))
      ..add(
        const SessionBeat(
          name: 'ack',
          detail: 'scripted seam accepted the sentence — no actor ran',
        ),
      );
    _turnCount++;
    return (
      ok: true,
      message: 'scripted session $sessionId took the sentence '
          '($_turnCount turn(s)) — no actor ran',
    );
  }

  @override
  SessionIntentResult answerPermission({required final bool allow}) {
    final title = pendingPermissionTitle;
    pendingPermissionSince = null;
    if (title == null) {
      return (
        ok: false,
        message: 'no pending permission on scripted session $sessionId',
      );
    }
    final outcome = allow ? 'allow' : 'reject';
    _beats.add(SessionBeat(name: 'perm', detail: '$title → $outcome'));
    pendingPermissionTitle = null;
    return (
      ok: true,
      message: 'scripted permission "${title.replaceAll('\n', ' ')}" '
          '→ ${allow ? 'allow' : 'reject'}',
    );
  }
}

/// Every verb/pane output that reads a seeded session names the seam —
/// scripted data must never read as a live run (DESIGN §6).
const String seededMessageSuffix =
    ' (scripted fixture — no real actors ran)';

/// The fixture's synthetic clock: fixed UTC offsets from the epoch (the
/// loaders' own tick origin), so replay ordering is deterministic and no
/// fixture ever claims a real wall time.
DateTime _seedTime(int seconds) =>
    DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).add(
      Duration(seconds: seconds),
    );

/// The permission's opening time is a WALL-CLOCK fact (the rule shows
/// its age): a real moment ~2 minutes ago, so "waiting 2m" reads
/// honestly while staying a fixture.
DateTime get _seedPermissionSince =>
    DateTime.now().toUtc().subtract(const Duration(minutes: 2));

SessionBeat _seedBeat(
  String name,
  String detail, {
  int atSeconds = 0,
  String? decisionId,
}) => SessionBeat(
  name: name,
  detail: detail,
  decisionId: decisionId,
  at: _seedTime(atSeconds),
);

/// The deterministic seed fixture: one RUNNING worker with a tool-beat
/// trail (grouped under its decision, time-stamped) and one idle planner
/// carrying a verdict, spend and a pending permission — the things the
/// pane's rule, rail, slates and (soon) time spine render.
Map<String, ScriptedSessionHandle> seedScriptedSessions() => {
  'seed-worker': ScriptedSessionHandle(
    sessionId: 'seed-worker',
    running: true,
    contextSummary: '2 files in scope · budget 12k',
    beats: [
      _seedBeat(
        'tool:read_file',
        'lib/main.dart (42 lines)',
        atSeconds: 1,
        decisionId: 'seed_d1',
      ),
      _seedBeat(
        'thought',
        'the entry point wires the toolkit binding first',
        atSeconds: 2,
        decisionId: 'seed_d1',
      ),
      _seedBeat(
        'tool:dart_test',
        'dart test test/ — 34 passed, 2 failed',
        atSeconds: 3,
        decisionId: 'seed_d1',
      ),
    ],
  ),
  'seed-planner': ScriptedSessionHandle(
    sessionId: 'seed-planner',
    verdict: 'task decomposed: 3 steps, checker dart test',
    spend: const SessionSpend(
      decisions: 4,
      rounds: 2,
      tokens: 12300,
      wallMs: 41200,
    ),
    pendingPermissionTitle: 'Write lib/src/registry.dart',
    pendingPermissionSince: _seedPermissionSince,
    contextSummary: 'plan lane · idle',
    beats: [
      _seedBeat(
        'decompose',
        'task → 3 steps (dstep_1..3)',
        atSeconds: 10,
        decisionId: 'seed_d2',
      ),
      _seedBeat(
        'tool:claim',
        'worker claimed dstep_1 (held)',
        atSeconds: 11,
        decisionId: 'seed_d2',
      ),
    ],
  ),
};
