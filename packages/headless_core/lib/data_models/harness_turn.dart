import 'package:xsoulspace_agentic_host/xsoulspace_agentic_host.dart'
    show
        CodingHostUpdate,
        CodingTaskOutcomeUpdate,
        CodingTaskTerminalState,
        CodingTextPhase,
        CodingTextUpdate,
        CodingVerificationStatus;

import 'actor_roster.dart';

/// One structured beat inside a turn: a tool call the agent made.
final class TurnToolCall {
  TurnToolCall(this.title, this.at);
  final String title;
  final DateTime at;
}

/// One permission round-trip inside a turn. `allowed == null` while the
/// human (or agent) has not answered — deny-by-default is the UI's job to
/// make visible, never to hide.
final class TurnPermission {
  TurnPermission(this.title, this.at);
  final String title;
  final DateTime at;
  bool? allowed;

  /// PLAN 5c — the answer's origin, resolved through the roster at record
  /// time (small-caps actor/device label, DESIGN §9). Null for local
  /// answers: a remote answer is recorded on the turn exactly like a
  /// local one, indistinguishable except by origin (ADR 0005 §5).
  String? originLabel;
}

/// One delegated task turn — the conversation node. The raw transcript
/// string stays the record (tests, debugState); [HarnessTurn] is the
/// structured projection the doc surface renders (small multiples: every
/// turn is laid out identically — task sentence, agent text, tool beats,
/// permission round-trips, verdict with spend).
final class HarnessTurn {
  HarnessTurn(this.taskSentence, this.startedAt);

  /// PLAN 9 — mutable once the turn COOLS (verdict landed): cooled turns
  /// are editable like document text (ADR 0010 D2); the pre-edit sentence
  /// is appended to [editHistory] — simple before/after, no diff engine.
  String taskSentence;
  final DateTime startedAt;

  /// PLAN 9 — per-turn edit history (first slice): the prior version(s)
  /// of [taskSentence], oldest first. Rendered as the dim `EDITED` SYS
  /// annotation with tap-to-expand (same mechanic as beats).
  final List<String> editHistory = [];

  bool get edited => editHistory.isNotEmpty;

  /// PLAN 9 — the turn was stopped before its verdict (send-now / stop):
  /// the verdict LANDS with whatever partial spend exists — honest, never
  /// fabricated (the harness emits no spend figures on cancel; the
  /// client renders only what it truly observed: beats + wall time).
  bool interrupted = false;

  /// R9.a — escalation guidance this turn continues (host-injected via
  /// `agent_task_guide`). First-class grid data, not a transcript line.
  String? guidance;
  final StringBuffer text = StringBuffer();
  final _provisionalText = <String, StringBuffer>{};
  final _settledText = <String>{};
  String get displayedText => '$text${_provisionalText.values.join()}';

  void observeText(CodingTextUpdate update) {
    if (_settledText.contains(update.requestId)) return;
    if (update.phase == CodingTextPhase.delta) {
      _provisionalText
          .putIfAbsent(update.requestId, StringBuffer.new)
          .write(update.text);
    } else {
      _provisionalText.remove(update.requestId);
      _settledText.add(update.requestId);
      if (update.text.isNotEmpty) text.write('${update.text} ');
    }
  }

  final List<TurnToolCall> toolCalls = [];
  final List<CodingHostUpdate> hostUpdates = [];
  final List<TurnPermission> permissions = [];
  String? verdictLine;
  DateTime? completedAt;

  CodingTaskOutcomeUpdate? get outcome =>
      hostUpdates.whereType<CodingTaskOutcomeUpdate>().lastOrNull;
  bool get completedUnverified =>
      outcome?.terminalState == CodingTaskTerminalState.completed &&
      outcome?.acceptance.status == CodingVerificationStatus.notRun;
  bool get hasVerdict => verdictLine != null;
  bool get verdictPassed => verdictLine?.contains('PASS') ?? false;
  bool get isDone => completedAt != null;

  /// Spend parsed from the verdict line — the tokens source is the backend
  /// verdict chunk (never a guess). Null until the turn ends. An
  /// interrupted turn's verdict line carries NO spend figures (the
  /// backend emits none on cancel) — returning null there keeps zeros
  /// from ever being fabricated into a spend (DESIGN §6).
  ({int decisions, int rounds, int tokens, int wallMs})? get spend {
    if (interrupted) return null;
    final typed = outcome;
    if (typed != null) {
      final values = {
        for (final measure in typed.usage)
          measure.metric: measure.value?.toInt(),
      };
      final decisions = values['decisions'];
      final rounds = values['tool_rounds'];
      final tokens = values['projection_tokens'];
      final wall = values['wall_ms'];
      if (decisions == null ||
          rounds == null ||
          tokens == null ||
          wall == null) {
        return null;
      }
      return (
        decisions: decisions,
        rounds: rounds,
        tokens: tokens,
        wallMs: wall,
      );
    }
    // Previously saved projection strings remain readable; live model text
    // never sets verdictLine. New host results use the typed path above.
    final v = verdictLine;
    if (v == null || !v.contains('decisions')) return null;
    int? figure(final String label) {
      final match = RegExp('$label (\\d+)').firstMatch(v);
      return match == null ? null : int.tryParse(match.group(1)!);
    }

    return (
      decisions: figure('decisions') ?? 0,
      rounds: figure('rounds') ?? 0,
      tokens: figure('tokens') ?? 0,
      wallMs: figure('wall') ?? 0,
    );
  }
}

/// One visible harness session: id, delegated workspace, the streamed
/// transcript, structured turns, and the latest surfaced verdict.
///
/// A session is a TRANSCRIPT PROJECTION onto the workspace's world, not
/// the world itself (ADR 0006): several sessions may sit on one workspace
/// — one world, one daemon — and each carries its own turn stream.
/// [viewId] is projection-local (unique per view even when two views
/// share the host's per-workspace session id); [id] is the host session.
final class HarnessSessionView {
  HarnessSessionView({required this.id, required this.cwd})
    : viewId = _nextViewId++;

  static int _nextViewId = 1;

  final String id;
  final int viewId;
  final String cwd;
  final StringBuffer transcript = StringBuffer();
  final List<HarnessTurn> turns = [];
  String? verdictLine;
  bool running = false;

  /// ADR 0006 registry `Actors[]`, roster-backed (ADR 0007 §4): stable,
  /// syncable ids — display identity resolves through the roster at read
  /// time ([actors]), so a late-arriving profile lights the row up without
  /// a registry rewrite.
  final List<String> actorIds = [];

  /// Resolves [actorIds] through [roster]. Unknown (not yet synced) ids
  /// are skipped, never guessed — honest surfaces (DESIGN §6).
  List<ActorProfile> actors(final ActorRoster roster) => [
    for (final actorId in actorIds) ?roster.get(actorId),
  ];

  bool get hasVerdict => verdictLine != null;
  bool get verdictPassed => verdictLine?.contains('PASS') ?? false;
  HarnessTurn? get openTurn => turns.isEmpty ? null : turns.last;
}

/// One bound workspace in the session registry (ADR 0006):
/// `Workspace (≤1 world/daemon) → Sessions[] → Actors[]`. The backend
/// keys sessions per cwd — a second `session/new` for the same workspace
/// CONTINUES the live world — so every session listed here is a
/// projection on one single-writer world.
final class HarnessWorkspaceView {
  HarnessWorkspaceView({required this.cwd});

  final String cwd;
  final List<HarnessSessionView> sessions = [];
}
