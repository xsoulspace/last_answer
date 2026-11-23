import 'dart:convert';

import 'package:lastanswer/common_imports.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The board→realm delegation seam (ADR 0039 stage 4): dispatch is an
/// op (ADR 0013) — the board PROPOSES a planning card as realm work;
/// the workspace owner's seat admits it through `task op:create`. The
/// shell builds the seam over the app's own harness client
/// (`SupervisorService.resolveAgentClient`); the boards module stays a
/// leaf and only sees this function type.
///
/// The result names the honest outcome: the admitted task id, or the
/// EXACT refusal in words — never a fabricated success.
typedef BoardDelegate = Future<BoardDelegationResult> Function(String title);

/// The outcome of one delegate op: [taskId] when the world admitted the
/// task, or [refusal] (the world's own words) when it did not. Exactly
/// one side is set.
final class BoardDelegationResult {
  const BoardDelegationResult.admitted(this.taskId) : refusal = null;
  const BoardDelegationResult.refused(this.refusal) : taskId = null;

  final String? taskId;
  final String? refusal;

  bool get ok => taskId != null;
}

/// The cardId→taskId provenance of delegated planning cards.
///
/// Storage law: an APP-SIDE map, deliberately NOT a replica field —
/// the planning replica's wire is byte-frozen (the merge lane's
/// contract) and planning cards must not become journal rows. The
/// durable task itself is world truth; this ledger only remembers
/// which card asked for it. SharedPreferences keeps the map across
/// runs; a lost row degrades to a card without provenance (honest
/// absence, the coordination board still shows the task).
final class BoardDelegationLedger {
  static const _prefsKey = 'boards.delegationLedger.v1';

  final Map<String, String> _byCardId = {};
  bool _loaded = false;

  /// Loads the persisted map once (a view calls this on mount; reads
  /// before it degrade to honest absence for that beat). Never throws.
  Future<void> ensureLoaded() async {
    try {
      final prefs = _cached ??= await SharedPreferences.getInstance();
      if (_loaded) return;
      _loaded = true;
      final raw = prefs.getString(_prefsKey);
      if (raw case final json?) {
        final decoded = jsonDecode(json);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final cardId = '${entry.key}';
            final taskId = '${entry.value}';
            if (cardId.isNotEmpty && taskId.isNotEmpty) {
              _byCardId[cardId] = taskId;
            }
          }
        }
      }
    } on Object {
      // An unreadable store keeps the in-memory truth.
    }
  }

  /// Records one admitted delegation (card → task). In-memory first;
  /// persistence is best-effort (a failed write keeps the session
  /// truth and names nothing — the next record retries).
  Future<void> record(final String cardId, final String taskId) async {
    _byCardId[cardId] = taskId;
    try {
      final prefs = _cached ??= await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(_byCardId));
    } on Object {
      // The session truth stands; the next record retries the write.
    }
  }

  /// The task id a card delegated, when the ledger knows one.
  String? taskIdOf(final String cardId) => _byCardId[cardId];

  static SharedPreferences? _cached;
}
