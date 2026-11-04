/// The mesh board bridge: the claim → run → settle discipline of the
/// board runs HERE — never inside a widget (the boards-extraction
/// program, stage 2). This file is the LA glue between three pieces:
///
/// - the frozen wire store: `MeshTaskBoard` (the synced replica whose
///   rows the multiplayer gates diff byte-for-byte — the authority for
///   what peers can see);
/// - the canonical vocabulary: `package:ecsly_boards` — its
///   `runRequestedCards` owns the ONE loop, its write-back hooks are
///   where the replica (the authority) gets the claim and the
///   settlement, and its `BoardTaskStatus` is THE task vocabulary;
/// - the turn capability: a [DocTurnRunner] — what a doc surface (or a
///   test) provides to run one delegated turn on its session.
library;

import 'dart:async';

import 'package:dart_acp_toolkit/dart_acp_toolkit.dart' show AcpStopReason;
import 'package:ecsly/ecsly.dart';
import 'package:ecsly_boards/ecsly_boards.dart';
import 'package:flutter/foundation.dart';
import 'package:lastanswer/coding_agent/mesh_task_board.dart';

/// The turn capability a surface (or a test) hands the bridge: what a
/// widget owns and NOTHING more — the bound workspace and one
/// delegated turn. Claim discipline, verdict honesty, and bookkeeping
/// live in the bridge and the package's loop, testable without widgets.
abstract interface class DocTurnRunner {
  /// The workspace the doc has bound, or null / empty when none — a
  /// request arriving before a workspace is bound FAILS honestly.
  String? get boundWorkspace;

  /// Runs one delegated turn like a composer submit. The outcome
  /// carries only figures the turn truly produced; [DocTurnOutcome.error]
  /// marks a turn that never ran (config, session).
  Future<DocTurnOutcome> runTurn(final String task);
}

/// The honest result of one delegated turn.
@immutable
final class DocTurnOutcome {
  const DocTurnOutcome({
    this.verdictLine,
    this.spend,
    this.stopReason,
    this.error,
  });

  factory DocTurnOutcome.failed(final String error) =>
      DocTurnOutcome(error: error);

  /// The turn's verdict line (PASS/FAIL with figures), when produced.
  final String? verdictLine;

  /// Spend figures — present only when the verdict carried them.
  final ({int decisions, int rounds, int tokens, int wallMs})? spend;

  /// The ACP stop reason name (`endTurn`, `cancelled`, …), when the
  /// turn ran at all.
  final String? stopReason;

  final String? error;

  bool get ran => error == null && stopReason != null;
}

/// Renders turn outcomes onto the canonical vocabulary: a turn that
/// never ran is a FAILED run; a cancelled turn is FAILED with the
/// named reason; figures ride only when they exist (DESIGN §6 —
/// nothing is invented).
final class MeshBoardHost implements BoardHost {
  MeshBoardHost({required this.runner});

  final DocTurnRunner runner;

  @override
  Future<BoardRunOutcome> run(final BoardWorkOrder order) async {
    final workspace = runner.boundWorkspace;
    if (workspace == null || workspace.trim().isEmpty) {
      return const BoardRunOutcome.failed(
        error: 'no workspace bound to the doc yet.',
      );
    }
    final turn = await runner.runTurn(order.title);
    final verdict = turnVerdict(turn);
    if (turn.error != null) {
      return BoardRunOutcome.failed(verdict: verdict, error: turn.error);
    }
    if (turn.stopReason == null) {
      return BoardRunOutcome.failed(
        verdict: verdict,
        error: 'the delegated turn failed with no stop reason.',
      );
    }
    if (turn.stopReason == AcpStopReason.cancelled.name) {
      return BoardRunOutcome.failed(
        verdict: verdict,
        error: 'the delegated turn was cancelled before completion.',
      );
    }
    return BoardRunOutcome.completed(verdict: verdict);
  }
}

/// The verdict map a turn earns: the verdict line, spend figures when
/// the line carried them, and the stop reason — the same shape the
/// gates diff today.
Map<String, Object?> turnVerdict(final DocTurnOutcome turn) => {
  if (turn.verdictLine != null) 'verdict': turn.verdictLine,
  if (turn.spend case final spend?) ...{
    'decisions': spend.decisions,
    'rounds': spend.rounds,
    'tokens': spend.tokens,
    'wallMs': spend.wallMs,
  },
  if (turn.stopReason != null) 'stopReason': turn.stopReason,
};

/// The bridge: one cycle mirrors the replica rows of ITS doc into the
/// canonical World, then the package's loop claims at most one remote
/// request and settles it — with the replica written back at claim and
/// settlement through the loop's hooks. A cycle never throws for task
/// failure; a failed run IS an outcome.
final class MeshBoardBridge {
  MeshBoardBridge({
    required this.board,
    required this.runner,
    required this.docId,
    required this.selfPeerId,
    final World? world,
    this.autoRun = true,
    this.maxRunSeconds = const Duration(minutes: 30),
  }) : _world = world ?? (World()..addPlugin(const BoardsPlugin())),
       _host = MeshBoardHost(runner: runner);

  /// The synced replica (authority + wire).
  final MeshTaskBoard board;

  /// The turn capability this bridge runs orders against.
  final DocTurnRunner runner;

  /// The doc whose requests this host serves.
  final String Function() docId;
  final String Function() selfPeerId;

  /// `autoRunRemoteTasks: false` (tests, viewer shadows) disables the
  /// whole loop — a cycle becomes a pure no-op.
  final bool autoRun;
  final Duration maxRunSeconds;

  final World _world;
  final MeshBoardHost _host;

  bool _cycleInFlight = false;

  /// True while a claimed run is between claim and settlement — the
  /// window the replica row reads `running` to every other peer.
  bool get cycleInFlight => _cycleInFlight;

  /// One sync-cycle step (unawaited by the caller — the bridge is
  /// single-writer and re-entrant cycles are refused while one runs).
  /// Returns the claimed task id, or null.
  Future<String?> cycle() async {
    if (!autoRun || _cycleInFlight) return null;
    _cycleInFlight = true;
    try {
      board.tasksFor(docId()).forEach(_project);
      return await runRequestedCards(
        world: _world,
        host: _host,
        maxRunSeconds: maxRunSeconds,
        selfPeerId: selfPeerId(),
        onClaimed: (final claimed) {
          debugPrint('mesh board bridge: claiming ${claimed.key}');
          board.markRunning(claimed.key);
        },
        onSettled: (final settled, final outcome) {
          final verdict = <String, Object?>{...?outcome.verdict};
          if (outcome.succeeded) {
            board.completeTask(settled.key, verdict: verdict);
          } else {
            board.failTask(settled.key, verdict: verdict, error: outcome.error);
          }
        },
      );
    } finally {
      _cycleInFlight = false;
    }
  }

  /// Projects one replica row into the canonical World (idempotent:
  /// the wire vocabulary IS the canonical one — statuses map by name).
  void _project(final MeshTaskRecord record) {
    final existing = cardOf(_world, record.taskId);
    final status = BoardTaskStatus.values.firstWhere(
      (final s) => s.name == record.status,
      orElse: () => BoardTaskStatus.failed,
    );
    if (existing == null) {
      spawnCard(
        _world,
        key: record.taskId,
        board: board.boardId,
        title: record.task,
        status: status,
        createdAtMs: record.createdAt.millisecondsSinceEpoch,
        originPeerId: record.originPeerId,
        originActorId: record.originActorId,
        verdict: record.verdict,
      );
      _world.flush();
      return;
    }
    if (existing.status != status) {
      moveCard(_world, record.taskId, status);
      _world.flush();
    }
  }
}
